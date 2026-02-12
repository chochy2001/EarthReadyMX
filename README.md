# EarthReady MX

An immersive earthquake preparedness app that transforms passive learning into a multisensory simulation experience. Built entirely with SwiftUI for the Swift Student Challenge 2025.

## About

Mexico sits on three tectonic plates, making it one of the most seismically active countries in the world. The devastating 2017 Puebla earthquake (7.1 magnitude) killed 370 people, and the 2023 Guerrero earthquake reminded us that preparedness saves lives.

**EarthReady MX** goes beyond traditional quiz-based learning by combining visual simulations, real-time audio synthesis, haptic feedback, and actionable preparedness checklists — all within a single App Playground.

## Features

### Immersive Earthquake Simulation
- **5 illustrated emergency scenarios** built entirely with SF Symbols and SwiftUI shapes — no external images
- **15-second countdown timer** per scenario creating real-time pressure, simulating the urgency of actual earthquake response
- **Scene illustrations** that shake and respond to the earthquake simulation
- Visual feedback with color-coded responses (correct/incorrect)

### Real-Time Audio Synthesis
- **SASMEX-style seismic alert** sound during the splash screen (alternating 950/1200 Hz tones)
- **Earthquake rumble** with sub-bass oscillators and noise generation during simulations
- **Correct/incorrect answer sounds** providing immediate auditory feedback
- **Score-based celebration** audio that adapts to performance
- All audio generated programmatically using `AVAudioEngine` with a multi-oscillator architecture — zero audio files bundled

### CoreHaptics Integration
- **6 distinct haptic patterns** designed to enhance the simulation experience
- Earthquake simulation haptics with increasing intensity
- Success and failure tactile feedback
- Celebration patterns for perfect scores

### Preparedness Checklist
- **34 real preparedness items** sourced from FEMA Ready.gov and CENAPRED Mexico
- **3 categories**: Emergency Kit, Home Safety, Family Emergency Plan
- **Priority levels**: Critical, Important, Recommended
- Interactive progress tracking with visual indicators
- Practical, actionable items that users can implement in real life

### Accessibility
- **Full VoiceOver support** across all 5 views with descriptive labels, hints, and traits
- **Reduce Motion** support — animations are replaced with immediate content display
- **Accessibility announcements** for screen and state changes
- Decorative elements properly hidden from assistive technologies

## Technical Highlights

| Metric | Value |
|--------|-------|
| Swift version | 6.0 (strict concurrency) |
| Minimum iOS | 16.0 |
| Source files | 15 |
| Lines of code | ~3,900 |
| Project size | < 1 MB |
| External dependencies | None |
| External images/audio | None |

### Architecture
- **SwiftUI** for all UI with `@EnvironmentObject` dependency injection
- **CoreHaptics** with `CHHapticEngine` for tactile earthquake simulation
- **AVFoundation** with `AVAudioEngine` + `AVAudioSourceNode` for real-time audio synthesis
- **Swift 6 strict concurrency** with `@MainActor`, `Sendable`, and `nonisolated(unsafe)` for audio thread safety
- **Canvas + TimelineView** for particle effects

### Frameworks Used
- SwiftUI
- CoreHaptics
- AVFoundation
- Accessibility (UIAccessibility)

## App Flow

```
Splash Screen → Learn (Before/During/After earthquake phases)
    → Emergency Simulation (5 scenarios with timer)
    → Results (score + key takeaways)
    → Preparedness Checklist (34 actionable items)
```

## Data Sources

All preparedness information is based on official guidelines from:
- **FEMA Ready.gov** — Federal Emergency Management Agency (United States)
- **CENAPRED** — Centro Nacional de Prevencion de Desastres (Mexico)

## Author

**Jorge Salgado Miranda**
UNAM (Universidad Nacional Autonoma de Mexico)
