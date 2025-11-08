extends Area3D
var sampled_velocity : Vector3
var flip : bool = false
var pos_sample1 : Vector3 = Vector3.ZERO
var pos_sample2 : Vector3 = Vector3.ZERO
var bodies_aboard : Array[Node3D]
func _physics_process(delta: float) -> void:
	flip = !flip
	if flip:
		pos_sample1 = global_position
	else:
		pos_sample2 = global_position
	
	var posdelta = pos_sample1-pos_sample2
	sampled_velocity = -100*posdelta*posdelta
	for bd in bodies_aboard:
		bd.external_velocity = sampled_velocity
func _on_body_entered(body: Node3D) -> void:
	if "Player" in body.get_groups():
		bodies_aboard.append(body)
		#body.external_velocity += sampled_velocity
		

func _on_body_exited(body: Node3D) -> void:
	if "Player" in body.get_groups():
		body.external_velocity *= 0.0
		bodies_aboard.pop_back()
