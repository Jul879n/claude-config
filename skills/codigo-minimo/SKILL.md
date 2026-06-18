---
name: codigo-minimo
description: Use when about to write any code — enforces minimum-code discipline before implementation begins. Applies always.
---

# Código Mínimo

Antes de escribir código, recorre esta escalera. Detente en el primer peldaño que resuelva el problema:

```
1. ¿Necesita existir?            → no: omítelo (YAGNI)
2. ¿Lo resuelve el lenguaje/stdlib? → úsalo
3. ¿Lo resuelve una feature nativa del runtime/DOM? → úsala
4. ¿Ya está instalada una dependencia que lo hace? → úsala
5. ¿Existe un componente en src/components/ui/?    → reutilízalo
6. ¿Es una línea?                → una línea
7. Solo entonces: el mínimo que funciona
```

**Nunca recortar:** validación en límites del sistema (input de usuario, APIs externas), manejo de errores reales (no hipotéticos), seguridad, accesibilidad.

## Red flags — detente si piensas:

| Pensamiento | Realidad |
|---|---|
| "Necesito un wrapper para esto" | ¿Seguro? Revisa peldaños 2-5 primero |
| "Voy a crear un componente nuevo" | ¿Buscaste en `src/components/ui/`? |
| "Instalo esta librería para X" | ¿X ya existe en el proyecto? |
| "Agrego manejo de error por si acaso" | Solo si el caso realmente ocurre |
| "Lo hago genérico para el futuro" | YAGNI. El futuro no ha llegado |

El código que nunca se escribe no tiene bugs.
