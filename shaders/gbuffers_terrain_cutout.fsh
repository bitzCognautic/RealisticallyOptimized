#version 120

varying vec2 vTex;
varying vec2 vLm;
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

    if (albedo.a < 0.1) discard;

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
    c = applyVibrance(c * sunWarm, VIBRANCE) * tint;

    gl_FragColor = vec4(c, albedo.a);
}
