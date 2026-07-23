#ifndef COMMON_GLSL
#define COMMON_GLSL

#ifndef SHADOW_DARKNESS
#define SHADOW_DARKNESS 0.85
#endif
#ifndef TOON_STEPS
#define TOON_STEPS 4.0
#endif
#ifndef VIBRANCE
#define VIBRANCE 1.30
#endif
#ifndef DAY_TINT
#define DAY_TINT 1.08
#endif
#ifndef NIGHT_TINT
#define NIGHT_TINT 0.90
#endif
#ifndef GLOWING_ORE_MULT
#define GLOWING_ORE_MULT 1.00 // [0.15 0.20 0.25 0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.10 1.20 1.30 1.40 1.50 1.60 1.70 1.80 1.90 2.00]
#endif
#ifndef GOD_RAYS_STEPS
#define GOD_RAYS_STEPS 8
#endif
#ifndef GOD_RAYS_STRENGTH
#define GOD_RAYS_STRENGTH 0.12
#endif
float toonRamp(float x) {
    float steps = max(1.0, TOON_STEPS);
    return floor(clamp(x, 0.0, 1.0) * steps) / steps;
}

vec3 applyVibrance(vec3 c, float amount) {
    float luma = dot(c, vec3(0.2126, 0.7152, 0.0722));
    return mix(vec3(luma), c, amount);
}

float dayFactor(float worldTime) {
    return clamp(sin((worldTime / 24000.0) * 6.2831853) * 0.5 + 0.5, 0.0, 1.0);
}

#endif
