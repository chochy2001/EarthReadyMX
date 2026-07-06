# Plan de Implementacion: Simulacion Interactiva de Sismos

## EarthReady MX - Swift Student Challenge 2026

**Fecha:** 11 de Febrero 2026
**Autor:** Jorge Salgado Miranda
**Estado:** Documento de planeacion

---

## 1. Vision General

### Por que este cambio transforma la app competitivamente

La app actual tiene un flujo de **Splash > Aprender > Quiz de opcion multiple > Resultados**. Aunque funcional, el quiz de opcion multiple es un mecanismo pasivo: el usuario lee texto y selecciona una respuesta. Esto no diferencia la app de cientos de otras submissions educativas.

La transformacion propuesta reemplaza el quiz con una **simulacion visual interactiva** donde el usuario:

- **Ve** un escenario ilustrado (aula, calle, cocina, oficina, exterior)
- **Siente** el sismo (la escena tiembla, objetos caen, grietas aparecen)
- **Actua** tocando el lugar seguro correcto o arrastrando un personaje a la zona de seguridad
- **Experimenta presion de tiempo** (tiene segundos limitados para reaccionar, como en un sismo real)
- **Recibe retroalimentacion visual** (polvo, objetos cayendo, grietas en pantalla)

Esto alinea directamente con los criterios de evaluacion del Swift Student Challenge 2026:
- **Innovacion**: Simulacion interactiva de desastres, no un quiz convencional
- **Creatividad**: Escenas construidas enteramente con SF Symbols y shapes de SwiftUI (sin imagenes externas)
- **Impacto social**: Mexico es zona sismica - la app ensenya reacciones correctas de manera visceral
- **Inclusividad**: Interacciones intuitivas (tap/drag) que no requieren instrucciones textuales

### Referentes competitivos

Segun la investigacion de apps ganadoras del Swift Student Challenge 2025:
- **EvacuMate** (Marina Lee) - app de organizacion durante desastres naturales - gano por impacto social
- **Hanafuda Tactics** (Taiki Hamamoto) - preservacion cultural a traves de un juego de cartas interactivo
- **BreakDownCosmic** (Luciana Ortiz Nolasco) - astronomia accesible con visualizaciones

Nuestro enfoque combina **impacto social** (preparacion ante sismos en Mexico) con **interactividad tipo juego** (simulacion visual con presion de tiempo), diferenciandose de un simple quiz educativo.

---

## 2. Descripcion de Escenas

Cada escena es un escenario visual construido **sin imagenes externas**, usando unicamente:
- **SF Symbols** (5,000+ iconos disponibles)
- **Shapes de SwiftUI** (Rectangle, RoundedRectangle, Circle, Capsule, Path)
- **Canvas** para rendering de particulas y efectos complejos
- **Gradients** para fondos y ambientacion

### Escena 1: Aula de Clases (Classroom)

**Contexto**: Estas en un salon de clases en el 3er piso cuando comienza un sismo fuerte.

**Composicion visual**:
```
+------------------------------------------+
|  [techo - Rectangle gris con lampara]    |
|                                          |
|  [pizarron - RoundedRect verde oscuro]   |
|                                          |
|  [ventana]    [reloj]     [estante]      |
|  Rectangle    SF Symbol   Rectangle +    |
|  con lineas   clock.fill  books.vertical |
|                                          |
|  [escritorio1] [escritorio2] [escritor3] |
|  Rectangle     Rectangle     Rectangle  |
|  + chair       + chair       + chair    |
|                                          |
|          [puerta - RoundedRect]          |
|  [personaje - person.fill SF Symbol]     |
+------------------------------------------+
```

**Elementos que se mueven durante el sismo**:
- Libros caen del estante (SF Symbol `book.closed.fill` con animacion de caida)
- Lampara del techo se balancea (oscilacion pendular)
- Reloj cae de la pared (rotacion + caida)
- Ventana se agrieta (Path con lineas de grieta)
- Todo el escenario tiembla (ShakeEffect existente con mayor intensidad)

**Zona segura correcta**: Debajo de cualquiera de los escritorios (tap zone o arrastrar personaje)

**Zonas incorrectas**:
- Puerta (mito comun, no es mas seguro en edificios modernos)
- Ventana (peligro de vidrios rotos)
- Junto al estante (objetos caen encima)

**SF Symbols utilizados**:
- `person.fill` - personaje del usuario
- `book.closed.fill` - libros que caen
- `clock.fill` - reloj de pared
- `lamp.ceiling.fill` - lampara
- `door.left.hand.open` - puerta
- `chair.fill` - sillas

---

### Escena 2: Calle entre Edificios (Street)

**Contexto**: Caminas por la calle entre edificios cuando un sismo golpea. Hay edificios a ambos lados.

**Composicion visual**:
```
+------------------------------------------+
|  [cielo - gradiente azul a naranja]      |
|                                          |
| [edificio]                  [edificio]   |
| Rectangle                   Rectangle    |
| con ventanas                con ventanas |
| (grid de                    (grid de     |
|  Rectangles)                 Rectangles) |
|                                          |
| [poste luz]    [calle]    [semaforo]     |
| Capsule +      gris        Rectangle    |
| circle         Path         + circles   |
|                                          |
|  [auto]  [personaje]  [grieta suelo]     |
|  SF car  person.fill   Path zigzag      |
|                                          |
| [area abierta - zona verde/parque]       |
| RoundedRect + tree.fill SF Symbols       |
+------------------------------------------+
```

**Elementos que se mueven durante el sismo**:
- Vidrios caen de los edificios (pequenyos cuadrados con animacion de caida)
- Poste de luz se balancea y puede caer (rotacion sobre base)
- Semaforo parpadea y se apaga
- Grietas aparecen en la calle (Path animado)
- Ladrillos caen de edificios (rectangulos pequenyos con gravedad)

**Zona segura correcta**: Area abierta (lejos de edificios) + proteger cabeza

**Zonas incorrectas**:
- Dentro del edificio mas cercano (puede haber colapso)
- Junto al poste de luz (puede caer)
- Debajo del semaforo (puede caer)
- Junto a la pared del edificio (caida de escombros)

**SF Symbols utilizados**:
- `person.fill` - personaje
- `car.fill` - auto estacionado
- `tree.fill` - arboles del parque
- `building.2.fill` - referencia de edificios
- `light.beacon.max` - poste de luz

---

### Escena 3: Cocina (Kitchen)

**Contexto**: Estas cocinando cuando sientes el sismo. Hay fuego encendido y objetos pesados en estantes altos.

