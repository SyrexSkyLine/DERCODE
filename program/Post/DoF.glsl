
out vec3 sceneData;

/* DRAWBUFFERS:4 */

#include "/lib/Head/Common.inc"
#include "/lib/Head/Uniforms.inc"

#define DOF_CHROMA_DISPERSION

#define DOF_SAMPLES 48 // [8 16 24 32 36 48 56 64 128 256 512 1024]
#define DOF_INTENSITY 0.02 // [0.0 0.001 0.0015 0.002 0.003 0.005 0.007 0.01 0.015 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0]
#define DOF_ANAMORPHIC_RATIO 1.0 // [0.3 0.4 0.5 0.6 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5]

#define FOCUS_MODE 0 // [0 1]
#define MANUAL_FOCUS 5.0 // [0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.8 1.0 1.2 1.4 1.6 1.8 2.0 2.3 2.6 2.9 3.2 3.5 4.0 4.5 5.0 5.5 6.0 6.5 7.0 7.5 8.0 8.5 9.0 9.5 10.0 11.0 12.0 13.0 14.0 15.0 16.0 18.0 20.0 22.0 24.0 27.0 30.0 35.0 40.0 45.0 50.0 55.0 60.0 65.0 70.0 80.0 90.0 100.0]

#define CAMERA_APERTURE 2.8 // [0.8 1.0 1.2 1.4 1.8 2.8 4 5.6 8.0 9.6 11.0 16.0 22.0 32.0 44.0]

//#if FOCUS_MODE == 0
//    uniform float centerDepthSmooth;
//#endif

//----// FUNCTIONS //-----------------------------------------------------------------------------//

#include "/lib/Head/Functions.inc"

float CalculateCoC(float p, float z, float a, float f) {
    //return a * (f * (p - z)) / (p * (z - f));
    return oneMinus(p / z) * a * f * rcp(p - f);
}

//----// MAIN //----------------------------------------------------------------------------------//
void main() {
	ivec2 texel = ivec2(gl_FragCoord.xy);
	vec2 screenCoord = gl_FragCoord.xy * screenPixelSize;

	float depth = texelFetch(depthtex1, texel, 0).x;
	if (depth < 0.56) {
		sceneData = texelFetch(colortex4, texel, 0).rgb;
		return;
	}

    #if FOCUS_MODE == 0
        //float focus = centerDepthSmooth;
        float focusDist = texelFetch(colortex5, ivec2(1), 0).a;
    #else
        float focus = far * (MANUAL_FOCUS - near) / ((far - near) * MANUAL_FOCUS);
        float focusDist = GetDepthLinear(focus);
    #endif

    const float focalLength = 0.5 * 0.035 * gbufferProjection[1][1];
    const float aperture = focalLength / CAMERA_APERTURE;

    float dist = GetDepthLinear(depth);
    // float focusDist = GetDepthLinear(focus);

	vec2 CoC = CalculateCoC(focusDist, dist, aperture, focalLength) * vec2(DOF_ANAMORPHIC_RATIO, aspectRatio);
	CoC *= screenSize * DOF_INTENSITY * 1e3 * TAU;
	const float goldenAngle = TAU / (PHI1 + 1.0);
	const mat2 goldenRotate = mat2(cos(goldenAngle), -sin(goldenAngle), sin(goldenAngle), cos(goldenAngle));

	float noise = BlueNoiseTemporal();
	vec2 rot = cossin(noise * TAU) * CoC;

    sceneData = vec3(0.0);
	const float rSteps = 1.0 / DOF_SAMPLES;

    #ifdef DOF_CHROMA_DISPERSION
    	// ivec2 chromaOffset = ivec2(dotSelf(screenCoord - 0.5) * 2.0);
    	ivec2 chromaOffset = ivec2(normalize(screenCoord - 0.5) * 0.5 * CoC);
    #endif

    for (uint i = 0u; i < DOF_SAMPLES; ++i, rot *= goldenRotate) {
		vec2 sampleOffset = rot * sqrt((noise + i) * rSteps);

        #ifdef DOF_CHROMA_DISPERSION
			ivec2 sampleCoord = texel + ivec2(sampleOffset);
        	sceneData.r += texelFetch(colortex4, sampleCoord + chromaOffset, 0).r;
        	sceneData.g += texelFetch(colortex4, sampleCoord, 0).g;
        	sceneData.b += texelFetch(colortex4, sampleCoord - chromaOffset, 0).b;
		#else
        	sceneData += texelFetch(colortex4, texel + ivec2(sampleOffset), 0).rgb;
        #endif
    }

    sceneData *= rSteps;
}
