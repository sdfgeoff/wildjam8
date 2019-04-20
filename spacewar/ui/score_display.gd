tool
extends TextureRect


export(String) var state_entry = ""

func _ready():
	material = material.duplicate()


func _process(_delta):
	
	if state_entry != "":
		material.set_shader_param("score", int(
			state.get(state_entry)
		))