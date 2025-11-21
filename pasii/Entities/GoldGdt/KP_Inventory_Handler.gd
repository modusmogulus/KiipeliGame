class_name KP_InventoryHandler extends Node

#@export var hotbar : Array[enumsKP.items] = [enumsKP.items.NO, enumsKP.items.LIUKURI, enumsKP.items.TOASTER, enumsKP.items.PHONE]
var hotbar : Array[itemdata]
#powerups are in GoldGdt_Body btw
@export var controllable = true
var current_hotbar_index = 0
var currently_holding : itemdata
@export var AnimHandler : KiipeliAnimHandler
@export var model_target_parent : Node3D
@export var display_target_parent : Control
func fix_ownership():
	if hotbar.size() > 0:
		for itm in hotbar:
			itm.item_owner = self
func _ready() -> void:
	fix_ownership()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("kp_cycleitem_A") && controllable:
		if current_hotbar_index >= hotbar.size()-1:
			current_hotbar_index = 0
		else:
			current_hotbar_index += 1
			currently_holding = hotbar[current_hotbar_index]
	if Input.is_action_just_pressed("kp_cycleitem_B") && controllable:
		if current_hotbar_index <= 0:
			current_hotbar_index = hotbar.size()-1
		else:
			current_hotbar_index -= 1
			currently_holding = hotbar[current_hotbar_index]
	if currently_holding:
		AnimHandler.item = enumsKP.items.find_key(currently_holding.item_type)
		AnimHandler.fullitemdata = currently_holding
	else:
		AnimHandler.item = enumsKP.items.find_key(enumsKP.items.NO)
		AnimHandler.fullitemdata = null
func add_to_hotbar(itm : itemdata):
	hotbar.append(itm)
	itm.display_visible = true
	itm.model_visible = false
	itm.reparent(self, false)
	itm.refresh()
	currently_holding = itm
