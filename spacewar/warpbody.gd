"""Warps a rigidbody2d across the map when it hits the edge"""
extends RigidBody2D

const WARP_DISTANCE = 1800

var warp_count = 0

signal on_warp(warp_count)

func _process(delta):
	var radius = global_transform.origin.length()
	if radius > WARP_DISTANCE:
		var direction = global_transform.origin.normalized()
		global_transform.origin = -direction * WARP_DISTANCE * 0.95
		warp_count += 1
		emit_signal("on_warp", warp_count)