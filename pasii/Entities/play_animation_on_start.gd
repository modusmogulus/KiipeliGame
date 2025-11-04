extends AnimationPlayer
@export var StartAnimationName : StringName

func _ready() -> void:
	current_animation = StartAnimationName
