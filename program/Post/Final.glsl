out vec3 finalData;

// Временное определение для VHS_STATIC_GLITCH_INTENSITY
#define VHS_STATIC_GLITCH_INTENSITY 0.3 // [0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0]

// Запасные определения для констант, отсутствующих в старом /settings.glsl
#ifndef SHARPNESS_STRENGTH
#define SHARPNESS_STRENGTH 0.5 // Сила шарпенинга [0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0]
#endif
#ifndef SCANLINE
#define SCANLINE 1 // Включение сканлайнов [0 1]
#endif
#ifndef GRAIN
#define GRAIN 1 // Включение зерна [0 1]
#endif
#ifndef GRAIN_STRENGTH
#define GRAIN_STRENGTH 0.05 // Сила зерна [0.0 0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.1]
#endif
#ifndef COLOR_DIST
#define COLOR_DIST 1 // Включение цветового искажения [0 1]
#endif
#ifndef COLOR_DIST_STRENGTH
#define COLOR_DIST_STRENGTH 0.02 // Сила цветового искажения [0.0 0.01 0.02 0.03 0.04 0.05]
#endif
#ifndef ENABLE_NVG_IsSneaking
#define ENABLE_NVG_IsSneaking 1 // Включение NVG при приседании [0 1]
#endif
#ifndef NVG
#define NVG 0 // Включение NVG без приседания [0 1]
#endif
#ifndef R
#define R 0.0 // Красный компонент для NVG [0.0 0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.10 0.11 0.12 0.13 0.14 0.15 0.16 0.17 0.18 0.19 0.20 0.21 0.22 0.23 0.24 0.25 0.26 0.27 0.28 0.29 0.30 0.31 0.32 0.33 0.34 0.35 0.36 0.37 0.38 0.39 0.40 0.41 0.42 0.43 0.44 0.45 0.46 0.47 0.48 0.49 0.50 0.51 0.52 0.53 0.54 0.55 0.56 0.57 0.58 0.59 0.60 0.61 0.62 0.63 0.64 0.65 0.66 0.67 0.68 0.69 0.70 0.71 0.72 0.73 0.74 0.75 0.76 0.77 0.78 0.79 0.80 0.81 0.82 0.83 0.84 0.85 0.86 0.87 0.88 0.89 0.90 0.91 0.92 0.93 0.94 0.95 0.96 0.97 0.98 0.99 1.00]
#endif
#ifndef G
#define G 1.0 // Зелёный компонент для NVG [0.0 0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.10 0.11 0.12 0.13 0.14 0.15 0.16 0.17 0.18 0.19 0.20 0.21 0.22 0.23 0.24 0.25 0.26 0.27 0.28 0.29 0.30 0.31 0.32 0.33 0.34 0.35 0.36 0.37 0.38 0.39 0.40 0.41 0.42 0.43 0.44 0.45 0.46 0.47 0.48 0.49 0.50 0.51 0.52 0.53 0.54 0.55 0.56 0.57 0.58 0.59 0.60 0.61 0.62 0.63 0.64 0.65 0.66 0.67 0.68 0.69 0.70 0.71 0.72 0.73 0.74 0.75 0.76 0.77 0.78 0.79 0.80 0.81 0.82 0.83 0.84 0.85 0.86 0.87 0.88 0.89 0.90 0.91 0.92 0.93 0.94 0.95 0.96 0.97 0.98 0.99 1.00]
#endif
#ifndef B
#define B 0.0 // Синий компонент для NVG [0.0 0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.10 0.11 0.12 0.13 0.14 0.15 0.16 0.17 0.18 0.19 0.20 0.21 0.22 0.23 0.24 0.25 0.26 0.27 0.28 0.29 0.30 0.31 0.32 0.33 0.34 0.35 0.36 0.37 0.38 0.39 0.40 0.41 0.42 0.43 0.44 0.45 0.46 0.47 0.48 0.49 0.50 0.51 0.52 0.53 0.54 0.55 0.56 0.57 0.58 0.59 0.60 0.61 0.62 0.63 0.64 0.65 0.66 0.67 0.68 0.69 0.70 0.71 0.72 0.73 0.74 0.75 0.76 0.77 0.78 0.79 0.80 0.81 0.82 0.83 0.84 0.85 0.86 0.87 0.88 0.89 0.90 0.91 0.92 0.93 0.94 0.95 0.96 0.97 0.98 0.99 1.00]
#endif
#ifndef degree_brightness_increase
#define degree_brightness_increase 1.5 // Увеличение яркости для NVG [0.5 1.0 1.5 2.0 2.5 3.0]
#endif
#ifndef FISHEYE_CENTER_STRENGTH
#define FISHEYE_CENTER_STRENGTH 0.5 // Сила закругления fisheye ближе к центру [0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0]
#endif

