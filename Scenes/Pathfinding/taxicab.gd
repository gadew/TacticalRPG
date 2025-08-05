class_name TaxiCab
extends RefCounted

static func distance(v: Vector2i, w: Vector2i) -> int:
    return abs(v.x - w.x) + abs(v.y - w.y)

static func range(position: Vector2i, radius: int) -> TaxicabIterator:
    return TaxicabIterator.new(position, radius)

class TaxicabIterator:
    var _position: Vector2i
    var _radius: int

    var x: int
    var y: int

    func _init(position: Vector2i, radius: int) -> void:
        self._position = position
        self._radius = radius

    func should_continue() -> bool:
        return (y <= _radius)

    func _iter_init(_arg):
        x = 0
        y = -_radius
        return should_continue()

    func _iter_next(_arg) -> bool:
        if abs(x+1) + abs(y) <= _radius:
            x += 1
        else:
            y += 1
            x = -_radius + abs(y)
        return should_continue()

    func _iter_get(_arg):
        return _position + Vector2i(x, y)