class_name Commander
extends RefCounted

enum ControllerType {HUMAN, COMPUTER}

## Signals the end of this [Commander]s turn.
@warning_ignore("unused_signal")
signal end_turn(commander: Commander)

## Color shift away from red.
var color_shift: float
## Name of the [Commander].
var name: String = "No Name"

var _controller: Controller
var _terrain: Terrain
var _units: Array[Unit]

func _init(controller: ControllerType, terrain: Terrain, _name: String, color: float) -> void:
	match controller:
		ControllerType.HUMAN:
			_controller = PlayerController.new(self)
		ControllerType.COMPUTER:
			_controller = ComputerController.new(self)
	
	_terrain = terrain
	color_shift = color
	name = _name

## Register [param unit] under this [Commander]s control.
func register_unit(unit: Unit) -> void:
	assert(not _units.has(unit))
	_units.append(unit)

## Start this [Commander]s turn.
func start_turn() -> void:
	_controller.start_turn()

## Input at [param _grid_position].
func input_grid_position(grid_position: Vector2i) -> void:
	_controller.input_map_position(grid_position)
