@preconcurrency import CoreMotion
import SwiftUI

@MainActor
final class MotionManager: ObservableObject {
    private let motionManager = CMMotionManager()
    @Published var filteredMagnitude: CGFloat = 0

    var isMotionAvailable: Bool {
        motionManager.isDeviceMotionAvailable
    }

    private var lowPassValue: Double = 0
    private let filterAlpha: Double = 0.3

    func startUpdates() {
        guard motionManager.isDeviceMotionAvailable else { return }
        motionManager.deviceMotionUpdateInterval = 1.0 / 50.0
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, _ in
            guard let self, let motion else { return }
            self.processMotion(motion)
        }
    }

    func stopUpdates() {
        motionManager.stopDeviceMotionUpdates()
        filteredMagnitude = 0
        lowPassValue = 0
    }

    private func processMotion(_ motion: CMDeviceMotion) {
        let acc = motion.userAcceleration
        let magnitude = sqrt(acc.x * acc.x + acc.y * acc.y + acc.z * acc.z)

        // Low-pass filter to smooth sensor data
        lowPassValue = filterAlpha * magnitude + (1.0 - filterAlpha) * lowPassValue

        // Normalize to 0...1 range (max ~1.5g considered full scale)
        let normalized = min(lowPassValue / 1.5, 1.0)

        // Add sign based on dominant axis for waveform variety
        let dominantAxis = [acc.x, acc.y, acc.z].max(by: { abs($0) < abs($1) }) ?? 0
        let signed = dominantAxis >= 0 ? normalized : -normalized
        filteredMagnitude = CGFloat(signed)
    }
}
