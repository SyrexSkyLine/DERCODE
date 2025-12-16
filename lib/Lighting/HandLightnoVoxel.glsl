//lib/Lighting/HandLightnoVoxel.glsl
//Dynamic Colored Hand Light System - Integrated Professional Version

#ifndef HANDLIGHT_NO_VOXEL_GLSL
#define HANDLIGHT_NO_VOXEL_GLSL

// Dynamic light settings (can be overridden in shaders.properties)
#ifndef HELD_LIGHT_COLOR_ENABLED
    #define HELD_LIGHT_COLOR_ENABLED 1  // [0 1] Enable colored dynamic lighting
#endif

#ifndef DYNAMIC_LIGHT_COLOR_INTENSITY
    #define DYNAMIC_LIGHT_COLOR_INTENSITY 0.8  // [0.0 0.3 0.5 0.8 1.0] Color tint intensity
#endif

// LUM/SAT settings for each light category
#define TORCH_LUM 0.65
#define TORCH_SAT 0.85

#define BEACON_LUM 0.75
#define BEACON_SAT 0.65

#define REDSTONE_LUM 0.55
#define REDSTONE_SAT 0.95

#define SOUL_LUM 0.60
#define SOUL_SAT 0.90

#define SEA_LANTERN_LUM 0.70
#define SEA_LANTERN_SAT 0.85

#define END_LUM 0.60
#define END_SAT 0.95

#define PICKLE_LUM 0.68
#define PICKLE_SAT 0.82

#define CONDUIT_LUM 0.72
#define CONDUIT_SAT 0.78

#define OCHRE_LUM 0.68
#define OCHRE_SAT 0.88

#define VERDANT_LUM 0.68
#define VERDANT_SAT 0.88

#define PEARL_LUM 0.68
#define PEARL_SAT 0.88

#define MAGMA_LUM 0.68
#define MAGMA_SAT 0.92

// Helper function: get luminance
float handlightGetLuminance(vec3 color) {
    return dot(color, vec3(0.299, 0.587, 0.114));
}

// Advanced color LUM/SAT control
vec3 colorLumSat(vec3 color, float luminance, float saturation) {
    vec3 grey = vec3(handlightGetLuminance(color));
    vec3 greyedColor = mix(grey, color, saturation);
    
    if (luminance < 0.5) {
        return mix(vec3(0.0), greyedColor, clamp(luminance * 2.0, 0.0, 1.0));
    } else {
        return mix(greyedColor, vec3(1.0), clamp((luminance - 0.5) * 2.0, 0.0, 1.0));
    }
}

// Check if item ID is handled (left hand / offhand)
bool isLightHandledLeft(int heldItemId2) {
    return (heldItemId2 == 13001 ||  // Torch group
            heldItemId2 == 13002 ||  // Beacon
            heldItemId2 == 13003 ||  // Redstone Torch
            heldItemId2 == 13004 ||  // Soul Lantern group
            heldItemId2 == 13005 ||  // Sea Lantern
            heldItemId2 == 13006 ||  // End Rod group
            heldItemId2 == 13007 ||  // Sea Pickle
            heldItemId2 == 13008 ||  // Conduit
            heldItemId2 == 13009 ||  // Ochre Froglight
            heldItemId2 == 13010 ||  // Verdant Froglight
            heldItemId2 == 13011 ||  // Pearlescent Froglight
            heldItemId2 == 13012);   // Magma Block
}

bool isLightHandledRight(int heldItemId) {
    return (heldItemId == 13001 ||  // Torch group
            heldItemId == 13002 ||  // Beacon
            heldItemId == 13003 ||  // Redstone Torch
            heldItemId == 13004 ||  // Soul Lantern group
            heldItemId == 13005 ||  // Sea Lantern
            heldItemId == 13006 ||  // End Rod group
            heldItemId == 13007 ||  // Sea Pickle
            heldItemId == 13008 ||  // Conduit
            heldItemId == 13009 ||  // Ochre Froglight
            heldItemId == 13010 ||  // Verdant Froglight
            heldItemId == 13011 ||  // Pearlescent Froglight
            heldItemId == 13012);   // Magma Block
}

// Low light items (for special handling)
bool isLightHandledLeft1(int heldItemId2) {
    return (heldItemId2 == 13003 ||  // Redstone Torch
            heldItemId2 == 13007 ||  // Sea Pickle
            heldItemId2 == 13008 ||  // Conduit
            heldItemId2 == 13012);   // Magma Block
}

bool isLightHandledRight1(int heldItemId) {
    return (heldItemId == 13003 ||  // Redstone Torch
            heldItemId == 13007 ||  // Sea Pickle
            heldItemId == 13008 ||  // Conduit
            heldItemId == 13012);   // Magma Block
}

bool isLightHandled() {
    return isLightHandledLeft(heldItemId2) || isLightHandledRight(heldItemId);
}

bool isLightHandledLow() {
    return isLightHandledLeft1(heldItemId2) || isLightHandledRight1(heldItemId);
}

