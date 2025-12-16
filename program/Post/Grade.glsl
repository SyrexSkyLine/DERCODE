#include "/lib/Head/Common.inc"
#include "/lib/Head/Uniforms.inc"

#if DIRT_STYLE > 0
    #if DIRT_STYLE == 1
        uniform sampler2D colortex8;  // astralex
        #define DIRTY_LENS_SAMPLER colortex8
    #elif DIRT_STYLE == 2
        uniform sampler2D colortex10; // bodycam
        #define DIRTY_LENS_SAMPLER colortex10
    #elif DIRT_STYLE == 3
        uniform sampler2D colortex11; // big
        #define DIRTY_LENS_SAMPLER colortex11
    #elif DIRT_STYLE == 4
        uniform sampler2D colortex12; // blink
        #define DIRTY_LENS_SAMPLER colortex12
    #endif
#endif

//--// Internal Settings //---------------------------------------------------//

/*
	const int 	colortex0Format 			= RGBA16F;
	const int 	colortex1Format 			= RGBA16F;
	const int 	colortex2Format 			= RGBA16F;
	const int 	colortex3Format 			= RGBA16;
	const int 	colortex4Format 			= R11F_G11F_B10F;
	const int 	colortex5Format 			= RGBA16F;
	const int 	colortex6Format 			= RGB8;
	const int 	colortex7Format 			= RGB8;

	const bool	colortex0Clear				= false;
	const bool	colortex1Clear				= false;
	const bool	colortex2Clear				= false;
	const bool	colortex4Clear				= false;
	const bool  colortex5Clear				= false;
	const bool 	colortex7Clear				= true;

	const float shadowIntervalSize 			= 2.0;
	const float ambientOcclusionLevel 		= 0.05f;
	const float	sunPathRotation				= -35.0;
	const float eyeBrightnessHalflife 		= 10.0;
	const float wetnessHalflife				= 180.0;
	const float drynessHalflife				= 60.0;
	const bool 	shadowHardwareFiltering1 	= true;
*/

#ifdef PARALLAX
/*
	const int 	colortex7Format 			= RGBA8;
*/
#endif

//----------------------------------------------------------------------------//

//#define PURKINJE_SHIFT

#if !defined IS_OVERWORLD
	#undef PURKINJE_SHIFT
#endif

#define TONEMAP AcademyFit // [AcademyCustom AcademyFit AgX_Minimal AgX_Full]

//#define CINEMATIC_EFFECT

//#define COLOR_GRADING
#define BRIGHTNESS 		1.0  // [0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 2.5 3.0]
#define GAMMA 			1.0  // [0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 2.5 3.0]
#define CONTRAST		0.8  // [0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 2.5 3.0]
#define SATURATION 		1.0  // [0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 2.5 3.0]
#define WHITE_BALANCE	6500 // [2500 3000 3500 4000 4100 4200 4300 4400 4500 4600 4700 4800 4900 5000 5100 5200 5300 5400 5500 5600 5700 5800 5900 6000 6100 6200 6300 6400 6500 6600 6700 6800 6900 7000 7100 7200 7300 7400 7500 7600 7700 7800 7900 8000 8100 8200 8300 8400 8500 8600 8700 8800 8900 9000 9100 9200 9300 9400 9500 9600 9700 9800 9900 10000 10100 10200 10300 10400 10500 10600 10700 10800 10900 11000 11100 11200 11300 11400 11500 11600 11700 11800 11900 12000]

//#define VIGNETTE_ENABLED
#define VIGNETTE_STRENGTH 1.0 // [0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 2.5 3.0 3.5 4.0 5.0]

// ==== НАСТРОЙКИ ДОПОЛНИТЕЛЬНОГО МЯГКОГО БЛУМА (SEUS PTGI STYLE) ====
//#define SOFT_BLOOM_ENABLED




//#define DEBUG_COUNTER

//----------------------------------------------------------------------------//

out vec3 sceneColor;

/* DRAWBUFFERS:3 */

in vec2 screenCoord;

//----// FUNCTIONS //-----------------------------------------------------------------------------//

float ScreenToViewSpace(in float depth) {
    depth = depth * 2.0 - 1.0;
    return 1.0 / (depth * gbufferProjectionInverse[2][3] + gbufferProjectionInverse[3][3]);
}

vec2 CalculateTileOffset(int lod) {
	vec2 lodMult = floor(lod * 0.5 + vec2(0.0, 0.5));
	vec2 offset = vec2(1.0 / 3.0, 2.0 / 3.0) * (1.0 - exp2(-2.0 * lodMult));

	return lodMult * 16.0 * screenPixelSize + offset;
}

vec3 DualBlurUpSample(in sampler2D tex, in int lod) {
    float scale = exp2(-lod);
    vec2 coord = screenCoord * scale + CalculateTileOffset(lod - 1);

    return textureBicubic(tex, coord).rgb;
}

