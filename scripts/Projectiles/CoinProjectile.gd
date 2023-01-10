extends RigidBody

signal coin_rebound

var active = 0
var split_shot_active = 1
var ready_to_rebound = 0

#func _ready():
#	connect("coin_rebound", $"..", "coin_bullet_rebound")

func _physics_process(delta):
	if ready_to_rebound:
		
		emit_signal("coin_rebound", translation, calculate_rebound($Detection.get_overlapping_areas(), $Detection.get_overlapping_bodies()))
		if split_shot_active:
			print("split shot")
			emit_signal("coin_rebound", translation, calculate_rebound($Detection.get_overlapping_areas(), $Detection.get_overlapping_bodies()))
		$ShootHitbox.set_deferred("monitoring", false)
		$Detection.set_deferred("monitoring", false)
		queue_free()

func _on_DeadTimer_timeout():
	active = 1

func _on_SuperTimer_timeout():
	split_shot_active = 0

func _on_LifeTimer_timeout():
	queue_free()

func calculate_rebound(surrounding_areas: Array, surrounding_bodies: Array):
	global_rotation = Vector3.ZERO
	print(surrounding_areas)
	print(surrounding_bodies)
	#remember to ignore the first detected coin (as that is itself) and the first detected bullet (as that is the bullet that hit the coin)
	var enemy = []
	var glass = []
	var other = []
	for entry in surrounding_bodies:
		if entry.get("split_shot_active") != null and entry.global_translation != global_translation: #entry is a different coin, no need to sort
			entry.global_rotation = Vector3.ZERO
			entry.linear_velocity = Vector3.UP
			return entry.global_translation
		elif entry.get("enemy_health") != null: #entry is an enemy
			enemy.append(entry)
			continue
		elif entry.get("glass_broken") != null: #entry is glass
			glass.append(entry)
			continue
		else:
			other.append(entry) #entry is anything else
	for entry in surrounding_areas:
		if entry.get("enemy_health") != null: #entry is an enemy
			enemy.append(entry)
			continue
		elif entry.get("glass_broken") != null: #entry is glass
			glass.append(entry)
			continue
		else:
			other.append(entry) #entry is anything else
	if len(enemy):
		return enemy[0].get_node("WeakHurtbox").global_translation
	if len(glass):
		return glass[0].global_translation
	return global_translation #nothing to reflect towards

func _on_ShootHitbox_area_entered(area):
	if area.get("bullet_type") == 1: #revolver bullet
		ready_to_rebound = 1
