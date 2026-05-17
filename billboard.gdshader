shader_type spatial;

render_mode unshaded;

uniform sampler2D albedo_texture : source_color, filter_nearest;

void vertex() {
    vec3 right = normalize(cross(vec3(0.0, 1.0, 0.0), INV_VIEW_MATRIX[2].xyz));
    vec3 forward = normalize(cross(right, vec3(0.0, 1.0, 0.0)));
    
    MODELVIEW_MATRIX = VIEW_MATRIX * mat4(
        vec4(right, 0.0),
        vec4(0.0, 1.0, 0.0, 0.0),
        vec4(forward, 0.0),
        MODEL_MATRIX[3]
    );
    MODELVIEW_NORMAL_MATRIX = mat3(MODELVIEW_MATRIX);
}

void fragment() {
	vec4 tex = texture(albedo_texture, UV);
	
    ALBEDO = tex.rgb;
    ALPHA = tex.a;
}