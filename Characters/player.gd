extends CharacterBody3D
class_name Player

@onready var _camera := %Camera3D as Camera3D
@onready var _camera_pivot := %CameraPivot as Node3D
@onready var _armature := %Armature as Node3D
@onready var _anim_player := $AnimationPlayer as AnimationPlayer
@onready var interact_area := $Area3D as Area3D

@export_group("Camera")
@export_range(0.0, 1.0) var mouse_sensitivity = 0.01
@export var tilt_limit = deg_to_rad(75)

@export_group("Movement")
@export var movement_speed: float = 8
@export var acceleration: float = 20
@export var rotation_speed: float = 12
@export var jump_impulse: float = 12

var _gravity: float = -30

var paused: bool = false

enum STATE {IDLE, MOVING, JUMPING, FALLING}
var current_state = STATE.IDLE

var bodies: Array[Node3D]

#lock cursor, make cursor invis:

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _process(delta: float) -> void:
		
	move_and_slide()
	
	#process_pause()
	process_movement(delta)
	
	#Interaction
	if Input.is_action_just_pressed("interact") && len(bodies) > 0:
		var interactable = _get_closest_node(bodies)
		interactable.interact()
	
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
	
# Camera Look
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		_camera_pivot.rotation.x -= event.relative.y * mouse_sensitivity
		# Prevent the camera from rotating too far up or down.
		_camera_pivot.rotation.x = clampf(_camera_pivot.rotation.x, -tilt_limit, tilt_limit)
		_camera_pivot.rotation.y += -event.relative.x * mouse_sensitivity


func _on_area_3d_body_entered(_body: Node3D) -> void:
	bodies = interact_area.get_overlapping_bodies()
	#print(bodies)

func _on_area_3d_body_exited(_body: Node3D) -> void:
	bodies = interact_area.get_overlapping_bodies()

func _get_closest_node(nodes: Array[Node3D]) -> Node3D:
	var closest: Node3D
	var closest_dist: float = 100
	for n in nodes:
		var dist = n.global_position.distance_squared_to(global_position)
		if dist < closest_dist:
			closest = n
	return closest
