class_name ComputerController
extends Controller

var _commander: Commander

func _init(commander: Commander) -> void:
	_commander = commander

func start_turn() -> void:
	var unit: Unit = _commander._units.pick_random()
	var reachable: Array[Vector2i] = _commander._terrain.get_reachable_tiles(unit)
	if not reachable.is_empty():
		await _commander._terrain.move_unit_to(unit, reachable.pick_random())
	_commander.end_turn.emit(_commander)

func input_map_position(_map_position: Vector2i) -> void:
	pass