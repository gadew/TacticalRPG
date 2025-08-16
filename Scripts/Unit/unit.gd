class_name Unit
extends Sprite2D

## Signals that a moving animation has finished.
signal move_end(Unit)

const MOVERANGE: int = 3

var _commander: Commander

## Instantiate a new [Unit] under the control of [param commander].[br]
## Returns the newly instantiated [Unit].
static func create(commander: Commander) -> Unit:
	var unit: Unit = load("uid://twn5dfmtjwap").instantiate()
	unit.material.set_shader_parameter("shift", commander.color_shift)
	unit._commander = commander
	commander.register_unit(unit)
	return unit

## Returns wether this [Unit] is controlled by [param commander].
func is_commanded_by(commander: Commander) -> bool:
	return _commander == commander

## Mark this [Unit] as selected.
func select() -> void:
	%selected.visible = true

## Mark this [Unit] as not selected.
func deselect() -> void:
	%selected.visible = false

## Walk along the given [param points], taking [param duration] time to travel between each pair of points.
func move_along(points: Array[Vector2], duration: float = 0.25) -> void:
	var tween: Tween = create_tween()
	for point in points:
		tween.tween_property(self, "position", point + Vector2.ONE * 32, duration)
	await tween.finished
	move_end.emit(self)
