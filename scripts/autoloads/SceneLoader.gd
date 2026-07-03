extends Node

# =====================================================
# SceneLoader.gd - Autoload
# Carga de escenas centralizada — GDD v6.0
# Responsable: Cricko
# =====================================================

const SCENE_MAIN_MENU = "res://scenes/UI/MainMenu.tscn"
const SCENE_LOBBY     = "res://scenes/network/lobby.tscn"
const SCENE_GAME      = "res://scenes/gameplay/game_scene.tscn"

signal scene_loaded(scene_name: String)


func load_main_menu() -> void:
	GameManager.reset_to_menu()
	get_tree().change_scene_to_file(SCENE_MAIN_MENU)
	scene_loaded.emit("MainMenu")


func load_lobby() -> void:
	GameManager.set_game_state(GameManager.GameState.LOBBY)
	get_tree().change_scene_to_file(SCENE_LOBBY)
	scene_loaded.emit("Lobby")


func load_game() -> void:
	get_tree().change_scene_to_file(SCENE_GAME)
	scene_loaded.emit("GameScene")
