// deixa o objeto mais azul e transparente
vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
    vec4 pixel = Texel(texture, texture_coords);
    float grayScale = 0.213 * pixel.r + 0.712 * pixel.g + 0.07 * pixel.b;
    grayScale += 0.2;
    return vec4(grayScale, grayScale, grayScale + 0.5, pixel.a * 0.6);
}
