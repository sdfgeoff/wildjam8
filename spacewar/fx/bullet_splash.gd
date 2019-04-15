extends Particles2D


var age = 0.0

func _ready():
	emitting = true

func _process(delta):
	age += delta
	if age > lifetime:
		queue_free()
