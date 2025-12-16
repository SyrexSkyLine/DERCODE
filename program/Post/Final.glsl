
///BROOO DONT TRANSLATE THIS BY DEEPSEEK PLS STOoooooooooooooooP 
out vec3 finalData;

// Определение для VHS_STATIC_GLITCH_INTENSITY
#define VHS_STATIC_GLITCH_INTENSITY 0.3 // [0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0]

// Новые макросы для управления рамками
#define VHS_LETTERBOX_ENABLED 1         // Включение рамок [0 1]
#define VHS_LETTERBOX_ORIENTATION 0     // Ориентация рамок: 0 - горизонтальные, 1 - вертикальные [0 1]

// Параметры для BodycamMISC
#define BODYCAMMISC_ENABLED 0           // Включение новых эффектов BodycamMISC [0 1]
#define DYNAMIC_VIGNETTE 1              // Динамическая виньетка [0 1]
#define DYNAMIC_VIGNETTE_STRENGTH 0.3   // Сила динамической виньетки [0.0 0.1 0.2 0.3 0.4 0.5]
#define CRT_CURVE 0.05                  // Сила CRT-искривления [0.0 0.02 0.04 0.06 0.08 0.1]
#define BLOOM_ENABLED 1                 // Включение эффекта блум [0 1]
#define BLOOM_STRENGTH 0.1              // Сила блум [0.0 0.05 0.1 0.15 0.2]
#define DYNAMIC_NOISE 1                 // Динамический шум [0 1]
#define DYNAMIC_NOISE_STRENGTH 0.02     // Сила динамического шума [0.0 0.01 0.02 0.03 0.04 0.05]
#define EDGE_DISTORTION_ENABLED 1       // Включение искажения краёв [0 1]
#define CUBIC_VIGNETTE_ENABLED 1        // Включение кубической виньетки [0 1]
#define CUBIC_VIGNETTE_STRENGTH 0.5     // Сила кубической виньетки [0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.01 1.02 1.03 1.04 1.05 1.1 1.15 1.2 1.25 1.3 1.35 1.4 1.45 1.5 1.55 1.6 1.65 1.7 1.75 1.8 1.85 1.9 1.95 2.0]
#define PS1_STYLE_ENABLED 1             // Включение стиля PS1 [0 1]
#define PS1_STYLE_INTENSITY 0.5         // Интенсивность стиля PS1 [0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.01 1.02 1.03 1.04 1.05 1.1 1.15 1.2 1.25 1.3 1.35 1.4 1.45 1.5 1.55 1.6 1.65 1.7 1.75 1.8 1.85 1.9 1.95 2.0]
#define VHS_CHROMATIC_ABERRATION 0.002  // Хроматическая аберрация для BodyCam+VHS [0.0 0.001 0.002 0.003 0.004 0.005 0.1 0.2 0.4 0.8 1.0]

#define DIRTY_LENS_INTENSITY 0.8


// Запасные определения для констант
#ifndef SHARPNESS_STRENGTH
#define SHARPNESS_STRENGTH 0.5 // Сила шарпенинга [0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0]
#endif
#ifndef SCANLINE
#define SCANLINE 1 // Включение сканлайнов [0 1]
#endif
#ifndef GRAIN
#define GRAIN 0 // Включение зерна [0 1]
#endif
#ifndef GRAIN_STRENGTH
#define GRAIN_STRENGTH 0.05 // Сила зерна [0.0 0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.1]
#endif
#ifndef COLOR_DIST
#define COLOR_DIST 0 // Включение цветового искажения [0 1]
#endif
#ifndef COLOR_DIST_STRENGTH
#define COLOR_DIST_STRENGTH 0.02 // Сила цветового искажения [0.0 0.01 0.02 0.03 0.04 0.05]
#endif
#ifndef ENABLE_NVG_IsSneaking
#define ENABLE_NVG_IsSneaking 0 // Включение NVG при приседании [0 1]
#endif

#ifndef R
#define R 0.0 // Красный компонент для NVG [0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0]
#endif
#ifndef G
#define G 1.0 // Зелёный компонент для NVG [0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0]
#endif
#ifndef B
#define B 0.0 // Синий компонент для NVG [0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0]
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

#include "/lib/Head/Common.inc"
#include "/lib/Head/Uniforms.inc"
#include "/lib/Head/Noise.inc"

// Uniforms
uniform vec3 viewDir;
uniform vec2 mouseDelta;
uniform vec3 sunPosition;
uniform float sunVisibility;
uniform float moonVisibility;
uniform vec3 lightNight;
uniform float isSneaking;
uniform float sneakSmooth;
uniform float rainStrength;
uniform int worldTime;
uniform float eyeSquint;
uniform vec3 cameraSpeed;
uniform vec3 previousPosition;

#ifdef USE_PNG_TEXTURE
uniform sampler2D texture;
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
    #if BODYCAM_STYLE == 0
        float r = length(centered * fovScale); // Круглый стиль
        return 1.0 - smoothstep(0.7, 1.0, r);
    #else
        float r = max(centered.x, centered.y) * fovScale; // Квадратный стиль
        return 1.0 - smoothstep(0.7, 1.0, r);
    #endif
}

vec2 lensDistortion(vec2 coord) {
    vec2 centered = coord - 0.5;
    float r = length(centered);
    float lens_effect = LENS_STRENGTH * (1.0 - r * r);
    float scale = 1.0 + lens_effect;
    return centered * scale + 0.5;
}

