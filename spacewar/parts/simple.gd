extends CollisionShape2D

export var health: float = 1.0
export var mass: float = 1.0

export(NodePath) var main_sprite = ""
export(PackedScene) var splash = null
export var _health_max = 0.0

export var alive: bool = true setget _set_alive

var _shape = null

enum MODULE_TYPES {
	SIMPLE,
	THRUSTER,
	PRIMARY,
	SECONDARY,
	CORE,
}

var type = MODULE_TYPES.SIMPLE;

func _ready():
	_health_max = health
	_shape = shape
	get_node(main_sprite).material = get_node(main_sprite).material.duplicate()

func set_color(rgb: Color):
	get_node(main_sprite).material.set_shader_param("color", rgb)
	

func inflict_damage(damage):
	self.health -= damage
	get_node(main_sprite).material.set_shader_param("health", health / _health_max)
	if self.health < 0:
		var splash_instance = splash.instance()
		get_parent().get_parent().add_child(splash_instance)
		splash_instance.global_transform = global_transform
		self.alive = false

func _set_alive(val):
	if val:
		set_shape(_shape)
	else:
		set_shape(null)
	visible = val  # Hide it
	alive = val