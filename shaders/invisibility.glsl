extern float timer;

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
    vec4 c = Texel(texture, texture_coords);
    float grayscale_factor = min(min(7.5 - timer * 1.5, timer * 1.5), 1.0);
    vec3 grayscale = vec3(dot(c.rgb, vec3(0.321, 0.567, 0.111)));
    vec3 result = mix(c.rgb, grayscale, grayscale_factor);

    return vec4(result, c.a - grayscale_factor * 0.5);
}
