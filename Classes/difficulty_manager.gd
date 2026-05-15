extends Node
class_name DifficultyManager

@export var difficulty: float = 10

func increase_difficulty(_value: float) -> void:
	difficulty += _value
