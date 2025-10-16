#version 450 compatibility

#define IS_END
#define SUBSURFACE_SCATTERING_STRENGTH 1.0 // Fix for undeclared identifier error

// NEW: End Flash params (configurable via uniforms if needed)
// Adjusted to match vanilla Minecraft End flashes more closely (from 1.21.9+ Java / Bedrock equivalents)
// Duration: 5-19 sec (randomized), Interval: ~30 sec average delay between flashes
// Reduced brightness overall to avoid overexposure
#define END_FLASH_COLOR        vec3(0.4, 0.1, 0.5)  // Фиолетовый tint для вспышки (purple as in vanilla)
#define END_FLASH_TINT         vec3(0.5, 0.1, 0.6)  // Пурпурный оттенок для lighting
#define END_FLASH_DURATION_MIN 5.0                  // Минимальная длительность вспышки
#define END_FLASH_DURATION_MAX 19.0                 // Максимальная длительность вспышки
#define END_FLASH_INTERVAL_MIN 25.0                 // Минимальный кулдаун (adjusted for ~30 sec avg)
#define END_FLASH_INTERVAL_MAX 35.0                 // Максимальный кулдаун
#define END_FLASH_FADE_TIME    2.0                  // Время fade in/out
#define END_FLASH_SIZE         0.1                  // Размер диска вспышки на небе (increased for better visibility)
#define END_FLASH_BRIGHTNESS   1.5                  // Яркость в небе + lighting boost (reduced from 3.0)

#define END_FOG_COLOR        vec3(0.02, 0.0, 0.05)       // Почти чёрный туман
#define END_SKY_COLOR        vec3(2.5, 2.8, 1.0)         // Холодное синее сияние
#define END_SKY_DARK_COLOR   vec3(2.5, 2.6, 1.5)         // Очень тёмный синий
#define END_LIGHT_COLOR      vec3(2.8, 3.0, 5.0)         // Свет как из туманности
#define END_LIGHT_DARK_COLOR vec3(1.0, 1.2, 3.5)         // Холодное затемнение
#define END_SHADOW_COLOR     vec3(2.7, 2.75, 1.9)        // Лёгкий синий оттенок в тенях

layout(location = 0) out vec2 specularData;
layout(location = 1) out vec3 sceneData;

uniform sampler2DShadow shadowtex1;
uniform sampler2D shadowtex0;
uniform sampler2D shadowcolor0;
uniform sampler2D shadowcolor1;

in vec2 screenCoord;

flat in vec3 blocklightColor;

#include "/lib/Head/Common.inc"
#include "/lib/Head/Uniforms.inc"

#ifdef DARK_END
    bool darkEnd = bossBattle == 2 || bossBattle == 3;
#else
    const bool darkEnd = false;
#endif

// NEW: Function to simulate flash state (0-1 intensity)
// Fixed the bug where subsequent flashes blink rapidly by declaring interval and duration outside the loop
// Uses a loop to accumulate cycles with stable per-cycle random intervals (fixed noise seeds per cycle)
// Randomized duration to match vanilla (5-19 sec), interval ~30 sec avg
// Limited loop to 10 iterations to prevent shader compile issues or performance hits
float GetEndFlashIntensity() {
    float time = frameTimeCounter;
    float accumulated = 0.0;
    float cycle_index = 0.0;
    float interval = 0.0; // Declare outside loop
    float duration = 0.0; // Declare outside loop
    const float max_loops = 10.0; // Safety limit

    while (accumulated < time && cycle_index < max_loops) {
        // Use fixed noise per cycle (based on cycle_index)
        vec2 noiseCoordInterval = vec2(cycle_index * 0.05, 0.0);
        interval = mix(END_FLASH_INTERVAL_MIN, END_FLASH_INTERVAL_MAX, textureLod(noisetex, noiseCoordInterval, 0).x);

        vec2 noiseCoordDuration = vec2(cycle_index * 0.05, 0.5); // Different seed for duration
        duration = mix(END_FLASH_DURATION_MIN, END_FLASH_DURATION_MAX, textureLod(noisetex, noiseCoordDuration, 0).x);

        float cycleLength = interval + duration;

        accumulated += cycleLength;
        cycle_index += 1.0;
    }

    // Backtrack to current cycle
    accumulated -= (interval + duration); // Now interval and duration are defined
    float local_time = time - accumulated;

    float intensity = 0.0;
    if (local_time < duration) {
        // Fade in (0–fade_time), hold, fade out (duration - fade_time – duration)
        float fadeIn = smoothstep(0.0, END_FLASH_FADE_TIME, local_time);
        float fadeOut = smoothstep(duration, duration - END_FLASH_FADE_TIME, local_time);
        intensity = fadeIn * fadeOut;
    }

    return intensity;
}

