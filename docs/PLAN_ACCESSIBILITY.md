# Plan de Accesibilidad Completa - EarthReady MX

## Resumen e Impacto en el Criterio de "Inclusivity"

El Swift Student Challenge evalua las submissions en 4 criterios principales: **Innovation, Creativity, Social Impact, e Inclusivity**. La accesibilidad mapea directamente al criterio de **Inclusivity**, que puede ser el factor diferenciador entre una submission aceptada y una Distinguished Winner.

Apple valora especialmente:
- **VoiceOver completo**: Que un usuario ciego pueda usar toda la app sin asistencia
- **Dynamic Type**: Que usuarios con baja vision puedan agrandar el texto
- **Reduce Motion**: Que usuarios con sensibilidad al movimiento tengan una experiencia sin mareo
- **Alto contraste**: Que la interfaz sea legible en todas las condiciones
- **Descripciones semanticas**: Que las visualizaciones complejas (sismografo, score ring, particulas) tengan sentido sin vision

La app actualmente tiene **CERO** modificadores de accesibilidad. Todo el contenido visual (sismografo animado, crack lines, particles, score ring animado) es completamente invisible para VoiceOver. Esto representa una brecha critica.

---

## Auditoria de Brechas de Accesibilidad por Vista

### 1. SplashView.swift

| Elemento | Brecha | Severidad |
|----------|--------|-----------|
| SeismographView (linea animada) | Sin label de accesibilidad, invisible para VoiceOver | CRITICA |
| CrackLines (grietas decorativas) | Sin `.accessibilityHidden(true)`, VoiceOver intentara leerlas | MEDIA |
| Globe icon con ShakeEffect | Sin descripcion, animacion sin alternativa Reduce Motion | ALTA |
| GlowEffect en circulo | Animacion perpetua sin respetar Reduce Motion | ALTA |
| PulseEffect en boton | Animacion perpetua sin respetar Reduce Motion | ALTA |
| StatBadge (12K+, 3 min, 70%) | Sin agrupacion semantica, labels truncados | ALTA |
| Boton "Start Learning" | Sin `.accessibilityHint` | MEDIA |
| Texto del terremoto 2017 | Sin `.accessibilityLabel` contextual | BAJA |
| Secuencia de animacion staggered | Sin alternativa para Reduce Motion | ALTA |
| Todos los textos | Fuentes con tamano fijo (`size: 42`, `size: 16`, etc.) | CRITICA |

### 2. LearnView.swift

| Elemento | Brecha | Severidad |
|----------|--------|-----------|
| Header "Safety Protocol" | Sin `.accessibilityAddTraits(.isHeader)` | ALTA |
| Phase selector (Before/During/After) | Sin `.accessibilityValue` para estado seleccionado | ALTA |
| TipCard expandible | Sin `.accessibilityHint("Double tap to expand")` | ALTA |
| TipCard expandida | Sin anuncio de cambio de estado | MEDIA |
| Chevron up/down en TipCard | Decorativo pero no marcado como hidden | BAJA |
| Progress indicators (checkmarks) | Sin `.accessibilityValue` para progreso | ALTA |
| Boton "Mark as Read" / "Completed" | Sin `.accessibilityValue` para estado actual | MEDIA |
| Boton "Test Yourself" | Sin `.accessibilityHint` | MEDIA |
| Animaciones spring en phase change | Sin alternativa Reduce Motion | MEDIA |
| Todos los textos | Fuentes con tamano fijo | CRITICA |

### 3. SimulationView.swift

| Elemento | Brecha | Severidad |
|----------|--------|-----------|
| Progress ring (1/5, 2/5...) | Sin `.accessibilityLabel` descriptivo | ALTA |
| Score counters (correct/wrong) | Sin agrupacion semantica | MEDIA |
| Scenario card | Sin `.accessibilityAddTraits(.isHeader)` | MEDIA |
| Option buttons | Sin `.accessibilityValue` para estado (correcto/incorrecto/seleccionado) | CRITICA |
| ShakeEffect en respuesta incorrecta | Sin alternativa Reduce Motion | ALTA |
| Intensidad de fondo rojo | Sin feedback no-visual para error | ALTA |
| Explanation card | Sin anuncio VoiceOver cuando aparece | ALTA |
| Boton "Next Scenario"/"See Results" | Sin `.accessibilityHint` | MEDIA |
| Compact scenario card | Sin contexto de que es la pregunta actual | MEDIA |
| Todos los textos | Fuentes con tamano fijo | CRITICA |

### 4. ResultView.swift

| Elemento | Brecha | Severidad |
|----------|--------|-----------|
| Score ring animado | Sin `.accessibilityLabel` con porcentaje | CRITICA |
| Score ring progress animation | Sin alternativa Reduce Motion | ALTA |
| ParticlesView (confeti 100%) | Sin `.accessibilityHidden(true)`, sin alternativa RM | ALTA |
| Mensaje de resultado | Sin anuncio VoiceOver al aparecer | MEDIA |
| Lista de responses | Sin agrupacion semantica por escenario | MEDIA |
| Takeaways section | Sin `.accessibilityAddTraits(.isHeader)` | MEDIA |
| Boton "Start Over" | Sin `.accessibilityHint` | BAJA |
| Animacion staggered de secciones | Sin alternativa Reduce Motion | ALTA |
| Animated score counter | Sin acceso al valor final inmediato | ALTA |
| Todos los textos | Fuentes con tamano fijo | CRITICA |

### 5. ShakeEffect.swift (Efectos globales)

| Elemento | Brecha | Severidad |
|----------|--------|-----------|
| PulseEffect | No respeta `accessibilityReduceMotion` | ALTA |
| GlowEffect | No respeta `accessibilityReduceMotion` | ALTA |
| ShakeEffect | No respeta `accessibilityReduceMotion` | ALTA |

### 6. ContentView.swift (Transiciones)

| Elemento | Brecha | Severidad |
|----------|--------|-----------|
| Transiciones entre fases | Sin alternativa Reduce Motion | MEDIA |

---

## Implementacion Detallada por Vista

### Paso 0: Crear AccessibilityHelper.swift (nuevo archivo utility)

Este archivo centraliza constantes y helpers para accesibilidad.

```swift
import SwiftUI

// MARK: - Accessibility Announcements

enum AccessibilityAnnouncement {
    static func announce(_ message: String) {
        UIAccessibility.post(
            notification: .announcement,
            argument: message
        )
    }

    static func announceScreenChange(_ message: String) {
        UIAccessibility.post(
            notification: .screenChanged,
            argument: message
        )
    }

    static func announceLayoutChange(_ message: String? = nil) {
        UIAccessibility.post(
            notification: .layoutChanged,
            argument: message
        )
    }
}

// MARK: - Reduce Motion Helper

struct ReduceMotionModifier: ViewModifier {
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    let animation: Animation
    let reducedAnimation: Animation

    func body(content: Content) -> some View {
        content.animation(reduceMotion ? reducedAnimation : animation)
    }
}

extension View {
    func adaptiveAnimation(
        _ animation: Animation,
        reducedTo reducedAnimation: Animation = .none
    ) -> some View {
        modifier(ReduceMotionModifier(
            animation: animation,
            reducedAnimation: reducedAnimation
        ))
    }
}
```

