///////VOLUMETRIC FOG WITH GOD RAYS - BLISS/PTGI STYLE

/////////////////OK 
#define VOLUMETRIC_FOG_DENSITY 0.005 // [0.0001 0.0002 0.0005 0.0007 0.001 0.0015 0.002 0.0025 0.003 0.0035 0.004 0.005 0.006 0.007 0.01 0.015 0.02 0.025 0.03 0.035 0.04 0.05 0.07 0.1]
#define SEA_LEVEL 63.0 // [0.0 1.0 2.0 3.0 4.0 5.0 6.0 7.0 8.0 9.0 10.0 11.0 12.0 13.0 14.0 15.0 16.0 17.0 18.0 19.0 20.0 21.0 22.0 23.0 24.0 25.0 26.0 27.0 28.0 29.0 30.0 31.0 32.0 33.0 34.0 35.0 36.0 37.0 38.0 39.0 40.0 41.0 42.0 43.0 44.0 45.0 46.0 47.0 48.0 49.0 50.0 51.0 52.0 53.0 54.0 55.0 56.0 57.0 58.0 59.0 60.0 61.0 62.0 63.0 64.0 65.0 66.0 67.0 68.0 69.0 70.0 71.0 72.0 73.0 74.0 75.0 76.0 77.0 78.0 79.0 80.0 81.0 82.0 83.0 84.0 85.0 86.0 87.0 88.0 89.0 90.0 91.0 92.0 93.0 94.0 95.0 96.0 97.0 98.0 99.0 100.0 101.0 102.0 103.0 104.0 105.0 106.0 107.0 108.0 109.0 110.0 111.0 112.0 113.0 114.0 115.0 116.0 117.0 118.0 119.0 120.0 121.0 122.0 123.0 124.0 125.0 126.0 127.0 128.0 129.0 130.0 131.0 132.0 133.0 134.0 135.0 136.0 137.0 138.0 139.0 140.0 141.0 142.0 143.0 144.0 145.0 146.0 147.0 148.0 149.0 150.0 151.0 152.0 153.0 154.0 155.0 156.0 157.0 158.0 159.0 160.0 161.0 162.0 163.0 164.0 165.0 166.0 167.0 168.0 169.0 170.0 171.0 172.0 173.0 174.0 175.0 176.0 177.0 178.0 179.0 180.0 181.0 182.0 183.0 184.0 185.0 186.0 187.0 188.0 189.0 190.0 191.0 192.0 193.0 194.0 195.0 196.0 197.0 198.0 199.0 200.0 201.0 202.0 203.0 204.0 205.0 206.0 207.0 208.0 209.0 210.0 211.0 212.0 213.0 214.0 215.0 216.0 217.0 218.0 219.0 220.0 221.0 222.0 223.0 224.0 225.0 226.0 227.0 228.0 229.0 230.0 231.0 232.0 233.0 234.0 235.0 236.0 237.0 238.0 239.0 240.0 241.0 242.0 243.0 244.0 245.0 246.0 247.0 248.0 249.0 250.0 251.0 252.0 253.0 254.0 255.0]
#define VOLUMETRIC_FOG_SAMPLES 20 // [2 4 6 8 9 10 12 14 15 16 18 20 24 30 50 70 100 150 200 300 500]

#define VOLUMETRIC_LIGHT_STRENGTH 0.8 // [0.001 0.002 0.005 0.007 0.01 0.02 0.03 0.04 0.05 0.07 0.1 0.12 0.15 0.17 0.2 0.25 0.3 0.35 0.4 0.45 0.5 0.55 0.6 0.7 0.8 0.9 1.0 1.5 2.0 3.0 4.0 5.0 7.0 10.0]
#define UW_VOLUMETRIC_LIGHT_STRENGTH 1.0 // [0.01 0.015 0.02 0.03 0.05 0.075 0.1 0.15 0.2 0.3 0.5 0.75 1.0 1.5 2.0 3.0 5.0 7.5 10.0 15.0 20.0 30.0 50.0 75.0 100.0]
#define UW_VOLUMETRIC_LIGHT_LENGTH 50.0 // [10.0 15.0 20.0 25.0 30.0 35.0 40.0 45.0 50.0 55.0 60.0 80.0 100.0 120.0 150 200.0 300.0]
//#define RAY_STAINED_GLASS_TINT
#define TIME_FADE

// ============================================
// GOD RAYS SETTINGS
// ============================================
#define GODRAYS_ENABLED
#define GODRAY_STRENGTH 2.5 // [0.5 0.75 1.0 1.25 1.5 1.75 2.0 2.5 3.0 3.5 4.0 5.0 7.0 10.0]
#define GODRAY_SAMPLES 40 // [16 20 24 28 32 40 48 56 64 80 96 128]
#define GODRAY_DENSITY 0.65 // [0.1 0.2 0.3 0.4 0.5 0.65 0.8 1.0 1.25 1.5 2.0]
#define GODRAY_DECAY 0.975 // [0.90 0.92 0.94 0.95 0.96 0.97 0.975 0.98 0.985 0.99]
#define GODRAY_EXPOSURE 1.0 // [0.3 0.5 0.7 0.8 0.9 1.0 1.2 1.5 1.8 2.0 2.5]
#define GODRAY_DITHER_STRENGTH 0.6 // [0.0 0.2 0.4 0.6 0.8 1.0 1.5 2.0]
//#define GODRAY_BLUR // Размытие god rays для мягкости
#define GODRAY_COLOR_BLEEDING // Цвет от витражей
// ============================================

