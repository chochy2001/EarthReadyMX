import AVFoundation

@MainActor
final class SoundManager: ObservableObject {

    private var engine: AVAudioEngine?
    private var sourceNode: AVAudioSourceNode?
    private var isPlaying = false
    private var modulationTimer: Timer?

    private let maxOscillators = 6
    nonisolated(unsafe) private var oscillators: [Oscillator] = Array(
        repeating: Oscillator(), count: 6
    )

    init() {
        configureAudioSession()
    }

    // MARK: - Audio Session

    private func configureAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try session.setPreferredIOBufferDuration(0.005)
            try session.setActive(true)
        } catch {
            #if DEBUG
            print("[SoundManager] Audio session error: \(error)")
            #endif
        }
    }

    // MARK: - Engine Setup

    private func setupEngine() {
        guard engine == nil else { return }

        let audioEngine = AVAudioEngine()
        let sampleRate = Float(audioEngine.outputNode.outputFormat(forBus: 0).sampleRate)
        let deltaTime = 1.0 / sampleRate

        let node = AVAudioSourceNode { [unowned self] (
            _: UnsafeMutablePointer<ObjCBool>,
            _: UnsafePointer<AudioTimeStamp>,
            frameCount: AVAudioFrameCount,
            audioBufferList: UnsafeMutablePointer<AudioBufferList>
        ) -> OSStatus in

            let ablPointer = UnsafeMutableAudioBufferListPointer(audioBufferList)

            for frame in 0..<Int(frameCount) {
                var mixedSample: Float = 0

                for i in 0..<self.maxOscillators {
                    mixedSample += self.oscillators[i].nextSample(deltaTime: deltaTime)
                }

                mixedSample = max(-1.0, min(1.0, mixedSample))

                for buffer in ablPointer {
                    let buf: UnsafeMutableBufferPointer<Float> = UnsafeMutableBufferPointer(buffer)
                    buf[frame] = mixedSample
                }
            }
            return noErr
        }

        audioEngine.attach(node)
        let format = audioEngine.outputNode.outputFormat(forBus: 0)
        audioEngine.connect(node, to: audioEngine.mainMixerNode, format: format)
        audioEngine.mainMixerNode.outputVolume = 0.5

        self.sourceNode = node
        self.engine = audioEngine
    }

    private func startEngine() {
        guard let engine = engine, !engine.isRunning else { return }
        do {
            try engine.start()
            isPlaying = true
        } catch {
            #if DEBUG
            print("[SoundManager] Engine start error: \(error)")
            #endif
        }
    }

    private func stopEngine() {
        modulationTimer?.invalidate()
        modulationTimer = nil
        engine?.stop()
        isPlaying = false
        for i in 0..<maxOscillators {
            oscillators[i].isActive = false
            oscillators[i].amplitude = 0
        }
    }

    private func silenceAll() {
        for i in 0..<maxOscillators {
            oscillators[i].amplitude = 0
            oscillators[i].isActive = false
        }
    }

    func stop() {
        stopEngine()
    }
}

// MARK: - Oscillator

struct Oscillator: Sendable {
    var frequency: Float = 0
    var amplitude: Float = 0
    var phase: Float = 0
    var waveform: WaveformType = .sine
    var isActive: Bool = false

    enum WaveformType: Sendable {
        case sine, triangle, square, noise
    }

    mutating func nextSample(deltaTime: Float) -> Float {
        guard isActive && amplitude > 0 else { return 0 }

        var sample: Float = 0
        switch waveform {
        case .sine:
            sample = sin(2.0 * .pi * frequency * phase)
        case .triangle:
            let t = phase * frequency
            let frac = t - floor(t)
            sample = 4.0 * abs(frac - 0.5) - 1.0
        case .square:
            let t = phase * frequency
            let frac = t - floor(t)
            sample = frac < 0.5 ? 1.0 : -1.0
        case .noise:
            sample = Float.random(in: -1.0...1.0)
        }

        phase += deltaTime
        if phase > 1000.0 { phase -= 1000.0 }

        return sample * amplitude
    }
}

// MARK: - Seismic Alert (SASMEX Style)

extension SoundManager {

