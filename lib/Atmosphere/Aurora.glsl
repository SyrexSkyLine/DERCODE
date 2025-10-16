// Auroras by _DureXXX_ 2025 (discord: s_y_r_3_x)
// License FREE GO COPY BRO
// Contact the author for found bugs etc

/*
--------------------------------------------------------------------------------
REMADED AURORA BY _DureXXX_ 
--------------------------------------------------------------------------------
*/
#include "/Settings.glsl"

// Uniform для рандомизации узора
uniform float patternSeed;        // Семя для рандомизации узора (например, 0.0 - 1.0)
uniform float frameTimeCounter;   // Время кадра для анимации (стандартный uniform в Minecraft шейдерах)

// ============================
// Цвета (через Settings.glsl)
// ============================
#define AURORA_COLOR1 vec3(AURORA_R1, AURORA_G1, AURORA_B1) / 255.0
#define AURORA_COLOR2 vec3(AURORA_R2, AURORA_G2, AURORA_B2) / 255.0
#define AURORA_COLOR3 vec3(AURORA_R3, AURORA_G3, AURORA_B3) / 255.0

// Сила авроры
#define AURORA_STRENGTH 0.7

// Функция для преобразования HSV в RGB (оставляем, если нужно)
vec3 hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

// ============================
// Noise / math helpers
// ============================
mat2 mm2(in float a) { 
    float c = cos(a), s = sin(a); 
    return mat2(c, s, -s, c); 
}

mat2 m2 = mat2(0.95534, 0.29552, -0.29552, 0.95534);

float tri(in float x) { 
    return clamp(abs(fract(x) - 0.5), 0.01, 0.49); 
}

vec2 tri2(in vec2 p) { 
    return vec2(tri(p.x) + tri(p.y), tri(p.y + tri(p.x))); 
}

float triNoise2d(in vec2 p, in float spd) {
    p *= mm2(patternSeed * 6.283185); // random rotation

    float z = 1.8;
    float z2 = 2.5;
    float rz = 0.0;
    p *= mm2(p.x * 0.06);
    vec2 bp = p;

    for (uint i = 0u; i < 5u; ++i) {
        vec2 dg = tri2(bp * 1.85) * 0.75;
        dg *= mm2(frameTimeCounter * spd);
        p -= dg / z2;

        bp *= 1.3;
        z2 *= 0.45;
        z *= 0.42;
        p *= 1.21 + (rz - 1.0) * 0.02;    
        p *= -m2;
        rz += tri(p.x + tri(p.y)) * z;
    }

    return clamp(pow(rz * 29.0, -1.3), 0.0, 0.55);
}

float hash21(in vec2 n) { 
    return fract(sin(dot(n, vec2(12.9898, 4.1414))) * 43758.5453); 
}

// ============================
// Aurora main
// ============================
vec4 aurora(in vec3 ro, in vec3 rd) {
    vec4 col = vec4(0.0);
    vec4 avgCol = vec4(0.0);
    
    const float maxI = 40.0;

    for (float i = 0.0; i < maxI; i++) {
        float of = 0.006 * hash21(gl_FragCoord.xy) * smoothstep(0.0, 15.0, i);
        float pt = ((0.8 + pow(i, 1.4) * 0.002) - ro.y) / (rd.y * 2.0 + 0.4);
        pt -= of;
        vec3 bpos = ro + pt * rd;
        vec2 p = bpos.zx;
        float rzt = triNoise2d(p, 0.1883);
        vec4 col2 = vec4(0.0, 0.0, 0.0, rzt);

        // Нормализованная высота от 0 (низ) до 1 (верх)
        float normI = i / maxI; 
        
        // Смещение для анимации
        float time = frameTimeCounter * 0.15;
        float mixOffset = (sin(time + normI * 2.0) * 0.5 + 0.5) * 0.2;
        
        // Переход между цветами
        vec3 auroraColor;
        if (normI < 0.33) {
            auroraColor = mix(AURORA_COLOR1, AURORA_COLOR2, normI / 0.33 + mixOffset);
        } else if (normI < 0.66) {
            auroraColor = mix(AURORA_COLOR2, AURORA_COLOR3, (normI - 0.33) / 0.33 + mixOffset);
        } else {
            auroraColor = mix(AURORA_COLOR3, AURORA_COLOR1, (normI - 0.66) / 0.34 + mixOffset);
        }
        
        auroraColor = clamp(auroraColor, 0.0, 1.0);
        
        col2.rgb = auroraColor * rzt;
        
        avgCol = mix(avgCol, col2, 0.5);
        col += avgCol * exp2(-i * 0.065 - 2.5) * smoothstep(0.0, 5.0, i);  
    }

    col *= clamp(rd.y * 15.0 + 0.4, 0.0, 1.0);

    return col * 1.8;
}

// ============================
// NightAurora wrapper
// ============================
vec3 NightAurora(in vec3 worldDir) {	
    if (worldDir.y < 0.0 && eyeAltitude < 2e4) return vec3(0.0);

    vec3 planeOrigin = vec3(0.0, planetRadius + eyeAltitude, 0.0);
    vec2 intersection = RaySphereIntersection(planeOrigin, worldDir, planetRadius + 2e4);
    float raylength = intersection.y;

    if (raylength <= 0.0 || raylength > 5e5) return vec3(0.0);
    vec3 rd = worldDir * raylength;
    float fade = exp(-raylength * 1e-5);

    vec4 aur = smoothstep(0.0, 2.5, aurora(vec3(0.0, 0.0, -6.7), rd * 1e-5));
    return aur.rgb * fade * AURORA_STRENGTH;
}
