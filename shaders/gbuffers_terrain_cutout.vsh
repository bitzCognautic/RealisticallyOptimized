#version 120

varying vec2 vTex;
varying vec2 vLm;
varying vec3 vNormal;
varying vec3 vWorldPos;
varying vec4 vColor;

uniform mat4 gbufferModelViewInverse;
uniform float frameTimeCounter;

attribute vec4 mc_Entity;

float leafMask(float id) {
    return 1.0 - step(0.5, abs(id - 1004.0));
}

void main() {
    vec3 pos = gl_Vertex.xyz;
    float vid = floor(mc_Entity.x + 0.5);
    float mask = leafMask(vid);

    float gust = sin(frameTimeCounter * 2.0 + pos.x * 0.12 + pos.z * 0.14);
    float sway = sin(frameTimeCounter * 1.1 + pos.x * 0.08 - pos.z * 0.10);
    float topPart = smoothstep(0.1, 0.9, gl_MultiTexCoord0.y);

    pos.x += (gust * 0.04 + sway * 0.02) * mask * topPart;
    pos.z += (gust * 0.02) * mask * topPart;

    vec4 viewPos = gl_ModelViewMatrix * vec4(pos, 1.0);
    gl_Position = gl_ProjectionMatrix * viewPos;

    vTex = gl_MultiTexCoord0.xy;
    vLm = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
    vNormal = normalize(gl_NormalMatrix * gl_Normal);
    vWorldPos = (gbufferModelViewInverse * viewPos).xyz;
    vColor = gl_Color;
}
