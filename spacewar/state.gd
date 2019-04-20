tool
extends Node
"""This is a combination of "settings" and "game state". There is
a single flat dictionary of name: value, and some of those are
mapped to disk. This provides a way for different parts of the 
game to talk to each other indirectly - particularly for GUI's.

Some parts of this name: value are written to disk as settings"""


# All items of state that are tracked
var _state = {
	"player_1.ship_type": 0,
	"player_1.player_type": 0,
	"player_1.ready": false,
	"player_1.kills": 0,
	"player_1.deaths": 0,
	"player_2.ship_type": 1,
	"player_2.player_type": 0,
	"player_2.ready": false,
	"player_2.kills": 0,
	"player_2.deaths": 0,
	"game.num_rounds": 3,
	"game.current_round": 0,
}

# Elements of state that should be written to disk
var _settings = [
	"player_1.ship_type",
	"player_1.player_type",
	"player_2.ship_type",
	"player_2.player_type",
	"game.num_rounds",
]


func _init():
	for set in _state:
		add_user_signal(set)
	
	for setting in _settings:
		connect(setting, self, "save_settings")
	
	load_settings(false)

	

func get(setting_name: String):
	return _state[setting_name]


func set(setting_name: String, value):
	_state[setting_name] = value
	emit_signal(setting_name, value)


func connect_call(setting_name: String, target: Object, method: String, binds=[ ], flags=0):
	connect(setting_name, target, method, binds, flags)
	var newargs = binds + [get(setting_name)]
	target.callv(method, newargs)


func save_settings(_changed):
	print("Saving Settings")
	var config = ConfigFile.new()
	for setting in _settings:
		config.set_value("settings", setting, get(setting))
	var err = config.save(defs.SETTINGS_FILE)
	if err != OK:
		print("Saving Settings Failed with error: ", err)


func load_settings(allow_emit=true):
	"""Tries to load the settings. If it doesn't manage to, the settings
	will not be loaded"""
	print("Loading Settings")
	var config = ConfigFile.new()
	var err = config.load(defs.SETTINGS_FILE)
	if err == OK: # if not, something went wrong with the file loading
		if config.has_section("settings"):
			for setting in _settings:
				var new_value = config.get_value("settings", setting, get(setting))
				if allow_emit:
					set(setting, new_value)
				else:
					_state[setting] = new_value
		else:
			print("Loading Settings Failed: missing section")
	else:
		print("Loading Settings Failed with error: ", err)