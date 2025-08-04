extends Area2D

# Declare Variables
var grid_size = 64
var mouse_position : Vector2
var target_grid_position : Vector2
var target_world_position : Vector2
var grid_x : int
var grid_y : int
var user_input = {
	"right": Vector2.RIGHT,
	"left": Vector2.LEFT,
	"up": Vector2.UP,
	"down": Vector2.DOWN
	}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	target_world_position = Vector2(0.0,0.0)
	
	# position property update to center character on a grid square
	position = target_world_position + (Vector2(grid_size/2, grid_size/2))

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				move_to_mouse()
	for direction in user_input.keys():
		if event.is_action_pressed(direction):
			move_grid_square(direction)

func move_grid_square(direction):
	position += user_input[direction] * grid_size

func move_to_mouse():
	# floor function used to round down to nearest integer
	mouse_position = get_global_mouse_position()
	grid_x = floor(mouse_position.x / grid_size)
	grid_y = floor(mouse_position.y / grid_size)

	target_grid_position = Vector2(grid_x, grid_y)
	target_world_position = (target_grid_position * grid_size) 
	position = target_world_position + (Vector2(grid_size/2, grid_size/2))