// Функция для линейной глубины
float linearizeDepth(float depth, float near, float far) {
    return (2.0 * near) / (far + near - depth * (far - near));
}

// Определение констант для факела
#define TORCH_RANGE 8.0 // Диапазон действия света от факела
#define TORCH_SHADOW_STRENGTH 0.6 // Сила тени от факела


#include "/lib/Head/Common.inc"
#include "/lib/Head/Uniforms.inc"
#include "/lib/Head/Noise.inc"

// Uniforms for bodycam, VHS, and lens flare effects
uniform vec3 viewDir;
uniform vec2 mouseDelta;
uniform vec3 sunPosition;
uniform float sunVisibility;
uniform float moonVisibility;
uniform vec3 lightNight;
uniform float isSneaking; // Для NVG при приседании
uniform float rainStrength; // Для lens flare в зависимости от погоды
#ifdef USE_PNG_TEXTURE
uniform sampler2D texture; // AXON.png texture
#endif

// Supporting functions
float random(vec2 st) {
    return fract(sin(dot(st, vec2(12.9898, 78.233))) * 43758.5453123);
}

float bodyCamNoise(vec2 x) {
    vec2 i = floor(x);
    vec2 f = fract(x);
    vec2 u = f * f * (3.0 - 2.0 * f);
    float a = random(i + vec2(0.0, 0.0));
    float b = random(i + vec2(1.0, 0.0));
    float c = random(i + vec2(0.0, 1.0));
    float d = random(i + vec2(1.0, 1.0));
    return mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
}

vec2 cameraShake(float frameTimeCounter, float intensity) {
    return vec2(
        intensity * sin(frameTimeCounter * 1.5),
        intensity * cos(frameTimeCounter * 1.85)
    );
}

vec2 handSway(float frameTimeCounter, float intensity) {
    return vec2(
        intensity * sin(frameTimeCounter * 2.0),
        intensity * cos(frameTimeCounter * 2.5)
    );
}

float blackFOVMask(vec2 coord) {
    vec2 centered = abs(coord - 0.5);
    float fovScale = 1.0 / (0.01 + 0.99 * (BLACK_FOV / 100.0));
    float r = length(centered * fovScale);
    return 1.0 - smoothstep(0.7, 1.0, r);
}

vec2 lensDistortion(vec2 coord) {
    vec2 centered = coord - 0.5;
    float r = length(centered);
    float lens_effect = LENS_STRENGTH * (1.0 - r * r);
    float scale = 1.0 + lens_effect;
    return centered * scale + 0.5;
}

vec2 DistortPosition(vec2 coord) {
    vec2 centered = coord - 0.5;
    float distortionFactor = length(centered) + 0.1;
    distortionFactor = 1.0 + DIST_STRENGTH * (distortionFactor - 1.0);
    centered /= distortionFactor;
    return centered + 0.5;
}

vec2 imageRoundedDistortion(vec2 coord) {
    vec2 centered = coord - 0.5;
    vec2 scaled = centered / vec2(1.0 - IMAGE_HORIZONTAL_STRENGTH, 1.0 - IMAGE_VERTICAL_STRENGTH);
    float r = length(scaled / IMAGE_ROUNDING_RADIUS);
    vec2 glitch_offset = GLITCH_STRENGTH * vec2(
        ENABLE_HORIZONTAL_GLITCH * random(coord + vec2(frameTimeCounter, 0.0)),
        random(coord + vec2(frameTimeCounter, 1.0))
    );
    float mask = smoothstep(1.0, 1.0 - BLACK_STRIPES_SOFT_NEW, r);
    return mix(coord + glitch_offset, vec2(0.5), 1.0 - mask);
}