#ifdef SOFT_BLOOM_ENABLED
vec3 CalculateSoftBloom(in sampler2D tex, in int baseLod) {
	vec3 softBloom = vec3(0.0);
	float totalWeight = 0.0;
	
	// SEUS PTGI стиль: используем большой радиус и плавное затухание
	// Берём несколько LOD уровней с экспоненциальным весом
	
	#if SOFT_BLOOM_QUALITY >= 1
		float weight1 = 1.0;
		softBloom += DualBlurUpSample(tex, baseLod + 1) * weight1;
		totalWeight += weight1;
	#endif
	
	#if SOFT_BLOOM_QUALITY >= 2
		float weight2 = 1.2;
		softBloom += DualBlurUpSample(tex, baseLod + 2) * weight2;
		totalWeight += weight2;
	#endif
	
	#if SOFT_BLOOM_QUALITY >= 3
		float weight3 = 1.5;
		softBloom += DualBlurUpSample(tex, baseLod + 3) * weight3;
		totalWeight += weight3;
	#endif
	
	#if SOFT_BLOOM_QUALITY >= 4
		float weight4 = 1.8;
		softBloom += DualBlurUpSample(tex, baseLod + 4) * weight4;
		totalWeight += weight4;
	#endif
	
	#if SOFT_BLOOM_QUALITY >= 5
		float weight5 = 2.0;
		softBloom += DualBlurUpSample(tex, baseLod + 5) * weight5;
		totalWeight += weight5;
	#endif
	
	// Нормализация с учётом радиуса
	softBloom /= totalWeight;
	
	// Применяем силу блума и радиус
	return softBloom * SOFT_BLOOM_AMOUNT * (SOFT_BLOOM_RADIUS * 0.5);
}
#endif

void CalculateBloomFog(inout vec3 color, in ivec2 texel) {
	vec3 sampleTile = vec3(0.0);
	vec3 bloomData = vec3(0.0);
	vec3 fogBloom = vec3(0.0);

	sampleTile = DualBlurUpSample(colortex4, 1);
	bloomData += sampleTile;
	fogBloom += sampleTile;

	sampleTile = DualBlurUpSample(colortex4, 2);
	bloomData += sampleTile * 0.83333333;
	fogBloom += sampleTile * 1.5;

	sampleTile = DualBlurUpSample(colortex4, 3);
	bloomData += sampleTile * 0.69444444;
	fogBloom += sampleTile * 2.25;

	sampleTile = DualBlurUpSample(colortex4, 4);
	bloomData += sampleTile * 0.57870370;
	fogBloom += sampleTile * 3.375;

	sampleTile = DualBlurUpSample(colortex4, 5);
	bloomData += sampleTile * 0.48225309;
	fogBloom += sampleTile * 5.0625;

	sampleTile = DualBlurUpSample(colortex4, 6);
	bloomData += sampleTile * 0.40187757;
	fogBloom += sampleTile * 7.59375;

	sampleTile = DualBlurUpSample(colortex4, 7);
	bloomData += sampleTile * 0.33489798;
	fogBloom += sampleTile * 11.328125;

	bloomData *= 0.23118661;
	fogBloom *= 0.03108305;

	// ==== ДОПОЛНИТЕЛЬНЫЙ МЯГКИЙ БЛУМ (SEUS PTGI STYLE) ====
	#ifdef SOFT_BLOOM_ENABLED
		vec3 softBloom = CalculateSoftBloom(colortex4, 2);
		
		// Смешиваем мягкий блум с основным более агрессивно
		bloomData = mix(bloomData, softBloom, 0.7);
		
		// Добавляем дополнительный слой для свечения
		bloomData += softBloom * 0.3;
	#endif

	// ==== DIRTY LENS (ПРИМЕНЯЕМ ПОСЛЕ СМЕШИВАНИЯ) ====
#if DIRT_STYLE > 0
    float newAspectRatio = 1.777777777777778 / aspectRatio;
    vec2 scale = vec2(max(newAspectRatio, 1.0), max(1.0 / newAspectRatio, 1.0));
    vec2 dirtCoord = (screenCoord - 0.5) / scale + 0.5;

    float dirt = texture2D(DIRTY_LENS_SAMPLER, dirtCoord).r;

    float brightness = length(bloomData / (1.0 + bloomData));
    dirt *= brightness * DIRTY_LENS_STRENGTH;

    // Усиление bloom через грязь
    #ifdef DIRTY_LENS_BLOOM_BOOST
        bloomData *= (dirt * DIRTY_LENS_BLOOM_STRENGTH + 1.0);
        fogBloom  *= (dirt * (DIRTY_LENS_BLOOM_STRENGTH * 0.5) + 1.0);
    #else
        bloomData *= (dirt * 16.0 + 1.0);
        fogBloom  *= (dirt * 8.0 + 1.0);
    #endif
#endif

	fogBloom += bloomData;

	#ifdef BLOOMY_FOG
		float fogTransmittance = texelFetch(colortex6, texel, 0).x;
		color = mix(fogBloom * 0.5, color, fogTransmittance);
	#endif

	float bloomAmount = BLOOM_AMOUNT * 0.15;

	float exposure = texelFetch(colortex5, ivec2(0), 0).a;
	bloomAmount /= fma(max(exposure, 1.0), 0.7, 0.3);

	color += bloomData * bloomAmount;
	
	#if !defined IS_NETHER
		if (isEyeInWater == 0 && wetness > 1e-2) {
			float rain = texelFetch(colortex0, texel, 0).b * 0.35;
			fogBloom *= 1.0 + weatherSnowySmooth * 2.0;
			color = color * oneMinus(rain) + fogBloom * fma(clamp(exposure, 0.6, 2.0), 0.15, 0.3) * rain;
		}
	#endif
}

