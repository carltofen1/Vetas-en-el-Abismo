extends CharacterBody2D

# Personaje principal — Sistema porcentual 0-100%

@export var base_speed: float = Constants.PLAYER_SPEED
@export var base_jump_velocity: float = Constants.PLAYER_JUMP_FORCE
@export var player_id: int = 1

# Estado de combate
var porcentaje_dano: float = 0.0
var esta_vivo: bool = true
var timer_respawn: float = 0.0

# Movimiento
var max_jumps: int = Constants.MAX_JUMPS
var jumps_made: int = 0
var dash_speed: float = Constants.DASH_SPEED
var dash_duration: float = Constants.DASH_DURATION
var dash_timer: float = 0.0
var is_dashing: bool = false
var has_dashed_in_air: bool = false
var knockback: Vector2 = Vector2.ZERO

# Inventario
var minerales: int = 0
var max_minerales: int = Constants.PLAYER_INVENTORY_MAX
var en_zona_base: bool = false

# Equipo (1=Rojo, 2=Azul)
var team_id: int = 0

# Mejoras de crafteo
var tiene_botas: bool = false
var tiene_guantes: bool = false
var tiene_casco: bool = false
var tiene_dash_mejorado: bool = false
var tiene_salto_extra: bool = false
var bonus_dano: float = 0.0

# Stats de partida
var kills: int = 0
var muertes: int = 0
var minerales_totales_recogidos: int = 0

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

signal inventario_actualizado(cantidad: int, maximo: int)
signal porcentaje_actualizado(porcentaje: float)
signal jugador_murio(player_id: int, team_id: int)
signal jugador_revivio(player_id: int)

const SPAWN_EQUIPO_ROJO: Vector2 = Vector2(200, 750)
const SPAWN_EQUIPO_AZUL: Vector2 = Vector2(1720, 750)


func _ready():
	if NetworkManager.players.has(player_id):
		var player_data = NetworkManager.players[player_id]
		if player_data.has("team"):
			team_id = player_data["team"]
	
	# Color segun equipo
	if team_id == Constants.TEAM_RED:
		$Sprite2D.modulate = Constants.TEAM_RED_COLOR
	elif team_id == Constants.TEAM_BLUE:
		$Sprite2D.modulate = Constants.TEAM_BLUE_COLOR
	
	# Solo configuramos HUD y camara para nuestro personaje
	if player_id == multiplayer.get_unique_id():
		if has_node("HUD"):
			$HUD.conectar_jugador(self)
		if has_node("Sprite2D/Camera2D"):
			$Sprite2D/Camera2D.make_current()
	else:
		if has_node("HUD"):
			$HUD.queue_free()
		if has_node("Sprite2D/Camera2D"):
			$Sprite2D/Camera2D.queue_free()


func _physics_process(delta):
	if not esta_vivo:
		timer_respawn -= delta
		if timer_respawn <= 0:
			ejecutar_respawn()
		return
	
	if is_on_floor():
		jumps_made = 0
		has_dashed_in_air = false
	else:
		velocity.y += gravity * delta

	var direction = 0.0

	if player_id == multiplayer.get_unique_id():
		
		# Bajar de plataforma
		if Input.is_action_pressed("ui_down") and Input.is_action_just_pressed("jump"):
			set_collision_mask_value(1, false)
			await get_tree().create_timer(0.2).timeout
			set_collision_mask_value(1, true)
		elif Input.is_action_just_pressed("jump") and jumps_made < max_jumps:
			velocity.y = base_jump_velocity
			jumps_made += 1
		
		if Input.is_action_just_pressed("dash") and not is_dashing and not has_dashed_in_air:
			is_dashing = true
			dash_timer = dash_duration
			if not is_on_floor():
				has_dashed_in_air = true
			
		if Input.is_action_just_pressed("attack"):
			var mi_direccion = -1 if $Sprite2D.flip_h else 1
			for cuerpo in $HitboxAtaque.get_overlapping_bodies():
				if cuerpo != self and cuerpo.has_method("recibir_dano"):
					var dano = CombatSystem.calcular_dano(bonus_dano)
					cuerpo.recibir_dano.rpc(dano, mi_direccion, player_id)

		if Input.is_action_just_pressed("interact"):
			if en_zona_base:
				if has_node("HUD"):
					$HUD.abrir_cerrar_tienda()

		if Input.is_action_just_pressed("ui_cancel"):
			if has_node("HUD"):
				$HUD.toggle_pausa()

		direction = Input.get_axis("move_left", "move_right")

	# Movimiento y knockback
	if is_dashing:
		dash_timer -= delta
		if dash_timer <= 0:
			is_dashing = false
		var dash_dir = -1 if $Sprite2D.flip_h else 1
		velocity.x = dash_dir * dash_speed
		velocity.y = 0
	elif knockback != Vector2.ZERO:
		velocity.x = knockback.x
		knockback = knockback.move_toward(Vector2.ZERO, 2000 * delta)
	else:
		if direction != 0:
			velocity.x = direction * base_speed
			$Sprite2D.flip_h = direction < 0
			if direction < 0:
				$HitboxAtaque.position.x = -abs($HitboxAtaque.position.x)
			else:
				$HitboxAtaque.position.x = abs($HitboxAtaque.position.x)
		else:
			velocity.x = move_toward(velocity.x, 0, base_speed)

	move_and_slide()


# --- Combate porcentual ---

