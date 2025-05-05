extends WorldEnvironment

func _ready():
	var env = Environment.new()
	
	# Carica il materiale esistente
	var sky_material = preload("res://new_panorama_sky_material.tres")
	
	# Configurazione ambiente
	env.background_mode = Environment.BG_SKY
	env.sky = sky_material
	
	# Impostazioni HDR corrette
	env.tonemap_mode = Environment.TONE_MAPPER_ACES
	env.tonemap_exposure = 2.0  # Valore iniziale più alto
	
	# Applica le impostazioni
	self.environment = env
	
	# Configurazione avanzata HDR (NON usare get_viewport().use_hdr)
	ProjectSettings.set_setting("rendering/viewport/hdr", true)
	
	# Verifica finale
	print("HDR abilitato:", ProjectSettings.get_setting("rendering/viewport/hdr"))
