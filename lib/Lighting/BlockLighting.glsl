#define EMISSION_MODE 2 // [0 1 2]
#define EMISSION_BRIGHTNESS 1.0 // [0.0 0.1 0.2 0.3 0.5 0.7 1.0 1.5 2.0 3.0 5.0 7.0 10.0 15.0 20.0 30.0 50.0 70.0 100.0]

#define EMISSIVE_ORES

float lightSourceMask = 1.0;
float albedoLuminance = length(albedo);

GetBlocklightFalloff(mcLightmap.r);

#if EMISSION_MODE < 2
    vec3 EmissionColor = vec3(0.0);

    switch (materialID) {
        // Amethyst (no emission)
        case 27:
            break;
    }

    sceneData += EmissionColor * TORCHLIGHT_BRIGHTNESS;
#endif

#if EMISSION_MODE == 2
    vec3 EmissionColor = vec3(0.0);

    switch (materialID) {
        // Total glowing
        case 20:
            EmissionColor += albedoLuminance;
            lightSourceMask = 0.1;
            break;
        // Torch like (increased brightness and bloom)
        case 21:
            #ifdef IS_END
                // Purple glow for torches in End
                vec3 endLightColor = vec3(0.6, 0.2, 1.0) * (1.0 + 0.3 * sin(frameTimeCounter * 10.0));
                EmissionColor += 6.0 * endLightColor * float(albedoRaw.r > 0.8 || albedoRaw.r > albedoRaw.g * 1.4);
                lightSourceMask = 0.05;
            #else
                // Regular orange outside End
                EmissionColor += 6.0 * blocklightColor * float(albedoRaw.r > 0.8 || albedoRaw.r > albedoRaw.g * 1.4);
                lightSourceMask = 0.05;
            #endif
            break;
        // Fire (with purple in End or on Enderman)
        case 22: case 15:
            #ifdef IS_END
                // Purple fire in End
                vec3 endFireColor = vec3(0.6, 0.2, 1.0) * (1.0 + 0.3 * sin(frameTimeCounter * 10.0));
                EmissionColor += 6.0 * endFireColor * cube(albedoLuminance);
                lightSourceMask = 0.1;
            #else
                // Regular orange fire outside End
                EmissionColor += 6.0 * blocklightColor * cube(albedoLuminance);
                lightSourceMask = 0.1;
            #endif
            // Additional for fire on Enderman
            #ifdef IS_ENTITY
                if (gl_EntityID == 37) { // Enderman ID = 37
                    vec3 enderFireColor = vec3(0.4, 0.1, 0.9) * (1.0 + 0.5 * sin(frameTimeCounter * 8.0));
                    EmissionColor = mix(EmissionColor, enderFireColor * 7.0 * cube(albedoLuminance), 0.8);
                    lightSourceMask = 0.05;
                }
            #endif
            break;
        // Glowstone like (lamps, increased brightness and bloom)
        case 23:
            EmissionColor += 4.0 * blocklightColor * cube(albedoLuminance);
            lightSourceMask = 0.05;
            break;
        // Sea lantern like
        case 24:
            EmissionColor += 2.0 * cube(albedoLuminance);
            lightSourceMask = 0.0;
            break;
        // Redstone
        case 25:
            if (fract(worldPos.y + cameraPosition.y) > 0.18) EmissionColor += step(0.65, albedoRaw.r);
            else EmissionColor += step(1.25, albedo.r / (albedo.g + albedo.b)) * step(0.5, albedoRaw.r);
            EmissionColor *= vec3(2.1, 0.9, 0.9);
            break;
        // Soul fire (enhanced bloom and bluish tint)
        case 26:
            vec3 soulLightColor = vec3(0.2, 0.6, 1.0) * (1.0 + 0.3 * sin(frameTimeCounter * 8.0)); // Bluish tint with pulse
            EmissionColor += 8.0 * soulLightColor * float(albedoRaw.b > 0.5 || albedoRaw.g > albedoRaw.r * 1.4);
            lightSourceMask = 0.03;
            break;
        // Amethyst (no emission)
        case 27:
            break;
        // Glowberry
        case 28:
            EmissionColor += saturate(dot(saturate(albedo - 0.1), vec3(1.0, -0.6, -0.99))) * vec3(28.0, 25.0, 21.0);
            lightSourceMask = 0.4;
            break;
        // Rails
        case 29:
            EmissionColor += vec3(2.1, 0.9, 0.9) * albedoLuminance * step(albedoRaw.g * 2.0 + albedoRaw.b, albedoRaw.r);
            break;
        // Beacon core
        case 30:
            vec3 midBlockPos = abs(fract(worldPos + cameraPosition) - 0.5);
            if (maxOf(midBlockPos) < 0.4 && albedo.b > 0.5) EmissionColor += 6.0 * albedoLuminance;
            lightSourceMask = 0.2;
            break;
        // Sculk
        case 31:
            if (albedoRaw.b > 0.6) {
                float pulse = 1.0 + 0.5 * sin(frameTimeCounter * 12.0);
                vec3 sensorGlow = vec3(0.3, 0.6, 1.0) * pulse;
                EmissionColor += 5.0 * sensorGlow * pow(albedoLuminance, 2.0);
                lightSourceMask = 0.2;
            }
            break;
        // Glow lichen
        case 32:
            if (albedoRaw.r > albedoRaw.b * 1.2) EmissionColor += 3.0;
            else EmissionColor += albedoLuminance * 0.1;
            break;
        // Partial glowing
        case 33:
            EmissionColor += 30.0 * albedoLuminance * cube(saturate(albedo - 0.5));
            lightSourceMask = 0.5;
            break;
        // Middle glowing
        case 34:
            vec2 midBlockPosXZ = abs(fract(worldPos.xz + cameraPosition.xz) - 0.5);
            EmissionColor += step(maxOf(midBlockPosXZ), 0.063) * albedoLuminance;
            break;
        // Nether Portal (with glowing outline)
        case 36:
            vec3 blockPos = fract(worldPos + cameraPosition);
            float edgeDist = max(max(abs(blockPos.x - 0.5), abs(blockPos.y - 0.5)), abs(blockPos.z - 0.5));
            float outlineStrength = smoothstep(0.45, 0.5, edgeDist);
            EmissionColor += albedoLuminance + 2.0 * outlineStrength * vec3(0.6, 0.2, 1.0);
            lightSourceMask = 0.05;
            break;
        // Lapis Lazuli
        case 51:
            float isLapis = saturate((max(max(dot(albedoRaw, vec3(2.0, -1.0, -1.0)), dot(albedoRaw, vec3(-1.0, 2.0, -1.0))), dot(albedoRaw, vec3(-1.0, -1.0, 2.0))) - 0.1) * rcp(0.3));
            EmissionColor += LinearToSRGB(isLapis * (pow5(max0(albedoRaw - vec3(0.1))))) * 2.0;
            break;
        // Emerald
        case 58:
            float isEmerald = saturate(dot(albedoRaw, vec3(-20.0, 30.0, 10.0)));
            EmissionColor += LinearToSRGB(isEmerald * (cube(max0(albedoRaw - vec3(0.1))))) * 2.0;
            break;
            
            // Copper lanterns and torches with soul-like glow
case 11001:
    vec3 copperLightColor = vec3(0.2, 0.6, 1.0) * (1.0 + 0.3 * sin(frameTimeCounter * 8.0)); // Bluish tint with pulse
    EmissionColor += 8.0 * copperLightColor * float(albedoRaw.b > 0.5 || albedoRaw.g > albedoRaw.r * 1.4);
    lightSourceMask = 0.03; // Enhanced bloom similar to soul fire
    break;
        // Chorus Flower (yellow pixels in final stage)
        case 10033:
            // Filter for yellow pixels (high red and green, low blue)
            float isYellowChorus = saturate(dot(albedoRaw, vec3(1.0, 1.0, -2.0))) * step(albedoRaw.r, albedoRaw.g * 1.2) * step(albedoRaw.b, 0.3);
            vec3 yellowGlowColor = vec3(1.0, 0.9, 0.2) * (1.0 + 0.3 * sin(frameTimeCounter * 6.0)); // Yellow pulsating glow
            EmissionColor += 5.0 * yellowGlowColor * cube(albedoLuminance) * isYellowChorus;
            lightSourceMask = 0.005; // Further enhanced bloom for yellow glow
            break;
    }

    sceneData += EmissionColor * TORCHLIGHT_BRIGHTNESS;
