extends MeshInstance3D

@export var info_testo: String = "Informazioni su questo quadro."
@export var popup_scene: PackedScene = preload("res://popup/cubo9_iniz.tscn")
@onready var quadro_mesh := self

var default_material : StandardMaterial3D
var highlight_material := StandardMaterial3D.new()
func _ready():
	# Backup materiale originale
	default_material = quadro_mesh.get_active_material(0)
	
		# Crea highlight (giallo)
	highlight_material.albedo_color = Color(1, 1, 0, 0.3)  # giallo semitrasparente
	highlight_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	highlight_material.blend_mode = BaseMaterial3D.BLEND_MODE_MIX
	highlight_material.depth_draw_mode = BaseMaterial3D.DEPTH_DRAW_ALWAYS
	highlight_material.flags_transparent = true	
	
	# Crea l'area cliccabile
	var area := Area3D.new()
	add_child(area)
	area.owner = owner

	var shape := CollisionShape3D.new()
	area.add_child(shape)
	shape.owner = owner

	var aabb := get_aabb()
	var box := BoxShape3D.new()
	box.size = Vector3(1, 1, 0.3)  # sottile, fronte al quadro
	shape.shape = box
	area.transform.origin = Vector3(0, 0, 0.3)
	#area.global_transform.origin = global_transform.origin + Vector3(0, aabb.size.y * 0.5, 0)
	
	area.input_ray_pickable = true
	area.connect("input_event", Callable(self, "_on_click"))
	# segnali hover
	area.connect("mouse_entered", Callable(self, "_on_mouse_enter"))
	area.connect("mouse_exited", Callable(self, "_on_mouse_exit"))
	
	
func _on_click(camera, event, position, normal, shape_idx):
	var player = get_tree().get_current_scene().get_node_or_null("player")
	if player and global_transform.origin.distance_to(player.global_transform.origin) > 3.0:
		return  # troppo lontano per interagire
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var popup := popup_scene.instantiate()
		get_tree().current_scene.add_child(popup)
		popup.get_node("Label").text = info_testo
		popup.popup_centered()
		print("Hai cliccato su:", name)

func _on_mouse_enter():
	quadro_mesh.set_surface_override_material(0, highlight_material)

func _on_mouse_exit():
	quadro_mesh.set_surface_override_material(0, default_material)
