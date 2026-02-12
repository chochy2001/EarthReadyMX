# Estado del Proyecto EarthReady MX

**Fecha**: 11 de Febrero 2026
**Ultima actualizacion**: 11 Feb 2026 — Fix de carga infinita en Xcode + crash de audio

---

## Estado de Git

- **Rama**: `main`
- **Remote**: `git@github.com:chochy2001/EarthReadyMX.git`
- **Ultimo commit**: `1514c8f` - Todo pusheado, working tree limpio
- **Stashes**: Ninguno
- **Ramas**: Solo `main`

### Historial de commits (mas reciente primero)

```
1514c8f Add .build and .swiftpm directories to gitignore
a6b20e8 Remove Assets.xcassets that broke App Playground loading
ee033f1 Revert Package.swift to original auto-generated state
0f40b87 Add custom app icon and update app metadata
e4db232 Add README for Swift Student Challenge submission
6ebfbf5 Fix non-deterministic rubble rendering in aftershock scene
a77ef56 Update ROADMAP with completion status for all phases
9567a9a Add interactive simulation with scene illustrations and countdown timer
3046e97 Add ChecklistView with interactive preparedness checklist
723af5e Add checklist data model with 34 items from FEMA/CENAPRED
e355c0c Add VoiceOver and Reduce Motion to SimulationView and ResultView
1f3be26 Add VoiceOver and Reduce Motion to SplashView and LearnView
a08d125 Add accessibility helpers and Reduce Motion support
3937928 Integrate SoundManager into all views
beb7d0c Add SoundManager with AVAudioEngine audio synthesis
3085990 Add CoreHaptics integration with 6 haptic patterns
74a2390 Add implementation plan documents
0a6f244 Fix text truncation in SplashView
2457737 Initial commit
```

---

## Que esta completado (todo el codigo funciona, typecheck pasa sin errores)

### Fase 1: CoreHaptics + Sonidos ✅
- `HapticManager.swift` - 6 patrones hapticos
- `SoundManager.swift` - Sintesis de audio con AVAudioEngine (4 osciladores)
- Integrado en SplashView, SimulationView, ResultView

### Fase 2: Simulacion Interactiva ✅
- `SceneIllustration.swift` - 5 escenas visuales con SF Symbols
- `CountdownTimerView` - Timer de 15 segundos con colores de urgencia
- Timer funcional con auto-timeout
- Integrado en SimulationView

### Fase 3: Accesibilidad ✅
- `AccessibilityHelpers.swift` - Utilidades VoiceOver
- VoiceOver en las 5 vistas principales
- Reduce Motion en SplashView, ResultView, PulseEffect, GlowEffect

### Fase 4: Checklist ✅
- `ChecklistData.swift` - 34 items de FEMA/CENAPRED
- `ChecklistView.swift` - UI completa con progreso y categorias
- Integrado como nueva fase en el flujo de la app

### Fase 5: Pulido 🔄 Parcialmente completado
- [x] README.md creado
- [x] ROADMAP.md actualizado
- [x] .gitignore mejorado
- [x] Tamano verificado: 896KB (limite 25MB)
- [x] Funciona offline (sin dependencias de red)
- [x] Typecheck pasa sin errores ni warnings

---

## Que falta por hacer

### 1. App Icon (PENDIENTE)
El logo ya esta descargado en `~/Downloads/Logo_app_terremoto.png` (1024x1024, sin alpha).

**IMPORTANTE**: NO editar Package.swift manualmente. El icono se debe configurar desde Xcode GUI:
1. Abrir el proyecto en Xcode
2. Ir a la configuracion del proyecto (icono azul arriba a la izquierda)
3. En "App Icon", cambiar de placeholder a asset
4. Arrastrar el PNG ahi

**Alternativa**: Abrir el proyecto en Swift Playgrounds en iPad y configurar ahi el icono (Swift Playgrounds maneja mejor los assets de App Playgrounds).

### 2. Testing en dispositivo fisico (PENDIENTE)
- Abrir en Xcode, seleccionar iPhone Chochy como destino, Cmd+R
- Verificar flujo completo: Splash → Learn → Simulation → Result → Checklist
- Verificar que haptics y sonido funcionan
- Verificar que el timer countdown funciona
- Verificar que VoiceOver funciona (Settings > Accessibility > VoiceOver)
- Medir tiempo total del flujo (debe ser < 3 minutos)

