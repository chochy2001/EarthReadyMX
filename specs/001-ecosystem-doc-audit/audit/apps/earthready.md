# Audit Inventory: `EarthReadyMX` (`chochy2001/EarthReadyMX`)

- **Task**: `[Spec Kit][T022]` (`#4`)
- **Repository**: `chochy2001/EarthReadyMX` (Swift Playgrounds App Playground package `EarthReadyMXFinal`, historically cloned into workspace folder `EarthReadyMXFinal.swiftpm/`)
- **Default branch**: `main`
- **Audit date**: `2026-11-10`

## Workspace Inventory Table

| path | kind | git_root | nearest_guidance | manifests | documentation_roots | status | notes |
|------|------|----------|------------------|-----------|---------------------|--------|-------|
| `.` (`EarthReadyMXFinal.swiftpm/` workspace folder) | `mobile` | `.` | `AGENTS.md` | `Package.swift` (`swift-tools-version: 6.0`, `AppleProductTypes.iOSApplication`, `com.capdesis.EarthReadyMXFinal`, `displayVersion: "1.0"`, `bundleVersion: "1"`, `.iOS("16.0")`), `SupportingInfo.plist`, `.pre-commit-config.yaml`, `.gitleaks.toml` | `README.md`, `MASTER_SPEC.md`, `AGENTS.md`, `docs/` | `completed` | Root of `chochy2001/EarthReadyMX` IS the `.swiftpm` App Playground package (`AppModule` executable target with **21** Swift UI/hardware files totaling `9,074` lines + `Assets.xcassets/AppIcon.appiconset`). Note: task descriptions referring to `EarthReadyMXFinal.swiftpm/` reflect the local macOS directory name where this repo was cloned; inside git, `.` is that package root. |
| `EarthReadyCore/` | `shared-package` | `.` | `AGENTS.md` | `EarthReadyCore/Package.swift` (`swift-tools-version: 6.0`, `.iOS(.v16)`, `.macOS(.v13)`, `.swiftLanguageMode(.v6)`) | `AGENTS.md`, `MASTER_SPEC.md` | `completed` | Pure-Swift domain & state library extracted so pure logic can run under `swift test`: **5** source files (`AppearancePreference.swift`, `ChecklistData.swift`, `GameState.swift`, `KitBuilderData.swift`, `SeismicZoneData.swift` — `1,519` lines) and **5** XCTest suites (`EarthReadyCore/Tests/EarthReadyCoreTests/` — **44** unit tests). |
| `.github/workflows/` | `infrastructure` | `.` | `AGENTS.md` | `.github/workflows/ci.yml`, `.gitleaks.toml`, `.pre-commit-config.yaml` | `AGENTS.md` | `completed` | GitHub Actions `macos-15` CI running two jobs on pushes and pull requests to `main`: `core-tests` (`swift test --enable-code-coverage` + `xcrun llvm-cov report` in `EarthReadyCore/`) and `app-build` (`xcodebuild -scheme EarthReadyMXFinal -destination 'platform=iOS Simulator,name=iPhone 16 Pro' build`). |
| `docs/` | `documentation` | `.` | `AGENTS.md` | `none-found` | `docs/ESTADO_PROYECTO.md`, `docs/PLAN_V6_NEW_FEATURES.md`, `docs/ROADMAP.md`, `docs/SUBMISSION_ESSAY.md` | `completed` | Swift Student Challenge 2026 planning docs and final submission essay (`SUBMISSION_ESSAY.md`). |
| `resueltos/docs/` | `archive` | `.` | `AGENTS.md` | `none-found` | `resueltos/docs/*.md` (24 files) | `completed` | Completed historical implementation plans and resolved issue logs (`IMPL_ROOM_SCANNER.md`, `IMPL_SEISMIC_ZONES.md`, `ISSUES_V2..V7`, `PLAN_*`). |
| `.build/`, `DerivedData/`, `.swiftpm/` | `generated` | `.` | `AGENTS.md` | `none-found` | `none-found` | `excluded` | Gitignored SwiftPM/Xcode build artifacts. |

## Application Record Table

| name | root_path | repo_path | stack | source_roots | test_roots | validation_plan | master_spec_path | readiness |
|------|-----------|-----------|-------|--------------|------------|-----------------|------------------|-----------|
| `earthready` (`EarthReadyMXFinal`) | `.` (workspace alias `EarthReadyMXFinal.swiftpm`) | `chochy2001/EarthReadyMX` | Swift 6.0 (`strict concurrency`), SwiftUI, `AppleProductTypes` App Playground (`.iOS("16.0")`), CoreHaptics, AVFoundation (`AVAudioEngine` + `AVSpeechSynthesizer`), CoreMotion, Vision (`VNClassifyImageRequest`), PhotosUI | `.` (`AppModule`: 21 `.swift` files), `EarthReadyCore/Sources/EarthReadyCore/` (5 `.swift` files) | `EarthReadyCore/Tests/EarthReadyCoreTests/` (5 suites, 44 XCTest unit tests) | `cd EarthReadyCore && swift test --enable-code-coverage` and `xcodebuild -scheme EarthReadyMXFinal -destination 'platform=iOS Simulator,name=iPhone 16 Pro' build` (automated on `macos-15` via `.github/workflows/ci.yml`) | `MASTER_SPEC.md` | `partial` |
