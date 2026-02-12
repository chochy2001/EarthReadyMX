# Plan: Storytelling Animation - 2017 Mexico City Earthquake

## Objetivo
Crear una secuencia animada cinematográfica en SwiftUI puro que cuente la historia
del sismo de 2017 antes del quiz. Impacto emocional + educativo.

## Por qué SwiftUI nativo (NO video)
- Zero bundle size (todo es código)
- Demuestra maestría Swift ante jueces SSC
- Interactivo (responde a touches, VoiceOver)
- Renderiza a resolución nativa en cualquier dispositivo
- Ningún ganador SSC ha usado videos pre-renderizados

## Datos del Sismo 2017

### Hechos clave
- Fecha: September 19, 2017, 1:14 PM
- Magnitud: 7.1 Mw
- Epicentro: ~120 km de CDMX (cerca de Puebla)
- Duración del temblor: ~20 segundos
- Muertes: 370 personas
- Edificios colapsados en CDMX: 44+
- Edificios dañados: 12,000+
- Heridos: 6,000+
- Misma fecha que sismo de 1985 (32 años después)
- Simulacro nacional fue 2 horas antes (11:00 AM)
- Alerta SASMEX llegó simultáneamente con el temblor (inútil por cercanía del epicentro)
- 91% edificios colapsados construidos antes de 1985

### Timeline
- 11:00 AM - National earthquake drill
- 1:14:40 PM - Earthquake strikes
- 1:15 PM - Strong shaking in CDMX, buildings collapse
- Zero effective warning time

## Nuevo Flujo de App
```
Splash → StoryView (NEW) → Simulation (quiz) → Result → Learn (safety) → KitBuilder → Drill → Checklist
```

## Diseño de StoryView

### Estructura: Secuencia de "slides" animados
Cada slide tiene texto + animación + haptic + sonido.
Auto-advance con delays, con opción de tap to skip.

### Slide 1: "September 19, 2017" (3s)
- Texto grande aparece con fade
- Subtexto: "Mexico City" aparece con delay
- Fondo: Dark, subtle pulse
- Sonido: Silencio, ambiente tenso

### Slide 2: "11:00 AM - A National Drill" (3s)
- Texto: "That morning, millions practiced an earthquake drill."
- Subtexto: "32 years after the devastating 1985 earthquake."
- Animación: Calm seismograph line

### Slide 3: "1:14 PM - Without Warning" (4s)
- Texto: "A 7.1 magnitude earthquake struck."
- Animación: Seismograph spikes violently
- Haptic: Earthquake pattern
- Sound: Seismic alert
- ShakeEffect on the entire view

### Slide 4: "The Numbers" (5s)
- Animated counters counting up:
  - "370" lives lost (count from 0)
  - "44" buildings collapsed
  - "6,000+" injured
- Cada número aparece secuencialmente
- Haptic: Subtle pulse per number

### Slide 5: "The Alert Arrived Too Late" (3s)
- Texto: "The seismic alert arrived at the same time as the earthquake."
- Subtexto: "The epicenter was too close. There was no time."
- Animación: Alert icon + simultaneous shake

### Slide 6: "Preparedness Saves Lives" (3s)
- Texto: "The difference between survival and tragedy is preparation."
- Subtexto: "Are you ready?"
- Animación: Transition from red/dark to orange/hopeful
- Button: "Test Your Knowledge" → goes to simulation/quiz

### Técnicas de Animación

**Typewriter text**: Timer-driven character reveal
```swift
@State private var displayedChars = 0
Text(String(fullText.prefix(displayedChars)))
// Timer increments displayedChars every 0.03s
```

**Animated number counter**: .contentTransition(.numericText()) iOS 16+
```swift
Text("\(count)")
    .contentTransition(.numericText())
    .animation(.easeInOut(duration: 1.5), value: count)
```

**Sequential slide advance**: DispatchQueue.main.asyncAfter chain
(same pattern as existing SplashView.startAnimationSequence())

**Screen shake**: Existing ShakeEffect modifier

**Seismograph**: Existing SeismographView component

## Archivos

### StoryView.swift (NEW)
- ~200-300 lines
- @EnvironmentObject var gameState, hapticManager, soundManager, motionManager
- @State private var currentSlide: Int = 0
- @State private var animationStates for each slide
- Auto-advance with asyncAfter
- "Skip" button always visible (for judges who've seen it before)
- Accessibility: announceScreenChange per slide, reduceMotion support
- iPad: .frame(maxWidth: 600)

### GameState.swift
- Add `case story` to AppPhase
- Reorder flow: splash → story → simulation → result → learn → kitBuilder → drill → checklist

### ContentView.swift
- Add case .story: StoryView()

### SplashView.swift
- Change "Start Learning" button to go to .story instead of .learn

### ResultView.swift
- "Learn Safety Protocols" button goes to .learn
- Keep existing buttons for kitBuilder and drill
