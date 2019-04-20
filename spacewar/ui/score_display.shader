shader_type canvas_item;

uniform int score = 3;

void fragment(){
	float template = texture(TEXTURE, UV).r;
	COLOR.rgb = vec3(1.0);
	COLOR.a = template+0.05 > (float(score) / 10.0) ? 0.0: 1.0;
}