// Nether-specific volumetric fog parameters (inspired by Complementary Euphoria)
#define NETHER_FOG_DENSITY 0.015 // Base density for volumetric fog in Nether [0.005 0.01 0.015 0.02 0.025 0.03 0.05 0.07 0.1]
#define NETHER_FOG_SAMPLES 24 // Steps for Nether volumetric [16 20 24 28 32 36]
#define NETHER_HEIGHT_NETHER_FOG_SAMPLESFALLOFF 0.008 // Height-based falloff [0.005 0.008 0.01 0.012]
#define NETHER_NOISE_SCALE 0.012 // Noise scale for Nether fog turbulence [0.008 0.01 0.012 0.015]
#define NETHER_LIGHT_DISPERSION_RADIUS 15.0 // Radius around light sources (lava/glowstone) to disperse fog [10.0 12.5 15.0 17.5 20.0]
#define NETHER_MINI_CLOUD_SCALE 0.5 // Scale for mini fog clouds [0.3 0.4 0.5 0.6 0.7]
#define NETHER_MINI_CLOUD_INTENSITY 2.0 // Intensity of mini clouds [1.0 1.5 2.0 2.5 3.0]
#define NETHER_CLOUD_COVERAGE 0.6 // Coverage for volumetric clouds [0.3 0.4 0.5 0.6 0.7 0.8]
#define NETHER_CLOUD_ALTITUDE 80.0 // Base altitude for clouds [60.0 70.0 80.0 90.0 100.0]
#define NETHER_CLOUD_THICKNESS 20.0 // Thickness of cloud layer [10.0 15.0 20.0 25.0 30.0]
#define NETHER_RANDOM_CLOUD_SCALE 0.02 // Scale for random dense cloud patches in Basalt Deltas [0.01 0.015 0.02 0.025 0.03]
#define NETHER_RANDOM_CLOUD_DENSITY 60.0 // Density multiplier for random cloud patches [40.0 50.0 60.0 70.0 80.0]
#define NETHER_RANDOM_CLOUD_FREQUENCY 0.3 // Frequency of random cloud patches [0.1 0.2 0.3 0.4 0.5]

// Nether special effects
#define NETHER_VORTEX_COLOR_R 0.8
#define NETHER_VORTEX_COLOR_G 0.2
#define NETHER_VORTEX_COLOR_B 0.1
#define NETHER_HALO_COLOR_R 0.7
#define NETHER_HALO_COLOR_G 0.3
#define NETHER_HALO_COLOR_B 0.1
#define NETHER_HAZE_COLOR_R 0.6
#define NETHER_HAZE_COLOR_G 0.4
#define NETHER_HAZE_COLOR_B 0.2
#define BRIGHTNESS_VORTEX 0.6
#define BRIGHTNESS_HALO 0.1
#define BRIGHTNESS_HAZE 0.001
#define NETHER_VORTEX_BOUNDS_RANGE 800.0
#define NETHER_VORTEX_DENSITY_BOOST 20.5
#define NETHER_CENTER_FOG_RADIUS 350.0
#define NETHER_CENTER_FOG_HEIGHT_MIN 40.0
#define NETHER_CENTER_FOG_HEIGHT_MAX 300.0
#define NETHER_CENTER_FOG_BOTTOM -30.0
#define NETHER_CENTER_FOG_BASE_Y 70.0
#define NETHER_CENTER_FOG_THICKNESS 200.0
#define NETHER_CENTER_FOG_DARK_R 0.3
#define NETHER_CENTER_FOG_DARK_G 0.1
#define NETHER_CENTER_FOG_DARK_B 0.05
#define NETHER_CENTER_FOG_OVERALL_BRIGHTNESS 1.0
#define NETHER_CENTER_LAYER1_OFFSET_Y 0.0
#define NETHER_CENTER_LAYER2_OFFSET_Y 10.0
#define NETHER_CENTER_LAYER3_OFFSET_Y 2.0
#define NETHER_CENTER_LAYER1_ANIM_SPEED 0.12
#define NETHER_CENTER_LAYER2_ANIM_SPEED 0.09
#define NETHER_CENTER_LAYER3_ANIM_SPEED 0.18
#define NETHER_CENTER_LAYER1_ANIM_AMPLITUDE 6.0
#define NETHER_CENTER_LAYER2_ANIM_AMPLITUDE 4.0
#define NETHER_CENTER_LAYER3_ANIM_AMPLITUDE 2.5

//------------------------------------------------------------------------------------------------//

#ifdef CLOUDS_SHADOW
	#include "/lib/Atmosphere/VolumetricClouds.glsl"

	#define CLOUD_PLANE_ALTITUDE 7000 // [400 500 1000 1200 1500 1700 2000 3000 4000 5000 6000 6500 7000 7500 8000 9000 10000 12000]
	#define CLOUD_PLANE1_COVERY 0.5 // [0 0.05 0.1 0.15 0.2 0.25 0.3 0.35 0.4 0.45 0.5 0.55 0.6 0.65 0.7 0.8 0.9 1.0]

	float CloudPlanarDensity(in vec2 worldPos) {
    	worldPos /= 1.0 + distance(worldPos, cameraPosition.xz) * 2e-5;
		vec2 position = worldPos * 1e-4 - wind.xz;

		float baseCoverage = curve(texture(noisetex, position * 0.08).z * 0.7 + 0.1);
		baseCoverage *= max0(1.07 - texture(noisetex, position * 0.003).y * 1.4);

		vec2 curl = texture(noisetex, position * 0.05).xy * 0.04;
		curl += texture(noisetex, position * 0.1).xy * 0.02;
		position += curl;
		float noise = 0.5 * texture(noisetex, position * vec2(0.4, 0.16)).z;
		noise += texture(noisetex, position * 0.9).z - 0.24;
		noise = saturate(noise);

		#ifdef CLOUDS_WEATHER
			noise -= cloudDynamicWeather.x;
		#endif

		noise *= clamp((baseCoverage + CLOUD_PLANE1_COVERY - 0.6) * 0.9, 0.0, 0.14);
    	if (noise < 1e-6) return 0.0;
		position.x += noise * 0.2;

		noise += 0.02 * texture(noisetex, position * 3.0).z;
		noise += 0.01 * texture(noisetex, position * 5.0 + curl).z - 0.05;

		return cube(saturate(noise * (4.0 + wetness)));
	}

	float CalculateCloudShadow(in vec3 worldPos, in CloudProperties cloudProperties) {
		float cloudDensity = 0.0;
		vec3 checkOrigin = worldPos + vec3(0.0, planetRadius, 0.0);
		#ifdef VC_SHADOW
			float checkRadius = planetRadius + cloudProperties.altitude;
			vec3 checkPos = RaySphereIntersection(checkOrigin, worldLightVector, checkRadius + 0.15 * cloudProperties.thickness).y * worldLightVector + worldPos;
			cloudDensity = CloudVolumeDensitySmooth(cloudProperties, checkPos) * 2.0;
		#endif
		#ifdef PC_SHADOW
			vec2 checkPos1 = RaySphereIntersection(checkOrigin, worldLightVector, planetRadius + CLOUD_PLANE_ALTITUDE).y * worldLightVector.xz + worldPos.xz;
			cloudDensity += CloudPlanarDensity(checkPos1) * 10.0;
		#endif
		cloudDensity = saturate(cloudDensity);

		return expf(cloudDensity * cloudDensity * -1e2);
	}
