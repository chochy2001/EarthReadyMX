---
name: earthready
description: Guidelines for EarthReady MX iOS earthquake preparedness app (Swift 6 + SwiftUI + CoreHaptics + AVFoundation)
---

# EarthReady MX Development Guidelines

Immersive earthquake preparedness iOS app for Swift Student Challenge 2026. Zero external dependencies.

## Tech Stack
- **Language**: Swift 6.0 (strict concurrency)
- **UI**: SwiftUI (iOS 16+, iPhone + iPad)
- **Audio**: AVAudioEngine real-time synthesis (no audio files)
- **Haptics**: CoreHaptics (6 distinct earthquake patterns)
- **Motion**: CoreMotion accelerometer (live seismograph)
- **Speech**: AVSpeechSynthesizer (drill narration)
- **State**: @StateObject + @EnvironmentObject via GameState

## Commands
- Build: `swift build`
- Test: `swift test`

## Conventions
- ZERO external dependencies. Only Apple-native frameworks.
- ZERO bundled media. All audio synthesized, all graphics via SF Symbols + SwiftUI shapes.
- Swift 6 strict concurrency: Use @MainActor for UI, @Sendable for closures, nonisolated where needed.
- Accessibility: Full VoiceOver, Reduce Motion, Dynamic Type support.
- Project size must stay under 25MB (SSC requirement).
- Central state in GameState.swift. All views observe via @EnvironmentObject.
