---
name: simplify
description: >
  Refactorizar y simplificar archivos grandes en fases progresivas. Usa este skill siempre que el usuario mencione simplificar, refactorizar, o reducir un archivo grande. El flujo completo: analiza el archivo → propone fases → ejecuta cada fase (extrae hooks/componentes) → actualiza el plan en plans/ y el CHANGELOG.md. Actívate cuando el usuario diga "simplifica [archivo]", "refactoriza [archivo]", "extrae la lógica de", "el archivo está muy grande", o cuando pida dividir un archivo en partes.
---

# Skill: Simplificación Progresiva de Archivos

Tu objetivo es reducir archivos grandes en fases controladas, extrayendo lógica en hooks y JSX en componentes, manteniendo 100% del funcionamiento.

## Reglas críticas

- **Leer siempre con reposynapse MCP**: `read_file_outline`, `read_file_symbol`, `search_in_project`
- **Escribir siempre con herramientas nativas**: `Edit`, `Write` (nunca con reposynapse para escritura)
- **Sin animaciones**: nunca usar `animation`, `enterStyle`, `exitStyle` en Tamagui ni equivalentes
- **Registrar en CHANGELOG.md** al final de cada fase completada
- **No hacer commit** a menos que el usuario lo pida explícitamente

---

## Fase 0: Analizar el archivo

Antes de proponer nada, lee el archivo objetivo:

1. Usa `mcp__reposynapse__read_file_outline` para ver la estructura completa
2. Usa `mcp__reposynapse__read_file_symbol` para leer secciones clave
3. Cuenta las líneas actuales del archivo
4. Identifica los bloques candidatos a extraer:

**Candidatos a HOOK** (lógica, no JSX):
- Estados (`useState`, `useRef`, `useEffect`) agrupados por dominio
- Llamadas a APIs (`useInvokeAsync`, `useTriggerInvokeAsync`)
- Handlers y funciones de negocio
- Lógica de cálculo o transformación de datos

**Candidatos a COMPONENTE** (JSX):
- Secciones visuales grandes (cards, forms, listas, banners)
- Bloques repetidos
- Secciones con render condicional complejo

5. Verifica si existe un plan en `plans/` para este archivo antes de crear uno nuevo

---

## Fase 1: Proponer el plan de fases

Presenta al usuario una tabla con las fases propuestas:

```
| Fase | Tipo    | Nombre sugerido         | Qué extrae                    | Meta líneas |
|------|---------|-------------------------|-------------------------------|-------------|
| 1    | Hook    | useXxxData              | fetch + estado de datos       | -NNN L      |
| 2    | Hook    | useXxxActions           | handlers de mutación          | -NNN L      |
| 3    | Componente | XxxHeaderCard        | sección superior del JSX      | -NNN L      |
| ...  | ...     | ...                     | ...                           | ...         |
```

Incluye:
- Líneas actuales del archivo
- Meta de líneas final (idealmente <400L para pantallas, <200L para pantallas simples)
- Cuántas fases propones

**Espera aprobación del usuario antes de ejecutar.** Puede ajustar, reordenar o cancelar fases.

---

## Fase 2: Ejecutar una fase

Cuando el usuario aprueba y pide ejecutar una fase (o todas):

### Para extraer un HOOK

1. Lee el símbolo o sección completa con `read_file_symbol`
2. Identifica las dependencias (imports, otros hooks, contextos usados)
3. Crea el archivo `hooks/useXxx.ts` con:
   - Todos los imports necesarios
   - La lógica extraída
   - Un return tipado con todos los valores que necesita el componente padre
4. En el archivo original:
   - Agrega el import del nuevo hook
   - Reemplaza el código extraído por `const { ... } = useXxx(...)`
   - Elimina los imports que ya no se usan directamente

### Para extraer un COMPONENTE

1. Lee la sección JSX completa con `read_file_symbol`
2. Identifica las props que necesita (valores del padre)
3. Crea `components/[dominio]/XxxComponent.tsx` con:
   - Interface de props tipada
   - El JSX extraído
   - Imports necesarios
4. En el archivo original:
   - Agrega el import del componente
   - Reemplaza el JSX con `<XxxComponent prop1={...} prop2={...} />`

### Antes de crear cualquier archivo

Busca si ya existe un componente o hook reutilizable:
```
mcp__reposynapse__search_symbol con el nombre candidato
```
Si existe algo similar, reutiliza en lugar de crear uno nuevo.

---

## Fase 3: Verificar la fase

Después de cada fase:

1. Cuenta las líneas del archivo original (antes vs después)
2. Verifica que el archivo modificado compile (revisa imports, referencias)
3. Confirma al usuario: "Fase X completada. Archivo pasó de NNN → MMM líneas (-XX%)"

---

## Fase 4: Actualizar el plan y CHANGELOG

### Actualizar `plans/PLAN_*.md`

Si existe un plan:
- Cambia el estado de la fase de `⏳ Pendiente` a `✅ Completo`
- Actualiza la tabla de métricas con líneas actuales
- Agrega detalle de la fase en la sección "Detalle de fases completadas"

Si no existe plan:
- Crea `plans/PLAN_SIMPLIFICATION_[NOMBRE_ARCHIVO].md` con la misma estructura del plan existente como referencia

### Actualizar `CHANGELOG.md`

Agrega una entrada con formato:
```
## [fecha] — Simplificación [NombreArchivo]
- Fase N: Extraído `[nombre]` ([tipo]) — [ArchivoPrincipal].tsx NNN → MMM L (-XX%)
```

---

## Notas de estilo del proyecto

- **Booleanos en MongoDB**: tipados como `0 | 1`, no `boolean`. Al pasar a componentes usar `Boolean(value)`
- **Lambda calls**: `invokeLambda('nombre-lambda', { filter, project, sort })`
- **Imports con alias**: `@/hooks/...`, `@/components/...`, `@/constants/...`
- **Tamagui** para UI: `XStack`, `YStack`, `Text`, `Button`, etc.
- **i18n**: usar `const { t } = useI18n()` para textos visibles al usuario
