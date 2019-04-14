extends CollisionShape2D

export var health: float = 1.0
export var mass: float = 1.0

export(NodePath) var main_sprite = ""

enum MODULE_TYPES {
	SIMPLE,
	GUN,
	THRUSTER,
}

var type = MODULE_TYPES.SIMPLE;

func set_color(rgb: Color):
	get_node(main_sprite).material.set_shader_param("color", rgb)