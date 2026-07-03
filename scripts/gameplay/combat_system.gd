extends Node

# =====================================================
# CombatSystem.gd
# Cálculos de combate porcentual y knockback escalado
# Basado en GDD v6.0 - Sistema Smash-like in-bounds
# =====================================================

class_name CombatSystem

# Calcula la fuerza de knockback según el porcentaje de daño actual.
# A mayor porcentaje, más lejos sale volando el personaje.
# Inspirado en Super Smash Bros pero SIN ring-outs.
static func calcular_knockback(porcentaje_dano: float, direccion_golpe: int, atacante_bonus_dano: float = 0.0) -> Vector2:
	# Fórmula: fuerza = base + (porcentaje * factor_escala)
	var fuerza_horizontal = Constants.KNOCKBACK_BASE_FORCE + (porcentaje_dano * Constants.KNOCKBACK_SCALE_FACTOR)
	var fuerza_vertical = fuerza_horizontal * Constants.KNOCKBACK_VERTICAL_RATIO
	
	# Aplicamos la dirección del golpe (izquierda = -1, derecha = 1)
	return Vector2(direccion_golpe * fuerza_horizontal, -fuerza_vertical)


# Calcula cuánto daño porcentual hace un ataque.
# El daño base es 12%, pero puede aumentar con items (guantes).
static func calcular_dano(base_extra: float = 0.0) -> float:
	return Constants.PLAYER_BASE_ATTACK_DAMAGE + base_extra


# Calcula cuántos minerales dropea un jugador al morir.
# Regla: siempre el 50% redondeado hacia abajo.
static func calcular_mineral_drop(minerales_actuales: int) -> int:
	return int(minerales_actuales * Constants.PLAYER_MINERAL_DROP_PERCENT)


# Verifica si un jugador debería morir (llegar al 100%).
static func esta_muerto(porcentaje_dano: float) -> bool:
	return porcentaje_dano >= Constants.PLAYER_MAX_DAMAGE_PERCENT


# Aplica reducción de knockback por casco.
static func aplicar_reduccion_kb(knockback: Vector2, tiene_casco: bool) -> Vector2:
	if tiene_casco:
		return knockback * (1.0 - Constants.ITEM_CASCO_KB_REDUCTION)
	return knockback
