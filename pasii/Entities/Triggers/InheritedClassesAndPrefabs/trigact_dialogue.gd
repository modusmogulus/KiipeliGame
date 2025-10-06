extends "res://Entities/Triggers/trigger_action.gd"
@export var timeline_name : String = 'tmln_'

func do_shit(body: Node3D):
	if Dialogic.current_timeline != null:
		return
	Dialogic.start(timeline_name)
	get_viewport().set_input_as_handled()
