extends Node3D

func _ready() -> void:
	# Load the scene file into a PackedScene resource
	var scene = load("res://Scenes/level.tscn")
	# Create an instance of that scene
	var scene_instance = scene.instantiate()
	# Add the instance to the current node (or any parent node)
	add_child(scene_instance)

	var spawn = scene_instance.find_child("CharacterSpawn", true, false)
	
	var character_scene = load("res://Characters/slime.tscn")
	
	var character_scene_instance = character_scene.instantiate()
	if spawn:
		character_scene_instance.transform = spawn.transform
	else:
		push_error("CharacterSpawn not found!")
	add_child(character_scene_instance)
