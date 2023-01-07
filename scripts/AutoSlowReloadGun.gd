extends Spatial

#A gun that reloads piecemeal over time.

signal fire_weapon
signal reload_weapon

export var weapon_name: String
export var left_hand = false #if in the left hand
export var ammo: int #current ammo in gun
export var ammo_change: int #how much ammo is used when firing
export var reload_time: float #time for reloading
onready var reload_timer = $ReloadTimer
export var reload_change: int #how much ammo changes by when reloading
export var max_ammo: int #maximum ammo
export var fire_break_time: float #time between shots
onready var fire_pause_timer = $FirePauseTimer
export var accuracy_initial: float #initial accuracy
export var accuracy_held: float #accuracy lerped to while holding down the trigger
export var accuracy_lerp: float #lerp value for changing accuracy
var state: int #current state of gun
onready var animations = $Animations
onready var fire_sound = $FireSound
onready var model = $Model
var fire_button = ""
var current_accuracy = 0.0

enum states {
	DISABLED, #always 0
	IDLE, #always 1
	FIRING,
}

func _ready():
	ammo = max_ammo
	reload_timer.wait_time = reload_time
	reload_timer.one_shot = false
	reload_timer.start()
	reload_timer.connect("timeout", self, "_on_ReloadTimer_timeout")
	fire_pause_timer.wait_time = fire_break_time
	fire_pause_timer.one_shot = true
	
	fire_button = "fire_" + ("right" if !left_hand else "left")
	state = states.IDLE

func fire_routine():
	animations.play("Fire")
	make_bullet(current_accuracy, ammo_change)
	reload_timer.stop()
	fire_pause_timer.start()

func _process(delta):
	match state:
		states.IDLE:
			model.show()
			animations.play("Idle")
			if ammo < max_ammo:
				reload_timer.paused = 0
			else:
				reload_timer.paused = 1
			if Input.is_action_pressed(fire_button):
				current_accuracy = accuracy_initial
				fire_routine()
				state = states.FIRING
		states.FIRING:
			if fire_pause_timer.is_stopped():
				reload_timer.start()
				if Input.is_action_pressed(fire_button): #still holding the button
					current_accuracy = lerp(current_accuracy, accuracy_held, accuracy_lerp)
					fire_routine()
				else: #let go of the button
					state = states.IDLE
		states.DISABLED:
			model.hide()

func make_bullet(accuracy: float, cost: int):
	ammo -= cost
	emit_signal("fire_weapon", ammo, accuracy)
	print("firing " + ("last " if ammo < 1 else "") + "bullet with " + str(accuracy) + " accuracy!")


func _on_ReloadTimer_timeout():
	ammo = int(min(ammo + reload_change, max_ammo))
	emit_signal("reload_weapon", ammo)
	print("reloaded!")
