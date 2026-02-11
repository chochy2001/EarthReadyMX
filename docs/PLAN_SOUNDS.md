# Plan de Implementacion de Sonidos Inmersivos - EarthReady MX

## Resumen General

### Objetivo
Agregar efectos de sonido inmersivos a EarthReady MX usando **AVAudioEngine** con sintesis de audio programatica en tiempo real. Esto elimina la necesidad de archivos de audio externos, mantiene el tamano del proyecto minimo y demuestra conocimiento tecnico avanzado de AVFoundation -- un criterio diferenciador fuerte para el Swift Student Challenge.

### Impacto en Criterios de Evaluacion

| Criterio | Impacto del Sonido |
|---|---|
| **Innovation** | Sintesis de audio en tiempo real usando AVAudioSourceNode, sin archivos de audio pre-grabados |
| **Creativity** | Recreacion programatica del sonido de la alerta sismica de Mexico (SASMEX) |
| **Technical Accomplishment** | AVAudioEngine, procesamiento de senales digitales, osciladores, generacion de ruido |
| **Social Impact** | Audio inmersivo que refuerza la seriedad de la preparacion ante sismos |
| **Beyond Expectations** | La mayoria de los App Playgrounds no incluyen audio sintetizado en tiempo real |

---

## Arquitectura Tecnica

### Diagrama de Componentes

```
MyApp.swift
    |
    +-- ContentView.swift (navega entre fases)
    |       |
    |       +-- SplashView.swift     --> SoundManager.playSeismicAlert()
    |       +-- LearnView.swift      --> SoundManager.playUIFeedback()
    |       +-- SimulationView.swift --> SoundManager.playEarthquakeRumble()
    |       +-- ResultView.swift     --> SoundManager.playCelebration()
    |
    +-- SoundManager.swift (NUEVO - singleton @MainActor)
            |
            +-- AVAudioEngine
            |       |
            |       +-- AVAudioSourceNode (osciladores)
            |       +-- AVAudioMixerNode (mezcla de capas)
            |       +-- mainMixerNode --> outputNode
            |
            +-- AudioServicesPlaySystemSound (feedback UI rapido)
```

### Clase Principal: SoundManager

El `SoundManager` sera un singleton `@MainActor` con `ObservableObject` para integrarse con SwiftUI. Usara `AVAudioEngine` como motor principal de audio y `AVAudioSourceNode` para generar senales en tiempo real.

---

## Sonidos a Implementar

### 1. Alerta Sismica (Estilo SASMEX)
- **Vista:** `SplashView` - suena durante la animacion inicial del sismografo
- **Descripcion:** Replica del tono de alerta sismica de la Ciudad de Mexico. Es un tono agudo, repetitivo y claro, disenado para no confundirse con sirenas de ambulancia, bomberos o policia.
- **Tecnica:** Oscilador sinusoidal con frecuencia alternante entre ~950 Hz y ~1200 Hz, con patron de repeticion de 0.5 segundos on / 0.2 segundos off
- **Duracion:** ~3 segundos (mientras dura la animacion de shake del splash)
- **Patron de tono:** Tono ascendente-descendente que alterna entre dos frecuencias

#### Parametros de Sintesis
```
Onda: Sinusoidal (sine wave)
Frecuencia baja: 950 Hz
Frecuencia alta: 1200 Hz
Patron: 0.4s tono bajo -> 0.4s tono alto -> 0.15s silencio (repetir)
Amplitud: 0.3 (no queremos que sea ensordecedor)
Fade in: 0.1s
Fade out: 0.1s al final
```

### 2. Rumble/Temblor de Terremoto
- **Vista:** `SimulationView` - de fondo mientras el usuario responde escenarios
- **Descripcion:** Sonido de baja frecuencia que simula el retumbar de un sismo. Combinacion de ruido brown filtrado + osciladores de baja frecuencia + modulacion de amplitud aleatoria.
- **Tecnica:** Multiples capas de sintesis combinadas
- **Duracion:** Loop continuo mientras la vista este activa, con intensidad variable

#### Capas de Sintesis del Rumble

**Capa 1 - Sub-bass rumble (base del temblor)**
```
Tipo: Oscilador sinusoidal
Frecuencia: 25-45 Hz (varia aleatoriamente con LFO)
Amplitud: 0.25
LFO de frecuencia: 0.3 Hz, variacion +/- 10 Hz
Proposito: El "sentir" profundo del sismo
```

**Capa 2 - Brown noise filtrado (textura)**
```
Tipo: White noise pasado por filtro paso bajo
Frecuencia de corte: 200 Hz
Resonancia: Leve (Q = 0.7)
Amplitud: 0.15
Proposito: Textura de roca y tierra moviendose
```

