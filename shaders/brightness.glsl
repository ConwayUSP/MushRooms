extern number brightness = 1.0;

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
  vec4 pixel = Texel(texture, texture_coords);
  return vec4(pixel.rgb * brightness, pixel.a) * color;
}
