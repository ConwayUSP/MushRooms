extern vec4 glow_color;
extern float steps;
extern float grid_size;
extern float time;

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
    vec2 pixelated_uv = floor(texture_coords * grid_size) / grid_size;
    vec2 center_of_pixel = pixelated_uv + vec2(0.5 / grid_size);
    // distância "normalizada" para o centro da textura
    float d = distance(center_of_pixel, vec2(0.5, 0.5)) * 2.0;
    float oscilation = sin(time * 2) * sqrt(steps) / grid_size / 5;
    // criando transições rígidas, quanto mais longe do centro, maior o valor
    float d_step = floor((d + oscilation) * steps);
    // definindo a força do brilho inversamente proporcional ao centro
    float glow_alpha = max(0.0, 1.0 - (d_step / steps) - oscilation * 3);
    vec4 glow = vec4(glow_color.rgb, pow(glow_alpha, 3.0) * glow_color.a);

    vec4 result = glow;

    return result;
}
