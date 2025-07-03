class_name KP_InventoryHandler extends Node

var hotbar = [enumsKP.items.NO, enumsKP.items.LIUKURI, enumsKP.items.TOASTER, enumsKP.items.PHONE]
#powerups are in GoldGdt_Body btw
var current_hotbar_index = 0
var currently_holding : enumsKP.items
@export var AnimHandler : KiipeliAnimHandler

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("kp_cycleitem_A"):
		if current_hotbar_index >= hotbar.size()-1:
			current_hotbar_index = 0
		else:
			current_hotbar_index += 1
			currently_holding = hotbar[current_hotbar_index]
	if Input.is_action_just_pressed("kp_cycleitem_B"):
		if current_hotbar_index <= 0:
			current_hotbar_index = hotbar.size()-1
		else:
			current_hotbar_index -= 1
			currently_holding = hotbar[current_hotbar_index]
	AnimHandler.item = enumsKP.items.find_key(currently_holding)
