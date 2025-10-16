#define SkyStyle 0 // [0 1]
#define MOON_BLOOM_INTENSITY 20.0 // [0.0 0.5 1.0 1.5 2.0 2.5 3.0] Controls the intensity of the moon's bloom effect

vec3 MoonFlux = vec3(abs(moonPhase - 4.0) * 0.25 + 0.2) * (NIGHT_BRIGHTNESS + nightVision * 0.02);

vec3 lightningColor = isLightningFlashing * vec3(0.45, 0.43, 1.0) * 0.03;

#ifdef AURORA
    float auroraAmount = smoothstep(0.0, 0.2, -worldSunVector.y) * AURORA_STRENGTH;
#endif

vec4 ToSH(float value, vec3 dir) {
    const vec2 foo = vec2(0.5 * PI * sqrt(rPI), 0.3849 * PI * sqrt(0.75 * rPI));
    return vec4(foo.x, foo.y * dir.yzx) * value;
}

vec3 FromSH(vec4 cR, vec4 cG, vec4 cB, vec3 lightDir) {
    const vec2 foo = vec2(0.5 * sqrt(rPI), sqrt(0.75 * rPI));
    vec4 sh = vec4(foo.x, foo.y * lightDir.yzx);
    return vec3(dot(sh, cR), dot(sh, cG), dot(sh, cB));
}

float RayleighPhase(in float cosTheta) {
    const float c = 3.0 / 16.0 * rPI;
    return cosTheta * cosTheta * c + c;
}

float HenyeyGreensteinPhase(in float cosTheta, in const float g) {
    const float gg = g * g;
    float phase = 1.0 + gg - 2.0 * g * cosTheta;
    return oneMinus(gg) / (4.0 * PI * phase * sqrt(phase));
}

float CornetteShanksPhase(in float cosTheta, in const float g) {
    const float gg = g * g;
    float a = oneMinus(gg) * rcp(2.0 + gg) * 3.0 * rPI;
    float b = (1.0 + sqr(cosTheta)) * pow((1.0 + gg - 2.0 * g * cosTheta), -1.5);
    return a * b * 0.125;
}

float MiePhaseClouds(in float cosTheta, in const vec3 g, in const vec3 w) {
    const vec3 gg = g * g;
    vec3 a = (0.75 * oneMinus(gg)) * rcp(2.0 + gg);
    vec3 b = (1.0 + sqr(cosTheta)) * pow(1.0 + gg - 2.0 * g * cosTheta, vec3(-1.5));
    return dot(a * b, w) / (w.x + w.y + w.z);
}

vec3 DoNightEye(in vec3 color) {
    float luminance = GetLuminance(color);
    float rodFactor = exp2(-luminance * 6e2);
    return mix(color, luminance * vec3(0.72, 0.95, 1.2), rodFactor);
}

float fastAcos(in float x) {
    float a = abs(x);
    float r = 1.570796 - 0.175394 * a;
    r *= sqrt(1.0 - a);
    return x < 0.0 ? PI - r : r;
}

vec2 ProjectSky(in vec3 direction) {
    vec2 coord = vec2(atan(-direction.x, -direction.z) * rTAU + 0.5, fastAcos(direction.y) * rPI);
    coord.x = coord.x * oneMinus(4.0 / skyCaptureRes.x) + 2.0 / skyCaptureRes.x;
    return saturate(coord * skyCaptureRes * screenPixelSize);
}

vec3 UnprojectSky(in vec2 coord) {
    coord.x *= 256.0 / 255.0;
    coord.x = fract((coord.x - 2.0 / skyCaptureRes.x) * rcp(oneMinus(4.0 / skyCaptureRes.x)));
    coord *= vec2(TAU, PI);
    return vec3(sincos(coord.x) * sin(coord.y), cos(coord.y)).xzy;
}

vec2 RaySphereIntersection(in vec3 pos, in vec3 dir, in float rad) {
    float PdotD = dot(pos, dir);
    float delta = sqr(PdotD) + sqr(rad) - dotSelf(pos);
    if (delta < 0.0) return vec2(-1.0);
    delta = sqrt(delta);
    return vec2(-delta, delta) - PdotD;
}

