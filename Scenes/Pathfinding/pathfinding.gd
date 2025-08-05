extends Node

@onready var _terrainlayer: TileMapLayer = %terrain
@onready var _selectionlayer: TileMapLayer = %selection
@onready var _astar: AStarGrid2D = AStarGrid2D.new()

var _position2unit: Dictionary[Vector2i, Unit] = {}

enum State {NONE, SELECT, ACTION}
var _state: State = State.SELECT
var _selected: Vector2i

static func _setup_astargrid2d(_astar_grid: AStarGrid2D, _terrain: TileMapLayer):
	#initialize based on tilemaplayer values
	_astar_grid.cell_size = _terrain.tile_set.tile_size
	_astar_grid.region = _terrain.get_used_rect()
	#set expected heuristic and forbid diagonal movement
	_astar_grid.default_compute_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	_astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	_astar_grid.update()
	
	#set solid blocks as untraversable in AStarGrid2D graph
	var used_cells: Array[Vector2i] = _terrain.get_used_cells()
	var solid_cells: Array[Vector2i] = used_cells.filter(func(x): return not _terrain.get_cell_tile_data(x).get_custom_data("traversable"))
	for cell: Vector2i in solid_cells:
		_astar_grid.set_point_solid(cell)

func _traversable(v: Vector2i) -> bool:
	var tile_data: TileData = _terrainlayer.get_cell_tile_data(v)
	return tile_data != null and tile_data.get_custom_data("traversable")

func _ready() -> void:
	_setup_astargrid2d(_astar, _terrainlayer)

	_create_unit_at(Vector2i(0, 0))
	_create_unit_at(Vector2i(0, 1))
	_create_unit_at(Vector2i(1, 1))

func _create_unit_at(grid_position: Vector2i, color_shift: float = 0):
	var unit: Unit = Unit.create(color_shift)
	unit.global_position = _terrainlayer.map_to_local(grid_position)
	add_child(unit)
	_position2unit[grid_position] = unit
	_astar.set_point_solid(grid_position)
	return unit

func _attempt_move_to(origin: Vector2i, target: Vector2i):
	if origin in _position2unit.keys() and not target in _position2unit.keys():
		var unit: Unit = _position2unit[origin]
		var distance: Vector2i = (origin - target).abs()
		var path: PackedVector2Array = _astar.get_point_path(origin, target)
		if distance.x + distance.y <= unit.MOVERANGE and not path.is_empty():
			_position2unit.erase(origin)
			_astar.set_point_solid(origin, false)
			_position2unit[target] = unit
			_astar.set_point_solid(target)
			await unit.move_along(path)

func _render_selection_layer_radius(at: Vector2i, radius: int):
	_selectionlayer.clear()
	for i in range(at.x-radius, at.x+radius+1):
		var dx: int = abs(at.x - i)
		var dy: int = radius - dx
		for j in range(at.y-dy, at.y+dy+1):
			var position: Vector2i = Vector2i(i, j)
			if position in _terrainlayer.get_used_cells():
				var path: PackedVector2Array = _astar.get_point_path(at, position)
				var unoccupied: bool = not position in _position2unit.keys() and _traversable(position)
				var path_available: bool = len(path) > 0 and len(path) <= radius + 1
				if unoccupied and path_available:
					_selectionlayer.set_cell(position, 0, Vector2i.ZERO)

func _click_tile_at(input_global_position: Vector2):
	var grid_location: Vector2i = _terrainlayer.local_to_map(_terrainlayer.to_local(input_global_position))
	match _state:
		State.NONE:
			pass
		State.SELECT:
			if grid_location in _position2unit.keys():
				_selected = grid_location
				_position2unit[grid_location].select()
				_render_selection_layer_radius(grid_location, _position2unit[grid_location].MOVERANGE)
				_state = State.ACTION
		State.ACTION:
			_state = State.NONE
			_position2unit[_selected].deselect()
			_selectionlayer.clear()
			await _attempt_move_to(_selected, grid_location)
			_state = State.SELECT

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		_click_tile_at(event.position)
		get_viewport().set_input_as_handled()
