extends AnimationTree


func _ready() -> void:
	#THIS IS NOT DUMB CODE! DONT REMOVE WITHOUT THINKING!!!
	var unique_clone = tree_root.duplicate(false) #paradoxal name lol
	tree_root = unique_clone
#FIXME: Why the fuck doesnt walking/running work now????
