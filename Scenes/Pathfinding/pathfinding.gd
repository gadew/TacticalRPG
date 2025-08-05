extends Node2D

@onready var terrain: TileMapLayer = %terrain
@onready var astar: AStarGrid2D = AStarGrid2D.new()

func click_tile_at(input_global_position: Vector2):
    var grid_location: Vector2i = terrain.local_to_map(terrain.to_local(input_global_position))
    print(grid_location)

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
        click_tile_at(event.position)
        get_viewport().set_input_as_handled()