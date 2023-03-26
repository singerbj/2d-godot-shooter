extends CollisionShape2D

func _draw():
	shape.draw(get_canvas_item(), Color.WHITE)
	
func _is_ground():
	return true