const float planetRadius = 6371e3;
const float sun_angular_radius = 0.01;
const float mie_phase_g = 0.77;

#if defined PRECOMPUTED_ATMOSPHERIC_SCATTERING

#define TRANSMITTANCE_TEXTURE_WIDTH     256.0
#define TRANSMITTANCE_TEXTURE_HEIGHT    64.0
#define SCATTERING_TEXTURE_R_SIZE       32.0
#define SCATTERING_TEXTURE_MU_SIZE      128.0
#define SCATTERING_TEXTURE_MU_S_SIZE    32.0
#define SCATTERING_TEXTURE_NU_SIZE      8.0
#define IRRADIANCE_TEXTURE_WIDTH        64.0
#define IRRADIANCE_TEXTURE_HEIGHT       16.0

struct AtmosphereParameters {
    vec3 solar_irradiance;
    vec3 rayleigh_scattering;
    vec3 mie_scattering;
    vec3 ground_albedo;
};

AtmosphereParameters atmosphereModel = AtmosphereParameters(
    vec3(1.474000,1.850400,1.911980),
    vec3(0.005802, 0.013558, 0.033100),
    vec3(0.003996, 0.003996, 0.003996),
    vec3(0.1)
);

#define ATMOSPHERE_BOTTOM_ALTITUDE  1000.0
#define ATMOSPHERE_TOP_ALTITUDE     100000.0

const float atmosphere_bottom_radius = planetRadius - ATMOSPHERE_BOTTOM_ALTITUDE;
const float atmosphere_top_radius = planetRadius + ATMOSPHERE_TOP_ALTITUDE;
const float atmosphere_bottom_radius_sq = atmosphere_bottom_radius * atmosphere_bottom_radius;
const float atmosphere_top_radius_sq = atmosphere_top_radius * atmosphere_top_radius;
const float mu_s_min = -0.2;

float ClampCosine(float mu) {
    return clamp(mu, -1.0, 1.0);
}

float ClampRadius(float r) {
    return clamp(r, atmosphere_bottom_radius, atmosphere_top_radius);
}

float SafeSqrt(float a) {
    return sqrt(max0(a));
}

float DistanceToTopAtmosphereBoundary(float r, float mu) {
    float discriminant = r * r * (mu * mu - 1.0) + atmosphere_top_radius_sq;
    return max0(-r * mu + SafeSqrt(discriminant));
}

float DistanceToBottomAtmosphereBoundary(float r, float mu) {
    float discriminant = r * r * (mu * mu - 1.0) + atmosphere_bottom_radius_sq;
    return max0(-r * mu - SafeSqrt(discriminant));
}

bool RayIntersectsGround(float r, float mu) {
    return mu < 0.0 && r * r * (mu * mu - 1.0) + atmosphere_bottom_radius_sq >= 0.0;
}

float GetTextureCoordFromUnitRange(float x, float texture_size) {
    return 0.5 / texture_size + x * oneMinus(1.0 / texture_size);
}

vec2 GetTransmittanceTextureUvFromRMu(float r, float mu) {
    const float H = sqrt(atmosphere_top_radius_sq - atmosphere_bottom_radius_sq);
    float rho = SafeSqrt(r * r - atmosphere_bottom_radius_sq);
    float d = DistanceToTopAtmosphereBoundary(r, mu);
    float d_min = atmosphere_top_radius - r;
    float d_max = rho + H;
    return vec2(GetTextureCoordFromUnitRange((d - d_min) / (d_max - d_min), TRANSMITTANCE_TEXTURE_WIDTH),
                GetTextureCoordFromUnitRange(rho / H, TRANSMITTANCE_TEXTURE_HEIGHT));
}

