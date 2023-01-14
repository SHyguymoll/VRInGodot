extends Area

export (float) var damage_multiplier = 1.0

func handle_damage(dmg_val):
	print("doing ", dmg_val * damage_multiplier, " damage!")
	$"..".handle_damage(dmg_val * damage_multiplier)