**Capa 3 - Transitorios aleatorios (derrumbes)**
```
Tipo: Pulsos de ruido cortos
Frecuencia: Cada 0.5-2.0 segundos (aleatorio)
Duracion de pulso: 50-150ms
Filtro: Paso banda 100-400 Hz
Amplitud: 0.1-0.3 (aleatoria)
Proposito: Simula objetos cayendo, vidrios rompiendose
```

**Capa 4 - Modulacion de intensidad general**
```
Tipo: Envelope de amplitud que sube y baja
Ciclo: 3-5 segundos
Forma: Ondas lentas de intensidad (simula oleadas sismicas)
Proposito: El sismo no es constante, viene en oleadas
```

### 3. Sonidos de Feedback UI (Respuestas Correctas/Incorrectas)
- **Vista:** `SimulationView` - al seleccionar una opcion de respuesta
- **Duracion:** < 0.3 segundos

#### Respuesta Correcta
```
Tecnica: Dos tonos sinusoidales secuenciales (arpeggio ascendente)
Tono 1: 523 Hz (C5) por 0.1s
Tono 2: 659 Hz (E5) por 0.1s
Tono 3: 784 Hz (G5) por 0.15s
Transicion: Suave con overlap de 20ms
Amplitud: 0.2
Alternativa rapida: AudioServicesPlaySystemSound(1057) -- tono positivo del sistema
```

#### Respuesta Incorrecta
```
Tecnica: Tono descendente con leve distorsion
Tono 1: 400 Hz por 0.15s
Tono 2: 300 Hz por 0.2s
Forma de onda: Square wave (genera armonicos asperos)
Amplitud: 0.15
Alternativa rapida: AudioServicesPlaySystemSound(1053) -- tono negativo del sistema
```

### 4. Sonido Ambiental de Tension
- **Vista:** `SimulationView` - suena suavemente mientras se lee cada escenario
- **Descripcion:** Drone tonal bajo que genera sensacion de urgencia
- **Tecnica:** Acorde menor sostenido con leve detuning (desafinacion)
- **Duracion:** Continuo, fade in al aparecer escenario, fade out al responder

```
Oscilador 1: Sine wave 110 Hz (A2) -- amplitud 0.08
Oscilador 2: Sine wave 130.81 Hz (C3) -- amplitud 0.06
Oscilador 3: Sine wave 164.81 Hz (E3) -- amplitud 0.05
Detuning: +/- 1-2 Hz lento (LFO de 0.1 Hz) en cada oscilador
Efecto: Crea un drone menor amenazante pero no molesto
```

### 5. Sonido de Celebracion/Resultados
- **Vista:** `ResultView` - al mostrar el score
- **Descripcion:** Escala musical ascendente que transmite logro y exito
- **Tecnica:** Secuencia melodica con armonicos

#### Score Perfecto (100%)
```
Secuencia: C5(523) -> E5(659) -> G5(784) -> C6(1047)
Duracion por nota: 0.12s con overlap
Onda: Sine + leve triangular para brillo
Amplitud: 0.25 con fade in en cada nota
Efecto extra: Sweep de frecuencia ascendente de fondo (200 -> 2000 Hz en 0.5s)
```

#### Score Bueno (>= 60%)
```
Secuencia: C5(523) -> E5(659) -> G5(784)
Duracion por nota: 0.15s
Onda: Sinusoidal pura
Amplitud: 0.2
```

#### Score Bajo (< 60%)
```
Secuencia: Tono unico sostenido E4(330) -> fade out
Duracion: 0.5s
Onda: Triangular (suena mas calido/compasivo)
Amplitud: 0.15
```

---

## Implementacion del SoundManager

### Codigo Principal