vec3 GetTransmittanceToTopAtmosphereBoundary(float r, float mu) {
    vec2 uv = GetTransmittanceTextureUvFromRMu(r, mu);
    uv = clamp(uv, vec2(0.5 / 256.0, 0.5 / 64.0), vec2(255.5 / 256.0, 63.5 / 64.0));
    return vec3(texture(colortex4, vec3(uv * vec2(1.0, 0.5), 32.5 / 33.0)));
}

vec3 GetTransmittance(float r, float mu, float d, bool ray_r_mu_intersects_ground) {
    float r_d = ClampRadius(sqrt(d * d + 2.0 * r * mu * d + r * r));
    float mu_d = ClampCosine((r * mu + d) / r_d);
    if (ray_r_mu_intersects_ground) {
        return min(GetTransmittanceToTopAtmosphereBoundary(r_d, -mu_d) / GetTransmittanceToTopAtmosphereBoundary(r, -mu), vec3(1.0));
    } else {
        return min(GetTransmittanceToTopAtmosphereBoundary(r, mu) / GetTransmittanceToTopAtmosphereBoundary(r_d, mu_d), vec3(1.0));
    }
}

vec3 GetTransmittance(vec3 view_ray) {
    vec3 camera = vec3(0.0, planetRadius + eyeAltitude, 0.0);
    float r = length(camera);
    float rmu = dot(camera, view_ray);
    float distance_to_top_atmosphere_boundary = -rmu - sqrt(rmu * rmu - r * r + atmosphere_top_radius_sq);
    if (distance_to_top_atmosphere_boundary > 0.0) {
        camera += view_ray * distance_to_top_atmosphere_boundary;
        r = atmosphere_top_radius;
        rmu += distance_to_top_atmosphere_boundary;
    } else if (r > atmosphere_top_radius) {
        return vec3(1.0);
    }
    float mu = rmu / r;
    return GetTransmittanceToTopAtmosphereBoundary(r, mu);
}

vec3 GetTransmittanceToSun(float r, float mu_s) {
    float sin_theta_h = atmosphere_bottom_radius / r;
    float cos_theta_h = -sqrt(max0(1.0 - sin_theta_h * sin_theta_h));
    return GetTransmittanceToTopAtmosphereBoundary(r, mu_s) * smoothstep(-sin_theta_h * sun_angular_radius, sin_theta_h * sun_angular_radius, mu_s - cos_theta_h);
}

vec4 GetScatteringTextureUvwzFromRMuMuSNu(float r, float mu, float mu_s, float nu, bool ray_r_mu_intersects_ground) {
    float H = sqrt(atmosphere_top_radius_sq - atmosphere_bottom_radius_sq);
    float rho = SafeSqrt(r * r - atmosphere_bottom_radius_sq);
    float u_r = GetTextureCoordFromUnitRange(rho / H, SCATTERING_TEXTURE_R_SIZE);
    float r_mu = r * mu;
    float discriminant = r_mu * r_mu - r * r + atmosphere_bottom_radius_sq;
    float u_mu;
    if (ray_r_mu_intersects_ground) {
        float d = -r_mu - SafeSqrt(discriminant);
        float d_min = r - atmosphere_bottom_radius;
        float d_max = rho;
        u_mu = 0.5 - 0.5 * GetTextureCoordFromUnitRange(d_max == d_min ? 0.0 : (d - d_min) / (d_max - d_min), SCATTERING_TEXTURE_MU_SIZE * 0.5);
    } else {
        float d = -r_mu + SafeSqrt(discriminant + H * H);
        float d_min = atmosphere_top_radius - r;
        float d_max = rho + H;
        u_mu = 0.5 + 0.5 * GetTextureCoordFromUnitRange((d - d_min) / (d_max - d_min), SCATTERING_TEXTURE_MU_SIZE * 0.5);
    }
    float d = DistanceToTopAtmosphereBoundary(atmosphere_bottom_radius, mu_s);
    float d_min = atmosphere_top_radius - atmosphere_bottom_radius;
    float d_max = H;
    float a = (d - d_min) / (d_max - d_min);
    float D = DistanceToTopAtmosphereBoundary(atmosphere_bottom_radius, mu_s_min);
    float A = (D - d_min) / (d_max - d_min);
    float u_mu_s = GetTextureCoordFromUnitRange(max0(1.0 - a / A) / (1.0 + a), SCATTERING_TEXTURE_MU_S_SIZE);
    float u_nu = nu * 0.5 + 0.5;
    return vec4(u_nu, u_mu_s, u_mu, u_r);
}

