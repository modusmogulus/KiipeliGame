@icon("src/gdticon.png")
class_name GoldGdt_View extends Node

@export var Parameters : PlayerParameters
@export var Body : GoldGdt_Body

@export_subgroup("Gimbal")
@export var horizontal_view : Node3D ## Y-axis Camera Mount gimbal.
@export var vertical_view : Node3D ## X-axis Camera Mount gimbal.
@export var camera_mount : Node3D ## Used for player view aesthetics such as view tilt and bobbing.
@export var camera : Camera3D
@export var speedlines : ColorRect
var original_fov : float = 0.0

func _ready() -> void:
	original_fov = camera.fov

func _physics_process(_delta) -> void:
	# Add some view bobbing to the Camera Mount
	_camera_mount_bob()
	
	camera_mount.rotation.z = _calc_roll(Parameters.ROLL_ANGLE, Parameters.ROLL_SPEED)*0.4
	var _ct = camera_mount.rotation.x
	camera_mount.rotation.x = lerpf(_ct, _calc_pitch_overshoot(Parameters.ROLL_ANGLE*0.2, Parameters.ROLL_SPEED*0.1)*2, 0.2)
	#camera_mount.position.z = _calc_pitch_overshoot(0.1, 0.1)
	#if Body.velocity.length() == 0:
	camera.fov = _calc_speed_fov(original_fov, 0.1, 40.0)
	#else:
	#	camera.fov = _calc_speed_fov(camera.fov, 0.0001, 1.0)
	speedlines.modulate.a = _calc_speedlines(0.0, 0.1).w
# Manipulates the Camera Mount gimbals.
func _handle_camera_input(look_input: Vector2) -> void:
	horizontal_view.rotate_object_local(Vector3.DOWN, look_input.x)
	horizontal_view.orthonormalize()
	
	vertical_view.rotate_object_local(Vector3.LEFT, look_input.y)
	vertical_view.orthonormalize()
	
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
	
	return front * roll_sign + clampf(Body.velocity.y * 0.01, -0.5, 0.5)

func _calc_speed_fov(original: float, lerp_weight: float, max_change: float) -> float:
	var fov = original
	
	fov += (Vector2(Body.velocity.x, Body.velocity.z).length() / Parameters.FORWARD_SPEED)
	
	fov = lerpf(camera.fov, fov, lerp_weight)
	return original + clampf(fov, -max_change, max_change)

func _calc_speedlines(original: float, lerp_weight: float) -> Vector4:
	var alpha = 0.0
	alpha += (Vector2(Body.velocity.x, Body.velocity.z).length() / (Parameters.FORWARD_SPEED*0.1))
	alpha = lerpf(original, alpha, lerp_weight)
	return Vector4(1.0, 1.0, 1.0, clampf(alpha, 0.0, 1.0))
