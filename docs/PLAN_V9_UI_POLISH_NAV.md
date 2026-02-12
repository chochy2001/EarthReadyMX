# Plan V9: UI Polish & Navigation Consistency

## Resumen

Mejorar padding de botones en ResultView cuando estan completos (rellenos),
agregar "Back to Results" en KitBuilderView, y unificar flujo de navegacion.

---

## Fix 1: Padding en sectionButton de ResultView

**Archivo**: `ResultView.swift`, metodo `sectionButton` (~linea 291-303)

**Problema**: El HStack no tiene padding horizontal. Cuando el boton esta
relleno (completo), el icono izquierdo y el checkmark derecho quedan pegados
a los bordes del gradiente.

**Fix**: Agregar `.padding(.horizontal, 16)` despues de `.padding(.vertical, 14)`.

---

## Fix 2: "Back to Results" en KitBuilderView

**Archivo**: `KitBuilderView.swift`, `resultsOverlay` (~lineas 385-426)

**Problema**: Despues de completar el kit, solo hay 2 botones:
- "Continue to Checklist"
- "Try Again"
No hay forma de volver a ResultView.

**Fix**: Agregar un tercer boton "Back to Results" con el mismo estilo que
DrillView usa (lineas 652-674 de DrillView.swift como referencia):

```swift
Button(action: {
    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
        gameState.currentPhase = .result
    }
}) {
    HStack(spacing: 8) {
        Image(systemName: "arrow.left")
        Text("Back to Results")
            .font(.system(.footnote, design: .rounded, weight: .semibold))
    }
    .foregroundColor(.white.opacity(0.7))
    .frame(maxWidth: .infinity)
    .padding(.vertical, 12)
    .background(Color.white.opacity(0.08))
    .clipShape(RoundedRectangle(cornerRadius: 14))
}
.accessibilityHint("Double tap to return to results")
```

---

## Fix 3: Flujo de navegacion en ChecklistView

**Archivo**: `ChecklistView.swift`

**Problema**: Cuando el usuario ya completo todas las secciones (Learn, Kit,
Drill, Seismic, Room Scanner), el ChecklistView todavia muestra botones como
"Practice Drill", "Build Your Kit", etc. que ya no tienen sentido si ya estan
completas.

**Fix**: Condicionar la visibilidad de los botones de seccion segun si ya
estan completadas. Si todas estan completas, solo mostrar "Back to Results"
y el boton "I'm Ready!" (cuando checklist este al 100%).

---

## Orden de Implementacion

### Agente 1: ResultView padding fix
- Archivo: `ResultView.swift`
- Cambio: Agregar `.padding(.horizontal, 16)` en sectionButton

### Agente 2: KitBuilderView "Back to Results"
- Archivo: `KitBuilderView.swift`
- Cambio: Agregar boton "Back to Results" en resultsOverlay

### Agente 3: ChecklistView nav buttons cleanup
- Archivo: `ChecklistView.swift`
- Cambio: Condicionar botones de secciones completas

---

## Criterios de Aceptacion

- [ ] Botones de seccion en ResultView tienen padding horizontal adecuado
- [ ] KitBuilderView tiene "Back to Results" en pantalla de completado
- [ ] Typecheck pasa sin errores