**Composicion visual**:
```
+------------------------------------------+
|  [techo con lampara]                     |
|                                          |
|  [estante alto]    [refrigerador]        |
|  Rectangle +       RoundedRect grande    |
|  cup.and.saucer    con handle            |
|  bottle.fill                             |
|                                          |
|  [estufa/horno]   [fregadero]            |
|  Rectangle +       Rectangle +           |
|  flame.fill        drop.fill             |
|  (encendido)                             |
|                                          |
|  [mesa cocina]    [silla]                |
|  Rectangle +      chair SF Symbol        |
|  knife.fill                              |
|                                          |
|  [personaje]      [puerta salida]        |
|  person.fill       door symbol           |
+------------------------------------------+
```

**Elementos que se mueven durante el sismo**:
- Platos y vasos caen del estante (SF Symbols con animacion de caida + "rotura")
- Refrigerador se balancea peligrosamente (oscilacion lateral)
- Llama de la estufa crece y se mueve (particulas de fuego en Canvas)
- Cuchillos se deslizan de la mesa (movimiento lateral)
- Liquidos se derraman (shapes con animacion de fluido)

**Zona segura correcta**: Apagar fuego primero (tap en la estufa), luego cubrirse bajo la mesa de cocina

**Nota de disenyoo**: Esta escena tiene una interaccion en dos pasos:
1. Primero: Tap en la estufa para apagar el fuego (accion critica)
2. Despues: Arrastrar personaje debajo de la mesa

**Zonas incorrectas**:
- Junto al refrigerador (puede caer encima)
- Junto al estante (objetos caen)
- Salir corriendo por la puerta (tropezar durante sismo)

**SF Symbols utilizados**:
- `flame.fill` - fuego de estufa
- `cup.and.saucer.fill` - vajilla
- `fork.knife` - cubiertos
- `refrigerator.fill` - refrigerador
- `drop.fill` - agua/liquidos

---

### Escena 4: Oficina (Office)

**Contexto**: Estas en una oficina con computadoras, estantes con documentos y ventanas grandes.

**Composicion visual**:
```
+------------------------------------------+
|  [techo con luminarias fluorescentes]    |
|  Rectangles largos horizontales          |
|                                          |
|  [ventanal grande]                       |
|  Rectangle con grid de lineas            |
|  (vista de ciudad afuera)                |
|                                          |
|  [estante docs]  [impresora]  [planta]   |
|  Rectangle +     Rectangle    leaf.fill  |
|  doc.fill        printer.fill            |
|                                          |
|  [escritorio1 - PC]  [escritorio2 - PC]  |
|  Rectangle +          Rectangle +        |
|  desktopcomputer      desktopcomputer    |
|                                          |
|  [dispensador agua]   [extintor]         |
|  cylinder shape       Rectangle rojo     |
|                                          |
|  [personaje]          [puerta exit]      |
+------------------------------------------+
```

**Elementos que se mueven durante el sismo**:
- Monitores caen de escritorios (rotacion + caida)
- Documentos vuelan del estante (rectangulos blancos flotando)
- Luminarias del techo se balancean y una cae
- Ventanal se agrieta progresivamente (Path animado con cracks)
- Dispensador de agua se vuelca (rotacion sobre base)
- Maceta cae y se rompe

**Zona segura correcta**: Debajo de un escritorio resistente (Drop, Cover, Hold On)

**Zonas incorrectas**:
- Junto a la ventana (vidrio puede romperse)
- Junto al estante de documentos (puede volcarse)
- Hacia la puerta de salida (no correr durante el sismo)
- Junto al dispensador de agua (puede caer encima)

**SF Symbols utilizados**:
- `desktopcomputer` - computadoras
- `printer.fill` - impresora
- `doc.fill` - documentos
- `leaf.fill` - planta
- `drop.fill` - dispensador agua

---

### Escena 5: Exterior/Parque (Outdoor)

**Contexto**: Estas en un parque/area abierta cuando un sismo fuerte golpea. Hay arboles, un kiosko y postes de luz alrededor.

**Composicion visual**:
```
+------------------------------------------+
|  [cielo - gradiente azul]                |
|  [nubes - ellipses blancas]             |
|                                          |
|  [arbol grande]  [arbol]  [arbol]        |
|  Circle verde +  Circle   Circle         |
|  Rectangle cafe  + Rect   + Rect         |
|                                          |
|  [kiosko/estructura]                     |
|  Rectangle con triangulo encima          |
|  (techo inclinado)                       |
|                                          |
|  [poste luz] [banca] [poste luz]         |
|  Capsule     Rect    Capsule             |
|                                          |
|  [personaje]                             |
|  person.fill                             |
|                                          |
|  [area abierta central - zona verde]     |
|  Grande area sin obstaculos              |
|                                          |
|  [cables electricos entre postes]        |
|  Path curvo                              |
+------------------------------------------+
```

**Elementos que se mueven durante el sismo**:
- Arboles se balancean fuertemente (rotacion oscilante en la base)
- Ramas caen (shapes pequenyos con gravedad)
- Postes de luz se inclinan
- Kiosko se agrieta y el techo se deforma
- Grietas en el suelo (Paths animados)
- Cables electricos se balancean peligrosamente

**Zona segura correcta**: Area abierta central, lejos de arboles, postes y estructuras + cubrirse la cabeza

**Zonas incorrectas**:
- Debajo de un arbol (ramas pueden caer)
- Junto al poste de luz (puede caer, cables electricos)
- Dentro del kiosko (estructura puede colapsar)
- Junto a la banca bajo el arbol (combinacion de peligros)

**SF Symbols utilizados**:
- `tree.fill` - arboles
- `leaf.fill` - ramas/hojas que caen
- `light.beacon.max` - postes
- `bolt.fill` - cables electricos
- `person.fill` - personaje

---

## 3. Mecanicas de Interaccion

### 3.1 Sistema de Fases por Escenario

Cada escenario tiene tres fases:

```
FASE 1: Observacion (3 segundos)
- El usuario ve la escena tranquila
- Se muestra un breve texto contextual en la parte superior
- Elementos del ambiente se animan sutilmente (reloj funciona, llama de estufa parpadea)
- Un indicador de "alerta sismica" aparece gradualmente

FASE 2: Sismo Activo (8-12 segundos - TIEMPO PARA ACTUAR)
- La escena comienza a temblar (ShakeEffect con intensidad creciente)
- Objetos empiezan a caer progresivamente
- Particulas de polvo aparecen
- Timer circular visible en la esquina (cuenta regresiva)
- El usuario debe: TAP en zona segura o DRAG personaje a zona segura
- Feedback inmediato al interactuar

FASE 3: Resultado (sin limite)
- El sismo se detiene
- Si acerto: zona segura resalta en verde, animacion de "salvo"
- Si fallo o no actuo a tiempo: zona correcta se muestra en verde, zona elegida en rojo
- Explicacion breve de por que es la respuesta correcta
- Boton para continuar a siguiente escenario
```

