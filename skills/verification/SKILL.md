---
name: verification
description: Verificar que el código funciona después de hacer cambios. Ejecutar tests, verificar resultados, no ocultar errores.
---

# Verification

## REGLA: No Modificar Archivos de Otros Agentes

**NO modificar, leer ni actuar sobre archivos que pertenezcan a otros agentes** (ej: task_plan.md de otros subagents). Solo trabajar en archivos propios de esta sesión.

---

## Principio

**El código no está listo hasta que está verificado.**

Escribir código sin verificar es como pintar sin revisar si quedó bien.

## Orden del workflow

```
brainstorming → código → tests (realistic-testing) → verification
```

**Los tests se escriben DESPUÉS del código** para verificar que funciona.

## Proceso de Verification

### 1. Ejecutar Tests
```bash
npm test        # o el comando del proyecto
pytest          # python
cargo test      # rust
```

### 2. Verificar Resultados
- ✅ Todos pasan → Proceder
- ❌ Algunos fallan → **No ocultar, investigar y corregir**

### 3. Si Fallan los Tests
**NUNCA** hacer esto:
- Aumentar timeout para que pase
-注释 skip tests que fallan
- Modificar assertion para que pase
- "Funciona en mi máquina"

**SIEMPRE** hacer esto:
- Leer el error completo
- Entender qué falló
- Corregir la causa raíz
- Volver a ejecutar

### 4. Verificación Manual (si aplica)
Si el proyecto tiene comandos de verificación:
```bash
npm run lint
npm run typecheck
npm run build
```

## Checklist de Verification

Antes de marcar como "listo", verifica:

- [ ] **Tests pasan** con datos reales (no mocks silenciosos)
- [ ] **Lint pasa** sin advertencias ignoradas
- [ ] **Typecheck pasa** si existe
- [ ] **Build pasa** si existe
- [ ] **Errores visibles** - no ocultos en logs

## Regla de Verification

> **Si no puedes verificar que funciona, no está terminado.**

No digas "debería funcionar" o "funciona localmente".
Muestra evidencia:
- Output de tests
- Resultados de build
- Logs relevantes

## Affiliate with realistic-testing

**realistic-testing** asegura que los tests sean reales.
**verification** asegura que los tests pasan y el código funciona.

Juntos: código que funciona = tests reales que pasan.
