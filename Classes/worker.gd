extends StaticBody3D
class_name Worker

@export var work_speed: float = 25
@export var hp: float = 100
@export var stored_energy: float = 0
@export var req_level_up_energy: float = 100
@export var level = 1

@export var normal_color: Color = Color(0.0, 0.451, 1.0, 1.0)
@export var energized_color: Color = Color(0.0, 1.0, 0.761, 1.0)

@onready var collider = %WorkerCollider as CollisionShape3D
@onready var armature = %Armature as Node3D
@onready var worker_area = %WorkerArea as Area3D
@onready var _anim_player = %AnimationPlayer as AnimationPlayer
@onready var mesh := %Icosphere as MeshInstance3D

var trash_in_range: Array[Trash]

var max_energy: float = 200

@export var target: Trash

var work_timer: Timer = Timer.new()

enum STATE {IDLE, WORK}
var current_state = STATE.IDLE

@onready var ground_check = %RayCast3D
var on_ground: bool = false

func _ready() -> void:
	set_size()
	pass
	

func _process(_delta: float) -> void:
	if not on_ground:
		if ground_check.is_colliding():
			global_position = ground_check.get_collision_point()
			ground_check.queue_free()
			on_ground = true

	set_size()
	
	set_color()
	
	_anim_player.play("idle")
	
	match current_state:
		STATE.IDLE:
			find_target()
			if target:
				current_state = STATE.WORK
		STATE.WORK:
			if !target:
				current_state = STATE.IDLE
			if stored_energy >= max_energy:
				stored_energy = max_energy
				current_state = STATE.IDLE
			else:
				work(_delta)

func interact():
	get_tree().get_first_node_in_group("Player").add_energy(stored_energy)
	stored_energy = 0

func set_color():
	var mat = mesh.get_active_material(0) as StandardMaterial3D
	mat.albedo_color = lerp(normal_color, energized_color, stored_energy/req_level_up_energy)

func level_up():
	if stored_energy > req_level_up_energy:
		# use energy
		stored_energy -= req_level_up_energy
		# update stats
		work_speed += work_speed / level
		max_energy += max_energy / level
		req_level_up_energy = max_energy * 0.75
		hp += hp * level/2
	
func give_energy():
	get_tree().get_first_node_in_group("Player").add_energy(stored_energy)
	stored_energy = 0

func set_size():
	if stored_energy > 0:
		var fac = (stored_energy/req_level_up_energy) * 0.75
		collider.scale = Vector3.ONE * (0.5 + fac)
		armature.scale = Vector3.ONE * (0.5 + fac)

func work(_delta: float):
	if !target:
		return
	target.damage(work_speed*_delta, self)

func find_target():
	update_overlap()
	if len(trash_in_range) > 0:
		target = _get_closest_trash(trash_in_range)

func add_energy(_amount: float):
	stored_energy += _amount

func update_overlap():
	var areas = worker_area.get_overlapping_areas()
	#print(areas)
	trash_in_range.clear()
	for area in areas:
		if area.get_parent() is Trash:
			trash_in_range.push_back(area.get_parent())
			
func _get_closest_trash(nodes: Array[Trash]) -> Trash:
	var closest: Trash
	var closest_dist: float = 100
	for n in nodes:
		var dist = n.global_position.distance_squared_to(global_position)
		if dist < closest_dist:
			closest = n
	return closest
