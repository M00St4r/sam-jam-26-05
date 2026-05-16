extends Effect
class_name LessRangeEffect

func do_effect():
	var npcs = get_tree().get_nodes_in_group("NPC")
	for npc in npcs:
		npc.add_area_size(0.2)

func _ready() -> void:
	set_effect_name("- Work Range")