const mat3 rgbToXyz = mat3(
	vec3(0.4124564, 0.3575761, 0.1804375),
	vec3(0.2126729, 0.7151522, 0.0721750),
	vec3(0.0193339, 0.1191920, 0.9503041)
);

const mat3 xyzToRgb = mat3(
	vec3(3.2409699419, 	-1.5373831776, -0.4986107603),
	vec3(-0.9692436363,  1.8759675015,  0.0415550574),
	vec3(0.0556300797, 	-0.2039769589,  1.0569715142)
);

#ifdef PURKINJE_SHIFT
	vec3 PurkinjeShift(in vec3 color) {
		const vec3 rodResponse = vec3(7.15e-5, 4.81e-1, 3.28e-1);
		vec3 xyz = color * rgbToXyz;

		vec3 scotopicLuminance = max0(xyz * (1.33 * (1.0 + (xyz.y + xyz.z) / xyz.x) - 1.68));

		float purkinje = dot(rodResponse, scotopicLuminance * xyzToRgb);
		return mix(color, purkinje * vec3(0.5, 0.7, 1.0), expf(-purkinje * 90.0));
	}
#endif

#if defined COLOR_GRADING && WHITE_BALANCE != 6500
	mat3 ChromaticAdaptationMatrix(vec3 srcXyz, vec3 dstXyz) {
		const mat3 bradfordConeResponse = mat3(
			0.89510, -0.75020,  0.03890,
			0.26640,  1.71350, -0.06850,
			-0.16140,  0.03670,  1.02960
		);

		vec3 srcLms = srcXyz * bradfordConeResponse;
		vec3 dstLms = dstXyz * bradfordConeResponse;
		vec3 quotient = dstLms / srcLms;

		mat3 vonKries = mat3(
			quotient.x, 0.0, 0.0,
			0.0, quotient.y, 0.0,
			0.0, 0.0, quotient.z
		);

		return (bradfordConeResponse * vonKries) * inverse(bradfordConeResponse);
	}

	mat3 WhiteBalanceMatrix() {
		vec3 srcXyz = Blackbody(float(WHITE_BALANCE)) * rgbToXyz;
		vec3 dstXyz = Blackbody(6500.0) 			  * rgbToXyz;

		return rgbToXyz * ChromaticAdaptationMatrix(srcXyz, dstXyz) * xyzToRgb;
	}
#endif

vec3 Contrast(in vec3 color) {
	const float logMidpoint = log2(0.16);
	color = log2(color + 1e-6) - logMidpoint;
	return max0(exp2(color * CONTRAST + logMidpoint) - 1e-6);
}

#include "/lib/Post/ACES.glsl"
#include "/lib/Post/AgX.glsl"

#ifdef DEBUG_COUNTER
	#include "/lib/Post/PrintFloat.glsl"
#endif

//----// MAIN //----------------------------------------------------------------------------------//
void main() {
	ivec2 texel = ivec2(gl_FragCoord.xy);
	#ifdef MOTION_BLUR
		vec3 color = texelFetch(colortex2, texel, 0).rgb;
	#else
		vec3 color = texelFetch(colortex5, texel, 0).rgb;
	#endif

	#ifdef BLOOM_ENABLED
		CalculateBloomFog(color, texel);
	#endif

	#ifdef PURKINJE_SHIFT
		color = PurkinjeShift(color);
	#endif

	color *= texelFetch(colortex5, ivec2(0), 0).a; // Exposure

	#ifdef VIGNETTE_ENABLED
		color *= expf(-2.0 * dotSelf(screenCoord - 0.5) * VIGNETTE_STRENGTH);
	#endif

	color = TONEMAP(color);

	#ifdef CINEMATIC_EFFECT
		color *= step(abs(screenCoord.y - 0.5) * 2.0, aspectRatio * (9.0 / 21.0)); // 21:9
	#endif

	#ifdef DEBUG_COUNTER
		const float scale = 5.0, size = 1.0 / scale;
		vec2 tCoord = gl_FragCoord.xy * size;

		if (clamp(tCoord, vec2(0.0, 25.0), vec2(40.0, 50.0)) == tCoord) {
			color = min(color * 0.5, 0.8);
		}

		color += PrintFloat(shadowProjection[0].x, vec2(10.0, 35.0) * scale, size);
	#endif

	sceneColor = saturate(color);
}