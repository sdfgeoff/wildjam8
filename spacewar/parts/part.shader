shader_type canvas_item;
render_mode blend_mix;

uniform vec4 color: hint_color = vec4(0.0,1.0,0.0, 1.0);
uniform float health = 1.0;


void fragment() {
	vec4 part = texture(TEXTURE, UV);
	float outline = part.r;
	float glow = pow(part.g, 2.0);
	float center = clamp(part.b - outline, 0.0, 1.0);
	
	vec3 col = clamp(color.rgb - center + glow, 0.0, 1.0);
	COLOR.rgb = col + vec3(0.5, 0.0, 0.0) * (1.0 - health) * center;
	COLOR.a = clamp(outline + glow + center, 0.0, 1.0);
}