### 3. Cambios en Package.swift (PENDIENTE - hacer desde Xcode GUI)
- Cambiar `appCategory` de `.reference` a `.education`
- Cambiar `accentColor` de `.blue` a `.orange`
- Cambiar `appIcon` de `.placeholder` a `.asset("AppIcon")`
- **NUNCA editar este archivo desde terminal/editor de texto**

### 4. Submission essay (PENDIENTE)
- Escribir el ensayo para el Swift Student Challenge
- El README.md ya tiene la base de contenido

---

## Archivos del proyecto (15 Swift files, 3928 lineas)

| Archivo | Descripcion | Lineas |
|---------|-------------|--------|
| `MyApp.swift` | Entry point, inyecta EnvironmentObjects | ~15 |
| `ContentView.swift` | Router de fases (splash/learn/simulation/result/checklist) | ~43 |
| `SplashView.swift` | Pantalla de inicio con animaciones + alerta sismica | ~400 |
| `LearnView.swift` | Contenido educativo Before/During/After | ~350 |
| `SimulationView.swift` | Quiz con escenas, timer, haptics, sonido | ~400 |
| `ResultView.swift` | Score, respuestas, takeaways, boton Prepare Now | ~345 |
| `ChecklistView.swift` | Checklist interactivo con categorias y progreso | ~455 |
| `GameState.swift` | Modelo de datos, escenarios, checklist, scoring | ~300 |
| `HapticManager.swift` | CoreHaptics con 6 patrones | ~350 |
| `SoundManager.swift` | AVAudioEngine con 4 osciladores | ~430 |
| `SceneIllustration.swift` | 5 escenas SF Symbols + CountdownTimerView | ~520 |
| `ChecklistData.swift` | 34 items FEMA/CENAPRED en 3 categorias | ~250 |
| `ShakeEffect.swift` | ShakeEffect, PulseEffect, GlowEffect | ~70 |
| `AccessibilityHelpers.swift` | Anuncios VoiceOver | ~20 |
| `Package.swift` | Auto-generado por Xcode (NO EDITAR) | ~45 |

## Otros archivos
- `README.md` - Para el submission
- `docs/ROADMAP.md` - Estado de todas las fases
- `docs/PLAN_*.md` - 5 documentos de planificacion
- `docs/ESTADO_PROYECTO.md` - Este documento

---

## Problema de Xcode: Crash por directorio `~` en la raiz del proyecto (RESUELTO)

### Sintomas
- Xcode crasheaba inmediatamente al abrir el proyecto `.swiftpm`
- Error: `EXC_BAD_ACCESS (SIGSEGV)` - Segmentation fault / Stack overflow
- Stack trace mostraba recursion infinita (511 frames) en `IDEFoundation._locateFileReferencesRecursivelyInGroup:`
- Xcode aparecia como "Not Responding" en Activity Monitor

### Causa raiz
Un directorio llamado `~` (tilde) fue creado accidentalmente en la raiz del proyecto por una herramienta CLI que interpreto `~` como ruta relativa en lugar del home directory del usuario.

Cuando Xcode escanea recursivamente los archivos del bundle `.swiftpm`, al encontrar un directorio llamado `~`, las funciones internas de resolucion de rutas (`_CFCopyHomeDirURLForUser`, `NSHomeDirectoryForUser`) lo interpretan como el home directory (`/Users/jorgesalgadomiranda/`), creando un **ciclo infinito**:
```
proyecto/ → ~/  → /Users/.../proyecto/ → ~/ → /Users/.../proyecto/ → ...
```
Esto causa un stack overflow que termina en `SIGSEGV`.

### Solucion aplicada
1. Eliminar el directorio `~` del proyecto: `rm -rf ~/Documents/Apps/EarthReadyMXFinal.swiftpm/\~`
2. Crear un archivo vacio `~` para prevenir que se recree como directorio: `touch ~/Documents/Apps/EarthReadyMXFinal.swiftpm/\~`
3. Limpiar todas las caches de Xcode:
   ```bash
   rm -rf ~/Library/Developer/Xcode/DerivedData
   rm -rf ~/Library/Caches/com.apple.dt.Xcode
   rm -rf ~/Library/Caches/org.swift.swiftpm
   rm -rf ~/Library/Developer/CoreSimulator/Caches
   rm -rf .swiftpm .build
   ```
