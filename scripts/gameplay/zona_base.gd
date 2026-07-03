extends Area2D

func _ready():
	# Registrar señales de entrada y salida de area
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	# Validar si el cuerpo posee funcionalidad de base
	if body.has_method("set_zona_base"):
		# Validacion de autoridad: Solo actualizar al cliente local
		if body.player_id == multiplayer.get_unique_id():
			body.set_zona_base(true)

func _on_body_exited(body):
	if body.has_method("set_zona_base"):
		if body.player_id == multiplayer.get_unique_id():
			body.set_zona_base(false)
