extends CanvasLayer

# HUD — Interfaz del jugador durante partida

@onready var inventory_label = $Interface/InventoryLabel
@onready var health_bar = $Interface/HealthBar
@onready var porcentaje_label = $Interface/PorcentajeLabel
@onready var pisos_label = $Interface/PisosLabel
@onready var equipo_label = $Interface/EquipoLabel
@onready var kills_label = $Interface/KillsLabel
@onready var craft_menu = $CraftMenu
@onready var resultado_panel = $ResultadoPanel

var jugador_referencia = null


func _ready():
	if has_node("CraftMenu/BotonBotas"):
		$CraftMenu/BotonBotas.pressed.connect(_on_boton_botas_pressed)
	if has_node("CraftMenu/BotonGuantes"):
		$CraftMenu/BotonGuantes.pressed.connect(_on_boton_guantes_pressed)
	if has_node("CraftMenu/BotonCasco"):
		$CraftMenu/BotonCasco.pressed.connect(_on_boton_casco_pressed)
	if has_node("CraftMenu/BotonDash"):
		$CraftMenu/BotonDash.pressed.connect(_on_boton_dash_pressed)
	if has_node("CraftMenu/BotonSalto"):
		$CraftMenu/BotonSalto.pressed.connect(_on_boton_salto_pressed)
	
	if has_node("ResultadoPanel/BotonMenu"):
		$ResultadoPanel/BotonMenu.pressed.connect(_on_boton_menu_pressed)
	
	if craft_menu:
		craft_menu.visible = false
	if resultado_panel:
		resultado_panel.visible = false
	
	if health_bar:
		health_bar.min_value = 0
		health_bar.max_value = 100
		health_bar.value = 0


func conectar_jugador(personaje):
	jugador_referencia = personaje
	personaje.inventario_actualizado.connect(_on_inventario_actualizado)
	personaje.porcentaje_actualizado.connect(_on_porcentaje_actualizado)
	
	_on_inventario_actualizado(personaje.minerales, personaje.max_minerales)
	_on_porcentaje_actualizado(personaje.porcentaje_dano)
	
	if equipo_label:
		var equipo_nombre = NetworkManager.nombre_equipo(personaje.team_id)
		equipo_label.text = "Equipo: " + equipo_nombre
		if personaje.team_id == Constants.TEAM_RED:
			equipo_label.modulate = Constants.TEAM_RED_COLOR
		elif personaje.team_id == Constants.TEAM_BLUE:
			equipo_label.modulate = Constants.TEAM_BLUE_COLOR


func _on_inventario_actualizado(actual: int, maximo: int):
	if inventory_label:
		inventory_label.text = "Minerales: " + str(actual) + " / " + str(maximo)


func _on_porcentaje_actualizado(porcentaje: float):
	if health_bar:
		health_bar.value = porcentaje
	if porcentaje_label:
		porcentaje_label.text = str(int(porcentaje)) + "%"
		
		# Color gradual segun dano
		if porcentaje < 33:
			if porcentaje_label:
				porcentaje_label.modulate = Color(0.3, 1.0, 0.3)
			if health_bar:
				health_bar.modulate = Color(0.3, 1.0, 0.3)
		elif porcentaje < 66:
			if porcentaje_label:
				porcentaje_label.modulate = Color(1.0, 1.0, 0.3)
			if health_bar:
				health_bar.modulate = Color(1.0, 1.0, 0.3)
		else:
			if porcentaje_label:
				porcentaje_label.modulate = Color(1.0, 0.3, 0.3)
			if health_bar:
				health_bar.modulate = Color(1.0, 0.3, 0.3)


func actualizar_pisos(pisos_rojo: int, pisos_azul: int):
	if pisos_label:
		pisos_label.text = "Pisos: ROJO " + str(pisos_rojo) + " | AZUL " + str(pisos_azul)


# --- Tienda ---

func abrir_cerrar_tienda():
	if craft_menu:
		craft_menu.visible = not craft_menu.visible

func cerrar_tienda():
	if craft_menu:
		craft_menu.visible = false


func _on_boton_botas_pressed():
	if jugador_referencia and not jugador_referencia.tiene_botas:
		if jugador_referencia.comprar_item(Constants.ITEM_BOTAS_COSTO):
			jugador_referencia.aplicar_botas()
			$CraftMenu/BotonBotas.disabled = true
			$CraftMenu/BotonBotas.text = "Botas [Comprado]"

func _on_boton_guantes_pressed():
	if jugador_referencia and not jugador_referencia.tiene_guantes:
		if jugador_referencia.comprar_item(Constants.ITEM_GUANTES_COSTO):
			jugador_referencia.aplicar_guantes()
			$CraftMenu/BotonGuantes.disabled = true
			$CraftMenu/BotonGuantes.text = "Guantes [Comprado]"

func _on_boton_casco_pressed():
	if jugador_referencia and not jugador_referencia.tiene_casco:
		if jugador_referencia.comprar_item(Constants.ITEM_CASCO_COSTO):
			jugador_referencia.aplicar_casco()
			$CraftMenu/BotonCasco.disabled = true
			$CraftMenu/BotonCasco.text = "Casco [Comprado]"

func _on_boton_dash_pressed():
	if jugador_referencia and not jugador_referencia.tiene_dash_mejorado:
		if jugador_referencia.comprar_item(Constants.ITEM_DASH_COSTO):
			jugador_referencia.aplicar_dash_mejorado()
			$CraftMenu/BotonDash.disabled = true
			$CraftMenu/BotonDash.text = "Dash+ [Comprado]"

func _on_boton_salto_pressed():
	if jugador_referencia and not jugador_referencia.tiene_salto_extra:
		if jugador_referencia.comprar_item(Constants.ITEM_SALTO_COSTO):
			jugador_referencia.aplicar_salto_extra()
			$CraftMenu/BotonSalto.disabled = true
			$CraftMenu/BotonSalto.text = "Salto+ [Comprado]"


# --- Pausa ---

func toggle_pausa():
	if craft_menu:
		craft_menu.visible = false


# --- Resultado ---

func mostrar_resultado(mensaje: String, es_victoria: bool):
	if resultado_panel:
		resultado_panel.visible = true
		
		if has_node("ResultadoPanel/TituloLabel"):
			if es_victoria:
				$ResultadoPanel/TituloLabel.text = "VICTORIA"
				$ResultadoPanel/TituloLabel.modulate = Color(1.0, 0.85, 0.2)
			else:
				$ResultadoPanel/TituloLabel.text = "DERROTA"
				$ResultadoPanel/TituloLabel.modulate = Color(0.8, 0.2, 0.2)
		
		if has_node("ResultadoPanel/DetalleLabel"):
			var stats = mensaje
			if jugador_referencia:
				stats += "\n\nEstadisticas:"
				stats += "\nKills: " + str(jugador_referencia.kills)
				stats += "\nMuertes: " + str(jugador_referencia.muertes)
				stats += "\nMinerales recogidos: " + str(jugador_referencia.minerales_totales_recogidos)
			$ResultadoPanel/DetalleLabel.text = stats


func _on_boton_menu_pressed():
	get_tree().change_scene_to_file("res://scenes/UI/MainMenu.tscn")
