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
@export var speedlines : ColorRect
@export var legs : Node
@export var zoneout : ColorRect
@export var g_loc_curve : Curve
@export var afterimage : TextureRect

var original_fov : float = 0.0
var previous_velocity : Vector3
var _frm = 0
func _ready() -> void:
	original_fov = camera.fov
func _process(delta: float) -> void:
	_frm += 1
	if _frm > 30:
		var _atimg = get_viewport().get_texture().get_image()
		var _attex = ImageTexture.create_from_image(_atimg)
		afterimage.texture = _attex
		_frm = 0
func _physics_process(_delta) -> void:
	# Add some view bobbing to the Camera Mount
	_camera_mount_bob()
	
	camera_mount.rotation.z = lerpf(camera_mount.rotation.z, _calc_roll(Parameters.ROLL_ANGLE*Parameters.ROLL_ANGLE, Parameters.ROLL_SPEED)*1.2, 0.2)
	var _ct = camera_mount.rotation.x
	var _lt = legs.rotation.x
	camera_mount.rotation.x = lerpf(_ct, (_calc_pitch_overshoot(Parameters.ROLL_ANGLE*0.2, Parameters.ROLL_SPEED*0.1)*2), 0.2)
	#legs.rotation.x = lerpf(_lt, _calc_pitch_overshoot(Parameters.ROLL_ANGLE*Parameters.ROLL_ANGLE, Parameters.ROLL_SPEED*0.2)*0.1, 0.2)
	
	camera.fov = lerpf(camera.fov, _calc_speed_fx(original_fov, 20.0), 0.1)
	if speedlines.modulate.a + 0.1 < _calc_g_fx():
		
		speedlines.modulate.a = lerpf(speedlines.modulate.a, _calc_g_fx(), 0.1)
	else:
		#if randi_range(0, 10) > 5:
		speedlines.modulate.a = lerpf(speedlines.modulate.a, _calc_g_fx(), 0.05)
	previous_velocity = Body.velocity
	if Vector2(Body.velocity.x, Body.velocity.y).length() > 0:
		zoneout.modulate.a = lerpf(zoneout.modulate.a, 1-_calc_speed_fx(0.0, 1.0), 0.02) #Speedlines by using same function as fov
	else:
		zoneout.modulate.a = lerpf(zoneout.modulate.a, 1-_calc_speed_fx(0.0, 1.0), 0.002) #Lazy way to make braking lose speedlines faster
		
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


func _calc_speed_fx(original: float, max_change: float) -> float:
	var fov = (Body.velocity.length() / Parameters.MAX_SPEED*16.0) * max_change
	return original+clampf(fov, 0.0, max_change)

func _calc_g_fx() -> float:
	var gs = Body.g_forces
	var fx_strength = g_loc_curve.sample_baked(gs)
	return fx_strength
