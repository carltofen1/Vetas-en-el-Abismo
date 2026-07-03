extends Node

# =====================================================
# DominationManager.gd
# Sistema "Rey de la Colina" — Captura de 4 pisos
# Basado en GDD v6.0
# =====================================================

class_name DominationManager

# --- Estado de cada piso ---
# Formato: { piso_id: { equipo: 0/1/2, tiempo_equipo1: float, tiempo_equipo2: float } }
var pisos: Dictionary = {}
var kills_equipo: Array[int] = [0, 0]  # [equipo_rojo, equipo_azul] para desempate

signal piso_capturado(piso_id: int, equipo: int)
signal victoria_dominacion(equipo: int)
signal puntuacion_actualizada(tiempo_eq1: float, tiempo_eq2: float)

func _init():
	for i in range(Constants.TOTAL_PLATFORMS):
		pisos[i] = {
			"equipo": 0,            # 0 = neutral, 1 = rojo, 2 = azul
			"tiempo_equipo1": 0.0,  # Tiempo acumulado de control Eq. Rojo
			"tiempo_equipo2": 0.0,  # Tiempo acumulado de control Eq. Azul
		}


func resetear():
	kills_equipo = [0, 0]
	for i in range(Constants.TOTAL_PLATFORMS):
		pisos[i] = {
			"equipo": 0,
			"tiempo_equipo1": 0.0,
			"tiempo_equipo2": 0.0,
		}


# Llamado cuando una bandera cambia de dueño.
func capturar_piso(piso_id: int, equipo: int) -> void:
	if piso_id < 0 or piso_id >= Constants.TOTAL_PLATFORMS:
		return
	pisos[piso_id]["equipo"] = equipo
	piso_capturado.emit(piso_id, equipo)
	
	# Verificar victoria por control total (los 4 pisos)
	if verificar_control_total(equipo):
		victoria_dominacion.emit(equipo)


# Acumular tiempo de dominación cada segundo (llamado desde game_scene).
func acumular_tiempo(delta: float) -> void:
	for piso_id in pisos:
		var equipo = pisos[piso_id]["equipo"]
		if equipo == Constants.TEAM_RED:
			pisos[piso_id]["tiempo_equipo1"] += delta
		elif equipo == Constants.TEAM_BLUE:
			pisos[piso_id]["tiempo_equipo2"] += delta
	
	var t1 = obtener_tiempo_total(Constants.TEAM_RED)
	var t2 = obtener_tiempo_total(Constants.TEAM_BLUE)
	puntuacion_actualizada.emit(t1, t2)


# ¿Un equipo controla los 4 pisos al mismo tiempo?
func verificar_control_total(equipo: int) -> bool:
	for piso_id in pisos:
		if pisos[piso_id]["equipo"] != equipo:
			return false
	return true


# Obtener el tiempo total de dominación de un equipo.
func obtener_tiempo_total(equipo: int) -> float:
	var total = 0.0
	for piso_id in pisos:
		if equipo == Constants.TEAM_RED:
			total += pisos[piso_id]["tiempo_equipo1"]
		elif equipo == Constants.TEAM_BLUE:
			total += pisos[piso_id]["tiempo_equipo2"]
	return total


# Registrar kill para desempate.
func registrar_kill(equipo_atacante: int) -> void:
	if equipo_atacante == Constants.TEAM_RED:
		kills_equipo[0] += 1
	elif equipo_atacante == Constants.TEAM_BLUE:
		kills_equipo[1] += 1


# Determinar ganador al terminar el tiempo.
# Retorna: 1 = rojo gana, 2 = azul gana, 0 = empate absoluto
func determinar_ganador() -> int:
	var tiempo_rojo = obtener_tiempo_total(Constants.TEAM_RED)
	var tiempo_azul = obtener_tiempo_total(Constants.TEAM_BLUE)
	
	# Primero: quien tiene más tiempo de dominación
	if tiempo_rojo > tiempo_azul:
		return Constants.TEAM_RED
	elif tiempo_azul > tiempo_rojo:
		return Constants.TEAM_BLUE
	
	# Desempate por kills
	if kills_equipo[0] > kills_equipo[1]:
		return Constants.TEAM_RED
	elif kills_equipo[1] > kills_equipo[0]:
		return Constants.TEAM_BLUE
	
	# Empate absoluto
	return 0


# Obtener cuántos pisos controla un equipo.
func contar_pisos(equipo: int) -> int:
	var count = 0
	for piso_id in pisos:
		if pisos[piso_id]["equipo"] == equipo:
			count += 1
	return count


# Obtener el equipo dueño de un piso.
func obtener_equipo_piso(piso_id: int) -> int:
	if pisos.has(piso_id):
		return pisos[piso_id]["equipo"]
	return 0
