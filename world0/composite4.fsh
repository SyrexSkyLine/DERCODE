#version 450 compatibility

#include "/Settings.glsl"
#include "/program/Post/DownSample0.glsl"


in vec2 TexCoords;
uniform sampler2D colortex0;
uniform sampler2D colortex8;
uniform float viewWidth, viewHeight;
uniform vec3 cameraPosition, previousCameraPosition;
uniform mat4 gbufferPreviousProjection, gbufferProjectionInverse;
uniform mat4 gbufferPreviousModelView, gbufferModelViewInverse;
uniform sampler2D depthtex1;
uniform float frameCounter;

vec2 finalUv;

#if ANTI_ALIASING == 1
const float edgeThresholdMin = 0.03125;
const float edgeThresholdMax = 0.125;
const float subpixelQuality = 0.75;
const int iterations = 12;
const float quality[12] = float[12] (1.0, 1.0, 1.0, 1.0, 1.0, 1.5, 2.0, 2.0, 2.0, 2.0, 4.0, 8.0);

float GetLuminance(vec3 color)
{
    return dot(color, vec3(0.299, 0.587, 0.114));
}

void FXAA311(inout vec3 color)
{
    vec2 view = 1.0 / vec2(viewWidth, viewHeight);
    float lumaCenter = GetLuminance(color);
    ivec2 texelCoord = ivec2(gl_FragCoord.xy);

    float lumaDown  = GetLuminance(texelFetch(colortex0, texelCoord + ivec2( 0, -1), 0).rgb);
    float lumaUp    = GetLuminance(texelFetch(colortex0, texelCoord + ivec2( 0,  1), 0).rgb);
    float lumaLeft  = GetLuminance(texelFetch(colortex0, texelCoord + ivec2(-1,  0), 0).rgb);
    float lumaRight = GetLuminance(texelFetch(colortex0, texelCoord + ivec2( 1,  0), 0).rgb);

    float lumaMin = min(lumaCenter, min(min(lumaDown, lumaUp), min(lumaLeft, lumaRight)));
    float lumaMax = max(lumaCenter, max(max(lumaDown, lumaUp), max(lumaLeft, lumaRight)));
    float lumaRange = lumaMax - lumaMin;

    if (lumaRange > max(edgeThresholdMin, lumaMax * edgeThresholdMax))
    {
        float lumaDownLeft  = GetLuminance(texelFetch(colortex0, texelCoord + ivec2(-1, -1), 0).rgb);
        float lumaUpRight   = GetLuminance(texelFetch(colortex0, texelCoord + ivec2( 1,  1), 0).rgb);
        float lumaUpLeft    = GetLuminance(texelFetch(colortex0, texelCoord + ivec2(-1,  1), 0).rgb);
        float lumaDownRight = GetLuminance(texelFetch(colortex0, texelCoord + ivec2( 1, -1), 0).rgb);

        float lumaDownUp    = lumaDown + lumaUp;
        float lumaLeftRight = lumaLeft + lumaRight;

        float lumaLeftCorners  = lumaDownLeft  + lumaUpLeft;
        float lumaDownCorners  = lumaDownLeft  + lumaDownRight;
        float lumaRightCorners = lumaDownRight + lumaUpRight;
        float lumaUpCorners    = lumaUpRight   + lumaUpLeft;

        float edgeHorizontal = abs(-2.0 * lumaLeft   + lumaLeftCorners ) +
                               abs(-2.0 * lumaCenter + lumaDownUp      ) * 2.0 +
                               abs(-2.0 * lumaRight  + lumaRightCorners);
        float edgeVertical   = abs(-2.0 * lumaUp     + lumaUpCorners   ) +
                               abs(-2.0 * lumaCenter + lumaLeftRight   ) * 2.0 +
                               abs(-2.0 * lumaDown   + lumaDownCorners );

        bool isHorizontal = (edgeHorizontal >= edgeVertical);

        float luma1 = isHorizontal ? lumaDown : lumaLeft;
        float luma2 = isHorizontal ? lumaUp : lumaRight;
        float gradient1 = luma1 - lumaCenter;
        float gradient2 = luma2 - lumaCenter;

        bool is1Steepest = abs(gradient1) >= abs(gradient2);
        float gradientScaled = 0.25 * max(abs(gradient1), abs(gradient2));

        float stepLength = isHorizontal ? view.y : view.x;

        float lumaLocalAverage = 0.0;

        if (is1Steepest)
        {
            stepLength = - stepLength;
            lumaLocalAverage = 0.5 * (luma1 + lumaCenter);
        }
        else
        {
            lumaLocalAverage = 0.5 * (luma2 + lumaCenter);
        }

        vec2 currentUv = TexCoords;
        if (isHorizontal)
        {
            currentUv.y += stepLength * 0.5;
        }
        else
        {
            currentUv.x += stepLength * 0.5;
        }

        vec2 offset = isHorizontal ? vec2(view.x, 0.0) : vec2(0.0, view.y);

        vec2 uv1 = currentUv - offset;
        vec2 uv2 = currentUv + offset;

        float lumaEnd1 = GetLuminance(texture(colortex0, uv1).rgb);
        float lumaEnd2 = GetLuminance(texture(colortex0, uv2).rgb);
            
        lumaEnd1 -= lumaLocalAverage;
        lumaEnd2 -= lumaLocalAverage;

        bool reached1 = abs(lumaEnd1) >= gradientScaled;
        bool reached2 = abs(lumaEnd2) >= gradientScaled;
        bool reachedBoth = reached1 && reached2;

        if (!reached1)
        {
            uv1 -= offset;
        }
        if (!reached2)
        {
            uv2 += offset;
        }

        if (!reachedBoth)
        {
            for (int i = 2; i < iterations; i++)
            {
                if (!reached1)
                {
                    lumaEnd1 = GetLuminance(texture(colortex0, uv1).rgb);
                    lumaEnd1 = lumaEnd1 - lumaLocalAverage;
                }
                if (!reached2)
                {
                    lumaEnd2 = GetLuminance(texture(colortex0, uv2).rgb);
                    lumaEnd2 = lumaEnd2 - lumaLocalAverage;
                }

                reached1 = abs(lumaEnd1) >= gradientScaled;
                reached2 = abs(lumaEnd2) >= gradientScaled;
                reachedBoth = reached1 && reached2;

                if (!reached1)
                {
                    uv1 -= offset * quality[i];
                }
                if (!reached2)
                {
                    uv2 += offset * quality[i];
                }

                if (reachedBoth) break;
            }
        }

        float distance1 = isHorizontal ? (TexCoords.x - uv1.x) : (TexCoords.y - uv1.y);
        float distance2 = isHorizontal ? (uv2.x - TexCoords.x) : (uv2.y - TexCoords.y);

        bool isDirection1 = distance1 < distance2;
        float distanceFinal = min(distance1, distance2);

        float edgeThickness = (distance1 + distance2);

        float pixelOffset = - distanceFinal / edgeThickness + 0.5;

        bool isLumaCenterSmaller = lumaCenter < lumaLocalAverage;

        bool correctVariation = ((isDirection1 ? lumaEnd1 : lumaEnd2) < 0.0) != isLumaCenterSmaller;

        float finalOffset = correctVariation ? pixelOffset : 0.0;

        float lumaAverage = (1.0 / 12.0) * (2.0 * (lumaDownUp + lumaLeftRight) + lumaLeftCorners + lumaRightCorners);
        float subPixelOffset1 = clamp(abs(lumaAverage - lumaCenter) / lumaRange, 0.0, 1.0);
        float subPixelOffset2 = (-2.0 * subPixelOffset1 + 3.0) * subPixelOffset1 * subPixelOffset1;
        float subPixelOffsetFinal = subPixelOffset2 * subPixelOffset2 * subpixelQuality;

        finalOffset = max(finalOffset, subPixelOffsetFinal);

        if (isHorizontal) {
            finalUv.y += finalOffset * stepLength;
        } else {
            finalUv.x += finalOffset * stepLength;
        }

        color = texture(colortex0, finalUv).rgb;
    }
}
#endif

