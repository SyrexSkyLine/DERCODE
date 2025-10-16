// === Colored Block Light ===
uniform sampler3D uLightVolume;
uniform ivec3 uVolumeSize;
uniform vec3 uVolumeOrigin;
uniform float uVoxelSize;

vec3 sampleBlockLight(vec3 worldPos) {
    vec3 local = (worldPos - uVolumeOrigin) / (uVoxelSize * vec3(uVolumeSize));
    vec3 uvw = clamp(local, vec3(0.0), vec3(0.999));
    return texture(uLightVolume, uvw).rgb;
}
