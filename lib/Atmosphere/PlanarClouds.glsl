#define CLOUD_PLANE_ALTITUDE 7000 // [400 500 1000 1200 1500 1700 2000 3000 4000 5000 6000 6500 7000 7500 8000 9000 10000 12000]

#define CLOUD_PLANE0_DENSITY 1.0 // [0 0.1 0.2 0.3 0.4 0.6 0.8 1.0 1.2 1.5 1.7 2.0 3.0 5.0 7.5 10.0]
#define CLOUD_PLANE0_COVERY 0.5 // [0 0.05 0.1 0.15 0.2 0.25 0.3 0.35 0.4 0.45 0.5 0.55 0.6 0.65 0.7 0.8 0.9 1.0]

#define CLOUD_PLANE1_DENSITY 1.0 // [0 0.1 0.2 0.3 0.4 0.6 0.8 1.0 1.2 1.5 1.7 2.0 3.0 5.0 7.5 10.0]
#define CLOUD_PLANE1_COVERY 0.5 // [0 0.05 0.1 0.15 0.2 0.25 0.3 0.35 0.4 0.45 0.5 0.55 0.6 0.65 0.7 0.8 0.9 1.0]


//------------------------------------------------------------------------------------------------//

#if CIRRUS_CLOUDS == 1
    float GetCloudsNoise(vec2 position) { return texture(noisetex, position * 1e-2).a; }

    vec4 PlanarSample0(in float dist, in vec2 worldPos, in float LdotV) {
        worldPos /= 1.0 + distance(worldPos, cameraPosition.xz) * 5e-6;
        vec2 position = worldPos * 4e-5 - wind.xz;
        position += texture(noisetex, position * 0.04).y * 0.1;

        float localCoverage = texture(noisetex, position * 2e-3 + 0.15).x;

        const float goldenAngle = TAU / (PHI1 + 1.0);
        const mat2 goldenRotate = mat2(cos(goldenAngle), -sin(goldenAngle), sin(goldenAngle), cos(goldenAngle));

        float amplitude = 0.5;
        float noise = GetCloudsNoise(position);
        for (uint i = 1u; i < 6u; ++i, amplitude *= 0.43) {
            position = goldenRotate * 3.2 * (position - wind.xz);
            noise += GetCloudsNoise(position * (1.0 + vec2(-0.35, 0.05) * sqrt(i))) * amplitude;
        }

        noise -= saturate(localCoverage * 4.0 - 1.6);
        #ifdef CLOUDS_WEATHER
            noise -= cloudDynamicWeather.y;
        #endif
        noise = saturate(noise * 1.36 + CLOUD_PLANE0_COVERY - 1.7) * noise;

        if (noise < 1e-5) return vec4(0.0);

        float bounceEstimate = oneMinus(expf(-noise * 2.4)) * 0.7;
        bounceEstimate /= 1.0 - bounceEstimate;

        float phase = MiePhaseClouds(LdotV, vec3(-0.2, 0.5, 0.9), vec3(0.3, 0.6, 0.1));

        bool moonlit = worldSunVector.y < -0.049;

        vec3 lightColor = phase * (moonlit ? moonIlluminance : sunIlluminance) * 17.0;
        lightColor += skyIlluminance * 0.1;

        if (isLightningFlashing > 1e-2) lightColor += lightningColor * 2.5;

        #ifdef AURORA
            lightColor += vec3(0.007, 0.04, 0.049) * auroraAmount;
        #endif

        lightColor *= oneMinus(0.8 * wetness);
        noise = 1.0 - expf(-noise * 1.6 * CLOUD_PLANE0_DENSITY);

        return vec4(lightColor * bounceEstimate * noise, noise);
    }
#elif CIRRUS_CLOUDS == 2
    vec4 PlanarSample0(in float dist, in vec2 worldPos, in float LdotV) {
        worldPos /= 1.0 + distance(worldPos, cameraPosition.xz) * 5e-6;
        vec2 position = worldPos * 8e-7;

        float localCoverage = texture(noisetex, position * 0.1 - wind.xz * 2e-2).y;

        float weight = 0.5;
        float noise = texture(noisetex, position - wind.xz * 4e-2).x * weight;

        for (uint i = 1u; i < 6u; ++i) {
            weight *= 0.5;
            position *= vec2(2.0, 2.2 + sqrt(i));
            noise += texture(noisetex, position - curve(noise) * 0.3 * weight - wind.xz * 4e-2).x * weight;
        }

        noise -= saturate(localCoverage * 2.8 - 1.2);
        #ifdef CLOUDS_WEATHER
            noise -= cloudDynamicWeather.y;
        #endif
        noise = curve(saturate(noise * 2.0 + CLOUD_PLANE0_COVERY - 1.4) * noise);
        if (noise < 1e-5) return vec4(0.0);

        float bounceEstimate = oneMinus(expf(-noise * 18.0)) * 0.7;
        bounceEstimate /= 1.0 - bounceEstimate;

        float phase = MiePhaseClouds(LdotV, vec3(-0.2, 0.5, 0.9), vec3(0.3, 0.6, 0.1));

        bool moonlit = worldSunVector.y < -0.049;

        vec3 lightColor = phase * (moonlit ? moonIlluminance : sunIlluminance) * 25.0;
        lightColor += skyIlluminance * 0.1;

        if (isLightningFlashing > 1e-2) lightColor += lightningColor * 5.0;

        #ifdef AURORA
            lightColor += vec3(0.021, 0.04, 0.07) * auroraAmount;
        #endif

        lightColor *= oneMinus(0.8 * wetness);
        noise = 1.0 - expf(-noise * 4.0 * CLOUD_PLANE0_DENSITY);

        return vec4(lightColor * bounceEstimate * noise, noise);
    }
