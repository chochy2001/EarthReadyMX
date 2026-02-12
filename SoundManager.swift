import AVFoundation

private enum WaveformType: Sendable {
    case sine, triangle, square, noise
}

private struct OscillatorControl: Sendable {
    var frequency: Float = 0
    var amplitude: Float = 0
    var waveform: WaveformType = .sine
    var isActive: Bool = false
}

private final class OscillatorBank: @unchecked Sendable {
    let count = 4

    // Raw pointers exposed as let properties so the render callback can capture
    // ONLY the pointers (not the class instance), eliminating all ARC traffic
    // on the real-time audio thread.
    let controlsPtr: UnsafeMutablePointer<OscillatorControl>
    let phasesPtr: UnsafeMutablePointer<Float>
    let noiseSeedPtr: UnsafeMutablePointer<UInt32>

    init() {
        controlsPtr = .allocate(capacity: 4)
        controlsPtr.initialize(repeating: OscillatorControl(), count: 4)
        phasesPtr = .allocate(capacity: 4)
        phasesPtr.initialize(repeating: 0, count: 4)
        noiseSeedPtr = .allocate(capacity: 1)
        noiseSeedPtr.initialize(to: 123456789)
    }

    deinit {
        controlsPtr.deinitialize(count: 4)
        controlsPtr.deallocate()
        phasesPtr.deinitialize(count: 4)
        phasesPtr.deallocate()
        noiseSeedPtr.deinitialize(count: 1)
        noiseSeedPtr.deallocate()
    }

    // MARK: - Main thread API (safe to use Swift patterns)

    func getControl(_ index: Int) -> OscillatorControl {
        controlsPtr[index]
    }

    func update(_ index: Int, _ mutation: (inout OscillatorControl) -> Void) {
        mutation(&controlsPtr[index])
    }

    func anyActive() -> Bool {
        for i in 0..<count {
            if controlsPtr[i].isActive { return true }
        }
        return false
    }
}

// MARK: - Audio Source Node Factory (nonisolated)
// This free function lives OUTSIDE the @MainActor class so the render closure
// does NOT inherit @MainActor isolation. Swift 6 infers actor isolation from
// the lexical context — if this closure were created inside a @MainActor method,
// the runtime would inject a dispatch_assert_queue(mainQueue) check that crashes
// on the real-time audio thread (AURemoteIO::IOThread).

private func makeAudioSourceNode(
    format: AVAudioFormat,
    controlsPtr: UnsafeMutablePointer<OscillatorControl>,
    phasesPtr: UnsafeMutablePointer<Float>,
    noiseSeedPtr: UnsafeMutablePointer<UInt32>,
    oscillatorCount: Int,
    deltaTime: Float
) -> AVAudioSourceNode {
    AVAudioSourceNode(format: format) { @Sendable (
        _: UnsafeMutablePointer<ObjCBool>,
        _: UnsafePointer<AudioTimeStamp>,
        frameCount: AVAudioFrameCount,
        audioBufferList: UnsafeMutablePointer<AudioBufferList>
    ) -> OSStatus in

        let ablPointer = UnsafeMutableAudioBufferListPointer(audioBufferList)

        for frame in 0..<Int(frameCount) {
            var mixedSample: Float = 0

            for i in 0..<oscillatorCount {
                let ctrl = controlsPtr[i]
                guard ctrl.isActive && ctrl.amplitude > 0 else { continue }

                let phase = phasesPtr[i]
                var sample: Float = 0
                switch ctrl.waveform {
                case .sine:
                    sample = sin(2.0 * .pi * ctrl.frequency * phase)
                case .triangle:
                    let t = phase * ctrl.frequency
                    let frac = t - floor(t)
                    sample = 4.0 * abs(frac - 0.5) - 1.0
                case .square:
                    let t = phase * ctrl.frequency
                    let frac = t - floor(t)
                    sample = frac < 0.5 ? 1.0 : -1.0
                case .noise:
                    var seed = noiseSeedPtr.pointee
                    seed ^= seed << 13
                    seed ^= seed >> 17
                    seed ^= seed << 5
                    noiseSeedPtr.pointee = seed
                    sample = Float(Int32(bitPattern: seed)) / Float(Int32.max)
                }

                var newPhase = phase + deltaTime
                if newPhase > 1000.0 { newPhase -= 1000.0 }
                phasesPtr[i] = newPhase

                mixedSample += sample * ctrl.amplitude
            }

            mixedSample = max(-1.0, min(1.0, mixedSample))

            for buffer in ablPointer {
                let buf: UnsafeMutableBufferPointer<Float> = UnsafeMutableBufferPointer(buffer)
                buf[frame] = mixedSample
            }
        }
        return noErr
    }
}

@MainActor
final class SoundManager: ObservableObject {

    private var engine: AVAudioEngine?
    private var sourceNode: AVAudioSourceNode?
    private var isPlaying = false
    private var modulationTimer: Timer?

    private let bank = OscillatorBank()

    init() {
        configureAudioSession()
    }

    // MARK: - Audio Session

    private func configureAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
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
        let hardwareSampleRate = audioEngine.outputNode.outputFormat(forBus: 0).sampleRate
        let deltaTime: Float = 1.0 / Float(hardwareSampleRate)

        guard let renderFormat = AVAudioFormat(
            standardFormatWithSampleRate: hardwareSampleRate, channels: 1
        ) else { return }

