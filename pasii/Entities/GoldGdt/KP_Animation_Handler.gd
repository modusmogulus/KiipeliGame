
class_name KiipeliAnimHandler extends Node

#AnimationTree's advance_expression_base_node needs to point
#to a node that has this script 
var is_moving: bool = false
var is_grounded: bool = true
var player_velocity: Vector3 = Vector3.ZERO
var reloading: bool = false
var item = ""
var current_animation_node: String

@export var InvHandler : KP_InventoryHandler
@export var SyncedAnimTrees : Array[AnimationTree]
var state_machines : Array[AnimationNodeStateMachinePlayback]
@export var AnimPlayer : AnimationPlayer

@export var Dense: Node
@export var Phone: Node
@export var AnimationSound: AudioStreamPlayer3D

@export var PaahdinReloadSound: AudioStream
@export var PhoneReloadSound: AudioStream

@export var item_link: Dictionary[enumsKP.items, Node]
#tee: funktio reloadille joka travelaa animtreessä siihen ja sitten laittaa reloading = false
func _ready() -> void:
	state_machines.append(SyncedAnimTrees[0]["parameters/playback"])
	state_machines.append(SyncedAnimTrees[1]["parameters/playback"])
	
func _process(delta: float) -> void:
	#if InvHandler.currently_holding in item_link.keys():
	#	print(item_link[item_link.find_key(InvHandler.currently_holding)])
	#	print("jjjjjjjjjjjjjjjjjjjjj")
	current_animation_node = state_machines[0].get_current_node()
	#print(AnimTree.animation_finished)
	Dense.visible = false
	if !("RELOAD" in current_animation_node):
		AnimationSound.stop()
	
	match InvHandler.currently_holding:
		enumsKP.items.DENSE:
			Dense.visible = true
		enumsKP.items.TOASTER:
			if reloading && !AnimationSound.playing:
				AnimationSound.stream = PaahdinReloadSound
				AnimationSound.play()
		enumsKP.items.PHONE:
			Phone.visible = true
			if reloading && !AnimationSound.playing:
				AnimationSound.stream = PhoneReloadSound
				AnimationSound.play()
