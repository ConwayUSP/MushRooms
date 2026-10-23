vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
    vec4 c = Texel(texture, texture_coords);
    float grayscale_factor = 0.75;
    float g = dot(c.rgb, vec3(0.25, 0.5, 0.1));
    vec3 grayscale = vec3(g * 1.1, g * 0.95, g * 0.95); // números bãos
    vec3 result = mix(c.rgb, grayscale, grayscale_factor);

    return vec4(result, c.a);
}