vec3 GetExtrapolatedSingleMieScattering(AtmosphereParameters atmosphere, vec4 scattering) {
    if (scattering.r <= 0.0) {
        return vec3(0.0);
    }
    return scattering.rgb * scattering.a / scattering.r * (atmosphere.rayleigh_scattering.r / atmosphere.mie_scattering.r) * (atmosphere.mie_scattering / atmosphere.rayleigh_scattering);
}

vec3 GetCombinedScattering(AtmosphereParameters atmosphere, float r, float mu, float mu_s, float nu, bool ray_r_mu_intersects_ground, out vec3 single_mie_scattering) {
    vec4 uvwz = GetScatteringTextureUvwzFromRMuMuSNu(r, mu, mu_s, nu, ray_r_mu_intersects_ground);
    float tex_coord_x = uvwz.x * (SCATTERING_TEXTURE_NU_SIZE - 1.0);
    float tex_x = floor(tex_coord_x);
    float lerp = tex_coord_x - tex_x;
    vec3 uvw0 = vec3((tex_x + uvwz.y) / SCATTERING_TEXTURE_NU_SIZE, uvwz.z, uvwz.w);
    vec3 uvw1 = vec3((tex_x + 1.0 + uvwz.y) / SCATTERING_TEXTURE_NU_SIZE, uvwz.z, uvwz.w);
    vec4 combined_scattering = texture(colortex4, uvw0) * oneMinus(lerp) + texture(colortex4, uvw1) * lerp;
    vec3 scattering = vec3(combined_scattering);
    single_mie_scattering = GetExtrapolatedSingleMieScattering(atmosphere, combined_scattering);
    return scattering;
}

vec3 GetIrradiance(float r, float mu_s) {
    float x_r = (r - atmosphere_bottom_radius) / (atmosphere_top_radius - atmosphere_bottom_radius);
    float x_mu_s = mu_s * 0.5 + 0.5;
    vec2 uv = vec2(GetTextureCoordFromUnitRange(x_mu_s, IRRADIANCE_TEXTURE_WIDTH), GetTextureCoordFromUnitRange(x_r, IRRADIANCE_TEXTURE_HEIGHT));
    uv = clamp(uv, vec2(0.5 / 64.0, 0.5 / 16.0), vec2(63.5 / 64.0, 15.5 / 16.0));
    return vec3(texture(colortex4, vec3(uv * vec2(0.25, 0.125) + vec2(0.0, 0.5), 32.5 / 33.0)));
}

