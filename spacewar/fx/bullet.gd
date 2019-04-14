extends KinematicBody2D

export(float) var velocity = 20.0
export(float) var damage = 0.5

export (float) var max_life = 5.0


# Called when the node enters the scene tree for the first time.
func _process(delta):
	var col := move_and_collide(transform.y * velocity) 
	max_life -= delta
	if col != null or max_life < 0.0:
		queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
