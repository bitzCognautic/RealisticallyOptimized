#version 120

varying vec2 vTex;
varying vec3 vNormal;
varying vec3 vWorldPos;
varying vec4 vColor;

uniform sampler2D texture;
uniform vec3 sunPosition;
uniform float worldTime;

#include "lib/common.glsl"
#include "lib/shadows.glsl"

void main() {
    vec4 albedo = texture2D(texture, vTex) * vColor;

    vec3 n = normalize(vNormal);
    vec3 l = normalize(sunPosition);
    float ndotl = max(dot(n, l), 0.0);
    float toon = toonRamp(ndotl);
    float shadow = getShadowFactor(vWorldPos);

    float t = dayFactor(worldTime);
    float tint = mix(NIGHT_TINT, DAY_TINT, t);
    vec3 sunWarm = mix(vec3(1.00, 0.98, 0.95), vec3(1.12, 0.90, 0.70), t);

    vec3 base = albedo.rgb * (0.26 + 0.74 * toon * shadow);
    base *= sunWarm;
    base += vec3(0.02, 0.04, 0.06) * (0.5 + 0.5 * sin(worldTime * 0.03 + vTex.x * 20.0 + vTex.y * 16.0));

    base = applyVibrance(base, VIBRANCE + 0.05) * tint;
    gl_FragColor = vec4(base, albedo.a);
}
