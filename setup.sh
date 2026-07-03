#!/bin/bash
# setup.sh - Ejecutar una sola vez al clonar el repo

echo "=== Setup Plataformas 2v2 - Godot 4 ==="
echo ""

echo "Ingresa tu nombre de dev (patrick / mathew / jhon / cricko):"
read DEVNAME

case $DEVNAME in
  patrick)
    BRANCH="feature/patrick-netcode"
    AREA="scripts/network/"
    ;;
  mathew)
    BRANCH="feature/mathew-fisicas"
    AREA="scripts/gameplay/"
    ;;
  jhon)
    BRANCH="feature/jhon-sistemas"
    AREA="scripts/systems/"
    ;;
  cricko)
    BRANCH="feature/cricko-ui"
    AREA="scripts/ui/"
    ;;
  *)
    echo "Nombre no reconocido. Usando nombre directo..."
    BRANCH="feature/$DEVNAME"
    AREA="scripts/core/"
    ;;
esac

echo ""
echo "Ingresa tu nombre completo para Git:"
read GIT_NAME
echo "Ingresa tu email de GitHub:"
read GIT_EMAIL

git config user.name "$GIT_NAME"
git config user.email "$GIT_EMAIL"

echo ""
echo "Configurando ramas..."
git fetch origin

# Asegurar que dev existe localmente
git checkout dev 2>/dev/null || git checkout -b dev origin/dev

# Crear o cambiar a la rama del dev
git checkout $BRANCH 2>/dev/null || git checkout -b $BRANCH
git push -u origin $BRANCH 2>/dev/null || echo "Rama ya existe en remoto."

echo ""
echo "========================================"
echo "Setup completado!"
echo "Tu rama:  $BRANCH"
echo "Tu area:  $AREA"
echo ""
echo "Proximos pasos:"
echo "  1. Abre Godot 4"
echo "  2. Import -> selecciona esta carpeta"
echo "  3. Godot genera la carpeta .godot/ (no va a git)"
echo "  4. Trabaja en tu rama y haz PRs hacia dev"
echo "========================================"