float ImageRound(vec2 coord) {
    vec2 centered = abs(coord - 0.5);
    float r = length(centered / IMAGE_ROUND_STRENGTH);
    float glitch = GLITCH_STRENGTH * 10.0 * random(coord + vec2(frameTimeCounter));
    return 1.0 - clamp(smoothstep(0.7, 0.7 + glitch, r), 0.0, 1.0);
}

vec2 rotateUV(vec2 uv, float angle) {
    vec2 center = vec2(0.5, 0.5);
    vec2 d = uv - center;
    float c = cos(angle);
    float s = sin(angle);
    return center + vec2(
        d.x * c - d.y * s,
        d.x * s + d.y * c
    );
}

vec3 motionBlurTest(vec2 coord, vec3 color) {
    vec2 centered = coord - 0.5;
    float r = length(centered);
    float blur_mask = 1.0 - smoothstep(MOTION_BLUR_RADIUS * 0.8, MOTION_BLUR_RADIUS, r);
    if (blur_mask <= 0.0) return color;

    vec2 blur_dir = vec2(cos(frameTimeCounter * 2.0), sin(frameTimeCounter * 2.0)) * MOTION_BLUR_STRENGTH;
    vec3 blurred_color = vec3(0.0);
    const int samples = 5;
    for (int i = -samples / 2; i <= samples / 2; i++) {
        vec2 offset = blur_dir * float(i) / float(samples / 2);
        blurred_color += texture2D(colortex3, coord + offset).rgb;
    }
    blurred_color /= float(samples);
    return mix(color, blurred_color, blur_mask);
}

vec3 motionBlurMouse(vec2 coord, vec3 color) {
    #ifdef USE_MOUSE_DELTA
    vec2 motion = mouseDelta;
    #else
    vec2 motion = vec2(viewDir.x, viewDir.y) * sin(frameTimeCounter * 0.5) * 0.01;
    #endif
    float motion_magnitude = length(motion);
    if (motion_magnitude < 0.0001) return color;

    vec2 blur_dir = normalize(motion) * MOTION_BLUR_MOUSE_STRENGTH * motion_magnitude;
    vec3 blurred_color = vec3(0.0);
    const int samples = 7;
    for (int i = -samples / 2; i <= samples / 2; i++) {
        vec2 offset = blur_dir * float(i) / float(samples / 2);
        blurred_color += texture2D(colortex3, coord + offset).rgb;
    }
    blurred_color /= float(samples);
    return mix(color, blurred_color, clamp(motion_magnitude * 10.0, 0.0, 1.0));
}

vec3 drawImage(vec2 coord, vec3 base_color) {
    #ifdef USE_PNG_TEXTURE
    vec2 image_size = vec2(0.2, 0.2 * (textureSize(texture, 0).y / textureSize(texture, 0).x));
    vec2 image_pos;
    if (IMAGE_POSITION == 0) {
        image_pos = vec2(1.0 - image_size.x - 0.02, 0.02); // Right
    } else {
        image_pos = vec2(0.02, 0.02); // Left
    }
    if (coord.x >= image_pos.x && coord.x <= image_pos.x + image_size.x &&
        coord.y >= image_pos.y && coord.y <= image_pos.y + image_size.y) {
        vec2 tex_coord = (coord - image_pos) / image_size;
        tex_coord = lensDistortion(tex_coord);
        vec4 image_color = texture2D(texture, tex_coord);
        float flicker = (random(tex_coord + vec2(frameTimeCounter)) * 2.0 - 1.0) * FLICKER_STRENGTH;
        image_color.rgb *= (1.0 + flicker);
        return mix(base_color, image_color.rgb, image_color.a);
    }
    #endif
    return base_color;
}

// Lens flare functions
float clamp01(float x) {
    return clamp(x, 0.0, 1.0);
}

float fovmult = gbufferProjection[1][1] / 1.37373871;

float BaseLens(vec2 texcoord, vec2 lightPos, float size, float dist, float hardness) {
    vec2 lensCoord = (texcoord + (lightPos * dist - 0.5)) * vec2(aspectRatio, 1.0);
    float lens = clamp(1.0 - length(lensCoord) / (size * fovmult), 0.0, 1.0 / hardness) * hardness;
    lens *= lens; lens *= lens;
    return lens;
}

float OverlapLens(vec2 texcoord, vec2 lightPos, float size, float dista, float distb) {
    return BaseLens(texcoord, lightPos, size, dista, 2.0) * BaseLens(texcoord, lightPos, size, distb, 2.0);
}

