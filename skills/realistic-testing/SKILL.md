---
name: realistic-testing
description: Preferir falla visible a respaldo silencioso. Tests reales con datos reales, no marcadores de posición.
---

# Realistic Testing

## REGLA: No Modificar Archivos de Otros Agentes

**NO modificar, leer ni actuar sobre archivos que pertenezcan a otros agentes** (ej: task_plan.md de otros subagents). Solo trabajar en archivos propios de esta sesión.

---

## Principio Fundamental

**Prefiere una falla visible a un respaldo silencioso.**

- Nunca te tragues silenciosamente los errores para que las cosas sigan "funcionando".
- Muestra el error. No sustituyas datos de marcador de posición.
- Los respaldos son aceptables solo cuando se revelan. Muestra un banner, registra una advertencia, anota la salida.
- Diseña para la depuración, no para la estabilidad cosmética.

## Orden de Prioridad

1. **Funciona correctamente con datos reales** ← Objetivo principal
2. **Retrocede visiblemente** — Señala claramente el modo degradado
3. **Falla con un mensaje de error claro**
4. **Se degrada silenciosamente para parecer "bien"** ← NUNCA hacer esto

## Reglas para Tests

### ❌ Nunca hacer esto
```javascript
// Malo: Silenciar errores
test('user login', () => {
  try {
    expect(login('real@email.com', 'realpass')).toBe(true)
  } catch (e) {
    // Silenciado - parece que funciona
    expect(true).toBe(true)
  }
})

// Malo: Usar datos de marcador
test('user data', () => {
  expect(user.name).toBe('test-user') // Datos falsos
})

// Malo: Fallback silencioso
async function getData() {
  try {
    return await realApiCall()
  } catch {
    return { name: 'default' } // Silencioso - parece que funciona
  }
}
```

### ✅ Correcto
```javascript
// Bueno: Mostrar error claramente
test('user login with real credentials', () => {
  const result = login('real@email.com', 'realpass')
  expect(result.success).toBe(true)
  expect(result.user).toBeDefined()
})

// Bueno: Usar datos reales o fallar
test('fetches real user profile', async () => {
  const user = await fetchUserProfile(REAL_USER_ID)
  expect(user.id).toBe(REAL_USER_ID)
  expect(user.email).toContain('@')
})

// Bueno: Fallback visible
async function getData() {
  try {
    return await realApiCall()
  } catch (error) {
    console.warn('⚠️ Using fallback data - API unavailable')
    throw new Error(`API failed: ${error.message}. Use mock data explicitly.`)
  }
}
```

## Checklist de Test Realista

Antes de escribir un test, verifica:

- [ ] **¿Usa datos reales?** No usar 'test-user', 'foo', '123'
- [ ] **¿Muestra errores?** No hacer try/catch silencioso
- [ ] **¿Falla claramente?** Mensaje de error descriptivo
- [ ] **¿Revela fallback?** Si hay modo degradado, banner visible
- [ ] **¿Depurable?** Stack trace clara, logs útiles

## En Caso de Duda

Si no tienes datos reales para el test:
1. Pide al usuario datos de prueba reales
2. Crea fixtures con datos realistas (no 'foo', 'bar')
3. Marca el test como `.skip` con razón clara
4. NO uses datos falsos que pasen "porque sí"

## Affiliate Principle

Un test que pasa con datos falsos no es un test que pasa. Es una ilusión de coverage.

**El objetivo no es que pasen los tests. El objetivo es que el código funcione.**
