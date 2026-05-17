shader_type spatial;
render_mode unshaded;

uniform sampler2D albedo_texture : source_color, filter_nearest;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec4 tex = texture(albedo_texture, UV);
	
    ALBEDO = tex.rgb;
    ALPHA = tex.a;
}
