extends Spatial

export (PackedScene) var CoinProjectile
export (PackedScene) var RevolverBullet
export (PackedScene) var ShotgunShell
export (PackedScene) var GrenadeProjectile

export (PackedScene) var ParticleCollision

const COIN_SPEED = 0.1

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
	
	$PrimaryCrosshairs.translation = primary_list[current_primary_index].crosshair_ray.global_translation
	$PrimaryCrosshairs.look_at(
		primary_list[current_primary_index].crosshair_collision,
		Vector3.UP
	)
	$PrimaryCrosshairs.translate(
		Vector3.FORWARD * primary_list[current_primary_index].crosshair_distance
	)
	$SecondaryCrosshairs.translation = secondary_list[current_secondary_index].crosshair_ray.global_translation
	$SecondaryCrosshairs.look_at(
		secondary_list[current_secondary_index].crosshair_collision,
		Vector3.UP
	)
	$SecondaryCrosshairs.translate(
		Vector3.FORWARD * secondary_list[current_secondary_index].crosshair_distance
	)

func set_accuracy_size(value):
	$Accuracy.scale.x = value
	$Accuracy.scale.z = value

func _on_Revolver_fire_weapon(ammo, accuracy):
	$PrimaryAmmo.text = str(ammo) + "/6"
	create_revolver_bullet(
		$Weapons_Primary/Revolver/BulletFirePosition.global_translation,
		$Weapons_Primary.rotation,
		accuracy
	)
	set_accuracy_size(1-accuracy)

func make_particle(position:Vector3, type:int):
	match type:
		0:
			var newParticle = ParticleCollision.instance()
			add_child(newParticle)
			newParticle.translation = position

func create_revolver_bullet(start:Vector3, rot:Vector3, acc:float):
	var newBullet = RevolverBullet.instance()
	add_child(newBullet)
	newBullet.translation = start
	newBullet.rotate_x(rot.x + rand_range(-1+acc,1-acc))
	newBullet.rotate_y(rot.y + rand_range(-1+acc,1-acc))
	newBullet.act = 1

func _on_Revolver_reload_weapon(ammo):
	$PrimaryAmmo.text = str(ammo) + "/6"
	set_accuracy_size(0)

func create_shotgun_shell(start:Vector3, rot:Vector3, acc:float):
	var newBullet = ShotgunShell.instance()
	add_child(newBullet)
	newBullet.translation = start
	newBullet.rotate_x(rot.x + rand_range(-1+acc,1-acc))
	newBullet.rotate_y(rot.y + rand_range(-1+acc,1-acc))
	newBullet.act = 1

func create_shotgun_blast(start:Vector3, rot:Vector3, acc:float):
	for _n in range(8):
		create_shotgun_shell(start, rot, acc)

func _on_Shotgun_fire_weapon(ammo, accuracy):
	$PrimaryAmmo.text = str(ammo) + "/2"
	create_shotgun_blast(
		$Weapons_Primary/Shotgun/FirePointA.global_translation,
		$Weapons_Primary/Shotgun/FirePointA.global_rotation,
		accuracy
	)
	create_shotgun_blast(
		$Weapons_Primary/Shotgun/FirePointB.global_translation,
		$Weapons_Primary/Shotgun/FirePointB.global_rotation,
		accuracy
	)
	set_accuracy_size(1-accuracy)

func _on_Shotgun_reload_weapon(ammo):
	$PrimaryAmmo.text = str(ammo) + "/2"
	set_accuracy_size(0)

func _on_Coin_fire_weapon(ammo, _accuracy):
	$SecondaryAmmo.text = str(ammo) + "/4"
	var newCoin = CoinProjectile.instance()
	add_child(newCoin)
	newCoin.translation = $Weapons_Secondary/Coin/BulletFirePosition.global_translation
	var dir = ($Weapons_Secondary/Coin/CoinAimAngle.global_translation - newCoin.global_translation).normalized()
	newCoin.apply_central_impulse(dir * COIN_SPEED)

func _on_Coin_reload_weapon(ammo):
	$SecondaryAmmo.text = str(ammo) + "/4"

func _on_Fist_swing_weapon(from, to):
	print("Fist wants to make hitbox from ", from, " to ", to)

func coin_bullet_rebound(start: Vector3, end: Vector3):
	create_revolver_bullet(start, end - start, 1.0)
