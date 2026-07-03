extends Control

# Lobby — Sala de espera con conexion LAN

func _ready():
	NetworkManager.players_updated.connect(_actualizar_lista)
	NetworkManager.conexion_exitosa.connect(_on_conexion_ok)
	NetworkManager.conexion_fallida.connect(_on_conexion_fail)
	
	# Mostrar la IP local para que los demas se conecten
	$IPLocalLabel.text = "Tu IP (LAN): " + NetworkManager.mi_ip
	
	if has_node("BtnStart"):
		$BtnStart.visible = false


func _on_btn_host_pressed():
	NetworkManager.host_game()


func _on_btn_join_pressed():
	var ip = $IPInput.text.strip_edges()
	if ip == "":
		ip = "127.0.0.1"
	NetworkManager.join_game(ip)


func _on_btn_start_pressed():
	NetworkManager.iniciar_partida_forzado()


func _on_conexion_ok():
	$BtnHost.disabled = true
	$BtnJoin.disabled = true
	$IPInput.editable = false
	$EstadoLabel.text = "Conectado. Esperando jugadores..."
	
	if multiplayer.is_server() and has_node("BtnStart"):
		$BtnStart.visible = true


func _on_conexion_fail():
	$EstadoLabel.text = "Error de conexion. Verificar IP."


func _actualizar_lista():
	var texto = ""
	for pid in NetworkManager.players:
		var data = NetworkManager.players[pid]
		var equipo = NetworkManager.nombre_equipo(data["team"])
		texto += data["name"] + " - Equipo " + equipo + "\n"
	texto += "\n" + str(NetworkManager.players.size()) + "/" + str(NetworkManager.JUGADORES_REQUERIDOS)
	$JugadoresLabel.text = texto
