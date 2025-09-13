extends PhysicalBone3D
@export var target_node : ShapeCast3D
@export var secondary_target_node : ShapeCast3D
@export var strength : float = 2.0

func _physics_process(delta: float) -> void:
	
	var contactpoint = target_node.get_collision_point(0)
	if target_node.get_collision_count() > 0 && !is_zero_approx((contactpoint - global_position).length()):
		angular_velocity = Vector3((contactpoint - global_position)*0.1).normalized() * strength*10
		#angular_velocity += linear_velocity * 0.1
	else:
		if secondary_target_node:
			if secondary_target_node.get_collision_count() > 0:
				contactpoint = secondary_target_node.get_collision_point(0)
				#apply_central_impulse((contactpoint - global_position).normalized() * strength)