#if MOTION_BLUR == 1
float R1(uint seed, float randomInput) {
    return fract(sin(float(seed) + randomInput) * 43758.5453123);
}

float Bayer64(vec2 coords) {
    return R1(uint(coords.x + coords.y * viewWidth), frameCounter);
}

vec3 MotionBlur(vec3 color, float z, float dither)
{
    if (z > 0.56)
    {
        float mbwg = 0.0;
        vec2 doublePixel = 2.0 / vec2(viewWidth, viewHeight);
        vec3 mblur = vec3(0.0);

        vec4 currentPosition = vec4(TexCoords, z, 1.0) * 2.0 - 1.0;

        vec4 viewPos = gbufferProjectionInverse * currentPosition;
        viewPos = gbufferModelViewInverse * viewPos;
        viewPos /= viewPos.w;

        vec3 cameraOffset = cameraPosition - previousCameraPosition;

        vec4 previousPosition = viewPos + vec4(cameraOffset, 0.0);
        previousPosition = gbufferPreviousModelView * previousPosition;
        previousPosition = gbufferPreviousProjection * previousPosition;
        previousPosition /= previousPosition.w;

        vec2 velocity = (currentPosition - previousPosition).xy;
        velocity = velocity / (1.0 + length(velocity)) * MOTION_BLURRING_STRENGTH * 0.02;

        vec2 coord = TexCoords - velocity * (3.5 + dither);
        finalUv = coord;

        #if ANTI_ALIASING == 1
        FXAA311(color);
        #endif

        for (int i = 0; i < 9; i++, finalUv += velocity) {
            vec2 coordb = clamp(finalUv, doublePixel, 1.0 - doublePixel);
            mblur += textureLod(colortex0, coordb, 0).rgb;
            mbwg += 1.0;
        }
        mblur /= mbwg;
        return mblur;
    } else {
        return color;
    }
}
#endif

