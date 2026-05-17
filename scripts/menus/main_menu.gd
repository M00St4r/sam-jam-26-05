extends Control
func quit():
	get_tree().quit()

func start():
	get_tree().change_scene_to_file('res://Scenes/tutorial.tscn')
