extends KinematicBody

export var enemy_health: float
export var ground_move_speed: float
export (Array, String) var attack_name
export (Array, float) var attack_damage
export (Array, float) var attack_time

enum states {
	IDLE,
	CHASE,
	ATTACK,
	STUMBLE,
	DEATH
}
onready var model = $Model
onready var animations = $Animations
var state

func handle_damage(dmg_val):
	if enemy_health != -1:
		enemy_health -= dmg_val
		if enemy_health < 0:
			state = state.DEATH
	if rand_range(0, dmg_val) < dmg_val*0.25:
		state = states.STUMBLE

# Called when the node enters the scene tree for the first time.
func _ready():
	state = states.IDLE

func pick_attack():
	pass

func _process(_delta):
	match state:
		states.IDLE:
			model.show()
			animations.play("Idle")
		states.CHASE:
			pass
		states.ATTACK:
			pick_attack()
			state = states.IDLE
		states.STUMBLE:
			pass
		states.DEATH:
			pass
