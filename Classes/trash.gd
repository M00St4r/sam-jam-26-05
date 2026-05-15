extends Interactable
class_name Trash

var spawn_dist: float = 25
var speed: float = 1
var move_dir: Vector3

var stop: bool

@onready var isle_check = %TrashArea

func interact():
	# destroy self increase energy counter on player
	pass
	
func _ready() -> void:
	
	var circle_fac = randf()
	var x = sin(circle_fac)
	var z = cos(circle_fac)
	global_position = Vector3(x,0,z)
	
	move_dir = -global_position.normalized()

func _process(_delta: float) -> void:
	if !stop:
		constant_linear_velocity = move_dir * speed
	else:
		constant_linear_velocity = Vector3.ZERO

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.name == "Isle":
		stop = true


func _on_area_3d_area_entered(area: Area3D) -> void:
	if area.name == "TrashArea":
		stop = true
