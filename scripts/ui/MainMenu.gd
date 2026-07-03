extends Control

# =====================================================
# MainMenu.gd
# Controlador del menu principal
# Responsable: Cricko - Semana 1
# =====================================================

@onready var btn_play: Button = $VBoxContainer/Btn_Play
@onready var btn_options: Button = $VBoxContainer/Btn_Options
@onready var btn_quit: Button = $VBoxContainer/Btn_Quit
@onready var options_panel: Control = null


func _ready() -> void:
	btn_play.pressed.connect(_on_play_pressed)
	btn_options.pressed.connect(_on_options_pressed)
	btn_quit.pressed.connect(_on_quit_pressed)
	if options_panel:
		options_panel.hide()

	# Deshabilitado hasta semana 14
	btn_options.disabled = true


func _on_play_pressed() -> void:
	SceneLoader.load_lobby()


func _on_options_pressed() -> void:
	options_panel.show()


func _on_quit_pressed() -> void:
	get_tree().quit()
