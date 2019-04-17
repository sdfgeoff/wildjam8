extends Node
"""This file defines game-wide constants. Nothing in here changes during a
play-through."""

const PLAYER_1_COLOR = Color(0,1,0,1)
const PLAYER_2_COLOR = Color(0,0,1,1)

const SETTINGS_FILE = "user://settings.conf"

const SHIPS = [
	preload("res://ships/ship1.tscn"),
	preload("res://ships/ship2.tscn"),
]

