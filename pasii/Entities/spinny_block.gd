class_name Spinblock
extends Node3D
@export var rotate_per_second_local : Vector3
@export var spinning : bool = true
func _physics_process(delta: float) -> void:
	if spinning: rotation += rotate_per_second_local * delta
