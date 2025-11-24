extends TextureRect
var linked_inventory_child : itemdata
func  refresh() -> void:
	if itemdata:
		texture = linked_inventory_child.thumbnail
