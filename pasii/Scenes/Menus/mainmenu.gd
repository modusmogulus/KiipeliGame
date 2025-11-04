extends Node3D
var selected_node : Node
var size_multiplier_on_select : Vector3 = Vector3(1.1, 1.1, 1.1)
@onready var camera = $ykp_corkboard_menu/Camera3D
var original_camera_rotation
func _ready() -> void:
	original_camera_rotation = camera.rotation
	
func _on_static_body_3d_mouse_entered() -> void:
	print("MOUSENTERED")
	selected_node = $StaticBody3D
	selected_node.scale *= size_multiplier_on_select

func _on_static_body_3d_mouse_exited() -> void:
	if selected_node == $StaticBody3D:
		
		selected_node.scale /= size_multiplier_on_select
		selected_node = null
