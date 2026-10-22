// transição de tela padrão - cortina em camadas
// fase 0: a cortina desce do topo e cobre a cena antiga
// fase 1: a cortina sobe da base e revela a nova cena

extern float progress;
extern float phase;
extern float phaseProgress;
extern float time;
extern vec2 resolution;

float covered(float v, float front) {
    return step(v, front);
}

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
    float maxV = 1.0 + 0.25 * resolution.x / resolution.y;
    float v = clamp(screen_coords.y / max(resolution.y, 1.0)
                + (screen_coords.x / max(resolution.y, 1.0)) * 0.2, 0.0, maxV) / maxV;
    v = v + sin((screen_coords.x + time * 1000) / (resolution.x * 0.05) + time * 3) * 0.015;

    float e = 1.0 - (1.0 - phaseProgress) * (1.0 - phaseProgress);
    float front = 1.1 * (phase < 0.5 ? e : 1.0 - e);

    vec3 blackout = vec3(0.03, 0.03, 0.08);
    vec3 red = vec3(1.0, 0.45, 0.54);
    vec3 orange = vec3(0.95, 0.55, 0.34);
    vec3 yellow = vec3(0.9, 0.9, 0.24);
    vec3 cyan = vec3(0.5, 0.95, 0.76);
    vec3 blue = vec3(0.55, 0.55, 1.0);
    vec3 white = vec3(0.95, 0.95, 1.0);

    float a1 = covered(v + sin(0.1 + time * 4.5) * 0.01, front);
    float a2 = covered(v + sin(0.3 + time * 3) * 0.01, front - 0.02);
    float a3 = covered(v + sin(0.5 + time * 4) * 0.01, front - 0.035);
    float a4 = covered(v + sin(0.666 + time * 2) * 0.01, front - 0.05);
    float a5 = covered(v + sin(1.2 + time * 3) * 0.01, front - 0.065);
    float a6 = covered(v + sin(1.4 + time * 3.5) * 0.01, front - 0.08);
    float a7 = covered(v + sin(2.0 + time * 2.5) * 0.01, front - 0.09);

    vec3 rgb = white;
    rgb = mix(rgb, blue, a2);
    rgb = mix(rgb, cyan, a3);
    rgb = mix(rgb, yellow, a4);
    rgb = mix(rgb, orange, a5);
    rgb = mix(rgb, red, a6);
    rgb = mix(rgb, blackout, a7);

    return vec4(rgb, a1);
}
