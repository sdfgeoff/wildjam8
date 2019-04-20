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

var controllers = [
	null,
	null
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
		update_controllers()
	elif match_state == MatchState.EXIT:
		# Allow the player to dodge
		update_controllers()
		
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
	var player_type_id = state.get(player + "player_type")
	var ship_base_scene = defs.SHIPS[min(ship_type_id, len(defs.SHIPS) - 1)]
	
	var ship = ship_base_scene.instance()
	ship.ship_color = defs.PLAYER_COLORS[player_id]
	spawns[player_id].add_child(ship)
	ship.global_transform = spawns[player_id].global_transform
	
	ships[player_id] = ship
	ship.connect("on_death", self, "_player_death")
	
	if player_type_id == defs.PLAYER_TYPES.HUMAN:
		controllers[player_id] = PlayerController.new(player_id)
	else:
		controllers[player_id] = AIController.new(player_type_id)

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
	
func update_controllers():
	for player_id in range(len(ships)):
		var ship = ships[player_id]
		if ship == null:
			continue
			
		var controller = controllers[player_id]
		controller.update(ship, ships)



func play_low_buzz():
	utils.play_sound_effect(preload("res://sounds/bluzz1.wav"))

func play_high_buzz():
	utils.play_sound_effect(preload("res://sounds/bluzz2.wav"))



class PlayerController extends Node:
	var player_id = 0
	func _init(id):
		player_id = id

	func update(ship, other_ships):
		var player = "player_%d." % (player_id + 1)
		
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


class AIController extends Node:
	var difficulty_percent = 0
	func _init(diff):
		if diff == defs.PLAYER_TYPES.AI_EASY:
			difficulty_percent = 0.2
		if diff == defs.PLAYER_TYPES.AI_MED:
			difficulty_percent = 0.6
		if diff == defs.PLAYER_TYPES.AI_HARD:
			difficulty_percent = 1.0

	func update(ship, other_ships):
		var target_ship = null
		for o_ship in other_ships:
			if o_ship != ship:
				target_ship = o_ship
		

		if target_ship == null:
			request_velocity(ship, Vector2(0,0), 0.0)
			return
		
		var times = []
		
		var num_samples = difficulty_percent * 20
		for i in range(num_samples):
			times.append(i / num_samples * 10.0)  # up to 10 seconds in the future

		
		var intercepts = []  # Array of [position, quality]
		for i in range(len(times)):
			var time = times[i]
			var future_position = predict_position(target_ship, time)
			var vec_to_intercept = (future_position - ship.global_transform.origin)
			
			var bullet_travel_distance = 2000.0 * time # 2000 = bullet speed
			var bullet_position = ship.global_transform.origin + bullet_travel_distance * vec_to_intercept.normalized()
			var angle = abs(vec_to_intercept.angle_to(ship.global_transform.y))
			var quality = (bullet_position - future_position).length() / 10000.0 * angle
			#quality += pow(time, 2.0)  # Prioritize ones closer in time
			#print("T: ", time, " Q: ", quality)
			intercepts.append([quality, future_position, time])
		
		intercepts.sort_custom(self, "sort_quality")
		#print(times)
		var intercept = intercepts[0]
		var intercept_position = intercept[1]
		var intercept_quality = intercept[0]  # Lower is better
		#print(intercept_quality)
		var turn = calc_turn_to_point_at(ship, intercept_position)
		
		var motion = Vector2(0, (ship.global_transform.origin - intercept_position).length() - 1000.0)
		
		ship.request_motion(motion, turn)
		
		if intercept_quality < 0.02:
			ship.activate_primary()
	
	func sort_quality(a, b):
		return a[0] < b[0]
	
	func predict_position(target_ship, future_time):
		var target_velocity = target_ship.linear_velocity
		var target_probable_acceleration = target_ship.global_transform.y * 0.2  # Assuming uses throttle 20% of the time
		
		return target_ship.global_transform.origin + target_velocity * future_time + target_probable_acceleration * pow(future_time, 2.0)
	
	func request_velocity(ship, velocity: Vector2, turn: float):
		"""Tries to apply a velocity to a ship"""
		ship.request_motion(
			velocity * 1000.0 - ship.global_transform.basis_xform_inv(ship.linear_velocity) / 50.0,
			turn - ship.angular_velocity * 2.0
		)
	
	func calc_turn_to_point_at(ship: RigidBody2D, position):
		"""Tries to point the ship at a specific point in space"""
		var vec_to_target: Vector2 = position - ship.global_transform.origin
		var current_vec: Vector2 = ship.global_transform.y

		var ang_difference = current_vec.angle_to(vec_to_target)
		var current_ang_vel = ship.angular_velocity  # Radians per second (I hope)
		
		var time_to_target = 999.0
		if current_ang_vel != 0:
			time_to_target = ang_difference / current_ang_vel
		if time_to_target < 0:
			time_to_target = -2 * time_to_target
		time_to_target *= sign(ang_difference)
		var deceleration_time = current_ang_vel * 2.0 # Should use inertia and torque in here

		var delta = (time_to_target - deceleration_time)
		return pow(delta, 3.0)

