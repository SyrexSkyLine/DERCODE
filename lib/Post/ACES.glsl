
// Constants for horror preset
const float rrtGlowGain  = 0.1;     // Increased glow for eerie effect
const float rrtGlowMid   = 0.05;    // Lower mid-point for darker glow
const float rrtRedScale  = 0.7;     // Reduced red scale for colder tones
const float rrtRedPivot  = 0.02;    // Adjusted pivot for subtle red shift
const float rrtRedHue    = 180.0;   // Shift towards cyan/blue for horror vibe
const float rrtRedWidth  = 90.0;    // Narrower hue range for targeted effect
const float rrtSatFactor = 0.7;     // Heavy desaturation for bleak look
const float odtSatFactor = 0.65;    // Further desaturation in ODT
const float rrtGammaCurve = 1.2;    // Higher gamma for contrasty shadows
const float odtGammaCurve = 1.3;    // Stronger gamma for output
const float vignetteStrength = 0.4; // Vignette effect for horror framing

float rgbToSaturation(in vec3 rgb) {
    float max_component = max(maxOf(rgb), 1e-10);
    float min_component = max(minOf(rgb), 1e-10);
    return (max_component - min_component) / max_component;
}

float rgbToHue(in vec3 rgb) {
    if (rgb.r == rgb.g && rgb.g == rgb.b) return 0.0;
    float hue = (360.0 / TAU) * atan(2.0 * rgb.r - rgb.g - rgb.b, sqrt(3.0) * (rgb.g - rgb.b));
    if (hue < 0.0) hue += 360.0;
    return hue;
}

float rgbToYc(in vec3 rgb) {
    const float yc_radius_weight = 1.75;
    float chroma = sqrt(rgb.b * (rgb.b - rgb.g) + rgb.g * (rgb.g - rgb.r) + rgb.r * (rgb.r - rgb.b));
    return (rgb.r + rgb.g + rgb.b + yc_radius_weight * chroma) / 3.0;
}

const mat3 ap0ToXyz = mat3(
    0.9525523959,  0.0000000000,  0.0000936786,
    0.3439664498,  0.7281660966, -0.0721325464,
    0.0000000000,  0.0000000000,  1.0088251844
);
const mat3 xyzToAp0 = mat3(
    1.0498110175,  0.0000000000, -0.0000974845,
   -0.4959030231,  1.3733130458,  0.0982400361,
    0.0000000000,  0.0000000000,  0.9912520182
);

const mat3 ap1ToXyz = mat3(
    0.6624541811,  0.1340042065,  0.1561876870,
    0.2722287168,  0.6740817658,  0.0536895174,
   -0.0055746495,  0.0040607335,  1.0103391003
);
const mat3 xyzToAp1 = mat3(
    1.6410233797, -0.3248032942, -0.2364246952,
   -0.6636628587,  1.6153315917,  0.0167563477,
    0.0117218943, -0.0082844420,  0.9883948585
);

const mat3 ap0ToAp1 = ap0ToXyz * xyzToAp1;
const mat3 ap1ToAp0 = ap1ToXyz * xyzToAp0;

float GlowFwd(in float yc_in, in float glow_gain_in, in const float glow_mid) {
    float glow_gain_out;
    if (yc_in <= 2.0 / 3.0 * glow_mid)
        glow_gain_out = glow_gain_in;
    else if (yc_in >= 2.0 * glow_mid)
        glow_gain_out = 0.0;
    else
        glow_gain_out = glow_gain_in * (glow_mid / yc_in - 0.5);
    return glow_gain_out;
}

float SigmoidShaper(in float x) {
    float t = max0(1.0 - abs(0.5 * x));
    float y = 1.0 + sign(x) * oneMinus(t * t);
    return 0.5 * y;
}

float CubicBasisShaperFit(in float x, in const float width) {
    float radius = 0.5 * width;
    return abs(x) < radius ? sqr(curve(1.0 - abs(x) / radius)) : 0.0;
}

float CenterHue(in float hue, in float centerH) {
    float hueCentered = hue - centerH;
    if (hueCentered < -180.0) {
        return hueCentered + 360.0;
    } else if (hueCentered > 180.0) {
        return hueCentered - 360.0;
    } else {
        return hueCentered;
    }
}

// Vignette effect for horror aesthetic
vec3 ApplyVignette(in vec3 color, in vec2 uv) {
    float dist = length(uv - vec2(0.5));
    float vignette = 1.0 - vignetteStrength * dist;
    return color * clamp(vignette, 0.0, 1.0);
}

