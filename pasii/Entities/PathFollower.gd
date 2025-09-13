extends PathFollow3D
@export var speed : float

func _physics_process(delta: float) -> void:
	if progress_ratio < 1.0:
		progress_ratio += speed * delta
	else:
		progress_ratio = 0.0
