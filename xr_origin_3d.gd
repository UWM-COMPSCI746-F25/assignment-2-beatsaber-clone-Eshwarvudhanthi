extends XROrigin3D

@export var face_distance: float = 2.0  
@onready var head: XRCamera3D = $XRCamera3D

func _ready() -> void:
	var oxr := XRServer.find_interface("OpenXR")
	if oxr:
		if not oxr.is_connected("pose_recentered", Callable(self, "_on_pose_recentered")):
			oxr.pose_recentered.connect(_on_pose_recentered)
	else:
		print("[XR] OpenXR interface not active (desktop/editor run).")

func _on_pose_recentered() -> void:
	var cube := _nearest_cube()
	if cube == null:
		print("[XR] No cubes found to face.")
		return

	var cube_pos := cube.global_transform.origin
	var head_pos := head.global_transform.origin

	var to_cube := cube_pos - head_pos
	to_cube.y = 0.0
	if to_cube.length() < 0.001:
		to_cube = -head.global_transform.basis.z 

	var target_dir := to_cube.normalized()

	var current_forward := (-head.global_transform.basis.z)
	current_forward.y = 0.0
	current_forward = current_forward.normalized()
	var yaw := current_forward.signed_angle_to(target_dir, Vector3.UP)
	rotate_y(yaw)

	var desired_head := cube_pos - (target_dir * face_distance)

	var now_head := head.global_transform.origin  
	var delta := desired_head - now_head
	global_translate(delta)

	print("[XR] Recentered to face cube at ", cube_pos)

func _nearest_cube() -> Node3D:
	var nearest: Node3D = null
	var best_d2: float = 1e30                   

	var p: Vector3 = $XROrigin3D/XRCamera3D.global_transform.origin

	for c in get_tree().get_nodes_in_group("cubes"):
		if c is Node3D:
			var d2: float = p.distance_squared_to(c.global_transform.origin)
			if d2 < best_d2:
				best_d2 = d2
				nearest = c

	return nearest
