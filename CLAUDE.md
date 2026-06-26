# CLAUDE.md

## Git

Never use git commands (commit, push, branch, etc.) unless explicitly instructed by the user.

## Tool Usage — Reposynapse MCP (Solo Lectura)

**Usar reposynapse MCP únicamente para leer archivos y explorar directorios.** No usar para edición, renombrado, inserción, ni ninguna operación de escritura. Do not search memory files when the user asks about codebase behavior.

### Reading & Navigation (reposynapse)
- **Explorar estructura**: `read_file_outline` — devuelve solo símbolos con rangos.
- **Leer una función**: `read_file_symbol` — extrae por nombre sin necesidad de saber la línea.
- **Buscar archivos**: `list_files` y `search_in_project`.
- **Buscar símbolos**: `search_symbol`. Soporta alternancia regex (`handle(Create|Update)`) y `path_filter`. **Limitación**: wildcards `.*` caen a fuzzy — usar `Grep` para patrones con `.*`.

### Editing (siempre Claude Code nativo)
- Usar `Edit`, `Write`, `Bash` para todas las operaciones de escritura.
- No usar `replace_symbol`, `insert_after_symbol`, `add_import`, `patch_file`, `batch_rename`, `remove_dead_code` de reposynapse.

### Cuándo usar Claude Code nativo en lugar de reposynapse
- Todas las operaciones de escritura/edición → siempre Claude Code nativo.
- Búsquedas con wildcards `.*` o regex complejos → usar `Grep`.
- Cuando el MCP se desconecta → fallback a `Read`, `Edit`, `Grep`, `Glob`.

## UI & Styling

For visual/UI/CSS changes, apply the minimal targeted fix first. Do not cycle through multiple architectural approaches (clip-path, SVG overlays, etc.) without asking the user which direction they prefer. When a visual change is rejected, ask for clarification before trying another approach.

Before writing any UI/CSS code, show a plan and wait for approval. Break visual work into small, single-concern tasks. If the user has not described the exact end state, ask for it before proceeding — e.g., "use a single SVG wave, white on dark background, 60px tall".

## WordPress

This project has two WordPress themes that share customizations. When modifying WooCommerce/WordPress theme code, always check if the change needs to be applied to BOTH theme copies.

## Code Style

Before implementing a feature, check the existing codebase for reusable components. Do not create new components when existing ones (e.g., Select, Modal) can be reused.

## Bug Fixes

When reporting a bug, the user will specify the file and function where the problem manifests. Always look there first before exploring other files. Do not modify other files without explaining why.

## Multi-file Changes

Before writing any code for changes that span multiple files, provide a numbered plan: 1) which files will be modified, 2) what change in each file, 3) any existing components to reuse. Wait for explicit approval before proceeding.

## PDF Generation

Para generar PDFs desde HTML (con soporte de Lucide icons, SVG inline, CSS personalizado):

```bash
npx pagedjs-cli input.html --output output.pdf
```

- **PagedJS CLI** es la herramienta correcta: implementa CSS Paged Media W3C, renderiza SVG, soporta `@page` y `page-break-inside`.
- **Lucide icons**: siempre embeber los SVG paths inline directamente en el HTML. No usar el patrón `<symbol>/<use href="#...">` — WeasyPrint y otros motores no lo resuelven.
- **No usar** Chrome headless `--print-to-pdf` (rechazado por el usuario).
- **No usar** WeasyPrint directo para HTML con SVG icons (no resuelve `<use href>`).
- **WeasyPrint + pandoc** solo sirve para Markdown → PDF sin íconos SVG.
- Para tipografía sin íconos: `brew install --cask basictex` → habilita pandoc + xelatex.
