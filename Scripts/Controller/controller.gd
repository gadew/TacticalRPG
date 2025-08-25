class_name Controller
extends RefCounted

## Virtual method that handles a start of turn action.
func start_turn() -> void:
	pass

## Virtual method that handles an input action at [param _grid_position].
func input_map_position(_map_position: Vector2i) -> void:
	pass