extern vec2 p1_uv;
extern vec2 p2_uv;
extern vec2 p3_uv;
extern vec2 p4_uv;
// aspect ratio do sprite do obstáculo (largura / altura)
extern float aspect_ratio;
extern float radius;
// opacidade mínima dentro do círculo (ex: 0.35 para não sumir 100%)
extern float min_alpha;

float correctedDistance(vec2 uv1, vec2 uv2) {
    vec2 diff = uv1 - uv2;
    diff.x *= aspect_ratio; // compensa a proporção da textura
    return length(diff);
}

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
    vec4 texcolor = Texel(texture, texture_coords) * color;
    float dist = correctedDistance(p1_uv, texture_coords);
    dist = min(dist, correctedDistance(p2_uv, texture_coords));
    dist = min(dist, correctedDistance(p3_uv, texture_coords));
    dist = min(dist, correctedDistance(p4_uv, texture_coords));

    vec2 grid_xy = texture_coords * 16;

    float alpha_factor = step(radius, dist);
    alpha_factor = max(alpha_factor, min_alpha);
    alpha_factor = max(alpha_factor, 0.85f - step(0.25, max(fract(grid_xy.x), fract(grid_xy.y / aspect_ratio))) * 0.85f);

    texcolor.a *= alpha_factor;
    return texcolor;
}
