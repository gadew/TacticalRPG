extends Node

@onready var _terrainlayer: TileMapLayer = %terrain
@onready var _selectionlayer: TileMapLayer = %selection
var _terrain: Terrain

var red_commander: Commander = Commander.new(0)
var blue_commander: Commander = Commander.new(0.5)

enum State {NONE, SELECT, ACTION}
var _state: State = State.SELECT
var _selected: Vector2i

func _ready() -> void:
	_terrain = Terrain.new(_terrainlayer, _selectionlayer)

	_create_unit_for_at(blue_commander, Vector2i(0, 0))
	_create_unit_for_at(blue_commander, Vector2i(0, 1))
	_create_unit_for_at(red_commander, Vector2i(1, 1))

func _create_unit_for_at(commander: Commander, grid_position: Vector2i) -> Unit:
	var unit: Unit = Unit.create(commander)
	add_child(unit)
	_terrain.place_unit_at(unit, grid_position)
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
