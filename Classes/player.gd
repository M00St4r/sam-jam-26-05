extends CharacterBody3D
class_name Player

@onready var _camera := %Camera3D as Camera3D
@onready var _camera_pivot := %CameraPivot as Node3D
@onready var _armature := %Armature as Node3D
@onready var _anim_player := $AnimationPlayer as AnimationPlayer
@onready var interact_area := $Area3D as Area3D
@onready var mesh := %Icosphere as MeshInstance3D
@onready var energy_core := %EnergyCore as Node3D

@export_group("Camera")
@export_range(0.0, 1.0) var mouse_sensitivity = 0.01
@export var tilt_limit = deg_to_rad(75)

@export_group("Movement")
@export var movement_speed: float = 8
@export var acceleration: float = 20
@export var rotation_speed: float = 12
@export var jump_impulse: float = 12

@export_group("Color")
@export var normal_color: Color = Color(0.0, 0.451, 1.0, 1.0)
@export var energized_color: Color = Color(0.0, 1.0, 0.761, 1.0)

var _gravity: float = -30
var cancel_velocity = 0.2

var paused: bool = false

enum STATE {IDLE, MOVING, JUMPING, FALLING}
var current_state = STATE.IDLE

var bodies: Array[Node3D]
var areas: Array[Area3D]

var target

var energy: float = 50
var energy_required_for_split:float = 100
@export_group("stats")
@export var work_speed = 35
@export var split_lvl_factor: float = 0.3

var interact_hints: String

#lock cursor, make cursor invis
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _process(delta: float) -> void:
		
	move_and_slide()
	
	update_interact_hints()
	#process_pause()
	process_movement(delta)
	
	#set_color()
	
	set_core_size()
	
	if Input.is_action_pressed("attack"):
		update_overlap()
		var attack_body = _get_closest_node(bodies)
		#var interactable_areas = _get_closest_node(areas)
		if attack_body:
			if attack_body is Trash:
				target = attack_body as Trash
				target.damage(work_speed*delta, self)
			#print(energy)
	
	if Input.is_action_just_pressed("interact") && len(bodies) > 0:
		update_overlap()
		var interactable_body = _get_closest_node(bodies)
		#var interactable_areas = _get_closest_node(areas)
		if interactable_body:
			interactable_body.interact()
			#print(energy)
	
	# splitting
	if Input.is_action_just_pressed("split"):
		if energy > energy_required_for_split:
			#Split
			energy -= energy_required_for_split
			var worker_spawn_pos = global_position
			global_position = global_position + transform.basis.z * 2
			var worker = load("res://Characters/worker.tscn")
			var worker_instance = worker.instantiate()
			get_parent().add_child(worker_instance)
			worker_instance.global_position = worker_spawn_pos
			
			#increase required energy
			energy_required_for_split += energy_required_for_split * split_lvl_factor
		else:
			print("not enough energy to split")
	
	if Input.is_action_just_pressed("lvlup"):
		update_overlap()
		var interactable = _get_closest_node(bodies)
		if interactable is Worker:
			var lvl_up_worker = interactable as Worker
			lvl_up_worker.level_up()
	
	match current_state:
		STATE.IDLE:
			if velocity:
				current_state = STATE.MOVING
			if Input.is_action_just_pressed("jump") and is_on_floor():
				current_state = STATE.JUMPING
			if _anim_player.current_animation != "idle":
				_anim_player.play("idle")
			if velocity.y < 0:
				current_state = STATE.FALLING
		STATE.MOVING:
			if !velocity:
				current_state = STATE.IDLE
			if Input.is_action_just_pressed("jump") and is_on_floor():
				current_state = STATE.JUMPING
			if _anim_player.current_animation != "move":
				_anim_player.play("move")
			if velocity.y < 0:
				current_state = STATE.FALLING
		STATE.JUMPING:
			process_jump()
			current_state = STATE.MOVING
			_anim_player.play("jump")
		STATE.FALLING:
			_anim_player.stop()
			if is_on_floor():
				current_state = STATE.IDLE
			
	velocity.y += + _gravity * delta
	#print(current_state)
	
#func process_pause():
	#if Input.is_action_just_pressed("pause"):
		#if paused:
			#Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		#else:
			#Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		#paused = !paused
		
func update_interact_hints():
	update_overlap()
	
	if len(bodies) > 0:
		var body = _get_closest_node(bodies)
		
		if body is Trash:
			interact_hints = "LMouse to decompose Trash"
		if body is Worker:
			if body.stored_energy > body.req_level_up_energy:
				interact_hints = "E to level up Worker | F to collect Energy"
			elif body.stored_energy > 0:
				interact_hints = "F to collect Energy"
		if body is GachaMachine:
			interact_hints = "F to deposit 25 energy"
		
		#if body is not GachaMachine or not Worker or not Trash:
			#interact_hints = ""
	elif energy > energy_required_for_split:
		interact_hints = "Q to Split"
	else:
		interact_hints = ""
	
func get_interact_hints() -> String:
	return interact_hints

func get_bar_value() -> float:
	return (energy / energy_required_for_split) * 100

func set_core_size():
	var size = energy / energy_required_for_split
	energy_core.scale = (Vector3.ONE * size).clamp(Vector3.ZERO,Vector3.ONE)
	
func set_color():
	var mat = mesh.get_active_material(0) as StandardMaterial3D
	mat.albedo_color = lerp(normal_color, energized_color, energy/(energy_required_for_split+50))

func process_movement(delta):
	var _last_move_dir := Vector3.BACK
	
	var input_vector := Input.get_vector("left","right","forward","back")
	
	if input_vector:
		var forward := _camera.global_basis.z
		var right := _camera.global_basis.x
		var move_dir := forward * input_vector.y + right * input_vector.x
		move_dir.y = 0.0
		move_dir = move_dir.normalized()

		#velocity.y = 0
		var target_velocity: Vector3 = velocity.move_toward(move_dir * movement_speed, acceleration * delta)
		velocity = Vector3(target_velocity.x,velocity.y, target_velocity.z)
		_last_move_dir = move_dir
	else:
		velocity *= Vector3(0, 1, 0)
		
	rotate_model(_last_move_dir, delta)

func rotate_model(_last_move_dir, delta):
	var target_angle := Vector3.BACK.signed_angle_to(_last_move_dir, Vector3.UP)
	_armature.global_rotation.y = lerp_angle(_armature.rotation.y, target_angle, rotation_speed * delta)
	
func process_jump():
	velocity.y += jump_impulse
	
func add_energy(amount: float):
	energy += amount
	#print(energy)

func get_energy() -> float:
	return energy

# Camera Look
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		_camera_pivot.rotation.x -= event.relative.y * mouse_sensitivity
		_camera_pivot.rotation.x = clampf(_camera_pivot.rotation.x, -tilt_limit, tilt_limit)
		_camera_pivot.rotation.y += -event.relative.x * mouse_sensitivity


func _on_area_3d_body_entered(_body: Node3D) -> void:
	bodies = interact_area.get_overlapping_bodies()
	#print(bodies)

func _on_area_3d_body_exited(_body: Node3D) -> void:
	bodies = interact_area.get_overlapping_bodies()

func update_overlap():
	areas = interact_area.get_overlapping_areas()
	bodies = interact_area.get_overlapping_bodies()

func _get_closest_node(nodes: Array[Variant]) -> Variant:
	var closest: Variant
	var closest_dist: float = 100
	for n in nodes:
		var dist = n.global_position.distance_squared_to(global_position)
		if dist < closest_dist:
			closest = n
	return closest
