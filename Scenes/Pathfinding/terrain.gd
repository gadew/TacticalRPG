class_name Terrain
extends RefCounted

var _terrain: TileMapLayer
var _selection: TileMapLayer
var _astar: AStarGrid2D
var _unit_map: Dictionary[Vector2i, Unit]

static func taxicab(v: Vector2i, w: Vector2i) -> int:
	return abs(v.x - w.x) + abs(v.y + w.y)

func _traversable(v: Vector2i) -> bool:
	var tile_data: TileData = _terrain.get_cell_tile_data(v)
	return tile_data != null and tile_data.get_custom_data("traversable")

func _setup_astargrid2d() -> void:
	_astar = AStarGrid2D.new()
	#initialize based on tilemaplayer values
	_astar.cell_size = _terrain.tile_set.tile_size
	_astar.region = _terrain.get_used_rect()
	#set expected heuristic and forbid diagonal movement
	_astar.default_compute_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	_astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	_astar.update()
	#set solid blocks as untraversable in AStarGrid2D graph
	var solid_cells: Array[Vector2i] = _terrain.get_used_cells().filter(func(x): return not _traversable(x))
	for cell: Vector2i in solid_cells:
		_astar.set_point_solid(cell)

func _init(terrain: TileMapLayer, selection: TileMapLayer) -> void:
	_terrain = terrain
	_selection = selection
	_setup_astargrid2d()
	_unit_map = {}

func map_to_local(v: Vector2i) -> Vector2:
	return _terrain.map_to_local(v)

func _place_unit_at(unit: Unit, v: Vector2i) -> Unit:
	_unit_map[v] = unit
	_astar.set_point_solid(v)
	return unit

func _remove_unit_from(v: Vector2i) -> Unit:
	if v in _unit_map.keys(): 
		var unit: Unit = _unit_map[v]
		_unit_map.erase(v)
		_astar.set_point_solid(v, false)
		return unit
	else:
		return null

func create_unit_at(grid_position: Vector2i, color_shift: float = 0) -> Unit:
	var unit: Unit = Unit.create(color_shift)
	_unit_map[grid_position] = unit
	_astar.set_point_solid(grid_position)
	return unit

func attempt_move_to(origin: Vector2i, target: Vector2i) -> void:
	var unit: Unit = _remove_unit_from(origin)
	if unit != null and not target in _unit_map.keys():
		var path: PackedVector2Array = _astar.get_point_path(origin, target)
		if taxicab(origin, target) <= unit.MOVERANGE and not path.is_empty():
			_remove_unit_from(origin)
			_place_unit_at(unit, target)
			await unit.move_along(path)

func _render_selection_layer_radius(at: Vector2i, radius: int) -> void:
	_selection.clear()
	for position in TaxiCab.range(at, radius):
		if position in _terrain.get_used_cells():
			var path: PackedVector2Array = _astar.get_point_path(at, position)
			var unoccupied: bool = not position in _unit_map.keys() and _traversable(position)
			var path_available: bool = len(path) > 0 and len(path) <= radius + 1
			if unoccupied and path_available:
				_selection.set_cell(position, 0, Vector2i.ZERO)