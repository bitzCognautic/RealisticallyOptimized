#version 120

varying vec2 vTex;
varying vec2 vLm;
varying vec3 vNormal;
varying vec3 vWorldPos;
varying vec4 vColor;
varying float vMatId;

uniform sampler2D texture;
uniform vec3 sunPosition;
uniform float worldTime;

#include "lib/common.glsl"
#include "lib/shadows.glsl"

float oreGlowMask(float id, float target) {
    return 1.0 - step(0.5, abs(id - target));
}

float orePixelMask(float id, vec3 a) {
    float m = 0.0;
    if (oreGlowMask(id, 1101.0) > 0.5) m = step(0.15, a.r - a.b); // Iron
    if (oreGlowMask(id, 1102.0) > 0.5) m = max(step(0.15, a.g - a.b), step(0.99, a.r)); // Gold
    if (oreGlowMask(id, 1103.0) > 0.5) m = step(0.05, max(a.r * 0.5, a.g) - a.b); // Copper
    if (oreGlowMask(id, 1104.0) > 0.5) m = step(0.20, a.b - a.r); // Lapis
    if (oreGlowMask(id, 1105.0) > 0.5) {
        float dif = max(max(a.r, a.g), a.b) - min(min(a.r, a.g), a.b);
        m = max(step(0.40, dif), step(0.85, a.b)); // Emerald
    }
    if (oreGlowMask(id, 1106.0) > 0.5) m = max(step(1.5, a.b / max(a.r, 0.001)), step(0.80, a.b)); // Diamond
    if (oreGlowMask(id, 1107.0) > 0.5) m = step(0.02, abs(a.g - a.b)); // Nether Quartz
    if (oreGlowMask(id, 1108.0) > 0.5) m = step(0.02, abs(a.g - a.b)); // Nether Gold
    if (oreGlowMask(id, 1109.0) > 0.5) m = step(0.20, a.r - a.g); // Redstone
    return m;
}

vec3 oreGlowColor(float id, vec3 a) {
    vec3 c = vec3(0.0);
    c += oreGlowMask(id, 1101.0) * (vec3(1.7, 0.9, 0.4) * 0.45); // Iron
    c += oreGlowMask(id, 1102.0) * (vec3(1.7, 1.1, 0.2) * 0.45); // Gold
    c += oreGlowMask(id, 1103.0) * (vec3(1.7, 0.8, 0.4) * 0.45); // Copper
    c += oreGlowMask(id, 1104.0) * (vec3(0.75, 0.75, 3.0) * 0.20); // Lapis
    c += oreGlowMask(id, 1105.0) * (vec3(0.5, 3.5, 0.5) * 0.30); // Emerald
    c += oreGlowMask(id, 1106.0) * (vec3(0.5, 2.0, 2.0) * 0.40); // Diamond
    c += oreGlowMask(id, 1107.0) * (vec3(1.5, 1.5, 1.5) * 0.30); // Nether Quartz
    c += oreGlowMask(id, 1108.0) * (vec3(1.7, 1.1, 0.2) * 0.45); // Nether Gold
    c += oreGlowMask(id, 1109.0) * (vec3(2.2, 0.2, 0.1) * 0.30); // Redstone
    return c * orePixelMask(id, a);
}

float lightSourceMask(float id) {
    return 1.0 - step(0.5, abs(id - 1201.0));
}

void main() {
    vec4 albedo = texture2D(texture, vTex) * vColor;

    vec3 n = normalize(vNormal);
    vec3 l = normalize(sunPosition);
    float ndotl = max(dot(n, l), 0.0);

    float toon = toonRamp(ndotl);
    float shadow = getShadowFactor(vWorldPos);

    float t = dayFactor(worldTime);
    float baked = max(vLm.x * 0.8, vLm.y * 0.95);
    float blockLight = clamp(vLm.x, 0.0, 1.0);
    float localLight = pow(blockLight, 1.10) * mix(1.60, 0.90, t);
    float tint = mix(NIGHT_TINT, DAY_TINT, t);
    vec3 sunWarm = mix(vec3(1.00, 0.98, 0.95), vec3(1.14, 0.92, 0.72), t);

    vec3 c = albedo.rgb * (0.18 + 0.82 * toon * shadow + baked * 0.35 + localLight);
    vec3 oreGlow = oreGlowColor(vMatId, albedo.rgb) * GLOWING_ORE_MULT;
    c += oreGlow;
    c += albedo.rgb * max(max(oreGlow.r, oreGlow.g), oreGlow.b) * 0.30;
    // Complementary-style redstone treatment: keep red dominant while glowing.
    if (oreGlowMask(vMatId, 1109.0) > 0.5) c.gb *= 1.0 - 0.75 * min(GLOWING_ORE_MULT, 1.0);
    c += albedo.rgb * lightSourceMask(vMatId) * mix(1.35, 1.05, t);
    c = applyVibrance(c * sunWarm, VIBRANCE) * tint;

    gl_FragColor = vec4(c, albedo.a);
}