### 3.2 Tap Zones (Zonas de Toque)

Las zonas de toque son areas invisibles superpuestas sobre los elementos de la escena.

```swift
// Concepto: Cada zona tiene un hitbox rectangular
struct TapZone: Identifiable {
    let id: String
    let label: String
    let frame: CGRect          // Posicion relativa en la escena
    let isCorrect: Bool
    let feedbackMessage: String
    let sfSymbol: String       // Icono que aparece al tocar
}
```

**Indicadores visuales** (sin texto, intuitivos):
- Las zonas interactuables tienen un sutil pulso/glow para indicar que son tocables
- Al acercar el dedo (en iPad con hover), la zona se resalta ligeramente
- Flechas direccionales sutiles sugieren al personaje moverse

### 3.3 Drag-to-Move (Arrastrar para Mover)

El personaje (SF Symbol `person.fill` con circulo de fondo) es arrastrable:

```swift
// Concepto del gesto de arrastre
struct DraggableCharacter {
    var position: CGPoint       // Posicion actual
    let startPosition: CGPoint  // Posicion inicial
    var isDragging: Bool
}

// Uso de DragGesture:
// .gesture(
//     DragGesture()
//         .onChanged { value in
//             characterPosition = value.location
//             checkProximityToZones(value.location)
//         }
//         .onEnded { value in
//             evaluateDropPosition(value.location)
//         }
// )
```

**Feedback durante el arrastre**:
- El personaje deja una "estela" sutil (trail de circulos semi-transparentes)
- Al acercarse a una zona segura, esta pulsa en verde
- Al acercarse a una zona peligrosa, esta pulsa en rojo
- Si se suelta en zona neutral, el personaje regresa a la posicion inicial con animacion spring

### 3.4 Presion de Tiempo

```swift
// Concepto del timer
struct ScenarioTimer {
    let totalSeconds: Double = 10.0  // Ajustable por escenario
    var remainingSeconds: Double
    var isActive: Bool
}
```

**Representacion visual del timer**:
- Circulo de progreso en la esquina superior derecha (similar al existente pero mas prominente)
- Color del circulo cambia: verde > amarillo > naranja > rojo segun tiempo restante
- En los ultimos 3 segundos, el circulo pulsa con urgencia
- Si el tiempo se agota, se evalua como "no reacciono a tiempo" (resultado negativo pero con mensaje educativo)

**Tiempos por escenario** (ajustables segun testing):
| Escenario | Tiempo | Justificacion |
|-----------|--------|---------------|
| Aula | 10s | Primer escenario, mas tiempo para aprender |
| Calle | 8s | Ya tiene experiencia |
| Cocina | 12s | Dos pasos (apagar fuego + cubrirse) |
| Oficina | 8s | Escenario directo |
| Exterior | 8s | Ultimo, decision rapida |

### 3.5 Interaccion de Dos Pasos (Escena Cocina)

La cocina introduce una mecanica especial: **accion previa obligatoria**.

```
Paso 1: [Icono de llama parpadeando con urgencia]
        El usuario debe TAP en la estufa para apagar el fuego
        -> Feedback: la llama se extingue con animacion
        -> Texto breve: "Good! Now take cover!"

Paso 2: [Zonas de seguridad se activan]
        El usuario debe TAP en la mesa o DRAG personaje debajo
        -> Evaluacion normal
```

Si el usuario se cubre sin apagar el fuego: respuesta parcialmente correcta con mensaje de que siempre hay que apagar fuentes de fuego/gas primero si es posible.

---

## 4. Retroalimentacion Visual

### 4.1 Efecto de Temblor de Escena

Ya existe `ShakeEffect` en el proyecto. Se expandira con niveles de intensidad:

```swift
// Concepto: ShakeEffect mejorado con intensidad variable
// La intensidad incrementa durante la Fase 2 del sismo
// Rango de amount: 0 (sin temblor) -> 5 (leve) -> 15 (fuerte) -> 25 (critico)
// shakesPerUnit incrementa tambien: 3 -> 5 -> 8 por unidad
// Agrega componente Y mas pronunciado para temblor bidireccional
```

### 4.2 Grietas en Pantalla (Screen Cracks)

Ya existe `CrackShape` y `CrackLine` en `SplashView.swift`. Se reutilizara y mejorara:

```swift
// Concepto: Overlay de grietas que aparece sobre toda la escena
// Las grietas se generan desde el punto de impacto (centro-inferior)
// Crecen progresivamente durante el sismo
// Opacidad y cantidad incrementan con la intensidad
// Reutilizar CrackShape existente con generacion mas controlada
```

**Mejoras sobre el existente**:
- Grietas que nacen desde un punto central y se expanden
- Animacion de crecimiento progresivo (no aparecen de golpe)
- Color que va de gris claro a naranja segun intensidad
- Algunas grietas "secundarias" que se ramifican

### 4.3 Objetos Cayendo (Falling Objects)

```swift
// Concepto: Sistema de objetos con gravedad simulada
struct FallingObject: Identifiable {
    let id: UUID
    let symbol: String        // SF Symbol name
    let startPosition: CGPoint
    var currentPosition: CGPoint
    var rotation: Angle
    var velocity: CGFloat     // Velocidad vertical actual
    let gravity: CGFloat      // Aceleracion (constante)
    var opacity: Double
    let size: CGFloat
    var hasLanded: Bool
}

// Actualizado cada frame via TimelineView:
// velocity += gravity * deltaTime
// currentPosition.y += velocity * deltaTime
// rotation += angularVelocity * deltaTime
// Si currentPosition.y > floorY -> hasLanded = true, crear particulas de impacto
```

**Tipos de caida**:
1. **Caida libre**: Libros, platos (caen recto con rotacion)
2. **Caida con balanceo**: Lampara, reloj (pendulo antes de caer)
3. **Deslizamiento**: Objetos en mesas (se deslizan lateralmente primero, luego caen)
4. **Volcado**: Refrigerador, estante (rotacion lenta sobre la base, luego caida)

### 4.4 Particulas de Polvo/Escombros

Ya existe `ParticlesView` con `Canvas` en `ResultView.swift`. Se adaptara para polvo:

```swift
// Concepto: Particulas de polvo usando Canvas + TimelineView
// Particulas pequenyas (2-4px), color gris-cafe, opacidad 0.3-0.6
// Movimiento: mayormente ascendente y lateral (polvo sube al caer cosas)
// Se generan en posiciones donde caen objetos
// Vida corta (1-2 segundos)
// Sin gravedad (flotan) o con gravedad negativa (suben)

// Para impactos: particulas mas grandes, explosion radial desde punto de impacto
// Color mas oscuro, vida mas corta (0.5s)
```

**Sistemas de particulas por tipo**:
| Tipo | Tamano | Color | Movimiento | Duracion |
|------|--------|-------|------------|----------|
| Polvo ambiental | 2-4px | Gris claro | Flotante, aleatorio | 2-3s |
| Impacto de caida | 3-6px | Gris-cafe | Radial desde impacto | 0.5-1s |
| Vidrio roto | 2-5px | Blanco-cyan | Radial + gravedad | 1-2s |
| Chispas (electrico) | 1-3px | Amarillo-naranja | Radial rapido | 0.3-0.5s |
| Humo/vapor | 5-10px | Gris opaco | Ascendente lento | 3-4s |

### 4.5 Feedback de Respuesta

**Respuesta correcta**:
- La zona segura se ilumina en verde con glow
- Checkmark animado (SF Symbol `checkmark.circle.fill` con scale-in)
- El personaje muestra una animacion de "cubierto" (se agacha)
- Particulas doradas/verdes de celebracion
- Vibracion haptica suave (si dispositivo lo soporta)
- Texto breve: "Correct! Drop, Cover, Hold On saves lives."

**Respuesta incorrecta**:
- La zona elegida parpadea en rojo
- X animada (SF Symbol `xmark.circle.fill`)
- La zona correcta se ilumina en verde para mostrar donde debia ir
- Shake adicional del UI
- Texto educativo explicando por que esa zona es peligrosa

**Tiempo agotado**:
- Flash rojo en toda la pantalla (overlay 0.3 opacidad)
- Texto: "Time's up! In a real earthquake, every second counts."
- Se muestra la zona correcta en verde
- Cuenta como respuesta incorrecta en la puntuacion

---

## 5. Arquitectura Tecnica

### 5.1 Rendering de Escenas con Canvas + SwiftUI Views

Se usara un enfoque hibrido:

```
+-----------------------------------------------+
| ZStack (Escena completa)                       |
|                                                |
|  Capa 1: Canvas (fondo + elementos estaticos)  |
|  - Paredes, piso, cielo                        |
|  - Muebles/objetos fijos                       |
|  - Elementos decorativos                       |
|                                                |
|  Capa 2: SwiftUI Views (elementos animados)    |
|  - Objetos que caen (con animacion Spring)      |
|  - Personaje arrastrable                       |
|  - Zonas de toque interactivas                 |
|                                                |
|  Capa 3: Canvas (particulas + efectos)          |
|  - Polvo, escombros, chispas                   |
|  - Grietas en pantalla                         |
|                                                |
|  Capa 4: SwiftUI Overlay (UI)                  |
|  - Timer countdown                             |
|  - Feedback de respuesta                       |
|  - Texto contextual                            |
+-----------------------------------------------+
```

**Justificacion del enfoque hibrido**:
- Canvas es mas eficiente para rendering de muchas shapes estaticas y particulas (no crea un View por cada elemento)
- SwiftUI Views son mejores para elementos interactivos (gestures nativos, accessibility)
- Combinar ambos da el mejor balance de rendimiento e interactividad

### 5.2 Game Loop con TimelineView

```swift
// Concepto: Game loop basado en TimelineView para animaciones de fisica
// TimelineView(.animation) actualiza a ~60fps
// Cada frame calcula:
// 1. Delta time desde ultimo frame
// 2. Actualiza posiciones de objetos cayendo (gravedad)
// 3. Actualiza particulas (posicion, opacidad, vida)
// 4. Actualiza intensidad del sismo (curva de intensidad)
// 5. Verifica colisiones (objeto toca el suelo)
// 6. Genera nuevas particulas si es necesario

// Estructura conceptual:
// struct GameLoop {
//     var lastUpdate: Date
//     var earthquakeIntensity: Double  // 0.0 a 1.0
//     var fallingObjects: [FallingObject]
//     var particles: [DustParticle]
//     var elapsedTime: Double
//     var phase: ScenarioPhase  // .observation, .earthquake, .result
// }
```

### 5.3 Gestion de Estado (State Management)

Se extiende el `GameState` existente manteniendo compatibilidad:

```swift
// Concepto: Extensiones al GameState existente

// Nuevos enums:
// enum ScenarioType: String, CaseIterable, Sendable {
//     case classroom, street, kitchen, office, outdoor
// }
//
// enum ScenarioPhase: Sendable {
//     case observation    // 3s - ver la escena
//     case earthquake     // 8-12s - actuar
//     case result         // sin limite - ver resultado
// }
//
// enum InteractionResult: Sendable {
//     case correct
//     case incorrect(zoneTapped: String)
//     case timeout
//     case partiallyCorrect(reason: String)  // Para cocina
// }

// Nuevas propiedades en GameState:
// @Published var currentScenarioIndex: Int = 0
// @Published var currentScenarioPhase: ScenarioPhase = .observation
// @Published var scenarioResults: [ScenarioType: InteractionResult] = [:]
// @Published var characterPosition: CGPoint = .zero
// @Published var timeRemaining: Double = 10.0
// @Published var earthquakeIntensity: Double = 0.0
// @Published var interactiveScore: Int = 0
// @Published var totalInteractiveScenarios: Int = 5

// Los scenarios existentes (quiz de opcion multiple) se mantienen como fallback
// pero el flujo principal usa los nuevos InteractiveScenario
```

### 5.4 Curva de Intensidad del Sismo

La intensidad del sismo no es constante, sigue una curva realista:

```
Intensidad
1.0 |          ****
    |        **    **
0.8 |      **        **
    |    **            **
0.6 |   *                *
    |  *                  **
0.4 | *                     **
    |*                        ***
0.2 |                            ***
    |                               ****
0.0 |________________________________****___
    0s   2s   4s   6s   8s   10s   12s
         Fase Observacion | Fase Sismo
```