vec3 GetSkyRadiance(AtmosphereParameters atmosphere, vec3 view_ray, vec3 sun_direction, out vec3 transmittance) {
    vec3 camera = vec3(0.0, planetRadius + eyeAltitude, 0.0);
    float r = length(camera);
    float rmu = dot(camera, view_ray);
    float distance_to_top_atmosphere_boundary = -rmu - sqrt(rmu * rmu - r * r + atmosphere_top_radius_sq);
    if (distance_to_top_atmosphere_boundary > 0.0) {
        camera += view_ray * distance_to_top_atmosphere_boundary;
        r = atmosphere_top_radius;
        rmu += distance_to_top_atmosphere_boundary;
    } else if (r > atmosphere_top_radius) {
        transmittance = vec3(1.0);
        return vec3(0.0);
    }
    float mu = rmu / r;
    float mu_s = dot(camera, sun_direction) / r;
    float nu = dot(view_ray, sun_direction);
    bool ray_r_mu_intersects_ground = RayIntersectsGround(r, mu);
    transmittance = ray_r_mu_intersects_ground ? vec3(0.0) : GetTransmittanceToTopAtmosphereBoundary(r, mu);
    vec3 sun_single_mie_scattering;
    vec3 sun_scattering;
    vec3 moon_single_mie_scattering;
    vec3 moon_scattering;
    vec3 groundDiffuse = vec3(0.0);
    #ifdef SKY_GROUND
        if (ray_r_mu_intersects_ground) {
            vec3 planet_surface = camera + view_ray * DistanceToBottomAtmosphereBoundary(r, mu);
            float r = length(planet_surface);
            float mu_s = dot(planet_surface, sun_direction) / r;
            vec3 sky_irradiance = GetIrradiance(r, mu_s);
            sky_irradiance += GetIrradiance(r, -mu_s) * MoonFlux;
            vec3 sun_irradiance = atmosphere.solar_irradiance * GetTransmittanceToSun(r, mu_s);
            float d = distance(camera, planet_surface);
            vec3 surface_transmittance = GetTransmittance(r, mu, d, ray_r_mu_intersects_ground);
            groundDiffuse = mix(sky_irradiance * 0.1, sun_irradiance * 0.01, wetness * 0.7) * surface_transmittance;
        }
    #else
        ray_r_mu_intersects_ground = false;
    #endif
    sun_scattering = GetCombinedScattering(atmosphere, r, mu, mu_s, nu, ray_r_mu_intersects_ground, sun_single_mie_scattering);
    moon_scattering = GetCombinedScattering(atmosphere, r, mu, -mu_s, -nu, ray_r_mu_intersects_ground, moon_single_mie_scattering);
    vec3 rayleigh = sun_scattering * RayleighPhase(nu) + moon_scattering * RayleighPhase(-nu) * MoonFlux;
    vec3 mie = sun_single_mie_scattering * HenyeyGreensteinPhase(nu, mie_phase_g) + moon_single_mie_scattering * HenyeyGreensteinPhase(-nu, mie_phase_g) * MoonFlux;
    rayleigh = mix(rayleigh, GetLuminance(rayleigh) * vec3(1.026186824, 0.9881671071, 1.015787125), wetness * 0.7);
    return (rayleigh + mie + groundDiffuse) * oneMinus(wetness * 0.6);
}

vec3 GetSkyRadianceToPoint(AtmosphereParameters atmosphere, vec3 point, vec3 sun_direction, out vec3 transmittance) {
    vec3 camera = vec3(0.0, planetRadius + eyeAltitude, 0.0);
    vec3 view_ray = normalize(point);
    float r = length(camera);
    float rmu = dot(camera, view_ray);
    float distance_to_top_atmosphere_boundary = -rmu - sqrt(rmu * rmu - r * r + atmosphere_top_radius_sq);
    if (distance_to_top_atmosphere_boundary > 0.0) {
        camera += view_ray * distance_to_top_atmosphere_boundary;
        r = atmosphere_top_radius;
        rmu += distance_to_top_atmosphere_boundary;
    }
    float mu = rmu / r;
    float mu_s = dot(camera, sun_direction) / r;
    float nu = dot(view_ray, sun_direction);
    float d = length(point);
    bool ray_r_mu_intersects_ground = RayIntersectsGround(r, mu);
    transmittance = GetTransmittance(r, mu, d, ray_r_mu_intersects_ground);
    vec3 sun_single_mie_scattering;
    vec3 sun_scattering = GetCombinedScattering(atmosphere, r, mu, mu_s, nu, ray_r_mu_intersects_ground, sun_single_mie_scattering);
    vec3 moon_single_mie_scattering;
    vec3 moon_scattering = GetCombinedScattering(atmosphere, r, mu, -mu_s, -nu, ray_r_mu_intersects_ground, moon_single_mie_scattering);
    float r_p = ClampRadius(sqrt(d * d + 2.0 * r * mu * d + r * r));
    float mu_p = (r * mu + d) / r_p;
    float mu_s_p = (r * mu_s + d * nu) / r_p;
    float mu_s_p_m = (r * -mu_s + d * -nu) / r_p;
    vec3 sun_single_mie_scattering_p;
    vec3 sun_scattering_p = GetCombinedScattering(atmosphere, r_p, mu_p, mu_s_p, nu, ray_r_mu_intersects_ground, sun_single_mie_scattering_p);
    vec3 moon_single_mie_scattering_p;
    vec3 moon_scattering_p = GetCombinedScattering(atmosphere, r_p, mu_p, mu_s_p_m, -nu, ray_r_mu_intersects_ground, moon_single_mie_scattering_p);
    sun_scattering -= transmittance * sun_scattering_p;
    sun_single_mie_scattering -= transmittance * sun_single_mie_scattering_p;
    moon_scattering = moon_scattering - transmittance * moon_scattering_p;
    moon_single_mie_scattering -= transmittance * moon_single_mie_scattering_p;
    sun_single_mie_scattering *= smoothstep(0.0, 0.01, mu_s);
    moon_single_mie_scattering *= smoothstep(0.0, 0.01, -mu_s);
    vec3 rayleigh = sun_scattering * RayleighPhase(nu) + moon_scattering * RayleighPhase(-nu) * MoonFlux;
    vec3 mie = sun_single_mie_scattering * HenyeyGreensteinPhase(nu, mie_phase_g) + moon_single_mie_scattering * HenyeyGreensteinPhase(-nu, mie_phase_g) * MoonFlux;
    rayleigh = mix(rayleigh, GetLuminance(rayleigh) * vec3(1.026186824, 0.9881671071, 1.015787125), wetness * 0.7);
    return (rayleigh + mie) * oneMinus(wetness * 0.6);
}

