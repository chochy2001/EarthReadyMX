# EarthReady MX

An immersive earthquake preparedness app that transforms passive learning into a multisensory experience. Built entirely with SwiftUI for the Swift Student Challenge 2026.

## About

Mexico sits on three tectonic plates, making it one of the most seismically active countries in the world. The devastating 2017 Puebla earthquake (7.1 magnitude) killed 370 people and collapsed 44 buildings in Mexico City. EarthReady MX was inspired by that tragedy.

**EarthReady MX** goes beyond traditional quiz-based learning by combining cinematic storytelling, real-time audio synthesis, haptic feedback, interactive mini-games, guided emergency drills, and actionable preparedness checklists — all within a single App Playground.

## Features

### Cinematic Storytelling
- **6-slide animated narrative** about the 2017 Mexico City earthquake
- Typewriter text effects, animated impact counters, and screen shake
- SASMEX-style seismic alert sound synchronized with the story
- Sets the emotional context before the interactive learning begins

### Interactive Earthquake Simulation
- **5 randomized emergency scenarios** with shuffled answer options
- **15-second countdown timer** creating real-time pressure
- **Scene illustrations** built entirely with SF Symbols and SwiftUI shapes
- Visual feedback with color-coded responses (correct/incorrect)

### Emergency Kit Builder
- **19 items** to evaluate: 10 essential, 6 dangerous, 3 distractors
- **Tap or drag-and-drop** items into a virtual backpack using native iOS drag APIs
- Educational feedback explaining why each item is essential, dangerous, or unnecessary
- Star rating system based on accuracy
- Items randomized each session

### Guided Emergency Drill
- **10-phase timed drill** simulating a real earthquake emergency
- **Text-to-speech narration** guides users through each phase (Drop, Cover, Hold On, Evacuate, Rally Point)
- Synchronized haptic feedback and earthquake rumble audio
- Visual progress tracking with phase indicators

### Real-Time Audio Synthesis
- **SASMEX-style seismic alert** (alternating 950/1200 Hz tones)
- **Earthquake rumble** with sub-bass oscillators and noise generation
- **Correct/incorrect/celebration sounds** adapting to performance
- All audio generated programmatically using `AVAudioEngine` with a multi-oscillator architecture — zero audio files bundled

### CoreHaptics Integration
- **6 distinct haptic patterns** designed to enhance the experience
- Earthquake simulation haptics with increasing intensity
- Success and failure tactile feedback
- Celebration patterns for achievements

### CoreMotion Seismograph
- **Real accelerometer data** displayed as a live seismograph on the splash screen
- Low-pass filtered at 50Hz for smooth readings
- Graceful fallback on simulator with synthetic data

### Preparedness Checklist
- **34 real preparedness items** sourced from FEMA Ready.gov and CENAPRED Mexico
- **3 categories**: Emergency Kit, Home Safety, Family Emergency Plan
- **Priority levels**: Critical, Important, Recommended
- Persistent progress tracking with UserDefaults
- Practical, actionable items for real-life implementation

### Accessibility
- **Full VoiceOver support** across all views with descriptive labels, hints, and traits
- **Reduce Motion** support — animations replaced with immediate content display
- **Differentiate Without Color** — text labels supplement color-coded feedback
- **Dynamic Type** support for scalable text
- **Accessibility announcements** for screen and state changes

## Technical Highlights

| Metric | Value |
|--------|-------|
| Swift version | 6.0 (strict concurrency) |
| Minimum iOS | 16.0 |
| Source files | 21 |
| Lines of code | ~7,500 |
| Project size | < 3 MB |
| External dependencies | None |
| External images/audio | None |

### Architecture
- **SwiftUI** for all UI with `@EnvironmentObject` dependency injection
- **CoreHaptics** with `CHHapticEngine` for tactile earthquake simulation
- **AVFoundation** with `AVAudioEngine` + `AVAudioSourceNode` for real-time audio synthesis
- **AVFoundation** with `AVSpeechSynthesizer` for guided drill narration
- **CoreMotion** with `CMMotionManager` for live accelerometer seismograph
- **Swift 6 strict concurrency** with `@MainActor`, `Sendable`, `@Sendable`, and `nonisolated` for thread safety
- **Canvas + TimelineView** for particle effects

### Frameworks Used
- SwiftUI
- CoreHaptics
- AVFoundation
- CoreMotion
- Accessibility (UIAccessibility)

## App Flow

```
Splash Screen (interactive seismograph)
    → Cinematic Story (2017 earthquake narrative)
    → Emergency Quiz (5 randomized scenarios with timer)
    → Results Hub
        → Learn Safety Protocols (Before/During/After phases)
        → Build Your Emergency Kit (drag-and-drop mini-game)
        → Practice Emergency Drill (10-phase guided drill)
        → Preparedness Checklist (34 actionable items)
    → Completion Celebration
```

## Data Sources

All preparedness information is based on official guidelines from:
- **FEMA Ready.gov** — Federal Emergency Management Agency (United States)
- **CENAPRED** — Centro Nacional de Prevencion de Desastres (Mexico)
- **SENAPRED** — Servicio Nacional de Prevencion y Respuesta ante Desastres (Chile)

## Author

**Jorge Salgado Miranda**
UNAM (Universidad Nacional Autonoma de Mexico)