#endif

#include "/lib/Lighting/ShadowDistortion.glsl"

vec3 WorldPosToShadowPos(in vec3 worldPos) {
	vec3 shadowClipPos = transMAD(shadowModelView, worldPos);
	shadowClipPos = projMAD(shadowProjection, shadowClipPos);
	#if defined DISTANT_HORIZONS && defined DH_SHADOW
		shadowClipPos.z *= 0.05;
	#else
		shadowClipPos.z *= 0.2;
	#endif

	return shadowClipPos * 0.5 + 0.5;
}

vec2 DistortShadowSpace(in vec2 shadowClipPos) {
	shadowClipPos = shadowClipPos * 2.0 - 1.0;
	shadowClipPos.xy *= rcp(DistortionFactor(shadowClipPos.xy));

	return shadowClipPos * 0.5 + 0.5;
}

uniform float BiomeSandstorm, BiomeGreenShift, volFogDensity;
uniform vec3 volFogWind;
uniform float meWeight;

#if defined IS_NETHER
	uniform float BiomeNetherWastesSmooth;
	uniform float BiomeWarpedForestSmooth;
	uniform float BiomeCrimsonForestSmooth;
	uniform float BiomeSoulSandValleySmooth;
	uniform float BiomeBasaltDeltasSmooth;

	vec3 netherFogWind = vec3(0.8, 0.2, 0.6) * worldTimeCounter * 0.012;

	vec3 NetherFogColor() {
		return vec3(0.99, 0.23, 0.03) 	* BiomeNetherWastesSmooth
			 + vec3(0.04, 0.24, 0.2) 	* BiomeWarpedForestSmooth
			 + vec3(0.3, 0.03, 0.01) 	* BiomeCrimsonForestSmooth
			 + vec3(0.012, 0.055, 0.06) * BiomeSoulSandValleySmooth
			 + vec3(0.5, 0.5, 0.5) 		* BiomeBasaltDeltasSmooth;
	}

vec3 hash31(float p) {
    vec3 p3 = fract(vec3(p) * vec3(.1031, .1030, .0973));
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.xxy + p3.yzz) * p3.zyx);
}

float hash11(float p) {
    p = fract(p * .1031);
    p *= p + 33.33;
    p *= p + p;
    return fract(p);
}

uvec3 iqint2(uvec3 x) {
    const uint k = 1103515245u;
    x = ((x >> 8U) ^ x.yzx) * k;
    x = ((x >> 8U) ^ x.yzx) * k;
    x = ((x >> 8U) ^ x.yzx) * k;
    return x;
}

uvec3 hash(vec2 s) {
    uvec4 u = uvec4(s, uint(s.x) ^ uint(s.y), uint(s.x) + uint(s.y));
    return iqint2(u.xyz);
}

void SwirlAroundOrigin(inout vec3 alteredOrigin, vec3 origin) {
    float radiance = 2.39996 + alteredOrigin.y / 1.5 + worldTimeCounter / 50.0;
    mat2 rotationMatrix = mat2(vec2(cos(radiance), -sin(radiance)), vec2(sin(radiance), cos(radiance)));
    float swirlBounds = clamp(sqrt(length(vec3(origin.x, origin.y - 100.0, origin.z)) / 200.0 - 1.0), 0.0, 1.0);
    float swirlBoost = smoothstep(50.0, 80.0, length(origin.xz)) * NETHER_VORTEX_DENSITY_BOOST;
    alteredOrigin.xz = mix(alteredOrigin.xz * rotationMatrix, alteredOrigin.xz, swirlBounds * (1.0 - swirlBoost));
}

void NetherCenterSphericalFog(in vec3 worldPos, out float outDensity, out vec3 outTint) {
    float horizontalDist = length(worldPos.xz);
    if (horizontalDist > NETHER_CENTER_FOG_RADIUS) {
        outDensity = 0.0;
        outTint = vec3(0.0);
        return;
    }

    float centerSink = sin(worldTimeCounter * 0.03) * 6.0;
    float centerY = NETHER_CENTER_FOG_BASE_Y + centerSink;

    float layerDensity = 0.0;
    vec3 layerTint = vec3(0.0);
    const int LAYERS = 3;
    for (int i = 0; i < LAYERS; ++i) {
        float offsetY = 0.0;
        float animSpeed = 0.12;
        float animAmp = 6.0;
        if (i == 0) { offsetY = NETHER_CENTER_LAYER1_OFFSET_Y; animSpeed = NETHER_CENTER_LAYER1_ANIM_SPEED; animAmp = NETHER_CENTER_LAYER1_ANIM_AMPLITUDE; }
        if (i == 1) { offsetY = NETHER_CENTER_LAYER2_OFFSET_Y; animSpeed = NETHER_CENTER_LAYER2_ANIM_SPEED; animAmp = NETHER_CENTER_LAYER2_ANIM_AMPLITUDE; }
        if (i == 2) { offsetY = NETHER_CENTER_LAYER3_OFFSET_Y; animSpeed = NETHER_CENTER_LAYER3_ANIM_SPEED; animAmp = NETHER_CENTER_LAYER3_ANIM_AMPLITUDE; }

        float anim = sin(worldTimeCounter * animSpeed + float(i) * 2.1) * animAmp;
        float layerCenterY = centerY + offsetY + anim;

        vec3 rel = worldPos - vec3(0.0, layerCenterY, 0.0);
        float ellipsoidYScale = 1.0;
        vec3 scaled = vec3(rel.x, rel.y * ellipsoidYScale, rel.z);
        float dist = length(scaled);
        float radius = NETHER_CENTER_FOG_RADIUS * 0.9;
        float raw = smoothstep(radius, 0.0, dist);

        float topFade = smoothstep(NETHER_CENTER_FOG_HEIGHT_MAX, NETHER_CENTER_FOG_HEIGHT_MAX - 40.0, worldPos.y);
        float bottomRamp = smoothstep(NETHER_CENTER_FOG_HEIGHT_MIN, NETHER_CENTER_FOG_BOTTOM, worldPos.y);
        float heightFactor = clamp(topFade * bottomRamp, 0.0, 1.0);

        float contribution = raw * heightFactor;

        float lateral = 1.0 - smoothstep(NETHER_CENTER_FOG_RADIUS * 0.6, NETHER_CENTER_FOG_RADIUS, horizontalDist);
        contribution *= lateral;

        float layerBright = NETHER_CENTER_FOG_OVERALL_BRIGHTNESS * (1.0 / float(LAYERS));
        contribution *= layerBright;

        layerDensity += contribution;
        layerTint += vec3(NETHER_CENTER_FOG_DARK_R, NETHER_CENTER_FOG_DARK_G, NETHER_CENTER_FOG_DARK_B) * contribution;
    }

    outDensity = clamp(layerDensity, 0.0, 1.0);
    outTint = clamp(layerTint, vec3(0.0), vec3(1.0));
}

