# Issues V4 - Runtime Errors on Device

## 1. Black Screen on Launch
- Posible causa: SpeechManager pre-warm (`synthesizer.speak()` en init)
  activa AVAudioSession durante inicialización, conflicto con SoundManager
- Fix: Remover pre-warm, usar lazy initialization

## 2. Audio Thread Breakpoint (AURemoteIO::IOThread)
- Xcode "All Exceptions" breakpoint captura excepciones internas del audio engine
- Estas excepciones son NORMALES y manejadas internamente por AVAudioEngine
- Fix usuario: En Xcode → Breakpoint Navigator (Cmd+8) → eliminar "All Exceptions"
- Fix código: No necesario, es configuración de Xcode

## 3. CoreMotion.plist Permission Error
- Warning: "com.apple.CoreMotion.plist couldn't be opened - permission denied"
- Es un warning del SISTEMA, no de la app
- Ocurre normalmente en dispositivos reales cuando CoreMotion inicializa
- No afecta funcionalidad del acelerómetro
- Fix: Ninguno necesario

## 4. UnsafeMutablePointer Warnings en SoundManager
- Warnings de Swift 6: "Capture of non-Sendable type in @Sendable closure"
- Son inherentes al diseño de audio en tiempo real con raw pointers
- No son errores, no causan crashes
- Fix: Agregar @preconcurrency o suprimir si es posible
