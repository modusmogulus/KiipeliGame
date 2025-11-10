extends "res://Entities/Triggers/trigger_action.gd"

var pbody : CharacterBody3D
func do_shit(body: Node3D):
	pbody = body
	pbody.velocity.y += 4.0
	pbody.motion_mode = CharacterBody3D.MOTION_MODE_FLOATING
	
