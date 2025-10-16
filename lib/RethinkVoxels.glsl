#ifndef RETHINK_VOXELS_GLSL
#define RETHINK_VOXELS_GLSL

struct RethinkSample {
    vec3 color;
    float occ;
};

// Хэш-функция для генерации псевдослучайных значений
vec3 rv_hash33(vec3 p) {
    p = fract(p * 0.3183099 + vec3(0.1, 0.2, 0.3));
    p *= 17.0;
    return fract(p.x * p.y * p.z * (p.x + p.y + p.z));
}

// Простая случайная функция
float rv_rand(vec2 co) {
    return fract(sin(dot(co.xy, vec2(12.9898, 78.233))) * 43758.5453);
}

// Сэмплирование направления по полусфере для глобального освещения
vec3 rv_sampleHemisphere(vec3 normal, vec2 rand) {
    float phi = 2.0 * 3.14159265 * rand.x;
    float cosTheta = pow(1.0 - rand.y, 1.0 / 3.0);
    float sinTheta = sqrt(1.0 - cosTheta * cosTheta);

    vec3 tangent = normalize(abs(normal.y) < 0.999 ? cross(normal, vec3(0,1,0)) : cross(normal, vec3(1,0,0)));
    vec3 bitangent = cross(normal, tangent);
    return normalize(tangent * (sinTheta * cos(phi)) + bitangent * (sinTheta * sin(phi)) + normal * cosTheta);
}

// Screen-space voxel-style GI sampling
void rv_ssVoxelTrace(vec3 originVS, vec3 dirVS, float radius, vec2 uv, out RethinkSample sampleOut) {
    sampleOut.color = vec3(0.0);
    sampleOut.occ = 0.0;

    const int STEPS = 6;
    float stepSize = radius / float(STEPS);
    vec3 ray = originVS;

    for (int i = 0; i < STEPS; i++) {
        ray += dirVS * stepSize;

        vec4 projPos = gbufferProjection * vec4(ray, 1.0);
        projPos.xyz /= projPos.w;
        vec2 sampleUV = projPos.xy * 0.5 + 0.5;

        if (sampleUV.x < 0.0 || sampleUV.x > 1.0 || sampleUV.y < 0.0 || sampleUV.y > 1.0)
            continue;

        vec4 col = texture2D(colortex0, sampleUV);
        vec4 albedo = texture2D(colortex1, sampleUV);

        float lum = dot(albedo.rgb, vec3(0.299, 0.587, 0.114));
        if (lum > 0.15 && col.a > 0.3) {
            vec3 lightColor = albedo.rgb * 1.3 + vec3(0.02, 0.02, 0.03);
            sampleOut.color += lightColor * (1.0 - float(i) / float(STEPS));
            sampleOut.occ += 1.0;
        }
    }

    if (sampleOut.occ > 0.0)
        sampleOut.color /= sampleOut.occ;
}

// Главная функция глобального освещения через воксели
vec3 rv_rethinkVoxelGI(vec3 posVS, vec3 normalVS, vec2 uv) {
    vec3 result = vec3(0.0);
    const int SAMPLES = 8;
    float radius = 1.2;

    for (int i = 0; i < SAMPLES; i++) {
        vec2 rand = rv_hash33(vec3(uv * float(i), float(i))).xy;
        vec3 dir = rv_sampleHemisphere(normalVS, rand);
        RethinkSample giSample;
        rv_ssVoxelTrace(posVS, dir, radius, uv, giSample);
        result += giSample.color;
    }

    result /= float(SAMPLES);
    result = pow(result, vec3(0.9)); // Мягкий тон для Roblox Future Light
    return result;
}

#endif
