#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="$HOME/.claude"

echo "→ Instalando configuración de Claude Code en $TARGET"

# Verificar dependencias
for cmd in envsubst rsync jq; do
  command -v "$cmd" >/dev/null || { echo "Error: '$cmd' no encontrado. Instálalo primero."; exit 1; }
done

# Crear estructura de directorios
mkdir -p "$TARGET/skills" "$TARGET/hooks" \
         "$TARGET/projects/-Users-$(whoami)/memory"

# Backup de settings.json existente
[ -f "$TARGET/settings.json" ] && cp "$TARGET/settings.json" \
    "$TARGET/settings.json.backup.$(date +%s)"

# Renderizar settings.template.json con $HOME real
envsubst < "$REPO_DIR/settings.template.json" > "$TARGET/settings.json"
echo "  ✓ settings.json"

# Archivos principales
cp "$REPO_DIR/CLAUDE.md" "$TARGET/CLAUDE.md"
echo "  ✓ CLAUDE.md"

cp "$REPO_DIR/statusline-command.sh" "$TARGET/statusline-command.sh"
chmod +x "$TARGET/statusline-command.sh"
echo "  ✓ statusline-command.sh"

# Skills (copia completa, sobreescribe)
rsync -a --delete "$REPO_DIR/skills/" "$TARGET/skills/"
echo "  ✓ skills/"

# Hooks
rsync -a --delete "$REPO_DIR/hooks/" "$TARGET/hooks/"
chmod +x "$TARGET/hooks/SkillActivationHook/skill-activation-prompt.sh"
echo "  ✓ hooks/"

# MCP servers: merge en ~/.claude.json sin tocar otros campos
CLAUDE_JSON="$HOME/.claude.json"
if [ -f "$CLAUDE_JSON" ]; then
  cp "$CLAUDE_JSON" "$CLAUDE_JSON.backup.$(date +%s)"
  jq --slurpfile mcp "$REPO_DIR/mcp-servers.json" \
     '.mcpServers = ((.mcpServers // {}) * $mcp[0])' \
     "$CLAUDE_JSON" > "$CLAUDE_JSON.tmp" && mv "$CLAUDE_JSON.tmp" "$CLAUDE_JSON"
  echo "  ✓ MCPs mergeados en ~/.claude.json"
else
  echo "  ! ~/.claude.json no encontrado. Corre 'claude login' primero, luego vuelve a ejecutar este script para instalar los MCPs."
fi

# Memorias de preferencias
MEM_DIR="$TARGET/projects/-Users-$(whoami)/memory"
cp "$REPO_DIR/memory/"*.md "$MEM_DIR/"
echo "  ✓ memory/ (preferencias de workflow)"

echo ""
echo "✓ Instalación completa."
echo ""
echo "Pasos manuales pendientes:"
echo "  1. claude login                  — autenticar Claude Code"
echo "     (tras login, re-ejecutar este script si ~/.claude.json no existía)"
echo "  2. Instalar dependencias externas si usas sus hooks:"
echo "     - ~/.vibe-island/bin/vibe-island-bridge"
echo "     - ~/.pixel-agents/hooks/claude-hook.js"
echo "  3. Instalar el binario 'reposynapse' en tu PATH"
echo "     (ver: https://github.com/twinnydotdev/reposynapse o npm i -g reposynapse)"
echo "  4. Atlassian Rovo / Google Drive: se activan automáticamente al hacer"
echo "     login con tu cuenta Claude.ai. No requieren configuración local."
echo "  5. Plugins (context7, skill-creator, warp): se descargan al primer uso."
