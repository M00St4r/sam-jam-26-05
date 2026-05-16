extends Node
class_name DifficultyManager

@export var difficulty: float = 50

func increase_difficulty(_value: float) -> void:
	difficulty += _value