float PointLens(vec2 texcoord, vec2 lightPos, float size, float dist) {
    return BaseLens(texcoord, lightPos, size, dist, 1.5) + BaseLens(texcoord, lightPos, size * 4.0, dist, 1.0) * 0.5;
}

float RingLensTransform(float lensFlare) {
    return pow(1.0 - pow(1.0 - pow(lensFlare, 0.25), 10.0), 5.0);
}

float RingLens(vec2 texcoord, vec2 lightPos, float size, float distA, float distB) {
    float lensFlare1 = RingLensTransform(BaseLens(texcoord, lightPos, size, distA, 1.0));
    float lensFlare2 = RingLensTransform(BaseLens(texcoord, lightPos, size, distB, 1.0));

    float lensFlare = clamp01(lensFlare2 - lensFlare1);
    lensFlare *= sqrt(lensFlare);
    return lensFlare;
}

float AnamorphicLens(vec2 texcoord, vec2 lightPos, float size, float dist) {
    vec2 lensCoord = abs(texcoord + (lightPos * dist - 0.5)) * vec2(aspectRatio * 0.07, 2.0);
    float lens = clamp01(1.0 - length(pow(lensCoord / (size * fovmult), vec2(0.85))) * 4.0);
    lens *= lens * lens;
    return lens;
}

vec3 RainbowLens(vec2 texcoord, vec2 lightPos, float size, float dist, float rad) {
    vec2 lensCoord = (texcoord + (lightPos * dist - 0.5)) * vec2(aspectRatio, 1.0);
    float lens = clamp01(1.0 - length(lensCoord) / (size * fovmult));

    vec3 rainbowLens =
        (smoothstep(0.0, rad, lens) - smoothstep(rad, rad * 2.0, lens)) * vec3(1.0, 0.0, 0.0) +
        (smoothstep(rad * 0.5, rad * 1.5, lens) - smoothstep(rad * 1.5, rad * 2.5, lens)) * vec3(0.0, 1.0, 0.0) +
        (smoothstep(rad, rad * 2.0, lens) - smoothstep(rad * 2.0, rad * 3.0, lens)) * vec3(0.0, 0.0, 1.0);

    return rainbowLens;
}

vec3 LensTint(vec3 lens, float truePos) {
    float isMoon = truePos * 0.5 + 0.5;

    float visibility = mix(sunVisibility, moonVisibility, isMoon);
    lens = mix(lens, GetLuminance(lens) * lightNight * 0.5, isMoon * 0.98);
    return lens * visibility;
}