```swift
import AVFoundation
import AudioToolbox

@MainActor
final class SoundManager: ObservableObject {

    static let shared = SoundManager()

    private var engine: AVAudioEngine?
    private var sourceNode: AVAudioSourceNode?
    private var isPlaying = false

    // Parametros atomicos para comunicacion con el hilo de audio (no-lock)
    // Usamos nonisolated(unsafe) ya que el render block corre en hilo de audio
    nonisolated(unsafe) private var currentFrequency: Float = 0
    nonisolated(unsafe) private var currentAmplitude: Float = 0
    nonisolated(unsafe) private var currentPhase: Float = 0
    nonisolated(unsafe) private var currentWaveform: WaveformType = .sine
    nonisolated(unsafe) private var shouldGenerateNoise: Bool = false
    nonisolated(unsafe) private var noiseAmplitude: Float = 0

    enum WaveformType: Sendable {
        case sine
        case triangle
        case square
        case sawtooth
    }

    private init() {
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
            print("SoundManager: Error configurando audio session: \(error)")
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
                var sample: Float = 0

                // Generar onda tonal
                if self.currentAmplitude > 0 && self.currentFrequency > 0 {
                    switch self.currentWaveform {
                    case .sine:
                        sample = sin(2.0 * .pi * self.currentFrequency * self.currentPhase)
                    case .triangle:
                        let period = 1.0 / self.currentFrequency
                        let pos = self.currentPhase.truncatingRemainder(dividingBy: period) / period
                        if pos < 0.25 {
                            sample = pos * 4.0
                        } else if pos < 0.75 {
                            sample = 2.0 - pos * 4.0
                        } else {
                            sample = pos * 4.0 - 4.0
                        }
                    case .square:
                        let period = 1.0 / self.currentFrequency
                        let pos = self.currentPhase.truncatingRemainder(dividingBy: period) / period
                        sample = pos < 0.5 ? 1.0 : -1.0
                    case .sawtooth:
                        let period = 1.0 / self.currentFrequency
                        let pos = self.currentPhase.truncatingRemainder(dividingBy: period) / period
                        sample = 2.0 * pos - 1.0
                    }
                    sample *= self.currentAmplitude
                }

                // Agregar ruido (para texturas de terremoto)
                if self.shouldGenerateNoise {
                    sample += Float.random(in: -1.0...1.0) * self.noiseAmplitude
                }

                // Clamp para evitar distorsion
                sample = max(-1.0, min(1.0, sample))

                self.currentPhase += deltaTime

                // Escribir en todos los canales
                for buffer in ablPointer {
                    let buf: UnsafeMutableBufferPointer<Float> = UnsafeMutableBufferPointer(buffer)
                    buf[frame] = sample
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
            print("SoundManager: Error starting engine: \(error)")
            #endif
        }
    }

    private func stopEngine() {
        engine?.stop()
        isPlaying = false
        currentAmplitude = 0
        currentFrequency = 0
        shouldGenerateNoise = false
    }
}
```

### Implementacion de la Alerta Sismica

```swift
extension SoundManager {

    /// Reproduce el sonido de alerta sismica estilo SASMEX
    /// - Parameter duration: Duracion total de la alerta en segundos
    func playSeismicAlert(duration: TimeInterval = 3.0) {
        setupEngine()
        startEngine()

        currentWaveform = .sine
        currentAmplitude = 0 // Empezar en silencio para fade in
        shouldGenerateNoise = false

        let cycles = Int(duration / 0.95) // Cada ciclo dura ~0.95s
        for i in 0..<cycles {
            let offset = Double(i) * 0.95

            // Tono bajo (950 Hz) por 0.4s
            DispatchQueue.main.asyncAfter(deadline: .now() + offset) { [weak self] in
                self?.currentFrequency = 950
                self?.currentAmplitude = 0.3
            }

            // Tono alto (1200 Hz) por 0.4s
            DispatchQueue.main.asyncAfter(deadline: .now() + offset + 0.4) { [weak self] in
                self?.currentFrequency = 1200
            }

            // Silencio 0.15s
            DispatchQueue.main.asyncAfter(deadline: .now() + offset + 0.8) { [weak self] in
                self?.currentAmplitude = 0
            }
        }

        // Fade out final
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) { [weak self] in
            self?.fadeOut(duration: 0.2)
        }
    }

    private func fadeOut(duration: TimeInterval, steps: Int = 10) {
        let startAmp = currentAmplitude
        for i in 0...steps {
            let progress = Float(i) / Float(steps)
            DispatchQueue.main.asyncAfter(deadline: .now() + duration * Double(i) / Double(steps)) { [weak self] in
                self?.currentAmplitude = startAmp * (1.0 - progress)
                if i == steps {
                    self?.stopEngine()
                }
            }
        }
    }
}
```

### Implementacion del Rumble de Terremoto

