extends Spatial

export var left_hand = false #if in the left hand
export var ammo: int #current ammo in gun
export var reload_time: float #time for reloading
export var reload_amount: int #what ammo gets set to after reloading
export var fire_break_time: float #time between shots
export var accuracy_initial: float #initial accuracy
export var accuracy_held: float #accuracy lerped to while holding down the trigger
export var state: int #current state of gun
enum states {
	IDLE,
	FIRED,
	RELOADING
}

func _ready():
	ammo = reload_amount
