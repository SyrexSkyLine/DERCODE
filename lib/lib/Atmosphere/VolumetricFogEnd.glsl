//#define RAY_STAINED_GLASS_TINT

#define UW_VOLUMETRIC_LIGHT_STRENGTH 0.1 // [0.01 0.015 0.02 0.03 0.05 0.075 0.1 0.15 0.2 0.3 0.5 0.75 1.0 1.5 2.0 3.0 5.0 7.5 10.0 15.0 20.0 30.0 50.0 75.0 100.0]
#define UW_VOLUMETRIC_LIGHT_LENGTH 50.0 // [10.0 15.0 20.0 25.0 30.0 35.0 40.0 45.0 50.0 55.0 60.0 80.0 100.0 120.0 150 200.0 300.0]

//------------------------------------------------------------------------------------------------//

#include "/lib/Lighting/ShadowDistortion.glsl"

mat2 rot2D(float a) {
    float c = cos(a), s = sin(a);
    return mat2(c, -s, s, c);
}

vec3 WorldPosToShadowPos(in vec3 worldPos) {
	vec3 shadowClipPos = transMAD(shadowModelView, worldPos);
	shadowClipPos = projMAD(shadowProjection, shadowClipPos);
	shadowClipPos.z *= 0.2;

	return shadowClipPos * 0.5 + 0.5;
}

vec2 DistortShadowSpace(in vec2 shadowClipPos) {
	shadowClipPos = shadowClipPos * 2.0 - 1.0;
	shadowClipPos.xy *= rcp(DistortionFactor(shadowClipPos.xy));

	return shadowClipPos * 0.5 + 0.5;
}

#ifdef DARK_END
	float darkEnd = float(bossBattle == 2 || bossBattle == 3);
#else
	const float darkEnd = 0.0;
#endif

vec3 fogWind = vec3(1.0, 0.3, 0.6) * worldTimeCounter * (0.006 + darkEnd * 0.02);

float CalculateFogDensity(in vec3 rayPosition) {
	float falloff = exp2(-abs(rayPosition.y + 24.0) * 0.015);

	rayPosition *= 0.015;
	rayPosition += fogWind;
	float noise = Get3DNoiseSmooth(rayPosition) * 0.5;
		rayPosition += fogWind;
	noise += Get3DNoiseSmooth(rayPosition * 3.6) * 0.25;
		rayPosition += fogWind;
	noise += Get3DNoiseSmooth(rayPosition * 12.0) * 0.125;
		rayPosition += fogWind;
	noise += Get3DNoiseSmooth(rayPosition * 56.0) * 0.0625;

	//noise = curve(smoothstep(0.2, 0.7, noise)) - falloff * 0.2;

	return saturate(falloff * noise * 40.0 - 8.0 + darkEnd) * 0.2;
}

