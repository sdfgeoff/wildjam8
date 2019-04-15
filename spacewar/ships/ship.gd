extends RigidBody2D

export(Color) var ship_color = Color(0,0,1)

func _init():
	contact_monitor = true
	contacts_reported = 5
	linear_damp = 0.0
	angular_damp = 0.0

func _ready():
	for module in get_children():
		module.set_color(ship_color)
	connect("body_shape_entered", self, "_on_hit")

func _process(_delta):
	if len(get_cores()) == 0:
		# TODO: explode!
		queue_free()


func add_thrust(thrust, turn):
	for thruster in get_thrusters():
		var locaL_thrust_direction = thruster.transform.y
		var local_thrust_location = thruster.position
		
		var lin = locaL_thrust_direction.dot(Vector2(0,1))
		thruster.apply_thrust(lin * thrust * 5.0)
		
		var thrust_v3 = Vector3(local_thrust_location.x, local_thrust_location.y, 0)
		var ang = thrust_v3.cross(Vector3(locaL_thrust_direction.x, locaL_thrust_direction.y, 0))
		thruster.apply_thrust(ang.z * turn)


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
	


func _integrate_forces(state):
	recalc_mass(state)


func recalc_mass(state):
	var tmp_mass = 0.0
	var center = Vector2()
	for module in get_children():
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
		if module.type == module.MODULE_TYPES.THRUSTER:
			thrusters.append(module)
	return thrusters

func get_primaries():
	var primaries = []
	for module in get_children():
		if module.type == module.MODULE_TYPES.PRIMARY:
			primaries.append(module)
	return primaries

func get_secondaries():
	var secondaries = []
	for module in get_children():
		if module.type == module.MODULE_TYPES.SECONDARY:
			secondaries.append(module)
	return secondaries

func get_cores():
	var cores = []
	for module in get_children():
		if module.type == module.MODULE_TYPES.CORE:
			cores.append(module)
	return cores