---

### Paso 1: ShakeEffect.swift - Efectos con soporte Reduce Motion

**Antes:**
```swift
struct PulseEffect: ViewModifier {
    @State private var isPulsing = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(isPulsing ? 1.05 : 1.0)
            .animation(
                .easeInOut(duration: 1.5).repeatForever(autoreverses: true),
                value: isPulsing
            )
            .onAppear { isPulsing = true }
    }
}
```

**Despues:**
```swift
struct PulseEffect: ViewModifier {
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State private var isPulsing = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(reduceMotion ? 1.0 : (isPulsing ? 1.05 : 1.0))
            .opacity(reduceMotion ? (isPulsing ? 1.0 : 0.85) : 1.0)
            .animation(
                reduceMotion
                    ? .easeInOut(duration: 2.0).repeatForever(autoreverses: true)
                    : .easeInOut(duration: 1.5).repeatForever(autoreverses: true),
                value: isPulsing
            )
            .onAppear { isPulsing = true }
    }
}
```

**Logica:** Con Reduce Motion activado, el pulso se reemplaza con un sutil cambio de opacidad en lugar de escala. El movimiento visual se elimina, pero la atencion visual se mantiene.

**GlowEffect - Despues:**
```swift
struct GlowEffect: ViewModifier {
    let color: Color
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State private var isGlowing = false

    func body(content: Content) -> some View {
        content
            .shadow(
                color: color.opacity(
                    reduceMotion
                        ? 0.4
                        : (isGlowing ? 0.6 : 0.2)
                ),
                radius: reduceMotion ? 10 : (isGlowing ? 15 : 5)
            )
            .animation(
                reduceMotion
                    ? nil
                    : .easeInOut(duration: 2).repeatForever(autoreverses: true),
                value: isGlowing
            )
            .onAppear {
                if !reduceMotion {
                    isGlowing = true
                }
            }
    }
}
```

**Logica:** Con Reduce Motion, el glow se fija en un valor medio constante. Sin animacion ciclica.

---

### Paso 2: SplashView.swift

#### 2.1 SeismographView - Descripcion accesible

**Antes:**
```swift
SeismographView(points: seismographPoints, isActive: isShaking)
    .frame(height: 80)
    .padding(.horizontal, 30)
```

**Despues:**
```swift
SeismographView(points: seismographPoints, isActive: isShaking)
    .frame(height: 80)
    .padding(.horizontal, 30)
    .accessibilityElement(children: .ignore)
    .accessibilityLabel(
        isShaking
            ? "Seismograph showing active earthquake waves"
            : "Seismograph showing calm readings"
    )
    .accessibilityAddTraits(.isImage)
```

#### 2.2 Globe icon con efecto

**Despues:**
```swift
ZStack {
    Circle()
        .fill(/* ... */)
        .frame(width: 160, height: 160)
        .glowEffect(color: .orange)
        .accessibilityHidden(true)

    Image(systemName: "globe.americas.fill")
        .font(.system(size: 70))
        .foregroundStyle(/* ... */)
        .modifier(ShakeEffect(animatableData: reduceMotion ? 0 : shakeAmount))
}
.accessibilityElement(children: .ignore)
.accessibilityLabel("EarthReady app icon, a globe representing the Americas")
.accessibilityAddTraits(.isImage)
```

#### 2.3 CrackLines - Ocultar de VoiceOver

```swift
ForEach(crackLines) { crack in
    CrackShape(points: crack.points)
        .stroke(Color.orange.opacity(0.3), lineWidth: 1.5)
        .ignoresSafeArea()
}
.accessibilityHidden(true)
```

#### 2.4 StatBadge - Agrupacion semantica

**Antes:**
```swift
HStack(spacing: 20) {
    StatBadge(value: "12K+", label: "earthquakes\nper year", icon: "waveform.path.ecg")
    StatBadge(value: "3 min", label: "to be\nprepared", icon: "clock.fill")
    StatBadge(value: "70%", label: "survival\nincrease", icon: "heart.fill")
}
```

**Despues (en StatBadge):**
```swift
struct StatBadge: View {
    let value: String
    let label: String
    let icon: String
    @State private var isExpanded = false

    // Propiedad computada para VoiceOver
    private var accessibilityDescription: String {
        let cleanLabel = label.replacingOccurrences(of: "\n", with: " ")
        return "\(value) \(cleanLabel)"
    }

    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                isExpanded.toggle()
            }
        }) {
            VStack(spacing: 4) { /* ... contenido existente ... */ }
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityDescription)
        .accessibilityHint("Double tap to \(isExpanded ? "collapse" : "expand") details")
        .accessibilityAddTraits(.isButton)
    }
}
```

**VoiceOver leera:** "12K plus earthquakes per year. Double tap to expand details."

#### 2.5 Boton Start Learning

**Despues:**
```swift
Button(action: { /* ... */ }) {
    HStack(spacing: 12) { /* ... */ }
}
.padding(.horizontal, 40)
.pulseEffect()
.transition(.move(edge: .bottom).combined(with: .opacity))
.accessibilityLabel("Start Learning")
.accessibilityHint("Double tap to begin learning earthquake safety protocols")
```

#### 2.6 Texto historico 2017

```swift
Text("In 2017, a 7.1 magnitude earthquake struck Mexico City.\n250+ lives were lost. Preparedness makes the difference.")
    .font(.system(size: 14, weight: .regular, design: .rounded))
    .foregroundColor(.gray.opacity(0.8))
    .multilineTextAlignment(.center)
    .padding(.horizontal, 40)
    .transition(.opacity)
    .accessibilityLabel(
        "In 2017, a 7.1 magnitude earthquake struck Mexico City. "
        + "More than 250 lives were lost. Preparedness makes the difference."
    )
```

#### 2.7 Secuencia de animacion con Reduce Motion

**Antes (en startAnimationSequence):**
```swift
private func startAnimationSequence() {
    startSeismograph()
    withAnimation(.easeInOut(duration: 0.8)) {
        shakeAmount = 6
        isShaking = true
    }
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { generateCracks() }
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) { showTitle = true }
    }
    // ... mas delays
}
```

**Despues:**
```swift
@Environment(\.accessibilityReduceMotion) var reduceMotion

private func startAnimationSequence() {
    if reduceMotion {
        // Mostrar todo inmediatamente sin animaciones
        showTitle = true
        showStats = true
        showSubtitle = true
        showButton = true
        startSeismograph()
        AccessibilityAnnouncement.announceScreenChange(
            "EarthReady. Earthquake preparedness app. Tap Start Learning to begin."
        )
        return
    }

    // Secuencia animada original
    startSeismograph()
    withAnimation(.easeInOut(duration: 0.8)) {
        shakeAmount = 6
        isShaking = true
    }
    // ... resto de la secuencia original
}
```

**Logica:** Con Reduce Motion activo, todo el contenido aparece inmediatamente sin staggering. Se anuncia la pantalla para VoiceOver.

---

### Paso 3: LearnView.swift

#### 3.1 Header con trait de encabezado

