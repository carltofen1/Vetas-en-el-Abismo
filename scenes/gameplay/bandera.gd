extends Area2D

# Bandera — Zona de captura progresiva (Rey de la Colina)

@export var piso_id: int = 0
@export var equipo_inicial: int = 0
@export var imagen_roja: Texture2D
@export var imagen_azul: Texture2D
@export var imagen_neutral: Texture2D

var equipo_actual: int = 0
var progreso_captura: float = 0.0
var equipo_capturando: int = 0
var tiempo_curacion: float = 0.0

@onready var sprite = $BanderaSprite
@onready var barra_captura: ProgressBar = null

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	equipo_actual = equipo_inicial
	actualizar_visual(equipo_actual)
	_crear_barra_captura()
	add_to_group("Banderas")


func _crear_barra_captura():
	barra_captura = ProgressBar.new()
	barra_captura.min_value = 0.0
	barra_captura.max_value = 1.0
	barra_captura.value = 0.0
	barra_captura.show_percentage = false
	barra_captura.size = Vector2(100, 10)
	barra_captura.position = Vector2(-50, -60)
	barra_captura.visible = false
	add_child(barra_captura)


func _process(delta):
	if not multiplayer.is_server():
		return
	
	var jugadores_rojo: int = 0
	var jugadores_azul: int = 0
	
	for body in get_overlapping_bodies():
		if body.has_method("recibir_dano") and body.esta_vivo:
			var eq = _obtener_equipo(body)
			if eq == Constants.TEAM_RED:
				jugadores_rojo += 1
			elif eq == Constants.TEAM_BLUE:
				jugadores_azul += 1
	
	# Contestada: ambos equipos presentes, no avanza
	if jugadores_rojo > 0 and jugadores_azul > 0:
		actualizar_barra.rpc(progreso_captura, 0, true)
		return
	
	var equipo_presente = 0
	if jugadores_rojo > 0:
		equipo_presente = Constants.TEAM_RED
	elif jugadores_azul > 0:
		equipo_presente = Constants.TEAM_BLUE
	
	if equipo_presente > 0 and equipo_presente != equipo_actual:
		var tiempo_necesario = Constants.CAPTURE_TIME_NEUTRAL if equipo_actual == 0 else Constants.CAPTURE_TIME_ENEMY
		
		if equipo_capturando != equipo_presente:
			equipo_capturando = equipo_presente
			progreso_captura = 0.0
		
		progreso_captura += delta / tiempo_necesario
		
		if progreso_captura >= 1.0:
			progreso_captura = 0.0
			equipo_capturando = 0
			confirmar_captura.rpc(equipo_presente)
		else:
			actualizar_barra.rpc(progreso_captura, equipo_presente, false)
	elif equipo_presente == 0 and progreso_captura > 0:
		progreso_captura -= delta * 0.5
		progreso_captura = max(progreso_captura, 0.0)
		if progreso_captura <= 0:
			equipo_capturando = 0
		actualizar_barra.rpc(progreso_captura, equipo_capturando, false)
	else:
		actualizar_barra.rpc(0.0, 0, false)
	
	# Curacion en territorio propio
	if equipo_actual != 0:
		tiempo_curacion += delta
		if tiempo_curacion >= 1.0:
			tiempo_curacion = 0.0
			for body in get_overlapping_bodies():
				if body.has_method("recibir_curacion") and body.esta_vivo:
					if _obtener_equipo(body) == equipo_actual:
						body.recibir_curacion.rpc(Constants.CAPTURE_HEAL_PER_SECOND)


func _obtener_equipo(body) -> int:
	if body.has_method("recibir_dano"):
		return body.team_id
	return 0


@rpc("any_peer", "call_local", "reliable")
func confirmar_captura(nuevo_equipo: int):
	equipo_actual = nuevo_equipo
	progreso_captura = 0.0
	equipo_capturando = 0
	actualizar_visual(equipo_actual)
	
	if barra_captura:
		barra_captura.visible = false
	
	if multiplayer.is_server():
		var game_scene = get_tree().current_scene
		if game_scene.has_method("on_piso_capturado"):
			game_scene.on_piso_capturado(piso_id, nuevo_equipo)


@rpc("any_peer", "call_local", "unreliable")
func actualizar_barra(progreso: float, equipo: int, contestada: bool):
	progreso_captura = progreso
	if barra_captura:
		barra_captura.value = progreso
		barra_captura.visible = progreso > 0.0
		if contestada:
			barra_captura.modulate = Color(1.0, 1.0, 0.0)
		elif equipo == Constants.TEAM_RED:
			barra_captura.modulate = Constants.TEAM_RED_COLOR
		elif equipo == Constants.TEAM_BLUE:
			barra_captura.modulate = Constants.TEAM_BLUE_COLOR


func actualizar_visual(equipo: int):
	if not sprite:
		return
	if equipo == Constants.TEAM_RED:
		if imagen_roja:
			sprite.texture = imagen_roja
		sprite.modulate = Constants.TEAM_RED_COLOR
	elif equipo == Constants.TEAM_BLUE:
		if imagen_azul:
			sprite.texture = imagen_azul
		sprite.modulate = Constants.TEAM_BLUE_COLOR
	else:
		if imagen_neutral:
			sprite.texture = imagen_neutral
		sprite.modulate = Constants.TEAM_NEUTRAL_COLOR


func _on_body_entered(_body):
	pass

func _on_body_exited(_body):
	pass