    func playSeismicAlert(duration: TimeInterval = 3.0) {
        setupEngine()
        startEngine()

        oscillators[0].waveform = .sine
        oscillators[0].isActive = true
        oscillators[0].amplitude = 0

        let cycles = Int(duration / 0.95)
        for i in 0..<cycles {
            let offset = Double(i) * 0.95

            DispatchQueue.main.asyncAfter(deadline: .now() + offset) { [weak self] in
                self?.oscillators[0].frequency = 950
                self?.oscillators[0].amplitude = 0.3
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + offset + 0.4) { [weak self] in
                self?.oscillators[0].frequency = 1200
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + offset + 0.8) { [weak self] in
                self?.oscillators[0].amplitude = 0
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + duration) { [weak self] in
            self?.fadeOutOscillator(index: 0, duration: 0.2)
        }
    }
}

// MARK: - Earthquake Rumble

extension SoundManager {

    func playEarthquakeRumble() {
        setupEngine()
        startEngine()

        // Oscillator 0: Sub-bass rumble (25-45 Hz)
        oscillators[0].waveform = .sine
        oscillators[0].frequency = 35
        oscillators[0].amplitude = 0
        oscillators[0].isActive = true

        // Oscillator 1: Noise texture (filtered brown noise effect)
        oscillators[1].waveform = .noise
        oscillators[1].amplitude = 0
        oscillators[1].isActive = true

        // Fade in gradual
        let fadeSteps = 20
        let fadeDuration: TimeInterval = 1.5
        for i in 0...fadeSteps {
            let progress = Float(i) / Float(fadeSteps)
            DispatchQueue.main.asyncAfter(
                deadline: .now() + fadeDuration * Double(i) / Double(fadeSteps)
            ) { [weak self] in
                self?.oscillators[0].amplitude = 0.18 * progress
                self?.oscillators[1].amplitude = 0.08 * progress
            }
        }

        startRumbleModulation()
    }

    private func startRumbleModulation() {
        modulationTimer?.invalidate()
        var modulationTime: Float = 0
        modulationTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            Task { @MainActor in
                guard self.isPlaying else {
                    timer.invalidate()
                    return
                }
                modulationTime += 0.05
                // LFO for sub-bass frequency (25-45 Hz)
                let lfo = sin(modulationTime * 0.3 * 2 * .pi)
                self.oscillators[0].frequency = 35 + Float(lfo) * 10

                // Intensity waves (seismic waves effect)
                let intensityLFO = sin(modulationTime * 0.15 * 2 * .pi)
                self.oscillators[0].amplitude = 0.15 + Float(intensityLFO) * 0.06

                // Random debris noise bursts
                if Float.random(in: 0...1) < 0.03 {
                    self.oscillators[1].amplitude = Float.random(in: 0.12...0.2)
                } else {
                    self.oscillators[1].amplitude = max(0.04, self.oscillators[1].amplitude * 0.95)
                }
            }
        }
        RunLoop.main.add(modulationTimer!, forMode: .common)
    }

    func stopEarthquakeRumble() {
        modulationTimer?.invalidate()
        modulationTimer = nil
        fadeOutOscillator(index: 0, duration: 1.0)
        fadeOutOscillator(index: 1, duration: 1.0)
    }
}

// MARK: - UI Feedback Sounds

extension SoundManager {

    func playCorrectSound() {
        playToneSequence(
            frequencies: [523.25, 659.25, 783.99],
            durations: [0.1, 0.1, 0.15],
            waveform: .sine,
            amplitude: 0.2,
            oscillatorIndex: 2
        )
    }

    func playIncorrectSound() {
        playToneSequence(
            frequencies: [400, 300],
            durations: [0.15, 0.2],
            waveform: .square,
            amplitude: 0.1,
            oscillatorIndex: 2
        )
    }

    private func playToneSequence(
        frequencies: [Float],
        durations: [TimeInterval],
        waveform: Oscillator.WaveformType,
        amplitude: Float,
        oscillatorIndex: Int
    ) {
        setupEngine()
        startEngine()

        oscillators[oscillatorIndex].waveform = waveform
        oscillators[oscillatorIndex].isActive = true
        oscillators[oscillatorIndex].amplitude = 0

        var offset: TimeInterval = 0
        for (freq, dur) in zip(frequencies, durations) {
            DispatchQueue.main.asyncAfter(deadline: .now() + offset) { [weak self] in
                self?.oscillators[oscillatorIndex].frequency = freq
                self?.oscillators[oscillatorIndex].amplitude = amplitude
            }
            offset += dur
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + offset) { [weak self] in
            self?.oscillators[oscillatorIndex].amplitude = 0
            self?.oscillators[oscillatorIndex].isActive = false
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + offset + 0.1) { [weak self] in
            guard let self = self else { return }
            let anyActive = self.oscillators.contains { $0.isActive }
            if !anyActive {
                self.stopEngine()
            }
        }
    }
}