**Despues:**
```swift
private var headerSection: some View {
    HStack {
        VStack(alignment: .leading, spacing: 4) {
            Text("Safety Protocol")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .accessibilityAddTraits(.isHeader)
            Text("Tap each card to learn more")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(.gray)
        }
        Spacer()
        Image(systemName: "shield.lefthalf.filled")
            .font(.system(size: 30))
            .foregroundColor(.orange)
            .accessibilityHidden(true)
    }
    .padding(.horizontal, 20)
    .padding(.top, 16)
}
```

#### 3.2 Phase selector con valor de accesibilidad

**Despues (cada boton del selector):**
```swift
Button(action: {
    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
        selectedPhase = phase
        expandedTipId = nil
    }
    AccessibilityAnnouncement.announce("Selected \(phase.rawValue) phase")
}) {
    HStack(spacing: 6) {
        Image(systemName: iconFor(phase: phase))
            .font(.caption)
        Text(phase.rawValue)
            .font(.system(size: 14, weight: .semibold, design: .rounded))
    }
    // ... estilos existentes
}
.accessibilityLabel("\(phase.rawValue) phase")
.accessibilityValue(selectedPhase == phase ? "Selected" : "Not selected")
.accessibilityHint("Double tap to view \(phase.rawValue.lowercased()) earthquake tips")
.accessibilityAddTraits(selectedPhase == phase ? [.isSelected] : [])
```

#### 3.3 TipCard con accesibilidad completa

**Despues:**
```swift
struct TipCard: View {
    let tip: SafetyTip
    let isExpanded: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: {
            onTap()
            AccessibilityAnnouncement.announce(
                isExpanded ? "Collapsed \(tip.title)" : "Expanded \(tip.title)"
            )
        }) {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(colorFor(phase: tip.phase).opacity(0.15))
                            .frame(width: 44, height: 44)
                        Image(systemName: tip.icon)
                            .font(.system(size: 18))
                            .foregroundColor(colorFor(phase: tip.phase))
                    }
                    .accessibilityHidden(true)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(tip.title)
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                        if !isExpanded {
                            Text(tip.description.prefix(50) + "...")
                                .font(.system(size: 12, weight: .regular))
                                .foregroundColor(.gray)
                                .lineLimit(1)
                        }
                    }

                    Spacer()

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .accessibilityHidden(true)
                }
                .padding(16)

                if isExpanded {
                    Text(tip.description)
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(.white.opacity(0.85))
                        .padding(.horizontal, 16)
                        .padding(.bottom, 16)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            // ... estilos existentes
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(tip.title)
        .accessibilityValue(isExpanded ? tip.description : "Collapsed")
        .accessibilityHint(isExpanded ? "Double tap to collapse" : "Double tap to expand and read full tip")
        .accessibilityAddTraits(.isButton)
    }
}
```

**VoiceOver leera (colapsada):** "Emergency Kit. Collapsed. Double tap to expand and read full tip."
**VoiceOver leera (expandida):** "Emergency Kit. Prepare a kit with water, food... Double tap to collapse."

#### 3.4 Progress indicators en bottomSection

```swift
HStack(spacing: 8) {
    ForEach(EarthquakePhase.allCases, id: \.self) { phase in
        HStack(spacing: 4) {
            Image(systemName: gameState.learnPhasesCompleted.contains(phase)
                  ? "checkmark.circle.fill" : "circle")
                .font(.caption)
                .foregroundColor(gameState.learnPhasesCompleted.contains(phase) ? .green : .gray)
            Text(phase.rawValue)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(gameState.learnPhasesCompleted.contains(phase) ? .green : .gray)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            "\(phase.rawValue) phase: \(gameState.learnPhasesCompleted.contains(phase) ? "completed" : "not completed")"
        )
    }
    Spacer()
}
```

#### 3.5 Boton "Mark as Read" con estado

```swift
Button(action: { /* ... existente ... */ }) {
    HStack(spacing: 8) { /* ... existente ... */ }
}
.accessibilityLabel(
    gameState.learnPhasesCompleted.contains(selectedPhase)
        ? "\(selectedPhase.rawValue) phase completed"
        : "Mark \(selectedPhase.rawValue) phase as read"
)
.accessibilityHint(
    gameState.learnPhasesCompleted.contains(selectedPhase)
        ? "Already completed"
        : "Double tap to mark this phase as read"
)
```

#### 3.6 Boton "Test Yourself"

```swift
Button(action: { /* ... */ }) {
    HStack(spacing: 8) { /* ... */ }
}
.accessibilityLabel("Test Yourself")
.accessibilityHint("Double tap to start the earthquake simulation quiz")
```

---

### Paso 4: SimulationView.swift

#### 4.1 Progress ring accesible

**Despues:**
```swift
ZStack {
    // ... circulos existentes ...
    Text("\(currentIndex + 1)/\(gameState.scenarios.count)")
        .font(.system(size: 12, weight: .bold, design: .rounded))
        .foregroundColor(.white)
}
.accessibilityElement(children: .ignore)
.accessibilityLabel("Question \(currentIndex + 1) of \(gameState.scenarios.count)")
.accessibilityAddTraits(.updatesFrequently)
```

#### 4.2 Score counters agrupados

```swift
HStack(spacing: 16) {
    Label("\(gameState.score) correct", systemImage: "checkmark.circle.fill")
        .font(.system(size: 12, weight: .medium, design: .rounded))
        .foregroundColor(.green)
    Label("\(gameState.totalQuestions - gameState.score) wrong", systemImage: "xmark.circle.fill")
        .font(.system(size: 12, weight: .medium, design: .rounded))
        .foregroundColor(.red.opacity(0.7))
    Spacer()
}
.accessibilityElement(children: .ignore)
.accessibilityLabel(
    "\(gameState.score) correct answers, \(gameState.totalQuestions - gameState.score) wrong answers"
)
```

#### 4.3 Scenario card

**Despues:**
```swift
private func scenarioCard(_ scenario: SimulationScenario) -> some View {
    VStack(spacing: 12) {
        Image(systemName: "exclamationmark.triangle.fill")
            .font(.system(size: 36))
            .foregroundStyle(/* ... */)
            .accessibilityHidden(true)
        Text(scenario.situation)
            .font(.system(size: 17, weight: .semibold, design: .rounded))
            .foregroundColor(.white)
            .multilineTextAlignment(.center)
            .lineSpacing(4)
    }
    .padding(24)
    .frame(maxWidth: .infinity)
    .background(/* ... */)
    .accessibilityElement(children: .ignore)
    .accessibilityLabel("Scenario: \(scenario.situation)")
    .accessibilityAddTraits(.isHeader)
}
```

#### 4.4 Option buttons con estado completo

