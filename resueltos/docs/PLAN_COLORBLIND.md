# Plan: Color-Blind Accessibility

## Objetivo
Agregar soporte para `accessibilityDifferentiateWithoutColor` en toda la app.

## Archivos a modificar

### GameState.swift
- Agregar propiedad `icon` a `ChecklistPriority` enum

### SimulationView.swift (CRITICO - quiz)
- Agregar `@Environment(\.accessibilityDifferentiateWithoutColor)`
- Mostrar icono minus en opciones no seleccionadas cuando timedOut/differentiateWithoutColor
- Agregar badges "CORRECT"/"WRONG" texto cuando differentiateWithoutColor
- Bordes: solid grueso para correcto, dashed para incorrecto

### ResultView.swift
- Agregar `@Environment(\.accessibilityDifferentiateWithoutColor)`
- Badges texto en response rows
- Bordes diferenciados (solid vs dashed)
- Icono en score ring

### ChecklistView.swift
- Agregar `@Environment` en ChecklistView, CategoryCard, ChecklistItemRow, CheckboxView
- Priority headers: usar iconos en vez de solo dots de color
- CategoryCard: agregar "DONE" label
- CheckboxView: indicador visual para unchecked

### LearnView.swift
- Agregar `@Environment`
- Bold + strikethrough en fases completadas
- Borde en boton "Mark as Read" completado

### SceneIllustration.swift (CountdownTimerView)
- Icono de urgencia que cambia segun tiempo restante
