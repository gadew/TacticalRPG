shader_type canvas_item;

uniform float shift : hint_range(0.0, 1.0, 0.05) = 0.;

vec3 hueShift(vec3 color, float hue) {
    const vec3 k = vec3(0.57735, 0.57735, 0.57735);
    float a = cos(hue);
    return vec3(color * a + cross(k, color) * sin(hue) + k * dot(k, color) * (1.0 - a));
}

void fragment() {
	COLOR.rgb = hueShift(COLOR.rgb, shift * 2. * PI);
}
