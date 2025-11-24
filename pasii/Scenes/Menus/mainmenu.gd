extends Node3D
var selected_node : Node
var size_multiplier_on_select : Vector3 = Vector3(1.1, 1.1, 1.1)
@export var cam : Camera3D
@export var camtarget : Node3D
var original_cam_rotation : Vector3
var original_cam_position : Vector3
var selectables : Array[Node3D]
var selection_index : int

func _ready() -> void:
	original_cam_rotation = cam.rotation_degrees
	original_cam_position = cam.global_position

	if selected_node == null:
		camtarget.global_rotation = original_cam_rotation
		camtarget.global_position = original_cam_position

func _process(delta: float) -> void:
	cam.global_position = camtarget.global_position
	if !(selected_node == null):
		var _t = lerp(original_cam_position, selected_node.global_position, 0.5)
		camtarget.global_position = lerp(camtarget.position, _t, 0.1)
func select_menubutton(index : int):
	for stb in selectables:
		if selectables.find(stb) != index:
			stb.deselect_self()
	selection_index = wrap(index, -1, selectables.size())
	#selection_index = index
	selectables[selection_index].select_self()
	
func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("choice_up"):
		select_menubutton(selection_index+1)
		
	if Input.is_action_just_pressed("choice_down"):
		select_menubutton(selection_index-1)
	
