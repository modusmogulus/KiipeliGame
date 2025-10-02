extends Node3D

var actions: Array[TriggerAction]

func scan_action_nodes():
	for child in get_children():
		if child == TriggerAction:
			actions.append(child)

func execute_actions(body: Node3D):
	for action in actions:
		action.do_shit(body)
func _on_trig_area_body_entered(body: Node3D) -> void:
	if "Player" in body.get_groups():
		execute_actions(body)

func _on_trig_area_body_exited(body: Node3D) -> void:
	if "Player" in body.get_groups():
		print("TRIGGER EXITED")
