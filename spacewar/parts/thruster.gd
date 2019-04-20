extends "res://parts/simple.gd"

export(NodePath) var flame_path = ""
export(NodePath) var sound_path = ""
export(float) var max_thrust = 1200.0

var thrust_request = 0.0


var _actual_thrust = 0.0

func _init():
	type = MODULE_TYPES.THRUSTER


func _ready():
	get_node(sound_path).volume_db = -80
	get_node(sound_path).play()


func apply_thrust(thrust):
	thrust_request += thrust


func set_volume(sample, volume_percent: float):
	var volume_db = (volume_percent - 1.0)*80.0
	sample.volume_db = volume_db

func _process(delta):
	
	# TODO: make time invariant
	if not alive:
		return
	var thrust = clamp(thrust_request, 0.0, 1.0)
	_actual_thrust = lerp(_actual_thrust, thrust, 0.5)
	var thrust_vec = -global_transform.y * _actual_thrust * max_thrust * delta
	var global_position_offset = global_position - get_parent().global_position
	
	set_volume(get_node(sound_path), _actual_thrust * 0.8)
	get_node(sound_path).pitch_scale = (1.5 - _actual_thrust) + randf() * 0.1
	
	get_parent().apply_impulse(global_position_offset, thrust_vec)
	thrust_request = 0.0
	var flame = get_node(flame_path)
	flame.scale.y = _actual_thrust
	flame.get_child(0).frame = int(randf() * 4)
	flame.get_child(0).modulate.a = pow(_actual_thrust, 0.5)