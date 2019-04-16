extends Area2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	connect("body_exited", self, "_on_exit")
	
func _on_exit(body):
	var delta = global_position - body.global_position
	body.global_position += delta * 1.9
	#body.rotation += PI
	