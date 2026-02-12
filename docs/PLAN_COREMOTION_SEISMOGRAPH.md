# Plan: Sismógrafo Interactivo con CoreMotion

## Objetivo
Integrar el acelerómetro del dispositivo con el SeismographView existente para que
responda a movimiento real del dispositivo. Los jueces del SSC valoran uso creativo del hardware.

## Investigación Clave

### API
- Usar `CMDeviceMotion.userAcceleration` (gravedad ya removida por sensor fusion)
- Sampling rate: 50 Hz (`deviceMotionUpdateInterval = 1.0/50.0`)
- **NO requiere permiso del usuario** para acelerómetro básico
- Opcional: `NSMotionUsageDescription` en SupportingInfo.plist como precaución

### Swift 6
- `@preconcurrency import CoreMotion` para suprimir warnings de Sendable
- `CMMotionManager` NO es Sendable - mantener aislado en @MainActor
- Usar `.main` queue para updates (callback ya en MainActor)
- Patrón similar a SoundManager existente

### Compatibilidad
- CoreMotion funciona en Swift Playgrounds en iPad (confirmado)
- NO funciona en Simulator - fallback obligatorio con datos sintéticos
- Sin impacto en bundle size (framework del sistema)
- iPads tienen acelerómetro estándar

### Filtrado
- Low-pass filter (alpha ~0.3) para suavizar datos del sensor
- Magnitud: `sqrt(x² + y² + z²)` para señal escalar
- Normalizar a rango -1...1 (dividir entre ~2.0g, clamp)
- Dead zone: ignorar aceleración < 0.02g

## Archivos Nuevos

### MotionManager.swift
```
@MainActor final class MotionManager: ObservableObject
  - private let motionManager = CMMotionManager()
  - @Published var filteredMagnitude: CGFloat = 0
  - @Published var isMotionAvailable: Bool
  - private var lowPassValue: Double = 0
  - private let filterAlpha: Double = 0.3
  - func startUpdates()
  - func stopUpdates()
  - private func processMotion(_ motion: CMDeviceMotion)
```

## Archivos a Modificar

### MyApp.swift
- Agregar `@StateObject private var motionManager = MotionManager()`
- Pasar como `.environmentObject(motionManager)`

### SplashView.swift
- Agregar `@EnvironmentObject var motionManager: MotionManager`
- Modificar `startSeismograph()`:
  - Si `motionManager.isMotionAvailable`: usar datos reales del acelerómetro
  - Si no: mantener datos sintéticos actuales (fallback para simulator)
- Lifecycle: `onAppear` → `motionManager.startUpdates()`, `onDisappear` → `motionManager.stopUpdates()`

### SupportingInfo.plist (opcional)
- Agregar `NSMotionUsageDescription` como precaución

## Pipeline de Datos
```
CMDeviceMotion.userAcceleration (x, y, z)
  → magnitud: sqrt(x²+y²+z²)
  → low-pass filter (alpha=0.3)
  → normalizar a -1...1
  → @Published filteredMagnitude
  → SplashView lee valor, appends a seismographPoints[]
  → SeismographView renderiza (código existente, sin cambios)
```

## Consideraciones
- UNA sola instancia de CMMotionManager por app (regla de Apple)
- SIEMPRE llamar stopUpdates() en onDisappear
- Respetar accessibilityReduceMotion: usar datos sintéticos calmados
- Solo activar CoreMotion en fases que muestran sismógrafo
