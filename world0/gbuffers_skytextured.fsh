#version 450 compatibility

out vec3 albedoData;

/* DRAWBUFFERS:6 */

uniform sampler2D tex;

flat in vec3 tint;
in vec2 texcoord;


// ---------------- НАСТРОЙКИ ----------------

#define MOON_BLOOM_COLOR      vec3(40.0, 0.12, 0.12)
#define MOON_BLOOM_INTENSITY  3.0

#define MOON_CORE_POWER  40.0
#define MOON_GLOW_POWER  4.0

#define BLOOM_SOFTNESS  0.33


// ---------------- МАГИЯ ЦЕНТРА ----------------
// Вычисляет центр текущего примитива (луны)

vec2 localUV(vec2 uv)
{
    vec2 fw = fwidth(uv);
    vec2 minUV = uv - fw * 0.5;
    vec2 size  = fw;

    return (uv - minUV) / size;
}


void main()
{
    vec4 albedoTex = texture(tex, texcoord);
    if(albedoTex.a < 0.1) discard;

    vec3 texColor = albedoTex.rgb;


    // ---------- ДЕТЕКТ ЛУНЫ ----------

    bool tintWhite = all(lessThan(abs(tint - vec3(1.0)), vec3(0.05)));

    bool isYellowSun =
        texColor.r > 0.65 &&
        texColor.r > texColor.b * 1.5;


    // ---------- ЛУНА ----------

    if(tintWhite && !isYellowSun)
    {
        // ✅ ЛОКАЛЬНЫЕ UV ЛУНЫ
        vec2 uv = localUV(texcoord);

        // ✅ Реальный центр
        vec2 center = vec2(0.5);

        float dist = length(uv - center);


        // ✅ МАСКА ФАЗ
        float phase =
            dot(texColor, vec3(0.333));

        phase = smoothstep(0.05, 1.0, phase);


        // ---------- БЛУМ ----------

        float bloomCore =
            1.0 - smoothstep(0.0,
                              BLOOM_SOFTNESS,
                              dist);

        float bloomGlow =
            1.0 - smoothstep(BLOOM_SOFTNESS,
                              BLOOM_SOFTNESS + 0.18,
                              dist);

        vec3 bloom =
              MOON_BLOOM_COLOR
            * MOON_BLOOM_INTENSITY
            * (
                bloomCore * MOON_CORE_POWER +
                bloomGlow * MOON_GLOW_POWER
              )
            * phase;


        // ---------- ФИНАЛ ----------

        vec3 color = texColor + bloom;
        albedoData = color * tint;
        return;
    }


    // ---------- ПРОЧЕЕ ----------

    albedoData = texColor * tint;
}