float densityAtPosFog(in vec3 pos) {
    pos /= 18.0;
    pos.xz *= 0.5;
    vec3 p = floor(pos);
    vec3 f = fract(pos);
    f = (f * f) * (3.0 - 2.0 * f);
    vec2 uv = p.xz + f.xz + p.y * vec2(0.0, 193.0);
    vec2 coord = uv / 512.0;
    vec2 xy = texture2D(noisetex, coord).yx;
    return mix(xy.r, xy.g, f.y);
}

	float CalculateNetherFogDensity(in vec3 rayPosition) {
		if (rayPosition.y < 0.0 || rayPosition.y > 128.0) return 0.0;

		float heightFactor = exp2(-abs(rayPosition.y - 64.0) * NETHER_HEIGHT_FALLOFF);
		float biomeDensity = 1.0 + BiomeWarpedForestSmooth * 0.5 + BiomeCrimsonForestSmooth * 0.3 + BiomeSoulSandValleySmooth * 0.4;

		float density;
		if (BiomeBasaltDeltasSmooth > 0.5) {
			vec3 endPos = rayPosition * 0.013;
			endPos += netherFogWind;
			float weight = 0.5;
			float noise = 0.0;
			for (uint i = 0u; i < 5u; i++, weight *= 0.5) {
				noise += weight * Get3DNoiseSmooth(endPos);
				endPos = (endPos + netherFogWind) * 4.0;
			}
			density = saturate(heightFactor * noise * 4e2 - 1.7e2) * 48.0;

			vec3 cloudPatchPos = rayPosition * NETHER_RANDOM_CLOUD_SCALE + netherFogWind * 0.2;
			float cloudPatchNoise = Get3DNoiseSmooth(cloudPatchPos) * 0.5 + Get3DNoiseSmooth(cloudPatchPos * 2.0) * 0.3 + Get3DNoiseSmooth(cloudPatchPos * 4.0) * 0.2;
			float cloudPatch = saturate(cloudPatchNoise - (1.0 - NETHER_RANDOM_CLOUD_FREQUENCY)) * NETHER_RANDOM_CLOUD_DENSITY;
			density += cloudPatch * heightFactor;

            float vortexBounds = clamp(NETHER_VORTEX_BOUNDS_RANGE - length(rayPosition), 0.0, 1.0);
            vec3 samplePos = rayPosition * vec3(1.0, 1.0 / 48.0, 1.0);
            SwirlAroundOrigin(samplePos, rayPosition);
            float vortexNoise = densityAtPosFog(samplePos * 12.0);
            float vortexErosion = 1.0 - densityAtPosFog((samplePos - worldTimeCounter / 20.0) * (124.0 + (1.0 - vortexNoise) * 7.0));
            float vortexDensity = max(exp(vortexNoise * -mix(10.0, 4.0, vortexBounds)) * mix(2.0, 1.0, vortexBounds) - vortexErosion * 0.3, 0.0);
            vortexDensity *= 1.0 + smoothstep(40.0, 50.0, length(rayPosition.xz)) * NETHER_VORTEX_DENSITY_BOOST;
            density += vortexDensity * BRIGHTNESS_VORTEX * BiomeBasaltDeltasSmooth;

            float haloRadiusInner = 30.0, haloRadiusOuter = 70.0;
            float distToCenter = length(rayPosition.xz);
            float haloFactor = smoothstep(haloRadiusInner, haloRadiusOuter, distToCenter);
            haloFactor = 1.0 - haloFactor;
            haloFactor *= smoothstep(80.0, 100.0, rayPosition.y);
            density += haloFactor * BRIGHTNESS_HALO * 0.2 * BiomeBasaltDeltasSmooth;

            float hazeDensity = BRIGHTNESS_HAZE * 0.001 * (0.5 + pow(clamp(normalize(rayPosition).y * 0.5 + 0.5, 0.0, 1.0), 4.0) * 5.0);
            density += hazeDensity * BiomeBasaltDeltasSmooth;

            float centerDensity = 0.0;
            vec3 centerTint = vec3(0.0);
            NetherCenterSphericalFog(rayPosition, centerDensity, centerTint);
            density = max(density * (1.0 - centerDensity * 0.5), 0.0) + centerDensity;

		} else {
			rayPosition *= NETHER_NOISE_SCALE;
			rayPosition += netherFogWind;
			float noise = Get3DNoiseSmooth(rayPosition) * 0.7;
			rayPosition += netherFogWind * 0.3;
			noise += Get3DNoiseSmooth(rayPosition * 4.0) * 0.2;
			rayPosition += netherFogWind * 0.2;
			noise += Get3DNoiseSmooth(rayPosition * 16.0) * 0.1;
			rayPosition += netherFogWind * 0.1;
			noise += Get3DNoiseSmooth(rayPosition * 64.0) * 0.05;

			density = heightFactor * noise * 50.0 - 10.0;
			density *= biomeDensity * NETHER_FOG_DENSITY;

			float distToHotspot = length(rayPosition.xz - cameraPosition.xz) + abs(rayPosition.y - 64.0);
			float dispersionFactor = smoothstep(NETHER_LIGHT_DISPERSION_RADIUS * 0.5, NETHER_LIGHT_DISPERSION_RADIUS, distToHotspot);
			density *= (1.0 - (1.0 - dispersionFactor) * 0.3);

			vec3 localPos = rayPosition * NETHER_MINI_CLOUD_SCALE;
			localPos += netherFogWind * 0.5;
			float miniCloudNoise = Get3DNoiseSmooth(localPos) * 0.6 + Get3DNoiseSmooth(localPos * 2.5) * 0.4;
			float miniCloud = saturate(miniCloudNoise - 0.65) * NETHER_MINI_CLOUD_INTENSITY;
			density += miniCloud * heightFactor * (1.0 + BiomeNetherWastesSmooth * 0.5);

			float cloudAlt = NETHER_CLOUD_ALTITUDE + sin(worldTimeCounter * 0.05 + rayPosition.x * 0.001) * 5.0;
			float cloudDist = abs(rayPosition.y - cloudAlt);
			float cloudLayer = 1.0 - smoothstep(0.0, NETHER_CLOUD_THICKNESS, cloudDist);
			if (cloudLayer > 0.1) {
				vec3 cloudPos = rayPosition * 0.008 + netherFogWind * 0.3;
				float cloudWeight = 0.6;
				float cloudNoise = 0.0;
				for (int j = 0; j < 5; j++) {
					cloudNoise += cloudWeight * Get3DNoiseSmooth(cloudPos);
					cloudPos = cloudPos * 2.0 + netherFogWind * 0.15;
					cloudWeight *= 0.5;
				}
				float cloudShape = saturate(cloudNoise * 1.8 - 0.8);
				cloudShape = pow(cloudShape, 0.6) * NETHER_CLOUD_COVERAGE;
				float cloudDensity = cloudShape * cloudLayer * 1.5;
				density += cloudDensity * (1.0 + BiomeSoulSandValleySmooth * 0.3);
			}

            float vortexBounds = clamp(NETHER_VORTEX_BOUNDS_RANGE - length(rayPosition), 0.0, 1.0);
            vec3 samplePos = rayPosition * vec3(1.0, 1.0 / 48.0, 1.0);
            SwirlAroundOrigin(samplePos, rayPosition);
            float vortexNoise = densityAtPosFog(samplePos * 12.0);
            float vortexErosion = 1.0 - densityAtPosFog((samplePos - worldTimeCounter / 20.0) * (124.0 + (1.0 - vortexNoise) * 7.0));
            float vortexDensity = max(exp(vortexNoise * -mix(10.0, 4.0, vortexBounds)) * mix(2.0, 1.0, vortexBounds) - vortexErosion * 0.3, 0.0);
            vortexDensity *= 1.0 + smoothstep(40.0, 50.0, length(rayPosition.xz)) * NETHER_VORTEX_DENSITY_BOOST;
            density += vortexDensity * BRIGHTNESS_VORTEX * (1.0 - BiomeBasaltDeltasSmooth);

            float haloRadiusInner = 30.0, haloRadiusOuter = 70.0;
            float distToCenter = length(rayPosition.xz);
            float haloFactor = smoothstep(haloRadiusInner, haloRadiusOuter, distToCenter);
            haloFactor = 1.0 - haloFactor;
            haloFactor *= smoothstep(80.0, 100.0, rayPosition.y);
            density += haloFactor * BRIGHTNESS_HALO * 0.2 * (1.0 - BiomeBasaltDeltasSmooth);

            float hazeDensity = BRIGHTNESS_HAZE * 0.001 * (0.5 + pow(clamp(normalize(rayPosition).y * 0.5 + 0.5, 0.0, 1.0), 4.0) * 5.0);
            density += hazeDensity * (1.0 - BiomeBasaltDeltasSmooth);

            float centerDensity = 0.0;
            vec3 centerTint = vec3(0.0);
            NetherCenterSphericalFog(rayPosition, centerDensity, centerTint);
            density = max(density * (1.0 - centerDensity * 0.5), 0.0) + centerDensity;
		}

		return saturate(density);
	}