#endif

#if EMISSION_MODE > 0
    sceneData += material.emissiveness * 1.5 * EMISSION_BRIGHTNESS;
#endif

#ifdef EMISSIVE_ORES
    if (EMISSION_MODE != 2 && materialID == 51) {
        float isOre = saturate((max(max(dot(albedoRaw, vec3(2.0, -1.0, -1.0)), dot(albedoRaw, vec3(-1.0, 2.0, -1.0))), dot(albedoRaw, vec3(-1.0, -1.0, 2.0))) - 0.1) * rcp(0.3));
        sceneData += LinearToSRGB(isOre * (pow5(max0(albedoRaw - vec3(0.1))))) * 2.0;
    }
    if (EMISSION_MODE != 2 && materialID == 58) {
        float isNetherOre = saturate(dot(albedoRaw, vec3(-20.0, 30.0, 10.0)));
        sceneData += LinearToSRGB(isNetherOre * (cube(max0(albedoRaw - vec3(0.1))))) * 2.0;
    }
#endif

#if defined IS_NETHER
    if (mcLightmap.r > 1e-5) sceneData += mcLightmap.r * (ao * oneMinus(mcLightmap.r) + mcLightmap.r) * 20.0 * blocklightColor * TORCHLIGHT_BRIGHTNESS * lightSourceMask * metalMask;
#else
    if (mcLightmap.r > 1e-5) sceneData += mcLightmap.r * (ao * oneMinus(mcLightmap.r) + mcLightmap.r) * 2.0 * blocklightColor * TORCHLIGHT_BRIGHTNESS * lightSourceMask;
#endif

#ifdef HELD_TORCHLIGHT
    if (heldBlockLightValue + heldBlockLightValue2 > 1e-3) {
        float falloff = rcp(dotSelf(worldPos) + 1.0);
        falloff *= fma(NdotV, 0.8, 0.2);

        #if defined IS_NETHER
            sceneData += falloff * (ao * oneMinus(falloff) + falloff) * 2.0 * max(heldBlockLightValue, heldBlockLightValue2) * HELDLIGHT_BRIGHTNESS * blocklightColor * metalMask;
        #else
            sceneData += falloff * (ao * oneMinus(falloff) + falloff) * 0.2 * max(heldBlockLightValue, heldBlockLightValue2) * HELDLIGHT_BRIGHTNESS * blocklightColor;
        #endif
    }
#endif

sceneData += float(materialID == 12) * 12.0 + float(materialID == 36) * 2.0 + float(materialID == 19) * albedoLuminance * 2e2;