```swift
extension SoundManager {

    /// Inicia el sonido de rumble de terremoto
    /// Se debe llamar stopEarthquakeRumble() para detenerlo
    func playEarthquakeRumble() {
        setupEngine()
        startEngine()

        // Configurar capa base: sub-bass
        currentWaveform = .sine
        currentFrequency = 35  // Hz - sub bass
        currentAmplitude = 0   // Empezamos en 0 para fade in
        shouldGenerateNoise = true
        noiseAmplitude = 0.08  // Ruido sutil como textura

        // Fade in gradual del rumble
        let fadeSteps = 20
        let fadeDuration: TimeInterval = 1.5
        for i in 0...fadeSteps {
            let progress = Float(i) / Float(fadeSteps)
            DispatchQueue.main.asyncAfter(
                deadline: .now() + fadeDuration * Double(i) / Double(fadeSteps)
            ) { [weak self] in
                self?.currentAmplitude = 0.2 * progress
                self?.noiseAmplitude = 0.1 * progress
            }
        }

        // Modulacion continua de frecuencia (simula oleadas sismicas)
        startFrequencyModulation()
    }

    private func startFrequencyModulation() {
        // Varia la frecuencia del oscilador base lentamente
        // para simular las ondas P y S del sismo
        var modulationTime: Float = 0
        let modulationTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] timer in
            guard let self = self, self.isPlaying else {
                timer.invalidate()
                return
            }
            Task { @MainActor in
                modulationTime += 0.05
                // LFO lento que varia la frecuencia entre 25-45 Hz
                let lfo = sin(modulationTime * 0.3 * 2 * .pi)
                self.currentFrequency = 35 + Float(lfo) * 10

                // Variacion de intensidad (oleadas)
                let intensityLFO = sin(modulationTime * 0.15 * 2 * .pi)
                self.currentAmplitude = 0.15 + Float(intensityLFO) * 0.08

                // Pulsos aleatorios de ruido (simula derrumbes)
                if Float.random(in: 0...1) < 0.03 {
                    self.noiseAmplitude = Float.random(in: 0.15...0.25)
                } else {
                    self.noiseAmplitude = max(0.05, self.noiseAmplitude * 0.95)
                }
            }
        }
        RunLoop.main.add(modulationTimer, forMode: .common)
    }

    /// Detiene el sonido de rumble con fade out
    func stopEarthquakeRumble() {
        fadeOut(duration: 1.0)
    }
}
```

### Implementacion de Feedback UI

```swift
extension SoundManager {

    /// Reproduce feedback sonoro para respuesta correcta
    func playCorrectAnswer() {
        playToneSequence(
            frequencies: [523.25, 659.25, 783.99], // C5, E5, G5
            durations: [0.1, 0.1, 0.15],
            waveform: .sine,
            amplitude: 0.2
        )
    }

    /// Reproduce feedback sonoro para respuesta incorrecta
    func playIncorrectAnswer() {
        playToneSequence(
            frequencies: [400, 300],
            durations: [0.15, 0.2],
            waveform: .square,
            amplitude: 0.12
        )
    }

    private func playToneSequence(
        frequencies: [Float],
        durations: [TimeInterval],
        waveform: WaveformType,
        amplitude: Float
    ) {
        setupEngine()
        startEngine()

        currentWaveform = waveform
        shouldGenerateNoise = false

        var offset: TimeInterval = 0
        for (freq, dur) in zip(frequencies, durations) {
            DispatchQueue.main.asyncAfter(deadline: .now() + offset) { [weak self] in
                self?.currentFrequency = freq
                self?.currentAmplitude = amplitude
            }
            offset += dur
        }

        // Silencio al final
        DispatchQueue.main.asyncAfter(deadline: .now() + offset) { [weak self] in
            self?.currentAmplitude = 0
        }

        // Apagar engine despues de un momento
        DispatchQueue.main.asyncAfter(deadline: .now() + offset + 0.1) { [weak self] in
            self?.stopEngine()
        }
    }
}
```

### Alternativa Rapida con SystemSoundID

Para feedback UI instantaneo sin latencia, se puede usar como fallback o complemento:

```swift
import AudioToolbox

extension SoundManager {

    /// Feedback haptico + sonido del sistema para respuesta correcta
    func playSystemCorrect() {
        AudioServicesPlaySystemSound(1057) // Tink (positivo)
    }

    /// Feedback haptico + sonido del sistema para respuesta incorrecta
    func playSystemIncorrect() {
        AudioServicesPlaySystemSound(1053) // Tono negativo
    }

    /// Vibrar el dispositivo (simula temblor)
    func playHapticFeedback() {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
    }
}
```

### Implementacion de Sonido de Celebracion

```swift
extension SoundManager {

    /// Reproduce sonido de celebracion basado en el score
    func playCelebration(scorePercentage: Double) {
        if scorePercentage == 100 {
            playPerfectScore()
        } else if scorePercentage >= 60 {
            playGoodScore()
        } else {
            playLowScore()
        }
    }

    private func playPerfectScore() {
        // Arpeggio de C mayor ascendente hasta C6
        playToneSequence(
            frequencies: [523.25, 659.25, 783.99, 1046.50], // C5, E5, G5, C6
            durations: [0.12, 0.12, 0.12, 0.25],
            waveform: .sine,
            amplitude: 0.25
        )
    }

    private func playGoodScore() {
        // Triada de C mayor
        playToneSequence(
            frequencies: [523.25, 659.25, 783.99], // C5, E5, G5
            durations: [0.15, 0.15, 0.2],
            waveform: .sine,
            amplitude: 0.2
        )
    }

    private func playLowScore() {
        // Tono unico que se desvanece
        setupEngine()
        startEngine()
        currentWaveform = .triangle
        currentFrequency = 329.63 // E4
        currentAmplitude = 0.15
        shouldGenerateNoise = false
        fadeOut(duration: 0.5)
    }
}
```

