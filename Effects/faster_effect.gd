extends Effect
class_name FasterEffect

func do_effect():
	var npcs = get_tree().get_nodes_in_group("NPC")
	for npc in npcs:
		npc.work_speed += npc.work_speed * 0.1

func _ready() -> void:
	set_effect_name("+ Work Speed")