**Despues:**
```swift
private func optionButton(_ option: SimulationOption, scenario: SimulationScenario) -> some View {
    Button(action: {
        guard selectedOption == nil else { return }
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            selectedOption = option
            showExplanation = true
            gameState.answerScenario(scenario, correct: option.isCorrect)
        }
        // Anuncio de accesibilidad
        if option.isCorrect {
            AccessibilityAnnouncement.announce("Correct! \(scenario.explanation)")
        } else {
            AccessibilityAnnouncement.announce(
                "Incorrect. The correct answer was shown. \(scenario.explanation)"
            )
        }
        if !option.isCorrect {
            if !reduceMotion {
                withAnimation(.easeInOut(duration: 0.5)) {
                    shakeAmount = 3
                    intensity = 0.5
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation { intensity = 0 }
                }
            }
        }
    }) {
        HStack(spacing: 12) { /* ... contenido existente ... */ }
    }
    .buttonStyle(.plain)
    .disabled(selectedOption != nil)
    .accessibilityLabel(option.text)
    .accessibilityValue(accessibilityValueFor(option))
    .accessibilityHint(selectedOption == nil ? "Double tap to select this answer" : "")
    .accessibilityRemoveTraits(selectedOption != nil ? .isButton : [])
}

private func accessibilityValueFor(_ option: SimulationOption) -> String {
    guard let selected = selectedOption else { return "" }
    if option.id == selected.id {
        return option.isCorrect ? "Your answer, correct" : "Your answer, incorrect"
    }
    if option.isCorrect {
        return "Correct answer"
    }
    return ""
}
```

#### 4.5 Explanation card con anuncio

```swift
private func explanationCard(_ scenario: SimulationScenario) -> some View {
    VStack(alignment: .leading, spacing: 10) {
        HStack(spacing: 8) {
            Image(systemName: "lightbulb.fill")
                .foregroundColor(.yellow)
                .accessibilityHidden(true)
            Text("Why?")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .accessibilityAddTraits(.isHeader)
        }
        Text(scenario.explanation)
            .font(.system(size: 14, weight: .regular, design: .rounded))
            .foregroundColor(.white.opacity(0.85))
            .lineSpacing(3)
    }
    .padding(16)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(/* ... */)
    .accessibilityElement(children: .combine)
    .accessibilityLabel("Explanation: \(scenario.explanation)")
}
```

#### 4.6 Continue button

```swift
private var continueButton: some View {
    Button(action: { /* ... existente ... */ }) {
        HStack(spacing: 8) { /* ... */ }
    }
    .accessibilityLabel(
        currentIndex + 1 < gameState.scenarios.count
            ? "Next Scenario"
            : "See Results"
    )
    .accessibilityHint(
        currentIndex + 1 < gameState.scenarios.count
            ? "Double tap to go to scenario \(currentIndex + 2) of \(gameState.scenarios.count)"
            : "Double tap to view your final score"
    )
}
```

#### 4.7 Reduce Motion en ShakeEffect del scenario

Agregar `@Environment(\.accessibilityReduceMotion) var reduceMotion` al `SimulationView` y condicionar:

```swift
.modifier(ShakeEffect(
    amount: (!reduceMotion && selectedOption != nil && selectedOption?.isCorrect == false) ? 8 : 0,
    animatableData: reduceMotion ? 0 : shakeAmount
))
```

---

### Paso 5: ResultView.swift

#### 5.1 Score ring accesible

**Despues:**
```swift
private var scoreRing: some View {
    ZStack {
        Circle()
            .stroke(Color.white.opacity(0.08), lineWidth: 12)
        Circle()
            .trim(from: 0, to: ringProgress)
            .stroke(/* ... */)
            .rotationEffect(.degrees(-90))
        VStack(spacing: 4) {
            Text("\(Int(animatedScore))%")
                .font(.system(size: 48, weight: .black, design: .rounded))
                .foregroundColor(.white)
            Text("\(gameState.score)/\(gameState.totalQuestions)")
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(.gray)
        }
    }
    .frame(width: 200, height: 200)
    .padding(10)
    .accessibilityElement(children: .ignore)
    .accessibilityLabel(
        "Score: \(Int(gameState.scorePercentage)) percent. "
        + "\(gameState.score) out of \(gameState.totalQuestions) correct."
    )
    .accessibilityAddTraits(.isImage)
}
```

**Nota:** El label usa `gameState.scorePercentage` directamente (no `animatedScore`) para que VoiceOver diga el resultado real inmediatamente, sin esperar la animacion.

#### 5.2 ParticlesView - Ocultar y describir

**Despues:**
```swift
if gameState.scorePercentage == 100 {
    ParticlesView()
        .ignoresSafeArea()
        .accessibilityHidden(true)
}
```

Y ademas, si Reduce Motion esta activo, no mostrar particulas:

```swift
if gameState.scorePercentage == 100 && !reduceMotion {
    ParticlesView()
        .ignoresSafeArea()
        .accessibilityHidden(true)
}
```

Si se quiere una alternativa visual con Reduce Motion:

```swift
if gameState.scorePercentage == 100 {
    if reduceMotion {
        // Alternativa estatica: borde dorado brillante
        RoundedRectangle(cornerRadius: 0)
            .stroke(
                LinearGradient(
                    colors: [.orange, .yellow, .green],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: 4
            )
            .ignoresSafeArea()
            .accessibilityHidden(true)
    } else {
        ParticlesView()
            .ignoresSafeArea()
            .accessibilityHidden(true)
    }
}
```

#### 5.3 Message section con anuncio

```swift
private var messageSection: some View {
    VStack(spacing: 8) {
        Text(scoreTitle)
            .font(.system(size: 26, weight: .bold, design: .rounded))
            .foregroundColor(scoreColors.first ?? .white)
            .accessibilityAddTraits(.isHeader)
        Text(gameState.scoreMessage)
            .font(.system(size: 15, weight: .regular, design: .rounded))
            .foregroundColor(.gray)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 40)
    }
    .accessibilityElement(children: .combine)
}
```

#### 5.4 Responses section con agrupacion

```swift
ForEach(Array(gameState.scenarios.enumerated()), id: \.element.id) { index, scenario in
    let wasCorrect = gameState.answeredScenarios[scenario.id] ?? false
    HStack(spacing: 12) { /* ... existente ... */ }
    .padding(14)
    .background(/* ... */)
    .clipShape(RoundedRectangle(cornerRadius: 12))
    .accessibilityElement(children: .ignore)
    .accessibilityLabel(
        "Scenario \(index + 1): \(wasCorrect ? "Correct" : "Incorrect"). "
        + String(scenario.situation.prefix(80))
    )
    .accessibilityValue(wasCorrect ? "You answered correctly" : "You answered incorrectly")
}
```

#### 5.5 Takeaway items

```swift
private func takeawayItem(icon: String, color: Color, title: String, text: String) -> some View {
    HStack(spacing: 14) { /* ... existente ... */ }
    .padding(14)
    .background(Color.white.opacity(0.04))
    .clipShape(RoundedRectangle(cornerRadius: 12))
    .accessibilityElement(children: .ignore)
    .accessibilityLabel("\(title). \(text)")
}
```

#### 5.6 Takeaways header

```swift
Text("Key Takeaways")
    .font(.system(size: 18, weight: .bold, design: .rounded))
    .foregroundColor(.white)
    .frame(maxWidth: .infinity, alignment: .leading)
    .accessibilityAddTraits(.isHeader)
```

#### 5.7 Start Over button

```swift
Button(action: { /* ... */ }) {
    HStack(spacing: 8) { /* ... */ }
}
.accessibilityLabel("Start Over")
.accessibilityHint("Double tap to restart the entire learning experience from the beginning")
```

#### 5.8 Animacion staggered con Reduce Motion

