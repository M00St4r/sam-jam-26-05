shader_type spatial;

render_mode unshaded;

// Texture input
uniform sampler2D albedo_texture : source_color, filter_nearest;

// Wave settings
uniform float amplitude = 0.1;
uniform float frequency = 5.0;
uniform float speed = 5.0;

void vertex() {
    // Y-Billboard: Nur um die Y-Achse drehen, Blickrichtung bleibt horizontal
    vec3 right = normalize(cross(vec3(0.0, 1.0, 0.0), INV_VIEW_MATRIX[2].xyz));
    vec3 forward = normalize(cross(right, vec3(0.0, 1.0, 0.0)));
	
	VERTEX.y += sin((VERTEX.y * frequency) + (TIME * speed)) * amplitude;
    
    MODELVIEW_MATRIX = VIEW_MATRIX * mat4(
        vec4(right * 0.5, 0.0),
        vec4(0.0, 0.5, 0.0, 0.0), // Y-Achse bleibt fix
        vec4(forward *0.5, 0.0),
        MODEL_MATRIX[3]
    );
    MODELVIEW_NORMAL_MATRIX = mat3(MODELVIEW_MATRIX);
}

void fragment() {
	vec4 tex = texture(albedo_texture, UV);
	
    ALBEDO = tex.rgb;
    ALPHA = tex.a;
}