void LensFlare(inout vec3 color, vec2 texcoord, vec2 lightPos, float truePos, float multiplier) {
    float falloffBase = length(lightPos * vec2(aspectRatio, 1.0));
    float falloffIn = pow(clamp01(falloffBase * 10.0), 2.0);
    float falloffOut = clamp01(falloffBase * 3.0 - 1.5);

    if (falloffOut < 0.999) {
        vec3 lensFlare = (
            BaseLens(texcoord, lightPos, 0.3, -0.45, 1.0) * vec3(2.2, 1.2, 0.1) * 0.07 +
            BaseLens(texcoord, lightPos, 0.3,  0.10, 1.0) * vec3(2.2, 0.4, 0.1) * 0.03 +
            BaseLens(texcoord, lightPos, 0.3,  0.30, 1.0) * vec3(2.2, 0.2, 0.1) * 0.04 +
            BaseLens(texcoord, lightPos, 0.3,  0.50, 1.0) * vec3(2.2, 0.4, 2.5) * 0.05 +
            BaseLens(texcoord, lightPos, 0.3,  0.70, 1.0) * vec3(1.8, 0.4, 2.5) * 0.06 +
            BaseLens(texcoord, lightPos, 0.3,  0.95, 1.0) * vec3(0.1, 0.2, 2.5) * 0.10 +
            BaseLens(texcoord, lightPos, 0.3,  1.15, 1.0) * vec3(0.08, 0.1, 2.8) * 0.12 +
            BaseLens(texcoord, lightPos, 0.3,  1.35, 1.0) * vec3(0.04, 0.1, 3.4) * 0.14 +
            OverlapLens(texcoord, lightPos, 0.18, -0.30, -0.41) * vec3(2.5, 1.2, 0.1) * 0.010 +
            OverlapLens(texcoord, lightPos, 0.16, -0.18, -0.29) * vec3(2.5, 0.5, 0.1) * 0.020 +
            OverlapLens(texcoord, lightPos, 0.15,  0.06,  0.19) * vec3(2.5, 0.2, 0.1) * 0.015 +
            OverlapLens(texcoord, lightPos, 0.14,  0.15,  0.28) * vec3(1.8, 0.1, 1.2) * 0.015 +
            OverlapLens(texcoord, lightPos, 0.16,  0.24,  0.37) * vec3(1.0, 0.1, 2.5) * 0.015 +
            PointLens(texcoord, lightPos, 0.03, -0.55) * vec3(2.5, 1.6, 0.0) * 0.20 +
            PointLens(texcoord, lightPos, 0.02, -0.40) * vec3(2.5, 1.0, 0.0) * 0.15 +
            PointLens(texcoord, lightPos, 0.04,  0.43) * vec3(2.5, 0.6, 0.6) * 0.20 +
            PointLens(texcoord, lightPos, 0.02,  0.60) * vec3(0.2, 0.6, 2.5) * 0.15 +
            PointLens(texcoord, lightPos, 0.03,  0.67) * vec3(0.2, 1.6, 2.5) * 0.25 +
            PointLens(texcoord, lightPos, 0.03,  0.73) * vec3(0.2, 1.9, 2.5) * 0.35 +
            RingLens(texcoord, lightPos, 0.25, 0.43, 0.45) * vec3(0.10, 0.35, 2.50) * 1.5 +
            RingLens(texcoord, lightPos, 0.18, 0.98, 0.99) * vec3(0.15, 1.00, 2.55) * 2.5 +
            RingLens(texcoord, lightPos, 0.10, 1.32, 1.33) * vec3(0.30, 1.55, 2.85) * 1.5
        ) * (falloffIn - falloffOut) + (
            AnamorphicLens(texcoord, lightPos, 1.0, -1.0) * vec3(0.3, 0.7, 1.0) * 0.35 +
            RainbowLens(texcoord, lightPos, 0.425, -1.0, 0.2) * 0.035 +
            RainbowLens(texcoord, lightPos, 2.0, 4.0, 0.1) * 0.05
        ) * (1.0 - falloffOut);

        lensFlare = LensTint(lensFlare, truePos);

        color = mix(color, vec3(1.0), lensFlare * multiplier * multiplier);
    }
}

// VHS effect functions
float verticalBar(float pos, float uvY, float offset) {
    float edge0 = (pos - VHS_SHAKE);
    float edge1 = (pos + VHS_SHAKE);
    float x = smoothstep(edge0, pos, uvY) * offset;
    x -= smoothstep(pos, edge1, uvY) * offset;
    return x;
}

vec3 vhs_purple_static(vec2 texcoord, vec3 base_color) {
    vec2 uv = texcoord;
    vec3 purple_bg = vec3(0.2, 0.1, 0.3); // Dark semi-violet
    float bg_noise = random(uv + vec2(frameTimeCounter * 0.05)) * VHS_PURPLE_STATIC_INTENSITY;
    purple_bg += vec3(bg_noise * 0.1 - 0.05); // Subtle noise
    return mix(base_color, purple_bg, VHS_PURPLE_STATIC_INTENSITY * 0.3);
}