// NEW: Render flash as a bright purple disk/circle in sky
// Improved to look more like a distinct purple circle with soft edges (added glow effect)
vec3 RenderEndFlash(in vec3 worldDir) {
    vec3 flashDir = normalize(vec3(sin(frameTimeCounter * 0.1), cos(frameTimeCounter * 0.1), 0.5));  // Медленное движение
    float flashDot = dot(worldDir, flashDir);
    // Smooth disk with glow (for better circle appearance)
    float flash = smoothstep(1.0 - END_FLASH_SIZE, 1.0, flashDot);
    flash *= smoothstep(END_FLASH_SIZE * 0.5, 0.0, flashDot - (1.0 - END_FLASH_SIZE));
    // Add subtle glow around the circle
    float glow = pow(flash, 4.0) * 0.5;
    flash += glow;
    float intensity = GetEndFlashIntensity();
    return flash * END_FLASH_BRIGHTNESS * intensity * END_FLASH_COLOR;
}

//----// STRUCTS //-------------------------------------------------------------------------------//

#include "/lib/Head/Mask.inc"
#include "/lib/Head/Material.inc"

//----// FUNCTIONS //-----------------------------------------------------------------------------//

#include "/lib/Head/Functions.inc"

vec2 rot2D(vec2 p, float a) {
    float s = sin(a);
    float c = cos(a);
    return mat2(c, -s, s, c) * p;
}

float HenyeyGreensteinPhase(in float cosTheta, in const float g) { // Henyey Greenstein
    const float gg = sqr(g);
    float phase = 1.0 + gg - 2.0 * g * cosTheta;
    return oneMinus(gg) / (4.0 * PI * phase * (phase * 0.5 + 0.5));
}

#include "/lib/Lighting/SunLighting.glsl"

//#include "/lib/Water/WaterFog.glsl"

#ifdef GI_ENABLED
    vec4 SpatialFilter(in vec3 normal, in float dist, in float NdotV) {
        ivec2 texel = ivec2(gl_FragCoord.xy) / 2;

        float sumWeight = 0.1;
        vec4 light = texelFetch(colortex0, texel, 0) * sumWeight;

        for (uint i = 0u; i < 16u; ++i) {
            ivec2 offset = offset4x4[i];
            ivec2 sampleTexel = texel + offset * 2;
            if (clamp(sampleTexel, ivec2(1), ivec2(screenSize * 0.5) - 1) != sampleTexel) continue;

            vec4 prevData = texelFetch(colortex0, sampleTexel + ivec2(viewWidth * 0.5, 0), 0);

            float weight = exp2(-dotSelf(offset) * 0.1);
            weight *= exp2(-distance(prevData.w, dist) * 4.0 * NdotV); // Dist
            weight *= pow16(max0(dot(prevData.xyz, normal))); // Normal

            light += texelFetch(colortex0, sampleTexel, 0) * weight;
            sumWeight += weight;
        }

        light /= max(1e-6, sumWeight);
        //light.rgb = SRGBtoLinear(light.rgb);

        return light;
    }
#endif

#define coneAngleToSolidAngle(x) (TAU * oneMinus(cos(x)))

float fastAcos(float x) {
    float a = abs(x);
    float r = 1.570796 - 0.175394 * a;
    r *= sqrt(1.0 - a);

    return x < 0.0 ? PI - r : r;
}

