extends Control


func _process(_delta):
	var all_ready = true
	for player_id in range(defs.NUM_PLAYERS):
		var player_is_ready = update_player(player_id)
		all_ready = all_ready and player_is_ready
	
	if all_ready:
		get_tree().change_scene("res://map.tscn")
	

func update_player(player_id):
	var player = "player_%d." % (player_id + 1)
	
	var old_ship_type = state.get(player + "ship_type")
	var old_player_type = state.get(player + "player_type")
	var old_ready_state = state.get(player +"ready")
	
	var new_player_type = old_player_type
	var new_ready_state = old_ready_state
	var new_ship_type = old_ship_type

	if Input.is_action_just_pressed(player + "primary"):
		new_ready_state = !old_ready_state

		if new_player_type != defs.PLAYER_TYPES.HUMAN:
			# If it's an AI becoming ready, pick a ship
			new_ship_type = randi() % len(defs.SHIPS)

	if !new_ready_state:
		# If the player is not ready, things can be changed

		# Select player type
		if Input.is_action_just_pressed(player + "forward"):
			new_player_type -= 1
		if Input.is_action_just_pressed(player + "backward"):
			new_player_type += 1
		if new_player_type < 0:
			new_player_type = defs.PLAYER_TYPES.MAX - 1
		if new_player_type >= defs.PLAYER_TYPES.MAX:
			new_player_type = 0
		if new_player_type != old_player_type:
			# If the player type has changed, mark the player as not ready
			new_ready_state = false


		if new_player_type == defs.PLAYER_TYPES.HUMAN:
			# Player is human so can change the ship:
			var num_ships = len(defs.SHIPS)

			if Input.is_action_just_pressed(player + "left"):
				new_ship_type -= 1
			if Input.is_action_just_pressed(player + "right"):
				new_ship_type += 1

			if new_ship_type < 0:
				new_ship_type = num_ships - 1
			if new_ship_type >= num_ships:
				new_ship_type = 0


	if new_ship_type != old_ship_type:
		state.set(player + "ship_type", new_ship_type)
	if new_ready_state != old_ready_state:
		state.set(player + "ready", new_ready_state)
	if new_player_type != old_player_type:
		state.set(player + "player_type", new_player_type)
	
	return new_ready_state