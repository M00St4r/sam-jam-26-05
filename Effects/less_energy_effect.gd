extends Effect
class_name LessEnergyEffect

func do_effect():
	var npcs = get_tree().get_nodes_in_group("NPC")
	for npc in npcs:
		npc.energy_multiplayer -= 0.1

func _ready() -> void:
	set_effect_name("- Energy Gain")
