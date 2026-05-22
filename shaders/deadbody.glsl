extern float death_timer;

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
    vec4 c = Texel(texture, texture_coords);
    float grayscale_factor = min(death_timer * 1.5, 1.0); // dá pra multiplicar o timer para acelerar o efeito
    vec3 grayscale = vec3(dot(c.rgb, vec3(0.25, 0.5, 0.1))); // números bãos
    vec3 result = mix(c.rgb, grayscale, grayscale_factor);

    return vec4(result, c.a - grayscale_factor * 0.15);
}
