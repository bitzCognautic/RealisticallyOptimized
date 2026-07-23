#version 120

#define OUTLINE_WIDTH 1 // [1 2 3 4]
#define OUTLINE_BRIGHTNESS 1.50 // [0.50 0.75 1.00 1.25 1.50 1.75 2.00 2.50 3.00 4.00]
#define BORDER_EXPERIMENTAL

varying vec2 vTex;

uniform sampler2D colortex0;
uniform sampler2D depthtex0;
uniform float viewWidth;
uniform float viewHeight;
uniform float near;
uniform float far;
uniform float worldTime;
uniform float rainStrength;

#include "lib/common.glsl"

float getLinearDepth(float depth) {
    return (2.0 * near) / (far + near - depth * (far - near));
}

vec3 tonemapReinhard(vec3 c) {
    return c / (c + vec3(1.0));
}

const vec2 worldOutlineOffset[4] = vec2[4](
    vec2(-1.0, 1.0),
    vec2( 0.0, 1.0),
    vec2( 1.0, 1.0),
    vec2( 1.0, 0.0)
);

void doWorldOutline(inout vec3 color, float linearZ0) {
    vec2 scale = vec2(1.0 / viewWidth, 1.0 / viewHeight);

    float outlined = 1.0;
    float z = max(linearZ0 * far, 0.0001);
    float totalz = 0.0;
    float maxz = 0.0;
    int sampleCount = int(OUTLINE_WIDTH) * 4;

    for (int i = 0; i < 16; i++) {
        if (i >= sampleCount) break;
        vec2 offset = (1.0 + floor(float(i) / 4.0)) * scale * worldOutlineOffset[int(mod(float(i), 4.0))];
        float depthCheckP = getLinearDepth(texture2D(depthtex0, vTex + offset).r) * far;
        float depthCheckN = getLinearDepth(texture2D(depthtex0, vTex - offset).r) * far;

        outlined *= clamp(1.0 - ((depthCheckP + depthCheckN) - z * 2.0) * 32.0 / z, 0.0, 1.0);

        if (i <= 4) maxz = max(maxz, max(depthCheckP, depthCheckN));
        totalz += depthCheckP + depthCheckN;
    }

    float outlinea = 1.0 - clamp((z * 8.0 - totalz) * 64.0 / z, 0.0, 1.0) * clamp(1.0 - ((z * 8.0 - totalz) * 32.0 - 1.0) / z, 0.0, 1.0);
    float outlineb = clamp(1.0 + 8.0 * (z - maxz) / z, 0.0, 1.0);
    float outlinec = clamp(1.0 + 64.0 * (z - maxz) / z, 0.0, 1.0);

    float outline = (0.35 * (outlinea * outlineb) + 0.65) * (0.75 * (1.0 - outlined) * outlinec + 1.0);
    outline -= 1.0;

    outline *= OUTLINE_BRIGHTNESS / max(float(OUTLINE_WIDTH), 1.0);
    if (outline < 0.0) outline = -outline * 0.25;

    color += min(color * outline * 2.5, vec3(max(outline, 0.0)));
}

void main() {
    vec4 col = texture2D(colortex0, vTex);
    float t = dayFactor(worldTime);

    float rawDepth = texture2D(depthtex0, vTex).r;
    float skyMask = step(0.99995, rawDepth);

    #ifdef BORDER_EXPERIMENTAL
        float linearZ0 = getLinearDepth(rawDepth);
        doWorldOutline(col.rgb, linearZ0);
    #endif

    col.rgb = applyVibrance(col.rgb, VIBRANCE + 0.15);

    col.rgb = tonemapReinhard(col.rgb);

    float skyBoost = mix(1.35, 1.20, t);
    col.rgb *= mix(1.0, skyBoost, skyMask);

    col.rgb *= mix(0.65, 1.0, t);

    float blueFactor = clamp((1.0 - t) * 0.70 + rainStrength * 0.55, 0.0, 1.0);
    vec3 blueTint = vec3(0.86, 0.94, 1.16);
    col.rgb *= mix(vec3(1.0), blueTint, blueFactor * 0.50);

    gl_FragColor = col;
}