vec3 RenderBlackHole(in vec3 worldDir) {
    vec3 skyPos = mat3(shadowModelView) * worldDir;

    #if defined WORLD_LIGHT && !defined FORCE_DISABLE_DAY_CYCLE
        if (dayCycle < 1) skyPos.xz = -skyPos.xz;
    #endif

    const float blackHoleSize = 1024.0 - 0.5 * 64.0; // Slightly smaller black hole
    float blackHoleVar = blackHoleSize - skyPos.z * 1024.0;

    if (blackHoleVar <= 0.0) return vec3(0.0);

    float blackHole = 1.0 / max(1.0, blackHoleVar);

    // Distortion application
    const float rotationFactor = TAU * 16.0;
    skyPos.xy = rot2D(skyPos.xy, blackHole * rotationFactor);

    // Polar coordinates for spiral rings
    float cos_theta = skyPos.z;
    float sin_theta = sqrt(1.0 - cos_theta * cos_theta);
    float phi = atan(skyPos.y, skyPos.x);
    float r_proj = sin_theta * blackHole;

    // Spiral twist towards the center
    float twist_speed = frameTimeCounter * 2.0;
    float spiral_twist = twist_speed * (1.0 - cos_theta);
    phi += spiral_twist * log(max(0.01, r_proj + 0.1)) * 5.0;

    // Noise coordinates for rings with spiral
    vec2 noise_coord = vec2(
        r_proj * 10.0,  // Radial frequency
        (phi / TAU + 0.5) * blackHole * 0.5  // Azimuthal with twist
    );

    float rings = textureLod(noisetex, noise_coord, 0).x;

    vec3 bhColor = ((rings * blackHole * 0.9 + blackHole * 0.1) * 1.0) * END_LIGHT_COLOR;

    return bhColor;
}

vec3 RenderStars(in vec3 worldDir) {
    const float scale = 288.0;
    const float coverage = 0.02;
    const float maxLuminance = 5.0;
    const int minTemperature = 4000;
    const int maxTemperature = 8000;

    float visibility = oneMinus(exp2(-max0(worldDir.y) * 2.0));

    float cosine = worldSunVector.z;
    vec3 axis = cross(worldSunVector, vec3(0, 0, 1));
    float cosecantSquared = rcp(dotSelf(axis));
    worldDir = cosine * worldDir + cross(axis, worldDir) + (cosecantSquared - cosecantSquared * cosine) * dot(axis, worldDir) * axis;

    vec3  p = worldDir * scale;
    ivec3 i = ivec3(floor(p));
    vec3  f = p - i;
    float r = dotSelf(f - 0.5);

    vec3 i3 = fract(i * vec3(443.897, 441.423, 437.195));
    i3 += dot(i3, i3.yzx + 19.19);
    vec2 hash = fract((i3.xx + i3.yz) * i3.zy);
    hash.y = 2.0 * hash.y - 4.0 * hash.y * hash.y + 3.0 * hash.y * hash.y * hash.y;

    float cov = smoothstep(oneMinus(coverage), 1.0, hash.x);
    return visibility * maxLuminance * smoothstep(0.25, 0.0, r) * cov * cov * Blackbody(mix(minTemperature, maxTemperature, hash.y));
}

