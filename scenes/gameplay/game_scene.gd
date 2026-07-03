extends Node2D

# =====================================================
# game_scene.gd
# Escena principal de partida — Mapa "La Veta Superficial"
# GDD v6.0: 4 pisos, Rey de la Colina, timer 10min
# =====================================================

@onready var game_timer = $GameTimer

var player_scene = preload("res://scenes/gameplay/personaje.tscn")
var ultimo_segundo = -1

# --- Sistema de Dominación ---
var domination: DominationManager = DominationManager.new()
var partida_terminada: bool = false

# Spawn points por equipo
const SPAWNS_ROJO: Array = [Vector2(200, 750), Vector2(300, 750)]
const SPAWNS_AZUL: Array = [Vector2(1620, 750), Vector2(1720, 750)]
var spawn_rojo_index: int = 0
var spawn_azul_index: int = 0


func _ready():
	# Conectar señales de dominación
	domination.victoria_dominacion.connect(_on_victoria_dominacion)
	domination.piso_capturado.connect(_on_piso_capturado_dm)
	
	if multiplayer.is_server():
		# Spawnar personajes para todos los jugadores conectados
		for player_id in NetworkManager.players:
			add_player_character(player_id)
		
		multiplayer.peer_connected.connect(add_player_character)
		
		# Iniciar timer de partida
		game_timer.wait_time = Constants.MATCH_DURATION
		game_timer.one_shot = true
		game_timer.start()
		game_timer.timeout.connect(_on_game_timeout)
	
	print("=== PARTIDA INICIADA: La Veta Superficial ===")
	print("Equipo ROJO vs Equipo AZUL — 10 minutos — ¡Dominen los 4 pisos!")


func _process(delta):
	if partida_terminada:
		return
	
	if multiplayer.is_server():
		# Actualizar tiempo en las pantallas de todos
		var tiempo_restante = int(game_timer.time_left)
		if tiempo_restante != ultimo_segundo:
			ultimo_segundo = tiempo_restante
			actualizar_tiempo.rpc(tiempo_restante)
		
		# Acumular tiempo de dominación
		domination.acumular_tiempo(delta)


func add_player_character(id):
	var nuevo_personaje = player_scene.instantiate()
	nuevo_personaje.player_id = id
	nuevo_personaje.name = str(id)
	
	# Asignar equipo
	var equipo = NetworkManager.obtener_equipo(id)
	nuevo_personaje.team_id = equipo
	
	# Posición de spawn según equipo
	if equipo == Constants.TEAM_RED:
		nuevo_personaje.position = SPAWNS_ROJO[spawn_rojo_index % SPAWNS_ROJO.size()]
		spawn_rojo_index += 1
	elif equipo == Constants.TEAM_BLUE:
		nuevo_personaje.position = SPAWNS_AZUL[spawn_azul_index % SPAWNS_AZUL.size()]
		spawn_azul_index += 1
	else:
		nuevo_personaje.position = Vector2(960, 750)
	
	nuevo_personaje.get_node("MultiplayerSynchronizer").set_multiplayer_authority(id)
	add_child(nuevo_personaje)
	
	var equipo_nombre = NetworkManager.nombre_equipo(equipo)
	print("Jugador ", id, " spawneado → Equipo ", equipo_nombre)


# --- CAPTURA DE PISOS ---

func on_piso_capturado(piso_id: int, equipo: int):
	# Llamado desde bandera.gd cuando se captura un piso
	domination.capturar_piso(piso_id, equipo)
	
	var equipo_nombre = NetworkManager.nombre_equipo(equipo)
	notificar_captura.rpc(piso_id, equipo_nombre)
	
	# Actualizar estado de pisos en todos los clientes
	var pisos_rojo = domination.contar_pisos(Constants.TEAM_RED)
	var pisos_azul = domination.contar_pisos(Constants.TEAM_BLUE)
	actualizar_pisos_ui.rpc(pisos_rojo, pisos_azul)


func _on_piso_capturado_dm(piso_id: int, equipo: int):
	pass  # Manejado en on_piso_capturado