// Get hand light color based on item ID
void getHandLightColor(inout vec3 lightingColor, int heldItem) {
    
    // Group 1: Torch, Glowstone, Jack o'Lantern, Lantern, Campfire, Shroomlight, Lava Bucket, Blaze Rod
    if (heldItem == 13001) {
        lightingColor = vec3(1.0, 0.3686, 0.0);
        lightingColor = colorLumSat(lightingColor, TORCH_LUM, TORCH_SAT);
    }
    // Beacon
    else if (heldItem == 13002) {
        lightingColor = vec3(0.4863, 0.7686, 0.9882);
        lightingColor = colorLumSat(lightingColor, BEACON_LUM, BEACON_SAT);
    }
    // Redstone Torch
    else if (heldItem == 13003) {
        lightingColor = vec3(0.8863, 0.0235, 0.0235);
        lightingColor = colorLumSat(lightingColor, REDSTONE_LUM, REDSTONE_SAT);
    }
    // Soul Lantern, Soul Campfire, Soul Torch
    else if (heldItem == 13004) {
        lightingColor = vec3(0.0, 0.1843, 1.0);
        lightingColor = colorLumSat(lightingColor, SOUL_LUM, SOUL_SAT);
    }
    // Sea Lantern
    else if (heldItem == 13005) {
        lightingColor = vec3(0.0, 0.8549, 0.6667);
        lightingColor = colorLumSat(lightingColor, SEA_LANTERN_LUM, SEA_LANTERN_SAT);
    }
    // End Rod, Crying Obsidian, Nether Star
    else if (heldItem == 13006) {
        lightingColor = vec3(0.9765, 0.3412, 1.0);
        lightingColor = colorLumSat(lightingColor, END_LUM, END_SAT);
    }
    // Sea Pickle
    else if (heldItem == 13007) {
        lightingColor = vec3(0.8275, 0.8314, 0.4118);
        lightingColor = colorLumSat(lightingColor, PICKLE_LUM, PICKLE_SAT);
    }
    // Conduit
    else if (heldItem == 13008) {
        lightingColor = vec3(0.9922, 0.9255, 0.7059);
        lightingColor = colorLumSat(lightingColor, CONDUIT_LUM, CONDUIT_SAT);
    }
    // Ochre Froglight
    else if (heldItem == 13009) {
        lightingColor = vec3(0.8275, 0.8314, 0.4118);
        lightingColor = colorLumSat(lightingColor, OCHRE_LUM, OCHRE_SAT);
    }
    // Verdant Froglight
    else if (heldItem == 13010) {
        lightingColor = vec3(0.4941, 0.8314, 0.4118);
        lightingColor = colorLumSat(lightingColor, VERDANT_LUM, VERDANT_SAT);
    }
    // Pearlescent Froglight
    else if (heldItem == 13011) {
        lightingColor = vec3(0.7294, 0.5412, 0.9725);
        lightingColor = colorLumSat(lightingColor, PEARL_LUM, PEARL_SAT);
    }
    // Magma Block
    else if (heldItem == 13012) {
        lightingColor = vec3(1.0, 0.2353, 0.0);
        lightingColor = colorLumSat(lightingColor, MAGMA_LUM, MAGMA_SAT);
    }
}

// Screen-space fade between hands with smooth blending
void changeLightingColorByHand(inout vec3 lightingColor) {
    #if HELD_LIGHT_COLOR_ENABLED == 0
        lightingColor = vec3(1.0);
        return;
    #endif
    
    vec3 leftLightingColor = vec3(0.0);
    vec3 rightLightingColor = vec3(0.0);
    
    // Calculate screen-space fade (0 = left, 1 = right)
    float xpos = (gl_FragCoord.x / viewWidth) * 2.0 - 1.0;
    float fade = clamp((xpos * 2.0 + 1.0) * 0.5, 0.0, 1.0);
    
    // Get colors for each hand
    bool hasLeftLight = isLightHandledLeft(heldItemId2) || isLightHandledLeft1(heldItemId2);
    bool hasRightLight = isLightHandledRight(heldItemId) || isLightHandledRight1(heldItemId);
    
    if (hasLeftLight) {
        getHandLightColor(leftLightingColor, heldItemId2);
    }
    
    if (hasRightLight) {
        getHandLightColor(rightLightingColor, heldItemId);
    }
    
    // Blend based on which hands have lights
    if (hasLeftLight && hasRightLight) {
        // Both hands: smooth blend across screen
        lightingColor = mix(leftLightingColor, rightLightingColor, fade);
    } else if (hasLeftLight) {
        // Only left hand
        lightingColor = leftLightingColor;
    } else if (hasRightLight) {
        // Only right hand
        lightingColor = rightLightingColor;
    }
}

// Calculate dynamic light level based on distance
float calcDynamicLightLevel(float dist, int heldLightLevel) {
    if (heldLightLevel <= 0) return 0.0;
    float maxRadius = float(heldLightLevel);
    if (dist >= maxRadius) return 0.0;
    float lightAtDist = float(heldLightLevel) - dist;
    return clamp(lightAtDist / 15.0, 0.0, 1.0);
}

// Adjust lightmap with dynamic lighting
vec2 adjustLightmapWithDynamicLight(vec2 lmcoord, float dist, int heldLight, int heldLight2) {
    int maxHeld = max(heldLight, heldLight2);
    if (maxHeld <= 0) return lmcoord;
    
    float dynLight = calcDynamicLightLevel(dist, maxHeld);
    float newBlockLight = max(lmcoord.x, dynLight);
    
    return vec2(newBlockLight, lmcoord.y);
}

// Apply dynamic light color tint to surface
vec3 applyDynamicLightColor(vec3 albedo, float originalBlockLight, float currentBlockLight, vec3 lightColor) {
    #if HELD_LIGHT_COLOR_ENABLED == 0
        return albedo;
    #endif
    
    // Calculate how much dynamic light was added
    float dynamicLightAmount = max(0.0, currentBlockLight - originalBlockLight);
    
    if (dynamicLightAmount < 0.01) return albedo;
    
    // Apply color tint based on dynamic light amount
    float tintStrength = dynamicLightAmount * DYNAMIC_LIGHT_COLOR_INTENSITY;
    return albedo * mix(vec3(1.0), lightColor, tintStrength);
}

#endif //HANDLIGHT_NO_VOXEL_GLSL