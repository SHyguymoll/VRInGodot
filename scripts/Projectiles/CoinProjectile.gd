extends RigidBody

signal coin_rebound

var active = 0
var super_active = 1

func _ready():
	connect("coin_rebound", $"..", "coin_bullet_rebound")

func _on_DeadTimer_timeout():
	active = 1

func _on_SuperTimer_timeout():
	super_active = 0

func _on_LifeTimer_timeout():
	queue_free()

func calculate_rebound(surrounding_areas, surrounding_bodies):
	print("it should rebound here")
	return Vector3(0,4,-16)

func _on_ShootHitbox_area_entered(area):
	if area.get("is_a_bullet") == true:
		emit_signal("coin_rebound", translation, calculate_rebound($Detection.get_overlapping_areas(), $Detection.get_overlapping_bodies()))
		if super_active:
			print("split shot")
			emit_signal("coin_rebound", translation, calculate_rebound($Detection.get_overlapping_areas(), $Detection.get_overlapping_bodies()))
		queue_free()