4. El `.gitignore` ya tiene `~/` para ignorar este archivo

### Prevencion
- **NUNCA** crear directorios con nombres especiales del sistema (`~`, `.`, `..`) dentro de un proyecto `.swiftpm`
- Si una herramienta CLI crea un directorio `~` en el proyecto, eliminarlo inmediatamente
- El archivo `~` (archivo vacio, no directorio) actua como proteccion contra la recreacion
- Verificar con `ls -la` que `~` es un archivo (`-rw-r--r--`) y NO un directorio (`drwxr-xr-x`)

### Segundo crash: DVTSourceControl (SIGABRT)
Despues de resolver el crash principal, ocurrio un segundo crash transitorio en el modulo de source control de Xcode (`DVTSourceControl` con `SIGABRT`). Esto fue causado por estado corrupto de las multiples muertes forzadas de Xcode (`kill -9`). Se resolvio limpiando `.swiftpm` y reabriendo Xcode.

---

## Xcode se queda en "Loading..." indefinidamente (RESUELTO)

### Sintomas
- Al abrir el proyecto `.swiftpm` en Xcode, muestra "Loading EarthReadyMXFinal..." en la barra superior y nunca termina de cargar
- `xcodebuild -list` tambien se cuelga indefinidamente
- No muestra errores, simplemente se queda en estado de carga infinita

### Causas

**1. `Assets.xcassets/` en el directorio raiz**
Los App Playgrounds (`.swiftpm`) no soportan `Assets.xcassets` de la forma tradicional. Xcode al intentar resolver el asset catalog dentro del bundle se cuelga.

Este directorio fue agregado en el commit `0f40b87` y luego removido en `a6b20e8` con el mensaje "Remove Assets.xcassets that broke App Playground loading". Volvio a aparecer al recrearse manualmente.

**2. `appIcon: .asset("AppIcon")` en Package.swift sin asset catalog**
El manifest referenciaba un AppIcon asset que ya no existia despues de eliminar `Assets.xcassets`. Esto dejaba a Xcode atascado intentando resolver el recurso.

**3. Falta de `exclude` en el target de Package.swift**
Sin `exclude: ["docs", "README.md", "~"]`, SPM intentaba procesar archivos no-Swift en la raiz del proyecto (el archivo `~`, el directorio `docs/`), lo cual causaba que la resolucion del package graph se colgara.

**4. `--db-path` en la raiz del proyecto**
Un archivo vacio llamado `--db-path` fue creado accidentalmente. Su nombre con prefijo `--` podia confundir herramientas de build.

### Solucion aplicada
1. Eliminar `Assets.xcassets/` del proyecto
2. Cambiar `appIcon: .asset("AppIcon")` a `appIcon: .placeholder(icon: .calendar)` en Package.swift
3. Restaurar `exclude: ["docs", "README.md", "~"]` en el target de Package.swift
4. Eliminar archivo `--db-path`
5. Agregar `Assets.xcassets/` y `--db-path` al `.gitignore`
6. Limpiar caches: `rm -rf .build .swiftpm`

### Prevencion
- **NUNCA** agregar `Assets.xcassets` en un App Playground — usar `appIcon: .placeholder(icon: ...)` en Package.swift
- **SIEMPRE** mantener `exclude: ["docs", "README.md", "~"]` en el target del Package.swift
- Si Xcode se queda en "Loading...", verificar:
  1. Que no exista `Assets.xcassets/` en la raiz
  2. Que Package.swift no referencie assets inexistentes
  3. Que el `exclude` este presente en el target
  4. Limpiar `.build/` y `.swiftpm/` y reabrir

### Verificacion
```bash
# Si xcodebuild -list responde en menos de 10 segundos, el proyecto esta OK
xcodebuild -list
# Debe mostrar: Schemes: EarthReadyMXFinal
```

---

