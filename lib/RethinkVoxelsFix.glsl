#ifndef RETHINK_VOXELS_FIX_GLSL
#define RETHINK_VOXELS_FIX_GLSL

///////THIS SHIT CODE FOR TESTING OTHER SHITCODE//////////////////////


vec3 rv_computeVoxelGI(vec2 fragCoordUV) {
    vec2 rv_uv_local = fragCoordUV;
    float rv_depth_local = rv_GetDepth(rv_uv_local);
    vec3 rv_viewPos_local = rv_ReconstructViewPos(rv_uv_local, rv_depth_local);
    vec3 rv_normal_local = rv_GetNormal(rv_uv_local);
    vec3 rv_indirect_local = rv_rethinkVoxelGI(rv_uv_local, rv_viewPos_local, rv_normal_local);


    rv_indirect_local *= 1.15;

    return rv_indirect_local;
}

#endif // RETHINK_VOXELS_FIX_GLSL
