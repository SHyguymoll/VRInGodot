extends Spatial

export var left_hand = false #if in the left hand
export var ammo: int #current ammo in gun
export var ammo_change: int #how much ammo is used when firing
export var reload_time: float #time for reloading
onready var reload_timer = $ReloadTimer
export var reload_amount: int #what ammo gets set to after reloading
export var fire_break_time: float #time between shots
onready var fire_pause_timer = $FirePauseTimer
export var accuracy_initial: float #initial accuracy
export var accuracy_held: float #accuracy lerped to while holding down the trigger
export var accuracy_lerp: float #lerp value for changing accuracy
var state: int #current state of gun

var fire_button = ""
var reload_button = ""
var current_accuracy = 0.0

enum states {
	IDLE,
	FIRING,
	RELOADING,
	DISABLED
}

func _ready():
	ammo = reload_amount
	reload_timer.wait_time = reload_time
	reload_timer.one_shot = true
	fire_pause_timer.wait_time = fire_break_time
	fire_pause_timer.one_shot = true
	
	fire_button = "fire_" + ("right" if !left_hand else "left")
	reload_button = "reload_" + ("right" if !left_hand else "left")
	state = states.IDLE

func reload_routine():
	print("reloading!")
	reload_timer.start()
	state = states.RELOADING

func fire_routine():
	make_bullet(current_accuracy, ammo_change)
	fire_pause_timer.start()

func _process(delta):
	match state:
		states.IDLE:
			if ammo < 1:
				reload_routine()
			if Input.is_action_pressed(fire_button):
				current_accuracy = accuracy_initial
				fire_routine()
				state = states.FIRING
			if Input.is_action_pressed(reload_button) and ammo < reload_amount:
				reload_routine()
		states.FIRING:
			if ammo < 1:
				reload_routine()
			else:
				if fire_pause_timer.is_stopped():
					if Input.is_action_pressed(fire_button): #still holding the button
						current_accuracy = lerp(current_accuracy, accuracy_held, accuracy_lerp)
						fire_routine()
					else: #let go of the button
						state = states.IDLE
		states.RELOADING:
			if reload_timer.is_stopped():
				print("reloaded!")
				ammo = reload_amount
				state = states.IDLE
		states.DISABLED:
			pass

func make_bullet(accuracy: float, cost: int):
	ammo -= cost
	print("firing " + ("last " if ammo < 1 else "") + "bullet with " + str(accuracy) + " accuracy!")
