# GDD - Plataformas 2v2
**Version:** 0.1
**Motor:** Godot 4.3

---

## Concepto

Juego de accion 2D multijugador. Dos equipos de 2 jugadores compiten por controlar 4 plataformas. Gana el equipo con mas plataformas al acabar los 10 minutos.

---

## Mecanicas principales

### Control de plataformas
- 4 plataformas en el mapa
- Se conquista permaneciendo sin oponentes
- UI muestra estado en tiempo real por colores (azul/rojo/neutral)

### Recursos
- Nivel 1: comunes, respawn 15s
- Nivel 2: poco frecuentes, respawn 30s
- Nivel 3: raros, respawn 60s
- Inventario max: 10 unidades totales

### Crafteo en base
- Zona de base por equipo
- Tecla E para interactuar y abrir menu de crafteo
- Gasta recursos para obtener items

### Items (a definir costos exactos)

**Movilidad (3)**
- TBD

**Ataque (3)**
- TBD

**Pasivas/Mejoras (3)**
- TBD

**Pasivas comunes (6+)**
- TBD

---

## Condicion de victoria

1. Mas plataformas al terminar los 10 min -> gana
2. Empate -> desempate por tiempo acumulado en zona rival (contador oculto)

---

## HUD

- Barra de vida
- Inventario con iconos y cantidades
- Estado de 4 plataformas (colores)
- Timer 10:00 -> 0:00
- Notificaciones: "Plataforma X conquistada"

---

## Stack tecnico

- Motor: Godot 4.3
- Lenguaje: GDScript (tipado estatico)
- Red: MultiplayerAPI + ENetMultiplayerPeer
- Control de versiones: Git + GitHub

---

## Por definir

- [ ] Nombre del juego
- [ ] Arte y estilo visual
- [ ] Costos de crafteo por item
- [ ] Damage y cooldowns
- [ ] Layout del mapa con las 4 plataformas
