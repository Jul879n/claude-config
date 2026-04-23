---
name: reposynapse-explore
description: Use when launching Explore subagents or reading/searching code in this project. Provides the standard reposynapse-first prompt block to include in every Explore agent invocation.
---

# Reposynapse-First Exploration

## Standard Prompt Block

Include this verbatim in every Explore agent prompt:

```
Usa mcp__reposynapse__* tools como PRIMERA opción en toda búsqueda:
- read_file_outline / read_file_symbol para leer
- search_symbol para buscar símbolos
- search_in_project para búsquedas amplias
- list_files para explorar estructura
Solo fallback a Grep/Read si MCP se desconecta o necesitas wildcards .* en regex.
```

## Tool Mapping

| Task | Reposynapse Tool | Native Fallback |
|------|-----------------|-----------------|
| View file structure | `read_file_outline` | `Read` |
| Read a function | `read_file_symbol` | `Read` with offset |
| List files | `list_files` | `Glob` |
| Search code | `search_in_project` | `Grep` |
| Find symbol (function/class) | `search_symbol` | `Grep` (no `.*`) |

## When to Fall Back

- MCP disconnects → use Read/Grep/Glob
- Regex with `.*` wildcards → use `Grep`
- Writing/editing files → always use Claude Code native (Edit, Write, Bash)