        let node = makeAudioSourceNode(
            format: renderFormat,
            controlsPtr: bank.controlsPtr,
            phasesPtr: bank.phasesPtr,
            noiseSeedPtr: bank.noiseSeedPtr,
            oscillatorCount: bank.count,
            deltaTime: deltaTime
        )

        audioEngine.attach(node)
        audioEngine.connect(node, to: audioEngine.mainMixerNode, format: renderFormat)
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

        // Mute all oscillators so the render callback produces silence
        for i in 0..<bank.count {
            bank.update(i) { ctrl in
                ctrl.isActive = false
                ctrl.amplitude = 0
            }
        }

        engine?.stop()
        isPlaying = false
    }

    func stop() {
        stopEngine()
    }
}

// MARK: - Seismic Alert (SASMEX Style)

extension SoundManager {

    func playSeismicAlert(duration: TimeInterval = 3.0) {
        setupEngine()
        startEngine()

        bank.update(0) { ctrl in
            ctrl.waveform = .sine
            ctrl.isActive = true
            ctrl.amplitude = 0
        }

        let cycles = Int(duration / 0.95)
        for i in 0..<cycles {
            let offset = Double(i) * 0.95

            DispatchQueue.main.asyncAfter(deadline: .now() + offset) { [weak self] in
                self?.bank.update(0) { ctrl in
                    ctrl.frequency = 950
                    ctrl.amplitude = 0.3
                }
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + offset + 0.4) { [weak self] in
                self?.bank.update(0) { ctrl in
                    ctrl.frequency = 1200
                }
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + offset + 0.8) { [weak self] in
                self?.bank.update(0) { ctrl in
                    ctrl.amplitude = 0
                }
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
        bank.update(0) { ctrl in
            ctrl.waveform = .sine
            ctrl.frequency = 35
            ctrl.amplitude = 0
            ctrl.isActive = true
        }

        // Oscillator 1: Noise texture (filtered brown noise effect)
        bank.update(1) { ctrl in
            ctrl.waveform = .noise
            ctrl.amplitude = 0
            ctrl.isActive = true
        }

        // Fade in gradual
        let fadeSteps = 20
        let fadeDuration: TimeInterval = 1.5
        for i in 0...fadeSteps {
            let progress = Float(i) / Float(fadeSteps)
            DispatchQueue.main.asyncAfter(
                deadline: .now() + fadeDuration * Double(i) / Double(fadeSteps)
            ) { [weak self] in
                self?.bank.update(0) { ctrl in ctrl.amplitude = 0.18 * progress }
                self?.bank.update(1) { ctrl in ctrl.amplitude = 0.08 * progress }
            }
        }

        startRumbleModulation()
    }

    private func startRumbleModulation() {
        modulationTimer?.invalidate()
        var modulationTime: Float = 0
        modulationTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            Task { @MainActor in
                guard self.isPlaying else {
                    self.modulationTimer?.invalidate()
                    self.modulationTimer = nil
                    return
                }
                modulationTime += 0.05
                // LFO for sub-bass frequency (25-45 Hz)
                let lfo = sin(modulationTime * 0.3 * 2 * .pi)
                let intensityLFO = sin(modulationTime * 0.15 * 2 * .pi)
                self.bank.update(0) { ctrl in
                    ctrl.frequency = 35 + Float(lfo) * 10
                    ctrl.amplitude = 0.15 + Float(intensityLFO) * 0.06
                }

                // Random debris noise bursts
                self.bank.update(1) { ctrl in
                    if Float.random(in: 0...1) < 0.03 {
                        ctrl.amplitude = Float.random(in: 0.12...0.2)
                    } else {
                        ctrl.amplitude = max(0.04, ctrl.amplitude * 0.95)
                    }
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
        waveform: WaveformType,
        amplitude: Float,
        oscillatorIndex: Int
    ) {
        setupEngine()
        startEngine()

        bank.update(oscillatorIndex) { ctrl in
            ctrl.waveform = waveform
            ctrl.isActive = true
            ctrl.amplitude = 0
        }

        var offset: TimeInterval = 0
        for (freq, dur) in zip(frequencies, durations) {
            DispatchQueue.main.asyncAfter(deadline: .now() + offset) { [weak self] in
                self?.bank.update(oscillatorIndex) { ctrl in
                    ctrl.frequency = freq
                    ctrl.amplitude = amplitude
                }
            }
            offset += dur
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + offset) { [weak self] in
            self?.bank.update(oscillatorIndex) { ctrl in
                ctrl.amplitude = 0
                ctrl.isActive = false
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + offset + 0.1) { [weak self] in
            guard let self = self else { return }
            if !self.bank.anyActive() {
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
        bank.update(3) { ctrl in
            ctrl.waveform = .triangle
            ctrl.frequency = 329.63
            ctrl.amplitude = 0.15
            ctrl.isActive = true
        }
        fadeOutOscillator(index: 3, duration: 0.5)
    }
}

// MARK: - Fade Utilities

extension SoundManager {

    private func fadeOutOscillator(index: Int, duration: TimeInterval, steps: Int = 10) {
        let startAmp = bank.getControl(index).amplitude
        for i in 0...steps {
            let progress = Float(i) / Float(steps)
            DispatchQueue.main.asyncAfter(
                deadline: .now() + duration * Double(i) / Double(steps)
            ) { [weak self] in
                guard let self = self else { return }
                self.bank.update(index) { ctrl in
                    ctrl.amplitude = startAmp * (1.0 - progress)
                    if i == steps {
                        ctrl.isActive = false
                    }
                }
                if i == steps && !self.bank.anyActive() {
                    self.stopEngine()
                }
            }
        }
    }
}
