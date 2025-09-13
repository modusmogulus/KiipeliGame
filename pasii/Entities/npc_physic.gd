extends Skeleton3D
@export var simulatorparent : PhysicalBoneSimulator3D

func _ready() -> void:
	simulatorparent.physical_bones_start_simulation()
