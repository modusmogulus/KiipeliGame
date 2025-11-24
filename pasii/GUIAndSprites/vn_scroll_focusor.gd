extends TextureRect

var targetpos = Vector2.ZERO
func _process(delta: float) -> void:
	
	var lastpos = position
	if Input.is_action_just_pressed("choice_up"):
		targetpos.y -= 1
	if Input.is_action_just_pressed("choice_down"):
		targetpos.y += 1

	position = lerp(lastpos, lastpos+targetpos, 0.1)