**Despues:**
```swift
@Environment(\.accessibilityReduceMotion) var reduceMotion

private func startAnimationSequence() {
    if reduceMotion {
        showScore = true
        animatedScore = gameState.scorePercentage
        ringProgress = gameState.scorePercentage / 100
        showMessage = true
        showDetails = true
        showActions = true
        AccessibilityAnnouncement.announceScreenChange(
            "Results. Score: \(Int(gameState.scorePercentage)) percent. "
            + "\(gameState.score) out of \(gameState.totalQuestions) correct. "
            + scoreTitle
        )
        return
    }

    // ... secuencia animada original existente ...
}
```

---

### Paso 6: ContentView.swift - Transiciones con Reduce Motion

**Despues:**
```swift
struct ContentView: View {
    @EnvironmentObject var gameState: GameState
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            switch gameState.currentPhase {
            case .splash:
                SplashView()
                    .transition(reduceMotion ? .opacity : .opacity.combined(with: .scale))
            case .learn:
                LearnView()
                    .transition(reduceMotion
                        ? .opacity
                        : .asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
            case .simulation:
                SimulationView()
                    .transition(reduceMotion
                        ? .opacity
                        : .asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
            case .result:
                ResultView()
                    .transition(reduceMotion
                        ? .opacity
                        : .asymmetric(
                            insertion: .scale.combined(with: .opacity),
                            removal: .opacity
                        ))
            }
        }
        .animation(
            reduceMotion ? .easeInOut(duration: 0.3) : .easeInOut(duration: 0.6),
            value: gameState.currentPhase
        )
    }
}
```

---

## Estrategia de Dynamic Type

### Problema actual

Todos los textos usan tamanos fijos con `.font(.system(size: XX, ...))`. Esto significa que si un usuario tiene Dynamic Type configurado en "Extra Large" o superior, los textos de la app no se ajustan.

### Solucion propuesta

Crear un sistema de fuentes adaptativas que use los estilos de texto de sistema como base pero mantenga el diseno visual:

```swift
// MARK: - Adaptive Font Extension

extension Font {
    /// Fuente principal para titulos grandes (reemplaza size: 42)
    static var adaptiveLargeTitle: Font {
        .system(.largeTitle, design: .rounded).weight(.black)
    }

    /// Fuente para titulos de seccion (reemplaza size: 28)
    static var adaptiveTitle: Font {
        .system(.title2, design: .rounded).weight(.bold)
    }

    /// Fuente para titulos de simulacion (reemplaza size: 24)
    static var adaptiveTitle3: Font {
        .system(.title3, design: .rounded).weight(.bold)
    }

    /// Fuente para textos del body (reemplaza size: 17)
    static var adaptiveBody: Font {
        .system(.body, design: .rounded).weight(.semibold)
    }

    /// Fuente para subtitulos (reemplaza size: 15-16)
    static var adaptiveSubheadline: Font {
        .system(.subheadline, design: .rounded).weight(.medium)
    }

    /// Fuente para textos secundarios (reemplaza size: 14)
    static var adaptiveFootnote: Font {
        .system(.footnote, design: .rounded).weight(.regular)
    }

    /// Fuente para textos muy pequenos (reemplaza size: 12)
    static var adaptiveCaption: Font {
        .system(.caption, design: .rounded).weight(.medium)
    }

    /// Fuente para textos mas pequenos (reemplaza size: 9-11)
    static var adaptiveCaption2: Font {
        .system(.caption2, design: .rounded).weight(.medium)
    }

    /// Fuente para porcentaje del score (reemplaza size: 48)
    static func adaptiveScoreDisplay(size: CGFloat) -> Font {
        .system(size: size, weight: .black, design: .rounded)
    }

    /// Fuente para botones (reemplaza size: 18)
    static var adaptiveButton: Font {
        .system(.body, design: .rounded).weight(.bold)
    }

    /// Fuente para labels de botones pequenos (reemplaza size: 14)
    static var adaptiveSmallButton: Font {
        .system(.subheadline, design: .rounded).weight(.semibold)
    }
}
```

### Tabla de reemplazo de fuentes

| Uso actual | Archivo | Reemplazo |
|------------|---------|-----------|
| `.system(size: 42, weight: .black, design: .rounded)` | SplashView (titulo) | `.adaptiveLargeTitle` |
| `.system(size: 28, weight: .bold, design: .rounded)` | LearnView (header) | `.adaptiveTitle` |
| `.system(size: 26, weight: .bold, design: .rounded)` | ResultView (score title) | `.adaptiveTitle` |
| `.system(size: 24, weight: .bold, design: .rounded)` | SimulationView (header) | `.adaptiveTitle3` |
| `.system(size: 18, weight: .bold, design: .rounded)` | SplashView (boton), LearnView (headers section) | `.adaptiveButton` |
| `.system(size: 17, weight: .semibold, design: .rounded)` | SimulationView (scenario text) | `.adaptiveBody` |
| `.system(size: 16, weight: .bold, design: .rounded)` | SplashView (stat value), ResultView (boton), SimulationView (continue) | `.adaptiveSubheadline` con `.weight(.bold)` |
| `.system(size: 16, weight: .semibold, design: .rounded)` | TipCard (titulo), ExplanationCard (Why?) | `.adaptiveSubheadline` |
| `.system(size: 16, weight: .medium, design: .rounded)` | SplashView (subtitulo), ResultView (score fraction) | `.adaptiveSubheadline` |
| `.system(size: 15, weight: .medium, design: .rounded)` | SimulationView (option text) | `.adaptiveSubheadline` |
| `.system(size: 15, weight: .regular, design: .rounded)` | ResultView (score message) | `.adaptiveFootnote` |
| `.system(size: 14, weight: .semibold, design: .rounded)` | LearnView (botones, phase selector) | `.adaptiveSmallButton` |
| `.system(size: 14, weight: .regular, design: .rounded)` | SplashView (texto 2017), TipCard (descripcion), SimulationView (explanation), LearnView (subtitle) | `.adaptiveFootnote` |
| `.system(size: 14, weight: .medium, design: .rounded)` | SimulationView (subtitle) | `.adaptiveFootnote` |
| `.system(size: 13, weight: .medium, design: .rounded)` | ResultView (share text) | `.adaptiveCaption` |
| `.system(size: 12, weight: .bold, design: .rounded)` | SimulationView (progress number) | `.adaptiveCaption` |
| `.system(size: 12, weight: .medium)` | LearnView (progress labels), SimulationView (score labels), TipCard preview | `.adaptiveCaption` |
| `.system(size: 12, weight: .regular)` | TipCard (preview desc), ResultView (scenario desc) | `.adaptiveCaption` |
| `.system(size: 11, weight: .medium)` | StatBadge (label expandido) | `.adaptiveCaption2` |
| `.system(size: 9, weight: .medium)` | StatBadge (label colapsado) | `.adaptiveCaption2` |
| `.system(size: 48, weight: .black, design: .rounded)` | ResultView (porcentaje) | `.adaptiveScoreDisplay(size: 48)` (mantener fijo, no es texto de lectura) |

### Nota sobre el tamano del score

