#version 120

varying vec2 vTex;
varying vec3 vNormal;
varying vec3 vWorldPos;
varying vec4 vColor;

uniform mat4 gbufferModelViewInverse;

void main() {
    vec4 viewPos = gl_ModelViewMatrix * gl_Vertex;
    gl_Position = gl_ProjectionMatrix * viewPos;

    vTex = gl_MultiTexCoord0.xy;
    vNormal = normalize(gl_NormalMatrix * gl_Normal);
    vWorldPos = (gbufferModelViewInverse * viewPos).xyz;
    vColor = gl_Color;
}
