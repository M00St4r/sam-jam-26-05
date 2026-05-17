extends Control

@onready var t_image := %TextureRect as TextureRect
@onready var l_text := %Label as Label
@onready var b_text := %Button as Button

var t_images: Array[CompressedTexture2D]
var l_texts: Array[String] = [
	"Decompose trash to Gain Energy",
	"Split up to get helpful Workers",
	"Level up your workers or take their energy",
	"Deposit your energy to get effects"
]
var b_texts: Array[String] = [
	"Okay",
	"Got it",
	"hm hm",
	"Let's go!"
]

var counter: int = 0

func _ready() -> void:
	t_images.push_back(load("res://TutorialImages/01.tres") as CompressedTexture2D)
	t_images.push_back(load("res://TutorialImages/02.tres") as CompressedTexture2D)
	t_images.push_back(load("res://TutorialImages/03.tres") as CompressedTexture2D)
	t_images.push_back(load("res://TutorialImages/04.tres") as CompressedTexture2D)

func quit():
	get_tree().quit()

func start():
	get_tree().change_scene_to_file('res://Scenes/main.tscn')


func _on_button_button_down() -> void:
	counter += 1
	
	if counter == 4:
		get_tree().change_scene_to_file('res://Scenes/main.tscn')
	else:
		t_image.texture = t_images[counter]
		b_text.text = b_texts[counter]
		l_text.text = l_texts[counter]
