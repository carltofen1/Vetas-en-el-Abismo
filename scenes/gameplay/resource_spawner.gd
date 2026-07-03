extends Node2D

@export var mineral_scene: PackedScene

func _ready():
	# Autoridad de red: Solo el servidor gestiona el spawn de minerales
	# Los clientes desactivan el timer para evitar spawns redundantes o locales
	if multiplayer.is_server():
		$Timer.timeout.connect(_on_timer_timeout)
	else:
		$Timer.stop()

func _on_timer_timeout():
	if mineral_scene:
		var nuevo_mineral = mineral_scene.instantiate()
		var variacion_x = randf_range(-30, 30)
		nuevo_mineral.position = Vector2(variacion_x, 0)
		add_child(nuevo_mineral)
