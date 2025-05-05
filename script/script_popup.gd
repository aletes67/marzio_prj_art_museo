extends MeshInstance3D

@export var info_testo: String = "Informazioni su questo quadro."
@export var popup_scene: PackedScene = preload("res://popup/cubo9_iniz.tscn")
@onready var quadro_mesh := self
@export var distanza_interazione: float = 4.0

var default_material: StandardMaterial3D
var highlight_material: StandardMaterial3D = StandardMaterial3D.new()
var player: Node3D
var camera: Camera3D

func _ready():
	player = get_tree().get_root().find_child("Player", true, false)
	camera = get_viewport().get_camera_3d()

	# Backup materiale originale
	default_material = quadro_mesh.get_active_material(0)

	# Configura materiale evidenziato
	highlight_material.albedo_color = Color(1, 1, 0, 0.1)
	highlight_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	highlight_material.blend_mode = BaseMaterial3D.BLEND_MODE_MIX
	highlight_material.depth_draw_mode = BaseMaterial3D.DEPTH_DRAW_ALWAYS
	highlight_material.flags_transparent = true	
	highlight_material.next_pass = default_material

	# Crea l'area cliccabile
	var area := Area3D.new()
	add_child(area)
	area.owner = owner
	area.collision_layer = 1
	area.input_ray_pickable = true
	area.connect("input_event", Callable(self, "_on_click"))

	var shape := CollisionShape3D.new()
	area.add_child(shape)
	shape.owner = owner

	var aabb := get_aabb()
	var box := BoxShape3D.new()
	box.size = Vector3(aabb.size.x, aabb.size.y, 0.5)
	shape.shape = box

	# Posiziona Area centrata sull’AABB locale
	var local_center := aabb.position + (aabb.size * 0.5)
	area.transform.origin = local_center


func _on_click(camera, event, position, normal, shape_idx):
	if player and global_transform.origin.distance_to(player.global_transform.origin) > distanza_interazione:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var popup := popup_scene.instantiate()
		get_tree().current_scene.add_child(popup)
		popup.get_node("Label").text = info_testo
		popup.popup_centered()
		print("Hai cliccato su:", name)

func _process(_delta):
	if not player or not camera:
		return

	var mouse_pos = get_viewport().get_mouse_position()
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * 10.0

	var ray_params := PhysicsRayQueryParameters3D.new()
	ray_params.from = from
	ray_params.to = to
	ray_params.collide_with_areas = true

	var result = get_world_3d().direct_space_state.intersect_ray(ray_params)
	if result:
		print("Ray ha colpito:", result.collider.name)
	if result and result.collider.get_parent() == self and global_transform.origin.distance_to(player.global_transform.origin) < distanza_interazione:
		quadro_mesh.set_surface_override_material(0, highlight_material)
	else:
		quadro_mesh.set_surface_override_material(0, default_material)
