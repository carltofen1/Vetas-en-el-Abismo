extends Node

# =====================================================
# GameManager.gd - Autoload / Singleton
# Estado global de la partida — GDD v6.0
# Responsable: Cricko (Game Loop)
# Patrick conecta el estado de red aqui
# =====================================================

enum GameState { MENU, LOBBY, PLAYING, GAME_OVER }

var current_state: GameState = GameState.MENU
var match_time_remaining: float = Constants.MATCH_DURATION
var team_scores: Array[int] = [0, 0]  # [equipo_rojo, equipo_azul]

# Senales - otros sistemas se conectan aqui
signal game_state_changed(new_state: GameState)
signal match_started()
signal match_ended(winning_team: int)
signal platform_captured(platform_id: int, team: int)


func set_game_state(new_state: GameState) -> void:
	current_state = new_state
	game_state_changed.emit(new_state)


func start_match() -> void:
	match_time_remaining = Constants.MATCH_DURATION
	team_scores = [0, 0]
	set_game_state(GameState.PLAYING)
	match_started.emit()


func end_match(winning_team: int) -> void:
	set_game_state(GameState.GAME_OVER)
	match_ended.emit(winning_team)


func on_platform_captured(platform_id: int, team: int) -> void:
	platform_captured.emit(platform_id, team)


func reset_to_menu() -> void:
	current_state = GameState.MENU
	match_time_remaining = Constants.MATCH_DURATION
	team_scores = [0, 0]
