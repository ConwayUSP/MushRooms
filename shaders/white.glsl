extern vec4 fillColor = vec4(1.0, 1.0, 1.0, 1.0);

// passa por cada pixel da imagem e decide a cor final
vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
  vec4 pixel = Texel(texture, texture_coords);
  float a = pixel.a;

  if (a <= 0.0) return vec4(0.0);

  return vec4(fillColor.rgb, fillColor.a * a) * color;
}
