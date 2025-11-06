class_name KP_HpHandler extends Node
var hp = 100.0
var maxhp = 100.0
var damage_pending = 0.0
@export var godmode = false
@export var regen_per_second = 10.0
@export var hp_hearts : Array[AnimatedSprite2D]
@export var frame_empty_heart : int
@export var frame_healthy_heart : int
@export var frame_damage_pending_heart : int
func _process(delta: float) -> void:
	for i in hp_hearts.size():
		var heart_section = maxhp / hp_hearts.size() * i-1
		if hp < heart_section:
			hp_hearts[i].frame = frame_empty_heart
		else:
			if hp - damage_pending*1.5 < heart_section:
				hp_hearts[i].frame = frame_damage_pending_heart
			else:
				hp_hearts[i].frame = frame_healthy_heart
	hp += regen_per_second*delta
	hp = clampf(hp, 0.0, maxhp)
	if hp == 0 && !godmode:
		get_parent().die()

func take_damage(damage : float):
	hp -= damage
	damage_pending -= damage
	damage_pending = clampf(damage, 0.0, 0.0)

func threaten_with_damage(damage : float):
	damage_pending += damage
	

func remove_damage_threat():
	damage_pending = 0
