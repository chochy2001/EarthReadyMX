# Plan: Simulacro de Emergencia Guiado con Audio

## Objetivo
Modo "Drill" cronometrado con guía por voz (TTS), haptics y visuales sincronizados.
El usuario practica los pasos de un simulacro de sismo real siguiendo instrucciones de audio.
Hands-free design inspirado en "Fast Aid" (SSC 2025 Distinguished Winner).

## Investigación Clave

### AVSpeechSynthesizer
- Parte de AVFoundation (ya importado por SoundManager)
- Zero bytes adicionales en bundle (framework del sistema)
- Voz `es-MX` disponible en todos los dispositivos iOS
- `usesApplicationAudioSession = true` → coexiste con AVAudioEngine
- Delegate callbacks: `didFinish` para avanzar pasos, `willSpeakRange` para highlighting
- SSC 25MB limit: sin impacto (no hay archivos de audio)

### Swift 6
- `AVSpeechSynthesizerDelegate` es protocolo Obj-C
- Delegate methods marcados `nonisolated` + `Task { @MainActor in }` para updates
- Clase @MainActor siguiendo patrón de SoundManager
- `synthesizer` como propiedad de instancia (NO variable local, crashea en iOS 16.0)

### Accesibilidad
- Si VoiceOver está activo: NO usar AVSpeechSynthesizer (overlap)
- Fallback: `UIAccessibility.post(notification: .announcement, argument:)`
- Usar AccessibilityAnnouncement existente
- Diseño hands-free: auto-advance sin tocar pantalla
- Único botón: "STOP" grande (44pt mínimo) para abortar

### Protocolo CENAPRED
- "Agacharse, Cubrirse, Sujetarse" (Drop, Cover, Hold On)
- Basado en simulacros nacionales del 19 de septiembre
- SASMEX: 40-60 segundos de alerta antes de ondas sísmicas
- Post-sismo: revisar gas, cables, daños → evacuar → punto de reunión

### Audio Session
- SoundManager ya configura `.playback` + `.mixWithOthers`
- TTS coexiste con oscillator engine
- Bajar volumen del engine durante TTS para claridad de voz
- `engine.mainMixerNode.outputVolume = 0.15` durante speech

## Archivos Nuevos

### SpeechManager.swift
```
@MainActor final class SpeechManager: NSObject, ObservableObject, AVSpeechSynthesizerDelegate
  - private let synthesizer = AVSpeechSynthesizer()
  - @Published var isSpeaking: Bool = false
  - @Published var currentWordRange: NSRange?
  - private var onFinished: (() -> Void)?
  - func speak(text:, language: "es-MX", rate: 0.48, onFinished:)
  - func stop()
  - VoiceOver fallback: UIAccessibility.post si isVoiceOverRunning

  nonisolated delegate methods:
  - didFinish → Task { @MainActor in self.onFinished?() }
  - willSpeakRange → Task { @MainActor in self.currentWordRange = range }
```

### DrillView.swift
- Vista principal del simulacro
- `@EnvironmentObject var gameState, hapticManager, soundManager, speechManager`
- `@State private var drillPhase: DrillPhase`
- `@State private var timeInPhase: TimeInterval`
- `@State private var isActive: Bool`
- Full-screen dark UI con indicadores grandes
- Auto-advance: fases avanzan por TTS didFinish + timers
- Botón STOP siempre visible

**DrillPhase enum:**
```swift
enum DrillPhase: Int, CaseIterable, Sendable {
    case briefing       // 10s - Preparación
    case alert          // 8s  - ¡Alerta sísmica!
    case drop           // 8s  - ¡Agáchate!
    case cover          // 10s - ¡Cúbrete!
    case holdOn         // 20s - ¡Sujétate!
    case shakingStops   // 5s  - Cesa el movimiento
    case check          // 10s - Verificar peligros
    case evacuate       // 8s  - Evacuar
    case rallyPoint     // 5s  - Punto de reunión
    case complete       // 6s  - ¡Completado!
}
```

**Sub-componentes:**
- `DrillPhaseIndicator` - Ícono grande animado por fase
- `DrillProgressBar` - Barra de progreso de las 10 fases
- `DrillInstructionText` - Texto con word highlighting del TTS

## Archivos a Modificar

### GameState.swift
- Agregar `case drill` a `AppPhase` enum
- Agregar `@Published var drillCompleted: Bool = false`

### ContentView.swift
- Agregar case `.drill: DrillView()` con transition

### MyApp.swift
- Agregar `@StateObject private var speechManager = SpeechManager()`
- Pasar como `.environmentObject(speechManager)`

### HapticManager.swift
- Agregar `playAlertPulse()` - pulsos de alerta urgente
- Agregar `playDropImpact()` - impacto fuerte hacia abajo
- Agregar `playEvacuationRhythm()` - taps rítmicos (pasos)

### SoundManager.swift
- Agregar `func setVolume(_ volume: Float)` para duck durante TTS
- Agregar `func playAllClear()` - tono de "todo seguro"

### ResultView.swift o ChecklistView.swift
- Agregar botón "Practice Drill" que navega a `.drill`

## Secuencia del Simulacro (~90 segundos)

| Fase | Duración | TTS (es-MX) | Haptic | Audio |
|------|----------|-------------|--------|-------|
| Briefing | 10s | "Simulacro de sismo. Prepárate..." | Ninguno | Ninguno |
| Alert | 8s | "¡Alerta sísmica!" | Pulsos agudos | playSeismicAlert() |
| Drop | 8s | "¡Agáchate! Ponte de rodillas..." | Impacto fuerte | Rumble bajo |
| Cover | 10s | "¡Cúbrete! Protege tu cabeza..." | Rumble continuo | playEarthquakeRumble() |
| Hold On | 20s | "¡Sujétate!..." (intercalado) | Earthquake full | Rumble + aftershocks |
| Shaking Stops | 5s | "El movimiento ha cesado." | Fade out | Rumble fade |
| Check | 10s | "Revisa si hay peligros..." | Taps de atención | Tono calmo |
| Evacuate | 8s | "Evacúa con calma..." | Taps rítmicos | Beep guía |
| Rally Point | 5s | "Punto de reunión..." | Double-tap | Success tone |
| Complete | 6s | "¡Simulacro completado!" | Celebración | playAllClear() |

## Sincronización
- **Event-driven state machine**: avance por `didFinish` del TTS, NO por timers fijos
- Cada fase: TTS habla → callback didFinish → esperar N segundos → siguiente fase
- `holdOn` es especial: TTS intercalado con pausas de 5s (sismo simulado)
- Timer maestro cada 0.1s para actualizar `timeInPhase` y countdown visual

## Manejo de Interrupciones
- scenePhase .background → pausar drill + TTS
- Al volver: mostrar "Resume Drill" (no auto-resume)
- Botón STOP: detiene todo inmediatamente, muestra resumen parcial
