extends Spatial

var current = 0

func switch_crosshairs(ind: int):
	get_children()[current].hide()
	get_children()[ind].show()
	current = ind

func _process(delta):
	pass
