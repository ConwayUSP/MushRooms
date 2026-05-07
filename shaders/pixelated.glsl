extern vec2 res;

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
    // Transforma 0..1 em 0..Resoluçao
    vec2 grid_coords = vec2(texture_coords.x * res.x, texture_coords.y * res.y);

    // Arredonda para o pixel mais próximo
    grid_coords = floor(grid_coords);

    // Volta para o intervalo 0..1
    vec2 perfect_coords = (grid_coords + 0.5) / res;

    return Texel(texture, perfect_coords) * color;
}