```swift
// Concepto: Funcion de intensidad
// func earthquakeIntensity(at time: Double, duration: Double) -> Double {
//     let normalizedTime = time / duration
//     // Curva tipo campana asimetrica: sube rapido, baja gradualmente
//     if normalizedTime < 0.3 {
//         // Fase de incremento rapido
//         return sin(normalizedTime / 0.3 * .pi / 2)
//     } else if normalizedTime < 0.7 {
//         // Fase de maxima intensidad con variaciones
//         return 0.8 + 0.2 * sin(normalizedTime * 10)
//     } else {
//         // Fase de disminucion
//         return (1.0 - normalizedTime) / 0.3
//     }
// }
```

---

## 6. Arquitectura de Codigo y Componentes Clave

### 6.1 Estructura de Archivos Propuesta

```
EarthReadyMXFinal.swiftpm/
|-- MyApp.swift                    (existente - sin cambios)
|-- ContentView.swift              (existente - agregar nueva fase)
|-- GameState.swift                (existente - extender)
|-- ShakeEffect.swift              (existente - mejorar)
|-- LearnView.swift                (existente - sin cambios)
|-- SplashView.swift               (existente - sin cambios)
|-- SimulationView.swift           (existente - reemplazar contenido)
|-- ResultView.swift               (existente - adaptar scoring)
|
|-- Nuevos archivos:
|-- InteractiveScenario.swift      (modelo de datos del escenario)
|-- SceneRenderer.swift            (componente Canvas para dibujar escenas)
|-- ScenarioHostView.swift         (view que orquesta cada escenario)
|-- DraggableCharacter.swift       (personaje arrastrable)
|-- TapZoneOverlay.swift           (zonas de toque invisibles)
|-- FallingObjectsLayer.swift      (capa de objetos que caen)
|-- DustParticleSystem.swift       (sistema de particulas de polvo)
|-- CrackOverlay.swift             (grietas en pantalla, basado en existente)
|-- CountdownTimer.swift           (timer visual circular)
|-- ScenarioFeedback.swift         (feedback de respuesta correcta/incorrecta)
|
|-- Escenas individuales:
|-- ClassroomScene.swift           (configuracion de escena aula)
|-- StreetScene.swift              (configuracion de escena calle)
|-- KitchenScene.swift             (configuracion de escena cocina)
|-- OfficeScene.swift              (configuracion de escena oficina)
|-- OutdoorScene.swift             (configuracion de escena exterior)
```

### 6.2 Componentes Clave

#### InteractiveScenario (Modelo de Datos)

```swift
// Concepto: Cada escenario define su configuracion completa
// struct InteractiveScenario: Identifiable, Sendable {
//     let id: UUID
//     let type: ScenarioType
//     let title: String
//     let contextMessage: String
//     let timeLimit: Double
//     let characterStartPosition: CGPoint  // Posicion normalizada 0-1
//     let tapZones: [TapZone]
//     let fallingObjects: [FallingObjectConfig]
//     let correctExplanation: String
//     let incorrectExplanations: [String: String]  // zoneId: message
//     let hasPreAction: Bool      // true para cocina (apagar fuego primero)
//     let preActionZoneId: String? // ID de la zona de pre-accion
// }
```

#### SceneRenderer (Canvas Principal)

```swift
// Concepto: View que usa Canvas para dibujar el fondo de cada escena
// struct SceneRenderer: View {
//     let sceneType: ScenarioType
//     let intensity: Double  // 0-1, controla deformaciones visuales
//
//     var body: some View {
//         Canvas { context, size in
//             switch sceneType {
//             case .classroom: drawClassroom(context: context, size: size)
//             case .street: drawStreet(context: context, size: size)
//             case .kitchen: drawKitchen(context: context, size: size)
//             case .office: drawOffice(context: context, size: size)
//             case .outdoor: drawOutdoor(context: context, size: size)
//             }
//         }
//     }
//
//     // Cada metodo draw usa:
//     // context.fill(Path {...}, with: .color(...))
//     // context.stroke(Path {...}, with: .color(...))
//     // context.draw(Image(systemName: ...), at: ...)
//     // context.draw(Text(...), at: ...) para labels
// }
```

#### ScenarioHostView (Orquestador)

```swift
// Concepto: View principal que maneja el flujo de cada escenario
// struct ScenarioHostView: View {
//     let scenario: InteractiveScenario
//     @StateObject private var scenarioState = ScenarioState()
//
//     var body: some View {
//         ZStack {
//             // Capa 1: Escena de fondo
//             SceneRenderer(sceneType: scenario.type,
//                          intensity: scenarioState.intensity)
//                 .modifier(ShakeEffect(
//                     amount: scenarioState.shakeAmount,
//                     animatableData: scenarioState.shakeData
//                 ))
//
//             // Capa 2: Objetos cayendo
//             FallingObjectsLayer(objects: scenarioState.fallingObjects)
//
//             // Capa 3: Personaje arrastrable
//             DraggableCharacter(
//                 position: $scenarioState.characterPosition,
//                 isEnabled: scenarioState.phase == .earthquake
//             )
//
//             // Capa 4: Zonas de toque
//             TapZoneOverlay(
//                 zones: scenario.tapZones,
//                 phase: scenarioState.phase,
//                 onTap: scenarioState.handleTap
//             )
//
//             // Capa 5: Particulas
//             DustParticleSystem(
//                 emitters: scenarioState.activeEmitters,
//                 intensity: scenarioState.intensity
//             )
//
//             // Capa 6: Grietas
//             CrackOverlay(intensity: scenarioState.intensity)
//
//             // Capa 7: UI
//             VStack {
//                 CountdownTimer(remaining: scenarioState.timeRemaining,
//                               total: scenario.timeLimit)
//                 Spacer()
//                 if scenarioState.phase == .result {
//                     ScenarioFeedback(result: scenarioState.result,
//                                     explanation: scenario.correctExplanation)
//                 }
//             }
//         }
//     }
// }
```

#### FallingObjectsLayer (Objetos Cayendo)

```swift
// Concepto: Renderiza objetos que caen usando TimelineView + Canvas
// struct FallingObjectsLayer: View {
//     let objects: [FallingObject]
//
//     var body: some View {
//         TimelineView(.animation) { timeline in
//             Canvas { context, size in
//                 for object in objects where !object.hasLanded {
//                     // Resolver SF Symbol como Image
//                     let image = context.resolve(
//                         Image(systemName: object.symbol)
//                     )
//
//                     // Aplicar transformaciones
//                     var localContext = context
//                     localContext.opacity = object.opacity
//                     localContext.translateBy(
//                         x: object.currentPosition.x,
//                         y: object.currentPosition.y
//                     )
//                     localContext.rotate(by: object.rotation)
//
//                     // Dibujar
//                     localContext.draw(image, at: .zero)
//                 }
//             }
//         }
//     }
// }
```

