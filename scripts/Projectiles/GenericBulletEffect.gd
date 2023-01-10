extends Spatial
var act = 0

func _on_LifeTimer_timeout():
	queue_free()

func set_length(length: float):
	$Model.global_translation.z = length/2
	$Model.mesh.mid_height = length

func _ready():
	$Model.hide()

func _process(_delta):
	if act:
		act = 0
		$Model.show()
		$LifeTimer.start()
