
uniform sampler2D shadowtex1;
uniform sampler2D shadowcolor0;
uniform sampler2D shadowcolor1;

const int shadowMapResolution = 2048;  // Shadowmap resolution [1024 2048 4096 8192 16384 32768]

//----------------------------------------------------------------------------//

#include "ShadowDistortion.glsl"

vec3 WorldToShadowProjPos(in vec3 worldPos) {
	vec3 shadowPos = transMAD(shadowModelView, worldPos);
	return projMAD(shadowProjection, shadowPos);
}

vec2 DistortShadowProjPos(in vec2 shadowClipPos) {
	shadowClipPos.xy *= rcp(DistortionFactor(shadowClipPos.xy));

	return shadowClipPos * 0.5 + 0.5;
}

//----------------------------------------------------------------------------//

vec3 CalculateRSM(in vec3 viewPos, in vec3 worldNormal, in float dither) {
	vec3 total = vec3(0.0);

	const float realShadowMapRes = shadowMapResolution * MC_SHADOW_QUALITY;
	vec3 worldPos = transMAD(gbufferModelViewInverse, viewPos);
	vec3 shadowPos = WorldToShadowProjPos(worldPos);

	vec3 shadowNormal = mat3(shadowModelView) * worldNormal;
	shadowNormal.z = -shadowNormal.z;

	float rSteps = 1.0 / float(GI_SAMPLES);

	float sqRadius = GI_RADIUS * GI_RADIUS;
	float radiusAdd = sqrt(sqRadius / GI_SAMPLES);

	float rayStep = 2.0 / realShadowMapRes; // Clip space step per texel

	float skyLightmap = texelFetch(colortex7, ivec2(gl_FragCoord.xy * 2), 0).g;

	for (uint i = 0u; i < GI_SAMPLES; ++i) {
		float fi = float(i);
		vec2 hash = fract(sin(vec2(fi * PHI1 + dither * 12.9898, fi * PHI1 * PHI1 + dither * 78.233)) * 43758.5453123);

		vec3 dir = cosineWeightedHemisphereSample(shadowNormal, hash);

		float scale = (fi + hash.x) / float(GI_SAMPLES);
		scale = mix(0.1, 1.0, scale * scale);

		vec3 sampleOffset = dir * (scale * GI_RADIUS * rayStep);

		vec2 coord = shadowPos.xy + sampleOffset.xy; // Approximate by ignoring Z offset in projection (ortho assumption)

		ivec2 sampleTexel = ivec2(DistortShadowProjPos(coord) * realShadowMapRes);

		#if defined DISTANT_HORIZONS && defined DH_SHADOW
			float sampleDepth = texelFetch(shadowtex1, sampleTexel, 0).x * 40.0 - 20.0;
		#else
			float sampleDepth = texelFetch(shadowtex1, sampleTexel, 0).x * 10.0 - 5.0;
		#endif

		vec3 sampleVector = vec3(coord, sampleDepth) - shadowPos;

		float sampleDistSq = dotSelf(sampleVector);
		if (sampleDistSq > sqRadius || sampleDistSq < 1e-5) continue;

		vec3 sampleDir = normalize(sampleVector);

		float diffuse = saturate(dot(shadowNormal, sampleDir));
		if (diffuse < 1e-5) continue;

		vec3 sampleColor = texelFetch(shadowcolor1, sampleTexel, 0).rgb;

		vec3 sampleNormal = DecodeNormal(sampleColor.xy);
		sampleNormal.xy = -sampleNormal.xy;

		float bounce = saturate(dot(sampleNormal, sampleDir));
		if (bounce < 1e-5) continue;

		float falloff = rcp(sampleDistSq + radiusAdd);

		#if defined IS_OVERWORLD
			float skylightWeight = saturate(exp2(-sqr(sampleColor.z - skyLightmap)) * 2.5 - 1.5);
		#else
			float skylightWeight = 1.0;
		#endif

		vec3 albedo = pow(texelFetch(shadowcolor0, sampleTexel, 0).rgb, vec3(2.2));

		total += albedo * falloff * skylightWeight * bounce * diffuse; // Removed fi multiplier for better distribution with cosine sampling
	}

	return total * sqRadius * rSteps * 5e-2;
}
