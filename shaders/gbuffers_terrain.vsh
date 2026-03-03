#version 120

varying vec2 vTex;
varying vec2 vLm;
varying vec3 vNormal;
varying vec3 vWorldPos;
varying vec4 vColor;
varying float vMatId;

uniform mat4 gbufferModelViewInverse;
uniform float frameTimeCounter;

attribute vec4 mc_Entity;

float vegetationMask(float id) {
    float m = 0.0;
    m += 1.0 - step(0.5, abs(id - 1001.0)); // grass/fern
    m += 1.0 - step(0.5, abs(id - 1002.0)); // flowers
    m += 1.0 - step(0.5, abs(id - 1003.0)); // crops
    m += 1.0 - step(0.5, abs(id - 1004.0)); // leaves
    return clamp(m, 0.0, 1.0);
}

void main() {
    vec3 pos = gl_Vertex.xyz;
    float vid = floor(mc_Entity.x + 0.5);
    float mask = vegetationMask(vid);

    float gust = sin(frameTimeCounter * 2.2 + pos.x * 0.18 + pos.z * 0.16);
    float sway = sin(frameTimeCounter * 1.3 + pos.x * 0.09 - pos.z * 0.11);
    float topPart = smoothstep(0.15, 1.0, gl_MultiTexCoord0.y);

    pos.x += (gust * 0.05 + sway * 0.03) * mask * topPart;
    pos.z += (gust * 0.03) * mask * topPart;

    vec4 viewPos = gl_ModelViewMatrix * vec4(pos, 1.0);
    gl_Position = gl_ProjectionMatrix * viewPos;

    vTex = gl_MultiTexCoord0.xy;
    vLm = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
    vNormal = normalize(gl_NormalMatrix * gl_Normal);
    vWorldPos = (gbufferModelViewInverse * viewPos).xyz;
    vColor = gl_Color;
    vMatId = vid;
}
