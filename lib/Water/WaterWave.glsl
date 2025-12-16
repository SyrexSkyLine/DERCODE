

uniform sampler2D noisetex2; 


float textureSmooth(in vec2 coord) {
    coord += 0.5f;
    vec2 whole = floor(coord);
    vec2 part  = curve(coord - whole);
    coord = whole + part - 0.5f;
    return texture(noisetex, coord * rcp(256.0)).x;
}

float textureSmooth2(in vec2 coord) {
    coord += 0.5f;
    vec2 whole = floor(coord);
    vec2 part  = curve(coord - whole);
    coord = whole + part - 0.5f;
    return texture(noisetex2, coord * rcp(256.0)).x;
}

float WaterHeight(in vec2 p) {
    #if WATER_STYLE == 0 // Classic Style
        float wavesTime = frameTimeCounter * 1.2 * WATER_WAVE_SPEED;
        p.y *= 0.8;
        float wave = 0.0;
        wave += textureSmooth((p + vec2(0.0, p.x - wavesTime)) * 0.8);
        wave += textureSmooth((p - vec2(-wavesTime, p.x)) * 1.6) * 0.5;
        wave += textureSmooth((p + vec2(wavesTime * 0.6, p.x - wavesTime)) * 2.4) * 0.2;
        wave += textureSmooth((p - vec2(wavesTime * 0.6, p.x - wavesTime)) * 3.6) * 0.1;
        #if defined DISTANT_HORIZONS
            return wave / (0.8 + dot(abs(dFdx(p) + dFdy(p)), vec2(2e2 / dhFarPlane)));
        #else
            return wave / (0.8 + dot(abs(dFdx(p) + dFdy(p)), vec2(80.0 / far)));
        #endif

    #elif WATER_STYLE == 1 // BSL Style
        float wavesTime = frameTimeCounter * 1.0 * WATER_WAVE_SPEED;
        p.y *= 0.75;
        float wave = 0.0;
        wave += textureSmooth((p + vec2(wavesTime * 0.5, p.x * 0.3)) * 0.6) * 0.8;
        wave += textureSmooth((p - vec2(p.y * 0.2, wavesTime * 0.7)) * 1.2) * 0.4;
        wave += textureSmooth((p + vec2(wavesTime * 0.8, p.x * 0.5 - wavesTime * 0.4)) * 2.0) * 0.25;
        wave += textureSmooth((p - vec2(wavesTime * 1.2, p.y * 0.3)) * 3.0) * 0.15;
        const mat2 rotation = mat2(cos(1.57), -sin(1.57), sin(1.57), cos(1.57));
        p = rotation * p;
        wave += textureSmooth((p + vec2(wavesTime * 0.3, p.x * 0.2)) * 1.5) * 0.2;
        wave /= (0.8 + 0.4 + 0.25 + 0.15 + 0.2);
        #if defined DISTANT_HORIZONS
            return wave / (1.0 + dot(abs(dFdx(p) + dFdy(p)), vec2(2e2 / dhFarPlane)));
        #else
            return wave / (1.0 + dot(abs(dFdx(p) + dFdy(p)), vec2(80.0 / far)));
        #endif

    #elif WATER_STYLE == 2 // ПЛОСКИЙ СТИЛЬ 
        float wavesTime = frameTimeCounter * 0.9 * WATER_WAVE_SPEED;
        p.y *= 0.95;

        float wave = 0.0;
       
        wave += textureSmooth2((p + vec2(wavesTime * 0.6, p.x * 0.15)) * 0.7) * 0.65;
        wave += textureSmooth2((p - vec2(wavesTime * 0.4, p.y * 0.25)) * 1.4) * 0.35;
        
        
        wave += textureSmooth((p + vec2(wavesTime * 1.2, 0.0)) * 2.8) * 0.15;
        
        wave /= (0.65 + 0.35 + 0.15);
        
        #if defined DISTANT_HORIZONS
            return wave / (1.0 + dot(abs(dFdx(p) + dFdy(p)), vec2(2e2 / dhFarPlane)));
        #else
            return wave / (1.0 + dot(abs(dFdx(p) + dFdy(p)), vec2(80.0 / far)));
        #endif

    #elif WATER_STYLE == 3 // Classic + Texture Style
        float wavesTime = frameTimeCounter * 1.2 * WATER_WAVE_SPEED;
        p.y *= 0.8;
        float wave = 0.0;
        wave += textureSmooth((p + vec2(0.0, p.x - wavesTime)) * 0.8);
        wave += textureSmooth((p - vec2(-wavesTime, p.x)) * 1.6) * 0.5;
        wave += textureSmooth((p + vec2(wavesTime * 0.6, p.x - wavesTime)) * 2.4) * 0.2;
        wave += textureSmooth((p - vec2(wavesTime * 0.6, p.x - wavesTime)) * 3.6) * 0.1;
        wave += textureSmooth2((p + vec2(wavesTime * 0.5, p.y * 0.2)) * 1.2) * 0.15;
        wave /= (1.0 + 0.5 + 0.2 + 0.1 + 0.15);
        #if defined DISTANT_HORIZONS
            return wave / (0.8 + dot(abs(dFdx(p) + dFdy(p)), vec2(2e2 / dhFarPlane)));
        #else
            return wave / (0.8 + dot(abs(dFdx(p) + dFdy(p)), vec2(80.0 / far)));
        #endif

    #elif WATER_STYLE == 4 // BLISS ЗАЕБАЛО
        float time = frameTimeCounter * 1.1 * WATER_WAVE_SPEED;
        p *= 0.85;

        float wave = 0.0;
        // Bliss core waves
        wave += textureSmooth((p + vec2(0.0, p.x - time * 1.1)) * 0.85) * 1.0;
        wave += textureSmooth((p + vec2(time * 0.9, p.y * 0.7)) * 1.7) * 0.6;
        wave += textureSmooth((p - vec2(time * 0.7, p.x * 0.4)) * 2.5) * 0.35;
        wave += textureSmooth((p + vec2(p.y * 0.3, time * 1.3)) * 3.8) * 0.2;
        
        // Bliss rotated layer
        p *= mat2(0.866, -0.5, 0.5, 0.866); // 30° rotation
        wave += textureSmooth((p + vec2(time * 0.5, p.x * 0.6)) * 1.9) * 0.25;
        
        wave /= 2.4;

        #if defined DISTANT_HORIZONS
            return wave / (1.0 + dot(abs(dFdx(p) + dFdy(p)), vec2(2e2 / dhFarPlane)));
        #else
            return wave / (1.0 + dot(abs(dFdx(p) + dFdy(p)), vec2(80.0 / far)));
        #endif
    #endif
}