### Sonido Ambiental de Tension

```swift
extension SoundManager {

    /// Inicia un drone tonal de tension para la simulacion
    func playTensionDrone() {
        setupEngine()
        startEngine()

        currentWaveform = .sine
        currentFrequency = 110 // A2
        currentAmplitude = 0
        shouldGenerateNoise = false

        // Fade in gradual
        let steps = 15
        for i in 0...steps {
            let progress = Float(i) / Float(steps)
            DispatchQueue.main.asyncAfter(
                deadline: .now() + 1.0 * Double(i) / Double(steps)
            ) { [weak self] in
                self?.currentAmplitude = 0.06 * progress
            }
        }

        // Detuning sutil con LFO
        startDetuneLFO()
    }

    private func startDetuneLFO() {
        var time: Float = 0
        let timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] timer in
            guard let self = self, self.isPlaying else {
                timer.invalidate()
                return
            }
            Task { @MainActor in
                time += 0.05
                // LFO muy lento que varia la frecuencia +/- 2 Hz
                let detune = sin(time * 0.1 * 2 * .pi) * 2
                self.currentFrequency = 110 + detune
            }
        }
        RunLoop.main.add(timer, forMode: .common)
    }

    /// Detiene el drone de tension
    func stopTensionDrone() {
        fadeOut(duration: 0.5)
    }
}
```

---

## Arquitectura Avanzada: Multi-Oscilador

Para mezclar multiples osciladores simultaneamente (necesario para el rumble de terremoto con capas), se necesita una version mas avanzada del render block:

```swift
struct Oscillator: Sendable {
    var frequency: Float = 0
    var amplitude: Float = 0
    var phase: Float = 0
    var waveform: WaveformType = .sine
    var isActive: Bool = false

    enum WaveformType: Sendable {
        case sine, triangle, square, sawtooth, noise
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
        case .sawtooth:
            let t = phase * frequency
            let frac = t - floor(t)
            sample = 2.0 * frac - 1.0
        case .noise:
            sample = Float.random(in: -1.0...1.0)
        }

        phase += deltaTime
        // Evitar overflow de phase reseteando periodicamente
        if phase > 1000.0 { phase -= 1000.0 }

        return sample * amplitude
    }
}
```

El render block multi-oscilador:

```swift
// Dentro del SoundManager avanzado
private let maxOscillators = 6
nonisolated(unsafe) private var oscillators: [Oscillator] = Array(
    repeating: Oscillator(), count: 6
)

// En el render block de AVAudioSourceNode:
let node = AVAudioSourceNode { [unowned self] (_, _, frameCount, audioBufferList) -> OSStatus in
    let ablPointer = UnsafeMutableAudioBufferListPointer(audioBufferList)

    for frame in 0..<Int(frameCount) {
        var mixedSample: Float = 0

        for i in 0..<self.maxOscillators {
            mixedSample += self.oscillators[i].nextSample(deltaTime: deltaTime)
        }

        // Clamp final
        mixedSample = max(-1.0, min(1.0, mixedSample))

        for buffer in ablPointer {
            let buf: UnsafeMutableBufferPointer<Float> = UnsafeMutableBufferPointer(buffer)
            buf[frame] = mixedSample
        }
    }
    return noErr
}
```

Con esta arquitectura, los osciladores se usarian asi:

| Oscilador | Uso - Rumble | Uso - Alerta | Uso - Feedback |
|---|---|---|---|
| 0 | Sub-bass 35 Hz | Tono 950/1200 Hz | Nota 1 |
| 1 | Brown noise filtrado | -- | Nota 2 |
| 2 | Transitorios de derrumbe | -- | Nota 3 |
| 3 | Modulacion de intensidad | -- | -- |
| 4 | -- | -- | -- |
| 5 | -- | -- | -- |

---

## Configuracion de AVAudioSession

### Para App Playground (.swiftpm)

```swift
private func configureAudioSession() {
    do {
        let session = AVAudioSession.sharedInstance()

        // .playback: audio es central a la funcionalidad de la app
        // .mixWithOthers: no interrumpir otros audio (respetuoso)
        try session.setCategory(
            .playback,
            mode: .default,
            options: [.mixWithOthers]
        )

        // Buffer size pequeno para baja latencia en feedback UI
        try session.setPreferredIOBufferDuration(0.005) // 5ms

        try session.setActive(true)
    } catch {
        #if DEBUG
        print("SoundManager: Audio session error: \(error)")
        #endif
    }
}
```