#endif

#if FOG_TYPE == 0
	float CalculateFogDensity(in vec3 rayPosition) {
		float fogDensity = exp2(min((SEA_LEVEL + 32.0 - rayPosition.y) * rcp(12.0), 0.2));
		return fogDensity * 0.5;
	}
#elif FOG_TYPE == 1
	float CalculateFogDensity(in vec3 rayPosition) {
		float fogDensity = exp2(min((SEA_LEVEL + 28.0 - rayPosition.y) * 0.15, 0.2));

		rayPosition *= 0.06;
		rayPosition += volFogWind;
		float noise = Get3DNoiseSmooth(rayPosition) * 4.0;
		noise -= Get3DNoiseSmooth(rayPosition * 4.0 + volFogWind);

		fogDensity = saturate(noise * 4.0 * fogDensity - 5.0) * 1.4;
		if (BiomeSandstorm < 5e-3) fogDensity = fogDensity * oneMinus(timeNoon) + timeNoon;
		return fogDensity;
	}
#elif FOG_TYPE == 2
 	float CalculateFogDensity(in vec3 rayPosition) {
		float falloff = expf(-abs(rayPosition.y - SEA_LEVEL) * 0.01);

		rayPosition *= 0.04;
		rayPosition += volFogWind;
		float noise = Get3DNoiseSmooth(rayPosition) * 0.5;
			rayPosition += volFogWind;
		noise += Get3DNoiseSmooth(rayPosition * 3.2) * 0.25;
			rayPosition += volFogWind;
		noise += Get3DNoiseSmooth(rayPosition * 9.6) * 0.125;
			rayPosition += volFogWind;
		noise += Get3DNoiseSmooth(rayPosition * 28.8) * 0.0625;

		float fogDensity = saturate(noise * 12.0 * falloff - 4.5);
		return fogDensity * 9.0;
	}
#else
	float CalculateFogDensity(in vec3 rayPosition) {
		float falloff = exp2(-abs(rayPosition.y - SEA_LEVEL) * 0.01);
		rayPosition += volFogWind;
		rayPosition *= 0.013;
		float weight = 0.5;
		float noise = 0.0;

		for (uint i = 0u; i < 5u; i++, weight *= 0.5) {
			noise += weight * Get3DNoiseSmooth(rayPosition);
			rayPosition = (rayPosition + volFogWind) * 4.0;
		}

		float fogDensity = saturate(falloff * noise * 4e2 - 1.7e2);
		return fogDensity * 48.0;
	}
#endif

const int shadowMapResolution = 2048;
const float realShadowMapRes = shadowMapResolution * MC_SHADOW_QUALITY;

