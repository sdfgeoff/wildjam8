extends Node2D

export (NodePath) var player_1_spawn = ""
export (NodePath) var player_2_spawn = ""


var ships = [
	null,
	null
]

onready var spawns = [
	get_node(player_1_spawn),
	get_node(player_2_spawn),
]

var player_1_ship = null
var player_2_ship = null


func _ready():
	spawn_player(0)
	spawn_player(1)


func _process(delta):
	update_player(0)
	update_player(1)


func spawn_player(player_id):
	var player = "player_%d." % (player_id + 1)
	var ship_type_id = state.get(player + "ship_type")
	var ship_base_scene = defs.SHIPS[min(ship_type_id, len(defs.SHIPS) - 1)]
	
	var ship = ship_base_scene.instance()
	ship.ship_color = defs.PLAYER_COLORS[player_id]
	spawns[player_id].add_child(ship)
	ship.global_transform = spawns[player_id].global_transform
	
	ships[player_id] = ship

func update_player(player_id):
	var player = "player_%d." % (player_id + 1)
	var ship = ships[player_id]
	
	var thrust = 0.0
	var turn = 0.0
	if Input.is_action_pressed(player + "forward"):
		thrust += 1.0
	if Input.is_action_pressed(player + "backward"):
		thrust -= 1.0
	if Input.is_action_pressed(player + "left"):
		turn -= 1.0
	if Input.is_action_pressed(player + "right"):
		turn += 1.0
	
	ship.request_motion(Vector2(0,thrust), turn)
	
	if Input.is_action_pressed(player + "primary"):
		ship.activate_primary()
	if Input.is_action_pressed(player + "secondary"):
		ship.activate_secondary()