extends Area2D

# Declare Variables
var grid_size = 64
var user_input = {
	"right": Vector2.RIGHT,
	"left": Vector2.LEFT,
	"up": Vector2.UP,
	"down": Vector2.DOWN
	}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	position = position.snapped(Vector2.ONE * grid_size)
	position += Vector2.ONE * grid_size/2

func _input(event):
	for dir in user_input.keys():
		if event.is_action_pressed(dir):
			move_to_pos(dir)

func move_to_pos(dir):
	position += user_input[dir] * grid_size
