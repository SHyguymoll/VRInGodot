extends Particles

func _ready():
	emitting = 1
	#$CrashSound.play()

func _process(_delta):
	if !emitting:
		queue_free()
