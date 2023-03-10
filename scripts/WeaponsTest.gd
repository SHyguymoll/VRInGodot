extends Spatial

export (PackedScene) var CoinProjectile
export (PackedScene) var RevolverBullet
export (PackedScene) var ShotgunShell
export (PackedScene) var GrenadeProjectile

export (Array, PackedScene) var ParticleList

const COIN_SPEED = 0.1
const SEARCH_DIST = 100
const CROSSHAIR_REST = Vector3(0,0,5)

var primary_list
var secondary_list
var current_primary_index
var current_secondary_index

# Called when the node enters the scene tree for the first time.
func _ready():
	primary_list = $Weapons_Primary.get_children()
	secondary_list = $Weapons_Secondary.get_children()
	if len(primary_list) == 0:
		printerr("No primaries found!")
	for weapon in primary_list:
		weapon.state = 0 #states.DISABLED, should hide the model and disable actions
	current_primary_index = 0
	select_primary(0)
	set_accuracy_size(0)
	if len(secondary_list) == 0:
		printerr("No secondaries found!")
	for weapon in secondary_list:
		weapon.state = 0 #states.DISABLED, should hide the model and disable actions
	current_secondary_index = 0
	select_secondary(0)

func select_primary(index):
	primary_list[current_primary_index].state = 0
	primary_list[index].state = 1 #states.IDLE, might add states.EQUIP or something later
	current_primary_index = index
	$PrimaryCrosshairs.switch_crosshairs(index)
	$PrimaryName.text = primary_list[index].weapon_name
	$PrimaryAmmo.text = str(primary_list[index].ammo) + "/" + str(primary_list[index].max_ammo) if (primary_list[index].get("ammo") != null) else ""

func select_secondary(index):
	secondary_list[current_secondary_index].state = 0
	secondary_list[index].state = 1 #states.IDLE, might add states.EQUIP or something later
	current_secondary_index = index
	$SecondaryName.text = secondary_list[index].weapon_name
	$SecondaryAmmo.text = str(secondary_list[index].ammo) if secondary_list[index].get("ammo") else "" + ("/" + str(secondary_list[index].max_ammo) if secondary_list[index].get("max_ammo") else "")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_released("primary_next"):
		select_primary(current_primary_index + 1 if (current_primary_index < len(primary_list) - 1) else 0)
	if Input.is_action_just_released("primary_prev"):
		select_primary(current_primary_index - 1 if (current_primary_index > 0) else (len(primary_list) - 1))
	if Input.is_action_just_released("switch_secondary"):
		select_secondary(current_secondary_index + 1 if (current_secondary_index < len(secondary_list) - 1) else 0)
	
	var prime_cross = primary_list[current_primary_index].crosshair_ray
	var prime_cross_coll = primary_list[current_primary_index].crosshair_collision
	$PrimaryCrosshairs.translation = prime_cross_coll if prime_cross.is_colliding() else prime_cross.to_global(CROSSHAIR_REST)
	var sec_cross = secondary_list[current_secondary_index].crosshair_ray
	var sec_cross_coll = secondary_list[current_secondary_index].crosshair_collision
	$SecondaryCrosshairs.translation = sec_cross_coll if sec_cross.is_colliding() else sec_cross.to_global(CROSSHAIR_REST)

func make_particle(position:Vector3, type:int):
	var newParticle = ParticleList[type].instance()
	add_child(newParticle)
	newParticle.translation = position

func set_accuracy_size(value):
	$Accuracy.scale.x = value
	$Accuracy.scale.z = value

func create_bullet_effect(bullet_scene: PackedScene, start:Vector3, end:Vector3):
	var length = start.distance_to(end)
	var rot = end.direction_to(start)
	var newBullet = bullet_scene.instance()
	add_child(newBullet)
	newBullet.global_translate(start.linear_interpolate(end, 0.5))
	newBullet.set_length(length)
	newBullet.look_at(end, Vector3.UP)

func gun_damage(hit, dmg_val):
	if hit != null and hit.has_method("handle_damage"):
		hit.handle_damage(dmg_val)

func _on_Revolver_fire_weapon(ammo, accuracy, thing_hit, hit_position):
	$PrimaryAmmo.text = str(ammo) + "/6"
	var rev_pos = $Weapons_Primary/Revolver/BulletFirePosition.global_translation
	create_bullet_effect(
		RevolverBullet,
		rev_pos,
		hit_position
	)
	make_particle(hit_position, 0)
	gun_damage(thing_hit, 1)
	set_accuracy_size(1-accuracy)

func _on_Revolver_reload_weapon(ammo):
	$PrimaryAmmo.text = str(ammo) + "/6"
	set_accuracy_size(0)

func _on_Shotgun_fire_weapon(ammo, accuracy, thing_hit, hit_position):
	$PrimaryAmmo.text = str(ammo) + "/2"
	create_bullet_effect(
		ShotgunShell,
		$Weapons_Primary/Shotgun/FirePointA.global_translation if bool(randi() % 2) else $Weapons_Primary/Shotgun/FirePointB.global_translation,
		hit_position
	)
	gun_damage(thing_hit, 0.25)
	set_accuracy_size(1-accuracy)

func _on_Shotgun_reload_weapon(ammo):
	$PrimaryAmmo.text = str(ammo) + "/2"
	set_accuracy_size(0)

func _on_Coin_fire_weapon(ammo, _accuracy):
	$SecondaryAmmo.text = str(ammo) + "/4"
	var newCoin = CoinProjectile.instance()
	
	newCoin.translation = $Weapons_Secondary/Coin/BulletFirePosition.global_translation
	var dir = ($Weapons_Secondary/Coin/CoinAimAngle.global_translation - newCoin.global_translation).normalized()
	newCoin.apply_central_impulse(dir * COIN_SPEED)
	add_child(newCoin)

func coin_bullet_rebound(coin: RigidBody, end, dmg_val: float):
	if coin == end: #no reflect
		var hopefully_ground = get_world().direct_space_state.intersect_ray(coin.global_translation, coin.global_translation + Vector3.DOWN * SEARCH_DIST, [coin])
		if len(hopefully_ground) != 0:
			 create_bullet_effect(
				RevolverBullet,
				coin.global_translation,
				hopefully_ground.get("position")
			)
	else: #this is an area or rigidbody
		gun_damage(end, dmg_val) #all damagable entities require this function!
		create_bullet_effect(
				RevolverBullet,
				coin.global_translation,
				end.global_translation
			)

func _on_Coin_reload_weapon(ammo):
	$SecondaryAmmo.text = str(ammo) + "/4"

func _on_Fist_swing_weapon(from, to):
	print("Fist wants to make hitbox from ", from, " to ", to)
