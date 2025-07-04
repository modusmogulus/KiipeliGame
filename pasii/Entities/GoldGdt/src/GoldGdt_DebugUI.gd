extends Control

@export_group("Player Components")
@export var Controls : GoldGdt_Controls
@export var View : GoldGdt_View
@export var Body : GoldGdt_Body
@export var InventoryHandler : KP_InventoryHandler
@export var HpHandler : KP_HpHandler

@export_group("Component Info Labels")
@export var GameInfo : Label
@export var ControlsInfo : Label
@export var ViewInfo : Label
@export var BodyInfo : Label
@export var InvInfo : Label
@export var FootstepPlayer : Node
@export var FootstepInfo : Label

var plot_velocity : Array[float]

var wc_topmost: ImGuiWindowClassPtr

func _process(delta):

	if Input.is_action_just_pressed("kp_f3"):
		visible = !visible
	if !visible:
		return
	wc_topmost = ImGuiWindowClassPtr.new()
	wc_topmost.ViewportFlagsOverrideSet = ImGui.ViewportFlags_TopMost | ImGui.ViewportFlags_NoAutoMerge
	ImGui.Begin("Kiipeli F3 Menu")
	
	_write_game_ui()
	_write_input_ui()
	_write_view_ui()
	_write_body_ui()
	_write_health_ui()
	_write_inv_ui()
	_write_audio_info()
	ImGui.End()
	
func _write_audio_info():
	if FootstepPlayer.standing_on:
		FootstepInfo.text = FootstepPlayer.current_sound_tex.ingame_name
func _write_game_ui():
	var format = "Rendering FPS: %s\nPhysics Tick Rate: %s\nPhysics Frame Time: %s"
	var str = format % [Engine.get_frames_per_second(), Engine.physics_ticks_per_second, get_physics_process_delta_time()]
	GameInfo.text = str
	
	ImGui.Text(str)
	pass
	
func _write_input_ui():
	var format = "Movement Input: %s\nWish Direction: %s\nWish Speed: %s m/s (%s u/s)\nJump Pressed: %s\nDuck Pressed: %s"
	var str = format % [Controls.movement_input, Controls.move_dir.normalized(), round(Controls.move_dir.length()), round(Controls.move_dir.length() * 39.37), Controls.jump_on, Controls.duck_on]
	ControlsInfo.text = str
	ImGui.Text(str)
	pass
	
func _write_view_ui():
	var format = "View Angles: %s\nView Offset: %s"
	var str = format % [View.camera_mount.global_rotation_degrees, Body.offset]
	ViewInfo.text = str
	ImGui.Text(str)
	pass
	
func _write_health_ui():
	ImGui.Text(str(HpHandler.hp))

func _write_body_ui():
	var format = "Position: %s\nVelocity: %s\nSpeed: %s km/h (%s u/s)\n G-Forces: %s\n Ducking: %s\nDucked: %s"
	var h_vel = Vector2(Body.velocity.x, Body.velocity.z)
	var str = format % [Body.global_position, Body.velocity*3.6, round(h_vel.length()), round(h_vel.length() * 39.37), Body.g_forces, Body.ducking, Body.ducked]
	BodyInfo.text = str
	
	ImGui.Text(str)
	plot_velocity.append(h_vel.length())
	
	if plot_velocity.size() >= 512:
		plot_velocity.pop_front()
	
	ImGui.PlotHistogram("Velocity", plot_velocity, plot_velocity.size())
	pass

func _write_inv_ui():
	var format = "Hotbar: %s\n Current hotbar index: %s\n Holding: %s"
	var str = format % [InventoryHandler.hotbar, InventoryHandler.current_hotbar_index, enumsKP.items.find_key(InventoryHandler.currently_holding)]
	InvInfo.text = str
	ImGui.Text(str)
