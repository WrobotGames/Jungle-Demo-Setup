shader_type particles;
uniform float instance_rows1 = 30.;
uniform float radius1 = 40.;
uniform sampler2D map_heightmap;
uniform sampler2D map_mask;
uniform sampler2D noisemap;
uniform vec3 base_scale = vec3(1,1,1);
uniform float height_offset = 0.0;
uniform vec2 map_heightmap_size = vec2(1024.0, 1024.0);
uniform float __terrain_amplitude;
uniform float instance_pos_randomize : hint_range(0.0, 2.0) =  1.0;
uniform float random_seed : hint_range(0.0, 1.0) = 0.5;
global uniform float render_dist_factor;
uniform float extra_cull_margin = 2.; //distance in units
uniform float close_cull = 0.;

mat4 __build_rotation_mat4(vec3 axis, float angle) {
	axis = normalize(axis);
	float s = sin(angle);
	float c = cos(angle);
	float oc = 1.0 - c;
	return mat4(vec4(oc * axis.x * axis.x + c, oc * axis.x * axis.y - axis.z * s, oc * axis.z * axis.x + axis.y * s, 0), vec4(oc * axis.x * axis.y + axis.z * s, oc * axis.y * axis.y + c, oc * axis.y * axis.z - axis.x * s, 0), vec4(oc * axis.z * axis.x - axis.y * s, oc * axis.y * axis.z + axis.x * s, oc * axis.z * axis.z + c, 0), vec4(0, 0, 0, 1));
}
float get_height(vec2 pos) {
	//pos -= 0.5 * map_heightmap_size;
	pos += vec2(.5,.5); //reduces clipping with terrain
	pos /= map_heightmap_size;
	return (2.0*__terrain_amplitude * texture(map_heightmap, pos ).r) + height_offset;
}
vec2 pos_randomizer(vec2 noise, float scaler){
	return (2. * noise - 1.) * scaler ;
}

void start() {
	float radius = radius1 * render_dist_factor + 0.1 * radius1 ;
	float instance_rows = instance_rows1 * render_dist_factor;
	float fov_correction = 0.85;
	float instance_spacing =  (radius *2. * fov_correction)/ instance_rows ;
	vec3 pos = vec3(0.0, 0.0, 0.0);
	pos.z = float(INDEX);
	pos.x = mod(pos.z, instance_rows );
	pos.z = (pos.z - pos.x) / instance_rows;
	pos.xz -=  0.5 * vec2(instance_rows);
	pos.xz += vec2(1.0,1.0); //True center.
	pos *= instance_spacing;
	pos.xz += (EMISSION_TRANSFORM[2].xz* radius  * 0.5 - mod(EMISSION_TRANSFORM[2].xz* radius * 0.5, instance_spacing));
	vec2 cullpos = pos.xz; //save position for culling
	pos.x += EMISSION_TRANSFORM[3][0] - mod(EMISSION_TRANSFORM[3][0], instance_spacing);
	pos.z += EMISSION_TRANSFORM[3][2] - mod(EMISSION_TRANSFORM[3][2], instance_spacing);


	//Random values from noise, based on world space position.
	vec3 noise = texture(noisemap, pos.xz * 0.363 +  7.32 * vec2(random_seed)).rgb;
	noise.x = texture(noisemap, pos.xz * 0.48 + 10. * vec2(random_seed) + vec2(0.5)).x;
	//Apply randomisation to spawner space positions for culling.
	cullpos += pos_randomizer(noise.xy, instance_spacing);
	if (cullpos.x * cullpos.x + cullpos.y * cullpos.y > radius * radius  ){
		ACTIVE = false;
	}

	vec2 cull2 = EMISSION_TRANSFORM[2].xz * (radius - clamp(instance_spacing, extra_cull_margin, 1000.)) - cullpos;
	if (cull2.x * cull2.x + cull2.y * cull2.y > radius * radius){
		ACTIVE = false;
	}
	//True position randomisation, should be the same as above.
	pos.xz += pos_randomizer(noise.xy, instance_spacing);
	if (pos.x < 1. || pos.z < 1. || pos.x > 1023. || pos.z > 1023.){ //Disable out of bounds 1 meter margin
		ACTIVE = false;
	}
	pos.y = get_height(pos.xz);

	if (close_cull != 0.){
		float close_cull_true = close_cull * 0.8 * render_dist_factor;
		if (distance(pos, EMISSION_TRANSFORM[3].xyz) <  close_cull_true) {
			ACTIVE = false;
		}
	}
	if (texture(map_mask,((pos.xz + vec2(.5,.5))/map_heightmap_size) ).x == 0.0){
		ACTIVE = false;
	}else{
		float u,v, checksize, angle;
		vec3 rot;
		checksize = 0.5;
		u = pos.y - get_height(pos.xz + vec2(checksize, 0.));
		v = pos.y - get_height(pos.xz + vec2(0.,checksize));
		rot = normalize(vec3(u, 1., v));
		angle = acos(dot(rot, vec3(0.,1.,0.)));
		rot = normalize(cross(rot, vec3(0.,1.,0.)));

		if (RESTART_POSITION) {
			TRANSFORM = mat4(vec4(1.0, 0.0, 0.0, 0.0), vec4(0.0, 1.0, 0.0, 0.0), vec4(0.0, 0.0, 1.0, 0.0), vec4(pos, 1.0));
		}
		TRANSFORM *= __build_rotation_mat4(rot, angle);
		TRANSFORM *= __build_rotation_mat4(vec3(0.,1.,0.), noise.y * 6.3);
		vec3 truescale = base_scale * (0.15 * noise + vec3(1.));
		truescale = base_scale;
		TRANSFORM *= mat4(vec4(truescale.x, 0, 0, 0), vec4(0, truescale.y, 0, 0), vec4(0, 0, truescale.z, 0), vec4(0, 0, 0, 1));
	}
}
