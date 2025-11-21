
class_name KiipeliAnimHandler extends Node

#AnimationTree's advance_expression_base_node needs to point
#to a node that has this script 
var is_moving: bool = false
var in_dialogue: bool = false
var wallrunstate = "NONE"
var is_grounded: bool = true #DONT USE THIS -- WHAT THE FUCK IS THIS FOR?
var player_velocity: Vector3 = Vector3.ZERO
var player_speed_float: float = 0.0
var reloading: bool = false
var beer_opened: bool = false
var item = ""
var fullitemdata : itemdata
var grounded = true
var current_animation_node: String
var rolling : bool = false
var handswitch : bool = false
@export var ik_speed : float = 0.1
@export var Body : GoldGdt_Body
@export var powerup_ui_anim : AnimationPlayer
@export var InvHandler : KP_InventoryHandler
@export var SyncedAnimTrees : Array[AnimationTree]
@export var FootstepPlayer : Node3D #This VARIABLE is only for the landings etc. Fotsteps are handled straight from animplayer
var state_machines : Array[AnimationNodeStateMachinePlayback]
@export var AnimPlayer : AnimationPlayer
var vaultstate : String #This is set from move controller
var walljumpstate : String = "NONE"
@export var Dense: Node
@export var Phone: Node
@export var Liukuri: Node
@export var Paahdin: Node
@export var AnimationSound: AudioStreamPlayer3D
@export var Beer: Node
var targetinfluenceL : float = 0.0
var targetinfluenceR : float = 0.0
@export var ik_max_influence : float = 0.3
@export var PaahdinReloadSound: AudioStream
@export var PhoneReloadSound: AudioStream

@export var item_link: Dictionary[enumsKP.items, Node]
var handsnap_timer : float = 0.0

var diving = false #set from body script
#tee: funktio reloadille joka travelaa animtreessä siihen ja sitten laittaa reloading = false
func _ready() -> void:
	state_machines.append(SyncedAnimTrees[0]["parameters/playback"])
	state_machines.append(SyncedAnimTrees[1]["parameters/playback"])

func snap_hands_to(pos : Vector3, wideness : float, duration : float = -1):
	Body.IK_left_hand_target.global_position = pos + (Body.View.camera.global_basis.x)*-wideness
	Body.IK_right_hand.start()
	Body.IK_left_hand.start()
	handsnap_timer = duration
	targetinfluenceL = ik_max_influence
	Body.IK_right_hand_target.global_position = pos + (Body.View.camera.global_basis.x)*wideness
	
	targetinfluenceR = ik_max_influence
func switch_hand():
	handswitch = !handswitch

func animate_powerup_ui():
	powerup_ui_anim.play("powerup_added")

