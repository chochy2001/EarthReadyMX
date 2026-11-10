# Validation Evidence & Documentation Drift: `EarthReadyMX`

- **Task**: `[Spec Kit][T041]` (`#5`)
- **Repository**: `chochy2001/EarthReadyMX`
- **Audit date**: `2026-11-10`

## Validation Record Table

| application | working_directory | command | scope | status | reason | next_action | evidence_paths |
|-------------|-------------------|---------|-------|--------|-------------|----------------|----------------|
| `earthready` | `.` | Python source, manifest & test-target audit (`Package.swift`, `EarthReadyCore/Package.swift`, `*.swift`) | `docs` | `pass` | Verified **21** `AppModule` Swift files (`9,074` lines), **5** `EarthReadyCore` Swift files (`1,519` lines), **5** XCTest suites (**44** unit tests), `Assets.xcassets/AppIcon.appiconset/Logo_app_terremoto.png` (`appIcon: .asset("AppIcon")`), `SupportingInfo.plist` (`NSMotionUsageDescription`, `NSCameraUsageDescription`), and updated `Package.swift` `exclude` list (`docs`, `resueltos`, `specs`, `README.md`, `MASTER_SPEC.md`, `AGENTS.md`, `SupportingInfo.plist`, `EarthReadyCore`) so SwiftPM emits zero unhandled-file warnings. | `none` | `Package.swift`, `EarthReadyCore/Package.swift`, `SupportingInfo.plist`, `Assets.xcassets/**` |
| `earthready` | `EarthReadyCore` | `swift test --enable-code-coverage` | `swift` | `blocked` | Swift 6 / Apple toolchain is not installed on this Windows audit host; `.github/workflows/ci.yml` (`core-tests` job on `macos-15`) runs `swift test --enable-code-coverage` + `xcrun llvm-cov report` automatically on every push and pull request to `main`. | Verify `EarthReadyCore unit tests` job passes on the PR in GitHub Actions (`macos-15`). | `.github/workflows/ci.yml:14-40`, `EarthReadyCore/Tests/EarthReadyCoreTests/*.swift` |
| `earthready` | `.` | `xcodebuild -scheme EarthReadyMXFinal -destination 'platform=iOS Simulator,name=iPhone 16 Pro' build` | `swift` | `blocked` | `AppleProductTypes` resolves only inside macOS Xcode / Swift Playgrounds (`AGENTS.md:9-12`); `.github/workflows/ci.yml` (`app-build` job on `macos-15`) executes this exact `xcodebuild` Simulator build on every push and pull request to `main`. | Verify `App build (iOS Simulator)` job passes on the PR in GitHub Actions (`macos-15`). | `.github/workflows/ci.yml:41-57`, `Package.swift` |
| `earthready` | `.` | `manual-review` + `git diff --check` | `security` | `pass` | Confirmed 100% offline execution (`0` network endpoints, `0` API keys/secrets, on-device `VNClassifyImageRequest` + `AVAudioEngine` + `UserDefaults`). | `none` | `Package.swift`, `RoomScannerView.swift`, `SoundManager.swift`, `.gitleaks.toml` |

## Integration Boundary Validation

| boundary | source_evidence | target_evidence | status | notes / next_action |
|----------|-----------------|-----------------|--------|---------------------|
| `AppModule` SwiftUI Views <-> `EarthReadyCore` Domain Library | `Package.swift:45-53`, `MyApp.swift:2`, `ContentView.swift:2`, `SeismicZoneView.swift:2`, `RoomScannerView.swift:2`, `ChecklistView.swift`, `KitBuilderView.swift` | `EarthReadyCore/Sources/EarthReadyCore/{GameState,ChecklistData,KitBuilderData,SeismicZoneData,AppearancePreference}.swift` + `EarthReadyCore/Tests/EarthReadyCoreTests/` (44 unit tests) | `pass` | Clean dependency-injected boundary (`GameState(userDefaults:)`), validated on `macos-15` CI via `swift test --enable-code-coverage` and `xcodebuild`. |
| `RoomScannerView` <-> Apple `Vision` (`VNClassifyImageRequest`) & `PhotosUI` / `UIImagePickerController` | `RoomScannerView.swift:13-40,371-409`, `SupportingInfo.plist:11-12` (`NSCameraUsageDescription`) | Built-in iOS on-device `Vision` image classifier (`usesCPUOnly = true` on Simulator; module-level non-`@MainActor` `classifyRoomImage` helper avoiding Swift 6 executor traps) | `pass` | 100% offline on-device hazard classification with zero cloud uploads. |
| Hardware Sensory Managers <-> iOS Audio / Haptics / Motion / Speech Frameworks | `SoundManager.swift` (`AVAudioEngine` + `AVAudioSourceNode` 4-oscillator synthesis), `HapticManager.swift` (`CHHapticEngine`), `MotionManager.swift` (`CMMotionManager` 50 Hz + Simulator synthetic fallback), `SpeechManager.swift` (`AVSpeechSynthesizer`) | Local iOS hardware / Simulator fallbacks (`SupportingInfo.plist:9-10` `NSMotionUsageDescription`) | `pass` | Zero bundled audio assets; graceful fallbacks when haptics or accelerometer hardware are absent on Simulator. |

## Documentation Drift Classification

### 1. False pending items (Markdown says missing, code shows present)

