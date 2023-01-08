extends Spatial

#Basic melee. Has the ability to melee.
signal swing_weapon

export var weapon_name: String
export var recover_time: float #time for recovering
onready var recover_timer = $RecoverTimer
export var active_time: float #time for active
onready var active_timer = $ActiveTimer
export var minimum_velocity: float
var state: int #current state of melee
onready var animations = $Animations
onready var active_effects = $SwingTrail
onready var fire_sound = $FireSound
onready var model = $Model
onready var crosshair_ray = $BulletFirePosition
var fire_button = ""
var reload_button = ""
var current_velocity = 0.0
var previous_location = Vector3(0,0,0)

enum states {
	DISABLED, #always 0
	IDLE,
	ACTIVE,
}

func _ready():
	recover_timer.wait_time = recover_time
	recover_timer.one_shot = true
	active_timer.wait_time = active_time
	active_timer.one_shot = true
	state = states.IDLE

func _process(delta):
	match state:
		states.IDLE:
			model.show()
			animations.play("Idle")
			current_velocity = previous_location.distance_to(translation)/delta
			if (current_velocity > minimum_velocity) and recover_timer.is_stopped():
				state = states.ACTIVE
				print("swinging weapon with " + str(current_velocity) + " velocity!")
				emit_signal("swing_weapon", previous_location, translation)
				active_effects.emitting = 1
				active_timer.start()
			previous_location = translation
		states.ACTIVE:
			if active_timer.is_stopped():
				recover_timer.start()
				state = states.IDLE
		states.DISABLED:
			model.hide()
