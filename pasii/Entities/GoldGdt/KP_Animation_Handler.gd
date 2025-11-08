
class_name KiipeliAnimHandler extends Node

#AnimationTree's advance_expression_base_node needs to point
#to a node that has this script 
var is_moving: bool = false
var in_dialogue: bool = false
var wallrunning = "NO"
var is_grounded: bool = true #DONT USE THIS -- WHAT THE FUCK IS THIS FOR?
var player_velocity: Vector3 = Vector3.ZERO
var player_speed_float: float = 0.0
var reloading: bool = false
var beer_opened: bool = false
var item = ""
var grounded = true
var current_animation_node: String
var rolling : bool = false
@export var Body : GoldGdt_Body
@export var powerup_ui_anim : AnimationPlayer
@export var InvHandler : KP_InventoryHandler
@export var SyncedAnimTrees : Array[AnimationTree]
@export var FootstepPlayer : Node3D #This VARIABLE is only for the landings etc. Fotsteps are handled straight from animplayer
var state_machines : Array[AnimationNodeStateMachinePlayback]
@export var AnimPlayer : AnimationPlayer
var vaultstate : String #This is set from move controller
var walljumpstate : String
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
	player_speed_float = player_velocity.length()
	#if InvHandler.currently_holding in item_link.keys():
	#	print(item_link[item_link.find_key(InvHandler.currently_holding)])
	#	print("jjjjjjjjjjjjjjjjjjjjj")
	current_animation_node = state_machines[0].get_current_node()
	#print(AnimTree.animation_finished)
	walljumpstate = str(Body.current_walljump_state)
	Dense.visible = false
	Liukuri.visible = false
	Beer.visible = false
	Paahdin.visible = false
	for ant in SyncedAnimTrees:
		var grndmvprev : Vector2 = ant["parameters/GroundMovement/blend_position"]
		var grndmvtarget : Vector2
		var airmvtarget : Vector2
		var airmvprev : Vector2 = ant["parameters/AirMovement/blend_position"]
		grndmvtarget.y = clampf(absf(Body.velocity.length() * 2.34), 0.0, 1.0)
		var duckblend := 0.0
		if !Body.ducked:
			duckblend = lerpf(duckblend, 1.0, 0.05)
		else:
			duckblend = lerpf(1.0, duckblend, 0.05)
		grndmvtarget.x = duckblend
		
		airmvtarget.y = clampf(Body.velocity.y * -0.04, -0.8, 3.0)
		var hvel = (Body.velocity * Vector3(1, 0, 1)).length()*0.1
		airmvtarget.x = clampf(absf(hvel * 0.5), 0.0, 1.0)
		ant["parameters/GroundMovement/blend_position"] = lerp(grndmvprev, grndmvtarget, 0.1)
		ant["parameters/AirMovement/blend_position"] = lerp(airmvprev, airmvtarget, 0.01)
		var vaultprev : Vector2 = ant["parameters/Manuever/blend_position"]
		var vaulttarget : Vector2
		vaulttarget.y = clampf(Body.velocity.y * 0.1, -0.8, 3.0)
		vaulttarget.x = clampf(absf(hvel * 0.8), 0.0, 1.0)
		ant["parameters/Manuever/blend_position"] = lerp(vaultprev, vaulttarget, 0.1)

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
