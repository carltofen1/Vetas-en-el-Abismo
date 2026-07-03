# Plataformas 2v2

> Juego 2D multijugador online de conquista de 4 plataformas con sistema de crafteo.
> Motor: Godot 4.3 | Duracion: 15 semanas | Estado: En desarrollo

---

## Equipo

| Dev | Rol | Area | Rama |
|-----|-----|------|------|
| **Patrick** | Netcode & Sincronizacion | MultiplayerAPI, ENet, sync de variables | `feature/patrick-netcode` |
| **Mathew** | Fisicas & Control | CharacterBody2D, saltos, colisiones, habilidades | `feature/mathew-fisicas` |
| **Jhon** | Sistemas & Economia | Recursos, inventario, crafteo | `feature/jhon-sistemas` |
| **Cricko** | Game Loop & UI/UX | Estados de partida, HUD, menus, audio | `feature/cricko-ui` |

---

## Requisitos

- **Godot 4.3** (descargar en https://godotengine.org)
- **Git** instalado
- Editor de codigo recomendado: VSCode o Godot interno

---

## Setup inicial (solo la primera vez)

```bash
# 1. Clonar el repo
git clone https://github.com/TU_USUARIO/Plataformas2v2.git
cd Plataformas2v2

# 2. Correr el script de setup
bash setup.sh

# 3. Abrir Godot -> Import -> seleccionar la carpeta del proyecto
```

El script configura tu nombre Git y crea tu rama personal automaticamente.

---

## Estructura del proyecto

```
Plataformas2v2/
├── project.godot           <- configuracion del proyecto (no editar a mano)
├── assets/
│   ├── art/
│   │   ├── ui/             <- sprites de interfaz
│   │   ├── characters/     <- sprites de personajes
│   │   ├── map/            <- tiles y mapa
│   │   └── effects/        <- particulas
│   └── audio/
│       ├── sfx/            <- efectos de sonido (.wav / .ogg)
│       └── music/          <- musica de fondo (.ogg)
├── scenes/
│   ├── ui/                 <- MainMenu.tscn, Lobby.tscn, HUD.tscn
│   ├── gameplay/           <- GameScene.tscn, Player.tscn, Platform.tscn
│   └── network/            <- objetos de red (Patrick)
├── scripts/
│   ├── autoloads/          <- GameManager.gd, SceneLoader.gd, AudioManager.gd
│   ├── ui/                 <- Cricko: HUD.gd, MainMenu.gd, CraftingMenu.gd
│   ├── network/            <- Patrick: NetworkManager.gd, SyncPlayer.gd
│   ├── gameplay/           <- Mathew: Player.gd, Attack.gd
│   ├── systems/            <- Jhon: Inventory.gd, CraftingSystem.gd
│   └── core/               <- compartido: Constants.gd, Utils.gd
├── resources/
│   ├── items/              <- ItemData.tres (recursos de crafteo)
│   ├── tilesets/           <- TileSet del mapa
│   └── themes/             <- Theme de UI
├── addons/                 <- plugins de Godot (si se usan)
├── docs/
│   ├── gdd/                <- Game Design Document
│   ├── sprints/            <- notas semanales
│   └── arte/               <- referencias visuales
└── exports/                <- builds (ignorado por git)
```

---

## Autoloads (Singletons)

Godot los carga automaticamente. Acceso desde cualquier script:

```gdscript
GameManager.start_match()
SceneLoader.load_lobby()
AudioManager.play_sfx(sonido)
```

| Autoload | Responsable | Funcion |
|----------|-------------|---------|
| `GameManager` | Cricko | Estado global, tiempo, senales |
| `SceneLoader` | Cricko | Cambio de escenas |
| `AudioManager` | Cricko | Musica y SFX |

---

## Flujo de trabajo Git

### Ramas

```
main          <- build estable (solo en hitos)
dev           <- integracion del equipo
feature/...   <- trabajo individual
```

### Dia a dia

```bash
# Antes de empezar - actualizar con dev
git checkout feature/tu-rama
git pull origin dev

# Trabajar y hacer commits
git add .
git commit -m "feat: descripcion de lo que hiciste"
git push origin feature/tu-rama

# Crear Pull Request en GitHub hacia dev
```

### Formato de commits

```
feat: agrega sistema de inventario
fix: corrige bug en sincronizacion
ui: actualiza HUD de plataformas
refactor: limpia codigo de movimiento
docs: agrega notas semana 3
```

---

## Convenciones de codigo GDScript

```gdscript
# Nombres de clases: PascalCase
class_name PlayerController

# Variables: snake_case
var player_health: float = 100.0

# Variables privadas: _snake_case
var _is_jumping: bool = false

# Constantes: UPPER_SNAKE_CASE
const MAX_SPEED: float = 300.0

# Senales: snake_case
signal health_changed(new_value: float)

# Funciones: snake_case
func take_damage(amount: float) -> void:
    pass
```

- Tipado estatico siempre que sea posible
- Un script por escena/nodo principal
- Cada dev trabaja en su carpeta de scripts

---

## Hoja de ruta

| Fase | Semanas | Hito |
|------|---------|------|
| 1 - Prototipo | 1-4 | MVP jugable en red |
| 2 - Logica | 5-9 | Vertical Slice completo |
| 3 - Assets | 10-12 | Arte real + balance |
| 4 - Pulido | 13-15 | Launch |

---

## Inputs configurados en project.godot

| Accion | Tecla default |
|--------|---------------|
| `move_left` | A |
| `move_right` | D |
| `jump` | W |
| `attack` | J |
| `interact` | E |

---

## Multijugador - stack de Patrick

Godot 4 usa `MultiplayerAPI` con `ENetMultiplayerPeer`.
Los scripts de red van en `scripts/network/`.
Variables sincronizadas con `@export` + `MultiplayerSynchronizer`.

---

## Contacto

Coordinacion por Discord/WhatsApp del grupo.
Dudas de arquitectura -> abrir un Issue en GitHub.
