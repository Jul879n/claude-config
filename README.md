# claude-config

Configuración personal de [Claude Code](https://claude.ai/code) para sincronizar entre equipos.

## Qué incluye

| Componente | Descripción |
|---|---|
| `settings.template.json` | Hooks, permisos MCP, statusline, plugins, idioma, modelo |
| `CLAUDE.md` | Instrucciones globales de comportamiento |
| `statusline-command.sh` | Script del statusline personalizado |
| `skills/` | Skills activas automáticamente en cada sesión |
| `hooks/SkillActivationHook/` | Hook que inyecta skills activas en cada prompt |
| `mcp-servers.json` | MCP servers a instalar (`reposynapse`) |
| `memory/` | Memorias de preferencias de workflow (feedback) |

## Requisitos previos

- [Claude Code](https://claude.ai/code) instalado
- `envsubst` (incluido en `gettext`; en macOS: `brew install gettext`)
- `rsync` (incluido en macOS/Linux)
- `jq` (en macOS: `brew install jq`)
- `python3` (para sanitize.sh)
- Binario `reposynapse` en tu PATH

## Instalar en un equipo nuevo

```bash
git clone https://github.com/<tu-usuario>/claude-config ~/claude-config
cd ~/claude-config
chmod +x bootstrap.sh
./bootstrap.sh
```

Luego sigue los pasos manuales que imprime el script.

## Pasos manuales post-instalación

1. **`claude login`** — autenticar Claude Code con tu cuenta Anthropic
2. **Atlassian Rovo / Google Drive** — se activan automáticamente tras login con la misma cuenta Claude.ai. Sin configuración local necesaria.
3. **Plugins** (`context7`, `skill-creator`, `warp`) — se descargan al primer uso.
4. **Obsidian MCP** (si lo usas) — configurar manualmente con tu ruta de vault:
   ```bash
   claude mcp add obsidian -- npx @bitbonsai/mcpvault@latest /ruta/a/tu/vault
   ```

## Actualizar el repo desde este equipo

```bash
cd ~/claude-config
./sanitize.sh
git add -p
git commit -m "actualizar config"
git push
```

El script `sanitize.sh` sanitiza rutas absolutas, resuelve symlinks en skills, y verifica que no haya strings privados antes de salir.

## Qué NO está en este repo

- `settings.local.json` — permisos específicos de cada máquina
- `agent-memory/` — memorias de subagentes (pueden contener contexto de proyectos)
- `plans/`, `projects/`, `sessions/` — historial y estado local
- Memorias de tipo `project`/`user`/`reference` — pueden contener datos de proyectos
- OAuth tokens de MCPs (Atlassian, Google Drive)
- API key de Anthropic

## Versión de Claude Code

Generado con Claude Code **2.1.118**.
