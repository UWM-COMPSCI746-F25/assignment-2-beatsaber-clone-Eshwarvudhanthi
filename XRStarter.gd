extends XROrigin3D

@export var face_distance: float = 2.0   
@onready var head: XRCamera3D = $XRCamera3D

func _ready():
	var xr_interface = XRServer.find_interface("OpenXR")
	if xr_interface and xr_interface.initialize():
		get_viewport().use_xr = true
		print("OpenXR initialized")
	else:
		print("OpenXR not available")
	var iface := XRServer.primary_interface
	if iface and iface.has_signal("pose_recentered"):
		if not iface.pose_recentered.is_connected(_on_pose_recentered):
			iface.pose_recentered.connect(_on_pose_recentered)
		print("[XR] pose_recentered connected on primary_interface")
		return

	var oxr := XRServer.find_interface("OpenXR")
	if oxr and oxr.has_signal("pose_recentered"):
		if not oxr.pose_recentered.is_connected(_on_pose_recentered):
			oxr.pose_recentered.connect(_on_pose_recentered)
		print("[XR] pose_recentered connected on find_interface('OpenXR')")
	else:
		print("[XR] OpenXR interface not active; signal won't fire on desktop")

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
	var best_d2 := INF
	var p := head.global_transform.origin
	for c in get_tree().get_nodes_in_group("cubes"):
		if c is Node3D:
			var d2: float = p.distance_squared_to(c.global_transform.origin)
			if d2 < best_d2:
				best_d2 = d2
				nearest = c
	return nearest
