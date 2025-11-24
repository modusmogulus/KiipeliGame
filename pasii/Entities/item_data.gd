class_name itemdata extends Node

var item_owner : KP_InventoryHandler
@export var item_type : enumsKP.items = enumsKP.items.NO
@export var max_uses : int = -1
@export var uses_left : int = 1
@export var thumbnail : Texture
@export var item_model : Node3D
@export var item_hud_display : Control
var model_target_parent : Node3D
var display_target_parent : Node3D
@export var in_world : bool = false
@export var model_visible : bool
@export var display_visible : bool


func refresh() -> void:
	item_model.visible = model_visible
	item_hud_display.linked_inventory_child = self
	item_model.linked_inventory_child = self
	item_hud_display.visible = display_visible
	item_hud_display.refresh()
	if "KP_InventoryHandler" in get_parent().get_class():
		item_owner = get_parent()
		item_hud_display = get_parent().display_target_parent
		model_target_parent = get_parent().model_target_parent
		if model_target_parent && item_model:
			item_model.reparent(model_target_parent, false)
			item_model.position = Vector3.ZERO
		if display_target_parent && item_hud_display:
			item_hud_display.reparent(display_target_parent, false)
			item_hud_display.position = Vector2.ZERO

func _ready() -> void:
	refresh()

func destroy_item():
	if item_owner:
		item_owner.items.remove(self)
		item_hud_display.queue_free()
		item_model.queue_free()
		queue_free()

func use(howmuch : int = 1):
	if max_uses <= -1:
		return
	else:
		uses_left -= howmuch
	if uses_left <= 0:
		destroy_item()
