extends Particles

func _ready():
	emitting = 1
	#$CrashSound.play()

func _process(delta):
	if !emitting:
		queue_free()
