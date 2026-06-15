extern number thickness = 1.0;
extern vec2 texSize;
extern vec4 outlineColor = vec4(1.0, 1.0, 1.0, 1.0);

// passa por cada pixel da imagem e decide a cor final
vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
  vec4 pixel = Texel(texture, texture_coords);
  float maxAlpha = pixel.a;

  // normaliza baseado no tamanho da textura
  vec2 px = vec2(1.0 / texSize.x, 1.0 / texSize.y);

  // percorre vizinhança para detectar borda
  for (float x = -thickness; x <= thickness; x++) {
    for (float y = -thickness; y <= thickness; y++) {
      vec2 offset = vec2(x, y) * px;
      vec4 neigborPixel = Texel(texture, texture_coords + offset);

      maxAlpha = max(maxAlpha, neigborPixel.a);
    }
  }

  // se o pixel atual é semitransparente, mas seu vizinho (maxAlpha) não é, pinta a borda
  if (pixel.a < 0.1 && maxAlpha > 0.1)
    return outlineColor;

  // se não, retorna o pixel do jeito que ele entrou
  return pixel * color;
}
