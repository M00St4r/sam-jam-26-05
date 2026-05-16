extends StaticBody3D
class_name GachaMachine

@onready var fill = %GachaFill
@onready var gacha_text = %GachaDisplay

var stored_energy: float = 0
var required_energy: float = 100
var result

@export var effects: Node

func interact():
	var player = get_tree().get_first_node_in_group("Player")
	if player.get_energy() >= 10:
		player.add_energy(-10)
		add_energy(10)

func add_energy(_amount:float):
	stored_energy += _amount

func _process(delta: float) -> void:
	if stored_energy >= required_energy:
		gacha()
	fill.scale.y = stored_energy/required_energy

func gacha():
	var result: Effect = effects.get_children()[randi_range(0, len(effects.get_children())-1)]
	result.do_effect()
	gacha_text.text = "Added: " + result.effect_name
	stored_energy = 0
