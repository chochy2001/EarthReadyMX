# Plan de Implementacion: CoreHaptics para EarthReady MX

## Indice

1. [Resumen y Por Que Importa](#1-resumen-y-por-que-importa)
2. [Arquitectura Tecnica](#2-arquitectura-tecnica)
3. [Patrones Hapticos a Implementar](#3-patrones-hapticos-a-implementar)
4. [Snippets de Codigo](#4-snippets-de-codigo)
5. [Puntos de Integracion con Vistas Existentes](#5-puntos-de-integracion-con-vistas-existentes)
6. [Compatibilidad con App Playground (.swiftpm)](#6-compatibilidad-con-app-playground-swiftpm)
7. [Esfuerzo Estimado](#7-esfuerzo-estimado)
8. [Problemas Potenciales y Mitigaciones](#8-problemas-potenciales-y-mitigaciones)
9. [Checklist de Implementacion](#9-checklist-de-implementacion)
10. [Referencias](#10-referencias)

---

## 1. Resumen y Por Que Importa

### Contexto

EarthReady MX es una app de preparacion ante sismos para el Swift Student Challenge. La app guia al
usuario a traves de tres fases: aprender protocolos de seguridad, simular escenarios de emergencia y
revisar resultados. Actualmente la experiencia es puramente visual con animaciones de sacudida
(`ShakeEffect`), sismografo animado y particulas.

### Por Que CoreHaptics

CoreHaptics transforma la experiencia de "ver un sismo" a "sentir un sismo". Para una app educativa
sobre terremotos, la retroalimentacion haptica no es un adorno -- es el diferenciador clave que hace
que el usuario realmente comprenda la urgencia de estar preparado.

**Impacto en el Swift Student Challenge:**

- **Uso innovador de frameworks de Apple**: Los jueces valoran la integracion creativa de APIs del
  sistema. CoreHaptics demuestra dominio tecnico avanzado.
- **Experiencia inmersiva**: Sentir las ondas P y S de un sismo en el dispositivo crea una conexion
  emocional que las animaciones solas no logran.
- **Accesibilidad**: Los patrones hapticos agregan una dimension sensorial adicional, beneficiando
  a usuarios con discapacidades visuales.
- **Diferenciacion**: La mayoria de las apps del challenge se limitan a visuales; agregar hapticos
  posiciona esta submission por encima del promedio.

### Objetivo

Implementar cuatro categorias de retroalimentacion haptica:

| Categoria | Descripcion | Vista(s) |
|-----------|-------------|----------|
| Sismo en Splash | Vibracion sincronizada con la animacion del sismografo | `SplashView` |
| Simulacion de Sismo | Patron progresivo ondas P a ondas S | `SimulationView` |
| Feedback de Respuesta | Tap correcto/incorrecto con haptico distinto | `SimulationView` |
| Celebracion/Alerta | Patron de exito o motivacion en resultados | `ResultView` |

---

## 2. Arquitectura Tecnica

### Clase Principal: `HapticManager`

Se creara un archivo nuevo `HapticManager.swift` con una clase `@MainActor` que encapsula toda la
logica de CoreHaptics.

**Razon de usar `@MainActor` en lugar de singleton con `static let shared`:**
- Swift 6 requiere strict concurrency. `CHHapticEngine` no es `Sendable`.
- Al ser `@MainActor`, garantizamos que todas las operaciones del engine ocurren en el hilo
  principal, evitando data races.
- La clase se inyectara como `@StateObject` o `@EnvironmentObject` desde `MyApp`.

### Diagrama de Arquitectura

```
MyApp (@main)
  |
  |-- @StateObject gameState: GameState
  |-- @StateObject hapticManager: HapticManager
  |
  +-- ContentView
        |-- .environmentObject(hapticManager)
        |
        |-- SplashView
        |     +-- hapticManager.playEarthquakeSplash()
        |
        |-- LearnView
        |     (sin hapticos por ahora, fase futura)
        |
        |-- SimulationView
        |     +-- hapticManager.playEarthquakeSimulation()
        |     +-- hapticManager.playCorrectAnswer()
        |     +-- hapticManager.playWrongAnswer()
        |
        +-- ResultView
              +-- hapticManager.playPerfectScore()
              +-- hapticManager.playEncouragement()
```

### Ciclo de Vida del Engine

```
prepareEngine()           -- Crear CHHapticEngine, configurar handlers
     |
startEngine()             -- engine.start(), listo para reproducir
     |
playPattern(...)          -- makePlayer(with: pattern), player.start()
     |
stopEngine()              -- engine.stop(), liberar recursos
     |
resetHandler              -- Re-crear engine si hay error del sistema
stoppedHandler            -- Manejar cuando iOS detiene el engine
```

**Configuracion del Engine:**
- `playsHapticsOnly = true`: No necesitamos audio sintetico, esto reduce latencia de inicio.
- `isAutoShutdownEnabled = true`: Permite que iOS libere recursos cuando no se usa.
- `resetHandler`: Re-inicia el engine automaticamente tras un reset del sistema.
- `stoppedHandler`: Marca una flag para re-crear el engine cuando se necesite.

---

## 3. Patrones Hapticos a Implementar

### 3.1 Sismo en Splash Screen

**Duracion total**: ~2.2 segundos (sincronizado con `startAnimationSequence()`)

**Diseno del patron:**

Simula un sismo real de magnitud moderada (5.0-6.0). Los sismos reales comienzan con ondas P
(compresionales, rapidas, vibracion sutil) seguidas de ondas S (transversales, mas lentas,
sacudida violenta).

```
Tiempo (s):  0.0  0.3  0.5  0.8  1.0  1.3  1.5  1.8  2.0  2.2
             |    |    |    |    |    |    |    |    |    |
Fase:        |-P-wave (gentle)-|----S-wave (violent)-----|--decay--|
Intensity:   0.2  0.3  0.4  0.6  0.8  1.0  0.9  0.7  0.3  0.0
Sharpness:   0.1  0.2  0.2  0.5  0.7  0.8  0.6  0.4  0.2  0.0
```

**Composicion:**
- **Ondas P (0.0 - 0.8s)**: Evento `hapticContinuous` con intensidad baja (0.2-0.4) y sharpness
  bajo (0.1-0.2). Simula el temblor inicial que la gente a veces ni nota.
- **Ondas S (0.8 - 1.8s)**: Evento `hapticContinuous` con intensidad alta (0.8-1.0) y sharpness
  medio-alto (0.5-0.8). Intercalado con eventos `hapticTransient` para simular los "golpes"
  repentinos del sismo.
- **Decay (1.8 - 2.2s)**: Curva de parametros que lleva intensidad de 0.7 a 0.0. Simula como
  se siente cuando el sismo va cediendo.

### 3.2 Simulacion de Sismo (Fondo durante Escenarios)

**Duracion**: Continua mientras se muestra cada escenario, ~3-5 segundos

**Diseno del patron:**

Mas sutil que el splash. El objetivo es crear tension sin distraer de la lectura.

```
Tiempo (s):  0.0       1.0       2.0       3.0       4.0       5.0
             |         |         |         |         |         |
Intensity:   0.0 ----> 0.3 ----> 0.4 ----> 0.3 ----> 0.2 ----> 0.0
Sharpness:   0.1       0.2       0.3       0.2       0.1       0.0
Transients:       *         *  *        *              *
```

**Composicion:**
- Un evento `hapticContinuous` de 5 segundos con intensidad baja (0.3-0.4).
- `CHHapticParameterCurve` para crear la onda envolvente (ramp up, sustain, decay).
- Eventos `hapticTransient` espaciados irregularmente para simular replicas.
- Se dispara una sola vez al entrar a cada escenario, no se repite.

### 3.3 Feedback de Respuesta Correcta

**Duracion**: ~0.3 segundos

**Diseno del patron:**

Patron de "doble tap" similar al feedback de exito de Apple Pay.

```
Tiempo (s):  0.0   0.1   0.15  0.25
             |     |     |     |
Event:       TAP         TAP
Intensity:   0.6         0.8
Sharpness:   0.5         0.7
```

**Composicion:**
- Dos eventos `hapticTransient` separados por 150ms.
- El segundo mas fuerte que el primero (sensacion de confirmacion).
- Sharpness medio para un tacto "limpio" y satisfactorio.

### 3.4 Feedback de Respuesta Incorrecta

**Duracion**: ~0.5 segundos

**Diseno del patron:**

Patron de "error" - tres taps rapidos con intensidad descendente, similar a la negacion de Face ID.

```
Tiempo (s):  0.0   0.1   0.2   0.3   0.4
             |     |     |     |     |
Event:       TAP   TAP   TAP
Intensity:   0.8   0.5   0.3
Sharpness:   0.9   0.7   0.5
```

**Composicion:**
- Tres eventos `hapticTransient` separados por 100ms.
- Intensidad y sharpness decrecientes (sensacion de "algo salio mal").
- Sharpness alto en el primer tap para captar atencion.
- Se sincroniza con el `ShakeEffect` visual existente.

### 3.5 Celebracion de Puntaje Perfecto

**Duracion**: ~1.5 segundos

**Diseno del patron:**

Secuencia ascendente de taps que simula fuegos artificiales hapticos.

```
Tiempo (s):  0.0  0.1  0.2  0.4  0.6  0.8  1.0  1.2  1.5
             |    |    |    |    |    |    |    |    |
Event:       T    T    T    |---continuous---|    T
Intensity:   0.3  0.5  0.7  0.9              0.4  1.0
Sharpness:   0.3  0.5  0.7  0.3              0.2  0.9
```

**Composicion:**
- Tres transients ascendentes como "build-up".
- Un continuo de intensidad alta por ~0.6s como "climax".
- Un transient final fuerte como "boom" final.
- Se sincroniza con las `ParticlesView` del `ResultView`.

### 3.6 Feedback de Motivacion (Score < 100%)

**Duracion**: ~0.4 segundos

**Diseno del patron:**

Un tap suave seguido de un tap medio -- alentador, no castigador.

```
Tiempo (s):  0.0   0.15  0.3
             |     |     |
Event:       TAP         TAP
Intensity:   0.3         0.5
Sharpness:   0.2         0.4
```

---

## 4. Snippets de Codigo

### 4.1 HapticManager - Estructura Base

```swift
import CoreHaptics
import SwiftUI

@MainActor
final class HapticManager: ObservableObject {

    private var engine: CHHapticEngine?
    private var engineNeedsStart = true

    @Published private(set) var supportsHaptics: Bool = false

    init() {
        supportsHaptics = CHHapticEngine.capabilitiesForHardware().supportsHaptics
        if supportsHaptics {
            prepareEngine()
        }
    }

    // MARK: - Engine Lifecycle

    private func prepareEngine() {
        guard supportsHaptics else { return }

        do {
            engine = try CHHapticEngine()
            engine?.playsHapticsOnly = true
            engine?.isAutoShutdownEnabled = true

            engine?.stoppedHandler = { [weak self] reason in
                Task { @MainActor in
                    self?.engineNeedsStart = true
                }
            }

            engine?.resetHandler = { [weak self] in
                Task { @MainActor in
                    do {
                        try self?.engine?.start()
                        self?.engineNeedsStart = false
                    } catch {
                        self?.engineNeedsStart = true
                    }
                }
            }
        } catch {
            supportsHaptics = false
        }
    }

    private func startEngineIfNeeded() throws {
        guard supportsHaptics, let engine = engine else { return }
        if engineNeedsStart {
            try engine.start()
            engineNeedsStart = false
        }
    }

    func stopEngine() {
        engine?.stop(completionHandler: { _ in })
        engineNeedsStart = true
    }
}
```

### 4.2 Patron de Sismo para Splash

```swift
// MARK: - Earthquake Splash Pattern

extension HapticManager {

    func playEarthquakeSplash() {
        guard supportsHaptics else { return }

        do {
            try startEngineIfNeeded()

            // P-wave: gentle continuous rumble (0.0 - 0.8s)
            let pWave = CHHapticEvent(
                eventType: .hapticContinuous,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.3),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.15)
                ],
                relativeTime: 0,
                duration: 0.8
            )

            // S-wave: intense continuous shaking (0.8 - 1.8s)
            let sWave = CHHapticEvent(
                eventType: .hapticContinuous,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.9),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.6)
                ],
                relativeTime: 0.8,
                duration: 1.0
            )

            // S-wave transient "jolts" for realism
            let jolt1 = CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.8)
                ],
                relativeTime: 0.9
            )
            let jolt2 = CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.9),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.7)
                ],
                relativeTime: 1.2
            )
            let jolt3 = CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.7),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
                ],
                relativeTime: 1.5
            )

            // Decay phase continuous (1.8 - 2.2s)
            let decay = CHHapticEvent(
                eventType: .hapticContinuous,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.4),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.2)
                ],
                relativeTime: 1.8,
                duration: 0.4
            )

            // Intensity curve: ramps up during P-wave, peaks at S-wave, decays
            let intensityCurve = CHHapticParameterCurve(
                parameterID: .hapticIntensityControl,
                controlPoints: [
                    .init(relativeTime: 0.0, value: 0.4),
                    .init(relativeTime: 0.4, value: 0.6),
                    .init(relativeTime: 0.8, value: 1.0),
                    .init(relativeTime: 1.3, value: 1.0),
                    .init(relativeTime: 1.8, value: 0.5),
                    .init(relativeTime: 2.2, value: 0.0)
                ],
                relativeTime: 0
            )

            // Sharpness curve: low during P-wave, high during S-wave
            let sharpnessCurve = CHHapticParameterCurve(
                parameterID: .hapticSharpnessControl,
                controlPoints: [
                    .init(relativeTime: 0.0, value: 0.2),
                    .init(relativeTime: 0.8, value: 0.8),
                    .init(relativeTime: 1.3, value: 0.7),
                    .init(relativeTime: 2.2, value: 0.0)
                ],
                relativeTime: 0
            )

            let pattern = try CHHapticPattern(
                events: [pWave, sWave, jolt1, jolt2, jolt3, decay],
                parameterCurves: [intensityCurve, sharpnessCurve]
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
```

### 4.3 Patrones de Feedback (Correcto/Incorrecto)

```swift
// MARK: - Answer Feedback Patterns

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
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.7)
                ],
                relativeTime: 0.15
            )

            let pattern = try CHHapticPattern(events: [tap1, tap2], parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: CHHapticTimeImmediate)

        } catch {
            #if DEBUG
            print("[HapticManager] Correct answer haptic error: \(error)")
            #endif
        }
    }

    func playWrongAnswer() {
        guard supportsHaptics else { return }

        do {
            try startEngineIfNeeded()

            let events = (0..<3).map { index in
                CHHapticEvent(
                    eventType: .hapticTransient,
                    parameters: [
                        CHHapticEventParameter(
                            parameterID: .hapticIntensity,
                            value: Float(0.8 - Double(index) * 0.25)
                        ),
                        CHHapticEventParameter(
                            parameterID: .hapticSharpness,
                            value: Float(0.9 - Double(index) * 0.2)
                        )
                    ],
                    relativeTime: Double(index) * 0.1
                )
            }

            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: CHHapticTimeImmediate)

        } catch {
            #if DEBUG
            print("[HapticManager] Wrong answer haptic error: \(error)")
            #endif
        }
    }
}
```

### 4.4 Patrones de Resultado

```swift
// MARK: - Result Patterns

extension HapticManager {

    func playPerfectScore() {
        guard supportsHaptics else { return }

        do {
            try startEngineIfNeeded()

            // Ascending build-up taps
            let buildUp1 = CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.3),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.3)
                ],
                relativeTime: 0
            )
            let buildUp2 = CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.5),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
                ],
                relativeTime: 0.1
            )
            let buildUp3 = CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.7),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.7)
                ],
                relativeTime: 0.2
            )

            // Climax continuous buzz
            let climax = CHHapticEvent(
                eventType: .hapticContinuous,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.9),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.3)
                ],
                relativeTime: 0.4,
                duration: 0.6
            )

            // Final strong tap
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
            print("[HapticManager] Perfect score haptic error: \(error)")
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
            print("[HapticManager] Encouragement haptic error: \(error)")
            #endif
        }
    }
}
```

### 4.5 Patron de Simulacion de Sismo (Fondo)

```swift
// MARK: - Simulation Background Earthquake

extension HapticManager {

    func playEarthquakeSimulation() {
        guard supportsHaptics else { return }

        do {
            try startEngineIfNeeded()

            // Subtle continuous background rumble
            let rumble = CHHapticEvent(
                eventType: .hapticContinuous,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.35),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.2)
                ],
                relativeTime: 0,
                duration: 4.0
            )

            // Sparse aftershock transients
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

            // Envelope curve: gradual ramp up, sustain, gradual decay
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
```

---

## 5. Puntos de Integracion con Vistas Existentes

### 5.1 MyApp.swift

**Cambio:** Crear `HapticManager` como `@StateObject` e inyectarlo al environment.

```swift
import SwiftUI

@main
struct MyApp: App {
    @StateObject private var gameState = GameState()
    @StateObject private var hapticManager = HapticManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(gameState)
                .environmentObject(hapticManager)
                .preferredColorScheme(.dark)
        }
    }
}
```

### 5.2 SplashView.swift

**Punto de integracion:** Dentro de `startAnimationSequence()`, sincronizado con el inicio de
la animacion del sismografo y el `ShakeEffect`.

```swift
struct SplashView: View {
    @EnvironmentObject var gameState: GameState
    @EnvironmentObject var hapticManager: HapticManager
    // ... existing @State vars ...

    private func startAnimationSequence() {
        startSeismograph()

        // Trigger haptic earthquake synchronized with visual shake
        hapticManager.playEarthquakeSplash()

        withAnimation(.easeInOut(duration: 0.8)) {
            shakeAmount = 6
            isShaking = true
        }
        // ... rest of existing animation sequence ...
    }
}
```

**Momento exacto:** Al inicio de `startAnimationSequence()`, junto con `startSeismograph()`.
El patron haptico de 2.2s esta disenado para coincidir con el periodo de `isShaking = true`
(0.0s a 2.2s).

### 5.3 SimulationView.swift

**Puntos de integracion:**

1. **Al mostrar cada escenario nuevo** - disparar sismo de fondo:

```swift
// In the scenario display area, when currentIndex changes:
.onChange(of: currentIndex) { _ in
    hapticManager.playEarthquakeSimulation()
}
// Also on first appear:
.onAppear {
    hapticManager.playEarthquakeSimulation()
}
```

2. **Al seleccionar una respuesta** - dentro del `Button(action:)` de `optionButton`:

```swift
private func optionButton(_ option: SimulationOption, scenario: SimulationScenario) -> some View {
    Button(action: {
        guard selectedOption == nil else { return }
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            selectedOption = option
            showExplanation = true
            gameState.answerScenario(scenario, correct: option.isCorrect)
        }

        // Haptic feedback based on answer correctness
        if option.isCorrect {
            hapticManager.playCorrectAnswer()
        } else {
            hapticManager.playWrongAnswer()
            // existing visual shake animation...
        }
    }) {
        // ... existing button content ...
    }
}
```

### 5.4 ResultView.swift

**Punto de integracion:** Dentro de `startAnimationSequence()`, sincronizado con la aparicion
del score.

```swift
private func startAnimationSequence() {
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) { showScore = true }

        // Haptic feedback based on score
        if gameState.scorePercentage == 100 {
            hapticManager.playPerfectScore()
        } else {
            hapticManager.playEncouragement()
        }
    }
    // ... rest of existing animation sequence ...
}
```

**Momento exacto:** Al mismo tiempo que `showScore = true` (0.3s despues de onAppear).
Si el score es 100%, se reproduce el patron de celebracion que coincide con las `ParticlesView`.

### 5.5 Limpieza de Recursos

En `SplashView.onDisappear` ya se limpia el timer del sismografo. No es necesario detener el
engine manualmente ya que `isAutoShutdownEnabled = true` se encarga de liberar recursos.

Sin embargo, si se desea ser explicito, se puede agregar en `ContentView`:

```swift
.onDisappear {
    hapticManager.stopEngine()
}
```

---

## 6. Compatibilidad con App Playground (.swiftpm)

### CoreHaptics en App Playground

**Confirmado:** CoreHaptics es un framework del sistema que se importa directamente con
`import CoreHaptics`. No requiere dependencias externas, SPM packages, ni entitlements
especiales. Funciona en el formato `.swiftpm` sin problemas.

### Sin archivos .ahap necesarios

Los archivos AHAP (Apple Haptic and Audio Pattern) son archivos JSON que definen patrones
hapticos. Son utiles para diseno iterativo pero **no son necesarios** para nuestra
implementacion. Todos los patrones se definen programaticamente en codigo, lo cual es:

- Mas adecuado para App Playground (menos archivos que manejar)
- Mas facil de sincronizar con animaciones (los tiempos estan en el codigo)
- Mas facil de mantener (todo en un solo archivo)
- No impacta el limite de 25 MB del ZIP

### Verificacion de Capacidades en iPad

El Swift Student Challenge se evalua en iPad. Los iPad con chip M1 o posterior soportan
CoreHaptics a traves del Taptic Engine. iPads mas antiguos no tienen Taptic Engine.

**Mitigacion obligatoria:** Toda llamada a patrones hapticos esta protegida por:

```swift
guard supportsHaptics else { return }
```

Esto asegura que la app funciona perfectamente en iPads sin soporte haptico. La experiencia
visual permanece intacta; los hapticos son una mejora, no un requisito.

### Swift 6 Strict Concurrency

`CHHapticEngine` no conforma `Sendable`. La solucion es:

1. `HapticManager` es `@MainActor` -- todas las operaciones del engine ocurren en main thread.
2. Los handlers (`stoppedHandler`, `resetHandler`) usan `Task { @MainActor in ... }` para
   regresar al main actor.
3. No se pasa el engine entre actores ni se usa en contextos concurrentes.

Esto cumple con Swift 6 strict concurrency sin necesidad de `@unchecked Sendable`.

### Package.swift

No se requieren cambios en `Package.swift`. CoreHaptics es un framework del sistema incluido
en iOS y no necesita declararse como dependencia.

---

## 7. Esfuerzo Estimado

### Desglose por Tarea

| Tarea | Tiempo Estimado | Complejidad |
|-------|----------------|-------------|
| Crear `HapticManager.swift` (estructura base + lifecycle) | 30 min | Media |
| Implementar patron de sismo splash | 45 min | Alta |
| Implementar patrones de feedback (correcto/incorrecto) | 20 min | Baja |
| Implementar patron de simulacion de fondo | 30 min | Media |
| Implementar patrones de resultado | 20 min | Baja |
| Integrar con `MyApp.swift` | 5 min | Baja |
| Integrar con `SplashView.swift` | 15 min | Baja |
| Integrar con `SimulationView.swift` | 20 min | Baja |
| Integrar con `ResultView.swift` | 15 min | Baja |
| Pruebas en dispositivo fisico | 45 min | Media |
| Ajuste fino de intensidades y tiempos | 30 min | Media |
| Unit tests para `HapticManager` | 30 min | Media |

### Total Estimado: ~5 horas

**Nota:** El ajuste fino de patrones hapticos requiere pruebas en dispositivo fisico real.
El Simulator de Xcode no reproduce hapticos. Se recomienda tener un iPhone 8 o posterior
disponible para pruebas.

---

## 8. Problemas Potenciales y Mitigaciones

### 8.1 Dispositivo sin Taptic Engine

**Problema:** iPads antiguos y el Simulator no soportan CoreHaptics.

**Mitigacion:**
- `CHHapticEngine.capabilitiesForHardware().supportsHaptics` se verifica en `init()`.
- Todas las funciones publicas comienzan con `guard supportsHaptics else { return }`.
- La app funciona identicamente sin hapticos; son puramente aditivos.

### 8.2 Engine se Detiene Inesperadamente

**Problema:** iOS puede detener el engine por restricciones de recursos, audio interruptions,
o background mode.

**Mitigacion:**
- `stoppedHandler` marca `engineNeedsStart = true`.
- `resetHandler` reinicia el engine automaticamente.
- `startEngineIfNeeded()` se llama antes de cada patron, re-creando el engine si es necesario.

### 8.3 Latencia al Iniciar el Engine

**Problema:** La primera vez que se inicia `CHHapticEngine` puede haber una latencia de
~50-100ms.

**Mitigacion:**
- `playsHapticsOnly = true` reduce la latencia (no necesita preparar audio pipeline).
- El engine se prepara en `init()` del `HapticManager`, que ocurre al iniciar la app.
- Para cuando el usuario llega al `SplashView`, el engine ya esta listo.

### 8.4 Conflicto con Animaciones Visuales

**Problema:** Si los hapticos no estan sincronizados con las animaciones visuales, la
experiencia se siente desconectada.

**Mitigacion:**
- Los tiempos de los patrones hapticos estan calculados para coincidir exactamente con los
  `DispatchQueue.main.asyncAfter` existentes en cada vista.
- El patron del splash (2.2s) coincide con el periodo `isShaking = true` (0.0s - 2.2s).
- El feedback de respuesta es instantaneo (transient events at relativeTime: 0).

### 8.5 Swift 6 Concurrency Warnings

**Problema:** `CHHapticEngine` handlers son closures que capturan `self` y se ejecutan en
threads arbitrarios.

**Mitigacion:**
- `HapticManager` es `@MainActor`.
- Los handlers usan `Task { @MainActor in ... }` para regresar al main thread.
- `weak self` en closures previene retain cycles.
- Se evitan propiedades `Sendable` que crucen boundaries de actores.

### 8.6 Impacto en Bateria

**Problema:** Vibraciones constantes pueden drenar bateria.

**Mitigacion:**
- Los patrones son cortos (0.3s - 4s maximo).
- `isAutoShutdownEnabled = true` libera recursos cuando no se usan.
- No hay hapticos continuos en loop; cada patron se ejecuta una vez.
- La fase de `LearnView` no tiene hapticos, permitiendo descanso al motor.

### 8.7 Experiencia en iPad para Evaluacion

**Problema:** Los jueces del Swift Student Challenge evaluan en iPad. No todos los iPads
tienen Taptic Engine.

**Mitigacion:**
- La app no depende de hapticos para funcionalidad core.
- Si el juez tiene un iPad con soporte, es un "wow factor" adicional.
- Si no tiene soporte, la experiencia visual completa sigue funcionando.
- Se puede agregar un indicador visual sutil (por ejemplo, un icono de vibracion en
  el SplashView) que aparezca solo si `supportsHaptics` es true, demostrando que la
  feature existe incluso si el evaluador no puede sentirla.

### 8.8 Pruebas Unitarias sin Dispositivo Fisico

**Problema:** No se pueden probar hapticos reales en unit tests.

**Mitigacion:**
- Se puede verificar que `HapticManager` se inicializa correctamente.
- Se puede probar la logica de `supportsHaptics` flag.
- Se pueden mockear las llamadas verificando que no arrojan excepciones.
- Las pruebas de patron real requieren dispositivo fisico.

---

## 9. Checklist de Implementacion

- [ ] Crear archivo `HapticManager.swift`
- [ ] Implementar init, prepareEngine, startEngineIfNeeded, stopEngine
- [ ] Implementar playEarthquakeSplash()
- [ ] Implementar playEarthquakeSimulation()
- [ ] Implementar playCorrectAnswer()
- [ ] Implementar playWrongAnswer()
- [ ] Implementar playPerfectScore()
- [ ] Implementar playEncouragement()
- [ ] Modificar MyApp.swift: agregar @StateObject hapticManager
- [ ] Modificar SplashView.swift: integrar haptico en startAnimationSequence
- [ ] Modificar SimulationView.swift: integrar haptico en optionButton y onAppear
- [ ] Modificar ResultView.swift: integrar haptico en startAnimationSequence
- [ ] Agregar @EnvironmentObject var hapticManager a SplashView, SimulationView, ResultView
- [ ] Verificar compilacion con Swift 6 strict concurrency (sin warnings)
- [ ] Crear unit tests para HapticManager
- [ ] Probar en dispositivo fisico (iPhone 8 o posterior)
- [ ] Ajustar intensidades y tiempos basandose en pruebas fisicas
- [ ] Verificar que la app funciona correctamente en iPad sin Taptic Engine
- [ ] Verificar que no hay memory leaks con el engine lifecycle
- [ ] Ejecutar flutter analyze (N/A - proyecto Swift puro)
- [ ] Verificar que no hay textos hardcodeados nuevos

---

## 10. Referencias

### Documentacion de Apple
- [Core Haptics Framework](https://developer.apple.com/documentation/corehaptics/)
- [CHHapticEngine](https://developer.apple.com/documentation/corehaptics/chhapticengine)
- [Updating Continuous and Transient Haptic Parameters in Real Time](https://developer.apple.com/documentation/CoreHaptics/updating-continuous-and-transient-haptic-parameters-in-real-time)
- [Introducing Core Haptics - WWDC19](https://developer.apple.com/videos/play/wwdc2019/520/)

### Tutoriales y Guias
- [Hacking with Swift - How to play custom vibrations using Core Haptics](https://www.hackingwithswift.com/example-code/core-haptics/how-to-play-custom-vibrations-using-core-haptics)
- [Hacking with Swift - How to modify haptic events over time using CHHapticParameterCurve](https://www.hackingwithswift.com/example-code/core-haptics/how-to-modify-haptic-events-over-time-using-chhapticparametercurve)
- [Kodeco - Getting Started With Core Haptics](https://www.kodeco.com/10608020-getting-started-with-core-haptics)
- [Donny Wals - Adding haptic feedback to your app with CoreHaptics](https://www.donnywals.com/adding-haptics-to-your-app/)
- [Developer Guide about Haptics on Apple Platforms](https://blog.eidinger.info/haptics-on-apple-platforms)

### Swift Student Challenge 2026
- [Swift Student Challenge - Get Ready](https://developer.apple.com/swift-student-challenge/get-ready/)
- [Eligibility and Requirements](https://developer.apple.com/swift-student-challenge/eligibility/)

### Sismologia (para diseno de patrones)
- [USGS - Earthquake Waves](https://earthquake.usgs.gov/earthquakes/events/1906calif/18april/earthwaves.php)
- [Pacific Northwest Seismic Network - Earthquake Waves](https://pnsn.org/education/seismology/earthquake-waves)
- [Cal OES - What Are P-Waves and S-Waves?](https://www.news.caloes.ca.gov/what-are-p-waves-and-s-waves/)
