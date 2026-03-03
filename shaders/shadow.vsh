#version 120

const int shadowMapResolution = 2048;
const float shadowDistance = 160.0;

void main() {
    gl_Position = ftransform();
}
