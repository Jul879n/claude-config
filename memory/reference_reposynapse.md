---
name: reposynapse MCP — Estrategia de tokens y reglas de uso
description: Tabla de herramientas reposynapse con costo en tokens, flujo óptimo de exploración y reglas obligatorias de uso (aplica a todos los proyectos)
type: reference
---

## Estrategia de tokens (medido real 2026-03-03)

Referencia: `Read` completo 701L = **6,205t** baseline (useRouteSubmit.ts, 24,820 bytes)

| Tarea | Herramienta preferida | Tokens | Alternativa |
|---|---|---|---|
| Inicio de sesión / orientación | MCP `get_project_context ultra` | 97t | — |
| Ver hot files con tamaños | MCP `get_project_context section="hotfiles"` | 189t | compact=308t si necesito modelos también |
| Archivos modificados (git) | MCP `get_project_context section="modified"` | ~15t | v1.8.0: sección dedicada, bug 0L CORREGIDO |
| Errores compilación fatal | MCP `get_diagnostics` | 35t | filtra lint como ruido — solo errores reales |
| Tamaños de archivos en carpeta | MCP `list_files` | 36t | único con tamaños |
| Buscar símbolo por nombre | MCP `search_symbol "a,b"` | ~25t/búsqueda | v1.8.0: multi-nombre en 1 call, indica `~fuzzy`/`~sub` |
| ¿Existe este patrón? | MCP `search_in_project max_files=0` | 65t | — |
| ¿Qué archivos lo contienen? (por tipo) | CLI `Grep files_with_matches + glob` | 79t | search_in_project si no importa tipo |
| Ver código del patrón en contexto | MCP `search_in_project max_files=3` | ~600t | con patrón común — puede variar |
| Orientación rápida archivo grande | MCP `read_file_outline depth=1` | ~10-80t | v1.8.0: NUEVO — solo top-level, 99% ahorro en archivos con +300 símbolos |
| Estructura completa archivo | MCP `read_file_outline` | ~55-900t | escala con complejidad — evitar en archivos >300 símbolos |
| Buscar dentro de un archivo | MCP `search_in_file ctx±2` | 158t | Grep -C si prefiero CLI |
| Leer rango exacto de líneas | MCP `read_file start/end_line` | 212t | CLI Read offset+limit |
| Leer función/const completa por nombre | MCP `read_file_symbol` | ~350-1,159t | v1.6.7+: soporta `const`; usar Read+offset si sabes la línea |
| Leer archivo completo para editar | CLI `Read` directo | 6,205t | siempre nativo para Edit |

**Flujo óptimo para explorar (v1.8.0)**: `list_files`(36t) → `read_file_outline depth=1`(~10-80t) → `search_symbol`(~25t) → `Read offset+limit` = **<150t** vs 6,205t directo = **97%+ ahorro**

## REGLA OBLIGATORIA — reposynapse primero (siempre)
- **Toda exploración** debe empezar con reposynapse MCP (`read_file_outline`, `search_symbol`, `search_in_project`, `read_file_symbol`) ANTES de usar Read/Grep/Bash
- **Subagentes (Explore agents)**: incluir instrucción explícita en el prompt: "Usa mcp__reposynapse__* como primera opción antes de Read/Grep/Bash. Flujo: outline → search_symbol → read_file_symbol → Read solo si necesitas editar"
- **Read nativo** solo para: (1) leer las líneas exactas antes de Edit, (2) cuando reposynapse no tiene equivalente
- Preferencia del usuario: priorizar ahorro de tokens en todo momento

## NUNCA usar
- `repo://context/outlines` completo → 64.2 KB, ~16,000t estimado
- `ReadMcpResourceTool hotfiles` → redundante con `section="hotfiles"` + JSON overhead
- `get_project_context format="normal"` sin section → **~1,525t** (15× más caro que ultra=97t)
- `read_file_outline` sin `depth=1` en archivos con >200 símbolos → puede superar 3,000t
- `search_in_project max_files=-1` sin `file_pattern` → v1.8.0 limita a 5/archivo pero sin context_lines cae a summary; con `file_pattern` acotado es útil como grep

## Comportamientos clave verificados (v1.8.0, 2026-03-05)
- **`read_file_outline depth=1`**: filtra a símbolos top-level — [direction].tsx 338sym→1sym (~99% ahorro). Primera llamada puede ser stale (cache): reintentar si no filtra.
- **`search_symbol` multi-nombre**: `"handleDelete,handleEdit"` → 2 búsquedas en 1 call, separadas por `---`. Indicadores: `~fuzzy`, `~sub`, `~ci`.
- **`section="modified"`**: lista archivos git-modified con líneas reales (~15t). Bug 0L de v1.7.3 corregido.
- **`max_files=-1` v1.8.0**: ahora seguro — default 5 matches/archivo. Sin `context_lines` cae a summary automáticamente.
- `read_file_outline` escala con **complejidad** (símbolos): 131L→55t, 701L→148t, 1722L→~350t, 3405L→~900t, 5159L→~3,000t+ (sin depth)
- `read_file_symbol` v1.6.7+: soporta `const` variables. MEDIDO: 422L → 47L extraídas = ~90% ahorro
- `read_file` sin rango en archivo >200L → devuelve outline automáticamente
- `get_diagnostics`: filtra lint — solo errores de compilación reales
- `list_files`: único tool que muestra tamaños de archivo
