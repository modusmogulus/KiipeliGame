extends "res://Entities/Triggers/trigger_action.gd"

var pbody : CharacterBody3D
var inv : KP_InventoryHandler
@export var items : Array[itemdata]
func do_shit(body: Node3D):
	if body.has_method("get_inventory"):
		inv = body.get_inventory()
		for itm in items:
			itm.in_world = false
			inv.add_to_hotbar(itm)
			itm.refresh()