// ============================================
// GOD RAYS FUNCTION - ENHANCED (NO CUTOFF)
// ============================================
vec3 CalculateGodRays(
    in vec3 worldPos, 
    in vec3 worldDir, 
    in float sceneDepth,
    in float dither
) {
    #ifndef GODRAYS_ENABLED
        return vec3(0.0);
    #endif

    float sunVisibility = saturate(worldLightVector.y);
    if (sunVisibility < 0.01) return vec3(0.0);

    // ✅ НЕ проверяем если солнце за экраном - лучи все равно работают!
    vec3 sunViewPos = mat3(gbufferModelView) * worldLightVector * 1000.0;
    vec3 sunClipPos = projMAD(gbufferProjection, sunViewPos);
    vec2 sunScreenPos = sunClipPos.xy / sunClipPos.z * 0.5 + 0.5;

    // ✅ УДАЛЕНО: if (sunClipPos.z < 0.0) return vec3(0.0);
    // ✅ Теперь солнце может быть за камерой!
    
    // Clamp в границы экрана для стабильности
    bool sunBehindCamera = sunClipPos.z < 0.0;
    if (sunBehindCamera) {
        // Если солнце за камерой - проецируем его на противоположную сторону
        sunScreenPos = 1.0 - sunScreenPos;
    }


    
    // ✅ Clamp позиции солнца в пределах экрана (но НЕ отключаем лучи)
    sunScreenPos = clamp(sunScreenPos, vec2(0.0), vec2(1.0));

    vec4 viewPos = gbufferProjection * vec4(mat3(gbufferModelView) * worldPos, 1.0);
    vec2 screenPos = viewPos.xy / viewPos.w * 0.5 + 0.5;

    vec2 deltaTexCoord = (sunScreenPos - screenPos);
    float rayDist = length(deltaTexCoord);
    
    // ✅ Adaptive density - больше samples когда солнце далеко от края
    float edgeDistance = min(
        min(sunScreenPos.x, 1.0 - sunScreenPos.x),
        min(sunScreenPos.y, 1.0 - sunScreenPos.y)
    );
    float adaptiveDensity = GODRAY_DENSITY * (1.0 + edgeDistance * 2.0);
    
    deltaTexCoord *= adaptiveDensity / float(GODRAY_SAMPLES);

    vec2 texCoord = screenPos + deltaTexCoord * dither * GODRAY_DITHER_STRENGTH;

    float illuminationDecay = 1.0;
    vec3 godRayColor = vec3(0.0);
    float rayLength = length(worldPos);

    for (int i = 0; i < GODRAY_SAMPLES; ++i) {
        texCoord += deltaTexCoord;
        
        // Wrap around screen edges для эффекта "лучи со всех сторон"
        vec2 wrappedCoord = fract(texCoord);
        
        // ✅ Используем wrapped координаты вместо break
        if (saturate(wrappedCoord) != wrappedCoord) {
            wrappedCoord = saturate(texCoord); // Fallback
        }

        float sampleDepth = texture(depthtex0, wrappedCoord).r;

        
        #ifdef DISTANT_HORIZONS
            float dhDepth = texture(dhDepthTex0, wrappedCoord).r;
            sampleDepth = min(sampleDepth, dhDepth);
        #endif

        float occlusion = step(0.9999, sampleDepth);
        
        vec3 sampleWorldPos = worldDir * (rayLength * float(i) / float(GODRAY_SAMPLES));
        vec3 shadowPos = WorldPosToShadowPos(sampleWorldPos + gbufferModelViewInverse[3].xyz);
        vec2 shadowProjPos = DistortShadowSpace(shadowPos.xy);
        
        float shadowSample = 1.0;
        if (saturate(shadowProjPos) == shadowProjPos) {
            shadowSample = step(shadowPos.z, texture(shadowtex1, shadowProjPos).r);
            
            #ifdef GODRAY_COLOR_BLEEDING
                float translucentShadow = step(shadowPos.z, texture(shadowtex0, shadowProjPos).r);
                if (shadowSample != translucentShadow) {
                    vec3 stainedGlassColor = texture(shadowcolor0, shadowProjPos).rgb;
                    stainedGlassColor = pow(stainedGlassColor, vec3(2.2));
                    shadowSample = mix(shadowSample, 1.0, 0.7);
                    godRayColor += stainedGlassColor * illuminationDecay * occlusion * 0.3;
                }
            #endif
            
            #ifdef CLOUDS_SHADOW
                CloudProperties cloudProps = GetGlobalCloudProperties();
                shadowSample *= CalculateCloudShadow(sampleWorldPos, cloudProps);
            #endif
        }

        vec3 sampleColor = directIlluminance * occlusion * shadowSample;
        sampleColor *= illuminationDecay;
        
        godRayColor += sampleColor;
        illuminationDecay *= GODRAY_DECAY;
    }

    godRayColor *= GODRAY_EXPOSURE * GODRAY_STRENGTH;
    godRayColor *= sunVisibility;
    
    // ✅ Улучшенная phase function с учетом backscattering
    float LdotV = dot(worldDir, worldLightVector);
    float phase = HenyeyGreensteinPhase(LdotV, 0.76) * 0.6 
                + HenyeyGreensteinPhase(LdotV, -0.5) * 0.4  // Больше backscatter
                + HenyeyGreensteinPhase(-LdotV, 0.3) * 0.2; // Дополнительный back scatter
    
    godRayColor *= phase;

    float distance = length(worldPos);
    float atmosphericFade = exp(-distance * 0.00015);
    godRayColor *= atmosphericFade;

    vec3 sunColor = vec3(1.0, 0.95, 0.85);
    if (worldLightVector.y < 0.1) {
        sunColor = mix(vec3(1.0, 0.6, 0.3), sunColor, saturate(worldLightVector.y * 10.0));
    }
    godRayColor *= sunColor;

    // ✅ Улучшенный edge fade - мягче на краях, но не исчезает полностью
    float edgeFade = 1.0 - smoothstep(0.4, 1.2, rayDist);
    edgeFade = max(edgeFade, 0.3); // Минимум 30% интенсивности
    
    // ✅ Дополнительный fade когда солнце за камерой (но не полное отключение)
    edgeFade *= mix(1.0, 0.6, sunBehindCamera); // 60% интенсивности когда солнце сзади
    
    godRayColor *= edgeFade;

    return godRayColor;
}

