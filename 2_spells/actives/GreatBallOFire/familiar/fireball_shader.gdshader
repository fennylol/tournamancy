// Thanks to Clear Code [1]
shader_type spatial;
render_mode cull_disabled;

uniform sampler2D noise_sampler: filter_linear_mipmap, repeat_enable;
uniform sampler2D gradient_sampler: filter_linear_mipmap, repeat_enable;

float fresnel(float amount, vec3 normal, vec3 view) {
   return pow((1.0 - clamp(dot(normalize(normal), normalize(view)), 0.0, 1.0)), amount);
}

void fragment() {
   float noise = texture(noise_sampler, UV - vec2(TIME, 0.0)).x;
   vec3 gradient = texture(gradient_sampler, UV).rgb;
   ALBEDO = gradient;
   EMISSION = gradient + step(0.25, fresnel(2.0, NORMAL, VIEW)) * gradient;
   ALPHA = step(-0.35, noise - UV.x);
   ALPHA_SCISSOR_THRESHOLD = 0.5;
}
