extends StaticBody3D

@export var menu : Node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	menu.selectables.append(self)

func select_self() -> void:
	menu.selected_node = self
	scale *= menu.size_multiplier_on_select
	menu.selection_index = menu.selectables.find(self)
func deselect_self() -> void:
		scale /= menu.size_multiplier_on_select
		#if menu.selected_node != self:	return
		menu.selected_node = null
		#menu.selection_index = -1
func _mouse_enter() -> void:
	select_self()

#func _mouse_exit() -> void:
#	deselect_self()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
