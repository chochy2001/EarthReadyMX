# Plan: Flow Reorder + Polish Fixes

## Nuevo Flujo de Navegación
```
splash → story → simulation → result → learn → kitBuilder/drill → checklist → completion
```

### Justificación del Reorden
1. Splash: Impacto visual, seismógrafo interactivo
2. Story: Contexto emocional del sismo 2017 (motiva al usuario)
3. Simulation: Quiz inmediato (prueba conocimientos ANTES de enseñar)
4. Result: Muestra score, revela que hay mucho por aprender
5. Learn: Safety protocols (ahora el usuario QUIERE aprender porque falló el quiz)
6. KitBuilder/Drill: Práctica interactiva
7. Checklist: Preparación personal
8. Completion: Pantalla de celebración final

## Cambios de Navegación

### GameState.swift
- Add `case story` and `case completion` to AppPhase
- Flow: splash → story → simulation → result → learn → ... → completion

### ContentView.swift
- Add case .story and .completion

### SplashView.swift
- "Start Learning" button text → "Begin" or "Start"
- Action: → .story (not .learn)

### StoryView.swift (NEW)
- Last slide button → .simulation

### SimulationView.swift
- After last scenario → .result (already works)

### ResultView.swift
- Remove "Start Over" for now
- Primary button: "Learn Safety Protocols" → .learn
- Secondary buttons: "Build Your Kit" → .kitBuilder, "Practice Drill" → .drill
- Add "Skip to Checklist" → .checklist

### LearnView.swift
- After completing all 3 phases:
- Button: "Practice What You Learned" → .kitBuilder or .checklist
- Remove "Test Yourself" button (quiz was already done)

### ChecklistView.swift
- When 100% complete: show "Complete" button → .completion

## Completion Screen (CompletionView.swift - NEW)

### Diseño
- Celebratory animation (confetti/particles)
- "You're Earthquake Ready!" title
- Summary stats:
  - Quiz score
  - Kit builder stars
  - Drill completed
  - Checklist 100%
- Haptic: playPerfectScore()
- Sound: playCelebration(100)
- Buttons:
  - "Share Your Achievement" (ShareLink)
  - "Practice Again" → resetQuiz() → .simulation
  - "Start Over" → resetAll() → .splash

## Polish Fixes

### 1. Pre-warm SpeechManager
- In SpeechManager.init(), speak an empty string to initialize TTS engine
- Eliminates 200-500ms lag on first drill instruction

### 2. Reset Confirmation
- Before resetAll(), show alert/confirmation
- "Are you sure? This will reset all progress."

### 3. Better Text Truncation
- ResultView line ~121: Use full text or smart truncation
- LearnView line ~253: Same

### 4. Drill Phase VoiceOver Labels
- Progress dots should announce phase name
- "Phase 5 of 10: Hold On phase"