vec3 vhs_effect(vec2 texcoord, vec3 base_color) {
    vec2 uv = texcoord;
    vec3 color = base_color;

    // Vertical bar distortions (moving shifts like tape wobble) - apply to UV
    for (float i = 0.0; i < 0.71; i += 0.1313) {
        float d = mod(frameTimeCounter * i, 1.7);
        float o = sin(1.0 - tan(frameTimeCounter * 0.24 * i));
        o *= VHS_OFFSET_INTENSITY;
        uv.x += verticalBar(d, uv.y, o);
    }

    // Horizontal line noise (VHS grain on scanlines) - apply to UV
    float uvY = uv.y;
    uvY *= VHS_NOISE_QUALITY;
    uvY = floor(uvY) / VHS_NOISE_QUALITY;
    float noise = random(vec2(frameTimeCounter * 0.00001, uvY));
    uv.x += noise * VHS_NOISE_INTENSITY;

    // Static glitches - add static noise/glitches with intensity
    float static_glitch = (random(uv * 10.0 + vec2(0.0, frameTimeCounter * 0.1)) - 0.5) * VHS_STATIC_GLITCH_INTENSITY * 2.0;
    color += vec3(static_glitch * 0.5); // Add to all channels for glitch effect

    // Chromatic aberration (color bleeding) - sample with offsets
    vec2 offsetR = vec2(0.006 * sin(frameTimeCounter), 0.0) * VHS_COLOR_OFFSET_INTENSITY;
    vec2 offsetG = vec2(0.0073 * cos(frameTimeCounter * 0.97), 0.0) * VHS_COLOR_OFFSET_INTENSITY;

    float r = texture2D(colortex3, uv + offsetR).r;
    float g = texture2D(colortex3, uv + offsetG).g;
    float b = texture2D(colortex3, uv).b;

    vec3 vhs_color = vec3(r, g, b);

    // Mix distorted VHS color with base_color
    color = mix(color, vhs_color, 0.8); // 80% VHS distortion on base

    // Apply purple static background if enabled
    if (VHS_PURPLE_STATIC_ENABLED == 1) {
        color = vhs_purple_static(texcoord, color);
    }

    return color;
}

// CAS and Catmull-Rom functions
#define minOf(a, b, c, d, e, f, g, h, i) min(a, min(b, min(c, min(d, min(e, min(f, min(g, min(h, i))))))))
#define maxOf(a, b, c, d, e, f, g, h, i) max(a, max(b, max(c, max(d, max(e, max(f, max(g, max(h, i))))))))

#define SampleColor(texel) texelFetch(colortex3, texel, 0).rgb

vec3 CASFilter(in ivec2 texel) {
    #ifndef CAS_ENABLED
        return SampleColor(texel);
    #endif

    vec3 a = SampleColor(texel + ivec2(-1, -1));
    vec3 b = SampleColor(texel + ivec2(0, -1));
    vec3 c = SampleColor(texel + ivec2(1, -1));
    vec3 d = SampleColor(texel + ivec2(-1, 0));
    vec3 e = SampleColor(texel);
    vec3 f = SampleColor(texel + ivec2(1, 0));
    vec3 g = SampleColor(texel + ivec2(-1, 1));
    vec3 h = SampleColor(texel + ivec2(0, 1));
    vec3 i = SampleColor(texel + ivec2(1, 1));

    vec3 minColor = minOf(a, b, c, d, e, f, g, h, i);
    vec3 maxColor = maxOf(a, b, c, d, e, f, g, h, i);

    vec3 sharpeningAmount = sqrt(min(1.0 - maxColor, minColor) / maxColor);
    vec3 w = sharpeningAmount * mix(-0.125, -0.2, CAS_STRENGTH);

    return ((b + d + f + h) * w + e) / (4.0 * w + 1.0);
}

vec3 textureCatmullRomFast(in sampler2D tex, in vec2 position, in const float sharpness) {
    vec2 centerPosition = floor(position - 0.5) + 0.5;
    vec2 f = position - centerPosition;
    vec2 f2 = f * f;
    vec2 f3 = f * f2;

    vec2 w0 = -sharpness * f3 + 2.0 * sharpness * f2 - sharpness * f;
    vec2 w1 = (2.0 - sharpness) * f3 - (3.0 - sharpness) * f2 + 1.0;
    vec2 w2 = (sharpness - 2.0) * f3 + (3.0 - 2.0 * sharpness) * f2 + sharpness * f;
    vec2 w3 = sharpness * f3 - sharpness * f2;

    vec2 w12 = w1 + w2;

    vec2 tc0 = screenPixelSize * (centerPosition - 1.0);
    vec2 tc3 = screenPixelSize * (centerPosition + 2.0);
    vec2 tc12 = screenPixelSize * (centerPosition + w2 / w12);

    float l0 = w12.x * w0.y;
    float l1 = w0.x * w12.y;
    float l2 = w12.x * w12.y;
    float l3 = w3.x * w12.y;
    float l4 = w12.x * w3.y;

    vec3 color = texture(tex, vec2(tc12.x, tc0.y)).rgb * l0 +
                 texture(tex, vec2(tc0.x, tc12.y)).rgb * l1 +
                 texture(tex, vec2(tc12.x, tc12.y)).rgb * l2 +
                 texture(tex, vec2(tc3.x, tc12.y)).rgb * l3 +
                 texture(tex, vec2(tc12.x, tc3.y)).rgb * l4;

    return color / (l0 + l1 + l2 + l3 + l4);
}

