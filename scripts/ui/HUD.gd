extends CanvasLayer

# =====================================================
# HUD.gd
# Interfaz durante la partida
# Responsable: Cricko - Semanas 2-3-8
# =====================================================

@onready var health_bar: ProgressBar = $HUD/HealthBar
@onready var timer_label: Label = $HUD/TimerLabel
@onready var platform_status: HBoxContainer = $HUD/PlatformStatus
@onready var notification_label: Label = $HUD/NotificationLabel
@onready var inventory_container: HBoxContainer = $HUD/InventoryContainer

var _notification_timer: float = 0.0
const NOTIFICATION_DURATION: float = 3.0


func _ready() -> void:
	GameManager.match_started.connect(_on_match_started)
	GameManager.platform_captured.connect(_on_platform_captured)
	notification_label.hide()


func _process(delta: float) -> void:
	if GameManager.current_state != GameManager.GameState.PLAYING:
		return

	# Actualizar timer
	GameManager.match_time_remaining -= delta
	_update_timer_display(GameManager.match_time_remaining)

	# Ocultar notificacion despues de un tiempo
	if _notification_timer > 0.0:
		_notification_timer -= delta
		if _notification_timer <= 0.0:
			notification_label.hide()

	# Verificar fin de partida
	if GameManager.match_time_remaining <= 0.0:
		GameManager.match_time_remaining = 0.0
		_resolve_winner()


func update_health(current: float, maximum: float) -> void:
	health_bar.max_value = maximum
	health_bar.value = current


func show_notification(message: String) -> void:
	notification_label.text = message
	notification_label.show()
	_notification_timer = NOTIFICATION_DURATION


func _update_timer_display(seconds: float) -> void:
	var mins: int = int(seconds) / 60
	var secs: int = int(seconds) % 60
	timer_label.text = "%02d:%02d" % [mins, secs]


func _on_match_started() -> void:
	show_notification("Partida iniciada!")


func _on_platform_captured(platform_id: int, team: int) -> void:
	var team_name: String = "Equipo Azul" if team == 0 else "Equipo Rojo"
	show_notification("Plataforma %d conquistada por %s" % [platform_id + 1, team_name])


func _resolve_winner() -> void:
	# Logica de desempate en semana 8
	var scores = GameManager.team_scores
	if scores[0] > scores[1]:
		GameManager.end_match(0)
	elif scores[1] > scores[0]:
		GameManager.end_match(1)
	else:
		# TODO Semana 8: desempate por tiempo en plataforma rival
		GameManager.end_match(-1)  # -1 = empate
