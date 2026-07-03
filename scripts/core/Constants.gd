extends Node

# =====================================================
# Constants.gd - Autoload opcional o class_name
# Constantes globales del juego — GDD v6.0
# Responsable: Todo el equipo (coordinado por Cricko)
# =====================================================

class_name Constants

# --- Partida ---
const MATCH_DURATION: float = 600.0   # 10 minutos
const TOTAL_PLATFORMS: int = 4
const TEAMS: int = 2
const TEAM_SIZE: int = 2

# --- Jugador (Sistema Porcentual 0-100%) ---
const PLAYER_MAX_DAMAGE_PERCENT: float = 100.0  # Muerte al 100%
const PLAYER_SPEED: float = 300.0
const PLAYER_JUMP_FORCE: float = -400.0
const PLAYER_INVENTORY_MAX: int = 10
const PLAYER_BASE_ATTACK_DAMAGE: float = 12.0  # Daño porcentual por golpe
const PLAYER_RESPAWN_TIME: float = 33.0          # Regla de los 33s
const PLAYER_MINERAL_DROP_PERCENT: float = 0.5   # Dropea 50% al morir

# --- Knockback Scaling ---
const KNOCKBACK_BASE_FORCE: float = 200.0
const KNOCKBACK_SCALE_FACTOR: float = 8.0   # Fuerza extra por cada % de daño
const KNOCKBACK_VERTICAL_RATIO: float = 0.5  # Proporción vertical del golpe

# --- Dash ---
const DASH_SPEED: float = 800.0
const DASH_DURATION: float = 0.2

# --- Saltos ---
const MAX_JUMPS: int = 2

# --- Recursos (Tiers de Minerales) ---
const MINERAL_TIER1_VALUE: int = 1
const MINERAL_TIER2_VALUE: int = 3
const MINERAL_TIER3_VALUE: int = 5

const MINERAL_TIER1_RESPAWN: float = 15.0   # segundos
const MINERAL_TIER2_RESPAWN: float = 30.0
const MINERAL_TIER3_RESPAWN: float = 60.0

# Colores de modulación por tier (azul claro, púrpura, dorado)
const MINERAL_TIER1_COLOR: Color = Color(0.4, 0.7, 1.0)   # Azul claro
const MINERAL_TIER2_COLOR: Color = Color(0.7, 0.3, 1.0)   # Púrpura
const MINERAL_TIER3_COLOR: Color = Color(1.0, 0.85, 0.2)   # Dorado

# --- Captura de Pisos (Rey de la Colina) ---
const CAPTURE_TIME_NEUTRAL: float = 3.0   # Segundos para capturar piso neutral
const CAPTURE_TIME_ENEMY: float = 5.0      # Segundos para capturar piso enemigo
const CAPTURE_HEAL_PER_SECOND: float = 2.0 # Curación por segundo en territorio propio

# --- Crafteo / Tienda ---
const ITEM_BOTAS_COSTO: int = 5
const ITEM_BOTAS_SPEED_BONUS: float = 150.0

const ITEM_GUANTES_COSTO: int = 7
const ITEM_GUANTES_DAMAGE_BONUS: float = 5.0

const ITEM_CASCO_COSTO: int = 6
const ITEM_CASCO_KB_REDUCTION: float = 0.20  # -20% knockback

const ITEM_DASH_COSTO: int = 4
const ITEM_DASH_DURATION_BONUS: float = 0.1

const ITEM_SALTO_COSTO: int = 8
const ITEM_SALTO_EXTRA: int = 1  # +1 salto

# --- Red ---
const DEFAULT_PORT: int = 8910
const MAX_PLAYERS: int = 4

# --- Equipos ---
# Jugadores 1,2 → Equipo 1 (ROJO), Jugadores 3,4 → Equipo 2 (AZUL)
const TEAM_RED: int = 1
const TEAM_BLUE: int = 2
const TEAM_RED_COLOR: Color = Color(1.0, 0.3, 0.3)
const TEAM_BLUE_COLOR: Color = Color(0.3, 0.5, 1.0)
const TEAM_NEUTRAL_COLOR: Color = Color(0.7, 0.7, 0.7)

# --- Capas de fisicas (configurar igual en Project Settings) ---
const LAYER_PLAYER: int = 1
const LAYER_PLATFORM: int = 2
const LAYER_RESOURCE: int = 3
const LAYER_PROJECTILE: int = 4

# --- Mapa: La Veta Superficial (Distancias en pixeles) ---
const FLOOR_WIDTH: float = 1920.0
const FLOOR_HEIGHT_GAP: float = 270.0    # Distancia vertical entre pisos
const FLOOR_Y_POSITIONS: Array = [810.0, 540.0, 270.0, 0.0]  # Piso 1 (abajo) a 4 (arriba)