El porcentaje en el score ring (`48pt`) puede mantenerse fijo porque:
1. Es un numero grande decorativo, no contenido textual
2. La informacion ya esta disponible via VoiceOver con el label accesible
3. Agrandarlo con Dynamic Type romperia el layout del ring

Sin embargo, se puede usar `@ScaledMetric` para adaptarlo proporcionalmente:

```swift
@ScaledMetric(relativeTo: .largeTitle) private var scoreFontSize: CGFloat = 48
```

### Layout adaptativo para Dynamic Type grande

Cuando `dynamicTypeSize.isAccessibilitySize` es `true`, algunos layouts deben cambiar de horizontal a vertical:

```swift
@Environment(\.dynamicTypeSize) var dynamicTypeSize

// En StatBadge area de SplashView:
if dynamicTypeSize.isAccessibilitySize {
    VStack(spacing: 12) {
        StatBadge(value: "12K+", label: "earthquakes per year", icon: "waveform.path.ecg")
        StatBadge(value: "3 min", label: "to be prepared", icon: "clock.fill")
        StatBadge(value: "70%", label: "survival increase", icon: "heart.fill")
    }
} else {
    HStack(spacing: 20) {
        StatBadge(value: "12K+", label: "earthquakes\nper year", icon: "waveform.path.ecg")
        StatBadge(value: "3 min", label: "to be\nprepared", icon: "clock.fill")
        StatBadge(value: "70%", label: "survival\nincrease", icon: "heart.fill")
    }
}
```

---

## Soporte de Alto Contraste

### Problema actual

La app usa muchos valores de opacidad bajos (`.opacity(0.06)`, `.opacity(0.08)`, `.opacity(0.04)`) para fondos de tarjetas y bordes. Esto puede ser invisible en modo de alto contraste.

### Solucion

```swift
@Environment(\.colorSchemeContrast) var contrast

// Ejemplo: fondo de TipCard
.background(
    Color.white.opacity(contrast == .increased ? 0.15 : 0.06)
)
.overlay(
    RoundedRectangle(cornerRadius: 16)
        .stroke(
            isExpanded
                ? colorFor(phase: tip.phase).opacity(contrast == .increased ? 0.6 : 0.3)
                : Color.white.opacity(contrast == .increased ? 0.2 : 0.08),
            lineWidth: contrast == .increased ? 2 : 1
        )
)
```

### Tabla de ajustes de contraste

| Valor original | Uso | Valor alto contraste |
|---------------|-----|---------------------|
| `Color.white.opacity(0.04)` | Fondo takeaway items | `Color.white.opacity(0.12)` |
| `Color.white.opacity(0.05)` | StatBadge fondo | `Color.white.opacity(0.15)` |
| `Color.white.opacity(0.06)` | TipCard fondo, option button fondo, scenario card | `Color.white.opacity(0.15)` |
| `Color.white.opacity(0.08)` | Phase selector no-seleccionado, bordes | `Color.white.opacity(0.20)` |
| `Color.white.opacity(0.1)` | Bordes circulares | `Color.white.opacity(0.25)` |
| `Color.gray` para texto secundario | Subtitulos, hints | `Color.gray` con `.opacity(1.0)` |
| `Color.gray.opacity(0.8)` | Texto 2017 | `Color.white.opacity(0.7)` |
| `Color.white.opacity(0.7)` | Phase selector no-seleccionado texto | `Color.white.opacity(0.9)` |
| `lineWidth: 1` | Bordes | `lineWidth: 2` |
| `Color.orange.opacity(0.3)` | Bordes activos | `Color.orange.opacity(0.6)` |

### Helper para contraste

```swift
extension Color {
    func contrastAdapted(
        normal: Double,
        increased: Double,
        contrast: ColorSchemeContrast
    ) -> Color {
        self.opacity(contrast == .increased ? increased : normal)
    }
}
```

---

## Acciones de Accesibilidad para Interacciones Custom

### TipCard - Accion de expand/collapse

```swift
.accessibilityAction(named: isExpanded ? "Collapse tip" : "Expand tip") {
    onTap()
}
```

### StatBadge - Accion de expand

```swift
.accessibilityAction(named: isExpanded ? "Show less" : "Show more") {
    withAnimation { isExpanded.toggle() }
}
```

### Phase selector - Acciones de navegacion

```swift
// Agregar al phaseSelector completo:
.accessibilityElement(children: .contain)
.accessibilityAction(named: "Next phase") {
    if let currentIdx = EarthquakePhase.allCases.firstIndex(of: selectedPhase),
       currentIdx + 1 < EarthquakePhase.allCases.count {
        selectedPhase = EarthquakePhase.allCases[currentIdx + 1]
    }
}
.accessibilityAction(named: "Previous phase") {
    if let currentIdx = EarthquakePhase.allCases.firstIndex(of: selectedPhase),
       currentIdx > 0 {
        selectedPhase = EarthquakePhase.allCases[currentIdx - 1]
    }
}
```

---

## Notificaciones de Accesibilidad para Cambios de Estado

### Resumen de todos los anuncios necesarios

| Evento | Tipo de notificacion | Mensaje |
|--------|---------------------|---------|
| App aparece en SplashView | `.screenChanged` | "EarthReady. Earthquake preparedness app." |
| Navegar a LearnView | `.screenChanged` | "Safety Protocol. Learn earthquake phases." |
| Cambiar fase (Before/During/After) | `.announcement` | "Selected [Phase] phase" |
| Expandir TipCard | `.announcement` | "Expanded [TipTitle]" (invertido para collapse) |
| Marcar fase como leida | `.announcement` | "[Phase] phase marked as completed" |
| Todas las fases completas | `.announcement` | "All phases completed. Test Yourself button available." |
| Navegar a SimulationView | `.screenChanged` | "Emergency Simulation. Question 1 of 5." |
| Seleccionar respuesta correcta | `.announcement` | "Correct! [Explanation]" |
| Seleccionar respuesta incorrecta | `.announcement` | "Incorrect. [Explanation]" |
| Siguiente escenario | `.layoutChanged` | "Question [N] of [Total]" |
| Navegar a ResultView | `.screenChanged` | "Results. Score: [X]%. [Title]." |
| Tap Start Over | `.screenChanged` | "Starting over. Welcome back to EarthReady." |

### Implementacion en GameState o en cada View

Se recomienda hacer los anuncios de `.screenChanged` cuando `currentPhase` cambia. Se puede hacer con `.onChange`:

```swift
// En ContentView:
.onChange(of: gameState.currentPhase) { _, newPhase in
    switch newPhase {
    case .splash:
        AccessibilityAnnouncement.announceScreenChange(
            "EarthReady. Earthquake preparedness app."
        )
    case .learn:
        AccessibilityAnnouncement.announceScreenChange(
            "Safety Protocol. Learn what to do before, during, and after an earthquake."
        )
    case .simulation:
        AccessibilityAnnouncement.announceScreenChange(
            "Emergency Simulation. Test your earthquake knowledge."
        )
    case .result:
        // El anuncio se hace en ResultView despues de calcular el score
        break
    }
}
```

---

## Estrategia de Testing

### 1. Testing con VoiceOver (Manual)

Realizar un walkthrough completo de la app con VoiceOver activado:

