# Plan: Emergency Kit Builder con DragGesture

## Objetivo
Mini-juego donde el usuario arrastra items esenciales a una mochila de emergencia virtual.
Enseña qué llevar en un kit de emergencia de forma interactiva. Basado en guías CENAPRED/FEMA.

## Investigación Clave

### DragGesture
- Usar `DragGesture(coordinateSpace: .global)` manual (NO `.draggable/.dropDestination`)
- Manual DragGesture da control total sobre animaciones, posición, snap-back
- `.draggable` es para transferencia entre apps (overkill para juego in-app)
- `GeometryReader` para detección de zona de drop (frame del bag)
- `matchedGeometryEffect` para transición suave item → bag

### Accesibilidad
- **Dual-mode**: DragGesture para usuarios videntes, tap-to-add para VoiceOver
- `.accessibilityAction(named: "Add to Kit")` como alternativa al drag
- Anuncios con `AccessibilityAnnouncement.announceScreenChange()`
- Respetar `reduceMotion` (opacity transitions en vez de spring)
- Respetar `differentiateWithoutColor` (badges de texto ESSENTIAL/WRONG)

### Items CENAPRED/FEMA
- 10 items correctos (esenciales para kit de emergencia)
- 6 items incorrectos (peligrosos post-sismo)
- 3 distractores (plausibles pero no prioritarios)
- Total: 19 items, mostrar 12-16 aleatorios por partida

## Archivos Nuevos

### KitBuilderData.swift
- Datos estáticos de items (patrón similar a ChecklistData.swift)
- `enum KitItemCategory: Sendable { essential, dangerous, distractor }`
- `struct KitItem: Identifiable, Sendable { id, icon, name, explanation, category, points }`
- `static func allItems() -> [KitItem]`

**Items Correctos (essential):**
| Item | SF Symbol | Puntos |
|------|-----------|--------|
| Agua embotellada | drop.fill | +15 |
| Comida no perecedera | fork.knife | +15 |
| Botiquín primeros auxilios | cross.case.fill | +15 |
| Linterna | flashlight.on.fill | +10 |
| Silbato de emergencia | speaker.wave.3.fill | +10 |
| Documentos importantes | doc.text.fill | +10 |
| Radio de baterías | radio.fill | +10 |
| Cargador portátil | battery.100.bolt | +10 |
| Efectivo (billetes chicos) | banknote.fill | +5 |
| Ropa abrigadora | tshirt.fill | +5 |

**Items Incorrectos (dangerous):**
| Item | SF Symbol | Puntos |
|------|-----------|--------|
| Velas | flame.fill | -10 |
| Botellas de vidrio | wineglass.fill | -10 |
| Libros pesados | books.vertical.fill | -5 |
| Laptop | laptopcomputer | -5 |
| Tacones altos | shoe.fill | -5 |
| Control de TV | tv.fill | -5 |

**Distractores:**
| Item | SF Symbol | Puntos |
|------|-----------|--------|
| Lentes de sol | sunglasses.fill | -2 |
| Cartas de juego | suit.spade.fill | -2 |
| Perfume | humidity.fill | -2 |

### KitBuilderView.swift
- Vista principal del juego
- `@EnvironmentObject var gameState, hapticManager, soundManager`
- `@State private var bagContents: Set<UUID> = []`
- `@State private var bagFrame: CGRect = .zero`
- `@State private var feedbackMessage: String?`
- `@State private var feedbackIsCorrect: Bool = true`
- `@Namespace private var kitNamespace`
- Layout: grid de items arriba, mochila abajo
- LazyVGrid con 3 columnas (iPhone) / 4 columnas (iPad)
- `.frame(maxWidth: 700)` para iPad
- Botón "Continue" al completar

**Sub-componentes dentro del archivo:**
- `DraggableKitItem` - Item arrastrable con snap-back
- `BackpackDropTarget` - Zona de drop con glow/escala
- `FeedbackToast` - Toast educativo (por qué correcto/incorrecto)

## Archivos a Modificar

### GameState.swift
- Agregar `case kitBuilder` a `AppPhase` enum
- Agregar `@Published var kitScore: Int = 0`
- Agregar `@Published var kitEssentialsFound: Int = 0`
- Agregar `func resetKitBuilder()`

### ContentView.swift
- Agregar case `.kitBuilder: KitBuilderView()` con transition

### ResultView.swift
- Agregar botón "Build Your Kit" que navega a `.kitBuilder`

## Flujo del Juego
1. **Intro (3s)**: Título + instrucciones breves
2. **Gameplay (sin timer)**: Arrastrar items, feedback inmediato
3. **Resultado**: Score + estrellas + resumen educativo + "Continue to Checklist"

## Scoring
- Items correctos en bag: +5 a +15 puntos según prioridad
- Items incorrectos en bag: -2 a -10 puntos según peligro
- 10/10 esenciales: +20 bonus
- Estrellas: 3★ (all correct, 0 wrong), 2★ (7+ correct), 1★ (4+ correct)

## Reutilizar del Codebase
- `ShakeEffect` → wrong drops
- `GlowEffect` → bag hover
- `PulseEffect` → botón Complete
- `HapticManager.playCorrectAnswer/playWrongAnswer()`
- `SoundManager.playCorrectSound/playIncorrectSound()`
- `AccessibilityAnnouncement.announceScreenChange()`
- Dark gradient backgrounds
- `.frame(maxWidth: 700)` iPad constraint
