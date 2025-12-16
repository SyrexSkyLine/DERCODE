#ifndef BRDF_GLSL
#define BRDF_GLSL

// ===================================================================
// BRDF
// ===================================================================

// Fresnel Schlick (металлы)
float FresnelSchlick(float cosTheta, float f0){
    float f = pow(1.0 - cosTheta, 5.0);
    return clamp(f + (1.0 - f) * f0, 0.0, 1.0);
}

// Fresnel диэлектрика (deferred6.fsh)
float FresnelDielectric(float cosTheta, float eta){
    float r0 = (1.0 - eta) / (1.0 + eta);
    r0 = r0 * r0;
    return r0 + (1.0 - r0) * pow(1.0 - cosTheta, 5.0);
}

// Fresnel диэлектрика для RGB (металлы)
vec3 FresnelDielectric(float cosTheta, vec3 F0){
    return F0 + (1.0 - F0) * pow(1.0 - cosTheta, 5.0);
}

// Fresnel диэлектрика для векторов нормалей
float FresnelDielectricN(float cosTheta, float eta){
    float r0 = (1.0 - eta) / (1.0 + eta);
    r0 = r0 * r0;
    return r0 + (1.0 - r0) * pow(1.0 - cosTheta, 5.0);
}

// Fresnel диэлектрика для RGB векторов нормалей
vec3 FresnelDielectricN(float cosTheta, vec3 F0){
    return F0 + (1.0 - F0) * pow(1.0 - cosTheta, 5.0);
}

// GGX Distribution
float DistributionGGX(float NdotH, float alpha2){
    return alpha2 * 0.318309886 / pow(1.0 + (NdotH * alpha2 - NdotH) * NdotH, 2.0);
}

// Smith GGX Visibility
float V1SmithGGXInverse(float NdotX, float alpha2){
    return NdotX + sqrt(alpha2 + (1.0 - alpha2) * NdotX * NdotX);
}

float V2SmithGGX(float NdotV, float NdotL, float alpha2){
    float ggxl = V1SmithGGXInverse(NdotL, alpha2);
    float ggxv = V1SmithGGXInverse(NdotV, alpha2);
    return 0.5 / (ggxl + ggxv);
}

// Specular BRDF
float SpecularBRDF(float LdotH, float NdotV, float NdotL, float NdotH, float alpha2, float f0){
    if(NdotL < 1e-5) return 0.0;
    float F = FresnelSchlick(LdotH, f0);
    float D = DistributionGGX(NdotH, alpha2);
    float V = V2SmithGGX(max(NdotV, 1e-2), max(NdotL, 1e-2), alpha2);
    return min(NdotL * D * V * F, 4.0);
}

// ===================================================================
// Diffuse Hammon
// ===================================================================
vec3 DiffuseHammon(float LdotV, float NdotV, float NdotL, float NdotH, float roughness, vec3 albedo){
    if(NdotL < 1e-6) return vec3(0.0);
    float facing = max(LdotV, 0.0) * 0.5 + 0.5;

    float singleSmooth = 1.05 * (1.0 - pow(1.0 - max(NdotL, 1e-2), 5.0)) * (1.0 - pow(1.0 - max(NdotV, 1e-2), 5.0));
    float singleRough  = facing * (0.45 - 0.2 * facing) * (1.0 / max(NdotH, 1e-4) + 2.0);

    float single = mix(singleSmooth, singleRough, roughness) * 0.318309886;
    float multi  = 0.1159 * roughness;

    return (multi * albedo + single) * NdotL;
}

vec3 DiffuseHammon(float LdotV, float NdotV, float NdotL, float NdotH, float roughness){
    return DiffuseHammon(LdotV, NdotV, NdotL, NdotH, roughness, vec3(1.0));
}

// ===================================================================
// Integrated PBR
// ===================================================================
struct dataPBR {
    vec4 albedo;
    vec3 normal;
    float smoothness;
    float emissive;
    float metallic;
    float porosity;
    float ss;
    float parallaxShd;
    float ambient;
};

uniform sampler2D iron_block_s;
uniform sampler2D iron_block_n;

