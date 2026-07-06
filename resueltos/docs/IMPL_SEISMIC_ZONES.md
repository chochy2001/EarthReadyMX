# Implementation Plan: Seismic Zone Map

## Files to Create

### 1. SeismicZoneData.swift
Embedded data for 4 countries with seismic zone classifications.

#### Data Structure:
```swift
struct SeismicCountry: Identifiable, Sendable {
    let id = UUID()
    let name: String
    let flag: String  // emoji
    let states: [SeismicState]
    let historicalEarthquakes: [HistoricalEarthquake]
}

struct SeismicState: Identifiable, Sendable {
    let id = UUID()
    let name: String
    let zone: String       // "A", "B", "C", "D" for Mexico; "Low", "Moderate", etc for USA
    let riskLevel: SeismicRiskLevel
    let description: String
}

enum SeismicRiskLevel: Int, CaseIterable, Sendable {
    case veryLow = 0
    case low = 1
    case moderate = 2
    case high = 3
    case veryHigh = 4
}

struct HistoricalEarthquake: Identifiable, Sendable {
    let id = UUID()
    let year: Int
    let magnitude: Double
    let location: String
    let description: String
}
```

#### Country Data:
- **Mexico** (32 states): Zone A (low) to D (very high) from CENAPRED
- **USA** (50 states): 5 risk levels from USGS
- **Chile** (16 regions): Zones 1-3 from NCh433
- **Japan** (47 prefectures): HERP probability-based risk

### 2. SeismicZoneView.swift
UI with country picker -> state picker -> risk card

#### UI Components:
1. Header with title and back button
2. Country picker (horizontal scroll of country cards with flags)
3. State picker (searchable list or grid)
4. Risk result card with:
   - Zone classification badge (color-coded)
   - Risk level meter/bar
   - Description of what the zone means
   - Historical earthquakes section
   - Safety recommendations specific to zone
   - If low-risk: "Explore Mexico's zones for the full experience" suggestion

#### Color Coding:
- Very Low: Green
- Low: Blue
- Moderate: Yellow/Orange
- High: Orange/Red
- Very High: Red

#### Requirements:
- 100% offline
- All data in Swift code (no JSON/files)
- VoiceOver accessible
- Dynamic Type support
- Reduce Motion support
- Works in simulator
- maxWidth: 600 for iPad
- Back to Results button
