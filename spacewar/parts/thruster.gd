extends "res://parts/simple.gd"

export(NodePath) var flame_path = ""
export(float) var max_thrust = 1200.0

var thrust_request = 0.0


var _actual_thrust = 0.0

func _init():
	type = MODULE_TYPES.THRUSTER


func apply_thrust(thrust):
	thrust_request += thrust
	
func _process(delta):
	
	# TODO: make time invariant
	if not alive:
		return
	var thrust = clamp(thrust_request, 0.0, 1.0)
	_actual_thrust = lerp(_actual_thrust, thrust, 0.5)
	var thrust_vec = -global_transform.y * _actual_thrust * max_thrust * delta
	var global_position_offset = global_position - get_parent().global_position
	
	get_parent().apply_impulse(global_position_offset, thrust_vec)
	thrust_request = 0.0
	var flame = get_node(flame_path)
	flame.scale.y = _actual_thrust
	flame.get_child(0).frame = int(randf() * 4)
	flame.get_child(0).modulate.a = pow(_actual_thrust, 0.5)