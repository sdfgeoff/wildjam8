extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	utils.play_sound_effect(preload("res://sounds/big_explosion.wav"), 1.0)
	$AnimationPlayer.play("Explode")