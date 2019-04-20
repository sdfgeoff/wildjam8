shader_type canvas_item;
render_mode blend_add;
uniform int particles_anim_h_frames;
uniform int particles_anim_v_frames;
uniform bool particles_anim_loop;


void vertex() {
	float h_frames = float(particles_anim_h_frames);
	float v_frames = float(particles_anim_v_frames);
	VERTEX.xy /= vec2(h_frames, v_frames);
	float particle_total_frames = float(particles_anim_h_frames * particles_anim_v_frames);
	float particle_frame = floor(INSTANCE_CUSTOM.z * float(particle_total_frames));
	if (!particles_anim_loop) {
		particle_frame = clamp(particle_frame, 0.0, particle_total_frames - 1.0);
	} else {
		particle_frame = mod(particle_frame, particle_total_frames);
	}	UV /= vec2(h_frames, v_frames);
	UV += vec2(mod(particle_frame, h_frames) / h_frames, floor(particle_frame / h_frames) / v_frames);
	
}


void fragment(){
	vec4 part = texture(TEXTURE, UV);
	float outline = part.r;
	float glow = pow(part.g, 2.0);
	float center = clamp(part.b - outline, 0.0, 1.0);
	
	vec3 col = clamp(COLOR.rgb - center*0.2 + glow, 0.0, 1.0);
	COLOR.rgb = col;
	COLOR.a = clamp(outline + glow + center, 0.0, 1.0) * COLOR.a;
}