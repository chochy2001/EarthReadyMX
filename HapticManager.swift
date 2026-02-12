import CoreHaptics
import SwiftUI

@MainActor
final class HapticManager: ObservableObject {

    private var engine: CHHapticEngine?
    private(set) var supportsHaptics: Bool = false
    private var engineNeedsStart = true

    init() {
        supportsHaptics = CHHapticEngine.capabilitiesForHardware().supportsHaptics
        if supportsHaptics {
            prepareEngine()
        }
    }

    // MARK: - Engine Lifecycle

    private func prepareEngine() {
        do {
            engine = try CHHapticEngine()
            engine?.playsHapticsOnly = true
            engine?.isAutoShutdownEnabled = true

            engine?.stoppedHandler = { [weak self] reason in
                Task { @MainActor in
                    self?.engineNeedsStart = true
                    #if DEBUG
                    print("[HapticManager] Engine stopped: \(reason.rawValue)")
                    #endif
                }
            }

            engine?.resetHandler = { [weak self] in
                Task { @MainActor in
                    do {
                        try self?.engine?.start()
                        self?.engineNeedsStart = false
                    } catch {
                        #if DEBUG
                        print("[HapticManager] Engine reset failed: \(error)")
                        #endif
                    }
                }
            }

            try engine?.start()
            engineNeedsStart = false
        } catch {
            #if DEBUG
            print("[HapticManager] Engine preparation failed: \(error)")
            #endif
            supportsHaptics = false
        }
    }

    private func startEngineIfNeeded() throws {
        guard supportsHaptics else { return }

        if engine == nil {
            prepareEngine()
        }

        if engineNeedsStart {
            try engine?.start()
            engineNeedsStart = false
        }
    }

}

// MARK: - Earthquake Splash Pattern (2.2s)

extension HapticManager {

    func playEarthquakeSplash() {
        guard supportsHaptics else { return }

        do {
            try startEngineIfNeeded()

            // P-wave: gentle rumble (0 - 0.8s)
            let pWave = CHHapticEvent(
                eventType: .hapticContinuous,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.3),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.1)
                ],
                relativeTime: 0,
                duration: 0.8
            )

            // S-wave: violent shaking (0.8 - 1.8s)
            let sWave = CHHapticEvent(
                eventType: .hapticContinuous,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.8),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
                ],
                relativeTime: 0.8,
                duration: 1.0
            )

            // S-wave transient jolts
            let jolt1 = CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.8)
                ],
                relativeTime: 1.0
            )
            let jolt2 = CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.9),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.7)
                ],
                relativeTime: 1.4
            )

            // Decay (1.8 - 2.2s)
            let decay = CHHapticEvent(
                eventType: .hapticContinuous,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.4),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.2)
                ],
                relativeTime: 1.8,
                duration: 0.4
            )

            // Intensity envelope
            let intensityCurve = CHHapticParameterCurve(
                parameterID: .hapticIntensityControl,
                controlPoints: [
                    .init(relativeTime: 0.0, value: 0.3),
                    .init(relativeTime: 0.5, value: 0.5),
                    .init(relativeTime: 0.8, value: 0.8),
                    .init(relativeTime: 1.2, value: 1.0),
                    .init(relativeTime: 1.8, value: 0.6),
                    .init(relativeTime: 2.2, value: 0.0)
                ],
                relativeTime: 0
            )

            let pattern = try CHHapticPattern(
                events: [pWave, sWave, jolt1, jolt2, decay],
                parameterCurves: [intensityCurve]
            )

            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: CHHapticTimeImmediate)

        } catch {
            #if DEBUG
            print("[HapticManager] Earthquake splash error: \(error)")
            #endif
        }
    }
}

// MARK: - Answer Feedback

extension HapticManager {