vec3 GetSunAndSkyIrradiance(AtmosphereParameters atmosphere, vec3 point, vec3 sun_direction, out vec3 sky_irradiance, out vec3 moon_irradiance) {
    float r = length(point);
    float mu_s = dot(point, sun_direction) / r;
    sky_irradiance = GetIrradiance(r, mu_s) + GetIrradiance(r, -mu_s) * MoonFlux;
    sky_irradiance *= 1.0 + point.y / r;
    vec3 sun_irradiance = GetTransmittanceToSun(r, mu_s);
    moon_irradiance = atmosphere.solar_irradiance * DoNightEye(GetTransmittanceToSun(r, -mu_s) * MoonFlux);
    return atmosphere.solar_irradiance * sun_irradiance;
}

#endif

#define coneAngleToSolidAngle(x) (TAU * oneMinus(cos(x)))

vec3 RenderSun(in vec3 worldDir, in vec3 sunVector) {
    const vec3 sunIlluminance = vec3(1.026186824, 0.9881671071, 1.015787125) * 126.6e3;
    float cosTheta = dot(worldDir, sunVector);
    float centerToEdge = saturate(fastAcos(cosTheta) / sun_angular_radius);
    if (cosTheta < cos(sun_angular_radius)) return vec3(0.0);
    const vec3 alpha = vec3(0.429, 0.522, 0.614);
    vec3 factor = pow(vec3(1.0 - centerToEdge * centerToEdge), alpha * 0.5);
    vec3 finalLuminance = sunIlluminance / coneAngleToSolidAngle(sun_angular_radius) * factor;
    return min(finalLuminance, 1e4);
}

vec3 RenderSunReflection(in vec3 worldDir, in vec3 sunVector) {
    const vec3 sunIlluminance = vec3(1.026186824, 0.9881671071, 1.015787125) * 126.6e3;
    float cosTheta = dot(worldDir, sunVector);
    float centerToEdge = saturate(fastAcos(cosTheta) / 0.05);
    if (cosTheta < cos(0.05)) return vec3(0.0);
    const vec3 alpha = vec3(0.429, 0.522, 0.614);
    vec3 factor = pow(vec3(1.0 - centerToEdge * centerToEdge), alpha * 0.5);
    vec3 finalLuminance = sunIlluminance / coneAngleToSolidAngle(0.05) * factor;
    return min(finalLuminance, 2e3);
}