// Новая функция для кастомных эффектов (аккреционный диск + вортексы)
float CalculateCustomDensity(in vec3 pos) {
    float density = 0.0;

    // ──────────────────────────────────────────────────────────────
    // Bliss-style концентрические вихревые кольца каждые 10 блоков
    // ──────────────────────────────────────────────────────────────
    const float baseRingRadius = 60.0;   // первое кольцо на 60 блоках
    const float ringSpacing    = 10.0;   // каждое следующее — +10 блоков
    const int   numRings       = 9;      // 60, 70, 80, 90, 100, 110, 120, 130, 140
    const float ringThickness  = 4.0;
    const float wallMinY       = 60.0;
    const float wallMaxY       = 280.0;

    if (pos.y > wallMinY && pos.y < wallMaxY) {
        vec3 islandCenter = vec3(0.0, 70.0, 0.0);

        for (int i = 0; i < numRings; ++i) {
            float currentRadius = baseRingRadius + float(i) * ringSpacing;

            // Сужение к верху (как в Bliss — кольца "всасываются" в портал)
            float taper = 1.0 - smoothstep(wallMinY, wallMaxY, pos.y) * 0.45;
            float taperedRadius = currentRadius * taper;

            float distToRing = abs(length(pos.xz - islandCenter.xz) - taperedRadius);

            if (distToRing < ringThickness) {
                // Bliss-style многооктавный swirl
                float angle = atan(pos.z - islandCenter.z, pos.x - islandCenter.x);
                angle += worldTimeCounter * (0.35 + float(i) * 0.06); // разная скорость вращения
                angle += pos.y * 0.035 + float(i) * 0.7;             // смещение фазы по высоте и индексу

                float swirl  = sin(angle * 8.0)                     * 0.50;
                swirl       += sin(angle * 16.0 + worldTimeCounter * 0.15) * 0.30;
                swirl       += sin(angle * 32.0 + pos.y * 0.08)      * 0.20;
                swirl        = swirl * 0.5 + 0.5; // [0;1]

                // Плавное появление снизу и затухание сверху
                float heightFactor  = smoothstep(wallMinY, wallMinY + 50.0, pos.y);
                heightFactor       *= 1.0 - smoothstep(wallMaxY - 60.0, wallMaxY, pos.y);

                float ringDens = exp(-distToRing * 0.45) * swirl * heightFactor * 0.42;

                density += ringDens;
            }
        }
    }

    // ──────────────────────────────────────────────────────────────
    // Центральный восходящий вортекс (над драконом)
    // ──────────────────────────────────────────────────────────────
    if (pos.y > 0.0 && pos.y < 300.0) {
        float distToAxis = length(pos.xz);
        if (distToAxis < 20.0) {
            float angle = atan(pos.z, pos.x) + worldTimeCounter * 0.22;
            float swirl = sin(angle * 10.0 + pos.y * 0.05) * 0.5 + 0.5;
            float heightFactor = smoothstep(0.0, 300.0, pos.y) * (1.0 - smoothstep(270.0, 300.0, pos.y));
            density += exp(-distToAxis * 0.2) * swirl * heightFactor * 0.32;
        }
    }

    // ──────────────────────────────────────────────────────────────
    // 8 столбов-спиралей вокруг острова (как в оригинальном Bliss)
    // ──────────────────────────────────────────────────────────────
    const float pillarRadius = 45.0;
    const float numPillars   = 8.0;
    const float pillarThick  = 2.2;

    if (pos.y > 0.0 && pos.y < 300.0) {
        for (float i = 0.0; i < numPillars; ++i) {
            float theta = radians(i * 45.0);
            vec2 base = vec2(cos(theta), sin(theta)) * pillarRadius;

            // Наклон столбов к центру с высотой
            float taper = 1.0 - (pos.y / 300.0);
            vec2 tilted = base * taper;
            vec3 pillarCenter = vec3(tilted.x, pos.y, tilted.y);

            float dist = length(pos.xz - pillarCenter.xz);
            if (dist < pillarThick) {
                float angle = atan(pos.z - pillarCenter.z, pos.x - pillarCenter.x) + worldTimeCounter * 0.25 + pos.y * 0.06;
                float swirl = sin(angle * 11.0) * 0.5 + 0.5;
                float hFactor = smoothstep(0.0, 300.0, pos.y) * (1.0 - smoothstep(260.0, 300.0, pos.y));
                density += exp(-dist * 0.25) * swirl * hFactor * 0.28;
            }
        }
    }

    // ──────────────────────────────────────────────────────────────
    // Дополнительные горизонтальные вихри (оставляем как было)
    // ──────────────────────────────────────────────────────────────
    vec3 mainCenter = vec3(0.0, 70.0 + sin(worldTimeCounter * 0.1) * 20.0, sin(worldTimeCounter * 0.05) * 30.0);
    mainCenter.y += worldTimeCounter * 0.01;
    float distMain = length(pos - mainCenter);
    float radCheck = length(pos.xz);
    if (distMain < 30.0 && abs(radCheck - 300.0) < 20.0) {
        vec3 rel = pos - mainCenter;
        float angle = atan(rel.z, rel.x) + worldTimeCounter * 0.3 + mainCenter.y * 0.1;
        float swirl = sin(angle * 8.0) * 0.5 + 0.5;
        density += exp(-distMain * 0.1) * swirl * 0.38;
    }

    // Второй слой на ~100 блоках
    vec3 sec1 = vec3(0.0, 90.0 + sin(worldTimeCounter * 0.08) * 10.0, 100.0);
    vec3 sec2 = vec3(0.0, 120.0 + sin(worldTimeCounter * 0.08) * 10.0, 0.0);
    float d1 = length(pos - sec1);
    float d2 = length(pos - sec2);
    float rad100 = length(pos.xz);
    if ((d1 < 25.0 || d2 < 25.0) && abs(rad100 - 100.0) < 15.0 && pos.y > 80.0 && pos.y < 130.0) {
        float a1 = atan(pos.z - 100.0, pos.x) + worldTimeCounter * 0.15;
        float a2 = atan(pos.z, pos.x) + worldTimeCounter * 0.15;
        float s1 = sin(a1 * 6.0 + pos.y * 0.2) * 0.5 + 0.5;
        float s2 = sin(a2 * 6.0 + pos.y * 0.2) * 0.5 + 0.5;
        density += (exp(-d1 * 0.15) * s1 + exp(-d2 * 0.15) * s2) * 0.26 * exp(-(pos.y - 105.0) * (pos.y - 105.0) * 0.05);
    }

    return density;
}

const int shadowMapResolution = 2048;  // Shadowmap resolution [1024 2048 4096 8192 16384 32768]
const float realShadowMapRes = shadowMapResolution * MC_SHADOW_QUALITY;