void getPBR(inout dataPBR material, int id){
    vec2 dcdx = dFdx(vTexCoord);
    vec2 dcdy = dFdy(vTexCoord);
    material.albedo = textureGrad(gtexture, vTexCoord, dcdx, dcdy);
    if (material.albedo.a < ALPHA_THRESHOLD){ discard; return; }
    material.normal = TBN[2];

    // defaults
    material.smoothness = 0.0;
    material.emissive = 0.0;
    material.metallic = 0.04;
    material.porosity = 0.0;
    material.ss = 0.0;
    material.parallaxShd = 1.0;
    material.ambient = 1.0;
    
    // Старые блоки
    if(id >= 10001 && id <= 10007){ material.porosity=1.0; material.smoothness=0.2; }
    else if(id==10009 || id==10010){ material.ss=1.0; material.smoothness=0.4; }
    else if(id==10015){ material.emissive=1.0; material.smoothness=0.8; material.metallic=0.0; }
    else if(id==10017 || id==10018){ material.smoothness=0.96; material.metallic=0.02; }
    else if(id==10019){ material.smoothness=1.0; material.emissive=1.0; }
    else if(id==10020 || id==10021 || id==10023 || id==10024 || id==10026 || id==10030 || id==10033 || id==10034){ 
        material.emissive=1.0; material.smoothness=0.9; 
    }
    else if(id==10025 || id==10029){ 
        material.emissive=material.albedo.r*0.5; material.smoothness=0.9; material.metallic=1.0; 
    }
    else if(id==10027){ 
        float avg=dot(material.albedo.rgb,vec3(0.333)); 
        material.smoothness=avg*0.6+0.3; 
        material.emissive=avg*avg*avg; 
        material.metallic=0.17; 
    }
    else if(id==10028){ 
        material.emissive = smoothstep(0.3,0.9,max(material.albedo.rgb)); 
    }
    else if(id==10031){ 
        material.emissive=0.5; material.smoothness=0.8; 
    }
    else if(id==10032){ 
        material.emissive=1.0; material.smoothness=0.8; 
    }
    
    // Железный блок нет блять золотой 
    else if(id == 10070){
        material.albedo = texture(iron_block_s, vTexCoord);
        vec3 normalMap = texture(iron_block_n, vTexCoord).rgb;
        material.normal = normalize(TBN * (normalMap * 2.0 - 1.0));
        material.smoothness = 0.95;
        material.metallic = 0.9;
        material.emissive = 0.0;
    }

    else if(id == 10060){
material.metallic = 0.95;
        material.smoothness = 0.95;
        material.ambient = 1.30;
        
        float pureYellow = float(albedoRaw.r > 0.76 && albedoRaw.g > 0.66 && albedoRaw.g < 0.90 && albedoRaw.b < 0.30 && albedoRaw.b > 0.10);
        float pureOrange = float(albedoRaw.r > 0.83 && albedoRaw.g > 0.46 && albedoRaw.g < 0.70 && albedoRaw.b < 0.23 && albedoRaw.b > 0.07);
        float lightMask = max(pureYellow, pureOrange);
        
        vec3 lightColor = vec3(3.8, 2.8, 1.2);
        float flicker = 0.92 + 0.16 * sin(frameTimeCounter * 12.0);
        material.emissive = 28.0 * lightColor * flicker * lightMask;
    }
    
 
    else if(id == 10061){
        material.metallic = 0.95;
        material.smoothness = 0.95;
        material.ambient = 1.30;
        
        float pureYellow = float(albedoRaw.r > 0.76 && albedoRaw.g > 0.66 && albedoRaw.g < 0.90 && albedoRaw.b < 0.30 && albedoRaw.b > 0.10);
        float pureOrange = float(albedoRaw.r > 0.83 && albedoRaw.g > 0.46 && albedoRaw.g < 0.70 && albedoRaw.b < 0.23 && albedoRaw.b > 0.07);
        float lightMask = max(pureYellow, pureOrange);
        
        vec3 lightColor = vec3(3.8, 2.8, 1.2);
        float flicker = 0.92 + 0.16 * sin(frameTimeCounter * 12.0);
        material.emissive = 28.0 * lightColor * flicker * lightMask;
    }
    
///ТУТ ТИПА БЫЛ КОД НО ЕГО УКРАЛИ ЕВРЕИ 

    

    
    else if(id == 11001){
        material.albedo.rgb *= 0.5;
        material.smoothness = 0.95;
        material.metallic = 1.0;
        material.emissive = 1.0;
    }
    else if(id==10057 || id==10058){ material.smoothness=0.8; material.metallic=0.6; }
    else if(id==10059){ material.smoothness=0.9; material.metallic=0.05; }
}
#endif