#### DustParticleSystem (Particulas)

```swift
// Concepto: Basado en ParticlesView existente, adaptado para polvo
// Usa Canvas + TimelineView para rendimiento
// Cada emitter genera particulas en una posicion especifica
// Las particulas tienen: posicion, velocidad, tamano, color, vida
//
// struct DustParticleSystem: View {
//     let emitters: [ParticleEmitter]
//     let intensity: Double
//
//     @State private var particles: [DustParticle] = []
//
//     var body: some View {
//         TimelineView(.animation) { timeline in
//             Canvas { context, size in
//                 for particle in particles {
//                     let age = timeline.date.timeIntervalSince(particle.born)
//                     guard age < particle.lifetime else { continue }
//                     let progress = age / particle.lifetime
//
//                     let x = particle.x + particle.vx * age
//                     let y = particle.y + particle.vy * age
//                     let opacity = (1 - progress) * particle.maxOpacity
//                     let pSize = particle.size * (1 + progress * 0.5)
//
//                     context.opacity = opacity
//                     context.fill(
//                         Circle().path(in: CGRect(
//                             x: x - pSize/2, y: y - pSize/2,
//                             width: pSize, height: pSize
//                         )),
//                         with: .color(particle.color)
//                     )
//                 }
//             }
//         }
//     }
// }
```

### 6.3 Reutilizacion de Componentes Existentes

| Componente Existente | Reutilizacion |
|---------------------|---------------|
| `ShakeEffect` | Se usa directamente, parametrizando `amount` segun intensidad del sismo |
| `PulseEffect` | Se aplica a zonas de toque para indicar interactividad |
| `GlowEffect` | Se aplica a la zona correcta cuando se revela la respuesta |
| `CrackLine` + `CrackShape` | Se reutiliza para grietas de escena, generacion mas controlada |
| `ParticlesView` + `Particle` | Base para `DustParticleSystem`, se adapta colores/comportamiento |
| `SeismographView` | Se puede mostrar como indicador de intensidad del sismo en UI |

---

## 7. Integracion con Flujo Existente de la App

### 7.1 Flujo Actual

```
Splash -> Learn (Before/During/After) -> Simulation (Quiz MC) -> Result
```

### 7.2 Flujo Propuesto

```
Splash -> Learn (Before/During/After) -> Interactive Simulation -> Result
                                         |
                                         |-- Escena 1: Aula
                                         |-- Escena 2: Calle
                                         |-- Escena 3: Cocina
                                         |-- Escena 4: Oficina
                                         |-- Escena 5: Exterior
                                         |
                                         (transiciones entre escenas con
                                          matched geometry / fade)
```

### 7.3 Cambios en Archivos Existentes

**`GameState.swift`**:
- Agregar nuevos enums (`ScenarioType`, `ScenarioPhase`, `InteractionResult`)
- Agregar nuevas propiedades published para el estado de la simulacion interactiva
- Agregar array de `InteractiveScenario` (similar a como `scenarios` ya existe)
- Adaptar `scorePercentage` y `scoreMessage` para trabajar con ambos sistemas
- Mantener el quiz de opcion multiple como fallback (no borrar `scenarios`)

**`SimulationView.swift`**:
- Reemplazar el contenido del body para usar `ScenarioHostView`
- Mantener el header con progreso
- Cambiar la logica de navegacion entre escenarios

**`ResultView.swift`**:
- Adaptar para mostrar resultados por escenario (con iconos de escena)
- Mostrar si fue correcto, incorrecto, o timeout
- Agregar detalles mas ricos (tiempo de reaccion, etc.)

**`ContentView.swift`**:
- Sin cambios necesarios (el `AppPhase` ya tiene `.simulation`)

**`ShakeEffect.swift`**:
- Sin cambios estructurales, solo se usara con parametros mas variados

### 7.4 AppPhase sin Cambios

El flujo de `AppPhase` (.splash, .learn, .simulation, .result) se mantiene intacto. La simulacion interactiva reemplaza el contenido de `.simulation`, no la estructura de navegacion.

---

## 8. Consideraciones de Swift 6 y Sendable

### 8.1 Concurrency Safety

Swift 6 tiene strict concurrency checking. Todas las estructuras de datos deben ser `Sendable`:

```swift
// Todos los modelos DEBEN ser Sendable (ya lo hacen los existentes):
// struct InteractiveScenario: Identifiable, Sendable { ... }
// struct TapZone: Identifiable, Sendable { ... }
// struct FallingObjectConfig: Sendable { ... }
// enum ScenarioType: String, CaseIterable, Sendable { ... }
// enum ScenarioPhase: Sendable { ... }
// enum InteractionResult: Sendable { ... }

// GameState ya es @MainActor - se mantiene asi
// Todos los timers y callbacks usan Task { @MainActor in ... }
// como ya hace el seismographTimer existente en SplashView
```

### 8.2 Timer en Swift 6

El patron ya usado en SplashView con `Timer.scheduledTimer` + `Task { @MainActor in }` es correcto y se mantiene:

```swift
// Patron existente que se reutiliza:
// Timer.scheduledTimer(withTimeInterval: 1.0/60.0, repeats: true) { _ in
//     Task { @MainActor in
//         // Actualizar estado del juego aqui
//     }
// }
```

### 8.3 Compatibilidad iPad/iPhone

Todas las posiciones deben ser **relativas al tamano de pantalla**, no absolutas:

```swift
// Concepto: Usar GeometryReader para posiciones relativas
// GeometryReader { geo in
//     let w = geo.size.width
//     let h = geo.size.height
//
//     // Posicionar escritorio al 30% horizontal, 60% vertical
//     DeskShape()
//         .position(x: w * 0.3, y: h * 0.6)
//
//     // Tap zones tambien relativas
//     Rectangle()
//         .frame(width: w * 0.2, height: h * 0.15)
//         .position(x: w * 0.3, y: h * 0.65)
// }
```

**Landscape vs Portrait**: La app soporta ambas orientaciones (segun Package.swift). Las escenas deben adaptarse:
- Portrait: escena vertical, elementos apilados
- Landscape: escena horizontal, mas espacio lateral
- Usar `GeometryReader` y proporciones, no valores fijos

---

## 9. Experiencia sin Instrucciones (Intuitividad)

### 9.1 Onboarding Visual Implicito

En vez de texto de instrucciones, la primera escena (Aula) ensenyaa las mecanicas:

