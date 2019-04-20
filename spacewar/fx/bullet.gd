extends "res://warpbody.gd"

export(float) var velocity = 2000.0
export(float) var damage = 0.5

export (float) var max_life = 5.0
export(PackedScene) var splash = null


func _ready():
	linear_damp = 0.0
	contact_monitor = true
	contacts_reported = 5
	connect("body_entered", self, "_on_hit")
	$AudioStreamPlayer.pitch_scale = randf() * 0.2 + 1.0
	connect("on_warp", self, "_on_warp")

# Called when the node enters the scene tree for the first time.
func _process(delta):
	linear_velocity = global_transform.y * velocity
	max_life -= delta
	if max_life < 0.0:
		queue_free()

func _on_hit(_body):
	var splash_instance = splash.instance()
	get_parent().add_child(splash_instance)
	splash_instance.global_transform = global_transform
	queue_free()

func get_damage():
	return damage


func _on_warp(warps):
	if warps == 2:
		queue_free()