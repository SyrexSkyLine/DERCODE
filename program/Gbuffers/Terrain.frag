layout(location = 0) out vec3 albedoData;
layout(location = 2) out vec4 colortex3Out;

/* DRAWBUFFERS:673 */

#include "/lib/Head/Common.inc"

#ifdef PARALLAX_SHADOW
layout(location = 1) out vec4 colortex7Out;
#else
layout(location = 1) out vec3 colortex7Out;
#endif

uniform sampler2D tex;
#ifdef MC_NORMAL_MAP
uniform sampler2D normals;
#endif
#ifdef MC_SPECULAR_MAP
uniform sampler2D specular;
#endif

uniform mat4 gbufferModelView;
uniform vec3 cameraPosition;
uniform vec3 worldLightVector;

in vec4 tint;
in vec2 texcoord;
in vec3 minecraftPos;
in vec3 viewPos;
in vec2 lightmap;
flat in mat3 tbnMatrix;
flat in uint materialIDs;
uniform int frameCounter;

#if defined PARALLAX || ANISOTROPIC_FILTER > 0
in vec2 tileCoord;
flat in vec2 tileOffset;
flat in vec2 tileScale;
vec2 OffsetCoord(in vec2 coord) { return tileOffset + tileScale * fract(coord); }
#endif

float InterleavedGradientNoiseTemporal(in vec2 coord) {
    return fract(52.9829189 * fract(0.06711056 * coord.x + 0.00583715 * coord.y + 0.00623715 * (frameCounter & 63)));
}

#ifdef PARALLAX
#include "/lib/Surface/Parallax.glsl"
#endif

#if ANISOTROPIC_FILTER > 0
vec3 AnisotropicFilter(in vec2 baseCoord, in mat2 texGrad) {
    mat2 J = inverse(texGrad);
    J = transpose(J) * J;
    float d = determinant(J);
    float t = J[0][0] + J[1][1];
    float D = sqrt(max0(t * t - 4.0 * d));
    float V = (t - D) * 0.5;
    float v = (t + D) * 0.5;
    float l = log2(inversesqrt(v));
    vec2 A = inversesqrt(V) * normalize(vec2(-J[0][1], J[0][0] - V));
    A /= tileScale;
    float c = 0.0;
    vec3 albedo = vec3(0.0);
    for (float i = 0.5 / ANISOTROPIC_FILTER - 0.5; i < 0.5; i += 1.0 / ANISOTROPIC_FILTER) {
        vec2 sampleCoord = OffsetCoord(baseCoord + i * A);
        vec4 albedoSample = textureLod(tex, sampleCoord, l);
        if (albedoSample.a > 1e-3) { albedo += albedoSample.rgb; ++c; }
    }
    return albedo / max(c, 1.0);
}
#endif

#if defined IS_OVERWORLD
uniform sampler2D noisetex;
uniform sampler2D colortex7;
uniform mat4 gbufferModelViewInverse;
uniform float frameTimeCounter;
uniform float wetnessCustom;
#include "/lib/Surface/RainEffect.glsl"
#endif

// === DEBUG / OVERLAY MODE ===
#define LIGHT_OVERLAY 0 // [0 1] — 0 = выкл, 1 = включить оверлей света (X-метки как в моде)
#define CHUNK_OVERLAY 0 // [0 1] — 0 = выкл, 1 = включить оверлей чанков (тint границ)

