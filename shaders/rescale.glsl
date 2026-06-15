extern vec2 new_res;

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
    vec2 pixel_size = 1.0 / new_res;
    vec2 new_coords = floor(texture_coords * new_res) / new_res;
    new_coords += pixel_size * 0.5;
    return Texel(texture, new_coords) * color;
}