### Consideraciones Importantes para .swiftpm

1. **No se necesita `needsIndefiniteExecution`**: A diferencia de Swift Playgrounds clasicos, los App Playgrounds (.swiftpm) corren como apps reales.
2. **AVAudioEngine funciona sin restricciones**: El App Playground tiene acceso completo a AVFoundation.
3. **Audio session se activa automaticamente**: Pero es buena practica configurarlo explicitamente.
4. **Silent mode**: Con `.playback` category, el audio suena incluso con silent mode. Con `.ambient`, se respeta el switch de silencio. Para una app de emergencia, `.playback` es apropiado.

---

## Manejo de Archivos de Audio vs. Sintesis

### Comparacion

| Aspecto | Archivos de Audio | Sintesis Programatica |
|---|---|---|
| Tamano del .swiftpm | Aumenta (cada WAV/MP3 suma KB-MB) | 0 bytes adicionales (solo codigo) |
| Complejidad de codigo | Baja (AVAudioPlayer) | Alta (AVAudioEngine + DSP) |
| Calidad de sonido | Alta (pre-grabado) | Dependiente de la implementacion |
| Flexibilidad | Fija (archivo estatico) | Total (parametros en tiempo real) |
| Impresion tecnica SSC | Moderada | Alta (demuestra conocimiento DSP) |
| Mantenimiento | Hay que gestionar archivos | Todo en codigo |
| Latencia | Mas alta (cargar archivo) | Mas baja (genera en memoria) |

### Recomendacion: Sintesis Programatica

Para el Swift Student Challenge se recomienda **sintesis pura** porque:
1. **Demuestra conocimiento tecnico avanzado** que los jueces valoran
2. **Mantiene el proyecto minimo** (limite de 25 MB)
3. **Los sonidos que necesitamos son simples** (tonos, ruido, osciladores)
4. **Es mas "engineering"** que simplemente reproducir un MP3

### Alternativa Hibrida (si se necesita)

Si en algun momento se necesita un archivo de audio, se puede incluir en la carpeta `Resources/` del .swiftpm:

```
EarthReadyMXFinal.swiftpm/
    Resources/
        alert_sound.wav    <-- Bundle.main.url(forResource:withExtension:)
    SoundManager.swift
    ...
```

Y acceder con:
```swift
if let url = Bundle.main.url(forResource: "alert_sound", withExtension: "wav") {
    let player = try AVAudioPlayer(contentsOf: url)
    player.play()
}
```

---

## Puntos de Integracion con Vistas Existentes

### SplashView.swift

```swift
// En startAnimationSequence(), cuando inicia el shake:
.onAppear {
    startAnimationSequence()
    SoundManager.shared.playSeismicAlert(duration: 2.5)
}

// Al desaparecer:
.onDisappear {
    seismographTimer?.invalidate()
    seismographTimer = nil
    // El sonido de alerta ya tiene su propio fade out
}
```

### LearnView.swift

```swift
// En el boton "Mark as Read" -- feedback sutil al completar fase
Button(action: {
    _ = withAnimation {
        gameState.learnPhasesCompleted.insert(selectedPhase)
    }
    SoundManager.shared.playCorrectAnswer() // feedback positivo
    // ...
})

// En el boton "Test Yourself" -- transicion dramatica
Button(action: {
    SoundManager.shared.playSystemCorrect() // feedback haptico
    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
        gameState.currentPhase = .simulation
    }
})
```

### SimulationView.swift

```swift
// Al aparecer la vista -- iniciar ambiente de tension
.onAppear {
    SoundManager.shared.playTensionDrone()
}

// Al seleccionar opcion:
Button(action: {
    guard selectedOption == nil else { return }
    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
        selectedOption = option
        showExplanation = true
        gameState.answerScenario(scenario, correct: option.isCorrect)
    }
    if option.isCorrect {
        SoundManager.shared.playCorrectAnswer()
    } else {
        SoundManager.shared.playIncorrectAnswer()
        SoundManager.shared.playHapticFeedback() // vibrar para enfatizar
        // ... shake animation existente ...
    }
})

// Al navegar al siguiente escenario -- reiniciar drone
// Al salir de la vista:
.onDisappear {
    SoundManager.shared.stopTensionDrone()
}
```

### ResultView.swift

