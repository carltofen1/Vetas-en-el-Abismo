extends Area2D

# =====================================================
# mineral.gd
# Mineral Espectral — Sistema de 3 tiers (GDD v6.0)
# Tier 1: Azul claro (valor 1), Tier 2: Púrpura (valor 3), Tier 3: Dorado (valor 5)
# =====================================================

@export var tier: int = 1  # 1, 2 o 3

var valor: int = 1

func _ready():
	body_entered.connect(_on_body_entered)
	
	# Configurar valor y color según tier
	match tier:
		1:
			valor = Constants.MINERAL_TIER1_VALUE
			modulate = Constants.MINERAL_TIER1_COLOR
		2:
			valor = Constants.MINERAL_TIER2_VALUE
			modulate = Constants.MINERAL_TIER2_COLOR
		3:
			valor = Constants.MINERAL_TIER3_VALUE
			modulate = Constants.MINERAL_TIER3_COLOR
	
	# Escala visual según tier (más grandes los raros)
	if has_node("Sprite2D"):
		match tier:
			2:
				$Sprite2D.scale *= 1.3
			3:
				$Sprite2D.scale *= 1.6


func _on_body_entered(body):
	if body.has_method("recoger_mineral"):
		# Validacion de autoridad: Solo el peer local procesa la colision
		if body.player_id == multiplayer.get_unique_id():
			var pudo_recoger = body.recoger_mineral(valor)
			
			if pudo_recoger:
				# Solicitar al servidor la eliminacion de la entidad
				destruir_en_servidor.rpc_id(1)


@rpc("any_peer", "call_local", "reliable")
func destruir_en_servidor():
	if multiplayer.is_server():
		queue_free()
