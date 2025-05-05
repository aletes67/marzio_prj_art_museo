extends CharacterBody3D

# Velocità di movimento (metri/secondo)
@export var speed = 5.0
# Sensibilità del mouse
@export var mouse_sensitivity = 0.003

@onready var camera = $Camera3D

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	camera.current = true
	
func _unhandled_input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	# Gestione rotazione della telecamera con il mouse
	if event is InputEventMouseMotion:
		# Ruota il Player (asse Y)
		rotate_y(-event.relative.x * mouse_sensitivity)
		# Ruota la telecamera (asse X)
		camera.rotate_x(-event.relative.y * mouse_sensitivity)
		# Limita l'inclinazione verticale (evita ribaltamenti)
		camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)

func _physics_process(_delta):
	# Calcola la direzione del movimento (WASD)
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	# Applica la velocità
	velocity.x = direction.x * speed
	velocity.z = direction.z * speed

	# Muovi il Player e gestisci le collisioni
	move_and_slide()
