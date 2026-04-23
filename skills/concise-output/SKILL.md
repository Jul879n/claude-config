---
name: concise-output
description: Reducir texto descriptivo manteniendo claridad. Mismo objetivo, menos palabras.
---

# Output Conciso

## REGLA: No Modificar Archivos de Otros Agentes

**NO modificar, leer ni actuar sobre archivos que pertenezcan a otros agentes** (ej: task_plan.md de otros subagents). Solo trabajar en archivos propios de esta sesión.

---

## Principio

**Mismo objetivo, menos palabras.** El receptor debe entender qué vas a hacer, no cómo lo vas a hacer en detalle.

## Regla General

```
[verbo] [objeto] [contexto opcional]
```

| Verboso | Conciso |
|---------|---------|
| "Voy a explorar ambas pantallas para entender los patrones de diseño actuales y los problemas mencionados." | "explorar pantallas y problemas" |
| "Voy a buscar las funciones que hacen Y" | "buscar funciones Y" |
| "Necesito entender cómo funciona Z" | "entender función Z" |
| "Voy a modificar el código para que haga W" | "modificar para W" |
| "Primero voy a revisar los tests" | "revisar tests" |
| "Voy a ejecutar el comando para ver el resultado" | "ejecutar comando" |
| "Voy a escribir un test que verifique X" | "escribir test para X" |

## Equivalencias por Contexto

### Inicio de Tarea
| Verboso | Conciso |
|---------|---------|
| "Voy a comenzar explorando el codebase" | "explorar codebase" |
| "Primero necesito entender la estructura" | "entender estructura" |
| "Voy a revisar el archivo para ver qué contiene" | "leer archivo" |
| "Necesito explorar qué funciones hay disponibles" | "buscar funciones" |

### Acción Técnica
| Verboso | Conciso |
|---------|---------|
| "Voy a buscar en el archivo" | "buscar en archivo" |
| "Ejecutaré los tests" | "ejecutar tests" |
| "Voy a editar el archivo para hacer el cambio" | "editar archivo" |
| "Necesito ver la estructura del proyecto" | "ver estructura proyecto" |

### Transición
| Verboso | Conciso |
|---------|---------|
| "Ahora voy a proceder con la implementación" | "implementar" |
| "Después de esto voy a verificar" | "verificar" |
| "Vamos a pasar a la siguiente fase" | "siguiente fase" |
| "Una vez completado esto, haré la integración" | "integrar cambios" |

## Formato de Output

### ❌ Evitar
```
Voy a explorar ambas pantallas para entender los patrones de diseño actuales y los problemas mencionados.
Necesito primero revisar la estructura del proyecto para entender cómo está organizado.
Después de eso, voy a buscar las funciones que manejan la autenticación.
```

### ✅ Preferir
```
explorar pantallas y problemas
revisar estructura proyecto
buscar funciones auth
```

### ✅ Alternativo (si se necesita más contexto)
```
explorar: pantallas + problemas mencionados
revisar: estructura del proyecto
buscar: funciones auth
```

## Excepciones

Mantener detalle cuando:
- El usuario pide explicación explícitamente
- Hay decisión importante que requiere justificación
- Hay riesgo de malinterpretar la acción
- Feedback de error que necesita contexto

## Con Clauses

| Forma Larga | Forma Corta |
|-------------|-------------|
| "Voy a leer el archivo porque necesito entender la estructura" | "leer archivo" |
| "Primero voy a buscar las funciones porque necesito saber dónde hacer el cambio" | "buscar funciones" |
| "Después de explorar el código, voy a proceder a modificar" | "explorar → modificar" |

## En Resumen

1. **Eliminar subject** (yo, nosotros)
2. **Eliminar adverbios** (primero, ahora, después)
3. **Eliminar conectores** (porque, para)
4. **Quedarse con núcleo**: verbo + objeto

---

**Nota:** Esto aplica a输出 textuales hacia el usuario. Código y comments mantienen su estilo normal.
