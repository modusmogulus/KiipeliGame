class_name CutsceneCamera extends Camera3D

@export var optional_animation_player : AnimationPlayer
@export var optional_animation_name : StringName
@export var my_cutscene_name : String = ""

func _ready() -> void:
	CGG.cutscene_cameras.append(self)
	
func check_name_and_play(req_cutscene_name : String):
	if req_cutscene_name == my_cutscene_name:
		make_current()
		CGG.main_camera.current = false
		if optional_animation_player:
			optional_animation_player.play(optional_animation_name)
	
func check_name_and_stop(req_cutscene_name : String):
	if req_cutscene_name == my_cutscene_name:
		CGG.main_camera.make_current()
		current = false
