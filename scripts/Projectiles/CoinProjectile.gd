extends RigidBody

var active = 0
var super_active = 1


func _on_DeadTimer_timeout():
	active = 1

func _on_SuperTimer_timeout():
	super_active = 0

func _on_LifeTimer_timeout():
	queue_free()