//----// MAIN //----------------------------------------------------------------------------------//
void main() {
    ivec2 texel = ivec2(gl_FragCoord.xy);

    float depth = GetDepthFix(texel);

    vec3 viewPos = ScreenToViewSpace(vec3(screenCoord, depth));

    #if defined DISTANT_HORIZONS
        if (depth >= 1.0) {
            depth = GetDepthDH(texel);
            viewPos = ScreenToViewSpaceDH(vec3(screenCoord, depth));
        }
    #endif

    vec3 worldPos = mat3(gbufferModelViewInverse) * viewPos;
    vec3 worldDir = normalize(worldPos);

    vec4 gbuffer7 = texelFetch(colortex7, texel, 0);

    int materialID = int(gbuffer7.z * 255.0);

    // NEW: Compute flash intensity once
    float endFlashIntensity = GetEndFlashIntensity();

    if (depth >= 1.0 && materialID != 36) {
        // Sky with customizable End colors and fog
        sceneData = mix(END_SKY_COLOR, END_SKY_DARK_COLOR, float(darkEnd) * 0.9) * exp2(-max0(worldDir.y) * 1.5);
        sceneData = mix(sceneData, END_FOG_COLOR, 0.5); // Apply fog color to sky

        if (!darkEnd) {
            vec3 blackHoleDisc = RenderBlackHole(worldDir);
            vec3 stars = RenderStars(worldDir);
            // NEW: Add flash to sky
            vec3 endFlash = RenderEndFlash(worldDir);
            sceneData += blackHoleDisc + stars + endFlash;
        }

        specularData = vec2(1.0, 0.0);
    } else {
        sceneData = vec3(0.0);

        vec3 albedoRaw = texelFetch(colortex6, texel, 0).rgb;
        vec3 albedo = SRGBtoLinear(albedoRaw);

        vec4 gbuffer3 = texelFetch(colortex3, texel, 0);

        bool isGrass = materialID == 6 || materialID == 27 || materialID == 28 || materialID == 33;

        vec2 mcLightmap = gbuffer7.rg;

        vec3 normal = DecodeNormal(gbuffer3.xy);
        vec3 worldNormal = mat3(gbufferModelViewInverse) * normal;

        vec4 specTex = vec4(UnpackUnorm2x8(gbuffer3.z), UnpackUnorm2x8(gbuffer3.w));
        Material material = GetMaterialData(specTex);
        specTex.x = sqr(1.0 - specTex.x);
        specularData = specTex.xy;

        float rawNdotL = dot(worldNormal, worldLightVector);

        if (isGrass) worldNormal = vec3(0.0, 1.0, 0.0);

        float opaqueDepth = -viewPos.z;
        float LdotV = dot(worldLightVector, -worldDir);

        float NdotV = saturate(dot(worldNormal, -worldDir));
        float NdotL = max0(dot(worldNormal, worldLightVector));
        float halfwayNorm = inversesqrt(2.0 * LdotV + 2.0);
        float NdotH = (NdotL + NdotV) * halfwayNorm;
        float LdotH = LdotV * halfwayNorm + halfwayNorm;

        // Sunlight with customizable End lighting color
        vec3 waterTint = isEyeInWater == 1 ? vec3(0.6, 0.9, 1.2) / max(3.0, opaqueDepth * 0.1 * WATER_FOG_DENSITY) : vec3(1.0);
        vec3 sunlightMult = darkEnd ? END_LIGHT_DARK_COLOR : END_LIGHT_COLOR;
        sunlightMult *= waterTint;
        sunlightMult = mix(sunlightMult, END_FOG_COLOR, 0.3); // Apply fog color to lighting
        // NEW: Apply purple tint during flash
        sunlightMult *= mix(vec3(1.0), END_FLASH_TINT, endFlashIntensity);
        vec3 diffuse = vec3(1.0);

        #ifdef TAA_ENABLED
            float dither = BlueNoiseTemporal();
        #else
            float dither = InterleavedGradientNoise(gl_FragCoord.xy);
        #endif

        worldPos += gbufferModelViewInverse[3].xyz;

        float distortFactor;
        vec3 normalOffset = worldNormal * (dotSelf(worldPos) * 4e-5 + 2e-2) * (2.0 - saturate(NdotL));

        vec3 shadowProjPos = WorldPosToShadowProjPosBias(worldPos + normalOffset, distortFactor);

        float distanceFade = saturate(pow16(rcp(shadowDistance * shadowDistance) * dotSelf(worldPos)));

        vec2 blockerSearch = BlockerSearch(shadowProjPos, dither);

        if (materialID == 35 || materialID == 36) specTex.ba += 0.2;

        #if TEXTURE_FORMAT == 0 && defined MC_SPECULAR_MAP
            float hasSSScattering = step(64.5 / 255.0, specTex.b);
            float sssAmount = oneMinus(distanceFade) * remap(64.0 / 255.0, 1.0, specTex.b * hasSSScattering) * SUBSURFACE_SCATTERING_STRENGTH;
        #else
            float sssAmount = oneMinus(distanceFade) * remap(64.0 / 255.0, 1.0, specTex.a) * SUBSURFACE_SCATTERING_STRENGTH;
        #endif
        if (sssAmount > 1e-4) {
            vec3 subsurfaceScattering = CalculateSubsurfaceScattering(albedo, sssAmount, blockerSearch.y, LdotV);
            sunlightMult *= 1.0 - sssAmount * 0.5;
            sceneData += subsurfaceScattering * sunlightMult;
        }

        vec3 shadow = vec3(0.0);
        vec3 specular = vec3(0.0);
        if (NdotL > 1e-3) {
            float penumbraScale = max(blockerSearch.x / distortFactor, 2.0 / realShadowMapRes);
            shadow = PercentageCloserFilter(shadowProjPos, dither, penumbraScale);

            if (maxOf(shadow) > 1e-6) {
                #ifdef SCREEN_SPACE_SHADOWS
                    shadow *= ScreenSpaceShadow(viewPos, vec3(screenCoord, depth), dither, sssAmount);
                #endif
                diffuse *= DiffuseHammon(LdotV, NdotV, NdotL, NdotH, material.roughness, albedo);

                #ifdef PARALLAX_SHADOW
                    shadow *= oneMinus(gbuffer7.a);
                #endif

                specular = SpecularBRDF(LdotH, NdotV, rawNdotL, NdotH, sqr(material.roughness), material.f0) * mix(vec3(1.0), albedo, material.isMetal);
                specular *= SPECULAR_HIGHLIGHT_BRIGHTNESS;

                shadow *= sunlightMult * END_SHADOW_COLOR; // Apply customizable shadow color
                // NEW: Boost shadows/light during flash (reduced multiplier)
                shadow *= (1.0 + endFlashIntensity * 0.5);
            }
        }

        // Basic light with customizable fog influence
        sceneData += BASIC_BRIGHTNESS_END + nightVision;
        if (darkEnd) sceneData *= vec3(0.2, 0.15, 0.3);
        sceneData = mix(sceneData, END_FOG_COLOR, 0.2); // Apply fog color to basic lighting
        // NEW: Boost basic light during flash (reduced multiplier)
        sceneData *= (1.0 + endFlashIntensity * 0.3);

        // GI AO
        #ifdef GI_ENABLED
            vec4 indirectData = SpatialFilter(normal, opaqueDepth, NdotV);
            float ao = indirectData.a;
        #elif defined SSAO_ENABLED
            float ao = texelFetch(colortex0, texel / 2, 0).a;
        #else
            float ao = 1.0;
        #endif

        #if defined GI_ENABLED
            if (distanceFade > 1e-3) indirectData.rgb = indirectData.rgb * oneMinus(distanceFade) + 0.04 * oneMinus(saturate(NdotL * 1e2)) * distanceFade;
            sceneData += indirectData.rgb * GI_BRIGHTNESS * sunlightMult * 0.25;
            // NEW: Tint GI during flash
            indirectData.rgb *= mix(vec3(1.0), END_FLASH_TINT, endFlashIntensity);
        #else
            float bounce = CalculateFakeBouncedLight(worldNormal);
            sceneData += bounce * sunlightMult;
        #endif

        sceneData *= ao;

        // Block light
        #include "/lib/Lighting/BlockLighting.glsl"

        sceneData += shadow * diffuse;
        sceneData *= albedo;

        sceneData *= oneMinus(material.isMetal * 0.8);
        sceneData += shadow * specular;

        // NEW: Final flash boost (simulates added skylight, reduced intensity)
        sceneData += endFlashIntensity * END_FLASH_COLOR * 0.2 * ao;  // Глобальный tint/boost (reduced from 0.5)
    }

    sceneData = clamp16F(sceneData * 2.0);
}

/* DRAWBUFFERS:04 */