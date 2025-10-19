#extends Node3D
#
#@export var sword_color: Color = Color(0.1, 0.2, 0.8)
#func get_sword_color() -> Color:
	#return sword_color
#@export var is_on: bool = true
#
#@onready var hit_area: Area3D = $Area3D
#@onready var beam: MeshInstance3D = $Beam
#
#func _ready():
	#_update_enabled()
	#hit_area.body_entered.connect(_on_body_entered)
	#hit_area.area_entered.connect(_on_area_entered)
#
#func set_on(v: bool) -> void:
	#is_on = v
	#_update_enabled()
#
#func _update_enabled() -> void:
	#if hit_area:
		#hit_area.monitoring = is_on
		#hit_area.monitorable = is_on
	#if beam:
		#beam.visible = is_on
		#if is_on:
			#var mat := beam.get_active_material(0)
			#if mat == null:
				#mat = StandardMaterial3D.new()
				#beam.set_surface_override_material(0, mat)
			#mat.albedo_color = sword_color
#
#func _slice(n: Node) -> void:
	#if !is_on: return
	#if n and n.has_method("try_slice"):
		#var ok: bool = n.call("try_slice", sword_color)
		#if ok:
			#var sfx := get_tree().current_scene.get_node_or_null("Game/HitSFX")
			#if sfx: sfx.play()
#
#func _on_body_entered(body: Node) -> void: _slice(body)
#func _on_area_entered(area: Area3D) -> void: _slice(area)
#
#
#func _on_area_3d_body_entered(body: Node3D) -> void:
	#if not is_on:
		#return
	#if body and body.has_method("slice"):
		#body.slice(sword_color) # Replace with function body.
#
#
#func on_left_controller_button_pressed(name: String) -> void:
	#if name == "primary_click":
		#set_on(not is_on)  # Replace with function body.
#
#
#func on_right_controller_button_pressed(name: String) -> void:
	#if name == "primary_click":
		#set_on(not is_on) # Replace with function body.










extends Node3D

@export var sword_color: Color = Color(0.1, 0.2, 0.8) 
func get_sword_color() -> Color:
	return sword_color

@export var is_on: bool = false 

@onready var hit_area: Area3D = $Area3D
#@onready var beam: MeshInstance3D = $Beam
@onready var shape: CollisionShape3D = $Area3D/CollisionShape3D
@onready var beam: MeshInstance3D = $Beam

var _saved_layer := 0
var _saved_mask := 0
var _mat: StandardMaterial3D

func _ready():
	_saved_layer = hit_area.collision_layer
	_saved_mask = hit_area.collision_mask

	var m := beam.get_active_material(0)
	if m == null or !(m is StandardMaterial3D):
		m = StandardMaterial3D.new()
	else:
		m = m.duplicate()
	m.resource_local_to_scene = true
	beam.set_surface_override_material(0, m)
	_mat = m
	_mat.albedo_color = sword_color

	_update_enabled()

	if not hit_area.body_entered.is_connected(_on_body_entered):
		hit_area.body_entered.connect(_on_body_entered)
	if not hit_area.area_entered.is_connected(_on_area_entered):
		hit_area.area_entered.connect(_on_area_entered)

func set_on(v: bool) -> void:
	is_on = v
	_update_enabled()

func _update_enabled() -> void:
	if beam:
		beam.visible = is_on

	if hit_area:
		hit_area.monitoring = is_on
		hit_area.monitorable = is_on
		if is_on:
			hit_area.collision_layer = _saved_layer
			hit_area.collision_mask = _saved_mask
		else:
			hit_area.collision_layer = 0
			hit_area.collision_mask = 0

	if shape:
		shape.disabled = not is_on

	if _mat:
		_mat.albedo_color = sword_color
		
	if is_on:
		var mat := StandardMaterial3D.new()
		mat.albedo_color = sword_color
		mat.emission_enabled = true
		mat.emission = sword_color
		mat.emission_energy_multiplier = 6.0
		mat.roughness = 0.2
		mat.metallic = 0.1
		beam.set_surface_override_material(0, mat)

func _slice(n: Node) -> void:
	if !is_on:
		return
	if n and n.has_method("try_slice"):
		var ok: bool = n.call("try_slice", sword_color)
		if ok:
			var sfx := get_tree().current_scene.get_node_or_null("Game/HitSFX")
			if sfx: sfx.play()
	elif n and n.has_method("slice"):
		n.slice(sword_color)

func _on_body_entered(body: Node) -> void:
	_slice(body)

func _on_area_entered(area: Area3D) -> void:
	_slice(area)

func _on_left_controller_button_pressed(name: String) -> void:
	if name == "ax_button" or name == "primary_click":
		set_on(not is_on)

func _on_right_controller_button_pressed(name: String) -> void:
	if name == "ax_button" or name == "primary_click":
		set_on(not is_on)
		
	var mat := StandardMaterial3D.new()
	mat.emission_enabled = true
	mat.emission = sword_color        # same color as saber
	mat.emission_energy_multiplier = 5.0
	beam.set_surface_override_material(0, mat)
