# Plan V6 - New Features & Submission Essay

## Feature 1: Seismic Zone Map (Multi-Country)

### Requirements
- User selects Country → State/Region
- Countries to support: Mexico, USA, Chile, Japan (at minimum)
- Show seismic zone classification and risk level
- Color-coded risk visualization
- If low-risk area: suggest exploring Mexico's zones for the full experience
- Tailored safety recommendations based on zone
- 100% offline, works in simulator
- All data embedded as Swift code (no external files)
- Accessible (VoiceOver, Dynamic Type)

### Data Needed
- Mexico: 4 zones (A/B/C/D) from CENAPRED, 32 states
- USA: Seismic zones from USGS, 50 states
- Chile: Zones from SENAPRED
- Japan: Zones from JMA (Japan Meteorological Agency)

### UI Concept
- New phase in app flow OR accessible from ResultView hub
- Country picker → State picker → Risk card with:
  - Zone classification
  - Risk level (color-coded)
  - Historical notable earthquakes
  - Zone-specific safety tips
  - "Your preparedness priority" message

## Feature 2: Room Safety Scanner (Photo Analysis)

### Requirements
- User takes a photo of their room OR picks from photo library
- Vision framework (VNClassifyImageRequest) analyzes the photo
- Identifies objects: windows, bookshelves, TVs, chandeliers, heavy furniture
- Shows safety recommendations for each detected object
- Generates a "Room Safety Score"
- 100% offline (built-in Vision model, 0 MB extra)
- Works in simulator with sample/fallback images
- Camera permission via SupportingInfo.plist

### UI Concept
- Accessible from ResultView hub
- Camera/photo picker → Analysis screen → Safety report card
- Each detected hazard listed with icon + recommendation
- Overall safety score with improvement suggestions

## Feature 3: Submission Essay

### Personal Story (Jorge Salgado Miranda)
- September 19, 2017 - Mexico City
- Was in high school (prepa), sitting in class when the earthquake hit
- After the earthquake, no public transportation was available
- Had to walk home (lived far from school)
- While walking home, witnessed:
  - Fallen schools, walls collapsed
  - Broken glass everywhere
  - People crying in the streets
  - Some zones heavily damaged, others seemingly untouched
  - The contrast between damaged and undamaged zones was striking
- Realized that preparation depends heavily on WHERE you are
- The earthquake happened on the anniversary of the 1985 earthquake
- That morning, millions had just completed a national drill
- This experience inspired EarthReady MX
- Mexico now has extensive earthquake drills because of these events

### Essay Structure
1. Personal hook: The walk home through devastation
2. The contrast: damaged vs undamaged zones
3. The realization: preparation saves lives, location matters
4. What EarthReady MX does: multi-sensory learning experience
5. Technical choices: why SwiftUI + CoreHaptics + AVFoundation + CoreMotion
6. Social impact: making earthquake preparedness accessible and engaging
7. Accessibility commitment: VoiceOver, Reduce Motion, etc.

### Where it goes
- The submission essay is entered directly in the Swift Student Challenge application form
- Also save a copy in docs/SUBMISSION_ESSAY.md for reference

## Feature 4: Differentiators from Previous Winners

### What makes EarthReady MX unique vs EvacuMate/Fast Aid:
1. Multi-sensory simulation (haptics + synthesized audio + motion)
2. Cinematic storytelling with animated narrative
3. Multi-country seismic zone awareness (not just one country)
4. Room Safety Scanner using on-device ML
5. Interactive emergency drill with TTS guidance
6. Drag-and-drop kit builder mini-game
7. 5+ Apple frameworks integrated together
8. Personal connection to 2017 Mexico City earthquake

## Implementation Priority

1. Seismic Zone Map (multi-country) - ~1 day
2. Room Safety Scanner (photo) - ~2-3 days
3. Submission Essay - ~2 hours
4. App Icon + Package.swift config - ~30 min
5. Final device testing - ~1 day