    func playCorrectAnswer() {
        guard supportsHaptics else { return }

        do {
            try startEngineIfNeeded()

            let tap1 = CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.6),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
                ],
                relativeTime: 0
            )
            let tap2 = CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.8),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.6)
                ],
                relativeTime: 0.12
            )

            let pattern = try CHHapticPattern(events: [tap1, tap2], parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: CHHapticTimeImmediate)

        } catch {
            #if DEBUG
            print("[HapticManager] Correct answer error: \(error)")
            #endif
        }
    }

    func playWrongAnswer() {
        guard supportsHaptics else { return }

        do {
            try startEngineIfNeeded()

            let tap1 = CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.8),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.8)
                ],
                relativeTime: 0
            )
            let tap2 = CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.6),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.6)
                ],
                relativeTime: 0.1
            )
            let tap3 = CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.4),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.4)
                ],
                relativeTime: 0.2
            )

            let pattern = try CHHapticPattern(events: [tap1, tap2, tap3], parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: CHHapticTimeImmediate)

        } catch {
            #if DEBUG
            print("[HapticManager] Wrong answer error: \(error)")
            #endif
        }
    }
}

// MARK: - Simulation Background Earthquake (4s)

extension HapticManager {

    func playEarthquakeSimulation() {
        guard supportsHaptics else { return }

        do {
            try startEngineIfNeeded()

            let rumble = CHHapticEvent(
                eventType: .hapticContinuous,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.35),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.2)
                ],
                relativeTime: 0,
                duration: 4.0
            )

            let aftershock1 = CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.5),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.4)
                ],
                relativeTime: 0.8
            )
            let aftershock2 = CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.4),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.3)
                ],
                relativeTime: 1.7
            )
            let aftershock3 = CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.3),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.2)
                ],
                relativeTime: 2.9
            )

            let envelope = CHHapticParameterCurve(
                parameterID: .hapticIntensityControl,
                controlPoints: [
                    .init(relativeTime: 0.0, value: 0.0),
                    .init(relativeTime: 0.5, value: 0.8),
                    .init(relativeTime: 1.5, value: 1.0),
                    .init(relativeTime: 3.0, value: 0.6),
                    .init(relativeTime: 4.0, value: 0.0)
                ],
                relativeTime: 0
            )

            let pattern = try CHHapticPattern(
                events: [rumble, aftershock1, aftershock2, aftershock3],
                parameterCurves: [envelope]
            )

            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: CHHapticTimeImmediate)

        } catch {
            #if DEBUG
            print("[HapticManager] Simulation earthquake error: \(error)")
            #endif
        }
    }
}

// MARK: - Result Feedback

extension HapticManager {

    func playPerfectScore() {
        guard supportsHaptics else { return }

        do {
            try startEngineIfNeeded()

            let buildUp1 = CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.4),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.3)
                ],
                relativeTime: 0
            )
            let buildUp2 = CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.6),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
                ],
                relativeTime: 0.15
            )
            let buildUp3 = CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.8),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.6)
                ],
                relativeTime: 0.3
            )
            let climax = CHHapticEvent(
                eventType: .hapticContinuous,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.7)
                ],
                relativeTime: 0.5,
                duration: 0.7
            )
            let finalTap = CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.9)
                ],
                relativeTime: 1.2
            )

            let intensityCurve = CHHapticParameterCurve(
                parameterID: .hapticIntensityControl,
                controlPoints: [
                    .init(relativeTime: 0.4, value: 0.7),
                    .init(relativeTime: 0.7, value: 1.0),
                    .init(relativeTime: 1.0, value: 0.4)
                ],
                relativeTime: 0
            )

            let pattern = try CHHapticPattern(
                events: [buildUp1, buildUp2, buildUp3, climax, finalTap],
                parameterCurves: [intensityCurve]
            )

            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: CHHapticTimeImmediate)

        } catch {
            #if DEBUG
            print("[HapticManager] Perfect score error: \(error)")
            #endif
        }
    }

    func playEncouragement() {
        guard supportsHaptics else { return }

        do {
            try startEngineIfNeeded()

            let tap1 = CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.3),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.2)
                ],
                relativeTime: 0
            )
            let tap2 = CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.5),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.4)
                ],
                relativeTime: 0.15
            )

            let pattern = try CHHapticPattern(events: [tap1, tap2], parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: CHHapticTimeImmediate)

        } catch {
            #if DEBUG
            print("[HapticManager] Encouragement error: \(error)")
            #endif
        }
    }
}
