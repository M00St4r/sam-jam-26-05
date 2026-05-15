shader_type spatial;
render_mode cull_disabled, unshaded;
uniform vec4 albedo_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
// Wave settings
uniform float amplitude = 0.25;
uniform float frequency = 2.0;
uniform float speed = 1.0;

void vertex() {
    // Oscillate vertices along Y axis
    VERTEX.x += sin((VERTEX.x * frequency) + (TIME * speed)) * amplitude;
}

void fragment() {
	// Called for every pixel the material is visible on.
	ALBEDO = albedo_color.rgb;
    ALPHA = albedo_color.a;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
