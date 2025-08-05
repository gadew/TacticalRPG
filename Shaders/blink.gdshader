shader_type canvas_item;

uniform float frequency : hint_range(0.05, 10.0, 0.05) = 1.;

void fragment() {
	COLOR.a *= (sin(TIME * frequency) + 1.) / 2.;
}
