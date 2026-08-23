shader_type spatial;
render_mode cull_back, diffuse_burley, specular_schlick_ggx;

// ---------------------------------------------------------------------------
// DISCO BALL SHADER
// Apply to a ShaderMaterial on a SphereMesh's MeshInstance3D.
// Procedurally facets the sphere into small rectangular mirror tiles, each
// with a tiny random tilt so different tiles flash as the light direction /
// camera / ball changes.
// ---------------------------------------------------------------------------

uniform float tile_density : hint_range(4.0, 150.0) = 40.0;      // how many tiles wrap the sphere
uniform float tile_tilt : hint_range(0.0, 1.0) = 0.35;           // random per-tile facet tilt amount
uniform float grout_width : hint_range(0.0, 0.3) = 0.08;         // thickness of dark lines between tiles
uniform vec3 grout_color : source_color = vec3(0.015, 0.015, 0.018);
uniform vec3 mirror_color : source_color = vec3(0.92, 0.94, 0.97);
uniform float color_variation : hint_range(0.0, 1.0) = 0.06;     // subtle per-tile silver tint variance
uniform float base_roughness : hint_range(0.0, 1.0) = 0.04;
uniform float base_metallic : hint_range(0.0, 1.0) = 0.95;
uniform float specular_power : hint_range(8.0, 1024.0) = 300.0;  // higher = tighter, sharper glints
uniform float specular_boost : hint_range(0.0, 30.0) = 8.0;      // brightness of the glint flashes

varying vec3 obj_normal;

void vertex() {
	// Object-space normal (sphere is centered at origin, so normalized
	// local vertex position IS the surface normal). Using object space
	// keeps the tile pattern locked to the mesh as it rotates.
	obj_normal = normalize(VERTEX);
}

float hash21(vec2 p) {
	p = fract(p * vec2(123.34, 456.21));
	p += dot(p, p + 45.32);
	return fract(p.x * p.y);
}

void fragment() {
	vec3 n = normalize(obj_normal);

	// Spherical coords -> 2D plane fed into the rectangular grid.
	float theta = atan(n.z, n.x);                  // -PI .. PI
	float phi = acos(clamp(n.y, -1.0, 1.0));        // 0 .. PI
	vec2 sp = vec2(theta, phi) * tile_density;

	vec2 id = floor(sp);
	vec2 gv = fract(sp) - 0.5; // local position within the tile, centered, range -0.5..0.5

	float h1 = hash21(id);
	float h2 = hash21(id + 11.7);

	// Grout mask: dark border around each rectangular tile.
	float dist_to_edge = 0.5 - max(abs(gv.x), abs(gv.y));
	float grout_mask = smoothstep(grout_width, 0.0, dist_to_edge);

	// Per-tile random tilt baked into a normal map perturbation so each
	// little mirror catches specular highlights at a slightly different
	// moment as the ball turns.
	vec2 tilt = (vec2(h1, h2) - 0.5) * tile_tilt;
	vec3 tile_normal = normalize(vec3(tilt, 1.0));
	NORMAL_MAP = tile_normal * 0.5 + 0.5;
	NORMAL_MAP_DEPTH = 1.0;

	vec3 tint = mirror_color * (1.0 + (h1 - 0.5) * color_variation);
	ALBEDO = mix(tint, grout_color, grout_mask);
	ROUGHNESS = mix(base_roughness, 1.0, grout_mask);
	METALLIC = mix(base_metallic, 0.0, grout_mask);
	SPECULAR = 0.5;
}

void light() {
	// Sharp, boosted glint per facet so tiles "flash" based on light direction
	// instead of blending into one smooth highlight.
	vec3 H = normalize(VIEW + LIGHT);
	float NdotH = clamp(dot(NORMAL, H), 0.0, 1.0);
	float NdotL = clamp(dot(NORMAL, LIGHT), 0.0, 1.0);

	float spec = pow(NdotH, specular_power);
	SPECULAR_LIGHT += LIGHT_COLOR * ATTENUATION * spec * specular_boost;
	DIFFUSE_LIGHT += ALBEDO * LIGHT_COLOR * ATTENUATION * NdotL * (1.0 - METALLIC);
}