```
1. Escena aparece con animacion
2. Texto minimo en la parte superior: "An earthquake is starting..."
3. El personaje tiene un glow/pulso que indica "soy interactivo"
4. Al iniciar el sismo, flechas sutiles apuntan a zonas seguras
5. Si el usuario no interactua en 3 segundos, el personaje "mira" hacia
   la zona correcta (rotacion del SF Symbol)
6. El circulo de countdown es un lenguaje visual universal
```

### 9.2 Progressive Disclosure

| Escenario | Mecanica Nueva | Como se introduce |
|-----------|----------------|-------------------|
| Aula (1) | Tap en zona segura | Zona correcta pulsa sutilmente |
| Calle (2) | Drag personaje | El personaje tiene handle visual de arrastre |
| Cocina (3) | Accion previa (2 pasos) | Icono de llama parpadea con urgencia |
| Oficina (4) | Sin mecanica nueva | Refuerza lo aprendido |
| Exterior (5) | Decision bajo presion extrema | Timer mas agresivo |

### 9.3 Feedback Haptico (donde disponible)

```swift
// Concepto:
// Al inicio del sismo: UIImpactFeedbackGenerator(style: .heavy)
// Al tocar zona correcta: UINotificationFeedbackGenerator(.success)
// Al tocar zona incorrecta: UINotificationFeedbackGenerator(.error)
// Temblor continuo: UIImpactFeedbackGenerator(style: .light) periodico
```

---

## 10. Esfuerzo Estimado por Componente

### Componentes de Infraestructura (hacer primero)

| Componente | Esfuerzo | Descripcion |
|-----------|----------|-------------|
| `InteractiveScenario.swift` (modelo) | 1-2 horas | Structs y enums de datos |
| `GameState` extensiones | 2-3 horas | Nuevas propiedades, logica de scoring |
| `ScenarioHostView.swift` | 4-6 horas | Orquestador principal, game loop |
| `CountdownTimer.swift` | 1-2 horas | Timer visual circular |
| `ScenarioFeedback.swift` | 2-3 horas | Pantallas de resultado por escenario |
| `ShakeEffect` mejoras | 1 hora | Intensidad variable |
| `CrackOverlay.swift` | 2 horas | Basado en existente, mas controlado |

### Componentes de Interaccion

| Componente | Esfuerzo | Descripcion |
|-----------|----------|-------------|
| `DraggableCharacter.swift` | 3-4 horas | Personaje con DragGesture + feedback |
| `TapZoneOverlay.swift` | 2-3 horas | Zonas invisibles de toque + feedback |
| `FallingObjectsLayer.swift` | 4-5 horas | Canvas + TimelineView + fisica |
| `DustParticleSystem.swift` | 3-4 horas | Adaptacion del existente para polvo |

### Escenas Individuales

| Escena | Esfuerzo | Complejidad |
|--------|----------|-------------|
| `ClassroomScene.swift` | 6-8 horas | Media - primera escena, establece patrones |
| `StreetScene.swift` | 5-7 horas | Media-alta - muchos elementos, perspectiva |
| `KitchenScene.swift` | 7-9 horas | Alta - accion de dos pasos |
| `OfficeScene.swift` | 5-7 horas | Media - similar a aula |
| `OutdoorScene.swift` | 5-7 horas | Media - area abierta |

### Integracion y Pulido

| Tarea | Esfuerzo | Descripcion |
|-------|----------|-------------|
| Integracion con `SimulationView` | 2-3 horas | Reemplazar contenido |
| Adaptacion de `ResultView` | 2-3 horas | Nuevo formato de resultados |
| Transiciones entre escenas | 2-3 horas | Animaciones fluidas |
| Testing y ajuste de dificultad | 4-6 horas | Balance de tiempos, posiciones |
| Testing iPad/iPhone | 3-4 horas | Adaptacion responsive |

### Resumen de Esfuerzo Total

| Categoria | Horas estimadas |
|-----------|----------------|
| Infraestructura | 13-19 horas |
| Interaccion | 12-16 horas |
| Escenas | 28-38 horas |
| Integracion/Pulido | 13-19 horas |
| **TOTAL** | **66-92 horas** |

---

## 11. Orden de Implementacion Priorizado

### Fase 1: Infraestructura Base (prioridad critica)

**Objetivo**: Tener el framework funcional con una escena minima.

```
1. InteractiveScenario.swift - Modelos de datos
2. GameState extensiones - Estado del juego
3. ShakeEffect mejoras - Intensidad variable
4. CountdownTimer.swift - Timer visual
5. ScenarioHostView.swift - Orquestador basico
6. CrackOverlay.swift - Reutilizar existente
```

**Entregable**: Framework que puede mostrar una escena vacia con timer, temblor y grietas.

### Fase 2: Escena Piloto - Aula de Clases (prioridad alta)

**Objetivo**: Una escena completa de principio a fin.

```
7. SceneRenderer.swift - Canvas para dibujar el aula
8. ClassroomScene.swift - Configuracion de la escena
9. TapZoneOverlay.swift - Zonas de toque
10. FallingObjectsLayer.swift - Libros y reloj cayendo
11. DustParticleSystem.swift - Polvo basico
12. ScenarioFeedback.swift - Resultado de la escena
```

**Entregable**: Escena del aula completamente jugable con tap para seleccionar zona segura.

### Fase 3: Mecanica de Arrastre + Escena Calle (prioridad alta)

**Objetivo**: Agregar drag-to-move y segunda escena.

```
13. DraggableCharacter.swift - Personaje arrastrable
14. StreetScene.swift - Escena de la calle
15. Transiciones entre escenas
```

**Entregable**: Dos escenas jugables, una con tap y otra con drag.

### Fase 4: Escena Cocina con Mecanica de Dos Pasos (prioridad media)

**Objetivo**: Escena mas compleja con interaccion previa.

```
16. KitchenScene.swift - Escena de cocina
17. Logica de pre-accion (apagar fuego)
18. Nuevas particulas (fuego, vapor)
```

**Entregable**: Tres escenas jugables con mecanica de dos pasos.

### Fase 5: Escenas Restantes (prioridad media)

**Objetivo**: Completar todas las escenas.

```
19. OfficeScene.swift - Escena de oficina
20. OutdoorScene.swift - Escena exterior
```

**Entregable**: Cinco escenas completas.

### Fase 6: Integracion y Pulido Final (prioridad alta)

**Objetivo**: App pulida lista para submission.

```
21. Integracion con SimulationView existente
22. Adaptacion de ResultView para nuevos resultados
23. Testing de responsive (iPad/iPhone, portrait/landscape)
24. Ajuste de dificultad y tiempos
25. Testing completo de flujo end-to-end
26. Haptic feedback donde corresponda
27. Revision de accesibilidad basica
```

