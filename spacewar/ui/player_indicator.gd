tool
extends HBoxContainer

export(int) var player_id = 0 setget _change_playerid
export(ShaderMaterial) var indicator_material = null


# Called when the node enters the scene tree for the first time.
func _ready():
	for type in $Type.get_children():
		type.material = indicator_material.duplicate()
	$Ready.material = indicator_material.duplicate()
	
	# Ensure connections are set up and things are redrawn
	_change_playerid(player_id)

func _change_playerid(newval):
	var old_id_str = "player_%d." % (player_id+1)
	if state.is_connected(old_id_str + "player_type", self, "_change_type"):
		state.disconnect(old_id_str + "player_type", self, "_change_type")
	if state.is_connected(old_id_str + "ready", self, "_change_ready"):
		state.disconnect(old_id_str + "ready", self, "_change_ready")
		
	player_id = newval
	var new_id_str = "player_%d." % (player_id+1)
	state.connect_call(new_id_str + "player_type", self, "_change_type")
	state.connect_call(new_id_str + "ready", self, "_change_ready")

func _change_type(_newtype):
	redraw()

func _change_ready(_is_ready):
	redraw()

func redraw():
	var str_id = "player_%d." % (player_id+1)
	var player_type = state.get(str_id + "player_type")
	var player_ready = state.get(str_id + "ready")
	
	var id = 0
	for child in $Type.get_children():
		if id == player_type:
			child.material.set_shader_param("color", defs.PLAYER_COLORS[player_id])
		else:
			child.material.set_shader_param("color", Color(0,0,0,0))
		id += 1

	if player_ready:
		$Ready.material.set_shader_param("color", defs.PLAYER_COLORS[player_id])
	else:
		$Ready.material.set_shader_param("color", Color(0,0,0,0))