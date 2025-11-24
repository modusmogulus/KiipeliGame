extends Node3D
#Autoload name is CGG

var local_player_pawn : GoldGdt_Pawn
var local_player_body : GoldGdt_Body
var cutscene_cameras : Array[Camera3D]
var cutscene_name : String = ""
var main_camera : Camera3D
var start_pos_contenders : Array[StartPos]

func _ready() -> void:
		# disabling vsync reduces input lag
	if DisplayServer.window_get_vsync_mode() == DisplayServer.VSYNC_DISABLED:
		var refreshRate := DisplayServer.screen_get_refresh_rate()
		Engine.max_fps = int(refreshRate) if refreshRate > 0.0 else 60

	if Engine.has_singleton("ImGuiAPI"):
		var ImGui: Object = Engine.get_singleton("ImGuiAPI")
		var io: Object = ImGui.GetIO()
		io.ConfigFlags |= ImGui.ConfigFlags_ViewportsEnable

func start_camera_cutscene(cutscene_name : String):
	for cutcam in cutscene_cameras:
		cutcam.check_name_and_play(cutscene_name)

func stop_camera_cutscene(cutscene_name : String):
	for cutcam in cutscene_cameras:
		cutcam.check_name_and_stop(cutscene_name)

func  _enter_tree() -> void:
	cutscene_cameras = []
	main_camera = null