vec3 RenderMoonReflection(in vec3 worldDir, in vec3 sunVector) {
    #if (SkyStyle == 1)
    
        const vec3 moonIlluminance = vec3(1.0, 0.95, 0.9) * 10.0; // Яркость луны
        float moon_angular_radius = 0.008; // Размер луны
        float cosTheta = dot(worldDir, -sunVector);
        float centerToEdge = saturate(fastAcos(cosTheta) / moon_angular_radius);
        if (cosTheta < cos(moon_angular_radius)) return vec3(0.0);
        const vec3 alpha = vec3(0.429, 0.522, 0.614);
        vec3 factor = pow(vec3(1.0 - centerToEdge * centerToEdge), alpha * 0.5);
        vec3 moonLuminance = moonIlluminance / coneAngleToSolidAngle(moon_angular_radius) * factor;
        // Add bloom effect
        float bloomRadius = moon_angular_radius * 8.0; // Bloom extends twice the moon's radius
        float bloomFalloff = saturate(fastAcos(cosTheta) / bloomRadius);
        vec3 bloom = moonIlluminance * MOON_BLOOM_INTENSITY * exp(-bloomFalloff * bloomFalloff * 10.0);
        vec3 finalLuminance = moonLuminance + bloom;
        return min(finalLuminance, 5000.0) * MoonFlux;
    #else
        // Обычный стиль: мягкий градиент луны
        float cosTheta = dot(worldDir, -sunVector);
        float size = 5e-3;
        float hardness = 2e2;
        float disc = sqr(curve(saturate((cosTheta - 1.0 + size) * hardness)));
        // Add bloom effect
        float bloomRadius = size * 2.0; // Bloom extends twice the moon's size
        float bloomFalloff = saturate(fastAcos(cosTheta) / bloomRadius);
        vec3 bloom = vec3(1.0, 0.95, 0.9) * MOON_BLOOM_INTENSITY * exp(-bloomFalloff * bloomFalloff * 10.0);
        vec3 finalLuminance = vec3(disc) * 4.0 + bloom;
        return finalLuminance * MoonFlux;
    #endif
}

vec3 RenderStars(in vec3 worldDir) {
    #if (SkyStyle == 1)
        // Astralex-подобный стиль: больше звезд, ярче и разнообразнее
        const float scale = 256.0;
        const float coverage = 0.3 * STARS_COVERAGE; // Увеличено количество звезд
        const float maxLuminance = 1.0 * STARS_INTENSITY; // Увеличена яркость
        const float minTemperature = 3500.0; // Более теплые звезды
        const float maxTemperature = 9000.0; // Более холодные звезды
    #else
        // Обычный стиль
        const float scale = 256.0;
        const float coverage = 0.1 * STARS_COVERAGE;
        const float maxLuminance = 0.6 * STARS_INTENSITY;
        const float minTemperature = 4000.0;
        const float maxTemperature = 8000.0;
    #endif

    float cosine = worldSunVector.z;
    vec3 axis = cross(worldSunVector, vec3(0.0, 0.0, 1.0));
    float cosecantSquared = rcp(dotSelf(axis));
    worldDir = cosine * worldDir + cross(axis, worldDir) + cosecantSquared * oneMinus(cosine) * dot(axis, worldDir) * axis;

    vec3 p = worldDir * scale;
    ivec3 i = ivec3(floor(p));
    vec3 f = p - i;
    float r = dotSelf(f - 0.5);

    vec3 i3 = fract(i * vec3(443.897, 441.423, 437.195));
    i3 += dot(i3, i3.yzx + 19.19);
    vec2 hash = fract((i3.xx + i3.yz) * i3.zy);
    hash.y = 2.0 * hash.y - 4.0 * hash.y * hash.y + 3.0 * hash.y * hash.y * hash.y;

    float cov = remap(oneMinus(coverage), 1.0, hash.x);
    return maxLuminance * remap(0.25, 0.0, r) * cov * cov * Blackbody(mix(minTemperature, maxTemperature, hash.y));
}