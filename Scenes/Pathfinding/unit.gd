class_name Unit
extends Node2D

signal move_end(Unit)

var grid_location: Vector2i = Vector2i.ZERO

func move_to(pathfinding: AStarGrid2D, grid_target_location: Vector2i, duration: float = 0.25):
	var points: PackedVector2Array = pathfinding.get_point_path(grid_location, grid_target_location)
	if not points.is_empty():
		var tween: Tween = create_tween()
		for point in points:
			tween.tween_property(self, "position", point + Vector2.ONE * 32, duration)
		await tween.finished   
		grid_location = grid_target_location
	move_end.emit(self)
