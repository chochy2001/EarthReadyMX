# Plan: Data Persistence

## Objetivo
Persistir estado del checklist y mejor score con UserDefaults.

## Enfoque
- UserDefaults con keys basadas en titulo (category::item)
- Guardar en cada toggle + en scenePhase .background
- Cargar en init de GameState

## Archivos a modificar

### GameState.swift
- Agregar constantes `checklistKey` y `bestScoreKey`
- Agregar `stableKey(categoryTitle:itemTitle:)` helper
- Agregar `saveChecklistState()` - guarda array de keys completados
- Agregar `loadChecklistState()` - restaura isCompleted flags
- Agregar `saveBestScoreIfNeeded()` - guarda mejor score
- Agregar `bestScore` computed property
- Modificar `init()` para llamar `loadChecklistState()`
- Modificar `toggleChecklistItem()` para llamar `saveChecklistState()`
- Modificar `answerScenario()` para llamar `saveBestScoreIfNeeded()` en ultimo scenario
- Modificar `reset()` para limpiar UserDefaults key (no el best score)

### MyApp.swift
- Agregar `@Environment(\.scenePhase)`
- Agregar `.onChange(of: scenePhase)` para guardar en background
