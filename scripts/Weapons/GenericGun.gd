extends Spatial

#The most basic gun. Reloads its entire clip when empty, or when the reload key is pressed.
signal fire_weapon
signal reload_weapon

export var weapon_name: String
export var left_hand = false #if in the left hand
export var ammo: int #current ammo in gun
export var ammo_change: int #how much ammo is used when firing
export var reload_time: float #time for reloading
onready var reload_timer = $ReloadTimer
export var max_ammo: int #what ammo gets set to after reloading
export var fire_break_time: float #time between shots
onready var fire_pause_timer = $FirePauseTimer
export var accuracy_initial: float #initial accuracy
export var accuracy_held: float #accuracy lerped to while holding down the trigger
export var accuracy_lerp: float #lerp value for changing accuracy
var state: int #current state of gun
onready var animations = $Animations
onready var fire_sound = $FireSound
onready var model = $Model
onready var crosshair_ray = $BulletFirePosition
var fire_button = ""
var reload_button = ""
var current_accuracy = 0.0
var crosshair_distance = 0.0
var crosshair_collision = Vector3(0,0,0)

enum states {
	DISABLED, #always 0
	IDLE,
	FIRING,
	RELOADING,
}

func _ready():
	ammo = max_ammo
	reload_timer.wait_time = reload_time
	reload_timer.one_shot = true
	fire_pause_timer.wait_time = fire_break_time
	fire_pause_timer.one_shot = true
	
	fire_button = "fire_" + ("right" if !left_hand else "left")
	reload_button = "reload_" + ("right" if !left_hand else "left")
	state = states.IDLE

func reload_routine():
	print("reloading!")
	animations.play("Reload")
	reload_timer.start()
	state = states.RELOADING

func fire_routine():
	animations.play("Fire")
	make_bullet(current_accuracy, ammo_change)
	fire_pause_timer.start()

func _process(_delta):
	if state != states.DISABLED:
		var test_col = crosshair_ray.get_collision_point()
		crosshair_distance = crosshair_ray.global_translation.distance_to(test_col) if crosshair_ray.is_colliding() else -5
		crosshair_collision = test_col if crosshair_ray.is_colliding() else Vector3(0,0,0)
	match state:
		states.IDLE:
			model.show()
			animations.play("Idle")
			
			if ammo < 1:
				reload_routine()
			if Input.is_action_pressed(fire_button):
				current_accuracy = accuracy_initial
				fire_routine()
				state = states.FIRING
			if Input.is_action_pressed(reload_button) and ammo < max_ammo:
				reload_routine()
				
		states.FIRING:
			if fire_pause_timer.is_stopped():
				if ammo < 1:
					reload_routine()
				else:
					if Input.is_action_pressed(fire_button): #still holding the button
						current_accuracy = lerp(current_accuracy, accuracy_held, accuracy_lerp)
						fire_routine()
					else: #let go of the button
						state = states.IDLE
		states.RELOADING:
			if reload_timer.is_stopped():
				ammo = max_ammo
				emit_signal("reload_weapon", ammo)
				print("reloaded!")
				state = states.IDLE
		states.DISABLED:
			model.hide()

func make_bullet(accuracy: float, cost: int):
	ammo -= cost
	emit_signal("fire_weapon", ammo, accuracy)
	print("firing " + ("last " if ammo < 1 else "") + "bullet with " + str(accuracy) + " accuracy!")