vec4 CalculateVolumetricFog(in vec3 worldPos, in vec3 worldDir, in float dither) {	
	//worldPos *= min(1.0, far / length(worldPos));
	//worldPos *= min(1.0, far * 1.2 / length(worldPos));
	//worldPos *= min(1.0, far / length(worldPos));
	float rayLength = min(1e3, length(worldPos));

	uint steps = uint(12.0 + rayLength * 0.1);
	     steps = min(steps, 26u);

	float rSteps = 1.0 / float(steps);

	float stepLength = rayLength * rSteps,
		  transmittance = 1.0,
		  LdotV = dot(worldLightVector, worldDir),
		  LdotV01 = LdotV * 0.5 + 0.5,
		  skylightSample = 0.0;

	float airDensity = RayleighPhase(LdotV) * 0.4 * exp2(-worldDir.y * 2.0) / far;

	vec3 rayStep = worldDir * stepLength,
		 rayPosition = rayStep * dither + gbufferModelViewInverse[3].xyz + cameraPosition;

	vec3 shadowStart = WorldPosToShadowPos(gbufferModelViewInverse[3].xyz),
		 shadowEnd = WorldPosToShadowPos(rayStep + gbufferModelViewInverse[3].xyz);

	vec3 shadowStep = shadowEnd - shadowStart,
		 shadowPosition = shadowStep * dither + shadowStart;
	vec3 sunlightSample = vec3(0.0);

	float phases1 = (HenyeyGreensteinPhase(LdotV, 0.5) 		   + HenyeyGreensteinPhase(LdotV, -0.3))		 * 0.5,
		  phases2 = (HenyeyGreensteinPhase(LdotV * 0.5, 0.5)   + HenyeyGreensteinPhase(LdotV * 0.5, -0.3))   * 0.25,
		  phases3 = (HenyeyGreensteinPhase(LdotV * 0.25, 0.5)  + HenyeyGreensteinPhase(LdotV * 0.25, -0.3))  * 0.125,
		  phases4 = (HenyeyGreensteinPhase(LdotV * 0.125, 0.5) + HenyeyGreensteinPhase(LdotV * 0.125, -0.3)) * 0.0625;

	// for (uint i = 0u; i < steps; ++i, rayPosition += rayStep, shadowPosition += shadowStep) {
    uint i = 0u;
	while (++i < steps) {
		rayPosition += rayStep, shadowPosition += shadowStep;

		vec2 shadowProjPos = DistortShadowSpace(shadowPosition.xy);
		if (saturate(shadowProjPos) != shadowProjPos) continue;
		ivec2 shadowTexel = ivec2(shadowProjPos * realShadowMapRes);
	
		float fogDensity = airDensity;
		float density = CalculateFogDensity(rayPosition);
		fogDensity += density;

        // Добавляем кастомную плотность от вортексов
        float customDensity = CalculateCustomDensity(rayPosition);
        fogDensity += customDensity;

		if (fogDensity < 1e-5) continue;
        fogDensity *= stepLength;

        // 1. Аккреционный диск с оранжевым свечением на (0, 300, 0)
        vec3 diskCenter = vec3(0.0, 300.0, 0.0);
        float diskThickness = 5.0;
        float diskRadius = 50.0;
        float diskDistY = abs(rayPosition.y - diskCenter.y);
        if (diskDistY < diskThickness) {
            vec2 xzDist = rayPosition.xz - diskCenter.xz;
            float radialDist = length(xzDist);
            if (radialDist < diskRadius) {
                float diskDens = exp(-diskDistY * diskDistY * 0.2) * (1.0 - radialDist / diskRadius) * 0.5;
                diskDens *= sin(worldTimeCounter * 0.5 + radialDist * 0.1 + atan(xzDist.y, xzDist.x)); // вращение анимация
                fogDensity += diskDens * 2.0; // усиление плотности для диска
                // Оранжевое свечение (эмиссив)
                vec3 orangeGlow = vec3(1.0, 0.4, 0.0) * diskDens * transmittance * stepLength * 10.0;
                sunlightSample += orangeGlow; // добавляем к свету для glow
            }
        }

		vec3 shadow = texelFetch(shadowtex1, shadowTexel, 0).xxx;
		shadow = step(shadowPosition.z, shadow);
		#ifdef RAY_STAINED_GLASS_TINT
			float translucentShadow = step(shadowPosition.z, texelFetch(shadowtex0, shadowTexel, 0).x);
            if (shadow.x != translucentShadow) {
				vec3 shadowColorSample = pow4(texelFetch(shadowcolor0, shadowTexel, 0).rgb);
				shadow = shadowColorSample * (shadow - translucentShadow) + vec3(translucentShadow);
			}
		#endif

		if (density > 1e-5) {
			float stepLength = 5.0, sunlightOD = 0.0;
			vec3 checkPos = rayPosition;
			for (uint i = 0u; i < 4u; ++i, checkPos += worldLightVector * stepLength) {
				float density = CalculateFogDensity(checkPos);
				if (density < 1e-5) continue;
				sunlightOD += density * stepLength;
				stepLength *= 1.5;
			}

			float scatteringSun = oneMinus(expf(-sunlightOD * 3.0)) * oneMinus(LdotV01) + LdotV01;
			scatteringSun *= expf(-sunlightOD * 4.0) * phases1
						+ expf(-sunlightOD * 2.0)  	* phases2
						+ expf(-sunlightOD * 1.0)  	* phases3
						+ expf(-sunlightOD * 0.5) 	* phases4;

			shadow *= scatteringSun * 4.0;
		}

		float stepTransmittance = expf(-fogDensity);

		float powder = rcp(fogDensity * 0.3 + 0.15) * fogDensity;
		powder = powder * oneMinus(LdotV01) + LdotV01;
		float fogSample = powder * transmittance * oneMinus(stepTransmittance);
		sunlightSample += shadow * fogSample;
		skylightSample += fogSample;

		transmittance *= stepTransmittance;

		if (transmittance < 1e-3) break;
	}

	vec3 fogSunColor = mix(vec3(0.99, 0.88, 0.27), vec3(0.04, 0.02, 0.05), darkEnd * 0.96) * sunlightSample;
	vec3 fogSkyColor = mix(vec3(0.99, 0.95, 0.6), vec3(0.04, 0.03, 0.06), darkEnd * 0.96) * 0.04 * skylightSample;

	vec3 fogColor = fogSunColor * 9.0 + fogSkyColor;

	return vec4(fogColor, transmittance);
}

