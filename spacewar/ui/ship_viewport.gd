tool
extends ViewportContainer

export (int) var ship_id = 0 setget _set_ship_id
export (ShaderMaterial) var box_material = null


func _ready():
	_update_ship()

	$Viewport/ShipBox.material = box_material.duplicate()

	state.connect_call("player_1.ship_type", self, "_update_border")
	state.connect_call("player_2.ship_type", self, "_update_border")


func _update_ship():
	for child in $Viewport/ShipBox.get_children():
		child.queue_free()

	if ship_id > len(defs.SHIPS)-1 or ship_id < 0:
		return  # Preventative Programming
	var ship = defs.SHIPS[ship_id].instance()
	ship.mode = ship.MODE_STATIC
	ship.ship_color = Color(0,0,0,1)
	$Viewport/ShipBox.add_child(ship)
	_update_border(ship_id)


func _set_ship_id(id):
	ship_id = id
	_update_ship()


func _update_border(_val):
	var is_player_1 = state.get("player_1.ship_type") == ship_id
	var is_player_2 = state.get("player_2.ship_type") == ship_id
	
	var col1 = Color()
	var col2 = Color()
	
	if is_player_1 and not is_player_2:
		col1 = defs.PLAYER_COLORS[0]
		col2 = defs.PLAYER_COLORS[0]
	if is_player_2 and not is_player_1:
		col1 = defs.PLAYER_COLORS[1]
		col2 = defs.PLAYER_COLORS[1]
	if is_player_1 and is_player_2:
		col1 = defs.PLAYER_COLORS[0]
		col2 = defs.PLAYER_COLORS[1]
	
	$Viewport/ShipBox.material.set_shader_param("color1", col1)
	$Viewport/ShipBox.material.set_shader_param("color2", col2)
	