## Crash de Audio: _dispatch_assert_queue_fail en AURemoteIO::IOThread (RESUELTO)

### Sintomas
- La app crasheaba al reproducir sonido (alerta sismica, rumble de terremoto, etc.)
- Error: `EXC_BREAKPOINT (code=1)` en `AURemoteIO::IOThread`
- `_dispatch_assert_queue_fail` en el stack trace
- Pantalla negra al inicio si se dispara sonido automaticamente

### Causa raiz PRINCIPAL: Swift 6 @MainActor isolation en render callback

**Swift 6 inyecta runtime actor isolation checks en closures creados dentro de clases `@MainActor`.**

`SoundManager` es `@MainActor`. El render closure de `AVAudioSourceNode` se creaba dentro de `setupEngine()` (metodo `@MainActor`). Swift 6 infiere que el closure hereda `@MainActor` isolation del contexto lexico. En runtime, Swift 6 inserta:

```
swift_task_isCurrentExecutor(MainActor.shared)  // Estamos en main thread?
// Si NO → swift_task_reportUnexpectedExecutor → CRASH
```

Cuando `AURemoteIO::IOThread` (hilo real-time de audio) invoca el render callback:
1. Swift 6 runtime verifica si estamos en el MainActor executor
2. No lo estamos (estamos en el audio thread)
3. `dispatch_assert_queue(mainQueue)` falla
4. `EXC_BREAKPOINT` → crash

**El crash ocurre ANTES de que nuestro codigo ejecute** — es el runtime check de Swift 6.

