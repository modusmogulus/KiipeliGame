extends MeshInstance3D


func _process(delta: float) -> void:
	if CGG.local_player_body:
		global_position = CGG.local_player_body.global_position