@rpc("any_peer", "call_local", "reliable")
func recibir_dano(cantidad: float, direccion_golpe: int, atacante_id: int = 0):
	if not esta_vivo:
		return
	
	porcentaje_dano += cantidad
	porcentaje_dano = min(porcentaje_dano, Constants.PLAYER_MAX_DAMAGE_PERCENT)
	
	var kb = CombatSystem.calcular_knockback(porcentaje_dano, direccion_golpe, 0.0)
	kb = CombatSystem.aplicar_reduccion_kb(kb, tiene_casco)
	knockback = kb
	velocity.y = knockback.y
	
	porcentaje_actualizado.emit(porcentaje_dano)
	if has_node("HUD/Interface/HealthBar"):
		get_node("HUD/Interface/HealthBar").value = porcentaje_dano
	
	if CombatSystem.esta_muerto(porcentaje_dano):
		morir(atacante_id)


func morir(atacante_id: int = 0):
	esta_vivo = false
	muertes += 1
	
	var minerales_a_dropear = CombatSystem.calcular_mineral_drop(minerales)
	if minerales_a_dropear > 0:
		minerales -= minerales_a_dropear
		inventario_actualizado.emit(minerales, max_minerales)
		if multiplayer.is_server():
			_generar_mineral_drops(minerales_a_dropear)
		else:
			_generar_mineral_drops.rpc_id(1, minerales_a_dropear)
	
	if atacante_id > 0:
		var atacante_node = get_parent().get_node_or_null(str(atacante_id))
		if atacante_node and atacante_node.has_method("registrar_kill_propia"):
			atacante_node.registrar_kill_propia.rpc()
	
	jugador_murio.emit(player_id, team_id)
	
	visible = false
	set_physics_process(false)
	timer_respawn = Constants.PLAYER_RESPAWN_TIME
	set_physics_process(true)


@rpc("any_peer", "call_local", "reliable")
func registrar_kill_propia():
	kills += 1


func ejecutar_respawn():
	esta_vivo = true
	porcentaje_dano = 0.0
	velocity = Vector2.ZERO
	is_dashing = false
	has_dashed_in_air = false
	knockback = Vector2.ZERO
	visible = true
	
	if team_id == Constants.TEAM_RED:
		position = SPAWN_EQUIPO_ROJO
	elif team_id == Constants.TEAM_BLUE:
		position = SPAWN_EQUIPO_AZUL
	else:
		position = Vector2(960, -150)
	
	porcentaje_actualizado.emit(porcentaje_dano)
	if has_node("HUD/Interface/HealthBar"):
		get_node("HUD/Interface/HealthBar").value = 0
	
	jugador_revivio.emit(player_id)


@rpc("any_peer", "call_local", "reliable")
func _generar_mineral_drops(cantidad: int):
	if not multiplayer.is_server():
		return
	var mineral_scene = preload("res://scenes/gameplay/mineral.tscn")
	for i in range(cantidad):
		var mineral = mineral_scene.instantiate()
		mineral.position = position + Vector2(randf_range(-50, 50), -20)
		get_tree().current_scene.add_child(mineral)


# --- Inventario ---

func recoger_mineral(valor: int = 1):
	if minerales + valor <= max_minerales:
		minerales += valor
		minerales_totales_recogidos += valor
		inventario_actualizado.emit(minerales, max_minerales)
		return true
	elif minerales < max_minerales:
		var espacio = max_minerales - minerales
		minerales = max_minerales
		minerales_totales_recogidos += espacio
		inventario_actualizado.emit(minerales, max_minerales)
		return true
	return false


func set_zona_base(estado: bool):
	en_zona_base = estado
	if not en_zona_base:
		if has_node("HUD"):
			$HUD.cerrar_tienda()


func comprar_item(costo: int) -> bool:
	if minerales >= costo:
		minerales -= costo
		inventario_actualizado.emit(minerales, max_minerales)
		return true
	return false


# --- Mejoras ---

func aplicar_botas():
	if tiene_botas:
		return
	tiene_botas = true
	base_speed += Constants.ITEM_BOTAS_SPEED_BONUS

func aplicar_guantes():
	if tiene_guantes:
		return
	tiene_guantes = true
	bonus_dano += Constants.ITEM_GUANTES_DAMAGE_BONUS

func aplicar_casco():
	if tiene_casco:
		return
	tiene_casco = true

func aplicar_dash_mejorado():
	if tiene_dash_mejorado:
		return
	tiene_dash_mejorado = true
	dash_duration += Constants.ITEM_DASH_DURATION_BONUS

func aplicar_salto_extra():
	if tiene_salto_extra:
		return
	tiene_salto_extra = true
	max_jumps += Constants.ITEM_SALTO_EXTRA


# --- Curacion en territorio propio ---

@rpc("any_peer", "call_local", "reliable")
func recibir_curacion(cantidad: float):
	if not esta_vivo:
		return
	if porcentaje_dano > 0:
		porcentaje_dano -= cantidad
		if porcentaje_dano < 0:
			porcentaje_dano = 0
		porcentaje_actualizado.emit(porcentaje_dano)
		if has_node("HUD/Interface/HealthBar"):
			get_node("HUD/Interface/HealthBar").value = porcentaje_dano


# --- Lanzaderas ---

func recibir_impulso_vertical(fuerza: float):
	if player_id == multiplayer.get_unique_id():
		velocity.y = fuerza
		jumps_made = 0
		has_dashed_in_air = false
		if fuerza > 0:
			set_collision_mask_value(1, false)
			await get_tree().create_timer(0.1).timeout
			set_collision_mask_value(1, true)