// ============================================
// MAIN VOLUMETRIC FOG WITH GOD RAYS
// ============================================
vec4 CalculateVolumetricFog(in vec3 worldPos, in vec3 worldDir, in float dither) {	
	#if defined DISTANT_HORIZONS
		#define far float(dhRenderDistance)
		float rayLength = min(far + wetness * 3e-5 * dotSelf(worldPos.xz), length(worldPos));
		uint steps = VOLUMETRIC_FOG_SAMPLES;
	#else
		float rayLength = min(far + wetness * 3e-5 * dotSelf(worldPos.xz), length(worldPos));
		uint steps = uint(VOLUMETRIC_FOG_SAMPLES * 0.4 + rayLength * 0.1);
			 steps = min(steps, VOLUMETRIC_FOG_SAMPLES);
	#endif

	#ifdef IS_NETHER
		rayLength = min(256.0, length(worldPos));
		steps = NETHER_FOG_SAMPLES;
	#endif

	float rSteps = 1.0 / float(steps);

	float stepLength = rayLength * rSteps,
		  transmittance = 1.0,
		  LdotV = dot(worldLightVector, worldDir),
		  LdotV01 = LdotV * 0.5 + 0.5,
		  skylightSample = 0.0;

	float mistDensity = VOLUMETRIC_FOG_DENSITY * volFogDensity;
	#if FOG_TYPE > 1
		float phases1 = (HenyeyGreensteinPhase(LdotV, 0.6) + HenyeyGreensteinPhase(LdotV, -0.3)) * 0.5,
			  phases2 = (HenyeyGreensteinPhase(LdotV * 0.5, 0.6) + HenyeyGreensteinPhase(LdotV * 0.5, -0.3)) * 0.25,
			  phases3 = (HenyeyGreensteinPhase(LdotV * 0.25, 0.6) + HenyeyGreensteinPhase(LdotV * 0.25, -0.3)) * 0.125,
			  phases4 = (HenyeyGreensteinPhase(LdotV * 0.125, 0.6) + HenyeyGreensteinPhase(LdotV * 0.125, -0.3)) * 0.0625;
	#else
		mistDensity *= CornetteShanksPhase(LdotV, 0.7 - wetness * 0.3) * 0.45 + HenyeyGreensteinPhase(LdotV, -0.3) * 0.15 + 0.1;
	#endif
	#ifdef VOLUMETRIC_LIGHT
		float airDensity = VOLUMETRIC_LIGHT_STRENGTH + wetness * BiomeSandstorm;
		airDensity *= RayleighPhase(LdotV) * (4.0 / far);
	#else
		float airDensity = 0.0;
	#endif

	vec3 rayStep = worldDir * stepLength,
		 rayPosition = rayStep * dither + gbufferModelViewInverse[3].xyz + cameraPosition;

	vec3 shadowStart = WorldPosToShadowPos(gbufferModelViewInverse[3].xyz),
		 shadowEnd = WorldPosToShadowPos(rayStep + gbufferModelViewInverse[3].xyz);

	vec3 shadowStep = shadowEnd - shadowStart,
		 shadowPosition = shadowStep * dither + shadowStart;
	vec3 sunlightSample = vec3(0.0);

	#ifdef TIME_FADE
		stepLength *= max(sqr(meWeight + 0.05) + timeMidnight * 2.0, wetness);
	#endif

	stepLength *= eyeSkylightFix;

	#ifdef CLOUDS_SHADOW
		CloudProperties cloudProperties = GetGlobalCloudProperties();
	#endif

	uint i = 0u;
	while (++i < steps) {
		rayPosition += rayStep, shadowPosition += shadowStep;

		#ifdef IS_NETHER
			if (rayPosition.y > 128.0) continue;
		#else
			if (rayPosition.y > 384.0) continue;
		#endif

		vec2 shadowProjPos = DistortShadowSpace(shadowPosition.xy);
		ivec2 shadowTexel = ivec2(shadowProjPos * realShadowMapRes);

		float fogDensity = airDensity;
		#ifdef VOLUMETRIC_FOG
			#ifdef IS_NETHER
				float density = CalculateNetherFogDensity(rayPosition);
			#else
				float density = CalculateFogDensity(rayPosition) * mistDensity;
			#endif
			fogDensity += density;
		#endif

		if (fogDensity < 1e-5) continue;
		fogDensity *= stepLength;

		vec3 shadow = vec3(1.0);
		if (saturate(shadowProjPos) == shadowProjPos) {
			shadow = step(shadowPosition.z, vec3(texelFetch(shadowtex1, shadowTexel, 0).x));

			#ifdef RAY_STAINED_GLASS_TINT
				float translucentShadow = step(shadowPosition.z, texelFetch(shadowtex0, shadowTexel, 0).x);
				if (shadow.x != translucentShadow) {
					vec3 shadowColorSample = pow4(texelFetch(shadowcolor0, shadowTexel, 0).rgb);
					shadow = shadowColorSample * (shadow - translucentShadow) + vec3(translucentShadow);
				}
			#endif
		}

		#if defined VOLUMETRIC_FOG && FOG_TYPE > 1
			if (density > 1e-5) {
				float stepSize = 5.0, sunlightOD = 0.0;
				vec3 checkPos = rayPosition;
				for (uint i = 0u; i < 4u; ++i, checkPos += worldLightVector * stepSize) {
					float density = CalculateFogDensity(checkPos);
					if (density < 1e-5) continue;
					sunlightOD += density * stepSize;
					stepSize *= 1.5;
				}
				sunlightOD *= mistDensity;
				float scatteringSun = oneMinus(expf(-sunlightOD * 2.0)) * oneMinus(LdotV01) + LdotV01;
				scatteringSun *= expf(-sunlightOD * 2.4) * phases1
							+ expf(-sunlightOD * 1.2) * phases2
							+ expf(-sunlightOD * 0.6) * phases3
							+ expf(-sunlightOD * 0.3) * phases4;
				shadow *= (scatteringSun + airDensity) * FOG_TYPE * FOG_TYPE;

                #ifdef IS_NETHER
                    float distToCenter = length(rayPosition.xz);
                    vec3 netherTint = NetherFogColor();

                    float vortexFactor = smoothstep(40.0, 50.0, distToCenter) * BRIGHTNESS_VORTEX;
                    vec3 vortexTint = vec3(NETHER_VORTEX_COLOR_R, NETHER_VORTEX_COLOR_G, NETHER_VORTEX_COLOR_B) * vortexFactor * netherTint;

                    float haloRadiusInner = 30.0, haloRadiusOuter = 70.0;
                    float haloFactor = smoothstep(haloRadiusInner, haloRadiusOuter, distToCenter);
                    haloFactor = 1.0 - haloFactor;
                    haloFactor *= smoothstep(80.0, 100.0, rayPosition.y);
                    vec3 haloTint = vec3(NETHER_HALO_COLOR_R, NETHER_HALO_COLOR_G, NETHER_HALO_COLOR_B) * haloFactor * BRIGHTNESS_HALO * netherTint;

                    vec3 hazeLighting = vec3(NETHER_HAZE_COLOR_R, NETHER_HAZE_COLOR_G, NETHER_HAZE_COLOR_B) * (0.5 + pow(clamp(normalize(rayPosition).y * 0.5 + 0.5, 0.0, 1.0), 4.0) * 5.0) * BRIGHTNESS_HAZE * netherTint;

                    float cd = 0.0; vec3 ct = vec3(0.0);
                    NetherCenterSphericalFog(rayPosition, cd, ct);
                    vec3 centerTintBlend = ct * cd * 8.0 * netherTint;

                    shadow += vortexTint + haloTint + hazeLighting + centerTintBlend;
                #endif
			}
			float stepTransmittance = expf(-fogDensity);
		#else
			float stepTransmittance = expf(-fogDensity * (1.0 + BiomeSandstorm * wetness));
		#endif

		float powder = 1.0 - expf(-fogDensity * 3.0);
		powder = powder * oneMinus(LdotV01) + LdotV01;
		float fogSample = powder * transmittance * oneMinus(stepTransmittance);

		#ifdef CLOUDS_SHADOW
			float cloudShadow = CalculateCloudShadow(rayPosition, cloudProperties);
			shadow *= cloudShadow;
		#endif

		sunlightSample += shadow * fogSample * FOG_LIGHT_STRENGTH;
		skylightSample += fogSample;

		transmittance *= stepTransmittance;

		if (transmittance < 1e-3) break;
	}

	vec3 fogSunColor = directIlluminance * sunlightSample * SUNLIGHT_INTENSITY;
	vec3 fogSkyColor = skyIlluminance * skylightSample;

	#ifdef IS_NETHER
		vec3 netherTint = NetherFogColor() * 1.5;
		fogSunColor *= netherTint;
		fogSkyColor *= netherTint;
	#endif

	vec3 fogColor = fogSunColor * 20.0 * FOG_LIGHT_STRENGTH + fogSkyColor * 2.0;

	if (isLightningFlashing > 1e-2) fogColor += sqr(skylightSample) * 2.0 * lightningColor;

	if (BiomeSandstorm + BiomeGreenShift > 5e-3) {
		fogColor *= oneMinus(BiomeSandstorm) + vec3(0.42, 0.39, 0.21) * BiomeSandstorm;
		fogColor *= oneMinus(BiomeGreenShift) + vec3(0.7, 1.0, 0.74) * BiomeGreenShift;
	}

	fogColor *= oneMinus(0.8 * wetness);

	// ✅ ADD GOD RAYS
	#ifdef GODRAYS_ENABLED
		vec3 godRays = CalculateGodRays(worldPos, worldDir, length(worldPos), dither);
		fogColor += godRays * (1.0 - transmittance * 0.5);
	#endif

	return vec4(fogColor, transmittance);
}