**Entregable**: App lista para enviar al Swift Student Challenge.

---

## 12. Riesgos y Mitigaciones

| Riesgo | Probabilidad | Impacto | Mitigacion |
|--------|-------------|---------|------------|
| Rendimiento en Canvas con muchas particulas | Media | Alto | Limitar particulas a max 50 simultaneas; usar .animation schedule, no .periodic |
| Escenas no se ven bien sin imagenes reales | Alta | Alto | Invertir tiempo en disenyoo visual con shapes; usar gradientes y sombras para profundidad |
| SF Symbols no disponibles en iOS 16 | Baja | Medio | Verificar disponibilidad; usar fallbacks de SF Symbols basicos |
| Tamanyoo del zip > 25MB | Baja | Bajo | Sin imagenes externas, solo codigo; no deberia ser problema |
| Tiempo de desarrollo excede deadline (28 Feb 2026) | Media | Critico | Priorizar 3 escenas minimo (Aula, Calle, Cocina); las 2 restantes son "nice to have" |
| Experiencia 3 minutos (limite del challenge) | Media | Alto | Cada escena ~30s; 5 escenas = 2.5min + splash + learn resumido |

### Plan de Contingencia (si falta tiempo)

Si no se pueden completar las 5 escenas para el deadline:

**Minimo viable (3 escenas)**:
1. Aula de Clases (tap)
2. Calle entre Edificios (drag)
3. Cocina (dos pasos)

Estas tres escenas demuestran las tres mecanicas distintas y cubren tres contextos diferentes (interior educativo, exterior urbano, hogar).

---

## 13. Recursos Tecnicos de Referencia

### Canvas y Rendering 2D
- [Mastering Canvas in SwiftUI - Swift with Majid](https://swiftwithmajid.com/2023/04/11/mastering-canvas-in-swiftui/)
- [Drawing graphics with Canvas - Create with Swift](https://www.createwithswift.com/drawing-graphics-with-canvas/)
- [Canvas - Apple Developer Documentation](https://developer.apple.com/documentation/swiftui/canvas)
- [Creating shapes using Path in SwiftUI Canvas](https://www.createwithswift.com/creating-shapes-using-path-in-the-swiftui-canvas-view/)

### Gestos Interactivos
- [How to use gestures in SwiftUI - Hacking with Swift](https://www.hackingwithswift.com/books/ios-swiftui/how-to-use-gestures-in-swiftui)
- [Drag Gesture - Design+Code](https://designcode.io/swiftui-handbook-drag-gesture/)
- [Move your view around with Drag Gesture - Sarunw](https://sarunw.com/posts/move-view-around-with-drag-gesture-in-swiftui/)

### Efectos y Animaciones
- [Advanced SwiftUI Animations Part 2: GeometryEffect - SwiftUI Lab](https://swiftui-lab.com/swiftui-animations-part2/)
- [Particle Effects with SwiftUI Canvas - Pavel Zak](https://nerdyak.tech/development/2024/06/27/particle-effects-with-SwiftUI-Canvas.html)
- [Special Effects with SwiftUI - Hacking with Swift](https://www.hackingwithswift.com/articles/246/special-effects-with-swiftui)
- [Advanced SwiftUI Animations Part 5: Canvas - SwiftUI Lab](https://swiftui-lab.com/swiftui-animations-part5/)

### Game Loop y TimelineView
- [Custom animated drawings with TimelineView and Canvas - Hacking with Swift](https://www.hackingwithswift.com/quick-start/swiftui/how-to-create-custom-animated-drawings-with-timelineview-and-canvas)
- [Advanced Animations in SwiftUI Using TimelineView and Canvas - Commit Studio](https://commitstudiogs.medium.com/advanced-animations-in-swiftui-using-timelineview-and-canvas-cf71fbcb2f11)

### Matched Geometry y Transiciones
- [matchedGeometryEffect - Apple Developer Documentation](https://developer.apple.com/documentation/swiftui/view/matchedgeometryeffect(id:in:properties:anchor:issource:))
- [MatchedGeometryEffect Hero Animations - SwiftUI Lab](https://swiftui-lab.com/matchedgeometryeffect-part1/)

### State Management
- [SwiftUI State Management Guide - Swift by Sundell](https://www.swiftbysundell.com/articles/swiftui-state-management-guide/)
- [How to use a timer with SwiftUI - Hacking with Swift](https://www.hackingwithswift.com/quick-start/swiftui/how-to-use-a-timer-with-swiftui)

### Swift Student Challenge 2026
- [Swift Student Challenge - Apple Developer](https://developer.apple.com/swift-student-challenge/)
- [Eligibility and Requirements](https://developer.apple.com/swift-student-challenge/eligibility/)
- [Get Ready Guide](https://developer.apple.com/swift-student-challenge/get-ready/)

---

## 14. Notas Adicionales

### Limite de 3 Minutos del Challenge

La experiencia completa debe caber en 3 minutos:
- Splash: 5 segundos (reducir animaciones actuales)
- Learn: 30-45 segundos (modo rapido con swipe entre fases)
- Simulacion (3 escenas minimo): 30s x 3 = 90 segundos
- Resultado: 15-20 segundos
- **Total: ~2.5 minutos** - dentro del limite

Si se incluyen 5 escenas:
- Cada escena debe ser 25-30 segundos max
- 5 x 30s = 150s + 30s otros = 180s = exactamente 3 minutos

### Accesibilidad Basica

- VoiceOver: las zonas de toque deben tener `accessibilityLabel`
- Dynamic Type: el texto contextual debe respetar tamanyos de fuente
- Contraste: las zonas seguras e inseguras deben diferenciarse por forma ademas de color
- Reducir movimiento: si `UIAccessibility.isReduceMotionEnabled`, reducir intensidad de animaciones

### Sin Imagenes Externas - Verificacion

Cada elemento visual se construye con:
- `Image(systemName:)` para SF Symbols
- `Rectangle`, `RoundedRectangle`, `Circle`, `Capsule`, `Ellipse` para shapes
- `Path` para formas custom (grietas, cables, detalles)
- `LinearGradient`, `RadialGradient` para fondos y texturas
- `Canvas` para rendering programatico

Esto garantiza:
- Zip pequenyo (solo codigo Swift)
- Compatible con App Playgrounds
- Sin dependencias externas
- Sin problemas de copyright

---

*Documento creado: 11 de Febrero 2026*
*Siguiente paso: Comenzar con Fase 1 - Infraestructura Base*
