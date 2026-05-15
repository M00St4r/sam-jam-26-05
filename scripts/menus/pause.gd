extends Control

var is_paused: bool

@onready var pause = %Pause

func _ready() -> void:
	pause.visible = false

func _input(event) -> void:
	if event.is_action_pressed("pause"):
		if is_paused:
			pause.visible = false
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			#get_tree().paused = false
		else:
			pause.visible = true
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			#get_tree().paused = true
		is_paused = !is_paused
		
		#if Input.is_action_just_pressed("pause"):
		#if paused:
			#Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		#else:
			#Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		#paused = !paused

func _quit():
	get_tree().quit()

func _main_menu():
	get_tree().change_scene_to_file('res://Scenes/menu.tscn')

func _pause():
	is_paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	#get_tree().paused = false
	pause.visible = false
