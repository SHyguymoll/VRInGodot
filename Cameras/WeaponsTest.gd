extends Spatial

export (PackedScene) var CoinProjectile
export (PackedScene) var RevolverBullet
export (PackedScene) var ShotgunShell
export (PackedScene) var GrenadeProjectile

export (PackedScene) var ParticleCollision

const COIN_SPEED = 5

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
	$PrimaryName.text = primary_list[index].weapon_name
	$PrimaryAmmo.text = str(primary_list[index].ammo) + "/" + str(primary_list[index].max_ammo)

func select_secondary(index):
	secondary_list[current_secondary_index].state = 0
	secondary_list[index].state = 1 #states.IDLE, might add states.EQUIP or something later
	current_secondary_index = index
	$SecondaryName.text = secondary_list[index].weapon_name
	$SecondaryAmmo.text = str(secondary_list[index].ammo) + "/" + str(secondary_list[index].max_ammo)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_released("primary_next"):
		select_primary(current_primary_index + 1 if (current_primary_index < len(primary_list) - 1) else 0)
		$Crosshairs.switch_crosshairs(current_primary_index)
	if Input.is_action_just_released("primary_prev"):
		select_primary(current_primary_index - 1 if (current_primary_index > 0) else (len(primary_list) - 1))
		$Crosshairs.switch_crosshairs(current_primary_index)

func set_accuracy_size(value):
	$Wall/Accuracy.scale.x = value
	$Wall/Accuracy.scale.z = value

func _on_Revolver_fire_weapon(ammo, accuracy):
	$PrimaryAmmo.text = str(ammo) + "/6"
	create_revolver_bullet(
		$Weapons_Primary/Revolver/BulletFirePosition.global_translation,
		$Weapons_Primary/Revolver/BulletFirePosition.global_rotation,
		accuracy
	)
	set_accuracy_size(1-accuracy)

func make_particle(position:Vector3, type:int):
	var newParticle = ParticleCollision.instance()
	add_child(newParticle)
	newParticle.translation = position

func create_revolver_bullet(start:Vector3, rot:Vector3, acc:float):
	var newBullet = RevolverBullet.instance()
	add_child(newBullet)
	newBullet.translation = start
	newBullet.rotation = rot
	newBullet.rotation += Vector3(
		rand_range(0,1-acc),
		rand_range(0,1-acc),
		rand_range(0,1-acc)
	)

func create_shotgun_blast(start:Vector3, rot:Vector3, acc:float):
	for n in range(8):
		var newBullet = ShotgunShell.instance()
		add_child(newBullet)
		newBullet.translation = start
		newBullet.rotation = rot
		newBullet.rotation += Vector3(
			rand_range(0,1-acc),
			rand_range(0,1-acc),
			rand_range(0,1-acc)
		)

func _on_Revolver_reload_weapon(ammo):
	$PrimaryAmmo.text = str(ammo) + "/6"
	set_accuracy_size(0)

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

func _on_Coin_fire_weapon(ammo, accuracy):
	$SecondaryAmmo.text = str(ammo) + "/4"
	var newCoin = CoinProjectile.instance()
	add_child(newCoin)
	newCoin.translation = $Weapons_Secondary/Coin/CoinFireLocation.global_translation
	newCoin.rotation = $Weapons_Secondary/Coin/CoinFireLocation.global_rotation

func _on_Coin_reload_weapon(ammo):
	$SecondaryAmmo.text = str(ammo) + "/4"
