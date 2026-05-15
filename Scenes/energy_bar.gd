extends ProgressBar

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	var player = get_tree().get_first_node_in_group("Player")
	if player:
		value = player.get_bar_value()
