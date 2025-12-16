#ifndef SSGI_INCLUDED
#define SSGI_INCLUDED


#ifndef PI
#define PI 3.14159265359
#endif


// Параметры (подстройте под нужный результат)
#define SSGI_NUM_STEPS 24
#define SSGI_NUM_SAMPLES 6
#define SSGI_MAX_DISTANCE 8.0 // в view-space единицах
#define SSGI_STEP_SCALE 0.8
#define SSGI_BIAS 0.05
#define SSGI_INTENSITY 1.25


// Поддерживаемые uniform'ы — ожидаем, что они уже объявлены в UniformDeclare.glsl
// uniform sampler2D depthtex1;
// uniform sampler2D colortex3;
// uniform sampler2D colortex7; // если содержит world normal
// uniform float viewWidth;
// uniform float viewHeight;


// Вспомогательные функции
float LinearizeDepth(float d){
// Если в паке глубина хранится линейно, используйте identity.
// В большинстве паков depthtex1 хранит нелинейную глубину (0..1),
// поэтому нужна реконструкция.
float z = d * 2.0 - 1.0; // NDC
// Требуется inverse projection; если его нет — используем приближение.
// Здесь используем удобный аппрокс для типичных Minecraft-шейдеров.
return (2.0 * 0.1) / (1.0 - z * (1.0 - 0.1)); // near=0.1 hardcoded, если у вас другой near — поправьте
}


vec3 ScreenPosToView(in vec2 uv, in float depth){
// Простая реконструкция view-space позиции по экранным координатам и глубине.
// uv — [0..1]
float ndcX = uv.x * 2.0 - 1.0;
float ndcY = uv.y * 2.0 - 1.0;
float linearDepth = depth; // если depthtex1 уже линейный — ок


// Без доступа к inverse projection делаем приблизительную карту глубины вдоль z.
// Здесь мы интерпретируем depth как view-space z (если depth хранится линейно)
// Для большинства shaderpacks нужно заменить эту функцию на точную реконструкцию
// через projectionInverse (если он доступен).
return vec3(ndcX * linearDepth * (viewWidth / viewHeight), ndcY * linearDepth, -linearDepth);
}


vec3 SampleNormal(in vec2 uv){
#ifdef COLORTEX7_2D
// если в colortex7 лежат нормали в [-1,1] в RGB
vec3 n = texture(colortex7, uv).xyz * 2.0 - 1.0;
return normalize(n);
#else
// fallback: приближённая нормаль по соседним глубинам
float dC = texture(depthtex1, uv).r;
float dx = texture(depthtex1, uv + vec2(1.0/viewWidth,0)).r - dC;
float dy = texture(depthtex1, uv + vec2(0,1.0/viewHeight)).r - dC;
vec3 n = normalize(vec3(-dx, -dy, 1.0));
return n;
#endif
}


// Получаем эмиссив (источник света) — в большинстве паков это colortex3
vec3 SampleEmissive(in vec2 uv){
vec4 e = texture(colortex3, uv);
// если в colortex3 хранится RGBA (включая блоклайт), берем rgb
return e.rgb;
}


#endif // SSGI_INCLUDED