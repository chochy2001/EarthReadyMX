# Plan: Correcciones V2

## Fix 1: Package.swift Warning (TRIVIAL)
**Archivo**: Package.swift, línea 46
**Cambio**: `swiftLanguageVersions: [.version("6")]` → `swiftLanguageModes: [.v6]`

## Fix 2: Idioma Español → Inglés (CRÍTICO SSC)
**Archivos**: DrillView.swift, SpeechManager.swift

### DrillView.swift - 12 strings de DrillPhase.instruction
- L65: "Simulacro de sismo..." → "Earthquake drill. Prepare your body and mind. Identify the nearest safe spot."
- L67: "Alerta sísmica activada..." → "Seismic alert activated. You have seconds to act. Move to the nearest safe spot."
- L69: "Agáchate..." → "Drop. Get on your knees to avoid falling during the earthquake."
- L71: "Cúbrete..." → "Cover. Protect your head and neck. Get under a sturdy table."
- L73: "Sujétate..." → "Hold on. Grip the table firmly. Do not let go."
- L75: "El movimiento ha cesado..." → "The shaking has stopped. Stay calm. Do not stand up yet."
- L77: "Revisa si hay peligros..." → "Check for hazards. Look for gas leaks, downed wires, and structural damage."
- L79: "Evacúa con calma..." → "Evacuate calmly using the safest route. Do not use elevators. Help others if you can."
- L81: "Dirígete al punto..." → "Head to the rally point. Confirm everyone is present and safe."
- L83: "Simulacro completado..." → "Drill completed successfully. Remember to practice regularly."
- L88: holdOnSecondInstruction → "Hold your position. The earthquake continues. Protect your head."
- L92: holdOnThirdInstruction → "Keep holding on. It will be over soon."

### DrillView.swift - UI Labels en español
Buscar y traducir TODOS los textos de UI que estén en español:
- Títulos de fase (si están en español)
- Botones
- Textos descriptivos

### SpeechManager.swift
- L19: default `language: "es-MX"` → `language: "en-US"`

## Fix 3: KitBuilder Layout y Drop (FUNCIONALIDAD ROTA)
**Archivo**: KitBuilderView.swift

### Problema raíz: Coordinate space mismatch
- Items dentro de ScrollView usan coordenadas `.global`
- bagFrame capturado en `.global` pero no se actualiza con scroll
- Resultado: solo items cerca del bottom del grid logran drop

### Solución: Layout dividido (items arriba scrollable, bag abajo fijo)
1. Cambiar layout a VStack con dos secciones:
   - TOP: ScrollView con LazyVGrid de items (scrollable)
   - BOTTOM: BackpackDropTarget FUERA del ScrollView (siempre visible)
2. Usar coordinateSpace nombrado en el ZStack/VStack padre
3. bagFrame se captura una vez y no cambia (está fuera del scroll)
4. DragGesture sigue usando .global - ahora coordenadas coinciden

### Cambios específicos:
- Mover BackpackDropTarget fuera del ScrollView
- El bag queda fijo en la parte inferior (siempre visible)
- Items scroll independientemente arriba
- Reducir tamaño del bag para que quepa bien
- Actualizar bagFrame con .onChange de geometry (por rotación)

## Fix 4: Navegación - Back Buttons (UX CRÍTICO)
**Archivos**: KitBuilderView.swift, DrillView.swift

### KitBuilderView.swift
- Agregar botón "Back" (chevron.left) en la esquina superior izquierda
- Acción: `gameState.currentPhase = .result`
- Solo visible cuando showResults == false y showIntro == false (durante gameplay)

### DrillView.swift
- Agregar botón "Back" ANTES de que inicie el drill (en el countdown/briefing)
- Durante el drill activo: el "Stop Drill" ya existe y muestra back options
- En drill complete: ya tiene "Continue to Checklist"

## Fix 5: Haptic en StatBadge (MEJORA UX)
**Archivo**: SplashView.swift

### StatBadge
- Agregar `@EnvironmentObject var hapticManager: HapticManager`
- En Button action: agregar `hapticManager.playEncouragement()` antes del toggle
- Esto da feedback tactil sutil al tocar las estadísticas (12K+, 3min, 70%)
