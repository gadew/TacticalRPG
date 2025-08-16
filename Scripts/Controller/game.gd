class_name Game
extends Node

## Signals that [param commander]'s turn is starting.
signal start_turn(commander)

var red_commander: Commander 
var blue_commander: Commander

var _terrain: Terrain
var _turn_iterator: CircularIterator
var _current_commander: Commander

@onready var _terrainlayer: TileMapLayer = %terrain
@onready var _selectionlayer: TileMapLayer = %selection

func _ready() -> void:
	_terrain = Terrain.new(_terrainlayer, _selectionlayer)
	red_commander = Commander.new(Commander.ControllerType.HUMAN, _terrain, "PLAYER", 0)
	blue_commander = Commander.new(Commander.ControllerType.COMPUTER, _terrain, "CPU", 0.5)
	_turn_iterator = CircularIterator.new([red_commander, blue_commander])

	start_turn.connect(func(commander: Commander): _current_commander = commander; _current_commander.start_turn())
	red_commander.end_turn.connect(func(_end_commander): start_turn.emit(_turn_iterator.pop()))
	blue_commander.end_turn.connect(func(_end_commander): start_turn.emit(_turn_iterator.pop()))

	_create_unit_for_at(red_commander, Vector2i(0, 0))
	_create_unit_for_at(blue_commander, Vector2i(17, 0))

	await get_tree().process_frame
	start_turn.emit(_turn_iterator.pop())

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		_click_tile_at(event.position)
		get_viewport().set_input_as_handled()

func _click_tile_at(input_global_position: Vector2) -> void:
	var grid_position: Vector2i = _terrain.local_to_map(input_global_position)
	_current_commander.input_grid_position(grid_position)

func _create_unit_for_at(commander: Commander, grid_position: Vector2i) -> Unit:
	var unit: Unit = Unit.create(commander)
	add_child(unit)
	_terrain.place_unit_at(unit, grid_position)
	return unit