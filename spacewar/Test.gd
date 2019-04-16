extends Node2D

export (NodePath) var player_ship_1 = ""
export (NodePath) var player_ship_2 = ""

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	update_player_1()
	update_player_2()
	
func update_player_1():
	var player_1_ship = get_node(player_ship_1)
	if player_1_ship == null:
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
	var player_2_ship = get_node(player_ship_2)
	if player_2_ship == null:
		return
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