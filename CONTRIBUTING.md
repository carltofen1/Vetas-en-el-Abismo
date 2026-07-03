# Guia para contribuir

## Antes de empezar cada semana

```bash
git checkout feature/tu-rama
git pull origin dev
```

---

## Carpetas por dev

| Dev | Scripts | Escenas |
|-----|---------|---------|
| Patrick | `scripts/network/` | `scenes/network/` |
| Mathew | `scripts/gameplay/` | `scenes/gameplay/` |
| Jhon | `scripts/systems/` | `scenes/gameplay/` (items, recursos) |
| Cricko | `scripts/ui/` | `scenes/ui/` |
| Todos | `scripts/core/` | - |

No edites archivos fuera de tu area sin avisar primero.

---

## Archivos compartidos - cuidado con conflictos

- `project.godot` - solo Cricko edita los Autoloads; Patrick edita el input de red; avisar antes de tocar
- `scripts/autoloads/GameManager.gd` - avisar antes de modificar
- `scenes/gameplay/GameScene.tscn` - coordinar entre Mathew, Jhon y Patrick

---

## Como hacer un Pull Request

1. `git push origin feature/tu-rama`
2. GitHub -> "Compare & pull request"
3. Base: `dev` <- tu rama
4. Titulo: `feat: sistema de inventario semana 2`
5. Descripcion: que cambiaste y por que
6. Avisar al equipo para revision

---

## Conflictos en .tscn

Las escenas de Godot son texto pero sus conflictos son dificiles de resolver a mano.
Si dos personas tocan la misma escena:
- La persona que termino primero hace merge a dev
- La segunda hace `git pull origin dev` y reabre la escena en Godot para re-aplicar sus cambios

---

## Resolucion de conflictos GDScript

```bash
git status               # ver archivos en conflicto
# Editar el archivo, buscar <<<<<<< HEAD
# Dejar el codigo correcto, borrar los marcadores
git add archivo.gd
git commit -m "fix: resuelve conflicto en NombreArchivo"
```

---

## Hitos del proyecto

| Semana | Hito | Que necesita funcionar |
|--------|------|----------------------|
| 4 | MVP basico | Movimiento en red, recoleccion, combate simple |
| 9 | Vertical Slice | Juego completo inicio a fin con todos los items |
| 12 | Beta externa | Prueba con jugadores externos |
| 13 | Feature freeze | Cero codigo nuevo |
| 15 | Launch | Ejecutable final |

---

## Reglas

- Nunca `git push -f` en `dev` ni `main`
- Los archivos `.import` no van en git (ya estan en .gitignore)
- Si rompes `dev` avisas inmediatamente
- Builds no van en git - usar la carpeta `exports/` local
