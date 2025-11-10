extends "res://Entities/Triggers/trigger_action.gd"
@export_range(0.0, 101.0) var damage = 101
@export var DPS : float = 0.0
@export var SlowDPSTowardsEnd : float = 0.0
var pbody : Node3D
func do_shit(body: Node3D):
	body.damage(damage)
	pbody = body
	
func _process(delta: float) -> void:
	if DPS != 0.0:
		if pbody == null: return
		pbody.damage(lerpf(DPS*delta, (DPS*delta)*(pbody.HpHandler.hp/pbody.HpHandler.maxhp), SlowDPSTowardsEnd))
