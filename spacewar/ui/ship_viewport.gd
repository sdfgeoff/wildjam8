tool
extends ViewportContainer

export (int) var ship_id = 0 setget _set_ship_id

func _ready():
	_update_ship()

func _update_ship():
	for child in $Viewport/ShipBox.get_children():
		child.queue_free()

	if ship_id > len(defs.SHIPS)-1 or ship_id < 0:
		return  # Preventative Programming
	var ship = defs.SHIPS[ship_id].instance()
	ship.mode = ship.MODE_STATIC
	ship.ship_color = Color(0,0,0,1)
	$Viewport/ShipBox.add_child(ship)


func _set_ship_id(id):
	ship_id = id
	_update_ship()
