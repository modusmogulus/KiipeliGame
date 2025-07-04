class_name KP_HpHandler extends Node
var hp = 100.0
var maxhp = 100.0
@export var regen = 0.1

func _process(delta: float) -> void:
	hp += regen*delta
	hp = clampf(hp, 0.0, maxhp)
	if hp == 0:
		get_parent().die()

func take_damage(damage : float):
	hp -= damage
