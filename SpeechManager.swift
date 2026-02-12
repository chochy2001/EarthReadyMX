import AVFoundation
import UIKit

@MainActor
final class SpeechManager: NSObject, ObservableObject {
    private let synthesizer = AVSpeechSynthesizer()
    @Published var isSpeaking = false
    @Published var currentWordRange: NSRange?
    private var onFinished: (() -> Void)?

    override init() {
        super.init()
        synthesizer.delegate = self
        synthesizer.usesApplicationAudioSession = true
    }

    func speak(
        text: String,
        language: String = "es-MX",
        rate: Float = 0.48,
        onFinished: (() -> Void)? = nil
    ) {
        self.onFinished = onFinished

        if UIAccessibility.isVoiceOverRunning {
            UIAccessibility.post(notification: .announcement, argument: text)
            isSpeaking = true
            let estimatedDuration = Double(text.count) * 0.06
            DispatchQueue.main.asyncAfter(deadline: .now() + estimatedDuration) { [weak self] in
                self?.isSpeaking = false
                let callback = self?.onFinished
                self?.onFinished = nil
                callback?()
            }
            return
        }

        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: language)
        utterance.rate = rate
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0

        isSpeaking = true
        synthesizer.speak(utterance)
    }

    func stop() {
        synthesizer.stopSpeaking(at: .immediate)
        isSpeaking = false
        currentWordRange = nil
        onFinished = nil
    }
}

extension SpeechManager: AVSpeechSynthesizerDelegate {
    nonisolated func speechSynthesizer(
        _ synthesizer: AVSpeechSynthesizer,
        didFinish utterance: AVSpeechUtterance
    ) {
        Task { @MainActor in
            self.isSpeaking = false
            self.currentWordRange = nil
            let callback = self.onFinished
            self.onFinished = nil
            callback?()
        }
    }

    nonisolated func speechSynthesizer(
        _ synthesizer: AVSpeechSynthesizer,
        willSpeakRangeOfSpeechString characterRange: NSRange,
        utterance: AVSpeechUtterance
    ) {
        Task { @MainActor in
            self.currentWordRange = characterRange
        }
    }
}
