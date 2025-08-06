class_name Commander
extends RefCounted

enum ControllerType {HUMAN, COMPUTER}

signal end_turn(commander: Commander)

var _controller: Controller
var _units: Array[Unit]

var color_shift: float

enum State {NONE, SELECT, ACTION}
var _state: State = State.NONE

var _selected: Unit = null

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

func start_turn() -> void:
	_state = State.SELECT

func input_grid_position(grid_position: Vector2i, terrain: Terrain) -> void:
	var unit: Unit = terrain.get_unit_at(grid_position)
	match _state:
		State.NONE:
			pass
		State.SELECT:
			if unit != null and unit.is_commanded_by(self):
				_selected = unit
				terrain.select_unit(unit)
				_state = State.ACTION
		State.ACTION:
			assert(_selected != null)
			_state = State.NONE
			terrain.deselect_unit(_selected)
			await terrain.move_unit_to(_selected, grid_position)
			_selected = null
			end_turn.emit(self)
