extern vec2 shadow_center;
extern vec2 shadow_radii;
extern float time;

float rand(vec2 co) {
    return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);
}

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
    vec2 offset = screen_coords - shadow_center;
    vec2 dither_coords = floor(offset / 3); // faz os "pixels" de dithering entrarem na escala do jogo
    vec2 dither_offset = (dither_coords + 0.5) * 3;
    vec2 normalized_pos = dither_offset / shadow_radii;
    float dist = pow(length(normalized_pos), 2);
    float shadow_intensity = 1.0 - dist;
    const int bayer_n = 4;
    // [    -0.5,       0,  -0.375,   0.125 ] //
    // [    0.25,   -0.25,   0.375, - 0.125 ] //
    // [ -0.3125,  0.1875, -0.4375,  0.0625 ] //
    // [  0.4375, -0.0625,  0.3125, -0.1875 ] //
    mat4 bayer_matrix = mat4(
        -0.5, 0.25, -0.3125, 0.4375,
        0.0, -0.25, 0.1875, -0.0625,
        -0.375, 0.375, -0.4375, 0.3125,
        0.125, -0.125, 0.0625, -0.1875
    );
    int j = int(mod(dither_coords.x, bayer_n));
    int i = int(mod(dither_coords.y, bayer_n));

    float beat = floor(mod(time, 2)); // se alterna entre 0 e 1 a cada segundo
    float noise = rand(dither_coords + vec2(floor(time))); // se aleatoriza entre 0 e 1 a cada segundo
    shadow_intensity += (beat + noise * 0.75) * 0.15;

    float bayer_value = bayer_matrix[j][i] + 0.5;
    if (shadow_intensity < bayer_value) {
        return vec4(0.0); // transparente, para ser a parte que não está em sombra
    }

    return vec4(color.xyz, shadow_intensity * 0.6); // colocar um degradêzinho de cria
}
