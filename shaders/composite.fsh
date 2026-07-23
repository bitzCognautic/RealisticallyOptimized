#version 120

#define GOD_RAYS_STEPS 8 // [4 6 8 10 12 16 20 24]
#define GOD_RAYS_STRENGTH 0.12 // [0.04 0.06 0.08 0.10 0.12 0.15 0.18 0.22 0.26 0.30 0.35 0.40 0.50 0.60 0.80]

varying vec2 texCoord;

uniform sampler2D colortex0;
uniform sampler2D depthtex0;
uniform mat4 gbufferProjection;
uniform vec3 sunPosition;
uniform float near;
uniform float far;
uniform float worldTime;
uniform float rainStrength;

#include "lib/common.glsl"

void main() {
    vec3 color = texture2D(colortex0, texCoord).rgb;
    float depth = texture2D(depthtex0, texCoord).r;

    float t = dayFactor(worldTime);
    float intensity = GOD_RAYS_STRENGTH;
    intensity *= 1.0 - rainStrength * 0.95;
    intensity *= smoothstep(0.0, 0.2, t);
    intensity *= smoothstep(0.0, 0.2, 1.0 - t);
    if (intensity < 0.005) {
        gl_FragColor = vec4(color, 1.0);
        return;
    }

    float luma = dot(color, vec3(0.2126, 0.7152, 0.0722));

    if (depth > 0.99 || luma > 0.85) {
        gl_FragColor = vec4(color, 1.0);
        return;
    }

    vec3 sunV = sunPosition;
    vec4 pClip = gbufferProjection * vec4(sunV, 1.0);
    if (pClip.z < 0.0 || abs(pClip.w) < 0.01) {
        gl_FragColor = vec4(color, 1.0);
        return;
    }

    vec2 sunUV = pClip.xy / pClip.w * 0.5 + 0.5;
    if (sunUV.x < 0.0 || sunUV.x > 1.0 || sunUV.y < 0.0 || sunUV.y > 1.0) {
        gl_FragColor = vec4(color, 1.0);
        return;
    }

    float sunVis = texture2D(depthtex0, sunUV).r;
    if (sunVis < 0.99) {
        gl_FragColor = vec4(color, 1.0);
        return;
    }

    vec2 dir = sunUV - texCoord;
    float dist = length(dir);
    if (dist < 0.001) {
        gl_FragColor = vec4(color, 1.0);
        return;
    }
    dir /= dist;

    float stepSize = dist / float(GOD_RAYS_STEPS);
    vec3 accum = vec3(0.0);
    float wSum = 0.0;

    for (int i = 0; i < 24; i++) {
        if (i >= GOD_RAYS_STEPS) break;

        vec2 suv = texCoord + dir * stepSize * float(i + 1);
        if (suv.x < 0.0 || suv.x > 1.0 || suv.y < 0.0 || suv.y > 1.0) break;

        float sd = texture2D(depthtex0, suv).r;
        float w = step(0.99, sd) * (1.0 - float(i) / float(GOD_RAYS_STEPS));
        vec3 sc = texture2D(colortex0, suv).rgb;
        accum += sc * w;
        wSum += w;
    }

    if (wSum > 0.001) {
        accum /= wSum;
        float al = dot(accum, vec3(0.2126, 0.7152, 0.0722));
        if (al > 0.02) {
            color += accum * intensity;
        }
    }

    gl_FragColor = vec4(color, 1.0);
}
