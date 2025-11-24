class_name StartPos extends Node3D
#@export var start_view_pitch : float = 0.0
#@export var start_view_yaw : float = 0.0

##CONTROL THE START POS PRIORITY FROM INSPECTOR->NODE->PROCESS->PRIORITY
##HIGHEST PRIORITY START POS GETS USED

func _ready() -> void:
	CGG.start_pos_contenders.append(self)
