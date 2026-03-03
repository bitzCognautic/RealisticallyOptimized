#ifndef SHADOWS_GLSL
#define SHADOWS_GLSL

uniform sampler2D shadowtex0;
uniform mat4 shadowModelView;
uniform mat4 shadowProjection;

float getShadowFactor(vec3 playerPos) {
    vec4 shadowClip = shadowProjection * shadowModelView * vec4(playerPos, 1.0);
    vec3 p = shadowClip.xyz / shadowClip.w;
    p = p * 0.5 + 0.5;

    if (p.x <= 0.0 || p.x >= 1.0 || p.y <= 0.0 || p.y >= 1.0 || p.z <= 0.0 || p.z >= 1.0) {
        return 1.0;
    }

    float bias = 0.0015;
    vec2 texel = vec2(1.0 / 2048.0);
    float vis = 0.0;

    for (int x = -1; x <= 1; ++x) {
        for (int y = -1; y <= 1; ++y) {
            float d = texture2D(shadowtex0, p.xy + vec2(x, y) * texel).r;
            vis += ((p.z - bias) <= d) ? 1.0 : (1.0 - SHADOW_DARKNESS);
        }
    }

    return vis / 9.0;
}

#endif
