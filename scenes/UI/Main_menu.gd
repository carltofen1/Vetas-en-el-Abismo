extends Control

# Referencias a nuestros botones
@onready var host_button = $VBoxContainer/HostButton
@onready var join_button = $VBoxContainer/JoinButton

func _ready():
	# Conectamos los clics de los botones a nuestras funciones
	host_button.pressed.connect(_on_host_pressed)
	join_button.pressed.connect(_on_join_pressed)

func _on_host_pressed():
	# Llamamos al Autoload que creaste en el paso anterior
	NetworkManager.host_game()
	# Ocultamos el menú porque ya entramos al juego
	hide()

func _on_join_pressed():
	# Llamamos al Autoload para conectarnos
	NetworkManager.join_game()
	# Ocultamos el menú
	hide()