vec3 GetWavesNormal(in vec2 position) {
    #if WATER_STYLE == 0 || WATER_STYLE == 3 // Classic styles 
        float wavesCenter = WaterHeight(position);
        float wavesLeft   = WaterHeight(position + vec2(0.04, 0.0));
        float wavesUp     = WaterHeight(position + vec2(0.0, 0.04));
        vec2 wavesNormal = vec2(wavesCenter - wavesLeft, wavesCenter - wavesUp);
        return normalize(vec3(wavesNormal * WATER_WAVE_HEIGHT, 0.5));

    #elif WATER_STYLE == 1 // BSL Style 
        const float delta = 0.02;
        float wavesCenter = WaterHeight(position);
        float wavesLeft   = WaterHeight(position + vec2(delta, 0.0));
        float wavesUp     = WaterHeight(position + vec2(0.0, delta));
        vec2 wavesNormal = vec2(wavesLeft - wavesCenter, wavesUp - wavesCenter) / delta;
        return normalize(vec3(wavesNormal * WATER_WAVE_HEIGHT * 0.5, 1.0));

    #elif WATER_STYLE == 2 // Плоский
        const float delta = 0.035;
        float wavesCenter = WaterHeight(position);
        float wavesLeft   = WaterHeight(position + vec2(delta, 0.0));
        float wavesUp     = WaterHeight(position + vec2(0.0, delta));
        vec2 wavesNormal = vec2(wavesLeft - wavesCenter, wavesUp - wavesCenter) / delta;
        return normalize(vec3(wavesNormal * WATER_WAVE_HEIGHT * 0.25, 1.0)); 

    #elif WATER_STYLE == 4 // Bliss 
        const float eps = 0.025;
        float h = WaterHeight(position);
        float hx = WaterHeight(position + vec2(eps, 0.0));
        float hy = WaterHeight(position + vec2(0.0, eps));
        vec2 n = vec2(h - hx, h - hy) * WATER_WAVE_HEIGHT * 1.8;
        return normalize(vec3(n, 0.45));
    #endif
}