extern number radius;
extern number PI;
extern vec2 resolution;

vec4 effect(vec4 c, Image tex, vec2 tc, vec2 sc) {
  vec2 tex_size = 1.0 / resolution;
  vec4 sum = vec4(0.0);
  float weight_sum = 0.0;
  float sigma = radius / 2.0;

  // Horizontal blur
  for (float x = -radius; x <= radius; x++) {
    float weight =
        exp(-(x * x) / (2.0 * sigma * sigma)) / (sqrt(PI * 2 * sigma));
    vec2 offset = vec2(x * tex_size.x, 0.0);
    sum += weight * Texel(tex, tc + offset);
    weight_sum += weight;
  }

  sum /= weight_sum;
  return sum;
}