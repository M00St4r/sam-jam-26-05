extends Effect
class_name MoreDifficultyEffect

func do_effect():
	difficulty_manager.difficulty += 1

func _ready() -> void:
	set_effect_name("+ Difficulty")
