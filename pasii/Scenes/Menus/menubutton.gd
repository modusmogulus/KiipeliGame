extends StaticBody3D

@export var menu : Node
#@export var button_index : int
var respond_to_mouse = false
#NOTE: Enter tree is ordered from top down while ready is not

func _enter_tree() -> void:
	menu.selectables.append(self)
	#if menu.selectables.size() > button_index+1:
	#	menu.selectables.resize(button_index+1)
	#	menu.selectables[button_index] = self
func select_self() -> void:
	if menu.selected_node == self:	return
	menu.selected_node = self
	scale *= menu.size_multiplier_on_select
	menu.selection_index = menu.selectables.find(self)
func deselect_self() -> void:
		if menu.selected_node != self:	return
		scale /= menu.size_multiplier_on_select
		
		menu.selected_node = null
		#menu.selection_index = -1
func _mouse_enter() -> void:
	if respond_to_mouse:
		menu.deselect_all()
		select_self()

#func _mouse_exit() -> void:
#	deselect_self()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