#### SplashView Walkthrough
- [ ] VoiceOver anuncia "EarthReady. Earthquake preparedness app." al entrar
- [ ] El sismografo se lee como "Seismograph showing active earthquake waves"
- [ ] El globe se lee como "EarthReady app icon..."
- [ ] Las crack lines NO se leen
- [ ] Cada StatBadge se lee como "12K plus earthquakes per year" (etc.)
- [ ] El boton se lee como "Start Learning. Button. Double tap to begin..."
- [ ] El texto de 2017 se lee completo sin el "250+"

#### LearnView Walkthrough
- [ ] "Safety Protocol" se identifica como header
- [ ] Cada tab del phase selector indica si esta seleccionado
- [ ] Cada TipCard se lee con titulo y estado (collapsed/expanded)
- [ ] Al expandir, VoiceOver anuncia el cambio
- [ ] El chevron NO se lee por separado
- [ ] Los progress indicators dicen "Before phase: completed"
- [ ] "Mark as Read" indica el estado correcto
- [ ] "Test Yourself" aparece con hint correcto al completar todo

#### SimulationView Walkthrough
- [ ] "Question 1 of 5" se lee correctamente
- [ ] El score counter se lee como texto combinado
- [ ] El escenario se lee como header con "Scenario: [texto]"
- [ ] Cada opcion se lee con su texto
- [ ] Al seleccionar, VoiceOver anuncia "Correct!" o "Incorrect"
- [ ] Las opciones deshabilitadas ya no tienen trait de boton
- [ ] La explicacion se lee como bloque combinado
- [ ] "Next Scenario" tiene hint con numero

#### ResultView Walkthrough
- [ ] El score ring se lee como "Score: [X] percent. [N] out of [M] correct."
- [ ] Las particulas NO se leen
- [ ] El scoreTitle se identifica como header
- [ ] Cada respuesta se lee con estado correcto/incorrecto
- [ ] Los takeaways se leen como titulo + descripcion
- [ ] "Start Over" tiene hint adecuado

### 2. Testing con Reduce Motion (Manual)

- [ ] Activar Settings > Accessibility > Motion > Reduce Motion
- [ ] SplashView: Todo aparece inmediatamente sin stagger
- [ ] SplashView: Globe no tiene shake animation
- [ ] SplashView: Boton no tiene pulse animation (usa opacity alternativa)
- [ ] SplashView: Glow esta fijo
- [ ] LearnView: Transiciones de fase son instantaneas
- [ ] SimulationView: No hay shake en respuesta incorrecta
- [ ] SimulationView: No hay flash rojo de intensidad
- [ ] ResultView: Score aparece inmediato sin animacion de ring
- [ ] ResultView: Score number muestra valor final directamente
- [ ] ResultView: No hay particulas (alternativa estatica)
- [ ] ContentView: Transiciones entre vistas son solo opacity

### 3. Testing con Dynamic Type (Manual)

- [ ] Configurar Settings > Display > Text Size > al maximo
- [ ] Verificar que ningun texto se corta
- [ ] Verificar que StatBadges cambian a layout vertical
- [ ] Verificar que los botones son lo suficientemente grandes para tocar
- [ ] Verificar con Accessibility Text Sizes (aun mas grandes)

### 4. Testing con Increased Contrast (Manual)

- [ ] Activar Settings > Accessibility > Display > Increase Contrast
- [ ] Verificar que los fondos de tarjetas son visibles
- [ ] Verificar que los bordes son distinguibles
- [ ] Verificar que el texto gris es legible
- [ ] Verificar que los estados selected/unselected son claros

### 5. Accessibility Audit en Xcode

```
Xcode > Open Developer Tool > Accessibility Inspector
```

- [ ] Correr audit automatizado en cada pantalla
- [ ] Verificar que no hay warnings de contraste
- [ ] Verificar que todos los elementos interactivos tienen labels
- [ ] Verificar que no hay elementos sin descripcion

### 6. Unit Tests de Accesibilidad (Opcionales pero recomendados)

```swift
import XCTest
@testable import AppModule

final class AccessibilityTests: XCTestCase {

    func testStatBadgeAccessibilityLabel() {
        // Verificar que el label se genera correctamente
        let badge = StatBadge(value: "12K+", label: "earthquakes\nper year", icon: "waveform.path.ecg")
        // El label deberia ser "12K+ earthquakes per year"
        let expected = "12K+ earthquakes per year"
        let cleanLabel = "earthquakes\nper year".replacingOccurrences(of: "\n", with: " ")
        XCTAssertEqual("12K+ \(cleanLabel)", expected)
    }

    func testScoreAccessibilityLabel() {
        let gameState = GameState()
        gameState.score = 4
        gameState.totalQuestions = 5
        let expected = "Score: 80 percent. 4 out of 5 correct."
        XCTAssertEqual(
            "Score: \(Int(gameState.scorePercentage)) percent. \(gameState.score) out of \(gameState.totalQuestions) correct.",
            expected
        )
    }
}
```

---

## Estimacion de Esfuerzo

| Tarea | Archivos | Tiempo estimado |
|-------|----------|----------------|
| Crear AccessibilityHelper.swift | 1 nuevo | 15 min |
| Crear Font extension (Dynamic Type) | 1 nuevo | 20 min |
| Modificar ShakeEffect.swift (Reduce Motion) | 1 existente | 20 min |
| Modificar SplashView.swift (VoiceOver + RM + DT + Contrast) | 1 existente | 45 min |
| Modificar LearnView.swift (VoiceOver + RM + DT + Contrast) | 1 existente | 45 min |
| Modificar SimulationView.swift (VoiceOver + RM + DT + Contrast) | 1 existente | 50 min |
| Modificar ResultView.swift (VoiceOver + RM + DT + Contrast) | 1 existente | 40 min |
| Modificar ContentView.swift (Transiciones + anuncios) | 1 existente | 15 min |
| Testing VoiceOver completo | - | 30 min |
| Testing Reduce Motion | - | 20 min |
| Testing Dynamic Type | - | 20 min |
| Testing Increased Contrast | - | 15 min |
| Xcode Accessibility Inspector audit | - | 15 min |
| Correcciones post-testing | varios | 30 min |
| **TOTAL** | **8 archivos (2 nuevos + 6 existentes)** | **~6 horas** |

---

## Checklist Completo de Items de Accesibilidad

