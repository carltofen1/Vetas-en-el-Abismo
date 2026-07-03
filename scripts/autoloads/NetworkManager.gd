extends Node

# NetworkManager.gd - Autoload
# Red P2P con asignacion de equipos
# Jugadores 1,2 -> Equipo ROJO | Jugadores 3,4 -> Equipo AZUL

const PORT = 8910
const MAX_PLAYERS = 4

# Cuantos jugadores se necesitan para iniciar la partida.
# Cambiar a 4 para partida completa.
const JUGADORES_REQUERIDOS = 2

signal players_updated
signal conexion_exitosa
signal conexion_fallida

var players = {}
var orden_conexion: Array = []
var mi_ip: String = ""

func _ready():
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_ok)
	multiplayer.connection_failed.connect(_on_connected_fail)
	mi_ip = _obtener_ip_local()


# Obtiene la IP local de la maquina para mostrarla en el lobby.
# Los demas jugadores en la misma LAN usan esta IP para conectarse.
func _obtener_ip_local() -> String:
	var addresses = IP.get_local_addresses()
	for addr in addresses:
		# Filtramos para quedarnos con IPv4 de red local (192.168.x.x o 10.x.x.x)
		if addr.begins_with("192.168.") or addr.begins_with("10."):
			return addr
	# Si no encontramos una IP de red local, devolvemos loopback
	for addr in addresses:
		if addr.begins_with("172."):
			return addr
	return "127.0.0.1"


func host_game():
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(PORT, MAX_PLAYERS)
	
	if error != OK:
		print("Error al crear servidor: ", error)
		conexion_fallida.emit()
		return
		
	multiplayer.multiplayer_peer = peer
	
	orden_conexion.append(1)
	players[1] = {
		"id": 1,
		"name": "Jugador 1 (Host)",
		"team": Constants.TEAM_RED,
		"order": 1
	}
	print("Servidor creado en puerto ", PORT)
	print("IP local: ", mi_ip)
	print("Esperando jugadores (", players.size(), "/", JUGADORES_REQUERIDOS, ")")
	players_updated.emit()
	conexion_exitosa.emit()


func join_game(ip_address: String = "127.0.0.1"):
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(ip_address, PORT)
	
	if error != OK:
		print("Error al conectar: ", error)
		conexion_fallida.emit()
		return
		
	multiplayer.multiplayer_peer = peer
	print("Conectando a ", ip_address, ":", PORT)


func _asignar_equipo(orden: int) -> int:
	if orden <= 2:
		return Constants.TEAM_RED
	else:
		return Constants.TEAM_BLUE


func _on_player_connected(id):
	var orden = orden_conexion.size() + 1
	orden_conexion.append(id)
	
	var equipo = _asignar_equipo(orden)
	
	players[id] = {
		"id": id,
		"name": "Jugador " + str(orden),
		"team": equipo,
		"order": orden
	}
	players_updated.emit()
	
	print("Jugador ", id, " conectado -> Equipo ", nombre_equipo(equipo), " (Orden: ", orden, ")")
	print("Jugadores: ", players.size(), "/", JUGADORES_REQUERIDOS)
	
	if multiplayer.is_server():
		# Sincronizar info de equipos a todos
		for pid in players:
			_sync_player_data.rpc(pid, players[pid]["name"], players[pid]["team"], players[pid]["order"])
		
		if players.size() == JUGADORES_REQUERIDOS:
			print("Sala llena. Iniciando partida.")
			# Pequeno delay para que los datos se sincronicen
			await get_tree().create_timer(0.5).timeout
			iniciar_partida_red.rpc()


func _on_player_disconnected(id):
	print("Jugador ", id, " desconectado.")
	orden_conexion.erase(id)
	players.erase(id)
	players_updated.emit()


func _on_connected_ok():
	print("Conexion exitosa al servidor.")
	var my_id = multiplayer.get_unique_id()
	players[my_id] = {"id": my_id, "name": "Yo", "team": 0, "order": 0}
	players_updated.emit()
	conexion_exitosa.emit()


func _on_connected_fail():
	print("Fallo la conexion. Verificar IP y que el host este activo.")
	conexion_fallida.emit()


@rpc("any_peer", "call_local", "reliable")
func _sync_player_data(pid: int, nombre: String, equipo: int, orden: int):
	players[pid] = {
		"id": pid,
		"name": nombre,
		"team": equipo,
		"order": orden
	}
	players_updated.emit()


@rpc("any_peer", "call_local", "reliable")
func iniciar_partida_red():
	get_tree().change_scene_to_file("res://scenes/gameplay/game_scene.tscn")


func iniciar_partida_forzado():
	if multiplayer.is_server():
		iniciar_partida_red.rpc()
func obtener_equipo(player_id: int) -> int:
	if players.has(player_id):
		return players[player_id]["team"]
	return 0


static func nombre_equipo(team: int) -> String:
	match team:
		Constants.TEAM_RED:
			return "ROJO"
		Constants.TEAM_BLUE:
			return "AZUL"
		_:
			return "---"