```swift
// En startAnimationSequence(), cuando se muestra el score:
private func startAnimationSequence() {
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) { showScore = true }
    }
    // Sonido de celebracion sincronizado con la animacion del ring
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
        SoundManager.shared.playCelebration(scorePercentage: gameState.scorePercentage)
    }
    // ... resto de la secuencia ...
}
```

---

## Consideraciones de Swift 6 y Concurrencia

### Problemas Potenciales

1. **AVAudioSourceNode render block** corre en un hilo de audio separado (no MainActor)
2. Las variables compartidas entre MainActor y el hilo de audio necesitan ser thread-safe
3. Swift 6 con strict concurrency checkea esto en compilacion

### Solucion: `nonisolated(unsafe)`

Para las variables que se leen en el render block (hilo de audio) y se escriben desde MainActor:

```swift
@MainActor
final class SoundManager: ObservableObject {
    // Estas variables se leen desde el render block (hilo de audio)
    // y se escriben desde MainActor. Usamos nonisolated(unsafe)
    // porque sabemos que la escritura desde MainActor y la lectura
    // desde el hilo de audio son "safe enough" para Float atomico.
    nonisolated(unsafe) private var currentFrequency: Float = 0
    nonisolated(unsafe) private var currentAmplitude: Float = 0
    nonisolated(unsafe) private var currentPhase: Float = 0
}
```

### Alternativa: Atomics

Si el compilador se queja, usar `OSAtomicCompareAndSwap` o un wrapper atomico:

```swift
import os

final class AtomicFloat: @unchecked Sendable {
    private let lock = OSAllocatedUnfairLock(initialState: Float(0))

    var value: Float {
        get { lock.withLock { $0 } }
        set { lock.withLock { $0 = newValue } }
    }
}
```

**Nota:** Para el render block de audio, los locks son generalmente aceptables para lecturas simples de Float, ya que la contention es minima. Sin embargo, **NO se deben usar locks pesados** ni allocations dentro del render block.

---

## Estrategias de Fallback

### Dispositivos sin Altavoces / Audio Deshabilitado

```swift
extension SoundManager {

    var isAudioAvailable: Bool {
        let session = AVAudioSession.sharedInstance()
        return session.outputVolume > 0 &&
               !session.outputDataSources.isNilOrEmpty
    }

    /// Wrapper que verifica disponibilidad antes de reproducir
    func safePlay(_ action: @escaping () -> Void) {
        guard isAudioAvailable else {
            // Fallback: usar haptic feedback
            playHapticFeedback()
            return
        }
        action()
    }
}
```

### Estrategia de Degradacion Graceful

1. **Nivel 1 (Completo):** AVAudioEngine con sintesis completa
2. **Nivel 2 (Basico):** Solo AudioServicesPlaySystemSound para feedback
3. **Nivel 3 (Silencioso):** Solo haptic feedback (vibracion)
4. **Nivel 4 (Nada):** Sin feedback auditivo ni haptico (la app funciona igual visualmente)

```swift
enum AudioCapability {
    case fullSynthesis    // AVAudioEngine disponible
    case systemSoundsOnly // Solo SystemSoundID
    case hapticOnly       // Solo vibracion
    case none             // Sin audio

    static var current: AudioCapability {
        // Verificar si AVAudioEngine funciona
        let engine = AVAudioEngine()
        do {
            try engine.start()
            engine.stop()
            return .fullSynthesis
        } catch {
            // Intentar system sounds
            return .systemSoundsOnly
        }
    }
}
```

---

## Estimacion de Esfuerzo

| Tarea | Tiempo Estimado | Prioridad |
|---|---|---|
| Estructura base de SoundManager | 1.5 horas | P0 - Critica |
| AVAudioEngine setup + render block | 2 horas | P0 - Critica |
| Alerta sismica SASMEX | 1.5 horas | P1 - Alta |
| Rumble de terremoto (multi-capa) | 3 horas | P1 - Alta |
| Feedback UI (correcto/incorrecto) | 1 hora | P1 - Alta |
| Sonido de celebracion | 1 hora | P2 - Media |
| Drone de tension | 1.5 horas | P2 - Media |
| Integracion con vistas existentes | 2 horas | P0 - Critica |
| Fallbacks y manejo de errores | 1 hora | P1 - Alta |
| Testing y ajuste de parametros | 2 horas | P1 - Alta |
| Concurrencia Swift 6 compliance | 1.5 horas | P0 - Critica |
| **TOTAL** | **~18 horas** | |

### Orden de Implementacion Recomendado

1. `SoundManager` base con AVAudioEngine y un oscilador simple
2. Feedback UI (correcto/incorrecto) -- impacto inmediato visible
3. Alerta sismica -- muy memorable e impactante para demo
4. Rumble de terremoto -- la pieza mas impresionante tecnicamente
5. Celebracion y drone de tension
6. Fallbacks y pulido

