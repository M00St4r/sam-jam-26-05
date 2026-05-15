extends Node3D
class_name TrashSpawner

@export var trash: Array[Trash]
var spawn_timer: Timer = Timer.new()
var wait_time_base = 10

func _ready() -> void:
	add_child(spawn_timer)
	spawn_timer.one_shot = true
	spawn_timer.timeout.connect(_on_timer_timeout)
	set_spawn_timer()

func set_spawn_timer():
	spawn_timer.wait_time = wait_time_base / difficulty_manager.difficulty
	spawn_timer.start()

func _on_timer_timeout():
	spawn_trash(1)
	set_spawn_timer()

func _process(_delta: float) -> void:
	pass

func spawn_trash(burst: int) -> void:
	for spawn in burst:
		var trash_spawn = trash[randi_range(0,len(trash)-1)].duplicate()
		add_child(trash_spawn)
		trash_spawn.just_spawned()
