class_name PlayerController
extends Controller

var _commander: Commander

enum State {NONE, SELECT, ACTION}
var _state: State = State.NONE

var _selected: Unit = null

func _init(commander: Commander) -> void:
	_commander = commander

func start_turn() -> void:
	_state = State.SELECT

func input_map_position(map_position: Vector2i) -> void:
	var unit: Unit = _commander._terrain.get_unit_at(map_position)
	match _state:
		State.NONE:
			pass
		State.SELECT:
			if unit != null and unit.is_commanded_by(_commander):
				_selected = unit
				_commander._terrain.select_unit(unit)
				_state = State.ACTION
		State.ACTION:
			assert(_selected != null)
			_state = State.NONE
			_commander._terrain.deselect_unit(_selected)
			await _commander._terrain.move_unit_to(_selected, map_position)
			_selected = null
			_commander.end_turn.emit(_commander)