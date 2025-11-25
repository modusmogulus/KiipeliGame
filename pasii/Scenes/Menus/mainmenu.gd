extends Node3D
var selected_node : Node
var size_multiplier_on_select : Vector3 = Vector3(0.3, 0.3, 0.3)
@export var cam : Camera3D
@export var camtarget : Node3D
@export var lerpstep : float = 0.1

var original_cam_rotation : Vector3
var original_cam_position : Vector3
var selectables : Array[Node3D]
var selection_index : int
@export var upvector : Vector3 = Vector3.UP

func _ready() -> void:
	original_cam_rotation = cam.rotation_degrees
	original_cam_position = cam.global_position
	if selected_node == null:
		camtarget.global_rotation = original_cam_rotation
		camtarget.global_position = original_cam_position

func _process(delta: float) -> void:
	#cam.global_position = camtarget.global_position
	#cam.global_rotation = camtarget.global_rotation
	if Input.is_action_just_pressed("choice_up"):
		select_menubutton(selection_index-1)
	if Input.is_action_just_pressed("choice_down"):
		select_menubutton(selection_index+1)
	if Input.is_action_just_pressed("choice_enter"):
		if selectables[selection_index].trigact_on_click != null:
			selectables[selection_index].trigact_on_click.do_shit()
	if !(selected_node == null):
		var _t = lerp(original_cam_position, selected_node.global_position, 0.5)
		camtarget.global_position = lerp(camtarget.position, _t, 0.1)
		camtarget.look_at_from_position(camtarget.global_position, selected_node.global_position, upvector)
		cam.global_position = lerp(cam.global_position, camtarget.global_position, lerpstep)
		cam.global_rotation = cam.global_rotation.slerp(camtarget.global_rotation, lerpstep)
		#camtarget.global_position.y = original_cam_position.y

func deselect_all():
		for stb in selectables:
			stb.deselect_self()

func select_menubutton(index : int):
	deselect_all()
	selection_index = wrap(index, 0, selectables.size())
	#selection_index = index
	selectables[selection_index].select_self()
	
#func _input(event: InputEvent) -> void:
	
