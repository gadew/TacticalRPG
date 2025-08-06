class_name ComputerController
extends Controller

var _commander: Commander

func _init(commander: Commander) -> void:
	_commander = commander

func start_turn() -> void:
	var unit: Unit = _commander._units.pick_random()
	pass

func input_grid_position(_grid_position: Vector2i, _terrain: Terrain) -> void:
	pass