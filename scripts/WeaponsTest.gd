extends Spatial

var weapon_list
var current_weapon_index


# Called when the node enters the scene tree for the first time.
func _ready():
	weapon_list = $Weapons.get_children()
	if len(weapon_list) == 0:
		printerr("No weapons found!")
	for weapon in weapon_list:
		weapon.state = 0 #states.DISABLED, should hide the model and disable actions
	current_weapon_index = 0
	select_weapon(0)

func select_weapon(index):
	weapon_list[current_weapon_index].state = 0
	weapon_list[index].state = 1 #states.IDLE, might add states.EQUIP or something later
	current_weapon_index = index
	$WeaponName.text = weapon_list[index].weapon_name
	$WeaponAmmo.text = str(weapon_list[index].ammo) + "/" + str(weapon_list[index].reload_amount)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_pressed("weapon_next"):
		select_weapon(current_weapon_index + 1 if (current_weapon_index < len(weapon_list) - 1) else 0)
	if Input.is_action_pressed("weapon_prev"):
		select_weapon(current_weapon_index - 1 if (current_weapon_index > 0) else (len(weapon_list) - 1))


func _on_Revolver_fire_weapon(ammo, accuracy):
	$WeaponAmmo.text = str(ammo) + "/6"
	$Wall/Accuracy.scale.x = 1-accuracy
	$Wall/Accuracy.scale.z = 1-accuracy


func _on_Revolver_reload_weapon(ammo):
	$WeaponAmmo.text = str(ammo) + "/6"
	$Wall/Accuracy.scale.x = 0
	$Wall/Accuracy.scale.z = 0
