class_name TriggerBase
extends Area3D

var actions: Array[TriggerAction]

enum Triggertypes {
	ENTER = 0, #do_shit() on enter
	EXIT = 1, #do_shit() on exit
	LOOKED_AT = 2, #not implemented yet
	INTERACTED = 3 #press e to interact type shit etc etc
	}

@export var this_triggertype : Triggertypes = Triggertypes.ENTER
var last_body: Node3D

func scan_action_nodes():
	actions = [] #clear array
	for child in get_children():
		if child.has_method("do_shit"): #otherwise the node isnt based, fuck of
			actions.append(child) #add found actions
		else:
			print_rich("[color=orange] BULLSHIT DETECTED: Trigger named  " + get_name() + "  has an unexpected child!" + child.get_name() + "  does not have method do_shit() [/color] ")
			print_rich("[color=red] aborting ALL action related calls on  [/color]" + child.get_name())

func execute_actions(body: Node3D):
	for action in actions:
		action.do_shit(body)


func _ready() -> void:
	scan_action_nodes()
	
func _on_body_entered(body: Node3D) -> void:
	last_body = body
	if this_triggertype == Triggertypes.ENTER:
		if "Player" in body.get_groups():
			execute_actions(body)
			return
	if this_triggertype == Triggertypes.INTERACTED:
		body.interactables_in_reach.append(self)
func _on_body_exited(body: Node3D) -> void:

	if this_triggertype == Triggertypes.EXIT:
		if "Player" in body.get_groups():
			execute_actions(body)
			return
	if this_triggertype == Triggertypes.INTERACTED:
		body.interactables_in_reach.erase(self)

func interact():
	execute_actions(last_body)
