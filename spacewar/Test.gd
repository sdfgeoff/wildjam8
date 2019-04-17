extends Node2D

export (NodePath) var player_1_spawn = ""
export (NodePath) var player_2_spawn = ""


var player_1_ship = null
var player_2_ship = null
# Called when the node enters the scene tree for the first time.
func _ready():
	
	var player_1_ship_base_id = state.get("player_1_ship_type")
	var player_1_ship_base = defs.SHIPS[min(player_1_ship_base_id, len(defs.SHIPS) - 1)]
	var player_2_ship_base_id = state.get("player_2_ship_type")
	var player_2_ship_base = defs.SHIPS[min(player_2_ship_base_id, len(defs.SHIPS) - 1)]
	
	player_1_ship = player_1_ship_base.instance()
	player_1_ship.ship_color = defs.PLAYER_1_COLOR
	get_node(player_1_spawn).add_child(player_1_ship)
	player_1_ship.global_transform = get_node(player_1_spawn).global_transform
	
	player_2_ship = player_2_ship_base.instance()
	player_2_ship.ship_color = defs.PLAYER_2_COLOR
	get_node(player_2_spawn).add_child(player_2_ship)
	player_2_ship.global_transform = get_node(player_2_spawn).global_transform
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if is_instance_valid(player_1_ship):
		update_player_1()
	
	if is_instance_valid(player_2_ship):
		update_player_2()
	
func update_player_1():
	if !is_instance_valid(player_1_ship):
		return
	var thrust = 0.0
	var turn = 0.0
	if Input.is_action_pressed("p1_forward"):
		thrust += 1.0
	if Input.is_action_pressed("p1_backward"):
		thrust -= 1.0
	if Input.is_action_pressed("p1_left"):
		turn -= 1.0
	if Input.is_action_pressed("p1_right"):
		turn += 1.0
	
	player_1_ship.request_motion(Vector2(0,thrust), turn)
	
	if Input.is_action_pressed("p1_primary"):
		player_1_ship.activate_primary()
	if Input.is_action_pressed("p1_secondary"):
		player_1_ship.activate_secondary()


func update_player_2():
	var thrust = 0.0
	var turn = 0.0
	if Input.is_action_pressed("p2_forward"):
		thrust += 1.0
	if Input.is_action_pressed("p2_backward"):
		thrust -= 1.0
	if Input.is_action_pressed("p2_left"):
		turn -= 1.0
	if Input.is_action_pressed("p2_right"):
		turn += 1.0
	
	player_2_ship.request_motion(Vector2(0,thrust), turn)
	
	if Input.is_action_pressed("p2_primary"):
		player_2_ship.activate_primary()
	if Input.is_action_pressed("p2_secondary"):
		player_2_ship.activate_secondary()