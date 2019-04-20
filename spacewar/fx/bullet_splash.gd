extends Particles2D

export (AudioStream) var sound = preload("res://sounds/partdie.wav")
var age = 0.0

func _ready():
	emitting = true
	utils.play_sound_effect(sound, 0.8, 0.8 + randf()*0.4)

func _process(delta):
	age += delta
	if age > lifetime:
		queue_free()
