
class_name KiipeliAnimHandler extends Node

#AnimationTree's advance_expression_base_node needs to point
#to a node that has this script 
var is_moving: bool = false
var wallrunning = "NO"
var is_grounded: bool = true
var player_velocity: Vector3 = Vector3.ZERO
var reloading: bool = false
var beer_opened: bool = false
var item = ""
var grounded = true
var current_animation_node: String
var rolling : bool = false
@export var powerup_ui_anim : AnimationPlayer
@export var InvHandler : KP_InventoryHandler
@export var SyncedAnimTrees : Array[AnimationTree]
var state_machines : Array[AnimationNodeStateMachinePlayback]
@export var AnimPlayer : AnimationPlayer
var vaultstate : String #This is set from move controller
@export var Dense: Node
@export var Phone: Node
@export var Liukuri: Node
@export var Paahdin: Node
@export var AnimationSound: AudioStreamPlayer3D
@export var Beer: Node

@export var PaahdinReloadSound: AudioStream
@export var PhoneReloadSound: AudioStream

@export var item_link: Dictionary[enumsKP.items, Node]
var diving = false #set from body script
#tee: funktio reloadille joka travelaa animtreessä siihen ja sitten laittaa reloading = false
func _ready() -> void:
	state_machines.append(SyncedAnimTrees[0]["parameters/playback"])
	state_machines.append(SyncedAnimTrees[1]["parameters/playback"])

func animate_powerup_ui():
	powerup_ui_anim.play("powerup_added")
func _process(delta: float) -> void:
	if rolling:
		print("ROLLED")
	#if InvHandler.currently_holding in item_link.keys():
	#	print(item_link[item_link.find_key(InvHandler.currently_holding)])
	#	print("jjjjjjjjjjjjjjjjjjjjj")
	current_animation_node = state_machines[0].get_current_node()
	#print(AnimTree.animation_finished)
	
	Dense.visible = false
	Liukuri.visible = false
	Beer.visible = false
	Paahdin.visible = false
	if !("RELOAD" in current_animation_node):
		AnimationSound.stop()
	
	match InvHandler.currently_holding:
		enumsKP.items.DENSE:
			Dense.visible = true
		enumsKP.items.TOASTER:
			Paahdin.visible = true
			if reloading && !AnimationSound.playing:
				AnimationSound.stream = PaahdinReloadSound
				AnimationSound.play()
				
		enumsKP.items.PHONE:
			Phone.visible = true
			
			if reloading && !AnimationSound.playing:
				AnimationSound.stream = PhoneReloadSound
				AnimationSound.play()
		enumsKP.items.LIUKURI:
			Liukuri.visible = true
			#if reloading && !AnimationSound.playing:
				#AnimationSound.stream = PhoneReloadSound
			#	AnimationSound.play()
		enumsKP.items.BEER:
			Beer.visible = true
			if reloading:
				beer_opened = true
