extends Node3D

@export var cube_scene: PackedScene
@export var target: Node3D                         
@export var spawn_distance: float = 12.0            
@export var x_range := Vector2(-0.8, 0.8)           
@export var y_range := Vector2(0.8, 1.6)            
@export var interval_range := Vector2(0.5, 2.0)     
@export var speed_range := Vector2(5.0, 9.0)        
@export var left_sword: Node                        
@export var right_sword: Node                      

var _spawning := false

func _ready() -> void:
	randomize()
	if cube_scene == null:
		if ResourceLoader.exists("res://Scenes/Cube.tscn"):
			cube_scene = load("res://Scenes/Cube.tscn")
	_spawning = true
	_spawn_loop()

func _spawn_loop() -> void:
	if not _spawning:
		return
	_spawn_one()
	var wait := randf_range(interval_range.x, interval_range.y)
	await get_tree().create_timer(wait).timeout
	_spawn_loop()

func _spawn_one() -> void:
	if cube_scene == null or target == null:
		return

	var cube : RigidBody3D = cube_scene.instantiate()
	var pos := target.global_transform.origin
	pos.x += randf_range(x_range.x, x_range.y)
	pos.y += randf_range(y_range.x, y_range.y)
	pos.z -= spawn_distance
	cube.global_transform = Transform3D(Basis(), pos)

	cube.target = target
	cube.speed = randf_range(speed_range.x, speed_range.y)

	var choices: Array[Color] = []
	if is_instance_valid(left_sword) and left_sword.has_method("get_sword_color"):
		choices.append(left_sword.get_sword_color())
	if is_instance_valid(right_sword) and right_sword.has_method("get_sword_color"):
		choices.append(right_sword.get_sword_color())
	if choices.is_empty():
		choices = [Color(0,0,1), Color(1,0,0)]

	cube.color = choices[randi() % choices.size()]
	add_child(cube)
