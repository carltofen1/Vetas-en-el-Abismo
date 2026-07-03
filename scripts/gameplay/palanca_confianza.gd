extends Node

# =====================================================
# palanca_confianza.gd
# Sistema de economía compartida/dividida (GDD v6.0)
# Los jugadores deciden en la base si comparten minerales
# =====================================================

class_name PalancaConfianza

enum Modo { DIVIDIDO, COMPARTIDO }

var modo_actual: Modo = Modo.DIVIDIDO
var pool_compartido: int = 0
var voto_jugador_1: int = -1  # -1 = no ha votado, 0 = dividido, 1 = compartido
var voto_jugador_2: int = -1

signal modo_cambiado(nuevo_modo: Modo)
signal pool_actualizado(cantidad: int)


func resetear():
	modo_actual = Modo.DIVIDIDO
	pool_compartido = 0
	voto_jugador_1 = -1
	voto_jugador_2 = -1


# Un jugador vota para cambiar el modo.
# slot: 0 = primer jugador del equipo, 1 = segundo jugador del equipo
func votar(slot: int, voto: int) -> void:
	if slot == 0:
		voto_jugador_1 = voto
	elif slot == 1:
		voto_jugador_2 = voto
	
	# Si ambos votaron lo mismo, cambiar modo
	if voto_jugador_1 >= 0 and voto_jugador_2 >= 0:
		if voto_jugador_1 == voto_jugador_2:
			if voto_jugador_1 == 1:
				modo_actual = Modo.COMPARTIDO
			else:
				modo_actual = Modo.DIVIDIDO
			modo_cambiado.emit(modo_actual)
		
		# Resetear votos
		voto_jugador_1 = -1
		voto_jugador_2 = -1


# En modo compartido, depositar minerales al pool.
func depositar(cantidad: int) -> void:
	if modo_actual == Modo.COMPARTIDO:
		pool_compartido += cantidad
		pool_actualizado.emit(pool_compartido)


# En modo compartido, retirar minerales del pool.
func retirar(cantidad: int) -> bool:
	if modo_actual == Modo.COMPARTIDO:
		if pool_compartido >= cantidad:
			pool_compartido -= cantidad
			pool_actualizado.emit(pool_compartido)
			return true
		return false
	return false


func obtener_modo_texto() -> String:
	if modo_actual == Modo.COMPARTIDO:
		return "COMPARTIDO (Pool: " + str(pool_compartido) + ")"
	else:
		return "DIVIDIDO (Individual)"
