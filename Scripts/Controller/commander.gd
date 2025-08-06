class_name Commander
extends RefCounted

var _controller: Controller
var _units: Array[Unit]

var color_shift: float

func _init(color: float) -> void:
	color_shift = color