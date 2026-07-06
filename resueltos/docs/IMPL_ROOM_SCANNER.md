# Implementation Plan: Room Safety Scanner

## Files to Create

### 1. RoomScannerView.swift
Complete room safety scanner with photo analysis.

#### Architecture:
- Use `PhotosPicker` from PhotosUI (iOS 16+) for photo library
- Use `UIImagePickerController` wrapped in `UIViewControllerRepresentable` for camera
- Use `VNClassifyImageRequest` from Vision framework for analysis
- All processing on-device, 0 MB extra weight

#### Analysis Function:
Create as a FREE FUNCTION (not inside @MainActor class) to avoid Swift 6 isolation issues:

```swift
import Vision
import UIKit

// Module-level function - NOT @MainActor
func classifyImage(_ image: UIImage, topK: Int = 10) async throws -> [String: Float] {
    guard let cgImage = image.cgImage else { return [:] }
    return try await withCheckedThrowingContinuation { continuation in
        let request = VNClassifyImageRequest { request, error in
            if let error = error {
                continuation.resume(throwing: error)
                return
            }
            guard let results = request.results as? [VNClassificationObservation] else {
                continuation.resume(returning: [:])
                return
            }
            var dict: [String: Float] = [:]
            for obs in results.prefix(topK) {
                dict[obs.identifier] = obs.confidence
            }
            continuation.resume(returning: dict)
        }
        request.usesCPUOnly = true  // Simulator compatibility
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        do {
            try handler.perform([request])
        } catch {
            continuation.resume(throwing: error)
        }
    }
}
```

#### Hazard Mapping (~30 identifiers):
Map VNClassifyImageRequest identifiers to room safety hazards:

```swift
struct RoomHazard: Identifiable, Sendable {
    let id = UUID()
    let icon: String
    let name: String
    let recommendation: String
    let severity: HazardSeverity  // .high, .medium, .low
}

enum HazardSeverity: Sendable {
    case high, medium, low
}
```

Mapping examples:
- "bookcase", "bookshelf" → Anchor to wall, secure heavy items on lower shelves
- "television", "monitor" → Secure to stand, use anti-tip straps
- "window_shade", "window" → Stay away during shaking, cover with film
- "chandelier", "lamp" → Can swing/fall, move beds away from overhead fixtures
- "vase", "pot" → Secure decorative items, place on lower surfaces
- "cabinet", "chest" → Secure doors, use child-proof latches
- "mirror" → Can shatter, move away from beds/seating areas
- "refrigerator" → Anchor to wall, keep heavy items on lower shelves
- "water_heater" → Must be strapped to wall studs
- "shelf" → Anchor to wall, lip guards on shelves

#### UI Flow:
1. Welcome screen with explanation
2. Two buttons: "Take Photo" (camera) / "Choose from Library" (PhotosPicker)
3. Analyzing screen with progress indicator
4. Results card:
   - Photo thumbnail
   - Room Safety Score (0-100)
   - Detected items list with icons + recommendations
   - Color-coded severity for each hazard
   - "Scan Another Room" button
   - Back to Results button

#### Simulator Handling:
- Camera not available in simulator → show only "Choose from Library"
- Provide sample analysis fallback if Vision returns empty
- Check `UIImagePickerController.isSourceTypeAvailable(.camera)`

#### Requirements:
- Import Vision, PhotosUI
- NSCameraUsageDescription in SupportingInfo.plist
- 100% offline
- VoiceOver accessible
- Dynamic Type support
- Reduce Motion support
- maxWidth: 600 for iPad
- Back to Results button
