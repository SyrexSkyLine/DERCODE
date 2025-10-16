#version 450 compatibility

out vec4 fragColor;

/* DRAWBUFFERS:0 */

uniform sampler2D colortex0;   // финальный буфер сцены
uniform sampler2D noisetex;    // шум для генерации капель
uniform float frameTimeCounter;

in vec2 texcoord;

// хэш для рандома
float hash(vec2 p) {
    return fract(sin(dot(p, vec2(41.3, 289.1))) * 43758.5453);
}

// форма капли (округлая линза)
float dropShape(vec2 uv) {
    float d = length(uv - 0.5);
    return smoothstep(0.25, 0.2, d); // круглая маска
}

void main() {
    vec2 uv = texcoord;
    vec3 sceneColor = texture(colortex0, uv).rgb;

    // шум для распределения капель
    float n = texture(noisetex, uv * 4.0).r;

    // маска капли (появляется при определённом пороге шума)
    float dropMask = step(0.965, n);

    if (dropMask > 0.0) {
        // локальные координаты капли
        vec2 local = fract(uv * 15.0);

        // форма и движение вниз
        float shape = dropShape(local);
        float t = fract(frameTimeCounter * 0.05 + n);
        local.y = fract(local.y + t); // капля стекает вниз

        // интенсивность маски
        float mask = shape * smoothstep(0.0, 0.2, local.y);

        if (mask > 0.01) {
            // оффсет для "линзы" (рефракция)
            vec2 offset = (local - 0.5) * 0.05 * mask;
            vec3 refracted = texture(colortex0, uv + offset).rgb;

            // финальный микс (капля искажает фон)
            sceneColor = mix(sceneColor, refracted, mask * 0.8);
        }
    }

    fragColor = vec4(sceneColor, 1.0);
}
