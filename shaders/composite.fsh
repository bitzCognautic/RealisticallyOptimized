#version 120

#define GOD_RAYS_STEPS 12 // [4 6 8 10 12 16 20 24]
#define GOD_RAYS_STRENGTH 0.30 // [0.05 0.10 0.15 0.20 0.25 0.30 0.35 0.40 0.45 0.50 0.60 0.70 0.80 0.90 1.00]

varying vec2 texCoord;

uniform sampler2D colortex0;
uniform sampler2D depthtex0;
uniform mat4 gbufferProjection;
uniform vec3 sunPosition;
uniform float viewWidth;
uniform float viewHeight;
uniform float worldTime;
uniform float rainStrength;

#include "lib/common.glsl"

vec3 godRays(vec2 uv, vec2 sunUV) {
    vec2 dir = sunUV - uv;
    float dist = length(dir);
    if (dist < 0.001) return vec3(0.0);
    dir /= dist;

    float stepSize = dist / float(GOD_RAYS_STEPS);
    vec3 accum = vec3(0.0);
    float wSum = 0.0;

    for (int i = 0; i < 24; i++) {
        if (i >= GOD_RAYS_STEPS) break;

        vec2 suv = uv + dir * stepSize * float(i + 1);

        if (suv.x < 0.0 || suv.x > 1.0 || suv.y < 0.0 || suv.y > 1.0) break;

        float sd = texture2D(depthtex0, suv).r;
        float sky = step(0.9999, sd);

        float w = sky * (1.0 - float(i) / float(GOD_RAYS_STEPS));
        vec3 sc = texture2D(colortex0, suv).rgb;
        accum += sc * w;
        wSum += w;
    }

    if (wSum < 0.001) return vec3(0.0);
    accum /= wSum;

    float intensity = GOD_RAYS_STRENGTH;
    intensity *= 1.0 - rainStrength * 0.95;
    float day = dayFactor(worldTime);
    intensity *= smoothstep(0.0, 0.15, day);
    intensity *= smoothstep(0.0, 0.15, 1.0 - day);

    return accum * intensity;
}

void main() {
    vec3 color = texture2D(colortex0, texCoord).rgb;
    float depth = texture2D(depthtex0, texCoord).r;

    vec4 sunClip = gbufferProjection * vec4(sunPosition, 1.0);
    if (sunClip.z > 0.0) {
        vec2 sunUV = sunClip.xy / sunClip.w * 0.5 + 0.5;
        if (sunUV.x > -0.05 && sunUV.x < 1.05 && sunUV.y > -0.05 && sunUV.y < 1.05) {
            color += godRays(texCoord, sunUV);
        }
    }

    gl_FragColor = vec4(color, 1.0);
}