---

## Testing

### Unit Tests

```swift
import XCTest
@testable import AppModule

@MainActor
final class SoundManagerTests: XCTestCase {

    func testSoundManagerSingleton() {
        let a = SoundManager.shared
        let b = SoundManager.shared
        XCTAssertTrue(a === b)
    }

    func testPlaySeismicAlertDoesNotCrash() {
        // Verificar que no lanza excepciones
        SoundManager.shared.playSeismicAlert(duration: 0.5)
        // Esperar a que termine
        let exp = expectation(description: "alert completes")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            exp.fulfill()
        }
        wait(for: [exp], timeout: 2.0)
    }

    func testPlayCorrectAnswerDoesNotCrash() {
        SoundManager.shared.playCorrectAnswer()
        let exp = expectation(description: "sound completes")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }

    func testPlayIncorrectAnswerDoesNotCrash() {
        SoundManager.shared.playIncorrectAnswer()
        let exp = expectation(description: "sound completes")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }

    func testStopEngineResetsState() {
        SoundManager.shared.playEarthquakeRumble()
        SoundManager.shared.stopEarthquakeRumble()
        // Verificar que se puede volver a reproducir sin crash
        let exp = expectation(description: "restart works")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            SoundManager.shared.playCorrectAnswer()
            exp.fulfill()
        }
        wait(for: [exp], timeout: 3.0)
    }
}
```

### Testing Manual Checklist

- [ ] Audio se escucha en iPad simulator
- [ ] Audio se escucha en iPhone simulator
- [ ] Audio se escucha en dispositivo fisico
- [ ] Silent mode se respeta (o no, segun configuracion)
- [ ] No hay memory leaks al navegar entre vistas repetidamente
- [ ] El audio se detiene correctamente al cambiar de vista
- [ ] No hay crashes al reproducir multiples sonidos rapidamente
- [ ] El audio no interfiere con VoiceOver (accesibilidad)
- [ ] Los sonidos no son molestos despues de uso repetido (volumen correcto)
- [ ] El fade in/out es suave sin clicks o pops

---

## Referencias Tecnicas

- [Apple: Building a Signal Generator](https://developer.apple.com/documentation/avfaudio/audio_engine/building_a_signal_generator)
- [AVAudioSourceNode y AVAudioSinkNode: Low-Level Audio In Swift](https://orjpap.github.io/swift/real-time/audio/avfoundation/2020/06/19/avaudiosourcenode.html)
- [Building a Synthesizer in Swift - Grant Emerson](https://grantjemerson.github.io/blog/BuildingASynthesizerInSwift/)
- [Building a Synthesizer in Swift - SwiftMoji](https://medium.com/better-programming/building-a-synthesizer-in-swift-866cd15b731)
- [SwiftSynth en GitHub](https://github.com/GrantJEmerson/SwiftSynth)
- [WWDC19 - What's New in AVAudioEngine](https://developer.apple.com/videos/play/wwdc2019/510/)
- [AVAudioSession.CategoryOptions](https://developer.apple.com/documentation/avfaudio/avaudiosession/categoryoptions-swift.struct)
- [iOS System Sounds Library (SystemSoundID)](https://github.com/TUNER88/iOSSystemSoundsLibrary)
- [Sistema de Alerta Sismica Mexicano (SASMEX)](https://en.wikipedia.org/wiki/Mexican_Seismic_Alert_System)
- [SASMEX: A Retrospective View - Frontiers](https://www.frontiersin.org/journals/earth-science/articles/10.3389/feart.2022.827236/full)
- [Swift Student Challenge 2026 - Eligibility](https://developer.apple.com/swift-student-challenge/eligibility/)
- [Swift 6 Sendable and Concurrency](https://fatbobman.com/en/posts/sendable-sending-nonsending/)

---

## Notas Pendientes / TODO

- [ ] Determinar si el audio sintetizado suena bien en los altavoces pequenos del iPad -- puede requerir ajustar frecuencias del rumble hacia arriba (los altavoces del iPad no reproducen bien por debajo de ~80 Hz)
- [ ] Investigar `UIFeedbackGenerator` como complemento haptico para el shake effect
- [ ] Considerar agregar un boton de mute global en la UI para usuarios que prefieran silencio
- [ ] Evaluar si `AVAudioUnitEQ` seria util para filtrar el brown noise en el rumble
- [ ] Probar en Swift Playgrounds 4.6 en iPad directamente para verificar compatibilidad completa
- [ ] Verificar que el tamano del .swiftpm no exceda 25 MB con el codigo adicional (no deberia, es solo codigo)
