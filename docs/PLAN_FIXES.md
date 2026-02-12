# Plan: Code Fixes and Documentation

## 1. Hardcoded Dimensions

### SplashView.swift - generateCracks()
- Agregar `@State private var viewSize: CGSize = .zero`
- Wrap body en GeometryReader para capturar size
- Usar `viewSize.width`/`viewSize.height` en vez de 400/800
- Fallback: `max(viewSize.width, 300)` y `max(viewSize.height, 600)`

### ResultView.swift - ParticlesView
- Agregar GeometryReader en ParticlesView
- Usar `geometry.size.width` en vez de hardcoded 400

## 2. Share Button (ResultView.swift)
- Reemplazar texto estatico con ShareLink funcional
- Compartir texto: "Learn earthquake safety with EarthReady..."

## 3. Timeout UX (SimulationView.swift)
- Agregar `@State private var timedOut = false`
- Modificar handleTimeout(): no setear selectedOption, setear timedOut=true
- Actualizar optionCircleColor/optionTextColor/optionBackground/optionBorderColor para timedOut
- Mostrar "Time's Up!" banner en explanationCard
- Deshabilitar botones cuando timedOut
- Reset timedOut en continueButton

## 4. Code Documentation
- SoundManager: documentar OscillatorBank raw pointers, Timer+Task pattern
- HapticManager: documentar patrones sismologicos P-wave/S-wave
- ShakeEffect: documentar dual-axis shake
- SimulationView: documentar Timer architecture
