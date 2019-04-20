tool
extends HBoxContainer

var SHIP_PREVIEW_SCENE = preload("res://ui/ship_viewport.tscn")

var init = false

func _ready():
	create_displays()
	

func create_displays():
	for child in get_children():
		child.queue_free()
	for ship_id in range(len(defs.SHIPS)):
		var preview = SHIP_PREVIEW_SCENE.instance()
		preview.ship_id = ship_id
		add_child(preview)
	init = true


func _process(_delta):
	if not init:
		create_displays()