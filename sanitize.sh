#!/usr/bin/env bash
# Regenera los archivos del repo desde la configuración actual de ~/.claude/
# Ejecutar en el equipo origen antes de hacer git commit.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE="$HOME/.claude"

echo "→ Sincronizando desde $SOURCE al repo..."

# settings.template.json: sanitizar rutas absolutas
sed "s|$HOME|\$HOME|g" "$SOURCE/settings.json" > "$REPO_DIR/settings.template.json"
echo "  ✓ settings.template.json"

# Archivos directos
cp "$SOURCE/CLAUDE.md" "$REPO_DIR/CLAUDE.md"
cp "$SOURCE/statusline-command.sh" "$REPO_DIR/statusline-command.sh"
echo "  ✓ CLAUDE.md, statusline-command.sh"

# Skills: cp -L resuelve symlinks (find-skills, planning-with-files apuntan a ~/.agents/skills/)
rsync -aL --delete \
  --exclude=".DS_Store" \
  --exclude="recommendation-log.json" \
  "$SOURCE/skills/" "$REPO_DIR/skills/"
# Asegurarse de que skill-rules.json está incluido
cp "$SOURCE/skills/skill-rules.json" "$REPO_DIR/skills/"
echo "  ✓ skills/"

# Hooks
rsync -a --delete "$SOURCE/hooks/SkillActivationHook/" \
  "$REPO_DIR/hooks/SkillActivationHook/"
echo "  ✓ hooks/"

# MCP servers: extraer solo reposynapse de ~/.claude.json
python3 -c "
import json, sys
d = json.load(open('$HOME/.claude.json'))
mcp = {'reposynapse': d['mcpServers']['reposynapse']}
print(json.dumps(mcp, indent=2))
" > "$REPO_DIR/mcp-servers.json"
echo "  ✓ mcp-servers.json"

# Memorias de preferencias (solo feedback_*.md y MEMORY.md)
MEM_SRC="$SOURCE/projects/-Users-$(whoami)/memory"
cp "$MEM_SRC/MEMORY.md" "$REPO_DIR/memory/"
cp "$MEM_SRC/feedback_"*.md "$REPO_DIR/memory/" 2>/dev/null || true
echo "  ✓ memory/"

# Guardia: verificar que no haya datos sensibles
echo ""
echo "→ Verificando ausencia de datos sensibles..."
SENSITIVE_PATTERNS="cohasa|arauco|jaraya@|/Users/$(whoami)"
HITS=$(grep -rE "$SENSITIVE_PATTERNS" "$REPO_DIR" \
  --exclude-dir=".git" \
  --exclude="sanitize.sh" \
  --exclude="*.backup.*" 2>/dev/null || true)

if [ -n "$HITS" ]; then
  echo "⚠️  ADVERTENCIA: Se encontraron strings potencialmente sensibles:"
  echo "$HITS"
  echo ""
  echo "Revisar antes de hacer git commit."
  exit 1
else
  echo "  ✓ Sin datos sensibles detectados."
fi

echo ""
echo "✓ Repo actualizado. Revisar con 'git diff' antes de commitear."
