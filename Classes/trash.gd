extends RigidBody3D
class_name Trash

@export var hp = 100
@export var stored_energy: float = 5
@export var speed: float = 5
@export var difficulty_gain: float = 0.1
var spawn_dist: float = 40
var move_dir: Vector3

var stop: bool = true

var attacker

@onready var isle_check = %TrashArea

func interact():
	pass
	##print(name + " got interacted with")
	#var player = get_tree().get_nodes_in_group("Player")[0] as Player
	#player.add_energy(stored_energy)
	#
	#queue_free()
	
func _ready() -> void:
	var path = TrashTypes.trash_type_paths[randi_range(0,len(TrashTypes.trash_type_paths)-1)]
	var trash_scene = load(path)
	var trash_scene_instance = trash_scene.instantiate()
	# Add the instance to the current node (or any parent node)
	add_child(trash_scene_instance)
	trash_scene_instance.position = Vector3.ZERO
	
	for child in trash_scene_instance.get_children():
		if child is CollisionShape3D:
			child.reparent(self, true)
			
	rotation.y = randf_range(0, 2*PI)
	
	stored_energy = stored_energy * difficulty_manager.difficulty / 2

func just_spawned():
	
	stop = false
	var circle_fac = randf() * 2 * PI
	var x = sin(circle_fac)
	var z = cos(circle_fac)
	global_position = Vector3(x,0,z) * spawn_dist
	
	move_dir = -global_position.normalized()

func _process(_delta: float) -> void:
	move_dir = -global_position.normalized()
	if !stop:
		linear_velocity = move_dir * speed
	else:
		linear_velocity = Vector3.ZERO
		angular_velocity = Vector3.ZERO
	if hp <= 0:
		if attacker:
			#print("Energy: ", stored_energy)
			attacker.add_energy(stored_energy)
			attacker.target = null
		difficulty_manager.increase_difficulty(difficulty_gain)
		queue_free()

func damage(_amount: float, _attacker):
	hp -= _amount
	attacker = _attacker

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("World"):
		stop = true


func _on_area_3d_area_entered(_area: Area3D) -> void:
	#if area.is_in_group("Trash"):
		#if area.get_parent().stop == true:
			#stop = true
	pass
