out vec3 blurColor;

/* DRAWBUFFERS:2 */

uniform sampler2D colortex2; // Текстура с вектором скорости
uniform sampler2D colortex5; // Текстура с цветом

uniform vec2 screenSize;
uniform vec2 screenPixelSize;

#include "/lib/Head/Common.inc"

//----// SETTINGS //-----------------------------------------------------------------------------//

#define MOTION_BLUR_SAMPLES 8 // Количество выборок для размытия [4 8 12 16]
#define MOTION_BLUR_STRENGTH 2.0 // Сила размытия [0.5 1.0 1.5 2.0 2.1 2.2 2.3 2.4 2.5 2.6 2.7 2.8 2.9 3.0]
#define NOISE_SCALE 0.5 // Влияние шума на выборку [0.2 0.5 0.8 1.0]

//----// FUNCTIONS //-----------------------------------------------------------------------------//

float InterleavedGradientNoise(in vec2 coord) {
    return fract(52.9829189 * fract(0.06711056 * coord.x + 0.00583715 * coord.y));
}

vec3 MotionBlur() {
    ivec2 texel = ivec2(gl_FragCoord.xy);
    vec2 screenCoord = gl_FragCoord.xy * screenPixelSize;

    // Получаем вектор скорости из colortex2
    vec2 velocity = texelFetch(colortex2, texel, 0).xy;

    //Я ЕБАЛ НАХУЙ КОДИТЬ НА ГЛСЛ возвращаем исходный цвет
    if (length(velocity) < 1e-7) {
        return texelFetch(colortex5, texel, 0).rgb;
    }

    // Нормализуем и масштабируем скорость
    float velocityLength = length(velocity);
    velocity = clamp(velocity * 0.1, -0.28, 0.28); // Ограничиваем для стабильности
    float rSteps = 1.0 / float(MOTION_BLUR_SAMPLES);
    velocity *= MOTION_BLUR_STRENGTH * rSteps / (1.0 + velocityLength);

    // Инициализируем шум для рандомизации
    float dither = InterleavedGradientNoise(gl_FragCoord.xy);
    vec2 sampleCoord = screenCoord - velocity * (float(MOTION_BLUR_SAMPLES) * 0.5);

    vec3 blurColor = vec3(0.0);
    float totalWeight = 0.0;




    // Сэмплируем с учетом шума ТАК А НАХУЙ ТІ КОМЕНТІ ОСТАВЛЯЕШ? 
    for (uint i = 0u; i < MOTION_BLUR_SAMPLES; ++i) {
        // Добавляем шум к позиции выборки
        float noise = InterleavedGradientNoise(gl_FragCoord.xy + float(i) * 123.456);
        vec2 offset = velocity * (float(i) + noise * NOISE_SCALE - 0.5);
        vec2 samplePos = screenCoord + offset;

        // Ограничиваем координаты выборки
        samplePos = clamp(samplePos * screenSize, vec2(2.0), screenSize - 2.0);

        // Добавляем цвет с весом, зависящим от шума (для мягкости)
        float weight = 1.0 - abs(noise - 0.5) * 0.5; // Вес выборки
        blurColor += texelFetch(colortex5, ivec2(samplePos), 0).rgb * weight;
        totalWeight += weight;
    }

    // Нормализуем результат
    return clamp16F(blurColor / totalWeight);
}

//----// MAIN //----------------------------------------------------------------------------------//

void main() {
    #ifdef MOTION_BLUR
        blurColor = MotionBlur();
    #else
        blurColor = texelFetch(colortex5, ivec2(gl_FragCoord.xy), 0).rgb;
    #endif
}