// Bodycam effect function
vec3 color_aberration(vec2 texcoord) {
    // Apply zoom
    vec2 centered = (texcoord - 0.5) * ZOOM_NEW + 0.5;
    float distance = length(centered - 0.5);

    // Camera shake and hand sway
    vec2 shake = cameraShake(frameTimeCounter, INTENSITY_CAM_SHAKE_NEW) + handSway(frameTimeCounter, HAND_SWAY_STRENGTH);

    // Rotate UV for subtle camera tilt
    vec2 rotatedUV = rotateUV(centered + shake, sin(frameTimeCounter * 0.5) * 0.02); // Subtle rotation

    // Enhanced fisheye effect with center-focused distortion
    float center_factor = pow(distance, 2.0) * FISHEYE_CENTER_STRENGTH;
    vec2 fisheyeUV = (rotatedUV - 0.5) * (1.0 + DIST_STRENGTH * (distance * distance + center_factor)) + 0.5;

    // Chromatic aberration
    vec2 redUV = fisheyeUV + vec2(CHROMATIC_ABERRATION, CHROMATIC_ABERRATION) * distance;
    vec2 blueUV = fisheyeUV + vec2(-CHROMATIC_ABERRATION, -CHROMATIC_ABERRATION) * distance;
    vec3 color;
    color.r = texture2D(colortex3, redUV).r;
    color.g = texture2D(colortex3, fisheyeUV).g;
    color.b = texture2D(colortex3, blueUV).b;

    // Sharpening
    vec2 texelSize = 1.0 / vec2(viewWidth, viewHeight);
    vec3 sharpenedColor = vec3(0.0);
    sharpenedColor += texture2D(colortex3, fisheyeUV + texelSize * vec2(-1.0, 0.0)).rgb * -1.0;
    sharpenedColor += texture2D(colortex3, fisheyeUV + texelSize * vec2(1.0, 0.0)).rgb * -1.0;
    sharpenedColor += texture2D(colortex3, fisheyeUV + texelSize * vec2(0.0, -1.0)).rgb * -1.0;
    sharpenedColor += texture2D(colortex3, fisheyeUV + texelSize * vec2(0.0, 1.0)).rgb * -1.0;
    sharpenedColor += texture2D(colortex3, fisheyeUV).rgb * 5.0;
    color = mix(color, sharpenedColor, SHARPNESS_STRENGTH);
    color = clamp(color, 0.0, 1.0);

    // Apply tonemapping
    float luminance = dot(color, vec3(0.299, 0.587, 0.114));
    vec3 desaturated = mix(vec3(luminance), color, SATURATION);
    desaturated = pow(desaturated, vec3(0.9));
    float newLum = dot(desaturated, vec3(0.299, 0.587, 0.114));
    if (newLum > 0.0) {
        desaturated *= luminance / newLum;
    }
    color = desaturated;

    // Color tint
    color.r *= 0.975; // Slightly reduce red
    color.g *= 1.025; // Slightly boost green
    color.b *= 1.05;  // Slightly boost blue

    // Scanlines
    #if SCANLINE == 1
    float scanline = sin(fisheyeUV.y * SCANLINE_WIDTH_NEW * 1.5) * SCANLINE_STRENGTH_NEW;
    color += scanline;
    #endif

    // Grain
    #if GRAIN == 1
    float noise = (bodyCamNoise(fisheyeUV + vec2(frameTimeCounter)) - 0.5) * GRAIN_STRENGTH;
    color += vec3(noise);
    #endif

    // Color distortion
    #if COLOR_DIST == 1
    float colorDistort = COLOR_DIST_STRENGTH * sin(frameTimeCounter * 2.0);
    color *= vec3(1.0 + colorDistort, 1.0 - colorDistort, 1.0 + colorDistort);
    #endif

    // NVG effect
    #if ENABLE_NVG_IsSneaking == 1
    if (isSneaking == 1.0) {
        float gray = dot(color, vec3(0.299, 0.587, 0.114));
        vec3 grayscale = vec3(gray);
        vec3 colorTransform = vec3(R, G, B) * degree_brightness_increase;
        color = grayscale * colorTransform;
    }
    #else
    #if NVG == 1
    float gray = dot(color, vec3(0.299, 0.587, 0.114));
    vec3 grayscale = vec3(gray);
    vec3 colorTransform = vec3(R, G, B) * degree_brightness_increase;
    color = grayscale * colorTransform;
    #endif
    #endif

    // Exposure
    color *= pow(2.0, EXPOSURE);

    // Brightness and contrast
    color += BRIGHTNESS;
    color = ((color - 0.5) * CONTRAST) + 0.5;

    // Vignette
    #if VIGNETTE == 1
    float vignette = smoothstep(VIGNETTE_RADIUS_NEW, VIGNETTE_RADIUS_NEW + VIGNETTE_STRENGTH_NEW, distance);
    color = mix(color, vec3(0.0), vignette);
    #endif

    // Black stripes
    #if BLACK_STRIPES == 1
    float leftStripe = smoothstep(BLACK_STRIPES_WIDTH_NEW, BLACK_STRIPES_WIDTH_NEW - BLACK_STRIPES_SOFT_NEW, texcoord.x);
    float rightStripe = smoothstep(1.0 - BLACK_STRIPES_WIDTH_NEW, 1.0 - (BLACK_STRIPES_WIDTH_NEW - BLACK_STRIPES_SOFT_NEW), texcoord.x);
    float stripeEffect = max(leftStripe, rightStripe);
    color = mix(color, vec3(0.0), stripeEffect);
    #endif

    // FOV mask
    float fov_mask = blackFOVMask(texcoord);
    color = mix(color, vec3(0.0), 1.0 - fov_mask);

    // Torch shadow
    ivec2 texel = ivec2(gl_FragCoord.xy);
    float torchFactor = texelFetch(colortex7, texel, 0).z;
    if (torchFactor > 0.5) {
        vec3 torchDir = normalize(vec3(0.0, -1.0, 0.0));
        vec3 normal = DecodeNormal(texelFetch(colortex3, texel, 0).xy);
        float NdotL = max(dot(normal, torchDir), 0.0);
        float depth = texelFetch(depthtex0, texel, 0).r;
        float linearDepth = linearizeDepth(depth, near, far);
        float torchDistance = linearDepth * 2.0;
        float torchShadow = TORCH_SHADOW_STRENGTH * (1.0 - clamp(torchDistance / TORCH_RANGE, 0.0, 1.0)) * NdotL;
        color *= 1.0 - clamp(torchShadow, 0.0, 0.5);
    }

    // Overlay image (e.g., AXON.png)
    color = drawImage(texcoord, color);

    return color;
}

