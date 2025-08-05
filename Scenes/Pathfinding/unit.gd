class_name Unit
extends Sprite2D

const MOVERANGE: int = 3

signal move_end(Unit)

static func create(color_shift: float = 0) -> Unit:
    var unit: Unit = load("uid://twn5dfmtjwap").instantiate()
    unit.material.set_shader_parameter("shift", color_shift)
    return unit

func select():
    %selected.visible = true

func deselect():
    %selected.visible = false

func move_along(points: Array[Vector2], duration: float = 0.25):
    var tween: Tween = create_tween()
    for point in points:
        tween.tween_property(self, "position", point + Vector2.ONE * 32, duration)
    await tween.finished
    move_end.emit(self)
