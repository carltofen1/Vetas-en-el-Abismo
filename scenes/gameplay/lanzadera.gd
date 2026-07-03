extends Area2D

# =====================================================
# lanzadera.gd
# "Embudo Vertical" — Transporte entre pisos (GDD v6.0)
# Los jugadores NO pueden saltar libremente entre pisos;
# deben usar estas lanzaderas.
# =====================================================

@export var fuerza_impulso: float = -800.0  # Negativo = arriba
@export var cooldown_tiempo: float = 0.2     # Tiempo del efecto visual
@export var es_subida: bool = true            # true = sube, false = baja
@export var equipo_permitido: int = 0         # 0 = Todos, 1 = Rojo, 2 = Azul

func _ready():
	body_entered.connect(_on_body_entered)
	
	# Determinar equipo local
	var mi_equipo = NetworkManager.obtener_equipo(multiplayer.get_unique_id())
	
	if has_node("Label"):
		if es_subida:
			$Label.add_theme_color_override("font_color", Color(0.2, 0.8, 0.4, 1.0))  # Verde = sube
			$Label.text = "▲"
		else:
			$Label.add_theme_color_override("font_color", Color(0.8, 0.4, 0.2, 1.0))  # Naranja = baja
			$Label.text = "▼"
			
	if has_node("FondoMetal"):
		if equipo_permitido == 1:
			$FondoMetal.color = Color(0.8, 0.2, 0.2, 1.0) # Rojo
		elif equipo_permitido == 2:
			$FondoMetal.color = Color(0.2, 0.4, 0.8, 1.0) # Azul
			
	# Si la lanzadera es de un equipo especifico y yo soy del equipo enemigo, aplicar estilo de "Bloqueado"
	if equipo_permitido != 0 and mi_equipo != 0 and equipo_permitido != mi_equipo:
		modulate = Color(0.5, 0.5, 0.5, 0.4) # Aspecto de holograma fantasma / apagado
		if has_node("Label"):
			$Label.text = "X"
			$Label.add_theme_color_override("font_color", Color(0.8, 0.2, 0.2, 1.0)) # X roja


func _on_body_entered(body):
	# Filtrar por equipo si la lanzadera es especifica
	if equipo_permitido != 0:
		if not body.get("team_id") or body.team_id != equipo_permitido:
			return
	
	if body.has_method("recibir_impulso_vertical"):
		var fuerza = fuerza_impulso if es_subida else abs(fuerza_impulso)
		body.recibir_impulso_vertical(fuerza)
		
		# Efecto visual de activación
		if has_node("FondoMetal"):
			$FondoMetal.modulate = Color(1, 1, 1, 0.5)
		
		# Timer para restaurar color
		await get_tree().create_timer(cooldown_tiempo).timeout
		
		if has_node("FondoMetal"):
			$FondoMetal.modulate = Color(1, 1, 1, 1)
