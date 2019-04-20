extends Node

func play_sound_effect(sound, volume_percent=1.0, pitch_percent=1.0):
	var blip_player := AudioStreamPlayer.new()
	blip_player.stream = sound
	blip_player.pitch_scale = pitch_percent
	blip_player.volume_db = (volume_percent - 1.0)*80.0  # Not accurate, but whatever
	get_tree().get_root().add_child(blip_player)
	blip_player.play()
	blip_player.connect("finished", blip_player, "queue_free")