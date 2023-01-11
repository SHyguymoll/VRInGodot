extends Spatial

func _on_LifeTimer_timeout():
	queue_free()

func set_length(length: float):
	$Model.mesh.mid_height = length

func _ready():
	$Model.hide()

func _process(_delta):
	$Model.show()
	if $LifeTimer.is_stopped(): $LifeTimer.start()
