// Uncommented the sampling functions
vec3 uniformSphereSample(vec2 hash) {
hash.x *= TAU; hash.y = 2.0 * hash.y - 1.0;
return vec3(sincos(hash.x) * sqrt(1.0 - hash.y * hash.y), hash.y);
}
// https://amietia.com/lambertnotangent.html
vec3 cosineWeightedHemisphereSample(vec3 vector, vec2 hash) {
vec3 dir = normalize(uniformSphereSample(hash) + vector);
return dot(dir, vector) < 0.0 ? -dir : dir;
}
float SpiralAO(in vec2 coord, in vec3 viewPos, in vec3 normal, float dither) {
float rSteps = 1.0 / float(SSAO_SAMPLES);
float maxSqLen = sqr(viewPos.z) * 0.25;
float total = 0.0;
// Adjusted rayStep to be scalar for view space radius scaling
float rayStep = 0.6 / max((far - near) * -viewPos.z / far + near, 5.0) * gbufferProjection[1][1];
// Use dither to seed pseudo-random for each sample
for (uint i = 0u; i < SSAO_SAMPLES; ++i) {
// Pseudo-random hash based on sample index and dither (assuming dither is in [0,1])
float fi = float(i);
vec2 hash = fract(sin(vec2(fi * PHI1 + dither * 12.9898, fi * PHI1 * PHI1 + dither * 78.233)) * 43758.5453123);
vec3 dir = cosineWeightedHemisphereSample(normal, hash);
// Bias samples towards closer occluders
float scale = (fi + hash.x) / float(SSAO_SAMPLES);
scale = mix(0.1, 1.0, scale * scale);
vec3 rayPos = viewPos + dir * (scale * rayStep * float(SSAO_SAMPLES));  // Scale max radius appropriately
vec2 screenPos = ViewToScreenSpaceRaw(rayPos).xy;
vec3 diff = ScreenToViewSpace(screenPos) - viewPos;
float diffSqLen = dotSelf(diff);
if (diffSqLen > 1e-5 && diffSqLen < maxSqLen) {
float NdotL = saturate(dot(normal, diff * inversesqrt(diffSqLen)));
total += NdotL * saturate(1.0 - diffSqLen / maxSqLen);
}
}
total = max0(1.0 - total * rSteps * SSAO_STRENGTH);
return total * pow(total, 1.0);  // Усилено: теперь total^2 для более сильного falloff, как в Bliss/Complementary
}
#if defined DISTANT_HORIZONS
float SpiralAO_DH(in vec2 coord, in vec3 viewPos, in vec3 normal, float dither) {
float rSteps = 1.0 / float(SSAO_SAMPLES);
float maxSqLen = sqr(viewPos.z) * 0.25;
float total = 0.0;
float rayStep = 0.6 / max((far - near) * -viewPos.z / far + near, 5.0) * gbufferProjection[1][1];
for (uint i = 0u; i < SSAO_SAMPLES; ++i) {
float fi = float(i);
vec2 hash = fract(sin(vec2(fi * PHI1 + dither * 12.9898, fi * PHI1 * PHI1 + dither * 78.233)) * 43758.5453123);
vec3 dir = cosineWeightedHemisphereSample(normal, hash);
float scale = (fi + hash.x) / float(SSAO_SAMPLES);
scale = mix(0.1, 1.0, scale * scale);
vec3 rayPos = viewPos + dir * (scale * rayStep * float(SSAO_SAMPLES));
vec2 screenPos = ViewToScreenSpaceRaw(rayPos).xy;
vec3 diff = ScreenToViewSpaceDH(screenPos) - viewPos;
float diffSqLen = dotSelf(diff);
if (diffSqLen > 1e-5 && diffSqLen < maxSqLen) {
float NdotL = saturate(dot(normal, diff * inversesqrt(diffSqLen)));
total += NdotL * saturate(1.0 - diffSqLen / maxSqLen);
}
}
total = max0(1.0 - total * rSteps * SSAO_STRENGTH);
return total * pow(total, 1.0);  // То же усиление для DH версии
}
#endif