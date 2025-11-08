@icon("src/gdticon.png")
class_name GoldGdt_View extends Node

@export var Parameters : PlayerParameters
@export var Body : GoldGdt_Body

@export_subgroup("Gimbal")
@export var horizontal_view : Node3D ## Y-axis Camera Mount gimbal.
@export var vertical_view : Node3D ## X-axis Camera Mount gimbal.
@export var camera_mount : Node3D ## Used for player view aesthetics such as view tilt and bobbing.
@export var camera_animation_mount : Node3D ##Used to give a layer to rotation that is controlled by the rig animation
@export var camera : Camera3D
@export var animation_camera : Camera3D
@export var g_loc_filter : ColorRect
@export var speedlines : ColorRect
@export var legs : Node
@export var zoneout : ColorRect
@export var g_loc_curve : Curve
@export var afterimage : TextureRect
@export var viewmodel_shader_target_parent : Node3D
@export var adrenaline_effect : ColorRect
@export var wind_sfx_player : AudioStreamPlayer3D
@export var damage_flash_node : Control
@export var pre_damage_flash_node : Control
@export var pre_damage_flash_col_node : Control

var wind_sfx_vol_original : float

var initial_anim_camera_rot : Vector3
var original_fov : float = 0.0
var previous_velocity : Vector3
var _frm = 0
@export var interact_label : Label

func _ready() -> void:
	#initial_anim_camera_rot = animation_camera.global_rotation
	original_fov = camera.fov
	wind_sfx_vol_original = wind_sfx_player.volume_linear
	
func _process(delta: float) -> void:
	if Body.interactables_in_reach.size() > 0:
		interact_label.visible = true
	else:
		interact_label.visible = false
	_frm += 1
	if _frm > 1: #&& Body.g_forces > 0.9:
		var _atimg = get_viewport().get_texture().get_image()
		var _attex = ImageTexture.create_from_image(_atimg)
		afterimage.texture = _attex
		_frm = 0
func _physics_process(_delta) -> void:
	# Add some view bobbing to the Camera Mount
	_camera_mount_bob()
	
	if Body.current_wallrun_state !=  enumsKP.wallrun_states.NONE && Body.current_wallrun_state != enumsKP.wallrun_states.BOTH:
		camera_mount.rotation.z = lerpf(camera_mount.rotation.z, deg_to_rad(Body.current_wallrun_state * 42.0), 0.12)
		
	else:
		camera_mount.rotation.z = lerpf(camera_mount.rotation.z, _calc_roll(Parameters.ROLL_ANGLE*Parameters.ROLL_ANGLE, Parameters.ROLL_SPEED)*1.2, 0.2)
	var _ct = camera_mount.rotation.x
	var _lt = legs.rotation.x
	camera_mount.rotation.x = lerpf(_ct, (_calc_pitch_overshoot(Parameters.ROLL_ANGLE*0.2, Parameters.ROLL_SPEED*0.1)*2), 0.2)
	legs.rotation.x = lerpf(_lt, _calc_pitch_overshoot(Parameters.ROLL_ANGLE*Parameters.ROLL_ANGLE, Parameters.ROLL_SPEED*0.2)*0.1, 0.2)
	var _ft
	_ft = camera.fov
	#speedlines.modulate.a = _calc_speed_fx(0.0, 1.0, 4.0)
	adrenaline_effect.modulate.a = lerpf(adrenaline_effect.modulate.a, _calc_speed_fx(0.0, 1.0, 12.0), 0.1)
	var _currentamount = speedlines.material.get("shader_parameter/blur_power")
	if abs(Body.velocity.length()) > 7.0:
		#speedlines.modulate.a = lerpf(speedlines.modulate.a, 1.0, 0.1)
		speedlines.material.set("shader_parameter/blur_power", lerpf(_currentamount, 0.006, 0.1))
		wind_sfx_player.volume_linear = lerpf(wind_sfx_player.volume_linear, wind_sfx_vol_original, 0.05)
		wind_sfx_player.pitch_scale = lerpf(wind_sfx_player.pitch_scale, 4.0, 0.01)
	else:
		wind_sfx_player.volume_linear = lerpf(wind_sfx_player.volume_linear, 0.0, 0.15)
		wind_sfx_player.pitch_scale = lerpf(wind_sfx_player.pitch_scale, 1.0, 0.1)
		#speedlines.modulate.a = lerpf(speedlines.modulate.a, 0.0, 0.15)
		speedlines.material.set("shader_parameter/blur_power", lerpf(_currentamount, 0.0, 0.1))
	if _ft < camera.fov:
		lerpf(camera.fov, _calc_speed_fov(original_fov, 20.0), 0.8)
	else:
		camera.fov = lerpf(camera.fov, _calc_speed_fov(original_fov, 20.0), 0.1)
	animation_camera.fov = camera.fov
	var grayout = (Body.HpHandler.maxhp - Body.HpHandler.hp) * 1/Body.HpHandler.maxhp
	g_loc_filter.modulate.a = grayout
	if grayout == 0:
		AudioServer.set_bus_effect_enabled(1, 4, false)
		AudioServer.set_bus_effect_enabled(1, 2, false)
	else:
		AudioServer.set_bus_effect_enabled(1, 4, true)
		AudioServer.set_bus_effect_enabled(1, 2, true)
		AudioServer.get_bus_effect(1, 4).dry = 1.0-(grayout*0.5)
		AudioServer.get_bus_effect(1, 4).wet = grayout*0.5
		AudioServer.get_bus_effect(1, 2).cutoff_hz = 20500-(20500*grayout)

	#if g_loc_filter.modulate.a + 0.1 < _calc_g_fx():
		
	#	g_loc_filter.modulate.a = lerpf(g_loc_filter.modulate.a, _calc_g_fx(), 0.1)
	#else:
		
	#	g_loc_filter.modulate.a = lerpf(g_loc_filter.modulate.a, _calc_g_fx(), 0.05)
	previous_velocity = Body.velocity
	if Vector2(Body.velocity.x, Body.velocity.y).length() > 0:
		zoneout.modulate.a = lerpf(zoneout.modulate.a, 1-_calc_speed_fx(0.0, 1.0, 0.01), 0.1) #Speedlines by using same function as fov
	else:
		zoneout.modulate.a = lerpf(zoneout.modulate.a, 1-_calc_speed_fx(0.0, 1.0, 0.01), 0.002) #Lazy way to make braking lose speedlines faster
	#camera_animation_mount.rotation = camera_mount.rotation
	animation_camera.rotation = camera.rotation + Vector3(0.0, deg_to_rad(180), 0.0)
	
	pre_damage_flash_col_node.modulate.a = clampf(pre_damage_flash_col_node.modulate.a * 0.95, 0.0, 1.0)
	damage_flash_node.modulate.a = clampf(damage_flash_node.modulate.a * 0.95, 0.0, 1.0)
	_currentamount = pre_damage_flash_node.material.get("shader_parameter/blur_power")
	pre_damage_flash_node.material.set("shader_parameter/blur_power", clampf(_currentamount*0.95, 0.0, 1.0))
	if _currentamount < 0.001:
		pre_damage_flash_node.visible = false
	else: pre_damage_flash_node.visible = true
	#animation_camera.rotation = camera.rotation + initial_anim_camera_rot
