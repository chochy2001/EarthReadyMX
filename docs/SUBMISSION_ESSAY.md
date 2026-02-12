# EarthReady MX - Swift Student Challenge 2026

**Jorge Salgado Miranda**
**UNAM (Universidad Nacional Autonoma de Mexico)**

---

## 1. Describe Your App (500 words)

On September 19, 2017, I was sitting in my high school classroom in Mexico City when the floor began to shake. A 7.1 magnitude earthquake had struck -- on the exact anniversary of the devastating 1985 earthquake. That morning, millions of us had just completed a national drill. Hours later, the real thing hit.

No public transportation was available. I walked home, far from school, past fallen buildings, broken glass, and people crying in the streets. What struck me most was the contrast: some blocks were devastated -- and just a few streets over, everything looked untouched. The same earthquake, entirely different outcomes depending on where you were and how prepared you were.

That walk changed how I think about preparedness. I built EarthReady MX because the gap between knowing what to do and actually doing it is the gap that kills people.

EarthReady MX is a multisensory earthquake preparedness app built entirely as a Swift App Playground. It opens with a cinematic six-slide narrative about September 19, 2017 -- typewriter effects, animated counters, screen shake -- placing the user inside the moment that changed Mexico. Then it transitions into an interactive emergency simulation: five randomized scenarios where users must choose the correct response under a 15-second countdown while CoreHaptics shakes their device and a synthesized earthquake rumble plays through AVAudioEngine. After the quiz, users build a virtual emergency kit by dragging items into a backpack, distinguishing essentials from dangerous distractors. A multi-country seismic zone explorer lets users check the risk level for any state in Mexico, the USA, Chile, or Japan -- with color-coded classifications, historical earthquake data, and zone-specific safety advice. A room safety scanner uses the Vision framework to analyze photos of any room for earthquake hazards -- unsecured bookshelves, heavy fixtures, fragile items -- generating a safety score with actionable recommendations. A 34-item checklist sourced from FEMA, CENAPRED, and SENAPRED follows, organized by priority. Finally, a guided 10-phase emergency drill with text-to-speech voice commands walks users through Drop, Cover, Hold On, hazard check, and evacuation.

Every sound is synthesized in real time using AVAudioSourceNode with a four-oscillator architecture -- the splash screen reproduces SASMEX, Mexico's Seismic Alert System tones, and sub-bass oscillators create earthquake rumble. I solved a Swift 6 concurrency crash by isolating the audio render callback outside @MainActor, using raw UnsafeMutablePointers to eliminate ARC on the real-time thread. Zero audio files are bundled. Every illustration uses SF Symbols, every haptic pattern is crafted through CoreHaptics.

The project integrates seven Apple frameworks -- SwiftUI, CoreHaptics, AVFoundation, CoreMotion, Vision, PhotosUI, and Accessibility -- across 25 source files and ~10,000 lines of code, under 3 MB, with zero external dependencies. Accessibility was foundational: VoiceOver with semantic labels, Reduce Motion alternatives, Differentiate Without Color, and Dynamic Type throughout.

In Mexico, we say "no estamos preparados, pero somos solidarios" -- we are not prepared, but we stand together. EarthReady MX is my attempt to make us both.

---

## 2. Beyond WWDC (200 words)

At UNAM, I have seen firsthand how technology can bridge the gap between institutional knowledge and the communities that need it most. Government agencies like CENAPRED and FEMA publish excellent preparedness guidelines, but they sit in PDFs and brochures that most people never read. I want to bring that knowledge into people's hands through experiences they will remember.

If given the opportunity to attend WWDC, I plan to connect with developers working on accessibility and disaster preparedness to explore how EarthReady MX can expand beyond Mexico. The architecture is already designed for it -- the checklist data, scenarios, and guidelines are modular and can adapt to any seismically active country. I want to release EarthReady MX on the App Store, localized for Mexico, the United States, Chile, and Japan, with region-specific emergency protocols and alert systems.

Beyond this app, I want to contribute to the developer community by sharing what I learned about real-time audio synthesis in Swift 6, a topic with very little documentation. The concurrency challenges I solved -- isolating render callbacks from @MainActor, eliminating ARC on audio threads -- are problems other developers face, and I want to help them avoid the crashes I spent weeks debugging.

---

## 3. App Description (one sentence)

EarthReady MX is an immersive earthquake preparedness app that combines real-time audio synthesis, haptic simulation, and interactive emergency scenarios to transform passive safety knowledge into practiced, life-saving instincts.