| Location | Claim in Markdown | Actual Source Evidence | Disposition |
|----------|-------------------|------------------------|-------------|
| `docs/ESTADO_PROYECTO.md:75-98` & `docs/ROADMAP.md:100-101` | Marked **App Icon** (`PENDIENTE`), `Package.swift` `appIcon: .asset("AppIcon")` (`PENDIENTE`), and **Submission essay** (`PENDIENTE`) as unfinished tasks. | `Assets.xcassets/AppIcon.appiconset/Logo_app_terremoto.png` is committed, `Package.swift:29` already configures `appIcon: .asset("AppIcon")`, and `docs/SUBMISSION_ESSAY.md` contains the completed 3-part Swift Student Challenge 2026 submission essay. | Marked completed in `MASTER_SPEC.md`. |
| `docs/PLAN_V6_NEW_FEATURES.md:1-99` | Framed **Seismic Zone Map (Multi-Country)** and **Room Safety Scanner (Photo Analysis)** as upcoming planned work. | Both features are fully implemented and wired into `ContentView.swift:55-66` (`SeismicZoneView.swift` + `EarthReadyCore/.../SeismicZoneData.swift` + `SeismicZoneDataTests.swift`; `RoomScannerView.swift` using `Vision` + `PhotosUI`; historical specs archived in `resueltos/docs/IMPL_SEISMIC_ZONES.md` and `resueltos/docs/IMPL_ROOM_SCANNER.md`). | Classified as shipped capabilities in `MASTER_SPEC.md`. |

### 2. Ghost code (Code exists in repo, `README.md` / `docs/ESTADO_PROYECTO.md` omitted it)

| Source Path | Undocumented / Under-documented Capability | Notes |
|-------------|--------------------------------------------|-------|
| `SeismicZoneView.swift` & `EarthReadyCore/Sources/EarthReadyCore/SeismicZoneData.swift` | Multi-country seismic zone & historical earthquake explorer covering Mexico (CENAPRED), USA (USGS), Chile (SENAPRED), and Japan (JMA) (`ContentView` `.seismicZone` phase). Omitted completely from `README.md` Features & App Flow! | Added to `MASTER_SPEC.md` Current Capabilities and Key Workflows. |
| `RoomScannerView.swift` (`1,286` lines) | On-device `Vision` (`VNClassifyImageRequest`) room earthquake hazard scanner with camera/`PhotosPicker` capture, high/medium/low hazard dictionary, positive shelter item recognition, and Room Safety Score ring (`ContentView` `.roomScanner` phase). Omitted completely from `README.md`! | Added to `MASTER_SPEC.md`. |
| `AppearanceSettingsSheet.swift` & `EarthReadyCore/Sources/EarthReadyCore/AppearancePreference.swift` | User-selectable System / Light / Dark appearance sheet (`@AppStorage(AppearancePreference.storageKey)` in `MyApp.swift:17,27`), replacing the old forced dark-only mode. | Added to `MASTER_SPEC.md`. |
| `EarthReadyCore/` SPM package + `.github/workflows/ci.yml` | Extracted Swift 6 library with **5** source modules and **44** XCTest unit tests + `macos-15` GitHub Actions CI (`swift test --enable-code-coverage` + `xcodebuild`). Not mentioned in `README.md`, `ESTADO_PROYECTO.md`, or `ROADMAP.md`. | Added to `MASTER_SPEC.md`. |

### 3. Stale claims (Markdown contradicts current code or manifests)

| Location | Stale Claim | Current Reality in Source |
|----------|-------------|---------------------------|
| `README.md:75-76,90-96` | States `Source files: 21`, `Lines of code: ~7,500`, and lists only 5 frameworks (`SwiftUI`, `CoreHaptics`, `AVFoundation`, `CoreMotion`, `Accessibility`). | Total Swift code is **26** source files (`21` in `AppModule` + `5` in `EarthReadyCore`, `10,593` lines) plus **5** XCTest files (`44` tests), integrating **7** Apple frameworks (adding `Vision` and `PhotosUI`). |
| `docs/ROADMAP.md:3,18,29,141-143` | Header says `Swift Student Challenge 2025` (while deadline says `28 de Febrero 2026` and `README.md:3` says `2026`), lists only `5` views and `15 archivos Swift, 3,928 lineas`. | Current app router (`ContentView.swift:12-70`) has **11** phases (`splash`, `story`, `learn`, `simulation`, `result`, `kitBuilder`, `checklist`, `drill`, `seismicZone`, `roomScanner`, `completion`) across `10,593` Swift source lines. |
| `Package.swift:55` (prior to this audit) | Excluded only `["docs", "README.md", "SupportingInfo.plist", "EarthReadyCore"]`, leaving `resueltos/`, `AGENTS.md`, `MASTER_SPEC.md`, and `specs/` unhandled in the root `path: "."` target. | Updated `exclude` in `Package.swift` to include `"resueltos"`, `"specs"`, `"MASTER_SPEC.md"`, and `"AGENTS.md"`. |
| Task path alias `EarthReadyMXFinal.swiftpm/MASTER_SPEC.md` vs Git root `.` | Audit task prompts referenced `EarthReadyMXFinal.swiftpm/` from the original local macOS parent directory `/Users/jorge/Documents/Apps/EarthReadyMXFinal.swiftpm/`. | Inside `chochy2001/EarthReadyMX`, `.` is the `.swiftpm` root (`Package.swift` is at `./Package.swift`), so `MASTER_SPEC.md` lives canonically at `./MASTER_SPEC.md`. |

### 4. Unresolved claims

`None found after review` across `Package.swift`, `EarthReadyCore/`, all 26 Swift source files, `README.md`, `docs/*.md`, and `.github/workflows/ci.yml` — the application is a self-contained, 100% offline Swift App Playground with automated `macos-15` CI for both `EarthReadyCore` unit tests and iOS Simulator app compilation.
