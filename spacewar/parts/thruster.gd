extends "res://parts/simple.gd"

export(NodePath) var flame_path = ""
export(float) var max_thrust = 600.0

var thrust_request = 0.0

func _init():
	type = MODULE_TYPES.THRUSTER


func apply_thrust(thrust):
	thrust_request += thrust
	
func _process(delta):
	var thrust = clamp(thrust_request, 0.0, 1.0)
	var thrust_vec = -global_transform.y * thrust * max_thrust * delta
	var global_position_offset = global_position - get_parent().global_position
	
	get_parent().apply_impulse(global_position_offset, thrust_vec)
	thrust_request = 0.0
	get_node(flame_path).scale.y = thrust