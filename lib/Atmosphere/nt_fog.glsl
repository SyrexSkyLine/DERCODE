// ============================================================================
// Vol_Fog.glsl
// Облачный объёмный туман для Незера
// Два режима: SIMPLE_FOG (серый) и BIOME_FOG (с раскраской биомов)
// Автор: ChatGPT (2025)
// ============================================================================

// ВЫБОР РЕЖИМА ===============================================================
#define BIOME_FOG
// #define SIMPLE_FOG

// ============================================================================
// ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ
// ============================================================================

#ifndef saturate
#define saturate(x) clamp(x, 0.0, 1.0)
#endif

// Зависит от твоего движка шейдера (обычно в отдельном файле noise.glsl)
float Get3DNoiseSmooth(vec3 p);

// Эти функции-заглушки должны возвращать true, если точка принадлежит биому.
// Их обычно реализуют через сэмплинг карты биомов.
bool IsWarpedForest(vec3 pos);
bool IsSoulSandValley(vec3 pos);
bool IsBasaltDeltas(vec3 pos);
bool IsNetherWastes(vec3 pos);
bool IsCrimsonForest(vec3 pos);

// ============================================================================
// РАСЧЁТ ПЛОТНОСТИ ТУМАНА
// ============================================================================
float CalculateNetherFogDensity(in vec3 rayPosition, in vec3 netherFogWind) {
    if (rayPosition.y < 0.0 || rayPosition.y > 128.0) return 0.0;

    // Чем ниже, тем плотнее
    float heightFactor = exp2(-abs(rayPosition.y - 40.0) * 0.01);

    // Основной шум
    vec3 fogPos = rayPosition * 0.015 + netherFogWind * 0.8;
    float noise = 0.0;
    float weight = 0.6;
    for (int i = 0; i < 4; i++) {
        noise += weight * Get3DNoiseSmooth(fogPos);
        fogPos = fogPos * 2.2 + netherFogWind * 0.4;
        weight *= 0.5;
    }
    float baseFog = saturate(noise * 1.6 - 0.7);

    // Мини-облачки
    vec3 miniPos = rayPosition * 0.05 + netherFogWind * 0.3;
    float miniNoise = Get3DNoiseSmooth(miniPos) * 0.6 + Get3DNoiseSmooth(miniPos * 2.0) * 0.4;
    float miniClouds = saturate(miniNoise - 0.55) * 1.8;

    // Крупные облачные пласты
    vec3 puffPos = rayPosition * 0.01 + netherFogWind * 0.2;
    float puffNoise = Get3DNoiseSmooth(puffPos) * 0.7 + Get3DNoiseSmooth(puffPos * 3.0) * 0.3;
    float bigPuffs = saturate(puffNoise - 0.6) * 2.5;

    // Итоговая плотность
    float density = baseFog * 0.7 + miniClouds * 0.6 + bigPuffs * 1.2;
    density *= heightFactor * 0.8;

    return saturate(density);
}

// ============================================================================
// РАСЧЁТ ЦВЕТА ТУМАНА (ТОЛЬКО ДЛЯ BIOME_FOG)
// ============================================================================
#ifdef BIOME_FOG
vec3 CalculateNetherFogColor(in vec3 rayPosition, in vec3 noiseWind) {
    vec3 biomeColor = vec3(1.0, 0.3, 0.1); // Crimson по умолчанию

    if (IsWarpedForest(rayPosition)) {
        biomeColor = vec3(0.2, 0.9, 0.6);   // Warped Forest
    } else if (IsCrimsonForest(rayPosition)) {
        biomeColor = vec3(1.0, 0.3, 0.2);   // Crimson Forest
    } else if (IsSoulSandValley(rayPosition)) {
        biomeColor = vec3(0.4, 0.8, 1.0);   // Soul Sand Valley
    } else if (IsBasaltDeltas(rayPosition)) {
        biomeColor = vec3(0.3, 0.3, 0.3);   // Basalt Deltas
    } else if (IsNetherWastes(rayPosition)) {
        biomeColor = vec3(1.0, 0.5, 0.2);   // Nether Wastes
    }

    // Шумовые переливы цвета
    vec3 colorPos = rayPosition * 0.02 + noiseWind * 0.5;
    float colorNoise = Get3DNoiseSmooth(colorPos);
    float tintFactor = saturate(colorNoise * 1.2);

    return mix(biomeColor * 0.8, biomeColor * 1.2, tintFactor);
}
#endif

// ============================================================================
// ГЛАВНАЯ ФУНКЦИЯ
// ============================================================================
vec3 ApplyNetherFog(in vec3 rayPos, in vec3 rayDir, in vec3 baseColor, in vec3 netherFogWind) {
    float fogDensity = CalculateNetherFogDensity(rayPos, netherFogWind);

#ifdef SIMPLE_FOG
    vec3 fogColor = vec3(0.6, 0.6, 0.6); // серый
#endif

#ifdef BIOME_FOG
    vec3 fogColor = CalculateNetherFogColor(rayPos, netherFogWind);
#endif

    // Простейшее наложение fog
    return mix(baseColor, fogColor, fogDensity);
}