func _on_victoria_dominacion(equipo: int):
	if partida_terminada:
		return
	var equipo_nombre = NetworkManager.nombre_equipo(equipo)
	var mensaje = "¡VICTORIA ABSOLUTA! ¡Equipo " + equipo_nombre + " controla los 4 pisos!"
	terminar_partida.rpc(mensaje, equipo)


# --- FIN DE PARTIDA POR TIEMPO ---

func _on_game_timeout():
	if partida_terminada:
		return
	if not multiplayer.is_server():
		return
	
	print("¡Se acabó el tiempo! Calculando resultados...")
	
	var ganador = domination.determinar_ganador()
	var mensaje = ""
	
	if ganador == Constants.TEAM_RED:
		mensaje = "¡El Equipo ROJO gana por dominación!"
	elif ganador == Constants.TEAM_BLUE:
		mensaje = "¡El Equipo AZUL gana por dominación!"
	else:
		mensaje = "¡Empate técnico!"
	
	# Agregar stats al mensaje
	var t_rojo = domination.obtener_tiempo_total(Constants.TEAM_RED)
	var t_azul = domination.obtener_tiempo_total(Constants.TEAM_BLUE)
	var pisos_rojo = domination.contar_pisos(Constants.TEAM_RED)
	var pisos_azul = domination.contar_pisos(Constants.TEAM_BLUE)
	
	mensaje += "\nPisos: ROJO=" + str(pisos_rojo) + " AZUL=" + str(pisos_azul)
	mensaje += "\nTiempo total: ROJO=" + str(int(t_rojo)) + "s AZUL=" + str(int(t_azul)) + "s"
	mensaje += "\nKills: ROJO=" + str(domination.kills_equipo[0]) + " AZUL=" + str(domination.kills_equipo[1])
	
	terminar_partida.rpc(mensaje, ganador)


# --- RPCs ---

@rpc("any_peer", "call_local", "reliable")
func terminar_partida(mensaje_victoria: String, equipo_ganador: int):
	partida_terminada = true
	
	print("\n==================================")
	print("       FIN DE LA PARTIDA          ")
	print(mensaje_victoria)
	print("==================================\n")
	
	# Mostrar pantalla de victoria/derrota en el HUD de cada jugador
	var mi_id = multiplayer.get_unique_id()
	if has_node(str(mi_id)):
		var mi_personaje = get_node(str(mi_id))
		var mi_equipo = mi_personaje.team_id
		
		if has_node(str(mi_id) + "/HUD"):
			var hud = get_node(str(mi_id) + "/HUD")
			if hud.has_method("mostrar_resultado"):
				hud.mostrar_resultado(mensaje_victoria, mi_equipo == equipo_ganador)


@rpc("any_peer", "call_local", "unreliable")
func actualizar_tiempo(tiempo_restante: int):
	var minutos = tiempo_restante / 60
	var segundos = tiempo_restante % 60
	var texto_tiempo = str(minutos).pad_zeros(2) + ":" + str(segundos).pad_zeros(2)
	
	var mi_id = str(multiplayer.get_unique_id())
	if has_node(mi_id):
		var mi_personaje = get_node(mi_id)
		if mi_personaje.has_node("HUD/Interface/TimeLabel"):
			mi_personaje.get_node("HUD/Interface/TimeLabel").text = texto_tiempo


@rpc("any_peer", "call_local", "reliable")
func notificar_captura(piso_id: int, equipo_nombre: String):
	print("¡Piso ", piso_id + 1, " capturado por Equipo ", equipo_nombre, "!")


@rpc("any_peer", "call_local", "unreliable")
func actualizar_pisos_ui(pisos_rojo: int, pisos_azul: int):
	var mi_id = str(multiplayer.get_unique_id())
	if has_node(mi_id):
		var mi_personaje = get_node(mi_id)
		if mi_personaje.has_node("HUD") and mi_personaje.get_node("HUD").has_method("actualizar_pisos"):
			mi_personaje.get_node("HUD").actualizar_pisos(pisos_rojo, pisos_azul)