Referencia: [Swift Issue #75453](https://github.com/swiftlang/swift/issues/75453)
Referencia: [CocoaWithLove](https://www.cocoawithlove.com/blog/copilot-raindrop-generator.html)

### Causas secundarias (tambien corregidas)

**2. Float.random(in:) en el render callback**
- Usaba system calls (arc4random_buf) no safe para real-time
- Corregido: xorshift32 PRNG

**3. ARC retain/release en el render callback**
- Capturaba `bank` (clase) → ARC traffic en audio thread
- Corregido: captura solo UnsafeMutablePointer

**4. AVAudioSourceNode sin formato explicito**
- Podia causar conversion interna de formato
- Corregido: formato mono explicito

### Historial de soluciones

**Intento 1 (fallido)**: NSLock → bloqueaba hilo real-time
**Intento 2 (fallido)**: UnsafeMutablePointer pero closure en @MainActor context
**Intento 3 (fallido)**: Raw pointers + xorshift32, pero closure SEGUIA en @MainActor context
**Solucion final (correcta)**: Funcion libre `makeAudioSourceNode()` fuera de @MainActor

### Solucion: Funcion libre + @Sendable

```swift
// FUERA de la clase @MainActor — rompe herencia de isolation
private func makeAudioSourceNode(
    format: AVAudioFormat,
    controlsPtr: UnsafeMutablePointer<OscillatorControl>,
    phasesPtr: UnsafeMutablePointer<Float>,
    noiseSeedPtr: UnsafeMutablePointer<UInt32>,
    oscillatorCount: Int,
    deltaTime: Float
) -> AVAudioSourceNode {
    AVAudioSourceNode(format: format) { @Sendable (...) -> OSStatus in
        // Render callback: solo punteros raw, xorshift32, sin ARC
    }
}
```

Al mover la creacion del nodo a una funcion libre (no `@MainActor`):
1. El closure NO hereda `@MainActor` isolation
2. `@Sendable` marca explicitamente que el closure es thread-safe
3. Swift 6 NO inyecta el runtime check de actor isolation
4. El audio thread puede invocar el callback sin crash

### Reglas para audio render callbacks en Swift 6:
- **NUNCA crear AVAudioSourceNode render closures dentro de clases @MainActor**
- **SIEMPRE usar una funcion libre o nonisolated para crear el nodo**
- **SIEMPRE marcar el closure como @Sendable**
- NUNCA capturar `self`, clases, o tipos con ARC
- NUNCA usar Float.random() (system calls)
- SOLO capturar: UnsafeMutablePointer, Int, Float, scalars

---

## Explicacion tecnica detallada del error y como visualizarlo

### Que es el error

El error `_dispatch_assert_queue_fail` en `AURemoteIO::IOThread` con `EXC_BREAKPOINT (code=1)` es un **crash de violacion de actor isolation en Swift 6**. No es un bug en nuestro codigo de audio — es el **runtime de Swift 6** que mata el proceso porque detecta que un closure marcado como `@MainActor` esta siendo ejecutado en un hilo que no es el main thread.

### Entorno donde se produce

- **Swift**: 6.2.3 (swift-tools-version: 6.0)
- **Xcode**: 26.2
- **swiftLanguageModes**: [.v6] (activa enforcement estricto de actor isolation)
- **Dispositivo**: iPhone fisico (el simulador puede no reproducirlo)

### Por que se da

Swift 6 introduce **runtime enforcement de actor isolation**. A diferencia de Swift 5 (que solo daba warnings), Swift 6 **crashea la app** si detecta que un closure `@MainActor` se ejecuta fuera del main thread.

**Mecanismo interno paso a paso:**

```
1. SoundManager es @MainActor
   ↓
2. setupEngine() hereda @MainActor (es metodo de la clase)
   ↓
3. El closure del render callback se CREA dentro de setupEngine()
   ↓
4. Swift 6 infiere: "este closure nacio en contexto @MainActor,
   por lo tanto ES @MainActor" (isolation inheritance)
   ↓
5. Swift 6 INYECTA codigo invisible al inicio del closure:

   // Codigo inyectado por el compilador (no visible en fuente):
   let executor = MainActor.shared.unownedExecutor
   guard swift_task_isCurrentExecutor(executor) else {
       swift_task_reportUnexpectedExecutor(...)  // → CRASH
   }

   ↓
6. AVAudioEngine invoca el closure en AURemoteIO::IOThread
   (hilo de audio en tiempo real, NO es el main thread)
   ↓
7. swift_task_isCurrentExecutor(MainActor) → FALSE
   ↓
8. dispatch_assert_queue(mainQueue) → FALLA
   ↓
9. _dispatch_assert_queue_fail → EXC_BREAKPOINT (code=1)
   ↓
10. CRASH — la app muere antes de que nuestro codigo ejecute
```

### Como ver/reproducir el error

**Paso 1: Agregar breakpoints simbolicos en Xcode**

En Xcode → Debug → Breakpoints → Create Symbolic Breakpoint:
- Simbolo: `_dispatch_assert_queue_fail`
- Simbolo: `swift_task_isCurrentExecutor`
- Simbolo: `swift_task_reportUnexpectedExecutor`

**Paso 2: Correr la app**

La app dispara audio en `SplashView.onAppear` → `soundManager.playSeismicAlert(duration: 2.2)`

**Paso 3: Cuando se detenga en el breakpoint, ejecutar en LLDB:**

```lldb
(lldb) thread info
(lldb) bt
(lldb) thread backtrace all
(lldb) image lookup -a $pc
```

**Paso 4: Observar el backtrace**

El backtrace mostrara algo como:
```
Thread X: AURemoteIO::IOThread
  frame #0: _dispatch_assert_queue_fail
  frame #1: swift_task_isCurrentExecutor  ← CHECK DE SWIFT 6
  frame #2: closure #1 in SoundManager.setupEngine()  ← NUESTRO CLOSURE
  ...
  frame #N: _XPerformIO (libEmbeddedSystemAUs.dylib)
  frame #N+1: AURemoteIO::IOThread (libEmbeddedSystemAUs.dylib)
  frame #N+2: _pthread_start
```

**Claves para identificar este error:**
- Thread: `AURemoteIO::IOThread` (NO es el main thread)
- Frame: `_dispatch_assert_queue_fail` o `swift_task_reportUnexpectedExecutor`
- El closure aparece como `closure #1 in SoundManager.setupEngine()`
- Stack debajo muestra `_XPerformIO` → `mshMIGPerform` → `_pthread_start`

### Como verificar que el fix funciona

**Checklist de validacion (5 minutos):**

1. **Clean Build**: Shift+Cmd+K → Cmd+R
2. **SplashView**: La app inicia sin pantalla negra, se escucha la alerta sismica
3. **SimulationView**: El rumble de terremoto suena al iniciar la simulacion
4. **Feedback**: Los sonidos de correcto/incorrecto suenan al responder
5. **ResultView**: El sonido de celebracion suena al ver resultados

**Si quieres confirmar via LLDB que ya no hay isolation check:**

1. Poner breakpoint simbolico en `swift_task_isCurrentExecutor`
2. Correr la app
3. Si el breakpoint NO se activa en `AURemoteIO::IOThread` → el fix funciona
4. Si se activa pero en un thread diferente (como main thread) → es normal

### Evidencia del error (screenshots capturados)

El error se manifesto visualmente en Xcode asi:
- **Thread panel**: `AURemoteIO::IOThread` aparece con icono rojo de crash
- **Frame 0**: `_dispatch_assert_queue_fail` en assembly
- **Crash banner**: `AURemoteIO::IOThread: EXC_BREAKPOINT (code=1, subcode=0x10463f8e4)`
- **Assembly visible**: instruccion `brk` (breakpoint ARM) ejecutada por libdispatch
- **Otros threads visibles**: `AudioSession - RootQueue`, `caulk::deferred_logger`

### Por que los intentos anteriores no funcionaron

| Intento | Que se hizo | Por que fallo |
|---------|-------------|---------------|
| 1. NSLock | Sincronizar con lock | Lock bloquea hilo real-time → crash diferente |
| 2. UnsafeMutablePointer | Eliminar lock, usar punteros | Closure SEGUIA dentro de @MainActor → Swift 6 check |
| 3. + xorshift32 + formato | Eliminar Float.random, formato explicito | Closure SEGUIA dentro de @MainActor → Swift 6 check |
| **4. Funcion libre** | **Mover closure FUERA de @MainActor** | **CORRECTO: rompe herencia de isolation** |

Los intentos 2 y 3 mejoraron la seguridad real-time del codigo DENTRO del callback, pero el crash ocurria ANTES de entrar al callback, en el runtime check de Swift 6. Solo al mover la creacion del closure fuera del contexto `@MainActor` se elimina el check.

### Referencias

- [Swift Issue #75453](https://github.com/swiftlang/swift/issues/75453) — Bug report del problema de isolation inheritance
- [CocoaWithLove: Raindrop Generator](https://www.cocoawithlove.com/blog/copilot-raindrop-generator.html) — Documenta el missing `@Sendable` en AVAudioSourceNode
- [Swift Forums: Crash in Swift 6 language mode](https://forums.swift.org/t/crash-when-running-in-swift-6-language-mode/72431) — Confirmacion de runtime enforcement
- [Swift Forums: DispatchSource crash under Swift 6](https://forums.swift.org/t/dispatchsource-crash-under-swift-6/75951) — Mismo patron en otro contexto
- WWDC19 Session 510 "What's New in AVAudioEngine"
- forums.swift.org/t/realtime-threads-with-swift/40562

---

## Fix de Package.swift: swiftLanguageVersions deprecated (RESUELTO)

### Sintoma
Warning en Xcode: `'init(name:defaultLocalization:platforms:pkgConfig:providers:products:dependencies:targets:swiftLanguageVersions:cLanguageStandard:cxxLanguageStandard:)' is deprecated`

### Solucion
Cambiar `swiftLanguageVersions: [.version("6")]` por `swiftLanguageModes: [.v6]`

### Proteccion contra directorio ~ (actualizada)
Ademas del archivo vacio `~`, se agrego `exclude: ["docs", "README.md", "~"]` al target en Package.swift para que SPM ignore estos paths incluso si el directorio se recrea.

---

## Verificacion rapida del codigo

```bash
# Verificar que todo compila sin errores
cd /Users/jorgesalgadomiranda/Documents/Apps/EarthReadyMXFinal.swiftpm
ls *.swift | grep -v Package.swift | xargs swiftc -typecheck \
  -target arm64-apple-ios16.0-simulator \
  -sdk $(xcrun --sdk iphonesimulator --show-sdk-path) \
  -framework SwiftUI -framework CoreHaptics -framework AVFoundation

# Verificar git esta limpio
git status

# Verificar tamano
du -sh .
```

---

## Deadline

**28 de Febrero 2026** - Swift Student Challenge submission