//------------------------------------------------------------------------------------------------//

vec3 UnderwaterVolumetricLight(in vec3 worldPos, in vec3 worldDir, in float dither) {
	float rayLength = min(24.0, length(worldPos));

	uint steps = uint(12.0 + 0.5 * rayLength);
	     steps = min(steps, 22u);

	float rSteps = 1.0 / float(steps);

	float stepLength = rayLength * rSteps;

	vec3 shadowStart = WorldPosToShadowPos(gbufferModelViewInverse[3].xyz),
		 shadowEnd = WorldPosToShadowPos(worldDir * stepLength + gbufferModelViewInverse[3].xyz);

	vec3 shadowStep = shadowEnd - shadowStart,
		 shadowPosition = shadowStep * dither + shadowStart;

	const vec3 coeff = waterAbsorption + 0.02;
	vec3 stepTransmittance = expf(-coeff * stepLength);
	vec3 transmittance = vec3(1.0);

	vec3 scattering = vec3(0.0);

	uint i = 0u;
	while (++i < steps) {
		shadowPosition += shadowStep;

		vec2 shadowProjPos = DistortShadowSpace(shadowPosition.xy);
		if (saturate(shadowProjPos) != shadowProjPos) continue;
		ivec2 shadowTexel = ivec2(shadowProjPos * realShadowMapRes);
	
		float translucentShadow = step(shadowPosition.z, texelFetch(shadowtex0, shadowTexel, 0).x);
		vec3 sampleShadow = vec3(1.0);

		if (translucentShadow < 1.0) {
			sampleShadow = step(shadowPosition.z, texelFetch(shadowtex1, shadowTexel, 0).xxx);

			if (sampleShadow.x != translucentShadow) {
				float waterDepth = abs(texelFetch(shadowcolor1, shadowTexel, 0).w * 512.0 - 128.0 - shadowPosition.y - eyeAltitude);
				if (waterDepth > 0.1) {
					sampleShadow = sqr(cube(texelFetch(shadowcolor0, shadowTexel, 0).rgb));
				} else {
					vec3 shadowColorSample = pow4(texelFetch(shadowcolor0, shadowTexel, 0).rgb);
					sampleShadow = shadowColorSample * (sampleShadow - translucentShadow) + vec3(translucentShadow);
				}

				sampleShadow *= expf(-coeff * 0.4 * max(waterDepth, 8.0));
			}
		}

		scattering += sampleShadow * transmittance * oneMinus(stepTransmittance);

		transmittance *= stepTransmittance;
	}

	vec3 lightVector = refract(worldLightVector, vec3(0.0, -1.0, 0.0), 1.0 / WATER_REFRACT_IOR);
	float LdotV = dot(lightVector, worldDir);
	float phase = HenyeyGreensteinPhase(LdotV, 0.8) + HenyeyGreensteinPhase(LdotV, 0.6);

	vec3 fogColor = 8.0 / coeff * directIlluminance * oneMinus(0.95 * wetness);
	fogColor *= scattering * phase * UW_VOLUMETRIC_LIGHT_STRENGTH;

	return fogColor * SUNLIGHT_INTENSITY;
}