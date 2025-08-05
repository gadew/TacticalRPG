extends Node

@onready var _terrainlayer: TileMapLayer = %terrain
@onready var _selectionlayer: TileMapLayer = %selection
var _terrain: Terrain

enum State {NONE, SELECT, ACTION}
var _state: State = State.SELECT
var _selected: Vector2i

func _ready() -> void:
	_terrain = Terrain.new(_terrainlayer, _selectionlayer)

	_create_unit_at(Vector2i(0, 0))
	_create_unit_at(Vector2i(0, 1))
	_create_unit_at(Vector2i(1, 1))

func _create_unit_at(grid_position: Vector2i, color_shift: float = 0) -> Unit:
	var unit: Unit = _terrain.create_unit_at(grid_position, color_shift)
	add_child(unit)
	unit.global_position = _terrain.map_to_local(grid_position)
	return unit

func _click_tile_at(input_global_position: Vector2) -> void:
	var grid_location: Vector2i = _terrain.local_to_map(input_global_position)
	match _state:
		State.NONE:
			pass
		State.SELECT:
			var unit: Unit = _terrain.select_unit_at(grid_location)
			if unit != null:
				_selected = grid_location
				_state = State.ACTION
		State.ACTION:
			_state = State.NONE
			_terrain.deselect_unit_at(_selected)
			await _terrain.move_from_to(_selected, grid_location)
			_state = State.SELECT

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		_click_tile_at(event.position)
		get_viewport().set_input_as_handled()
