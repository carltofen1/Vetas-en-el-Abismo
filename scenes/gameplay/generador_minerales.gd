extends Node2D

# =====================================================
# generador_minerales.gd
# Genera minerales con soporte para tiers (GDD v6.0)
# =====================================================

var mineral_scene = preload("res://scenes/gameplay/mineral.tscn")

@export var tier: int = 1  # Qué tier de mineral genera (1, 2 o 3)
@export var rango_spawn_x: float = 60.0  # Rango horizontal de aparición

func _ready():
	# Configurar timer según tier
	var tiempo_respawn: float
	match tier:
		1:
			tiempo_respawn = Constants.MINERAL_TIER1_RESPAWN
		2:
			tiempo_respawn = Constants.MINERAL_TIER2_RESPAWN
		3:
			tiempo_respawn = Constants.MINERAL_TIER3_RESPAWN
		_:
			tiempo_respawn = Constants.MINERAL_TIER1_RESPAWN
	
	$Timer.wait_time = tiempo_respawn
	$Timer.timeout.connect(_on_timer_timeout)
	
	# Solo el servidor genera minerales
	if multiplayer.is_server():
		$Timer.start()
	else:
		$Timer.stop()

func _on_timer_timeout():
	if multiplayer.is_server():
		var nuevo_mineral = mineral_scene.instantiate()
		nuevo_mineral.tier = tier
		nuevo_mineral.position = global_position + Vector2(randf_range(-rango_spawn_x, rango_spawn_x), 0)
		get_tree().current_scene.add_child(nuevo_mineral)
