extends Node2D

@onready var terrain: TileMapLayer = %terrain
@onready var unit: Unit = %unit
@onready var astar: AStarGrid2D = AStarGrid2D.new()

func _ready() -> void:
    #initialize based on tilemaplayer values
    astar.cell_size = terrain.tile_set.tile_size
    astar.region = terrain.get_used_rect()
    astar.update()
    
    #set solid blocks as untraversable in AStarGrid2D graph
    var used_cells: Array[Vector2i] = terrain.get_used_cells()
    var solid_cells: Array[Vector2i] = used_cells.filter(func(x): return not terrain.get_cell_tile_data(x).get_custom_data("traversable"))
    for cell: Vector2i in solid_cells:
        astar.set_point_solid(cell)

func click_tile_at(input_global_position: Vector2):
    var grid_location: Vector2i = terrain.local_to_map(terrain.to_local(input_global_position))

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
        click_tile_at(event.position)
        get_viewport().set_input_as_handled()