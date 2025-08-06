class_name Unit
extends Sprite2D

const MOVERANGE: int = 3

signal move_end(Unit)

var _commander: Commander

static func create(commander: Commander) -> Unit:
	var unit: Unit = load("uid://twn5dfmtjwap").instantiate()
	unit.material.set_shader_parameter("shift", commander.color_shift)
	unit._commander = commander
	commander.register_unit(unit)
	return unit

func is_commanded_by(commander: Commander) -> bool:
	return _commander == commander

func select() -> void:
	%selected.visible = true

func deselect() -> void:
	%selected.visible = false

func move_along(points: Array[Vector2], duration: float = 0.25) -> void:
	var tween: Tween = create_tween()
	for point in points:
		tween.tween_property(self, "position", point + Vector2.ONE * 32, duration)
	await tween.finished
	move_end.emit(self)