vec3 UnderwaterVolumetricLight(in vec3 worldPos, in vec3 worldDir, in float dither) {
	float rayLength = min(24.0, length(worldPos));

	uint steps = uint(12.0 + 0.5 * rayLength);
	     steps = min(steps, 22u);

	float rSteps = 1.0 / float(steps);

	float stepLength = rayLength * rSteps;

	vec3 shadowStart = WorldPosToShadowPos(gbufferModelViewInverse[3].xyz),
		 shadowEnd = WorldPosToShadowPos(worldDir * stepLength + gbufferModelViewInverse[3].xyz);

	vec3 shadowStep = shadowEnd - shadowStart,
		 shadowPosition = shadowStep * dither + shadowStart;

	const vec3 coeff = waterAbsorption + 0.02;
	vec3 stepTransmittance = expf(-coeff * stepLength);
	vec3 transmittance = vec3(1.0);

	vec3 scattering = vec3(0.0);

    uint i = 0u;
	while (++i < steps) {
		shadowPosition += shadowStep;

		vec2 shadowProjPos = DistortShadowSpace(shadowPosition.xy);
		if (saturate(shadowProjPos) != shadowProjPos) continue;
		ivec2 shadowTexel = ivec2(shadowProjPos * realShadowMapRes);
	
        float translucentShadow = step(shadowPosition.z, texelFetch(shadowtex0, shadowTexel, 0).x);
        vec3 sampleShadow = vec3(1.0);

		if (translucentShadow < 1.0) {
			sampleShadow = step(shadowPosition.z, texelFetch(shadowtex1, shadowTexel, 0).xxx);

            if (sampleShadow.x != translucentShadow) {
				float waterDepth = abs(texelFetch(shadowcolor1, shadowTexel, 0).w * 512.0 - 128.0 - shadowPosition.y - eyeAltitude);
				if (waterDepth > 0.1) {
					sampleShadow = sqr(cube(texelFetch(shadowcolor0, shadowTexel, 0).rgb));
				} else {
					vec3 shadowColorSample = pow4(texelFetch(shadowcolor0, shadowTexel, 0).rgb);
					sampleShadow = shadowColorSample * (sampleShadow - translucentShadow) + vec3(translucentShadow);
				}

				sampleShadow *= expf(-coeff * 0.4 * max(waterDepth, 8.0));
			}
		}

		scattering += sampleShadow * transmittance * oneMinus(stepTransmittance);

		transmittance *= stepTransmittance;
	}

	vec3 lightVector = refract(worldLightVector, vec3(0.0, -1.0, 0.0), 1.0 / WATER_REFRACT_IOR);
	float LdotV = dot(lightVector, worldDir);
	float phase = HenyeyGreensteinPhase(LdotV, 0.8) + HenyeyGreensteinPhase(LdotV, 0.6);

	vec3 fogColor = 8.0 / coeff// * oneMinus(stepTransmittance)
	;
	fogColor *= scattering * phase * UW_VOLUMETRIC_LIGHT_STRENGTH;

	return fogColor;
}