extends VBoxContainer
@export var weird_cursor : Control
var choicebutts : Array[DialogicNode_ChoiceButton]

func _process(delta) -> void:
	
	for child in get_children():
		if "position" in child:
			if position.y + 10 > weird_cursor.position.y && position.y - 10 < weird_cursor.position.y:
				weird_cursor.grab_focus()
