extends "res://Entities/Triggers/trigger_action.gd"
@export var spinblocks : Array[Spinblock]

func do_shit(body):
	for spinny in spinblocks:
		spinny.spinning = true