### VoiceOver Labels y Hints
- [ ] `SplashView`: SeismographView `.accessibilityLabel` (activo/calma)
- [ ] `SplashView`: Globe `.accessibilityLabel` como imagen
- [ ] `SplashView`: CrackLines `.accessibilityHidden(true)`
- [ ] `SplashView`: Cada StatBadge `.accessibilityLabel` + `.accessibilityHint`
- [ ] `SplashView`: Boton "Start Learning" `.accessibilityHint`
- [ ] `SplashView`: Texto 2017 `.accessibilityLabel` limpio
- [ ] `LearnView`: "Safety Protocol" `.accessibilityAddTraits(.isHeader)`
- [ ] `LearnView`: Shield icon `.accessibilityHidden(true)`
- [ ] `LearnView`: Cada boton de phase `.accessibilityLabel` + `.accessibilityValue` + `.accessibilityHint`
- [ ] `LearnView`: Phase selector `.accessibilityAddTraits(.isSelected)`
- [ ] `LearnView`: Cada TipCard `.accessibilityLabel` + `.accessibilityValue` + `.accessibilityHint`
- [ ] `LearnView`: Chevron icon `.accessibilityHidden(true)`
- [ ] `LearnView`: TipCard icon circle `.accessibilityHidden(true)`
- [ ] `LearnView`: Progress indicators `.accessibilityLabel` con estado
- [ ] `LearnView`: "Mark as Read" `.accessibilityLabel` + `.accessibilityHint` condicional
- [ ] `LearnView`: "Test Yourself" `.accessibilityLabel` + `.accessibilityHint`
- [ ] `SimulationView`: Progress ring `.accessibilityLabel`
- [ ] `SimulationView`: Score counters `.accessibilityElement(children: .ignore)` + label combinado
- [ ] `SimulationView`: Scenario card `.accessibilityLabel` + `.isHeader`
- [ ] `SimulationView`: Warning icon `.accessibilityHidden(true)`
- [ ] `SimulationView`: Cada option button `.accessibilityLabel` + `.accessibilityValue` + `.accessibilityHint`
- [ ] `SimulationView`: Options disabled `.accessibilityRemoveTraits(.isButton)`
- [ ] `SimulationView`: Lightbulb icon `.accessibilityHidden(true)`
- [ ] `SimulationView`: Explanation "Why?" `.accessibilityAddTraits(.isHeader)`
- [ ] `SimulationView`: Explanation card `.accessibilityElement(children: .combine)`
- [ ] `SimulationView`: Continue button `.accessibilityLabel` + `.accessibilityHint` dinamico
- [ ] `ResultView`: Score ring `.accessibilityElement(children: .ignore)` + label con score real
- [ ] `ResultView`: ParticlesView `.accessibilityHidden(true)`
- [ ] `ResultView`: scoreTitle `.accessibilityAddTraits(.isHeader)`
- [ ] `ResultView`: Message section `.accessibilityElement(children: .combine)`
- [ ] `ResultView`: "Your Responses" `.accessibilityAddTraits(.isHeader)`
- [ ] `ResultView`: Cada response item `.accessibilityLabel` con estado
- [ ] `ResultView`: "Key Takeaways" `.accessibilityAddTraits(.isHeader)`
- [ ] `ResultView`: Cada takeaway `.accessibilityElement(children: .ignore)` + label combinado
- [ ] `ResultView`: "Start Over" `.accessibilityHint`
- [ ] `ResultView`: Share text sin cambios (ya es accesible)

### Acciones de Accesibilidad Custom
- [ ] `TipCard`: `.accessibilityAction(named:)` para expand/collapse
- [ ] `StatBadge`: `.accessibilityAction(named:)` para expand
- [ ] `LearnView`: Phase selector acciones de navegacion (next/previous)

### Agrupacion Semantica
- [ ] `SplashView`: Globe + glow circle agrupados
- [ ] `LearnView`: Progress indicators agrupados por fase
- [ ] `SimulationView`: Score counters agrupados
- [ ] `ResultView`: Score ring agrupado
- [ ] `ResultView`: Cada takeaway agrupado

### Notificaciones de Estado
- [ ] `ContentView`: `.onChange` para anunciar cambio de fase
- [ ] `LearnView`: Anunciar cambio de fase seleccionada
- [ ] `LearnView`: Anunciar expansion/colapso de TipCard
- [ ] `LearnView`: Anunciar "fase marcada como completada"
- [ ] `LearnView`: Anunciar "todas las fases completas"
- [ ] `SimulationView`: Anunciar respuesta correcta/incorrecta
- [ ] `SimulationView`: Anunciar nuevo escenario
- [ ] `ResultView`: Anunciar pantalla de resultados con score

### Dynamic Type
- [ ] Crear extension `Font` con fuentes adaptativas
- [ ] `SplashView`: Reemplazar todas las fuentes fijas
- [ ] `SplashView`: Layout adaptativo para StatBadges
- [ ] `LearnView`: Reemplazar todas las fuentes fijas
- [ ] `SimulationView`: Reemplazar todas las fuentes fijas
- [ ] `ResultView`: Reemplazar todas las fuentes fijas
- [ ] Score ring porcentaje: Usar `@ScaledMetric` o mantener fijo con label accesible
- [ ] Verificar scroll correcto con textos agrandados

### Reduce Motion
- [ ] `ShakeEffect.swift`: PulseEffect respeta `reduceMotion`
- [ ] `ShakeEffect.swift`: GlowEffect respeta `reduceMotion`
- [ ] `SplashView`: Secuencia staggered skip con `reduceMotion`
- [ ] `SplashView`: ShakeEffect condicional
- [ ] `SplashView`: Seismograph continua (no es motion-sickness, es OK)
- [ ] `ContentView`: Transiciones simplificadas
- [ ] `SimulationView`: ShakeEffect en scenario card condicional
- [ ] `SimulationView`: Intensidad roja de fondo condicional
- [ ] `ResultView`: Secuencia staggered skip
- [ ] `ResultView`: Ring progress instantaneo
- [ ] `ResultView`: Score counter instantaneo
- [ ] `ResultView`: Particles reemplazadas por alternativa estatica

### Alto Contraste
- [ ] `SplashView`: StatBadge fondos y bordes reforzados
- [ ] `LearnView`: TipCard fondos y bordes reforzados
- [ ] `LearnView`: Phase selector contraste mejorado
- [ ] `SimulationView`: Option buttons contraste mejorado
- [ ] `SimulationView`: Scenario card bordes reforzados
- [ ] `SimulationView`: Explanation card bordes reforzados
- [ ] `ResultView`: Response items contraste mejorado
- [ ] `ResultView`: Takeaway items contraste mejorado
- [ ] Todos: Textos gris con opacidad aumentada
- [ ] Todos: lineWidth aumentado en bordes

### Archivos Nuevos a Crear
- [ ] `AccessibilityHelper.swift` - Anuncios y utilities
- [ ] `AdaptiveFonts.swift` - Extension de Font para Dynamic Type

### Archivos Existentes a Modificar
- [ ] `ShakeEffect.swift` - Reduce Motion en 3 efectos
- [ ] `SplashView.swift` - VoiceOver + RM + DT + Contrast
- [ ] `LearnView.swift` - VoiceOver + RM + DT + Contrast
- [ ] `SimulationView.swift` - VoiceOver + RM + DT + Contrast
- [ ] `ResultView.swift` - VoiceOver + RM + DT + Contrast
- [ ] `ContentView.swift` - Transiciones + anuncios de fase

---

## Referencias

- [Accessibility Modifiers - Apple Developer Documentation](https://developer.apple.com/documentation/swiftui/view-accessibility)
- [Catch up on accessibility in SwiftUI - WWDC24](https://developer.apple.com/videos/play/wwdc2024/10073/)
- [Build accessible apps with SwiftUI and UIKit - WWDC23](https://developer.apple.com/videos/play/wwdc2023/10036/)
- [Swift Student Challenge - Apple Developer](https://developer.apple.com/swift-student-challenge/)
- [Eligibility and Requirements - Swift Student Challenge](https://developer.apple.com/swift-student-challenge/eligibility/)
