extends "res://warpbody.gd"

export(Color) var ship_color = Color(0,0,1)
export(PackedScene) var explosion = preload("res://fx/ship_splash.tscn")
var _velocity_request := Vector3()

signal on_death(dying_ship, killer_bullet)

func _init():
	contact_monitor = true
	contacts_reported = 5
	linear_damp = 0.1
	angular_damp = 0.1


func _ready():
	for module in get_children():
		module.set_color(ship_color)
	connect("body_shape_entered", self, "_on_hit")


func _process(_delta):
	add_thrust(
		Vector2(_velocity_request.x, _velocity_request.y),# * 1000.0 - global_transform.basis_xform_inv(linear_velocity) / 50.0,
		_velocity_request.z * 100# - angular_velocity * 5.0
	)


func request_motion(velocity: Vector2, turn: float):
	_velocity_request = Vector3(velocity.x, velocity.y, turn)


func add_thrust(thrust: Vector2, turn: float):
	for thruster in get_thrusters():
		var locaL_thrust_direction = -thruster.transform.y
		var local_thrust_location = thruster.position
		
		var lin_y = locaL_thrust_direction.dot(Vector2(0,1)) * thrust.y
		var lin_x = locaL_thrust_direction.dot(Vector2(1,0)) * thrust.x
		
		thruster.apply_thrust(lin_y + lin_x)
		
		var thrust_v3 = Vector3(local_thrust_location.x, local_thrust_location.y, 0)
		var ang = thrust_v3.cross(Vector3(locaL_thrust_direction.x, locaL_thrust_direction.y, 0))
		thruster.apply_thrust(ang.z * turn / 5.0)


func activate_primary():
	for primary in get_primaries():
		primary.set_active()

func activate_secondary():
	for secondary in get_secondaries():
		secondary.set_active()


func _on_hit(_body_id, body, _body_shape, local_shape):
	if body.has_method("get_damage"):
		var hit_shape = shape_find_owner(local_shape)
		var hit_module = shape_owner_get_owner(hit_shape)
		hit_module.inflict_damage(body.get_damage())
		
		if len(get_cores()) == 0:
			var new_explosion = explosion.instance()
			get_parent().add_child(new_explosion)
			new_explosion.global_transform = global_transform
			emit_signal("on_death", self, body)  # Notify the world this node is about to become invalid
			queue_free()
	


func _integrate_forces(state):
	recalc_mass(state)


func recalc_mass(state):
	var tmp_mass = 0.0
	var center = Vector2()
	for module in get_children():
		if module.alive:
			tmp_mass += module.mass
			center += module.position * module.mass
	mass = tmp_mass
	if mass == 0: 
		# No modules left - abort
		return
		
	center /= tmp_mass  # Where the center should be in current local space
	if center.length_squared() < 0.1:
		# No point changing if it's so close
		return

	var global_center_delta = transform.basis_xform(center)  # Where teh center should be in current global space

	for module in get_children():
		module.position -= center
	state.transform.origin += global_center_delta





func get_thrusters():
	var thrusters = []
	for module in get_children():
		if module.type == module.MODULE_TYPES.THRUSTER and module.alive:
			thrusters.append(module)
	return thrusters

func get_primaries():
	var primaries = []
	for module in get_children():
		if module.type == module.MODULE_TYPES.PRIMARY and module.alive:
			primaries.append(module)
	return primaries

func get_secondaries():
	var secondaries = []
	for module in get_children():
		if module.type == module.MODULE_TYPES.SECONDARY and module.alive:
			secondaries.append(module)
	return secondaries

func get_cores():
	var cores = []
	for module in get_children():
		if module.type == module.MODULE_TYPES.CORE and module.alive:
			cores.append(module)
	return cores