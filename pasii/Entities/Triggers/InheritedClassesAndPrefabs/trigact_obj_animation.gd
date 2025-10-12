extends "res://Entities/Triggers/trigger_action.gd"
@export var anim_player : AnimationPlayer
@export var animations_to_play_round_robin : Array[StringName]
var animation_index : int = 0
@export var reverse_each_other : bool = false
var reversed = false

func do_shit(body):
	anim_player.play(animations_to_play_round_robin[animation_index])
	if reverse_each_other:
		if anim_player.is_playing():
			reversed = !reversed
			anim_player.speed_scale *= -1
		else:
			
			anim_player.current_animation = animations_to_play_round_robin[0]
			anim_player.play()
			anim_player.speed_scale *= -1
	animation_index += 1
	if animation_index >= animations_to_play_round_robin.size():
		animation_index = 0
		if !anim_player:
			print("BULLSHIT DETECTED: No animation player set in trigger action: animation. Node is " + name)
	if animation_index % 2 == 0:
		pass
