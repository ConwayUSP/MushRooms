extern float time;
// x = u_min, y = v_min, z = u_width, w = v_height
extern vec4 quad_info;

float hash(vec2 p) {
    p = fract(p * vec2(123.34, 456.21));
    p += dot(p, p + 45.32);
    return fract(p.x * p.y);
}

vec2 cellOffset(vec2 cell_id) {
    return vec2(
        hash(cell_id + vec2(1.0, 2.0)),
        hash(cell_id + vec2(3.0, 4.0))
    ) * 2.0 - 1.0;
}

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
    vec4 texcolor = Texel(texture, texture_coords);
    if (texcolor.a == 0.0) {
        return texcolor;
    }

    vec2 local_uv = (texture_coords - quad_info.xy) / quad_info.zw;

    float gradient_mask = smoothstep(0.4, 1.0, local_uv.y);
    float pulse = (sin(time * 4.0) * 0.1) + 0.9;
    float gradient = gradient_mask * pulse;

    // partículas no próprio shader
    float grid_size = 12.0;
    vec2 particle_uv = local_uv;

    // adiciona movimento horizontal suave e variável
    float horizontal_wobble_speed = 0.5;
    float horizontal_offset = sin(time * horizontal_wobble_speed + local_uv.y * 10.0) * 0.02;
    particle_uv.x += horizontal_offset;
    particle_uv.y += time * 0.6;
    vec2 cell_id = floor(particle_uv * grid_size);
    vec2 cell_local = fract(particle_uv * grid_size);
    vec2 random_offset = cellOffset(cell_id) * 0.3;
    vec2 decentralized_cell_local = cell_local + random_offset;
    float random_val = fract(sin(dot(cell_id, vec2(12.9898, 78.233))) * 43758.5453);
    float is_particle = step(0.85, random_val);
    float particle_size = smoothstep(0.3, 0.9, local_uv.y);
    vec2 center_dist = abs(decentralized_cell_local - 0.5);
    float square_mask = step(center_dist.x, particle_size * 0.35) * step(center_dist.y, particle_size * 0.35);

    float particle_effect = is_particle * square_mask;
    particle_effect *= smoothstep(0.35, 0.7, local_uv.y);

    vec3 heal_color = vec3(0.2, 0.8, 0.35);
    float total_effect = clamp(gradient + particle_effect, 0.0, 1.0);
    vec3 final_rgb = mix(texcolor.rgb, heal_color, total_effect * 0.67);

    return vec4(final_rgb, texcolor.a) * color;
}