vec3 RRTSweeteners(in vec3 ACES2065) {
    // Glow module with fog-like effect
    float saturation = rgbToSaturation(ACES2065);
    float ycIn = rgbToYc(ACES2065);
    float s = SigmoidShaper(5.0 * saturation - 2.0);
    float addedGlow = 1.0 + GlowFwd(ycIn, rrtGlowGain * s, rrtGlowMid);

    ACES2065 *= addedGlow;

    // Red modifier for cold, horror-like tint
    float hue = rgbToHue(ACES2065);
    float centeredHue = CenterHue(hue, rrtRedHue);
    float hueWeight = CubicBasisShaperFit(centeredHue, rrtRedWidth);
    ACES2065.r += hueWeight * saturation * (rrtRedPivot - ACES2065.r) * oneMinus(rrtRedScale);

    ACES2065 = clamp16F(ACES2065);
    vec3 ACEScg = clamp16F(ACES2065 * ap0ToAp1);

    // Global desaturation
    float luminance = GetLuminance(ACEScg);
    ACEScg = mix(vec3(luminance), ACEScg, rrtSatFactor);

    // Gamma adjustment for horror contrast
    ACEScg = pow(ACEScg, vec3(rrtGammaCurve));

    return ACEScg;
}

vec3 RRTAndODTFit(in vec3 rgb) {
    vec3 a = rgb * (rgb + 0.0245786) - 0.000090537;
    vec3 b = rgb * (0.983729 * rgb + 0.4329510) + 0.238081;
    return a / b;
}

const mat3 xyzToSRGB = mat3(
    3.2409699419, -1.5373831776, -0.4986107603,
   -0.9692436363,  1.8759675015,  0.0415550574,
    0.0556300797, -0.2039769589,  1.0569715142
);

const mat3 d60ToD65 = mat3(
    0.9872240000, -0.0061132700,  0.0159533000,
   -0.0075983600,  1.0018600000,  0.0053300200,
    0.0030725700, -0.0050959500,  1.0816800000
);

const mat3 ap0ToSRGB = ap1ToXyz * d60ToD65 * xyzToSRGB;

vec4 splineOperator(in vec4 aces) {
    aces *= 1.313;
    vec4 a = aces * (aces + 0.0313) - 0.00006;
    vec4 b = aces * (0.983729 * aces + 0.5129510) + 0.168081;
    return clamp16F(a / b);
}

vec3 academyCustom(in vec3 ACES2065) {
    const float white = PI * 4.0;
    vec3 rgbPre = RRTSweeteners(ACES2065);
    vec4 mapped = splineOperator(vec4(rgbPre, white));
    vec3 mappedColor = mapped.rgb / mapped.a;

    // Global desaturation
    mappedColor = mix(vec3(GetLuminance(mappedColor)), mappedColor, odtSatFactor);
    mappedColor = clamp(mappedColor, 0.0, 65000.0);

    // Gamma correction
    mappedColor = pow(mappedColor, vec3(odtGammaCurve));

    // Apply vignette effect (assuming UV coordinates are passed elsewhere)
    // Note: UV must be provided in the main shader
    // mappedColor = ApplyVignette(mappedColor, uv);

    return mappedColor * ap1ToAp0;
}

vec3 AcademyCustom(in vec3 rgb) {
    rgb = academyCustom(rgb * ap1ToAp0) * ap0ToSRGB;

    #ifdef COLOR_GRADING
        rgb = Contrast(rgb * BRIGHTNESS);
        rgb = pow(rgb, vec3(rcp(GAMMA)));
        rgb = ColorSaturation(rgb, SATURATION);
        #if WHITE_BALANCE != 6500
            rgb *= WhiteBalanceMatrix();
        #endif
    #endif

    return LinearToSRGB(rgb);
}

vec3 AcademyFit(in vec3 rgb) {
    rgb *= 1.4; // Match the exposure to the RRT
    rgb = RRTSweeteners(rgb * ap1ToAp0);
    rgb = RRTAndODTFit(rgb);

    // Global desaturation
    rgb = mix(vec3(GetLuminance(rgb)), rgb, odtSatFactor);

    #ifdef COLOR_GRADING
        rgb = Contrast(rgb * BRIGHTNESS);
        rgb = pow(rgb, vec3(rcp(GAMMA)));
        rgb = ColorSaturation(rgb, SATURATION);
        #if WHITE_BALANCE != 6500
            rgb *= WhiteBalanceMatrix();
        #endif
    #endif

    return LinearToSRGB(rgb);
}	