extends Node2D

@onready var terrain: TileMapLayer = %terrain
@onready var astar: AStarGrid2D = AStarGrid2D.new()

@onready var unit: Unit = %unit

func _setup_astargrid2d(_astar_grid: AStarGrid2D, _terrain: TileMapLayer):
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
        astar.set_point_solid(cell)

func _ready() -> void:
    _setup_astargrid2d(astar, terrain)

func click_tile_at(input_global_position: Vector2):
    var grid_location: Vector2i = terrain.local_to_map(terrain.to_local(input_global_position))
    unit.move_to(astar, grid_location)
    await unit.move_end

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
        click_tile_at(event.position)
        get_viewport().set_input_as_handled()