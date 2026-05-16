extends Label

func _process(_delta: float) -> void:
	var player = get_tree().get_first_node_in_group("Player")
	if player:
		text = player.get_interact_hints()