// Main function
void main() {
    ivec2 texel = ivec2(gl_FragCoord.xy);
    vec2 texcoord = gl_FragCoord.xy / vec2(viewWidth, viewHeight); // Normalized texture coordinates

    #ifdef DEBUG_DRAWBUFFERS
        finalData = texelFetch(colortex4, texel, 0).rgb;
    #else
        // Apply CAS or Catmull-Rom filtering first
        if (abs(MC_RENDER_QUALITY - 1.0) < 1e-2) {
            finalData = CASFilter(texel);
        } else {
            finalData = textureCatmullRomFast(colortex3, texcoord * MC_RENDER_QUALITY, 0.6);
        }
        // Add TAA dithering
        finalData += (bayer16(gl_FragCoord.xy) - 0.5) * rcp(255.0);
        // Apply VHS effects if VHS_ENABLED is 1
        if (VHS_ENABLED == 1) {
            finalData = vhs_effect(texcoord, finalData);
        }
        // Apply bodycam effects if BODYCAM_ENABLED is 1
        if (BODYCAM_ENABLED == 1) {
            finalData = color_aberration(texcoord);
        }
        // Apply lens flare effect
        vec4 sunClipPos = gbufferProjection * vec4(sunPosition, 1.0);
        vec2 lightPos = (sunClipPos.xy / sunClipPos.w) * 0.5 + 0.5; // Transform to screen space
        float truePos = 1.0; // Assume sun for now
        float multiplier = LENS_FLARE_STRENGTH; // Use defined strength
        if (sunVisibility > 0.0 && rainStrength < 0.3) {
            LensFlare(finalData, texcoord, lightPos, truePos, multiplier);
        }
    #endif
}