extends Control

@onready var _player_label: Label = %player 

func set_current_commander(commander: Commander) -> void:
	_player_label.text = commander.name
	_player_label.label_settings.font_color = Color.from_hsv(commander.color_shift, 1, 1)
