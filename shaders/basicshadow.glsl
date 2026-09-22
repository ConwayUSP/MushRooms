extern vec2 shadow_center;
extern vec2 shadow_radii;
extern float zoom;
extern vec2 viewport_size;

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
    vec2 viewport_center = viewport_size * 0.5;
    vec2 unzoomed_coords = (screen_coords - viewport_center) / max(zoom, 0.0001) + viewport_center;
    vec2 offset = unzoomed_coords - shadow_center;
    vec2 px_coords = floor(offset / 3); // faz os "pixels" entrarem na escala do jogo
    vec2 px_offset = (px_coords + 0.5) * 3;
    vec2 normalized_pos = px_offset / shadow_radii;
    float dist = length(normalized_pos);
    float shadow_intensity = step(0.25, 1.0 - dist) * 0.25 + (0.2 - length(offset / shadow_radii) * 0.2);

    return vec4(color.xyz, shadow_intensity);
}