void main() {
    vec3 normalData;
    vec4 albedo = tint;
    float dither = InterleavedGradientNoiseTemporal(gl_FragCoord.xy);
    vec2 texGradX = dFdx(texcoord);
    vec2 texGradY = dFdy(texcoord);
    mat2 texGrad = mat2(texGradX, texGradY);

    #ifdef PARALLAX
        #define ReadTexture(tex) textureGrad(tex, parallaxCoord, texGradX, texGradY)
        vec2 parallaxCoord = texcoord;
        #ifdef SMOOTH_PARALLAX
            float sampleHeight = BilinearHeightSample(texcoord);
        #else
            float sampleHeight = ReadTexture(normals).a;
        #endif
        vec3 offsetCoord;
        if (sampleHeight < 0.999) {
            vec3 tangentViewVector = normalize(viewPos.xyz) * tbnMatrix;
            offsetCoord = CalculateParallax(tangentViewVector, texGrad, dither);
            parallaxCoord = OffsetCoord(offsetCoord.xy);
        }
        #ifdef MC_NORMAL_MAP
            normalData = ReadTexture(normals).rgb;
            DecodeNormalTex(normalData);
        #else
            normalData = vec3(0.0, 0.0, 1.0);
        #endif
        if (sampleHeight < 0.999) {
            #ifdef PARALLAX_SHADOW
                if (offsetCoord.z < 0.9999) {
                    vec3 viewLightVector = mat3(gbufferModelView) * worldLightVector;
                    if (dot(tbnMatrix[2], viewLightVector) > 1e-3)
                        colortex7Out.w = CalculateParallaxShadow(viewLightVector * tbnMatrix, offsetCoord, texGrad, dither);
                    #ifdef PARALLAX_BASED_NORMAL
                        vec2 shift = 1e-2 * tileScale;
                        float rD = textureGrad(normals, OffsetCoord(offsetCoord.xy + vec2(shift.x, 0.0)), texGradX, texGradY).a;
                        float lD = textureGrad(normals, OffsetCoord(offsetCoord.xy - vec2(shift.x, 0.0)), texGradX, texGradY).a;
                        float uD = textureGrad(normals, OffsetCoord(offsetCoord.xy + vec2(0.0, shift.y)), texGradX, texGradY).a;
                        float dD = textureGrad(normals, OffsetCoord(offsetCoord.xy - vec2(0.0, shift.y)), texGradX, texGradY).a;
                        normalData = vec3((lD - rD), (dD - uD), step(abs(lD - rD) + abs(dD - uD), 1e-3));
                    #endif
                }
            #endif
        }
        #if ANISOTROPIC_FILTER > 0
            if (materialIDs != 15u) {
                albedo.rgb *= AnisotropicFilter((parallaxCoord - tileOffset) / tileScale, texGrad);
                albedo.a *= ReadTexture(tex).a;
            } else
        #endif
    #else
        #define ReadTexture(tex) texture(tex, texcoord)
        #ifdef MC_NORMAL_MAP
            normalData = ReadTexture(normals).rgb;
            DecodeNormalTex(normalData);
        #else
            normalData = vec3(0.0, 0.0, 1.0);
        #endif
        #if ANISOTROPIC_FILTER > 0
            if (materialIDs != 15u) {
                albedo.rgb *= AnisotropicFilter(tileCoord, texGrad);
                albedo.a *= ReadTexture(tex).a;
            } else
        #endif
    #endif

    albedo *= ReadTexture(tex);

    if (albedo.a < 0.1) {
        discard;
        return;
    }
    #ifdef WHITE_WORLD
        albedo.rgb = vec3(1.0);
    #endif

    #ifdef MC_SPECULAR_MAP
        vec4 specularData = ReadTexture(specular);
    #else
        vec4 specularData = vec4(0.0);
    #endif

    if (materialIDs == 9u || materialIDs == 59u) {
        if (materialIDs == 9u && albedo.r > 0.6 && albedo.g > 0.6 && albedo.b > 0.6) {
            specularData.r = 0.9; specularData.g = 0.2; specularData.b = 0.0;
        } else if (materialIDs == 59u && albedo.r > albedo.g * 1.2 && albedo.r > albedo.b * 1.5) {
            specularData.r = 0.7; specularData.g = 0.3; specularData.b = 0.0;
        } else if (materialIDs == 59u && albedo.b > albedo.r * 1.1 && albedo.b > albedo.g * 1.1) {
            specularData.r = 0.95; specularData.g = 0.1; specularData.b = 0.0;
            albedo.rgb *= vec3(0.8, 0.9, 1.0);
        }
    }

    #if defined IS_OVERWORLD
        if (wetnessCustom > 1e-2) {
            float noise = GetRainWetness(minecraftPos.xz - minecraftPos.y);
            noise *= remap(0.5, 0.9, (mat3(gbufferModelViewInverse) * tbnMatrix[2]).y);
            noise *= saturate(lightmap.y * 10.0 - 9.0);
            float wetFact = smoothstep(0.54, 0.62, noise);
            #ifdef RAIN_SPLASH_EFFECT
                normalData = mix(normalData.xyz, vec3(GetRainNormal(minecraftPos), 1.0), wetFact * 0.5);
            #else
                normalData = mix(normalData.xyz, vec3(0.0, 0.0, 1.0), wetFact);
            #endif
            wetFact = sqr(remap(0.35, 0.57, noise));
            #ifdef FORCE_WET_EFFECT
                specularData.r = mix(specularData.r, 1.0, wetFact);
                specularData.g = max(specularData.g, 0.04 * wetFact);
                specularData.rg += (dither - 0.5) * rcp(255.0);
            #endif
            vec3 wetAlbedo = ColorSaturation(albedo.rgb, 0.75) * 0.85;
            #ifdef POROSITY
                float porosity = specularData.b > 64.5 / 255.0 ? 0.0 : remap(specularData.b, 0.0, 64.0 / 255.0) * 0.7;
                wetAlbedo *= oneMinus(porosity) / oneMinus(porosity * wetAlbedo);
            #endif
            albedo.rgb = mix(albedo.rgb, wetAlbedo, sqr(remap(0.3, 0.56, noise)));
        }
    #endif

    normalData = normalize(tbnMatrix * normalData);
    albedoData = albedo.rgb;

    // === OVERLAYS LIKE IN MOD ===
    #if LIGHT_OVERLAY == 1
        float blockLight = lightmap.x; // Block/torch light (0-1)
        float skyLight = lightmap.y;   // Sky light (0-1)
        if (blockLight < 1.0 / 15.0) { // Условие спауна: block light ≈0
            vec2 uv = fract(minecraftPos.xz); // UV внутри блока (0-1)
            float line1 = abs(uv.x - uv.y);
            float line2 = abs(uv.x + uv.y - 1.0);
            float thickness = 0.1; // Толщина линий X (0.05-0.15)
            if (min(line1, line2) < thickness) {
                vec3 maskColor = (skyLight < 0.5 ? vec3(1.0, 0.0, 0.0) : vec3(1.0, 1.0, 0.0)); // Красный (пещеры) или жёлтый (поверхность)
                float fade = 0.8; // Прозрачность оверлея (0-1)
                albedoData = mix(albedoData, maskColor, fade);
            }
        }
    #endif

    #if CHUNK_OVERLAY == 1
        float modX = mod(minecraftPos.x, 16.0);
        float modZ = mod(minecraftPos.z, 16.0);
        bool borderX = (modX < 0.1 || modX > 15.9);
        bool borderZ = (modZ < 0.1 || modZ > 15.9);
        if (borderX || borderZ) {
            vec3 maskColor = vec3(1.0, 0.0, 0.0); // Красный для границ
            float fade = 0.5; // Прозрачность
            albedoData = mix(albedoData, maskColor, fade);
        }
    #endif

    colortex7Out.xy = lightmap + (dither - 0.5) * rcp(255.0);
    colortex7Out.z = float(materialIDs + 0.1) * rcp(255.0);
    colortex3Out.xy = EncodeNormal(normalData);
    colortex3Out.z = PackUnorm2x8(specularData.rg);
    colortex3Out.w = PackUnorm2x8(specularData.ba);
}