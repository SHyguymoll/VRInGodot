extends RigidBody

signal coin_rebound

var active = 0
var split_shot_active = 1
var ready_to_rebound = 0
var damage = 1

func _ready():
	connect("coin_rebound", $"..", "coin_bullet_rebound")

func handle_damage(dmg): #All targetable entities must have this function
	damage += dmg
	ready_to_rebound = 1

func _physics_process(delta):
	if ready_to_rebound:
		var list_of_detects = $Detection.get_overlapping_areas() + $Detection.get_overlapping_bodies()
		emit_signal("coin_rebound", self, calculate_rebound(list_of_detects), damage)
#		if split_shot_active:
#			print("split shot")
#			emit_signal("coin_rebound", self, calculate_rebound(list_of_detects), damage)
		$ShootHitbox.set_deferred("monitoring", false)
		$Detection.set_deferred("monitoring", false)
		queue_free()

func _on_DeadTimer_timeout():
	active = 1

func _on_SuperTimer_timeout():
	split_shot_active = 0

func _on_LifeTimer_timeout():
	queue_free()

func calculate_rebound(detects: Array):
	global_rotation = Vector3.ZERO
	print(detects)
	#remember to ignore the first detected coin (as that is itself) and the first detected bullet (as that is the bullet that hit the coin)
	var coin = []
	var enemy = []
	var glass = []
	var other = []
	for entry in detects:
		if entry.get("split_shot_active") != null: #entry is a coin 
			if (
				entry.get("split_shot_active") != null and
				entry.global_translation != global_translation and
				entry.get("ready_to_rebound") == 0
				): #entry is a different coin, and it hasn't been used already
				coin.append(entry)
		elif entry.get("enemy_health") != null: #entry is an enemy
			enemy.append(entry)
			continue
		elif entry.get("glass_broken") != null: #entry is glass
			glass.append(entry)
			continue
		else:
			other.append(entry) #entry is anything else
	var combine_arrays = [coin, enemy, glass, other]
	for try_array in combine_arrays:
		for try in try_array:
			if get_world().direct_space_state.intersect_ray(global_translation, try.global_translation, [self]).get("collider") == try: #if the coin can see try, it's valid
				return try
	return global_translation #nothing to reflect towards, reflect down


