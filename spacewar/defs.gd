tool
extends Node
"""This file defines game-wide constants. Nothing in here changes during a
play-through."""

const NUM_PLAYERS = 2

const PLAYER_COLORS = [
	Color(0,1,0,1),
	Color(0.0,0.2,1,1),
]

const SETTINGS_FILE = "user://settings.conf"

const SHIPS = [
	preload("res://ships/ship1.tscn"),
	preload("res://ships/ship2.tscn"),
]

enum PLAYER_TYPES {
	HUMAN = 0
	AI_EASY = 1
	AI_MED = 2
	AI_HARD = 3
	MAX = 4
}