func _handle_camera_input(look_input: Vector2) -> void:
	horizontal_view.rotate_object_local(Vector3.DOWN, look_input.x)
	horizontal_view.orthonormalize()
	
	vertical_view.rotate_object_local(Vector3.LEFT, look_input.y)
	vertical_view.orthonormalize()
	var _ct = camera_mount.rotation.x
	var maxrotx = Parameters.NECK_LIMIT_LOWER + lerpf(_ct, (_calc_pitch_overshoot(Parameters.ROLL_ANGLE*0.2, Parameters.ROLL_SPEED*0.1)*2), 0.2)
	
	vertical_view.rotation.x = clamp(vertical_view.rotation.x, deg_to_rad(Parameters.NECK_LIMIT_LOWER), deg_to_rad(Parameters.NECK_LIMIT_UPPER))
	vertical_view.orthonormalize()
	
# Creates a sinusoidal Camera Mount bobbing motion whilst moving.
func _camera_mount_bob() -> void:
	var bob : float
	var simvel : Vector3
	simvel = Body.velocity
	simvel.y = 0
	
	if Parameters.BOB_FREQUENCY == 0.0 or Parameters.BOB_FRACTION == 0:
		return
	
	if Body.is_on_floor():
		bob = lerp(0.0, sin(Time.get_ticks_msec() * Parameters.BOB_FREQUENCY) / Parameters.BOB_FRACTION, (simvel.length() / 2.0) / Parameters.FORWARD_SPEED)
	else:
		bob = 0.0
	camera_mount.position.y = lerp(camera_mount.position.y, bob, 0.5)

# Returns a value for how much the Camera Mount should tilt to the side.
func _calc_roll(rollangle: float, rollspeed: float) -> float:
	
	if Parameters.ROLL_ANGLE == 0.0 or Parameters.ROLL_SPEED == 0:
		return 0
	
	var side = Body.velocity.dot(horizontal_view.transform.basis.x)
	
	
	var roll_sign = 1.0 if side < 0.0 else -1.0
	
	side = absf(side)
	
	var value = rollangle
	
	if (side < rollspeed):
		side = side * value / rollspeed
	else:
		side = value
	
	return side * roll_sign

func _calc_pitch_overshoot(rollangle: float, rollspeed: float) -> float:
	
	if Parameters.ROLL_ANGLE == 0.0 or Parameters.ROLL_SPEED == 0:
		return 0
	
	var front = -Body.velocity.dot(horizontal_view.transform.basis.z)
	
	var roll_sign = 0.2 if front < 0.0 else -1.0
	
	front = absf(front)
	
	var value = rollangle
	
	if (front < rollspeed):
		front = front * value / rollspeed
	else:
		front = value
	
	return front * roll_sign + clampf(Body.velocity.y * 0.01, -1.5, 1.5)


func _calc_speed_fov(original: float, max_change: float) -> float:
	var fov = (Body.velocity.length() / Parameters.MAX_SPEED*16.0) * max_change
	return original+clampf(fov, 0.0, max_change)

func _calc_speed_fx(original: float, max_change: float, max_speed : float) -> float:
	if Body.velocity.length() > max_speed:
		return 1.0
	var a = (abs(Body.velocity.length()) / max_speed)
	return clampf(a, 0.0, max_change)
	
func _calc_g_fx() -> float:
	var gs = Body.g_forces
	var fx_strength = g_loc_curve.sample_baked(gs)
	return fx_strength

func do_damage_flash_thing(damage : float):
	if damage < 0.1: return
	damage_flash_node.modulate.a = damage
func do_pre_damage_flash_thing(damage : float):
	if damage < 0.1: return
	pre_damage_flash_node.material.set("shader_parameter/blur_power", 0.006)
	pre_damage_flash_col_node.modulate.a = 0.5
