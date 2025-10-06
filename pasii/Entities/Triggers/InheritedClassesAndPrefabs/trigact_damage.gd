extends "res://Entities/Triggers/trigger_action.gd"
@export_range(0.0, 101.0) var damage = 101
func do_shit(body: Node3D):
	body.damage(damage)
