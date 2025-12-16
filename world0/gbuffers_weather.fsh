#version 450 compatibility

out vec4 fragColor;

/* DRAWBUFFERS:0 */

uniform sampler2D colortex0;
uniform sampler2D noisetex;
uniform float frameTimeCounter;

in vec2 texcoord;

// форма капли
float dropShape(vec2 uv) {
    float d = length(uv - 0.5);
    return smoothstep(0.17, 0.13, d);
}

// экрановое отражение
vec3 sampleReflection(vec2 uv, vec2 center, float strength) {
    vec2 dir = uv - center;
    vec2 reflectedUV = center - dir * strength;
    return texture(colortex0, reflectedUV).rgb;
}

void main() {
    vec2 uv = texcoord;
    vec3 sceneColor = texture(colortex0, uv).rgb;

    float n = texture(noisetex, uv * 6.0).r; 
    float dropMask = step(0.965, n);

    if (dropMask == 0.0) {
        fragColor = vec4(sceneColor, 1.0);
        return;
    }


    vec2 local = fract(uv * 32.0);

    float shape = dropShape(local);

    float t = fract(frameTimeCounter * 0.05 + n);
    local.y = fract(local.y + t);

    float mask = shape * smoothstep(0.0, 0.2, local.y);
    if (mask < 0.01) {
        fragColor = vec4(sceneColor, 1.0);
        return;
    }

    // рефракция
    vec2 refOffset = (local - 0.5) * 0.03 * mask; 
    vec3 refracted = texture(colortex0, uv + refOffset).rgb;

    // отражение
    float reflectStrength = 0.45; 
    vec3 reflected = sampleReflection(uv, uv + refOffset * 2.0, reflectStrength);

    vec3 dropColor = mix(refracted, reflected, mask * 0.9);

    sceneColor = mix(sceneColor, dropColor, mask);
    fragColor = vec4(sceneColor, 1.0);
}