// MARK: - Celebration Sounds

extension SoundManager {

    func playCelebration(scorePercentage: Double) {
        if scorePercentage == 100 {
            playPerfectScoreSound()
        } else if scorePercentage >= 60 {
            playGoodScoreSound()
        } else {
            playLowScoreSound()
        }
    }

    private func playPerfectScoreSound() {
        playToneSequence(
            frequencies: [523.25, 659.25, 783.99, 1046.50],
            durations: [0.12, 0.12, 0.12, 0.25],
            waveform: .sine,
            amplitude: 0.25,
            oscillatorIndex: 3
        )
    }

    private func playGoodScoreSound() {
        playToneSequence(
            frequencies: [523.25, 659.25, 783.99],
            durations: [0.15, 0.15, 0.2],
            waveform: .sine,
            amplitude: 0.2,
            oscillatorIndex: 3
        )
    }

    private func playLowScoreSound() {
        setupEngine()
        startEngine()
        oscillators[3].waveform = .triangle
        oscillators[3].frequency = 329.63
        oscillators[3].amplitude = 0.15
        oscillators[3].isActive = true
        fadeOutOscillator(index: 3, duration: 0.5)
    }
}

// MARK: - Tension Drone

extension SoundManager {

    func playTensionDrone() {
        setupEngine()
        startEngine()

        // Oscillator 4: Root A2 (110 Hz)
        oscillators[4].waveform = .sine
        oscillators[4].frequency = 110
        oscillators[4].amplitude = 0
        oscillators[4].isActive = true

        // Oscillator 5: Minor third C3 (130.81 Hz)
        oscillators[5].waveform = .sine
        oscillators[5].frequency = 130.81
        oscillators[5].amplitude = 0
        oscillators[5].isActive = true

        // Fade in
        let steps = 15
        for i in 0...steps {
            let progress = Float(i) / Float(steps)
            DispatchQueue.main.asyncAfter(
                deadline: .now() + 1.0 * Double(i) / Double(steps)
            ) { [weak self] in
                self?.oscillators[4].amplitude = 0.06 * progress
                self?.oscillators[5].amplitude = 0.04 * progress
            }
        }

        startDetuneLFO()
    }

    private func startDetuneLFO() {
        modulationTimer?.invalidate()
        var time: Float = 0
        modulationTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            Task { @MainActor in
                guard self.isPlaying else {
                    timer.invalidate()
                    return
                }
                time += 0.05
                let detune1 = sin(time * 0.1 * 2 * .pi) * 2
                let detune2 = sin(time * 0.13 * 2 * .pi) * 1.5
                self.oscillators[4].frequency = 110 + detune1
                self.oscillators[5].frequency = 130.81 + detune2
            }
        }
        RunLoop.main.add(modulationTimer!, forMode: .common)
    }

    func stopTensionDrone() {
        modulationTimer?.invalidate()
        modulationTimer = nil
        fadeOutOscillator(index: 4, duration: 0.5)
        fadeOutOscillator(index: 5, duration: 0.5)
    }
}

// MARK: - Fade Utilities

extension SoundManager {

    private func fadeOutOscillator(index: Int, duration: TimeInterval, steps: Int = 10) {
        let startAmp = oscillators[index].amplitude
        for i in 0...steps {
            let progress = Float(i) / Float(steps)
            DispatchQueue.main.asyncAfter(
                deadline: .now() + duration * Double(i) / Double(steps)
            ) { [weak self] in
                guard let self = self else { return }
                self.oscillators[index].amplitude = startAmp * (1.0 - progress)
                if i == steps {
                    self.oscillators[index].isActive = false
                    let anyActive = self.oscillators.contains { $0.isActive }
                    if !anyActive {
                        self.stopEngine()
                    }
                }
            }
        }
    }
}
