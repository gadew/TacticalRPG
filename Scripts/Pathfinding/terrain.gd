class_name Terrain
extends RefCounted

var _terrain: TileMapLayer
var _selection: TileMapLayer

var _astar: AStarGrid2D
var _unit_map: Dictionary[Vector2i, Unit]

func _init(terrain: TileMapLayer, selection: TileMapLayer) -> void:
	_terrain = terrain
	_selection = selection
	_setup_astargrid2d()
	_unit_map = {}

## Returns the centered position of a cell in the [TileMapLayer]'s local coordinate space. 
func map_to_local(map_position: Vector2i) -> Vector2:
	return _terrain.map_to_local(map_position)

## Returns the map coordinates of the cell containing the given [param local_position].
func local_to_map(local_position: Vector2) -> Vector2i:
	return _terrain.local_to_map(_terrain.to_local(local_position))

## Returns the [Unit] placed at [param map_position] if there is one otherwise return [null].
func get_unit_at(map_position: Vector2i) -> Unit:
	return _unit_map.get(map_position)

## Returns the location of [param unit] if [param unit] is inside this [Terrain], otherwise return [null].
func get_unit_location(unit: Unit) -> Vector2i:
	return _unit_map.find_key(unit)

## Returns an [Array] containing the tiles that are accessible by [param unit].
func get_reachable_tiles(unit: Unit) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	var from: Vector2i = get_unit_location(unit)
	var radius: int = unit.MOVERANGE
	for target in TaxiCab.range(from, radius):
		if target in _terrain.get_used_cells():
			var path: PackedVector2Array = _astar.get_point_path(from, target)
			var unoccupied: bool = not target in _unit_map.keys() and _traversable(target)
			var path_available: bool = len(path) > 0 and len(path) <= radius + 1
			if unoccupied and path_available:
				result.append(target)
	return result

## Place [param unit] at [param grid_position].
func place_unit_at(unit: Unit, grid_position: Vector2i) -> void:
	_unit_map[grid_position] = unit
	_astar.set_point_solid(grid_position)
	unit.global_position = _terrain.to_global(_terrain.map_to_local(grid_position))

## Mark [param unit] as selected.
func select_unit(unit: Unit) -> void:
	unit.select()
	_render_selection_layer_radius(unit)

## Mark [param unit] as deselected.
func deselect_unit(unit: Unit) -> void:
	unit.deselect()
	_selection.clear()

## Move [param unit] to [param target_map_position].
func move_unit_to(unit: Unit, target_map_position: Vector2i) -> void:
	var origin: Vector2i = get_unit_location(unit)
	if origin != null:
		_selection.clear()
		await _move_unit_from_to(unit, origin, target_map_position)

## Move the [Unit] placed at [param origin] to [param target_map_position].
func move_from_to(origin: Vector2i, target_map_position: Vector2i) -> void:
	var unit: Unit = _unit_map.get(origin)
	if unit != null and not _unit_map.has(target_map_position):
		await _move_unit_from_to(unit, origin, target_map_position)

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

func _traversable(v: Vector2i) -> bool:
	var tile_data: TileData = _terrain.get_cell_tile_data(v)
	return tile_data != null and tile_data.get_custom_data("traversable")

func _move_unit_from_to(unit: Unit, origin: Vector2i, target: Vector2i) -> void:
	assert(_unit_map[origin] == unit)
	if not _unit_map.has(target):
		var path: PackedVector2Array = _astar.get_point_path(origin, target)
		if TaxiCab.distance(origin, target) <= unit.MOVERANGE and not path.is_empty():
			_remove_unit_from(origin)
			_place_unit_at(unit, target)
			await unit.move_along(path)

func _place_unit_at(unit: Unit, v: Vector2i) -> Unit:
	_unit_map[v] = unit
	_astar.set_point_solid(v)
	return unit

func _remove_unit_from(v: Vector2i) -> Unit:
	var unit: Unit = _unit_map.get(v)
	if unit != null: 
		_unit_map.erase(v)
		_astar.set_point_solid(v, false)
	return unit

func _render_selection_layer_radius(unit: Unit) -> void:
	_selection.clear()
	var reachable: Array[Vector2i] = get_reachable_tiles(unit)
	for tile: Vector2i in reachable:
		_selection.set_cell(tile, 0, Vector2i.ZERO)
