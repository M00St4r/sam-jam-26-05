extends StaticBody3D
class_name  Interactable

func interact():
	print(name + " got interacted with")
	
func _ready() -> void:
	set_collision_layer_value(1, true)
	set_collision_layer_value(2, true)
	set_collision_layer_value(3, true)
