vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
    // distância "normalizada" para o centro da textura
    float d = distance(texture_coords, vec2(0.5, 0.5)) * 1.5;
    // definindo a força da sombra como proporcional à distância para o centro
    float vignette_alpha = d;
    vignette_alpha = max(0.0, vignette_alpha - 0.45);
    vignette_alpha = min(1.0, pow(vignette_alpha, 1.55) * 1.67);
    vec4 result = vec4(0.1, 0.04, 0.15, vignette_alpha);

    return result;
}