vec2 DistortPosition(vec2 coord) {
    #if EDGE_DISTORTION_ENABLED == 1
    vec2 centered = coord - 0.5;
    float distortionFactor = length(centered) + 0.1;
    distortionFactor = 1.0 + DIST_STRENGTH * (distortionFactor - 1.0);
    centered /= distortionFactor;
    return centered + 0.5;
    #else
    return coord;
    #endif
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

vec2 applyCRTCurve(vec2 coord) {
    vec2 centered = coord - 0.5;
    float dist = length(centered);
    float curve = dist * CRT_CURVE;
    centered *= (1.0 + curve * dist);
    return centered + 0.5;
}

vec3 applyBloom(vec2 coord, vec3 color) {
    #if BLOOM_ENABLED == 1
    vec3 bloom = vec3(0.0);
    const int samples = 5;
    vec2 texelSize = 1.0 / vec2(viewWidth, viewHeight);
    for (int i = -samples / 2; i <= samples / 2; i++) {
        for (int j = -samples / 2; j <= samples / 2; j++) {
            vec2 offset = vec2(float(i), float(j)) * texelSize * 2.0;
            vec3 sampleColor = texture2D(colortex3, coord + offset).rgb;
            bloom += max(vec3(0.0), sampleColor - 0.5) * 0.05;
        }
    }
    bloom /= float(samples * samples);
    return color + bloom * BLOOM_STRENGTH;
    #else
    return color;
    #endif
}


/*
vec3 applyElytraMotionBlur(vec2 texcoord, vec3 color) {
    #if ELYTRA_BLUR > 0
    
    // ============= НАСТРОЙКИ =============
    float blurStrength = 0.0;
    #if ELYTRA_BLUR == 1
        blurStrength = 0.3;   // Слабое
    #elif ELYTRA_BLUR == 2
        blurStrength = 0.6;   // Среднее
    #elif ELYTRA_BLUR == 3
        blurStrength = 1.0;   // Сильное
    #elif ELYTRA_BLUR == 4
        blurStrength = 1.5;   // Экстрим
    #endif
    
    float centerRadius = 0.0;
    #if ELYTRA_BLUR_CENTER == 1
        centerRadius = 0.15;  // Малый
    #elif ELYTRA_BLUR_CENTER == 2
        centerRadius = 0.25;  // Средний
    #elif ELYTRA_BLUR_CENTER == 3
        centerRadius = 0.35;  // Большой
    #endif
    
    int samples = 6;
    #if ELYTRA_BLUR_QUALITY == 1
        samples = 8;          // Среднее
    #elif ELYTRA_BLUR_QUALITY == 2
        samples = 12;         // Высокое
    #endif
    
    vec2 centered = texcoord - 0.5;
    float distFromCenter = length(centered);
    
    // Чёткий центр
    if (distFromCenter < centerRadius) {
        return color;
    }
    
    // Маска размытия от центра
    float blurMask = smoothstep(centerRadius, centerRadius + 0.3, distFromCenter);
    if (blurMask < 0.01) return color;
    
    // ============= СКОРОСТЬ КАМЕРЫ =============
    // cameraSpeed уже в блоках/сек (дельта * 20 тпс)
    float horizSpeed = length(cameraSpeed.xz);
    float vertSpeed = abs(cameraSpeed.y);
    float speed = max(horizSpeed, vertSpeed * 0.7);  // падение тоже учитываем
    
    // Нормализация: 0 при <30, плавно 1 при 120+
    float speedFactor = smoothstep(30.0, 120.0, speed);
    
    // ТОЛЬКО ДЛЯ СТИЛЯ 1: выключаем при низкой скорости
    #if ELYTRA_BLUR_STYLE == 1
        if (speedFactor < 0.01) return color;
    #endif
    
    // ============= НАПРАВЛЕНИЕ =============
    vec2 blurDir = vec2(0.0);
    
    #if ELYTRA_BLUR_STYLE == 0
        // Радиальное (всегда работает)
        blurDir = normalize(centered);
        
    #elif ELYTRA_BLUR_STYLE == 1
        // По реальной скорости камеры (только при высокой скорости)
        vec2 motionXZ = vec2(cameraSpeed.x, cameraSpeed.z);
        #ifdef USE_MOUSE_DELTA
            if (length(mouseDelta) > 0.001) {
                motionXZ = mouseDelta;  // приоритет мыши, если крутишь головой
            }
        #endif
        #ifndef USE_MOUSE_DELTA
            if (length(motionXZ) < 0.001) {
                motionXZ = vec2(viewDir.x, -viewDir.y);  // fallback на взгляд
            }
        #endif
        blurDir = normalize(motionXZ);
        
    #elif ELYTRA_BLUR_STYLE == 2
        // Комбо (всегда работает)
        vec2 radial = normalize(centered);
        vec2 motionXZ = vec2(cameraSpeed.x, cameraSpeed.z);
        #ifdef USE_MOUSE_DELTA
            if (length(mouseDelta) > 0.001) {
                motionXZ = mouseDelta;
            }
        #endif
        vec2 motion = normalize(motionXZ);
        blurDir = normalize(mix(motion, radial, 0.6));
    #endif
    
    // ============= СИЛА РАЗМЫТИЯ =============
    float finalStrength = blurStrength * blurMask * distFromCenter;
    
    // ТОЛЬКО ДЛЯ СТИЛЯ 1: сила зависит от скорости
    #if ELYTRA_BLUR_STYLE == 1
        finalStrength *= speedFactor * 1.8;  // подкрути 1.8 если слишком слабо/сильно
    #endif
    
    vec2 blurStep = blurDir * finalStrength / float(samples);
    
    // ============= СЭМПЛИНГ =============
    vec3 blurred = vec3(0.0);
    float totalWeight = 0.0;
    
    for (int i = -samples / 2; i <= samples / 2; i++) {
        vec2 sampleCoord = texcoord + blurStep * float(i);
        
        if (sampleCoord.x < 0.0 || sampleCoord.x > 1.0 || 
            sampleCoord.y < 0.0 || sampleCoord.y > 1.0) {
            continue;
        }
        
        float weight = 1.0 - abs(float(i)) / float(samples / 2);
        
        #if ELYTRA_BLUR_CHROMA == 1
            // Хрома тоже зависит от скорости только в стиле 1
            float chromaShift = 0.003 * distFromCenter * float(i);
            #if ELYTRA_BLUR_STYLE == 1
                chromaShift *= speedFactor;
            #endif
            vec3 sampleColor;
            sampleColor.r = texture2D(colortex3, sampleCoord + vec2(chromaShift, 0.0)).r;
            sampleColor.g = texture2D(colortex3, sampleCoord).g;
            sampleColor.b = texture2D(colortex3, sampleCoord - vec2(chromaShift, 0.0)).b;
            blurred += sampleColor * weight;
        #else
            blurred += texture2D(colortex3, sampleCoord).rgb * weight;
        #endif
        
        totalWeight += weight;
    }
    
    blurred /= max(totalWeight, 0.001);
    
    // ============= ФИНАЛЬНЫЙ МИКС =============
    float finalMix = blurMask;
    // ТОЛЬКО ДЛЯ СТИЛЯ 1: микс зависит от скорости
    #if ELYTRA_BLUR_STYLE == 1
        finalMix *= speedFactor;
    #endif
    
    return mix(color, blurred, finalMix);
    
    #else
    return color;
    #endif
}
*/























vec3 applyEyeImitation(vec2 texcoord, vec3 color) {
#if EYE_SQUINT_ENABLED == 1
    float px = 1.0 / viewHeight;
    float baseHeight = EYE_SQUINT_HEIGHT_PIXELS * px;
    float softUV = EYE_SQUINT_SOFTNESS * px;

    // Цель: 1.0 когда зажат Shift
    float target = float(isSneaking);

    // Прямой эффект без накопления (нет плавной анимации между кадрами)
    float h = baseHeight * target;
    float offset = 15.0 * px * target + EYE_SQUINT_OFFSET;

    // Верхняя полоска
    float topLow = 1.0 - h - offset;
    float topHigh = topLow + softUV;
    float topMask = smoothstep(topLow, topHigh, texcoord.y);

    // Нижняя полоска
    float bottomHigh = h + offset;
    float bottomLow = bottomHigh - softUV;
    float bottomMask = 1.0 - smoothstep(bottomLow, bottomHigh, texcoord.y);

    float mask = max(topMask, bottomMask);

    color = mix(color, vec3(0.0), mask);
#endif
    return color;
}

vec3 applyChromaticAberration(vec2 uv, vec3 color) {
    #if CHROMATIC_ABERRATION_ENABLED == 1
        vec2 coord = uv - 0.5;
        float dist = length(coord);
        float fovMask = mix(dist * 2.3, 1.0, CHROMATIC_ABERRATION_CENTER);
        float amount = CHROMATIC_ABERRATION_STRENGTH * fovMask;
        vec2 offset = coord * amount;

        #if CHROMATIC_ABERRATION_STYLE == 1          // 1. КЛАССИЧЕСКАЯ RGB
            color.r = texture2D(colortex3, uv + offset).r;
            color.g = texture2D(colortex3, uv).g;
            color.b = texture2D(colortex3, uv - offset).b;

        #elif CHROMATIC_ABERRATION_STYLE == 2        // 2. НАСТОЯЩИЙ GOPRO
            color.r = texture2D(colortex3, uv + offset * 1.7).r;   // красный сильно наружу
            color.g = texture2D(colortex3, uv - offset * 0.4).g;   // зелёный чуть внутрь
            color.b = texture2D(colortex3, uv - offset * 0.7).b;   // синий чуть сильнее внутрь

        #elif CHROMATIC_ABERRATION_STYLE == 3        // 3. РАДУЖНАЯ ДИНАМИЧЕСКАЯ ПОДСВЕТКА (переливается!)
            float time = frameTimeCounter * 0.9;
            float hue = time * 0.3;
            vec3 rainbow = 0.5 + 0.5 * cos(hue + vec3(0.0, 2.094, 4.188)); // R G B цикл
            
            vec2 offsetR = offset * (0.8 + 0.6 * rainbow.r);
            vec2 offsetG = offset * (0.8 + 0.6 * rainbow.g);
            vec2 offsetB = offset * (0.8 + 0.6 * rainbow.b);

            color.r = texture2D(colortex3, uv + offsetR).r;
            color.g = texture2D(colortex3, uv + offsetG * vec2(1.0, -0.7)).g;
            color.b = texture2D(colortex3, uv - offsetB * vec2(0.8, 1.1)).b;

        #elif CHROMATIC_ABERRATION_STYLE == 4        // 4. ТОЛЬКО СИНЕ-ЗЕЛЁНАЯ (без красного)
            color.r = texture2D(colortex3, uv).r;                    // красный на месте
            color.g = texture2D(colortex3, uv + offset * 0.9).g;
            color.b = texture2D(colortex3, uv - offset * 1.3).b;
        #endif
    #endif
    return color;
}

vec3 applyPS1Style(vec2 coord, vec3 color) {
    #if PS1_STYLE_ENABLED == 1
    vec2 lowResCoord = floor(coord * vec2(viewWidth, viewHeight) / 4.0) * 4.0 / vec2(viewWidth, viewHeight);
    vec3 lowResColor = texture2D(colortex3, lowResCoord).rgb;
    float dither = bayer16(gl_FragCoord.xy) * 0.05 * PS1_STYLE_INTENSITY;
    return mix(color, lowResColor + dither, PS1_STYLE_INTENSITY);
    #else
    return color;
    #endif
}

float applyCubicVignette(vec2 coord) {
    #if CUBIC_VIGNETTE_ENABLED == 1
    vec2 centered = abs(coord - 0.5);
    float vertical = pow(centered.y, 3.0); // Кубическая зависимость по вертикали
    float corner = length(centered) * 0.2; // Лёгкое закругление углов
    return clamp(vertical + corner, 0.0, 1.0) * CUBIC_VIGNETTE_STRENGTH;
    #else
    return 0.0;
    #endif
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
            BaseLens(texcoord, lightPos, 0.3, 0.10, 1.0) * vec3(2.2, 0.4, 0.1) * 0.03 +
            BaseLens(texcoord, lightPos, 0.3, 0.30, 1.0) * vec3(2.2, 0.2, 0.1) * 0.04 +
            BaseLens(texcoord, lightPos, 0.3, 0.50, 1.0) * vec3(2.2, 0.4, 2.5) * 0.05 +
            BaseLens(texcoord, lightPos, 0.3, 0.70, 1.0) * vec3(1.8, 0.4, 2.5) * 0.06 +
            BaseLens(texcoord, lightPos, 0.3, 0.95, 1.0) * vec3(0.1, 0.2, 2.5) * 0.10 +
            BaseLens(texcoord, lightPos, 0.3, 1.15, 1.0) * vec3(0.08, 0.1, 2.8) * 0.12 +
            BaseLens(texcoord, lightPos, 0.3, 1.35, 1.0) * vec3(0.04, 0.1, 3.4) * 0.14 +
            OverlapLens(texcoord, lightPos, 0.18, -0.30, -0.41) * vec3(2.5, 1.2, 0.1) * 0.010 +
            OverlapLens(texcoord, lightPos, 0.16, -0.18, -0.29) * vec3(2.5, 0.5, 0.1) * 0.020 +
            OverlapLens(texcoord, lightPos, 0.15, 0.06, 0.19) * vec3(2.5, 0.2, 0.1) * 0.015 +
            OverlapLens(texcoord, lightPos, 0.14, 0.15, 0.28) * vec3(1.8, 0.1, 1.2) * 0.015 +
            OverlapLens(texcoord, lightPos, 0.16, 0.24, 0.37) * vec3(1.0, 0.1, 2.5) * 0.015 +
            PointLens(texcoord, lightPos, 0.03, -0.55) * vec3(2.5, 1.6, 0.0) * 0.20 +
            PointLens(texcoord, lightPos, 0.02, -0.40) * vec3(2.5, 1.0, 0.0) * 0.15 +
            PointLens(texcoord, lightPos, 0.04, 0.43) * vec3(2.5, 0.6, 0.6) * 0.20 +
            PointLens(texcoord, lightPos, 0.02, 0.60) * vec3(0.2, 0.6, 2.5) * 0.15 +
            PointLens(texcoord, lightPos, 0.03, 0.67) * vec3(0.2, 1.6, 2.5) * 0.25 +
            PointLens(texcoord, lightPos, 0.03, 0.73) * vec3(0.2, 1.9, 2.5) * 0.35 +
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
float hash(float n) {
    return fract(sin(n) * 43758.5453);
}

vec2 hash2(vec2 p) {
    p = vec2(dot(p, vec2(127.1, 311.7)), dot(p, vec2(269.5, 183.3)));
    return -1.0 + 2.0 * fract(sin(p) * 43758.5453123);
}

vec2 vhsDistortion(vec2 uv, float time) {
    float wave1 = sin(uv.y * 8.0 + time * 2.0) * 0.001;
    float wave2 = sin(uv.y * 15.0 + time * 3.5) * 0.001;
    float glitchLine = floor(uv.y * 200.0);
    float glitchRandom = hash(glitchLine + floor(time * 5.0));
    float glitchStrength = step(0.98, glitchRandom) * 0.02;
    float horizontalShift = glitchStrength * (hash(glitchLine * 13.7 + time) - 0.5);
    return uv + vec2(wave1 + wave2 + horizontalShift, 0.0);
}

vec3 chromaShift(sampler2D tex, vec2 uv, float time) {
    float shift = 0.002 + sin(time * 0.5) * 0.001;
    vec2 redUV = uv + vec2(shift, 0.0);
    vec2 greenUV = uv;
    vec2 blueUV = uv - vec2(shift, 0.0);
    float r = texture2D(tex, redUV).r;
    float g = texture2D(tex, greenUV).g;
    float b = texture2D(tex, blueUV).b;
    return vec3(r, g, b);
}

float scanlines(vec2 uv) {
    float line = sin(uv.y * viewHeight * 0.7) * 0.08;
    return 1.0 - abs(line);
}

float filmGrain(vec2 uv, float time) {
    vec2 grainUV = uv * 300.0 + time * 50.0;
    return (random(grainUV) - 0.5) * 0.25;
}

float trackingLines(vec2 uv, float time) {
    float tracking = 0.0;
    float speed = time * 0.1;
    float trackY = fract(speed) * 2.0 - 1.0;
    float trackDist = abs(uv.y - trackY);
    tracking += smoothstep(0.01, 0.0, trackDist) * 0.3;
    float track2Y = fract(speed * 0.7 + 0.3) * 2.0 - 1.0;
    float track2Dist = abs(uv.y - track2Y);
    tracking += smoothstep(0.005, 0.0, track2Dist) * 0.3;
    return tracking;
}

vec3 vhsColor(vec3 color, float time) {
    float gray = dot(color, vec3(0.299, 0.587, 0.114));
    color = mix(color, vec3(gray), 0.3);
    color.r *= 1.1;
    color.g *= 0.95;
    color.b *= 0.9;
    color = (color - 0.5) * 1.3 + 0.6;
    color += vec3(0.05, 0.03, 0.0);
    return color;
}

vec3 glitchBlocks(vec3 color, vec2 uv, float time) {
    vec2 blockUV = floor(uv * vec2(20.0, 15.0));
    float blockRandom = hash(blockUV.x + blockUV.y * 13.7 + floor(time * 3.0));
    if (blockRandom > 0.95) {
        //color = 1.0 - color;
    } else if (blockRandom > 0.92) {
        //color = color.brg;
    } else if (blockRandom > 0.90) {
        //color *= 1.5;
    }
    return color;
}

float drawRect(vec2 uv, vec2 pos, vec2 size) {
    vec2 d = abs(uv - pos) - size;
    return 1.0 - smoothstep(0.0, 0.002, max(d.x, d.y));
}

float drawChar(vec2 uv, vec2 pos, int charCode) {
    vec2 localUV = (uv - pos) / vec2(0.015, 0.025);
    if (localUV.x < 0.0 || localUV.x > 1.0 || localUV.y < 0.0 || localUV.y > 1.0) {
        return 0.0;
    }
    float pixel = 0.0;
    vec2 pixelPos = floor(localUV * vec2(5.0, 7.0));
    if (charCode == 0) {
        if ((pixelPos.x == 0.0 || pixelPos.x == 4.0) && pixelPos.y > 0.0 && pixelPos.y < 6.0) pixel = 1.0;
        if ((pixelPos.y == 0.0 || pixelPos.y == 6.0) && pixelPos.x > 0.0 && pixelPos.x < 4.0) pixel = 1.0;
    } else if (charCode == 1) {
        if (pixelPos.x == 3.0) pixel = 1.0;
        if (pixelPos.x == 2.0 && pixelPos.y < 1.0) pixel = 1.0;
        if (pixelPos.x == 3.0 && pixelPos.y < 1.0) pixel = 1.0;
        if (pixelPos.x == 4.0 && pixelPos.y < 1.0) pixel = 1.0;
        if (pixelPos.y == 5.0 && pixelPos.x >= 2.0 && pixelPos.x <= 3.0) pixel = 1.0;
    } else if (charCode == 2) {
        if (pixelPos.y == 0.0 || pixelPos.y == 3.0 || pixelPos.y == 6.0) pixel = 1.0;
        if (pixelPos.x == 0.0 && pixelPos.y < 3.0) pixel = 1.0;
        if (pixelPos.x == 4.0 && pixelPos.y > 3.0) pixel = 1.0;
    } else if (charCode == 3) {
        if (pixelPos.y == 0.0 || pixelPos.y == 3.0 || pixelPos.y == 6.0) pixel = 1.0;
        if (pixelPos.x == 4.0 && pixelPos.y != 3.0) pixel = 1.0;
    } else if (charCode == 4) {
        if (pixelPos.x == 0.0 && pixelPos.y > 3.0) pixel = 1.0;
        if (pixelPos.x == 4.0) pixel = 1.0;
        if (pixelPos.y == 3.0) pixel = 1.0;
    } else if (charCode == 5) {
        if (pixelPos.y == 0.0 || pixelPos.y == 3.0 || pixelPos.y == 6.0) pixel = 1.0;
        if (pixelPos.x == 0.0 && pixelPos.y > 3.0) pixel = 1.0;
        if (pixelPos.x == 4.0 && pixelPos.y < 3.0) pixel = 1.0;
    } else if (charCode == 6) {
        if (pixelPos.y == 0.0 || pixelPos.y == 3.0 || pixelPos.y == 6.0) pixel = 1.0;
        if (pixelPos.x == 0.0) pixel = 1.0;
        if (pixelPos.x == 4.0 && pixelPos.y < 4.0) pixel = 1.0;
    } else if (charCode == 7) {
        if (pixelPos.y == 6.0) pixel = 1.0;
        if (pixelPos.x == 4.0) pixel = 1.0;
    } else if (charCode == 8) {
        if (pixelPos.y == 0.0 || pixelPos.y == 3.0 || pixelPos.y == 6.0) pixel = 1.0;
        if (pixelPos.x == 0.0 || pixelPos.x == 4.0) pixel = 1.0;
    } else if (charCode == 9) {
        if (pixelPos.y == 0.0 || pixelPos.y == 3.0 || pixelPos.y == 6.0) pixel = 1.0;
        if (pixelPos.x == 0.0 && pixelPos.y > 3.0) pixel = 1.0;
        if (pixelPos.x == 4.0) pixel = 1.0;
    } else if (charCode == 10) {
        if (pixelPos.x == 2.0 && (pixelPos.y == 2.0 || pixelPos.y == 4.0)) pixel = 1.0;
    } else if (charCode == 11) {
        if (pixelPos.x == 0.0) pixel = 1.0;
        if (pixelPos.y == 6.0 || pixelPos.y == 3.0) pixel = 1.0;
        if (pixelPos.x == 2.0 && (pixelPos.y > 5.0 || pixelPos.y == 2.0)) pixel = 1.0;
        if (pixelPos.x == 3.0 && (pixelPos.y > 5.0 || pixelPos.y == 1.0)) pixel = 1.0;
        if (pixelPos.x == 4.0 && (pixelPos.y > 3.0 || pixelPos.y == 0.0)) pixel = 1.0;
    } else if (charCode == 12) {
        if (pixelPos.x == 0.0) pixel = 1.0;
        if (pixelPos.y == 0.0 || pixelPos.y == 3.0 || pixelPos.y == 6.0) pixel = 1.0;
    } else if (charCode == 13) {
        if (pixelPos.x == 0.0 && pixelPos.y > 0.0 && pixelPos.y < 6.0) pixel = 1.0;
        if ((pixelPos.y == 0.0 || pixelPos.y == 6.0) && pixelPos.x > 0.0) pixel = 1.0;
    } else if (charCode == 14) {
        if (pixelPos.x == 0.0 && pixelPos.y > 0.0 && pixelPos.y < 1.0) pixel = 1.0;
        if ((pixelPos.y == 1.0 || pixelPos.y == 0.0) && pixelPos.x > 2.0) pixel = 1.0;
    }
    return pixel;
}

vec3 drawVHSUI(vec3 color, vec2 uv, float time) {
    vec3 uiColor = color;
    float ui = 0.0;
    #if VHS_LETTERBOX_ORIENTATION == 0 // Горизонтальные рамки
    float letterboxHeight = 0.15;
    if (uv.x < 0.55 && uv.y > 0.85 && uv.y < 1.0) {
        ui += drawChar(uv, vec2(0.17, 0.92), 11);
        ui += drawChar(uv, vec2(0.19, 0.92), 12);
        ui += drawChar(uv, vec2(0.21, 0.92), 13);
        float blink = step(0.5, fract(time * 0.5));
        if (uv.x > 0.235 && uv.x < 0.245 && uv.y > 0.915 && uv.y < 0.925) {
            uiColor = mix(uiColor, vec3(1.0, 0.0, 0.0), blink);
        }
    }
    if (uv.x > 0.6 && uv.y > 0.85 && uv.y < 1.0) {
        float totalSeconds = time + 01.0 * 3600.0 + 15.0 * 60.0;
        int hours = int(mod(totalSeconds / 3600.0, 24.0));
        int minutes = int(mod(totalSeconds / 60.0, 60.0));
        int seconds = int(mod(totalSeconds, 60.0));
        int hourTens = hours / 10;
        int hourOnes = hours - hourTens * 10;
        ui += drawChar(uv, vec2(0.73, 0.92), hourTens);
        ui += drawChar(uv, vec2(0.75, 0.92), hourOnes);
        ui += drawChar(uv, vec2(0.77, 0.92), 10);
        int minuteTens = minutes / 10;
        int minuteOnes = minutes - minuteTens * 10;
        ui += drawChar(uv, vec2(0.79, 0.92), minuteTens);
        ui += drawChar(uv, vec2(0.81, 0.92), minuteOnes);
    }
    if (uv.x < 0.55 && uv.y > 0.0 && uv.y < letterboxHeight) {
        float daysSinceStart = floor(time / 86400.0);
        int currentDay = int(mod(25.0 + daysSinceStart, 31.0));
        if (currentDay == 0) currentDay = 31;
        int dayTens = currentDay / 10;
        int dayOnes = currentDay - dayTens * 10;
        ui += drawChar(uv, vec2(0.17, 0.08), dayTens);
        ui += drawChar(uv, vec2(0.19, 0.08), dayOnes);
        ui += drawChar(uv, vec2(0.21, 0.08), 14);
        ui += drawChar(uv, vec2(0.23, 0.08), 1);
        ui += drawChar(uv, vec2(0.25, 0.08), 2);
        ui += drawChar(uv, vec2(0.27, 0.08), 14);
        ui += drawChar(uv, vec2(0.29, 0.08), 1);
        ui += drawChar(uv, vec2(0.31, 0.08), 9);
        ui += drawChar(uv, vec2(0.33, 0.08), 9);
        ui += drawChar(uv, vec2(0.35, 0.08), 8);
    }
    if (uv.x > 0.6 && uv.y > 0.0 && uv.y < letterboxHeight) {
        float recordingTime = time;
        int recordHours = int(recordingTime / 3600.0);
        int recordMinutes = int(mod(recordingTime / 60.0, 60.0));
        int recordSeconds = int(mod(recordingTime, 60.0));
        int hourTens = recordHours / 10;
        int hourOnes = recordHours - hourTens * 10;
        ui += drawChar(uv, vec2(0.67, 0.08), hourTens);
        ui += drawChar(uv, vec2(0.69, 0.08), hourOnes);
        ui += drawChar(uv, vec2(0.71, 0.08), 10);
        int minuteTens = recordMinutes / 10;
        int minuteOnes = recordMinutes - minuteTens * 10;
        ui += drawChar(uv, vec2(0.73, 0.08), minuteTens);
        ui += drawChar(uv, vec2(0.75, 0.08), minuteOnes);
        ui += drawChar(uv, vec2(0.77, 0.08), 10);
        int secondTens = recordSeconds / 10;
        int secondOnes = recordSeconds - secondTens * 10;
        ui += drawChar(uv, vec2(0.79, 0.08), secondTens);
        ui += drawChar(uv, vec2(0.81, 0.08), secondOnes);
    }
    #else // Вертикальные рамки
    float letterboxWidth = 0.15;
    if (uv.y < 0.55 && uv.x > 0.85 && uv.x < 1.0) {
        ui += drawChar(uv, vec2(0.92, 0.17), 11);
        ui += drawChar(uv, vec2(0.92, 0.19), 12);
        ui += drawChar(uv, vec2(0.92, 0.21), 13);
        float blink = step(0.5, fract(time * 0.5));
        if (uv.y > 0.235 && uv.y < 0.245 && uv.x > 0.915 && uv.x < 0.925) {
            uiColor = mix(uiColor, vec3(1.0, 0.0, 0.0), blink);
        }
    }
    if (uv.y > 0.6 && uv.x > 0.85 && uv.x < 1.0) {
        float totalSeconds = time + 01.0 * 3600.0 + 15.0 * 60.0;
        int hours = int(mod(totalSeconds / 3600.0, 24.0));
        int minutes = int(mod(totalSeconds / 60.0, 60.0));
        int seconds = int(mod(totalSeconds, 60.0));
        int hourTens = hours / 10;
        int hourOnes = hours - hourTens * 10;
        ui += drawChar(uv, vec2(0.92, 0.73), hourTens);
        ui += drawChar(uv, vec2(0.92, 0.75), hourOnes);
        ui += drawChar(uv, vec2(0.92, 0.77), 10);
        int minuteTens = minutes / 10;
        int minuteOnes = minutes - minuteTens * 10;
        ui += drawChar(uv, vec2(0.92, 0.79), minuteTens);
        ui += drawChar(uv, vec2(0.92, 0.81), minuteOnes);
    }
    if (uv.y < 0.55 && uv.x > 0.0 && uv.x < letterboxWidth) {
        float daysSinceStart = floor(time / 86400.0);
        int currentDay = int(mod(25.0 + daysSinceStart, 31.0));
        if (currentDay == 0) currentDay = 31;
        int dayTens = currentDay / 10;
        int dayOnes = currentDay - dayTens * 10;
        ui += drawChar(uv, vec2(0.08, 0.17), dayTens);
        ui += drawChar(uv, vec2(0.08, 0.19), dayOnes);
        ui += drawChar(uv, vec2(0.08, 0.21), 14);
        ui += drawChar(uv, vec2(0.08, 0.23), 1);
        ui += drawChar(uv, vec2(0.08, 0.25), 2);
        ui += drawChar(uv, vec2(0.08, 0.27), 14);
        ui += drawChar(uv, vec2(0.08, 0.29), 1);
        ui += drawChar(uv, vec2(0.08, 0.31), 9);
        ui += drawChar(uv, vec2(0.08, 0.33), 9);
        ui += drawChar(uv, vec2(0.08, 0.35), 8);
    }
    if (uv.y > 0.6 && uv.x > 0.0 && uv.x < letterboxWidth) {
        float recordingTime = time;
        int recordHours = int(recordingTime / 3600.0);
        int recordMinutes = int(mod(recordingTime / 60.0, 60.0));
        int recordSeconds = int(mod(recordingTime, 60.0));
        int hourTens = recordHours / 10;
        int hourOnes = recordHours - hourTens * 10;
        ui += drawChar(uv, vec2(0.08, 0.67), hourTens);
        ui += drawChar(uv, vec2(0.08, 0.69), hourOnes);
        ui += drawChar(uv, vec2(0.08, 0.71), 10);
        int minuteTens = recordMinutes / 10;
        int minuteOnes = recordMinutes - minuteTens * 10;
        ui += drawChar(uv, vec2(0.08, 0.73), minuteTens);
        ui += drawChar(uv, vec2(0.08, 0.75), minuteOnes);
        ui += drawChar(uv, vec2(0.08, 0.77), 10);
        int secondTens = recordSeconds / 10;
        int secondOnes = recordSeconds - secondTens * 10;
        ui += drawChar(uv, vec2(0.08, 0.79), secondTens);
        ui += drawChar(uv, vec2(0.08, 0.81), secondOnes);
    }
    #endif
    if (ui > 0.0) {
        uiColor = mix(uiColor, vec3(1.0, 1.0, 1.0), ui * 0.8);
    }
    return uiColor;
}

vec3 vhs_effect(vec2 texcoord, vec3 base_color) {
    float time = frameTimeCounter;
    vec2 uv = texcoord;
    vec3 color = base_color;

    #if VHS_LETTERBOX_ENABLED == 1
    #if VHS_LETTERBOX_ORIENTATION == 0 // Горизонтальные рамки
    float letterboxHeight = 0.15;
    float activeAreaStart = letterboxHeight;
    float activeAreaEnd = 1.0 - letterboxHeight;
    bool inLetterbox = (uv.y < letterboxHeight || uv.y > (1.0 - letterboxHeight));
    vec2 mainUV = uv;
    if (!inLetterbox) {
        mainUV.y = (uv.y - letterboxHeight) / (1.0 - 2.0 * letterboxHeight);
    }
    if (inLetterbox) {
        color = vec3(0.0, 0.0, 0.0);
    } else {
        vec2 distortedUV = vhsDistortion(mainUV, time);
        color = chromaShift(colortex3, distortedUV, time);
        if (length(color) < 0.05) {
            color = texture2D(colortex3, mainUV).rgb;
        }
        color = glitchBlocks(color, mainUV, time);
        color *= scanlines(mainUV);
        color += filmGrain(mainUV, time);
        color += trackingLines(mainUV, time);
        color = vhsColor(color, time);
        vec2 center = mainUV - 0.5;
        float vignette = 1.0 - dot(center, center) * 0.3;
        color *= vignette;
        color = clamp(color, 0.0, 1.0);
    }
    color = drawVHSUI(color, uv, time);
    #else // Вертикальные рамки
    float letterboxWidth = 0.15;
    float activeAreaStart = letterboxWidth;
    float activeAreaEnd = 1.0 - letterboxWidth;
    bool inLetterbox = (uv.x < letterboxWidth || uv.x > (1.0 - letterboxWidth));
    vec2 mainUV = uv;
    if (!inLetterbox) {
        mainUV.x = (uv.x - letterboxWidth) / (1.0 - 2.0 * letterboxWidth);
    }
    if (inLetterbox) {
        color = vec3(0.0, 0.0, 0.0);
    } else {
        vec2 distortedUV = vhsDistortion(mainUV, time);
        color = chromaShift(colortex3, distortedUV, time);
        if (length(color) < 0.02) {
            color = texture2D(colortex3, mainUV).rgb;
        }
        color = glitchBlocks(color, mainUV, time);
        color *= scanlines(mainUV);
        color += filmGrain(mainUV, time);
        color += trackingLines(mainUV, time);
        color = vhsColor(color, time);
        vec2 center = mainUV - 0.5;
        float vignette = 1.0 - dot(center, center) * 0.3;
        color *= vignette;
        color = clamp(color, 0.0, 1.0);
    }
    color = drawVHSUI(color, uv, time);
    #endif
    #else // Рамки отключены
    vec2 distortedUV = vhsDistortion(uv, time);
    color = chromaShift(colortex3, distortedUV, time);
    if (length(color) < 0.02) {
        color = texture2D(colortex3, uv).rgb;
    }
    color = glitchBlocks(color, uv, time);
    color *= scanlines(uv);
    color += filmGrain(uv, time);
    color += trackingLines(uv, time);
    color = vhsColor(color, time);
    vec2 center = uv - 0.5;
    float vignette = 1.0 - dot(center, center) * 0.3;
    color *= vignette;
    color = clamp(color, 0.0, 1.0);
    #endif

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
vec3 applyBodycamEffects(vec2 texcoord, vec3 base_color) {
    vec3 color = base_color;
    vec2 uv = texcoord;

    #if BODYCAMMISC_ENABLED == 1 || BODYCAM_ENABLED == 1
    vec2 centered = (texcoord - 0.5) * ZOOM_NEW + 0.5;
    float distance = length(centered - 0.5);
    float depth = texture2D(depthtex0, texcoord).r;
    float linearDepth = linearizeDepth(depth, 0.1, 100.0);

    #if BODYCAMMISC_ENABLED == 1
    vec2 crtUV = applyCRTCurve(centered);
    #else
    vec2 crtUV = centered;
    #endif

    vec2 shake = cameraShake(frameTimeCounter, INTENSITY_CAM_SHAKE_NEW) + handSway(frameTimeCounter, HAND_SWAY_STRENGTH);
    vec2 rotatedUV = rotateUV(crtUV + shake, sin(frameTimeCounter * 0.5) * 0.02);

    #if BODYCAM_ENABLED == 1
    float center_factor = pow(distance, 2.0) * FISHEYE_CENTER_STRENGTH;
    vec2 fisheyeUV = (rotatedUV - 0.5) * (1.0 + DIST_STRENGTH * (distance * distance + center_factor)) + 0.5;
    #else
    vec2 fisheyeUV = rotatedUV;
    #endif

#if BODYCAM_ENABLED == 1
    // === НОВАЯ БОДИКАМ ХРОМАТКА С ДВУМЯ ПАРАМЕТРАМИ ===
    float caStrength = BODYCAM_CHROMA_STRENGTH * distance;
    vec3 caColor;
    caColor.r = texture2D(colortex3, fisheyeUV + vec2(caStrength, 0.0)).r;
    caColor.g = texture2D(colortex3, fisheyeUV).g;
    caColor.b = texture2D(colortex3, fisheyeUV + vec2(-caStrength, 0.0)).b;

    // Плавное смешивание с оригиналом через opacity
    color = mix(color, caColor, BODYCAM_CHROMA_OPACITY);
#else
    color = texture2D(colortex3, fisheyeUV).rgb;
#endif

    #if BODYCAMMISC_ENABLED == 1
    vec2 texelSize = 1.0 / vec2(viewWidth, viewHeight);
    vec3 sharpenedColor = vec3(0.0);
    sharpenedColor += texture2D(colortex3, fisheyeUV + texelSize * vec2(-1.0, 0.0)).rgb * -0.25;
    sharpenedColor += texture2D(colortex3, fisheyeUV + texelSize * vec2(1.0, 0.0)).rgb * -0.25;
    sharpenedColor += texture2D(colortex3, fisheyeUV + texelSize * vec2(0.0, -1.0)).rgb * -0.25;
    sharpenedColor += texture2D(colortex3, fisheyeUV + texelSize * vec2(0.0, 1.0)).rgb * -0.25;
    sharpenedColor += texture2D(colortex3, fisheyeUV).rgb * 2.0;
    color = mix(color, sharpenedColor, SHARPNESS_STRENGTH);
    #endif

    color = clamp(color, 0.0, 1.0);

    #if BODYCAMMISC_ENABLED == 1
    color = applyBloom(fisheyeUV, color);
    #endif

    #if BODYCAMMISC_ENABLED == 1
    color = applyPS1Style(fisheyeUV, color);
    #endif

    float luminance = dot(color, vec3(0.299, 0.587, 0.114));
    vec3 desaturated = mix(vec3(luminance), color, SATURATION);
    desaturated = pow(desaturated, vec3(0.9));
    float newLum = dot(desaturated, vec3(0.299, 0.587, 0.114));
    if (newLum > 0.0) {
        desaturated *= luminance / newLum;
    }
    color = desaturated;

    #if BODYCAM_ENABLED == 1
    color.r *= 0.975;
    color.g *= 1.025;
    color.b *= 1.05;
    #endif

    #if SCANLINE == 1
    float scanline = sin(fisheyeUV.y * SCANLINE_WIDTH_NEW * 1.5) * SCANLINE_STRENGTH_NEW;
    color += scanline;
    #endif

    #if GRAIN == 1
    float noise = (bodyCamNoise(fisheyeUV + vec2(frameTimeCounter)) - 0.5) * GRAIN_STRENGTH;
    #if DYNAMIC_NOISE == 1 && BODYCAMMISC_ENABLED == 1
    noise *= (1.0 + DYNAMIC_NOISE_STRENGTH * (isSneaking + sin(frameTimeCounter * 2.0)));
    #endif
    color += vec3(noise);
    #endif

    #if COLOR_DIST == 1
    float colorDistort = COLOR_DIST_STRENGTH * sin(frameTimeCounter * 2.0);
    color *= vec3(1.0 + colorDistort, 1.0 - colorDistort, 1.0 + colorDistort);
    #endif

    #if ENABLE_NVG_IsSneaking == 1
    if (isSneaking == 1.0 || NVG == 1) {
        float gray = dot(color, vec3(0.299, 0.587, 0.114));
        vec3 grayscale = vec3(gray);
        vec3 colorTransform = vec3(R, G, B) * degree_brightness_increase;
        color = grayscale * colorTransform;
    }
    #endif

    color *= pow(2.0, EXPOSURE);
    color += BRIGHTNESS;
    color = ((color - 0.5) * CONTRAST) + 0.5;

    #if VIGNETTE == 1
    float vignette = smoothstep(VIGNETTE_RADIUS_NEW, VIGNETTE_RADIUS_NEW + VIGNETTE_STRENGTH_NEW, distance);
    #if DYNAMIC_VIGNETTE == 1 && BODYCAMMISC_ENABLED == 1
    float mouseMotion = length(mouseDelta) * 10.0;
    vignette *= (1.0 + DYNAMIC_VIGNETTE_STRENGTH * clamp(mouseMotion, 0.0, 1.0));
    #endif
    color = mix(color, vec3(0.0), vignette);
    #endif

    #if BODYCAMMISC_ENABLED == 1
    float cubicVignette = applyCubicVignette(texcoord);
    color = mix(color, vec3(0.0), cubicVignette);
    #endif

    #if BLACK_STRIPES == 1
    float leftStripe = smoothstep(BLACK_STRIPES_WIDTH_NEW, BLACK_STRIPES_WIDTH_NEW - BLACK_STRIPES_SOFT_NEW, texcoord.x);
    float rightStripe = smoothstep(1.0 - BLACK_STRIPES_WIDTH_NEW, 1.0 - (BLACK_STRIPES_WIDTH_NEW - BLACK_STRIPES_SOFT_NEW), texcoord.x);
    float stripeEffect = max(leftStripe, rightStripe);
    color = mix(color, vec3(0.0), stripeEffect);
    #endif

    float fov_mask = blackFOVMask(texcoord);
    color = mix(color, vec3(0.0), 1.0 - fov_mask);

    color = drawImage(texcoord, color);
    #endif

    return color;
}

// Main function
void main() {
    ivec2 texel = ivec2(gl_FragCoord.xy);
    vec2 texcoord = gl_FragCoord.xy / vec2(viewWidth, viewHeight);

    #ifdef DEBUG_DRAWBUFFERS
        finalData = texelFetch(colortex4, texel, 0).rgb;
    #else
        if (abs(MC_RENDER_QUALITY - 1.0) < 1e-2) {
            finalData = CASFilter(texel);
        } else {
            finalData = textureCatmullRomFast(colortex3, texcoord * MC_RENDER_QUALITY, 0.6);
        }
        finalData += (bayer16(gl_FragCoord.xy) - 0.5) * rcp(255.0);

        if (VHS_ENABLED == 1) {
            finalData = vhs_effect(texcoord, finalData);
        } else if (BODYCAM_ENABLED == 1 || BODYCAMMISC_ENABLED == 1) {
            finalData = applyBodycamEffects(texcoord, finalData);
        }

        finalData = applyChromaticAberration(texcoord, finalData);

    //finalData = applyElytraMotionBlur(texcoord, finalData);

        

        // Posterize + Desat
        #if POSTERIZATION_ENABLED == 1
        vec3 lum = vec3(0.299, 0.587, 0.114);
        float gray = dot(finalData.rgb, lum);
        finalData.rgb = mix(vec3(gray), finalData.rgb, SATURATION);
        
        float maxC = max(finalData.r, max(finalData.g, finalData.b));
        float levels = float(POSTERIZATION_LEVELS);
        finalData.rgb *= floor(maxC * levels) / levels / maxC;
        #endif

        vec4 sunClipPos = gbufferProjection * vec4(sunPosition, 1.0);
        vec2 lightPos = (sunClipPos.xy / sunClipPos.w) * 0.5 + 0.5;
        float truePos = 1.0;
        float multiplier = LENS_FLARE_STRENGTH;
        if (sunVisibility > 0.0 && rainStrength < 0.3) {
            LensFlare(finalData, texcoord, lightPos, truePos, multiplier);
        }




        finalData = applyEyeImitation(texcoord, finalData);
    #endif
}