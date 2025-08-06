class_name Commander
extends RefCounted

enum ControllerType {HUMAN, COMPUTER}

var _controller: Controller
var _units: Array[Unit]

var color_shift: float

func _init(controller: ControllerType, color: float) -> void:
	match controller:
		ControllerType.HUMAN:
			_controller = PlayerController.new()
		ControllerType.COMPUTER:
			_controller = ComputerController.new()
	
	color_shift = color

func register_unit(unit: Unit) -> void:
	assert(not _units.has(unit))
	_units.append(unit)