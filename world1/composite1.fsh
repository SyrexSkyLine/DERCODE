#version 450 compatibility


#include "/lib/Head/Common.inc"

layout(location = 0) out vec3 sceneData;

#ifdef BLOOMY_FOG
	layout(location = 1) out float fogTransmittance;
	/* DRAWBUFFERS:46 */
#else
	/* DRAWBUFFERS:4 */
#endif


in vec2 screenCoord;

#include "/lib/Head/Uniforms.inc"

//----// STRUCTS //-------------------------------------------------------------------------------//

#include "/lib/Head/Mask.inc"
#include "/lib/Head/Material.inc"

//----// FUNCTIONS //-----------------------------------------------------------------------------//

#include "/lib/Head/Functions.inc"

#include "/lib/Surface/Refraction.glsl"

#include "/lib/Surface/ReflectionFilter.glsl"

#include "/lib/Atmosphere/Fogs.glsl"

#include "/lib/Water/WaterFog.glsl"

//----// MAIN //----------------------------------------------------------------------------------//
void main() {
	ivec2 texel 		= ivec2(gl_FragCoord.xy);

	vec4 gbuffer3 		= texelFetch(colortex3, texel, 0);
	vec4 albedoT 		= vec4(UnpackUnorm2x8(gbuffer3.z), UnpackUnorm2x8(gbuffer3.w));

	vec3 normal 		= DecodeNormal(gbuffer3.xy);

	int materialIDT 	= int(texelFetch(colortex7, texel, 0).z * 255.0);
	TranslucentMask materialMaskT = CalculateMasksT(materialIDT);

	float depthSoild 	= GetDepthSoild(texel);
	// depthSoild += 0.38 * step(depthSoild, 0.56);
	float depth 		= GetDepthFix(texel);

	vec3 viewPos 		= ScreenToViewSpace(vec3(screenCoord, depth));

	if (depth < 1.0) {
		vec3 viewDir 	= normalize(viewPos);
		vec3 worldPos 	= transMAD(gbufferModelViewInverse, viewPos);;

		#ifdef RAYTRACED_REFRACTION
			#ifdef REFRACTIVE_DISPERSION
				vec2 refractCoord  	= CalculateRefractCoord(materialMaskT, normal, viewDir, viewPos, depth, 1.5);
				vec2 refractCoordR  = CalculateRefractCoord(materialMaskT, normal, viewDir, viewPos, depth, 1.45);
				vec2 refractCoordB  = CalculateRefractCoord(materialMaskT, normal, viewDir, viewPos, depth, 1.55);
				ivec2 refractTexel 	= ivec2(refractCoord * screenSize);
				ivec2 refractTexelR = ivec2(refractCoordR * screenSize);
				ivec2 refractTexelB = ivec2(refractCoordB * screenSize);

				sceneData.g 		= texelFetch(colortex4, refractTexel, 0).g;
				sceneData.r 		= texelFetch(colortex4, refractTexelR, 0).r;
				sceneData.b 		= texelFetch(colortex4, refractTexelB, 0).b;
			#else
				vec2 refractCoord  	= CalculateRefractCoord(materialMaskT, normal, viewDir, viewPos, depth, 1.5);
				ivec2 refractTexel 	= ivec2(refractCoord * screenSize);

				sceneData 			= texelFetch(colortex4, refractTexel, 0).rgb;
			#endif
		#else
			vec2 refractCoord  	= CalculateRefractCoord(materialMaskT, normal, worldPos, viewPos, depthSoild, depth);
			ivec2 refractTexel 	= ivec2(refractCoord * screenSize);

			sceneData 			= texelFetch(colortex4, refractTexel, 0).rgb;
		#endif

		vec3 albedoRaw 		= texelFetch(colortex6, refractTexel, 0).rgb;
		vec3 albedo 		= SRGBtoLinear(albedoRaw);

		Material material 	= GetMaterialData(texelFetch(colortex0, refractTexel, 0).xy);

		if (materialMaskT.stainedGlass) TransparentAbsorption(sceneData, albedoT);
		if (materialMaskT.ice) sceneData *= sqr(albedoT.rgb);

		if (materialMaskT.translucent) {
			vec4 reflectionData = texelFetch(colortex2, texel, 0);
			sceneData = sceneData * reflectionData.a + reflectionData.rgb;
		} else if (material.hasReflections) {
			vec4 reflectionData = texelFetch(colortex2, texel, 0);
			#ifdef REFLECTION_FILTER
				if (material.isRough) reflectionData.rgb = ReflectionFilter(texel, reflectionData, material.roughness, normal, viewDir, 1.0, RandNext2F() - 0.5).rgb;
			#endif
			sceneData += reflectionData.rgb * mix(vec3(1.0), albedo, material.isMetal);
		}
	} else {
		sceneData = texelFetch(colortex4, texel, 0).rgb;
	}

	float fogDist = length(viewPos);

	if (isEyeInWater == 1) UnderwaterFog(sceneData, materialMaskT, fogDist);

	vec4 VFData = SpatialUpscale(colortex1, gl_FragCoord.xy, GetDepthLinear(depth));

	sceneData *= VFData.a;
	sceneData += VFData.rgb;

	CommonFog(sceneData, fogDist);

	#ifdef BLOOMY_FOG
		fogTransmittance = saturate(VFData.a * 0.5 + 0.5);

		float fogDensity = 4e-3;

		if (isEyeInWater == 1) fogDensity = 0.06 * WATER_FOG_DENSITY;
		if (isEyeInWater > 1) fogDensity = 1.0;

		fogTransmittance = min(expf(-fogDensity * fogDist), fogTransmittance);
	#endif

	#if DEBUG_NORMAL == 0
		sceneData = clamp16F(sceneData);
	#elif DEBUG_NORMAL == 1
		sceneData = normal;
	#else
		sceneData = mat3(gbufferModelViewInverse) * normal;
	#endif
}
