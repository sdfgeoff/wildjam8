extends Node

export (NodePath) var player_1_spawn = ""
export (NodePath) var player_2_spawn = ""


enum MatchState {
	INTRO,
	PLAYING,
	EXIT
}

var match_state = MatchState.INTRO

var ships = [
	null,
	null
]

onready var spawns = [
	get_node(player_1_spawn),
	get_node(player_2_spawn),
]


func _ready():
	spawn_player(0)
	spawn_player(1)
	
	$IntroExitAnimation.play("Start")
	
	$IntroBox/RoundCounter.text = "Round %d of %d" % [state.get("game.current_round")+1, state.get("game.num_rounds")]


func _process(delta):
	if match_state == MatchState.INTRO:
		pass
	elif match_state == MatchState.PLAYING:
		update_player(0)
		update_player(1)
	elif match_state == MatchState.EXIT:
		# Allow the player to dodge
		update_player(0)
		update_player(1)
		
		# Ensure that if one player dies after the other, the
		# end card is updated correctly
		var player_id = 0
		var alive = []
		for ship in ships:
			if ship != null:
				alive.append(player_id)
			player_id += 1

		if len(alive) != 0:
			$RoundScoreBox/WinnerText.text = "Winner Player %d" % [alive[0]+1]
			$RoundScoreBox/WinnerText.modulate = defs.PLAYER_COLORS[alive[0]]
		else:
			$RoundScoreBox/WinnerText.text = "Both Players Died!"
			$RoundScoreBox/WinnerText.modulate = Color(1,1,1,1)


func spawn_player(player_id):
	var player = "player_%d." % (player_id + 1)
	var ship_type_id = state.get(player + "ship_type")
	var ship_base_scene = defs.SHIPS[min(ship_type_id, len(defs.SHIPS) - 1)]
	
	var ship = ship_base_scene.instance()
	ship.ship_color = defs.PLAYER_COLORS[player_id]
	spawns[player_id].add_child(ship)
	ship.global_transform = spawns[player_id].global_transform
	
	ships[player_id] = ship
	ship.connect("on_death", self, "_player_death")


func start_match():
	match_state = MatchState.PLAYING


func _player_death(dying_ship, killer_bullet):
	var dier_id = spawns.find(dying_ship.get_parent())
	assert dier_id != -1  # A ship we didn't know about died, or it died twice
	ships[dier_id] = null
	
	var killer_id = spawns.find(killer_bullet.get_parent())
	print("player ", killer_id+1, " killed player ", dier_id+1)
	
	var killer = "player_%d." % (killer_id + 1)
	var dier = "player_%d." % (dier_id + 1)
	
	var existing_kills = state.get(killer + "kills")
	state.set(killer + "kills", existing_kills + 1)
	var existing_deaths = state.get(dier + "deaths")
	state.set(dier + "deaths", existing_deaths + 1)
	
	check_all_dead()
	
func check_all_dead():
	"""Checks if only one player is alive, if so, begins the "end game" sequence"""
	var count = 0
	var alive = []
	for ship in ships:
		if ship != null:
			count += 1
	if count <= 1:
		match_state = MatchState.EXIT
		$IntroExitAnimation.play("Death")


func _death_animation_finished():
	var current_round = state.get("game.current_round")
	if current_round+1 >= state.get("game.num_rounds"):
		get_tree().change_scene("res://ui/scores.tscn")
	else:
		state.set("game.current_round", current_round+1)
		get_tree().change_scene("res://map.tscn") 
	


func update_player(player_id):
	var player = "player_%d." % (player_id + 1)
	var ship = ships[player_id]
	if ship == null:
		return
	
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
	