#if BLOOM == 1
const int samples = 35;
const int LOD = 2;
const int sLOD = 1 << LOD;
const float sigma = float(samples) * 1;

float gaussian(vec2 i) {
    return exp(-0.5 * dot(i /= sigma, i)) / (6.28 * sigma * sigma);
}

vec3 blur(sampler2D sampler, vec2 uv) {
    vec3 color = vec3(0.0);
    float totalWeight = 0.0;
    
    vec2 texelSize = 1.0 / vec2(viewWidth, viewHeight);
    vec2 mipTexelSize = texelSize * float(sLOD);
    
    int sampleCount = samples / sLOD;
    int halfSamples = sampleCount / 2;

    for (int x = -halfSamples; x <= halfSamples; x++) {
        for (int y = -halfSamples; y <= halfSamples; y++) {
            vec2 offset = vec2(x, y) * float(sLOD);
            float weight = gaussian(offset);
            color += textureLod(sampler, uv + offset * texelSize, float(LOD)).rgb * weight;
            totalWeight += weight;
        }
    }

    if (totalWeight > 0.0) {
        return color / totalWeight;
    }
    return texture(sampler, uv).rgb;
}
#endif

void main() {
    vec3 color = texture(colortex0, TexCoords).rgb;

    #if MOTION_BLUR == 1
    float z = texture(depthtex1, TexCoords).x;
    float dither = Bayer64(gl_FragCoord.xy);
    color = MotionBlur(color, z, dither);
    #else
    #if ANTI_ALIASING == 1
    finalUv = TexCoords;
    FXAA311(color);
    #endif
    #endif

    #if BLOOM == 1
    color += blur(colortex8, TexCoords) * BLOOM_INTENSITY;
    #endif

    /* DRAWBUFFERS:0 */
    gl_FragData[0] = vec4(color, 1.0);
}