func _process(delta: float) -> void:
	var previnfluenceL = Body.IK_left_hand.influence
	var previnfluenceR = Body.IK_right_hand.influence 
	if handsnap_timer > 0:
		handsnap_timer -= delta
		Body.IK_left_hand.influence = lerpf(previnfluenceL, targetinfluenceR, ik_speed)
		
		Body.IK_right_hand.influence = lerpf(previnfluenceR, targetinfluenceR, ik_speed)
	
	else:
		targetinfluenceL = 0.0
		targetinfluenceR = 0.0
		if Body.IK_left_hand.influence == targetinfluenceL:
			Body.IK_left_hand.stop()
		if Body.IK_right_hand.influence == targetinfluenceL:
			Body.IK_right_hand.stop()
		Body.IK_left_hand.influence = lerpf(previnfluenceL, targetinfluenceR, ik_speed)
		Body.IK_right_hand.influence = lerpf(previnfluenceR, targetinfluenceR, ik_speed)
	player_speed_float = player_velocity.length()
	#if InvHandler.currently_holding in item_link.keys():
	#	print(item_link[item_link.find_key(InvHandler.currently_holding)])
	#	print("jjjjjjjjjjjjjjjjjjjjj")
	current_animation_node = state_machines[0].get_current_node()
	#print(AnimTree.animation_finished)
	walljumpstate = str(Body.current_walljump_state)
	
	wallrunstate = str(Body.current_wallrun_state)
	if wallrunstate == "0":
		wallrunstate = "NONE"
	elif wallrunstate == "-1":
		wallrunstate = "LEFT"
	elif wallrunstate == "1":
		wallrunstate = "RIGHT"
	if walljumpstate == "0":
		walljumpstate = "NONE"
	elif walljumpstate == "1":
		walljumpstate = "WALLJUMP"
	elif walljumpstate == "-1":
		walljumpstate = "WALLKICK"
	Dense.visible = false
	Liukuri.visible = false
	Beer.visible = false
	Paahdin.visible = false
	
	for ant in SyncedAnimTrees:
		var grndmvprev : Vector2 = ant["parameters/GroundMovement/blend_position"]
		var grndmvtarget : Vector2
		var airmvtarget : Vector2
		var airmvprev : Vector2 = ant["parameters/AirMovement/blend_position"]
		var wallrunprev : Vector2 = ant["parameters/Wallruns/blend_position"]
		var wallruntarget : Vector2
		var walljumpprev : Vector2 = ant["parameters/Walljump/blend_position"]
		var walljumparget : Vector2
		
		grndmvtarget.y = clampf(absf(Body.velocity.length() * 2.34), 0.0, 1.0)
		var duckblend := 0.0
		if !Body.ducked:
			duckblend = lerpf(duckblend, 1.0, 0.05)
			if Dialogic.current_timeline != null:
				duckblend = lerpf(1.0, duckblend, 0.05)
		else:
			duckblend = lerpf(1.0, duckblend, 0.05)
		
		grndmvtarget.x = duckblend
		if wallrunstate == "LEFT":
			wallruntarget.x = -1
			wallruntarget.y = 0
		elif wallrunstate == "RIGHT":
			wallruntarget.x = 1
			wallruntarget.y = 0
		elif wallrunstate == "BOTH":
			wallruntarget.x = 0
			wallruntarget.y = -0.5
		
		
		if walljumpstate == "WALLJUMP":
			walljumparget.x = (int(handswitch)*2)-1
			walljumparget.y = player_velocity.y * 0.6
		ant["parameters/Wallruns/blend_position"] = lerp(wallrunprev, wallruntarget, 0.05)
		airmvtarget.y = clampf(Body.velocity.y * -0.04, -0.8, 3.0)
		var hvel = (Body.velocity * Vector3(1, 0, 1)).length()*0.1
		airmvtarget.x = clampf(absf(hvel * 0.5), 0.0, 1.0)
		ant["parameters/GroundMovement/blend_position"] = lerp(grndmvprev, grndmvtarget, 0.08)
		if item != "LIUKURI":
			ant["parameters/AirMovement/blend_position"] = lerp(airmvprev, airmvtarget, 0.11)
		ant["parameters/Walljump/blend_position"] = lerp(walljumpprev, walljumparget, 0.05)
		
		var vaultprev : Vector2 = ant["parameters/Manuever/blend_position"]
		var vaulttarget : Vector2
		vaulttarget.y = clampf(Body.velocity.y * 0.1, -0.8, 3.0)
		vaulttarget.x = clampf(absf(hvel * 0.8), 0.0, 1.0)
		ant["parameters/Manuever/blend_position"] = lerp(vaultprev, vaulttarget, 0.1)

	if !("RELOAD" in current_animation_node):
		AnimationSound.stop()
	
		Dense.visible = false
		Paahdin.visible = false
		Phone.visible = false
		Liukuri.visible = false
		Beer.visible = false
	match item:
		"DENSE":
			Dense.visible = true
		"TOASTER":
			Paahdin.visible = true
			if reloading && !AnimationSound.playing:
				AnimationSound.stream = PaahdinReloadSound
				AnimationSound.play()
				
		"PHONE":
			Phone.visible = true
			
			if reloading && !AnimationSound.playing:
				AnimationSound.stream = PhoneReloadSound
				AnimationSound.play()
		"LIUKURI":
			Liukuri.visible = true
			#if reloading && !AnimationSound.playing:
				#AnimationSound.stream = PhoneReloadSound
			#	AnimationSound.play()
		"BEER":
			Beer.visible = true
			if reloading:
				beer_opened = true
