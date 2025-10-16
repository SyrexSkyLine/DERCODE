#version 450 compatibility

out vec3 sceneData;

in vec2 screenCoord;

#include "/lib/Head/Common.inc"
#include "/lib/Head/Uniforms.inc"

//----// STRUCTS //-------------------------------------------------------------------------------//

#include "/lib/Head/Mask.inc"

//----// FUNCTIONS //-----------------------------------------------------------------------------//

#include "/lib/Head/Functions.inc"

#include "/lib/Water/WaterFog.glsl"
#include "/lib/RethinkVoxels.glsl"

//----// MAIN //----------------------------------------------------------------------------------//
void main() {
	ivec2 texel = ivec2(gl_FragCoord.xy);

	int materialIDT = int(texelFetch(colortex7, texel, 0).z * 255.0);
	TranslucentMask materialMaskT = CalculateMasksT(materialIDT);

	sceneData = texelFetch(colortex4, texel, 0).rgb;
	if ((materialMaskT.water || materialMaskT.ice) && isEyeInWater == 0) {
		float depthSoild = GetDepthSoild(texel);
		vec3 viewPos = ScreenToViewSpace(vec3(screenCoord, GetDepth(texel)));
		vec3 viewPosSoild = ScreenToViewSpace(vec3(screenCoord, depthSoild));

		// #if defined DISTANT_HORIZONS
		// 	if (depthSoild >= 1.0) {
		// 		viewPos = ScreenToViewSpaceDH(vec3(screenCoord, GetDepthDH(texel)));
		// 		viewPosSoild = ScreenToViewSpaceDH(vec3(screenCoord, GetDepthSoildDH(texel)));
		// 	}
		// #endif
		WaterFog(sceneData, materialMaskT, 0.0, 0.0, distance(viewPos, viewPosSoild));
	}


// --- Auto-inserted Rethink Voxel GI (Roblox Future Light color) ---
#ifdef RETHINK_VOXELS_GLSL
    vec2 rv_uv = gl_FragCoord.xy * screenPixelSize;
    float rv_depth = rv_GetDepth(rv_uv);
    vec3 rv_viewPos = rv_ReconstructViewPos(rv_uv, rv_depth);
    vec3 rv_normal = rv_GetNormal(rv_uv);
    vec3 rv_indirect = rv_rethinkVoxelGI(rv_uv, rv_viewPos, rv_normal);
    // stylized boost for Roblox look
    rv_indirect *= 1.15;
    // apply to sceneData (if exists) or to finalColor
    #ifdef sceneData
        sceneData += rv_indirect;
    #else
        #ifdef finalColor
            finalColor.rgb += rv_indirect;
        #endif
    #endif
#endif
// --- end Rethink GI injection ---
}

/* DRAWBUFFERS:4 */