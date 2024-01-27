shader_type particles;
uniform float instance_rows;
uniform sampler2D map_heightmap;
uniform sampler2D map_mask;
uniform sampler2D noisemap;
uniform sampler2D map_normalmap;
uniform vec3 base_scale = vec3(1,1,1);
uniform vec3 rotation = vec3(1,1,1);
uniform float instance_spacing = 1.0;
uniform float height_offset = 1.0;
uniform vec2 map_heightmap_size = vec2(2000.0, 2000.0);
uniform float __terrain_amplitude;
uniform float instance_pos_randomize : hint_range(0.0, 50.0) =  2.0;
uniform float instance_rot_randomize = 2.5;
uniform mat4 test;
uniform bool instance_orient_to_normal = false;
uniform vec2 map_normalmap_size = vec2(2000.0, 2000.0);
uniform mat3 terrain_normal_basis;
uniform float instance_orientation_influence : hint_range(0.0, 10.0) = 1.0;

vec3 unpack_normalmap(vec3 rgb) {
vec3 n = rgb.xzy * 2.0 - vec3(1.0);
n.z *= -1.0;
return n;
}	

vec3 get_normal(vec2 pos) {
	//pos -= 0.5 * map_normalmap_size;
	pos /= map_normalmap_size;
	return terrain_normal_basis * unpack_normalmap(texture(map_normalmap, pos).rgb);
}


float get_height(vec2 pos) {
	//pos -= 0.5 * map_heightmap_size;
	pos /= map_heightmap_size;	
	return (2.0*__terrain_amplitude * texture(map_heightmap, pos).r) + height_offset;
}

void start() {
	vec3 pos = vec3(0.0, 0.0, 0.0);
	pos.z = float(INDEX);
	pos.x = mod(pos.z, instance_rows);
	pos.z = (pos.z - pos.x) / instance_rows;
	
	// center the emitter
	pos.x -= instance_rows * 0.5;
	pos.z -= instance_rows * 0.5;
	
	// apply instance spacing
	pos *= instance_spacing;

	pos.x += EMISSION_TRANSFORM[3][0] - mod(EMISSION_TRANSFORM[3][0], instance_spacing);
	pos.z += EMISSION_TRANSFORM[3][2] - mod(EMISSION_TRANSFORM[3][2], instance_spacing);
	
	vec3 noise = texture(noisemap, pos.xz * 0.1).rgb;
	pos.x += noise.z * instance_spacing * instance_pos_randomize;
	pos.z -= noise.x * instance_spacing * instance_pos_randomize;
	pos.y = get_height(pos.xz);	
	COLOR = vec4(texture(map_normalmap, (pos.xz - vec2(512.)) / 1024.).xyz, 0.);
	if (texture(map_mask, (pos.xz -  map_heightmap_size)/map_heightmap_size ).x < 0.5){
		ACTIVE = false;
	}
	if (instance_orient_to_normal == true){
	TRANSFORM[1].xyz = get_normal(pos.xz) * instance_orientation_influence;
	TRANSFORM[2].xyz = sin(get_normal(pos.zx) * faceforward(vec3(1.0),TRANSFORM[1].xyz, vec3(0.0, 0.0, 1.0))) * instance_orientation_influence ;
	TRANSFORM[0].xyz = sin(get_normal(pos.zx) * faceforward(vec3(1.0),TRANSFORM[1].xyz, vec3(1.0, 0.0, 0.0))) * instance_orientation_influence ;
	}
	else {
		TRANSFORM[0].xyz = vec3(0.0);
		TRANSFORM[1].xyz = vec3(0.0);
		TRANSFORM[2].xyz = vec3(0.0);
	}
	TRANSFORM[0][0] = cos(noise.x * instance_rot_randomize) * base_scale.x;
	TRANSFORM[0][2] = -sin(noise.x * instance_rot_randomize) * base_scale.x;
	TRANSFORM[2][0] = sin(noise.z * instance_rot_randomize) * base_scale.z;
	TRANSFORM[2][2] = cos(noise.z * instance_rot_randomize) * base_scale.z;
	TRANSFORM[3][0] = pos.x;
	TRANSFORM[3][1] = pos.y;
	TRANSFORM[3][2] = pos.z;
	TRANSFORM[0][0]  = base_scale.x;
	TRANSFORM[1][1] =  base_scale.y;
	TRANSFORM[2][2]  = base_scale.z;

}


