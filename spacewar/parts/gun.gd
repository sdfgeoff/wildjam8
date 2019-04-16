extends "res://parts/simple.gd"

export(NodePath) var spawner = ""
export(bool) var is_secondary = false
export(PackedScene) var bullet_scene = null
export(float) var refire_time = 0.5

var _active = false
var _time = 0.0

func _init():
	if is_secondary:
		type = MODULE_TYPES.SECONDARY
	else:
		type = MODULE_TYPES.PRIMARY


func set_active():
	_active = true
	
func _process(delta):
	_time += delta
	if _active == true:
		if _time > refire_time:
			_fire()
			_time = 0.0
		_active = false


func _fire():
	var bullet = bullet_scene.instance()
	get_parent().get_parent().add_child(bullet)
	bullet.global_transform = get_node(spawner).global_transform
	bullet.add_collision_exception_with(get_parent())