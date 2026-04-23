---
name: model-selector
description: Seleccionar modelo Claude según complejidad. Escalamiento progresivo: Haiku → Sonnet → Opus.
---

# Model Selector

## REGLA: No Modificar Archivos de Otros Agentes

**NO modificar, leer ni actuar sobre archivos que pertenezcan a otros agentes** (ej: task_plan.md de otros subagents). Solo trabajar en archivos propios de esta sesión.

---

## Principio

**Escalamiento progresivo:** Empezar con el modelo más económico, escalar solo si es necesario.

```
Haiku → (no funciona) → Sonnet → (no funciona) → Opus
```

## Modelos

| Modelo | Costo | Uso |
|--------|-------|-----|
| **Haiku** | $0.25/1.25 | Read-only, glob, grep, explicaciones cortas |
| **Sonnet** | $3/15 | Editar archivos, tests simples, refactors locales |
| **Opus** | $15/75 | Arquitectura nueva, debugging complejo, multi-archivo |

## Flujo de Decisión

```
┌─────────────────────────────────────┐
│ ¿Tarea es read-only / búsqueda?    │
└──────────────┬──────────────────────┘
              │ sí
              ▼
         Haiku ✓
         
         no
         │
         ▼
┌─────────────────────────────────────┐
│ ¿Editor archivo conocido / test    │
│ simple / refactor local?           │
└──────────────┬──────────────────────┘
              │ sí
              ▼
         Sonnet ✓
         
         no
         │
         ▼
┌─────────────────────────────────────┐
│ ¿Usuario pidió explícitamente      │
│ Opus o "mejor modelo"?            │
└──────────────┬──────────────────────┘
              │ sí
              ▼
         Opus ✓
         
         no
         │
         ▼
┌─────────────────────────────────────┐
│ ¿Sonnet falló múltiples veces      │
│ en esta sesión?                    │
└──────────────┬──────────────────────┘
              │ sí
              ▼
         Opus ✓
         
         no
         │
         ▼
   Preguntar al usuario
```

## Regla: Preguntar Antes de Opus

> "Esta tarea requiere Opus. ¿Confirmas que quieres usar el modelo más potente?"

**Excepciones** (no preguntar):
- Usuario explícitamente pide Opus
- Sonnet falló 2+ veces en la misma sesión
- Arquitectura nueva compleja donde el usuario ya entiende el costo

## Checklist de Preguntas

Antes de decidir, pregúntate:

1. **¿Puedo resolver esto con Haiku?** (buscar, explorar, leer)
   - Si sí → Haiku

2. **¿Puedo resolver esto con Sonnet?** (editar, modificar, crear en archivos existentes)
   - Si sí → Sonnet

3. **¿Realmente necesito Opus?**
   - Si no estás seguro → pregunta al usuario
   - Si el usuario no specify modelo → assume Sonnet

## Prompt de Recordatorio

> "Antes de pedir Opus, pregúntate: ¿puedo resolver esto con Sonnet? El 80% de las tareas se resuelven con Sonnet."

## Uso con /model

En Claude Code:
```
/model haiku   # Para tareas simples
/model sonnet  # Para tareas medianas  
/model opus    # Solo si es necesario
```

## En Resumen

| Si la tarea es... | Usa |
|-------------------|-----|
| Read-only, glob, grep simple | **Haiku** |
| Editar archivos existentes, tests, refactors locales | **Sonnet** |
| Arquitectura nueva, debugging complejo, multi-archivo | **Preguntar → Opus** |
