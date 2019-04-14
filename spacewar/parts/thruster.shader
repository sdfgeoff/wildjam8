shader_type canvas_item;
render_mode blend_mix;

uniform vec4 color = vec4(0.0,1.0,0.0, 1.0);

void fragment() {
	vec4 part = texture(TEXTURE, UV);
	float outline = part.r;
	float glow = pow(part.g, 2.0);
	float center = clamp(part.b - outline, 0.0, 1.0);
	
	COLOR.rgb = clamp(color.rgb + glow, 0.0, 1.0);
	COLOR.a = clamp(outline + glow + center, 0.0, 1.0);
}