extends RigidBody3D

@export var speed: float = 5.0
@export var target: Node3D
@export var color: Color = Color(1, 0, 0)
@export var kill_distance_past: float = 0.8

@onready var mesh: MeshInstance3D = $Mesh
@onready var audio: AudioStreamPlayer3D = $Audio

var alive := true
var move_dir: Vector3 = Vector3.ZERO

func _ready() -> void:
	gravity_scale = 0.0
	sleeping = false
	_apply_color()
	add_to_group("cubes")

	if is_instance_valid(target):
		move_dir = (target.global_transform.origin - global_transform.origin).normalized()

func _physics_process(_delta: float) -> void:
	if not alive:
		return

	if move_dir != Vector3.ZERO:
		linear_velocity = move_dir * speed

	if is_instance_valid(target):
		var forward := -target.global_transform.basis.z  
		var cam_to_cube := global_transform.origin - target.global_transform.origin
		var signed := cam_to_cube.dot(forward)
		if signed < -0.3:
			queue_free()

func _apply_color() -> void:
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	m.metallic = 0.1
	m.roughness = 0.6
	mesh.set_surface_override_material(0, m)

func slice(sword_color: Color) -> void:
	if not alive:
		return

	var diff := Vector3(
		sword_color.r - color.r,
		sword_color.g - color.g,
		sword_color.b - color.b
	)
	if diff.length() < 0.05:
		alive = false
		linear_velocity = Vector3.ZERO

		audio.play()
		await get_tree().create_timer(0.2).timeout
		queue_free()
