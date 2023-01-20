extends RigidBody

signal coin_rebound

var active = 0
var split_shot_active = 1
var ready_to_rebound = 0
var damage = 1
var last_vel = Vector3.ZERO
const MIN_SPEED = Vector3(0.0001, 0.0001, 0.0001)

func _ready():
	connect("coin_rebound", $"..", "coin_bullet_rebound")

func handle_damage(dmg): #All targetable entities must have this function
	damage += dmg
	ready_to_rebound = 1

func _physics_process(delta):
	if active and (
		((linear_velocity.x < 0 and last_vel.x > 0) or #x bounce check
		(linear_velocity.y < 0 and last_vel.y > 0) or #y bounce check
		(linear_velocity.z < 0 and last_vel.z > 0)) or #z bounce check
		linear_velocity.abs() < MIN_SPEED): #simple speed check
		print("bounced or stopped")
		queue_free()
	if ready_to_rebound:
		var list_of_detects = $Detection.get_overlapping_areas() + $Detection.get_overlapping_bodies()
		emit_signal("coin_rebound", self, calculate_rebound(list_of_detects), damage)
#		if split_shot_active:
#			print("split shot")
#			emit_signal("coin_rebound", self, calculate_rebound(list_of_detects), damage)
		$ShootHurtbox.set_deferred("monitoring", false)
		$Detection.set_deferred("monitoring", false)
		$WorldCollide.set_deferred("monitoring", false)
		queue_free()
	last_vel = linear_velocity

func _on_DeadTimer_timeout():
	active = 1

func _on_SuperTimer_timeout():
	split_shot_active = 0

func _on_LifeTimer_timeout():
	queue_free()

func calculate_rebound(detects: Array) -> Node:
	print(self, " detected ", detects)
	var coin = []
	var enemy = []
	var glass = []
	var other = []
	for entry in detects:
		if entry.get("split_shot_active") != null: #entry is a coin 
			if entry != self and entry.get("ready_to_rebound") == 0: #entry is a different coin, and it hasn't been used already
				coin.append(entry)
			else:
				continue
		elif entry.get("damage_multiplier") != null: #entry is an enemy hurtbox
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
			return try #xray coin mode
#			var get_collision = $Detection.get_world().direct_space_state.intersect_ray(global_translation, try.global_translation).get("collider")
#			print(try, " sees ", get_collision, "? ", try == get_collision)
#			if get_collision == try: #if the coin can see try, it's valid
#				return try
	return self #nothing to reflect towards (somehow)


func _on_WorldCollide_area_entered(area):
	if area != self:
		queue_free()
