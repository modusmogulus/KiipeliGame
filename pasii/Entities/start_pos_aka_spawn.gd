class_name StartPos extends Node3D

@export_group("On Ready")
@export_range(-89, 89) var start_view_pitch : float = 0 ## How the vertical view of the pawn should be rotated on ready. The default value is 0.
@export var start_view_yaw : float = 0 ## How the horizontal view of the pawn should be rotated on ready. The default values is 0.

##CONTROL THE START POS PRIORITY FROM INSPECTOR->NODE->PROCESS->PRIORITY
##HIGHEST PRIORITY START POS GETS USED

func _ready() -> void:
	CGG.start_pos_contenders.append(self)
	CGG.local_player_pawn._override_view_rotation(Vector2(deg_to_rad(start_view_yaw), deg_to_rad(start_view_pitch)))
	
