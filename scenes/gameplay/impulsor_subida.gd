extends Area2D

# Fuerza con la que saldremos volando (negativo porque en Godot hacia arriba es menos)
@export var fuerza_impulso = -1200.0 

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	# Si el objeto que nos toca tiene la función para recibir el impulso...
	if body.has_method("recibir_impulso_vertical"):
		# ...¡Lo lanzamos!
		body.recibir_impulso_vertical(fuerza_impulso)
