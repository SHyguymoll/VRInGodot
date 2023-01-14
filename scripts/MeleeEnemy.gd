extends Spatial

export var enemy_health: float
export var ground_move_speed: float
export (Array, String) var attack_list
export (Array, float) var attack_damage
export (Array, float) var attack_time

enum states {
	IDLE,
	CHASE,
	ATTACK,
	STUMBLE,
	DEATH
}
var state
var animations

func handle_damage(dmg_val):
	enemy_health -= dmg_val
	if rand_range(0, dmg_val) < dmg_val*0.25:
		state = states.STUMBLE

# Called when the node enters the scene tree for the first time.
func _ready():
	state = states.IDLE

func _process(_delta):
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