#endif

#ifdef CIRROCUMULUS_CLOUDS
    float CloudPlanarDensity(in vec2 worldPos) {
        worldPos /= 1.0 + distance(worldPos, cameraPosition.xz) * 2e-5;
        vec2 position = worldPos * 1e-4 - wind.xz;

        float baseCoverage = curve(texture(noisetex, position * 0.08).z * 0.7 + 0.1);
        baseCoverage *= max0(1.07 - texture(noisetex, position * 0.003).y * 1.4);

        vec2 curl = texture(noisetex, position * 0.05).xy * 0.04;
        curl += texture(noisetex, position * 0.1).xy * 0.02;
        position += curl;

        float noise = 0.5 * texture(noisetex, position * vec2(0.4, 0.16)).z;
        noise += texture(noisetex, position * 0.9).z - 0.24;
        noise = saturate(noise);

        #ifdef CLOUDS_WEATHER
            noise -= cloudDynamicWeather.x;
        #endif

        // заменил clamp на saturate с умножением
        noise *= saturate((baseCoverage + CLOUD_PLANE1_COVERY - 0.6) * 0.9 / 0.14) * 0.14;
        if (noise < 1e-6) return 0.0;

        position.x += noise * 0.2;

        noise += 0.02 * texture(noisetex, position * 3.0).z;
        noise += 0.01 * texture(noisetex, position * 5.0 + curl).z - 0.05;

        return cube(saturate(noise * 4.0));
    }

    vec4 PlanarSample1(in float dist, in vec2 worldPos, in float LdotV, in float lightNoise, in vec4 phases, in vec3 worldDir) {
        float density = CloudPlanarDensity(worldPos);
        if (density < 1e-5) return vec4(0.0);

        float rayLength = 60.0;
        vec2 rayPos = worldPos;
        vec3 rayStep = vec3(worldLightVector.xz, 1.0) * rayLength;

        float opticalDepth = 0.0;

        for (uint i = 0u; i < 3u; ++i, rayPos += rayStep.xy) {
            rayStep *= 2.0;

            float d = CloudPlanarDensity(rayPos + rayStep.xy * lightNoise);
            if (d < 1e-4) continue;

            opticalDepth += d * rayStep.z;
        }
    
        opticalDepth *= CLOUD_PLANE1_DENSITY;
        float bounceEstimate = oneMinus(expf(-density * 6e2)) * 0.75;
        bounceEstimate /= 1.0 - bounceEstimate;

        float sunlightEnergy =  expf(-opticalDepth * 1.0) * phases.x;
        sunlightEnergy +=      expf(-opticalDepth * 0.4) * phases.y;
        sunlightEnergy +=      expf(-opticalDepth * 0.15) * phases.z;
        sunlightEnergy +=      expf(-opticalDepth * 0.05) * phases.w;

        opticalDepth = 0.0;

        rayLength = 1e2;
        rayStep = vec3(worldDir.xz, 1.0) * rayLength;

        for (uint i = 0u; i < 2u; ++i, worldPos += rayStep.xy) {
            rayStep *= 2.0;

            float d = CloudPlanarDensity(worldPos + rayStep.xy * lightNoise);
            if (d < 1e-4) continue;

            opticalDepth += d * rayStep.z;
        }

        opticalDepth *= CLOUD_PLANE1_DENSITY;
        float skylightEnergy = expf(-opticalDepth * 0.15);
        skylightEnergy += 0.2 * expf(-opticalDepth * 0.03);
        vec3 scatteringSky = skylightEnergy * 0.3 * skyIlluminance;

        if (isLightningFlashing > 1e-2) scatteringSky += sqr(skylightEnergy) * 1.4 * lightningColor;

        #ifdef AURORA
            scatteringSky += skylightEnergy * vec3(0.021, 0.04, 0.07) * auroraAmount;
        #endif

        density = oneMinus(expf(-density * 2e-2 * CLOUD_PLANE1_DENSITY * dist));
        bool moonlit = worldSunVector.y < -0.045;

        vec3 scattering = sunlightEnergy * 1.2e2 * (moonlit ? moonIlluminance : sunIlluminance);
        scattering += scatteringSky;
        scattering *= oneMinus(0.7 * wetness);

        return vec4(scattering * bounceEstimate * density, density);
    }
#endif
