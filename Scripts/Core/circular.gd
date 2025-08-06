class_name CircularBuffer
extends RefCounted

var _array: Array
var _i: int

func _init(array: Array) -> void:
	assert(not array.is_empty())
	self._array = array

func should_continue() -> bool:
	return true

func _iter_init(_arg):
	_i = 0
	return should_continue()

func _iter_next(_arg) -> bool:
	_i = (_i+1) % len(_array)
	return should_continue()

func _iter_get(_arg):
	return _array[_i]

func pop():
	var value = _iter_get(null)
	_iter_next(null)
	return value
