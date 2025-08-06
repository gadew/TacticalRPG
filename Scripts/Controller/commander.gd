class_name Commander
extends RefCounted

enum ControllerType {HUMAN, COMPUTER}

@warning_ignore("unused_signal")
signal end_turn(commander: Commander)

var _controller: Controller
var color_shift: float
var name: String = "No Name"

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

func register_unit(unit: Unit) -> void:
	assert(not _units.has(unit))
	_units.append(unit)

func start_turn() -> void:
	_controller.start_turn()

func input_grid_position(grid_position: Vector2i) -> void:
	_controller.input_grid_position(grid_position)
