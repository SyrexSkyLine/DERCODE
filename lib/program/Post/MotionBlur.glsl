out vec3 blurColor;

/* DRAWBUFFERS:2 */

uniform sampler2D colortex2;
uniform sampler2D colortex5;

uniform vec2 screenSize;
uniform vec2 screenPixelSize;
uniform vec3 cameraSpeed;  // Добавлен для расчёта скорости камеры

#include "/lib/Head/Common.inc"

// ===== ELYTRA MOTION BLUR НАСТРОЙКИ =====
// Включи один из стилей: 0=радиал (всегда), 1=по скорости (только >30 бл/сек), 2=комбо (всегда)
//----// FUNCTIONS //-----------------------------------------------------------------------------//

float InterleavedGradientNoise(in vec2 coord) {
    return fract(52.9829189 * fract(0.06711056 * coord.x + 0.00583715 * coord.y));
}

vec3 MotionBlur() {
	ivec2 texel = ivec2(gl_FragCoord.xy);
	vec2 screenCoord = gl_FragCoord.xy * screenPixelSize;

	vec2 velocity = texelFetch(colortex2, texel, 0).xy;

	if (length(velocity) < 1e-7) return texelFetch(colortex5, texel, 0).rgb;

    // ===== МЕХАНИКА СКОРОСТИ КАМЕРЫ (ТОЛЬКО ДЛЯ СТИЛЯ 1) =====
    float horizSpeed = length(cameraSpeed.xz);
    float vertSpeed = abs(cameraSpeed.y);
    float totalSpeed = max(horizSpeed, vertSpeed * 0.7);  // Учёт падения
    float speedFactor = smoothstep(30.0, 120.0, totalSpeed);  // 0 при <30, 1 при 120+

    #if ELYTRA_BLUR_STYLE == 1
        // Полное выключение при низкой скорости
        if (speedFactor < 0.01) {
            return texelFetch(colortex5, texel, 0).rgb;
        }
    #endif

	const float rSteps = rcp(float(MOTION_BLUR_SAMPLES));
	velocity *= MOTION_BLUR_STRENGTH * rSteps / (1.0 + length(velocity));

    // ===== МОДУЛЯЦИЯ СИЛЫ ДЛЯ СТИЛЯ 1 =====
    #if ELYTRA_BLUR_STYLE == 1
        velocity *= speedFactor * 1.8;  // Шлейф растёт с ускорением (подкрути 1.8)
    #endif

	float dither = InterleavedGradientNoise(gl_FragCoord.xy);

    vec2 sampleCoord = screenCoord + velocity * dither;
	sampleCoord -= velocity * MOTION_BLUR_SAMPLES * 0.5;

	vec3 blurColor = vec3(0.0);

	for (uint i = 0u; i < MOTION_BLUR_SAMPLES; ++i, sampleCoord += velocity) {
        blurColor += texelFetch(colortex5, ivec2(clamp(sampleCoord * screenSize, vec2(2.0), screenSize - 2.0)), 0).rgb;
	}

	return clamp16F(blurColor * rSteps);
}

//----// MAIN //----------------------------------------------------------------------------------//
void main() {
	#ifdef MOTION_BLUR
	#endif
	blurColor = MotionBlur();
}