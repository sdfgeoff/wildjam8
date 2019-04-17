shader_type canvas_item;
render_mode blend_mix;

uniform vec4 color1 : hint_color = vec4(0.0,1.0,0.0, 1.0);
uniform vec4 color2 : hint_color = vec4(0.0,0.0,1.0, 1.0);


void fragment() {
	vec4 part = texture(TEXTURE, UV);
	float outline = part.r;
	float glow = pow(part.g, 2.0);
	float center = clamp(part.b - outline, 0.0, 1.0);
	
	float color_mix = clamp((UV.x + UV.y / 2.0 - 0.75) * 10.0, 0.0, 1.0);
	vec4 color = mix(color1, color2, color_mix);
	
	vec3 col = clamp(color.rgb - center + glow, 0.0, 1.0);
	COLOR.rgb = col;
	COLOR.a = clamp(outline + glow + center, 0.0, 1.0);
}