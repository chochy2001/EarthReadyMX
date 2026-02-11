# Plan de Implementacion: Checklist Personal de Preparacion ante Sismos

## Tabla de Contenidos
1. [Resumen General](#1-resumen-general)
2. [Impacto Social y Criterios del Swift Student Challenge](#2-impacto-social-y-criterios-del-swift-student-challenge)
3. [Modelo de Datos](#3-modelo-de-datos)
4. [Items del Checklist (Fuentes Oficiales)](#4-items-del-checklist-fuentes-oficiales)
5. [Diseno de UI](#5-diseno-de-ui)
6. [Arquitectura del Codigo](#6-arquitectura-del-codigo)
7. [Animaciones y Gamificacion](#7-animaciones-y-gamificacion)
8. [Integracion con el Flujo Existente](#8-integracion-con-el-flujo-existente)
9. [Archivos a Crear/Modificar](#9-archivos-a-crearmodificar)
10. [Estimacion de Esfuerzo](#10-estimacion-de-esfuerzo)
11. [Diferenciadores](#11-diferenciadores)
12. [Fuentes Oficiales](#12-fuentes-oficiales)

---

## 1. Resumen General

### Que es
Un checklist interactivo de preparacion personal ante sismos que el usuario puede completar despues de terminar la simulacion/quiz. Transforma el conocimiento adquirido en acciones concretas del mundo real.

### Por que
La app actualmente educa (LearnView) y evalua (SimulationView), pero no conecta el aprendizaje con acciones tangibles. El checklist cierra el ciclo: **Aprender -> Evaluar -> Actuar**. Esto convierte a EarthReady MX de una herramienta educativa en un **companion de preparacion real**.

### Flujo del usuario
```
Splash -> Learn -> Simulation -> Results -> Checklist (nueva fase)
                                     |
                                     +-> "Prepare Now" (boton en ResultView)
```

El checklist es accesible desde ResultView mediante un boton prominente "Prepare Now" que aparece despues del boton "Start Over". Tambien se puede acceder en cualquier momento desde un tab o boton persistente.

### Persistencia
Solo durante la sesion de la app (`@Published` properties en `GameState`). No se necesita persistencia entre lanzamientos ya que es un App Playground demo de 3 minutos.

---

## 2. Impacto Social y Criterios del Swift Student Challenge

### Criterios del SSC 2026
Segun Apple, las submissions se evaluan en:
- **Innovation** - Nuevos enfoques originales
- **Creativity** - Soluciones creativas
- **Social Impact** - Abordar problemas importantes en tu comunidad
- **Inclusivity** - Soluciones accesibles e inclusivas

### Como el Checklist fortalece "Social Impact"

| Aspecto | Sin Checklist | Con Checklist |
|---------|--------------|---------------|
| Utilidad real | Solo educativo | Herramienta practica |
| Accion del usuario | Pasiva (leer/contestar) | Activa (prepararse) |
| Impacto post-app | Se olvida | Genera habitos |
| Datos | Genericos | Basados en FEMA/CENAPRED |
| Contexto Mexico | Mencion al 2017 | Plan completo CENAPRED |
| Narrativa SSC | "Aprendi sobre sismos" | "Me preparo para sismos" |

### Narrativa para el essay del SSC
> "EarthReady MX no solo ensena que hacer durante un sismo -- empodera a los usuarios para tomar accion ANTES de que ocurra. El checklist interactivo, basado en recomendaciones oficiales de FEMA y el CENAPRED de Mexico, transforma el conocimiento en preparacion real. En un pais donde 12,000+ sismos ocurren al ano, cada persona preparada puede salvar no solo su vida, sino la de su familia."

---

## 3. Modelo de Datos

### Enums y Structs

```swift
// MARK: - Checklist Data Models

enum ChecklistPriority: Int, CaseIterable, Sendable {
    case critical = 0   // Indispensable, hacer primero
    case important = 1  // Muy importante
    case recommended = 2 // Recomendado

    var label: String {
        switch self {
        case .critical: return "Critical"
        case .important: return "Important"
        case .recommended: return "Recommended"
        }
    }

    var color: Color {
        switch self {
        case .critical: return .red
        case .important: return .orange
        case .recommended: return .blue
        }
    }

    var icon: String {
        switch self {
        case .critical: return "exclamationmark.triangle.fill"
        case .important: return "exclamationmark.circle.fill"
        case .recommended: return "info.circle.fill"
        }
    }
}

struct ChecklistItem: Identifiable, Sendable {
    let id = UUID()
    let icon: String          // SF Symbol
    let title: String         // Nombre corto del item
    let description: String   // Descripcion detallada
    let priority: ChecklistPriority
    var isCompleted: Bool = false
}

struct ChecklistCategory: Identifiable, Sendable {
    let id = UUID()
    let icon: String          // SF Symbol para la categoria
    let title: String         // Nombre de la categoria
    let subtitle: String      // Descripcion breve
    let color: Color          // Color tematico
    let gradientColors: [Color]
    var items: [ChecklistItem]

    var completedCount: Int {
        items.filter(\.isCompleted).count
    }

    var totalCount: Int {
        items.count
    }

    var progress: Double {
        guard totalCount > 0 else { return 0 }
        return Double(completedCount) / Double(totalCount)
    }

    var isComplete: Bool {
        completedCount == totalCount
    }
}
```

### Extension de GameState

```swift
// Agregar a GameState.swift

// Nueva fase
enum AppPhase: Equatable, Sendable {
    case splash
    case learn
    case simulation
    case result
    case checklist  // NUEVO
}

// Propiedades en GameState
@Published var checklistCategories: [ChecklistCategory] = ChecklistData.allCategories()

var totalChecklistItems: Int {
    checklistCategories.reduce(0) { $0 + $1.totalCount }
}

var completedChecklistItems: Int {
    checklistCategories.reduce(0) { $0 + $1.completedCount }
}

var checklistProgress: Double {
    guard totalChecklistItems > 0 else { return 0 }
    return Double(completedChecklistItems) / Double(totalChecklistItems)
}

var checklistPercentage: Int {
    Int(checklistProgress * 100)
}

func toggleChecklistItem(categoryId: UUID, itemId: UUID) {
    guard let catIndex = checklistCategories.firstIndex(where: { $0.id == categoryId }),
          let itemIndex = checklistCategories[catIndex].items.firstIndex(where: { $0.id == itemId }) else {
        return
    }
    checklistCategories[catIndex].items[itemIndex].isCompleted.toggle()
}

var checklistMotivationalMessage: String {
    let pct = checklistPercentage
    if pct == 0 {
        return "Every journey starts with a single step. Begin preparing today."
    } else if pct < 25 {
        return "Great start! You're taking the first steps to protect your family."
    } else if pct < 50 {
        return "You're making real progress. Keep going!"
    } else if pct < 75 {
        return "Over halfway there! Your preparedness level is impressive."
    } else if pct < 100 {
        return "Almost there! You're among the most prepared people."
    } else {
        return "Outstanding! You and your family are fully prepared."
    }
}
```

---

## 4. Items del Checklist (Fuentes Oficiales)

Todos los items estan basados en recomendaciones reales de **FEMA (Ready.gov)** y **CENAPRED (Mexico)**. Organizados por categoria y prioridad.

### Categoria 1: Emergency Kit (Kit de Emergencia)

Fuente principal: FEMA Ready.gov Kit + CENAPRED Mochila de Emergencia

| # | Item | Descripcion | Prioridad | SF Symbol | Fuente |
|---|------|-------------|-----------|-----------|--------|
| 1 | Water Supply | One gallon per person per day for at least 3 days, for drinking and sanitation | Critical | `drop.fill` | FEMA |
| 2 | Non-perishable Food | At least a 3-day supply. Canned goods, energy bars, dried fruits. Easy to open. | Critical | `fork.knife` | FEMA + CENAPRED |
| 3 | First Aid Kit | Bandages, antiseptic, pain relievers, prescription medications, gauze, tape | Critical | `cross.case.fill` | FEMA |
| 4 | Flashlight & Batteries | LED flashlight with extra batteries. Avoid candles (fire risk after earthquake). | Critical | `flashlight.on.fill` | FEMA + CENAPRED |
| 5 | Emergency Whistle | To signal for help if trapped under debris | Critical | `speaker.wave.3.fill` | FEMA + CENAPRED |
| 6 | Important Documents | Copies of IDs, insurance, medical records in waterproof bag or USB drive | Critical | `doc.text.fill` | CENAPRED |
| 7 | Battery/Hand-crank Radio | NOAA Weather Radio or AM/FM. Essential when power and internet are down. | Important | `radio.fill` | FEMA + CENAPRED |
| 8 | Phone Charger & Power Bank | Portable battery pack, keep charged. Solar charger as backup. | Important | `battery.100.bolt` | FEMA |
| 9 | Cash (Small Bills) | ATMs and card readers won't work without power. Keep small denominations. | Important | `banknote.fill` | FEMA |
| 10 | Dust Masks | N95 or similar to filter contaminated air from debris and collapsed structures | Important | `facemask.fill` | FEMA |
| 11 | Manual Can Opener | For canned food. Don't rely on electric openers. | Recommended | `wrench.fill` | FEMA |
| 12 | Local Maps | Paper maps of your area. GPS may not work without cell service. | Recommended | `map.fill` | FEMA |
| 13 | Warm Clothing & Blanket | Extra clothes, rain jacket, sturdy shoes, thermal blanket | Recommended | `tshirt.fill` | CENAPRED |
| 14 | Wrench/Pliers | To turn off gas and water utilities if needed | Recommended | `wrench.and.screwdriver.fill` | FEMA |

### Categoria 2: Home Safety (Seguridad del Hogar)

Fuente principal: FEMA + CENAPRED Plan Familiar Step 1

| # | Item | Descripcion | Prioridad | SF Symbol | Fuente |
|---|------|-------------|-----------|-----------|--------|
| 1 | Secure Heavy Furniture | Anchor bookcases, shelves, and tall furniture to walls with brackets or straps | Critical | `cabinet.fill` | FEMA |
| 2 | Identify Safe Spots | Under sturdy tables/desks in each room. Away from windows and heavy objects. | Critical | `shield.checkered` | FEMA + CENAPRED |
| 3 | Know Gas Shutoff | Learn location of gas valve and how to shut it off. Keep wrench nearby. | Critical | `flame.fill` | FEMA + CENAPRED |
| 4 | Know Water Shutoff | Locate main water valve. Know how to turn it off in case of pipe damage. | Important | `drop.triangle.fill` | FEMA |
| 5 | Know Electrical Panel | Know location and how to shut off main breaker if wiring is damaged | Important | `bolt.fill` | CENAPRED |
| 6 | Secure Water Heater | Strap to wall studs. Prevent tipping which can cause gas leaks or floods. | Important | `heater.vertical.fill` | FEMA |
| 7 | Store Heavy Items Low | Move heavy objects from high shelves to lower shelves to prevent falling injuries | Important | `arrow.down.to.line` | FEMA |
| 8 | Check Evacuation Routes | Identify 2 exits from each room. Remove obstacles. Practice in the dark. | Critical | `figure.walk.departure` | CENAPRED |
| 9 | Inspect Home Structure | Check for cracks in walls, foundation issues. Consult professional if needed. | Recommended | `building.2.fill` | CENAPRED |
| 10 | Secure Hanging Objects | Mirrors, paintings, light fixtures. Use closed hooks and safety wire. | Recommended | `photo.artframe` | FEMA |

### Categoria 3: Family Plan (Plan Familiar)

Fuente principal: CENAPRED Plan Familiar de Proteccion Civil + FEMA

| # | Item | Descripcion | Prioridad | SF Symbol | Fuente |
|---|------|-------------|-----------|-----------|--------|
| 1 | Designate Meeting Point | Choose a safe location outside your home where family gathers after evacuation | Critical | `mappin.and.ellipse` | FEMA + CENAPRED |
| 2 | Emergency Contact List | Written list of family, neighbors, emergency services. Don't rely only on phone. | Critical | `phone.fill` | FEMA + CENAPRED |
| 3 | Out-of-Area Contact | Choose a relative/friend in another city as communication hub for family | Critical | `person.line.dotted.person.fill` | FEMA |
| 4 | Assign Family Roles | Each member knows their job: who shuts off gas, who grabs kit, who helps children | Important | `person.3.fill` | CENAPRED |
| 5 | Practice "Drop, Cover, Hold" | Drill with every family member. Practice quarterly. Include children. | Important | `arrow.down.to.line` | FEMA + CENAPRED |
| 6 | Know "Text, Don't Call" | Teach family to text instead of call during emergencies. Less bandwidth needed. | Important | `message.fill` | FEMA |
| 7 | Plan for Pets | Include pet food, carrier, leash, and veterinary records in your plan | Recommended | `pawprint.fill` | FEMA |
| 8 | Include Special Needs | Plan for elderly, disabled, or infant family members. Medications, mobility aids. | Important | `heart.fill` | CENAPRED |
| 9 | Alternative Meeting Point | Second meeting point farther from home in case neighborhood is inaccessible | Recommended | `mappin.slash` | FEMA |
| 10 | Practice Evacuation Drill | Run a full family drill at least twice a year. Time yourselves. | Recommended | `stopwatch.fill` | CENAPRED |

### Total: 34 items (14 + 10 + 10) distribuidos en 3 categorias

**Distribucion por prioridad:**
- Critical: 14 items (41%)
- Important: 13 items (38%)
- Recommended: 7 items (21%)

---

## 5. Diseno de UI

### Vista Principal: `ChecklistView`

```
+--------------------------------------------------+
|  [< Back]        My Preparedness           [34%]  |
|                                                    |
|  +--------------------------------------------+   |
|  |            PROGRESS RING (grande)           |   |
|  |         +-----------+                       |   |
|  |         |   34%     |  "Great start!"       |   |
|  |         | 12 of 34  |  motivational msg     |   |
|  |         +-----------+                       |   |
|  +--------------------------------------------+   |
|                                                    |
|  +--------------------------------------------+   |
|  | [Kit icon]  Emergency Kit         9/14      |   |
|  | [====------]  64%                    >      |   |
|  +--------------------------------------------+   |
|                                                    |
|  +--------------------------------------------+   |
|  | [Home icon] Home Safety           3/10      |   |
|  | [===-------]  30%                    >      |   |
|  +--------------------------------------------+   |
|                                                    |
|  +--------------------------------------------+   |
|  | [People icon] Family Plan         0/10      |   |
|  | [----------]   0%                    >      |   |
|  +--------------------------------------------+   |
|                                                    |
|  "Based on FEMA & CENAPRED guidelines"            |
+--------------------------------------------------+
```

### Tarjeta de Categoria (Colapsada)

```swift
// CategoryCard - Vista compacta
struct CategoryCard: View {
    let category: ChecklistCategory
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                HStack(spacing: 14) {
                    // Icono con fondo circular gradiente
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: category.gradientColors.map { $0.opacity(0.2) },
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 48, height: 48)
                        Image(systemName: category.icon)
                            .font(.system(size: 20))
                            .foregroundColor(category.color)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(category.title)
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        Text(category.subtitle)
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }

                    Spacer()

                    // Contador
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("\(category.completedCount)/\(category.totalCount)")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(category.isComplete ? .green : .white)
                        if category.isComplete {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundColor(.green)
                                .font(.caption)
                        }
                    }

                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.gray)
                }

                // Barra de progreso
                ProgressBarView(
                    progress: category.progress,
                    colors: category.gradientColors
                )
            }
            .padding(16)
            .background(Color.white.opacity(0.06))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        category.isComplete
                            ? Color.green.opacity(0.3)
                            : Color.white.opacity(0.08),
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(.plain)
    }
}
```

### Vista de Categoria Expandida: `CategoryDetailView`

```
+--------------------------------------------------+
|  [< Back]    Emergency Kit              9/14      |
|              [==========----]  64%                 |
|                                                    |
|  -- CRITICAL (must-have) --                        |
|                                                    |
|  +--------------------------------------------+   |
|  | [x] Water Supply                    [drop]  |   |
|  |     One gallon per person per day...        |   |
|  +--------------------------------------------+   |
|                                                    |
|  +--------------------------------------------+   |
|  | [ ] Non-perishable Food             [fork]  |   |
|  |     At least a 3-day supply...              |   |
|  +--------------------------------------------+   |
|                                                    |
|  ...                                               |
|                                                    |
|  -- IMPORTANT --                                   |
|  ...                                               |
|                                                    |
|  -- RECOMMENDED --                                 |
|  ...                                               |
+--------------------------------------------------+
```

### Checkbox Personalizado

```swift
struct CheckboxView: View {
    let isChecked: Bool
    let color: Color

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(isChecked ? color.opacity(0.2) : Color.white.opacity(0.06))
                .frame(width: 28, height: 28)

            RoundedRectangle(cornerRadius: 8)
                .stroke(isChecked ? color : Color.white.opacity(0.2), lineWidth: 1.5)
                .frame(width: 28, height: 28)

            if isChecked {
                Image(systemName: "checkmark")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(color)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isChecked)
    }
}
```

### Progress Ring (Vista Principal)

```swift
struct ProgressRingView: View {
    let progress: Double
    let lineWidth: CGFloat
    let size: CGFloat
    let gradientColors: [Color]

    @State private var animatedProgress: Double = 0

    var body: some View {
        ZStack {
            // Track
            Circle()
                .stroke(Color.white.opacity(0.08), lineWidth: lineWidth)

            // Progress arc
            Circle()
                .trim(from: 0, to: animatedProgress)
                .stroke(
                    AngularGradient(
                        colors: gradientColors + [gradientColors.first ?? .orange],
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))

            // Center content
            VStack(spacing: 4) {
                Text("\(Int(animatedProgress * 100))%")
                    .font(.system(size: size * 0.2, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .contentTransition(.numericText())
            }
        }
        .frame(width: size, height: size)
        .onAppear {
            withAnimation(.easeOut(duration: 1.0)) {
                animatedProgress = progress
            }
        }
        .onChange(of: progress) { newValue in
            withAnimation(.easeOut(duration: 0.5)) {
                animatedProgress = newValue
            }
        }
    }
}
```

### Barra de Progreso Lineal

```swift
struct ProgressBarView: View {
    let progress: Double
    let colors: [Color]

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.white.opacity(0.08))

                RoundedRectangle(cornerRadius: 4)
                    .fill(
                        LinearGradient(
                            colors: colors,
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geo.size.width * progress)
                    .animation(.easeOut(duration: 0.4), value: progress)
            }
        }
        .frame(height: 6)
    }
}
```

### Paleta de Colores por Categoria

| Categoria | Color Primario | Gradiente | Justificacion |
|-----------|---------------|-----------|---------------|
| Emergency Kit | `.orange` | `[.orange, .yellow]` | Consistente con la paleta naranja de la app |
| Home Safety | `.cyan` | `[.cyan, .blue]` | Azul = seguridad, proteccion |
| Family Plan | `.green` | `[.green, .mint]` | Verde = vida, familia, conexion |

---

## 6. Arquitectura del Codigo

### Archivos Nuevos

```
EarthReadyMXFinal.swiftpm/
├── ChecklistView.swift          // Vista principal del checklist
├── CategoryDetailView.swift     // Vista de detalle por categoria
├── ChecklistComponents.swift    // Componentes reutilizables (checkbox, progress bar, ring)
├── ChecklistData.swift          // Datos estáticos del checklist (items, categorias)
├── CelebrationView.swift        // Animacion de celebracion/confetti para categorias completadas
```

### Archivos a Modificar

```
├── GameState.swift              // Agregar AppPhase.checklist + propiedades del checklist
├── ContentView.swift            // Agregar case .checklist en switch
├── ResultView.swift             // Agregar boton "Prepare Now" en actionsSection
```

### ChecklistData.swift (Datos Estaticos)

```swift
import SwiftUI

enum ChecklistData {
    static func allCategories() -> [ChecklistCategory] {
        [emergencyKit(), homeSafety(), familyPlan()]
    }

    static func emergencyKit() -> ChecklistCategory {
        ChecklistCategory(
            icon: "bag.fill",
            title: "Emergency Kit",
            subtitle: "Essential supplies for the first 72 hours",
            color: .orange,
            gradientColors: [.orange, .yellow],
            items: [
                // Critical
                ChecklistItem(icon: "drop.fill", title: "Water Supply",
                    description: "One gallon per person per day for at least 3 days, for drinking and sanitation.",
                    priority: .critical),
                ChecklistItem(icon: "fork.knife", title: "Non-perishable Food",
                    description: "At least a 3-day supply. Canned goods, energy bars, dried fruits. Easy to open.",
                    priority: .critical),
                ChecklistItem(icon: "cross.case.fill", title: "First Aid Kit",
                    description: "Bandages, antiseptic, pain relievers, prescription medications, gauze, tape.",
                    priority: .critical),
                ChecklistItem(icon: "flashlight.on.fill", title: "Flashlight & Batteries",
                    description: "LED flashlight with extra batteries. Avoid candles due to fire risk after earthquakes.",
                    priority: .critical),
                ChecklistItem(icon: "speaker.wave.3.fill", title: "Emergency Whistle",
                    description: "To signal for help if trapped under debris. Can be heard farther than your voice.",
                    priority: .critical),
                ChecklistItem(icon: "doc.text.fill", title: "Important Documents",
                    description: "Copies of IDs, insurance, medical records in a waterproof bag or USB drive.",
                    priority: .critical),
                // Important
                ChecklistItem(icon: "radio.fill", title: "Battery/Hand-crank Radio",
                    description: "AM/FM radio for emergency broadcasts. Essential when power and internet are down.",
                    priority: .important),
                ChecklistItem(icon: "battery.100.bolt", title: "Phone Charger & Power Bank",
                    description: "Portable battery pack, keep charged. Consider a solar charger as backup.",
                    priority: .important),
                ChecklistItem(icon: "banknote.fill", title: "Cash in Small Bills",
                    description: "ATMs and card readers won't work without power. Keep small denominations.",
                    priority: .important),
                ChecklistItem(icon: "facemask.fill", title: "Dust Masks",
                    description: "N95 or similar to filter contaminated air from debris and collapsed structures.",
                    priority: .important),
                // Recommended
                ChecklistItem(icon: "wrench.fill", title: "Manual Can Opener",
                    description: "For opening canned food. Don't rely on electric openers.",
                    priority: .recommended),
                ChecklistItem(icon: "map.fill", title: "Local Maps",
                    description: "Paper maps of your area. GPS and cell service may not work after a major quake.",
                    priority: .recommended),
                ChecklistItem(icon: "tshirt.fill", title: "Warm Clothing & Blanket",
                    description: "Extra clothes, rain jacket, sturdy shoes, and a thermal or emergency blanket.",
                    priority: .recommended),
                ChecklistItem(icon: "wrench.and.screwdriver.fill", title: "Utility Wrench/Pliers",
                    description: "To turn off gas and water utilities if damage is detected.",
                    priority: .recommended),
            ]
        )
    }

    static func homeSafety() -> ChecklistCategory {
        ChecklistCategory(
            icon: "house.fill",
            title: "Home Safety",
            subtitle: "Secure your space before an earthquake strikes",
            color: .cyan,
            gradientColors: [.cyan, .blue],
            items: [
                // Critical
                ChecklistItem(icon: "cabinet.fill", title: "Secure Heavy Furniture",
                    description: "Anchor bookcases, shelves, and tall furniture to walls with brackets or straps.",
                    priority: .critical),
                ChecklistItem(icon: "shield.checkered", title: "Identify Safe Spots",
                    description: "Under sturdy tables or desks in each room. Away from windows and heavy objects.",
                    priority: .critical),
                ChecklistItem(icon: "flame.fill", title: "Know Gas Shutoff",
                    description: "Learn gas valve location and how to shut it off. Keep a wrench nearby.",
                    priority: .critical),
                ChecklistItem(icon: "figure.walk.departure", title: "Check Evacuation Routes",
                    description: "Identify 2 exits from each room. Remove obstacles. Practice in the dark.",
                    priority: .critical),
                // Important
                ChecklistItem(icon: "drop.triangle.fill", title: "Know Water Shutoff",
                    description: "Locate main water valve. Know how to turn it off in case of pipe damage.",
                    priority: .important),
                ChecklistItem(icon: "bolt.fill", title: "Know Electrical Panel",
                    description: "Know location and how to shut off main breaker if wiring is damaged.",
                    priority: .important),
                ChecklistItem(icon: "heater.vertical.fill", title: "Secure Water Heater",
                    description: "Strap to wall studs to prevent tipping, which can cause gas leaks or floods.",
                    priority: .important),
                ChecklistItem(icon: "arrow.down.to.line", title: "Store Heavy Items Low",
                    description: "Move heavy objects from high shelves to lower ones to prevent falling injuries.",
                    priority: .important),
                // Recommended
                ChecklistItem(icon: "building.2.fill", title: "Inspect Home Structure",
                    description: "Check for cracks in walls and foundation issues. Consult a professional if needed.",
                    priority: .recommended),
                ChecklistItem(icon: "photo.artframe", title: "Secure Hanging Objects",
                    description: "Mirrors, paintings, light fixtures. Use closed hooks and safety wire.",
                    priority: .recommended),
            ]
        )
    }

    static func familyPlan() -> ChecklistCategory {
        ChecklistCategory(
            icon: "person.3.fill",
            title: "Family Plan",
            subtitle: "Coordinate with your family before disaster strikes",
            color: .green,
            gradientColors: [.green, .mint],
            items: [
                // Critical
                ChecklistItem(icon: "mappin.and.ellipse", title: "Designate Meeting Point",
                    description: "Choose a safe location outside your home where family gathers after evacuation.",
                    priority: .critical),
                ChecklistItem(icon: "phone.fill", title: "Emergency Contact List",
                    description: "Written list of family, neighbors, and emergency services. Don't rely only on phone.",
                    priority: .critical),
                ChecklistItem(icon: "person.line.dotted.person.fill", title: "Out-of-Area Contact",
                    description: "Choose a relative or friend in another city as communication hub for your family.",
                    priority: .critical),
                // Important
                ChecklistItem(icon: "person.3.fill", title: "Assign Family Roles",
                    description: "Each member knows their job: who shuts off gas, who grabs the kit, who helps children.",
                    priority: .important),
                ChecklistItem(icon: "arrow.down.to.line", title: "Practice Drop, Cover, Hold",
                    description: "Drill with every family member. Practice quarterly. Include children and elderly.",
                    priority: .important),
                ChecklistItem(icon: "message.fill", title: "Learn: Text, Don't Call",
                    description: "Teach family to text instead of calling during emergencies. Uses less bandwidth.",
                    priority: .important),
                ChecklistItem(icon: "heart.fill", title: "Plan for Special Needs",
                    description: "Plan for elderly, disabled, or infant family members. Include medications and mobility aids.",
                    priority: .important),
                // Recommended
                ChecklistItem(icon: "pawprint.fill", title: "Plan for Pets",
                    description: "Include pet food, carrier, leash, and veterinary records in your emergency plan.",
                    priority: .recommended),
                ChecklistItem(icon: "mappin.slash", title: "Alternative Meeting Point",
                    description: "Second meeting point farther from home in case the neighborhood is inaccessible.",
                    priority: .recommended),
                ChecklistItem(icon: "stopwatch.fill", title: "Practice Evacuation Drill",
                    description: "Run a full family evacuation drill at least twice a year. Time yourselves.",
                    priority: .recommended),
            ]
        )
    }
}
```

### Flujo de Navegacion dentro del Checklist

```
ChecklistView (vista principal)
    |
    +---> CategoryDetailView (Emergency Kit)
    |         |
    |         +---> Items agrupados por prioridad
    |         +---> Toggle items
    |         +---> Celebracion cuando se completa la categoria
    |
    +---> CategoryDetailView (Home Safety)
    |
    +---> CategoryDetailView (Family Plan)
```

### Estado: `@State` vs `@Published`

- Los datos del checklist viven en `GameState` como `@Published var checklistCategories`
- La navegacion interna del checklist (que categoria esta expandida, scroll position) es `@State` local en las views
- No se necesita persistencia: todo en memoria durante la sesion

---

## 7. Animaciones y Gamificacion

### Al marcar un item

1. **Checkbox bounce**: Spring animation con `response: 0.3, dampingFraction: 0.6`
2. **Strikethrough suave**: El titulo se atenua ligeramente (opacity 0.6)
3. **Progress bar update**: Animacion `easeOut(duration: 0.4)` en la barra de progreso
4. **Haptic feedback**: `UIImpactFeedbackGenerator(style: .light)` -- Nota: verificar compatibilidad en App Playground

### Al completar una categoria

1. **Confetti explosion**: Reutilizar el patron de `ParticlesView` que ya existe en `ResultView.swift` pero con colores de la categoria
2. **Badge de completado**: Icono `checkmark.seal.fill` con animacion de escala
3. **Mensaje de felicitacion**: Banner temporal con mensaje motivacional
4. **Sonido**: No disponible en App Playground sin Audio framework -- omitir

### Confetti de Categoria (basado en ParticlesView existente)

```swift
struct CategoryCelebrationView: View {
    let colors: [Color]
    @State private var particles: [Particle] = []

    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                for particle in particles {
                    let age = timeline.date.timeIntervalSince(particle.created)
                    let progress = age / particle.lifetime
                    guard progress < 1 else { continue }

                    let x = particle.startX + particle.velocityX * age
                    let y = particle.startY + particle.velocityY * age + 40 * age * age
                    let opacity = 1 - progress
                    let pSize = particle.size * (1 - progress * 0.5)

                    context.opacity = opacity
                    // Alternar entre circulos y rectangulos para variedad
                    if particle.size > 5 {
                        context.fill(
                            RoundedRectangle(cornerRadius: 2)
                                .path(in: CGRect(x: x - pSize/2, y: y - pSize/2,
                                                 width: pSize, height: pSize * 0.6)),
                            with: .color(particle.color)
                        )
                    } else {
                        context.fill(
                            Circle().path(in: CGRect(x: x - pSize/2, y: y - pSize/2,
                                                     width: pSize, height: pSize)),
                            with: .color(particle.color)
                        )
                    }
                }
            }
        }
        .onAppear { generateParticles() }
        .allowsHitTesting(false) // No bloquear interaccion
    }

    private func generateParticles() {
        for _ in 0..<30 {
            particles.append(Particle(
                startX: CGFloat.random(in: 50...350),
                startY: CGFloat.random(in: -20...0),
                velocityX: CGFloat.random(in: -40...40),
                velocityY: CGFloat.random(in: 20...80),
                size: CGFloat.random(in: 3...9),
                color: colors.randomElement() ?? .orange,
                lifetime: Double.random(in: 1.5...3.0),
                created: Date()
            ))
        }
    }
}
```

### Sistema de Mensajes Motivacionales

```swift
// Mensajes por progreso general
var checklistMotivationalMessage: String {
    let pct = checklistPercentage
    switch pct {
    case 0:
        return "Every journey starts with a single step. Begin preparing today."
    case 1..<25:
        return "Great start! You're taking the first steps to protect your family."
    case 25..<50:
        return "You're making real progress. Keep going!"
    case 50..<75:
        return "Over halfway there! Your preparedness level is impressive."
    case 75..<100:
        return "Almost there! You're among the most prepared people."
    case 100:
        return "Outstanding! You and your family are fully prepared."
    default:
        return "Keep preparing!"
    }
}

// Mensajes al completar cada categoria
static func categoryCompletionMessage(for title: String) -> String {
    switch title {
    case "Emergency Kit":
        return "Your emergency kit is ready! You'll be self-sufficient for 72 hours."
    case "Home Safety":
        return "Your home is secured! You've reduced major risk factors."
    case "Family Plan":
        return "Your family knows what to do! Coordination saves lives."
    default:
        return "Category complete! Great job."
    }
}
```

### Gamificacion - Elementos Clave

| Elemento | Implementacion | Proposito |
|----------|---------------|-----------|
| Progress Ring | Anillo animado central | Visualizar progreso global |
| Category Progress Bars | Barra por categoria | Progreso granular |
| Priority Labels | Badges de prioridad con color | Urgencia, guia de accion |
| Completion Badges | Checkmark seal en categoria | Recompensa por completar |
| Confetti | Particulas animadas | Celebracion inmediata |
| Motivational Messages | Mensajes dinamicos | Refuerzo positivo |
| Numeric Counter | "12 of 34" con transicion | Tracking tangible |

### Por que no agregar mas gamificacion
- Es un demo de 3 minutos para el SSC -- simplicidad es clave
- El objetivo es preparacion real, no distraccion con badges/puntos
- La gamificacion sutil (progreso + celebracion) es mas apropiada para un tema serio como desastres naturales
- Los jueces buscan **impacto social**, no mecánicas de juego elaboradas

---

## 8. Integracion con el Flujo Existente

### Cambios en `AppPhase`

```swift
enum AppPhase: Equatable, Sendable {
    case splash
    case learn
    case simulation
    case result
    case checklist  // NUEVO
}
```

### Cambios en `ContentView.swift`

Agregar el caso `.checklist` en el switch:

```swift
case .checklist:
    ChecklistView()
        .transition(.asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .move(edge: .leading).combined(with: .opacity)
        ))
```

### Cambios en `ResultView.swift`

Agregar boton "Prepare Now" en `actionsSection`, ANTES del boton "Start Over":

```swift
private var actionsSection: some View {
    VStack(spacing: 12) {
        // NUEVO: Boton principal de accion
        Button(action: {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                gameState.currentPhase = .checklist
            }
        }) {
            HStack(spacing: 8) {
                Image(systemName: "checklist")
                Text("Prepare Now")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
            }
            .foregroundColor(.black)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                LinearGradient(colors: [.orange, .yellow], startPoint: .leading, endPoint: .trailing)
            )
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }

        // Start Over pasa a ser secundario
        Button(action: {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                gameState.reset()
            }
        }) {
            HStack(spacing: 8) {
                Image(systemName: "arrow.counterclockwise")
                Text("Start Over")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
            }
            .foregroundColor(.white.opacity(0.7))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color.white.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }

        Text("Share this app to help others be prepared.")
            .font(.system(size: 13, weight: .medium, design: .rounded))
            .foregroundColor(.gray)
            .multilineTextAlignment(.center)
    }
    .padding(.horizontal, 20)
}
```

### Cambios en `GameState.reset()`

```swift
func reset() {
    currentPhase = .splash
    score = 0
    totalQuestions = 0
    answeredScenarios = [:]
    currentLearnPhase = .before
    learnPhasesCompleted = []
    // Resetear checklist tambien
    checklistCategories = ChecklistData.allCategories()
}
```

### Navegacion de Retorno

Desde `ChecklistView` el usuario puede:
1. Tocar "Back to Results" para volver a `ResultView`
2. Tocar "Start Over" para resetear todo (volver al splash)

Desde `CategoryDetailView`:
1. Boton "Back" para volver a `ChecklistView`

---

## 9. Archivos a Crear/Modificar

### Archivos NUEVOS (5)

| Archivo | Proposito | LOC Estimadas |
|---------|-----------|---------------|
| `ChecklistView.swift` | Vista principal con progress ring y tarjetas de categorias | ~150 |
| `CategoryDetailView.swift` | Lista de items agrupados por prioridad, toggle logic | ~180 |
| `ChecklistComponents.swift` | CheckboxView, ProgressBarView, ProgressRingView, CategoryCard | ~200 |
| `ChecklistData.swift` | Datos estaticos de las 3 categorias y 34 items | ~180 |
| `CelebrationView.swift` | Confetti animation para completar categoria | ~80 |

### Archivos MODIFICADOS (3)

| Archivo | Cambio | LOC Afectadas |
|---------|--------|---------------|
| `GameState.swift` | Agregar `.checklist` a AppPhase, propiedades del checklist, toggleChecklistItem, mensajes motivacionales | ~50 |
| `ContentView.swift` | Agregar `case .checklist:` en switch | ~5 |
| `ResultView.swift` | Agregar boton "Prepare Now", cambiar "Start Over" a secundario | ~20 |

### Total estimado: ~865 lineas de codigo nuevo

---

## 10. Estimacion de Esfuerzo

| Tarea | Horas | Notas |
|-------|-------|-------|
| Modelo de datos + GameState | 1h | Structs, enums, extension de GameState |
| ChecklistData (items reales) | 1h | Copiar datos de las tablas, verificar SF Symbols |
| ChecklistView (principal) | 2h | Progress ring, tarjetas, layout |
| CategoryDetailView | 2h | Lista agrupada, toggle logic, animaciones |
| ChecklistComponents | 1.5h | Checkbox, progress bars, ring |
| CelebrationView | 0.5h | Basado en ParticlesView existente |
| Integracion (ContentView, ResultView) | 0.5h | Agregar cases, boton |
| Animaciones y polish | 1h | Transiciones, springs, haptics |
| Testing manual y ajustes | 1h | Verificar flujo completo |
| **TOTAL** | **~10.5h** | **1-2 dias de trabajo** |

### Riesgos

| Riesgo | Mitigacion |
|--------|-----------|
| SF Symbols no disponibles en iOS 16 | Verificar cada simbolo en SF Symbols app con filtro iOS 16+ |
| Performance con 34 items | Usar LazyVStack (ya se usa en LearnView) |
| App Playground sin UIKit | No usar UIImpactFeedbackGenerator, solo animaciones SwiftUI |
| Swift 6 concurrency | Todos los structs son Sendable, GameState ya es @MainActor |
| 3 minutos de demo | El checklist es rapido de explorar; se pueden marcar items en segundos |

---

## 11. Diferenciadores

### Vs. una app de checklist generica

| Aspecto | Checklist Generico | EarthReady MX Checklist |
|---------|-------------------|------------------------|
| Datos | Items inventados | Basado en FEMA + CENAPRED |
| Contexto | Aislado | Viene despues de aprender y ser evaluado |
| Motivacion | Ninguna | Mensajes motivacionales + celebraciones |
| Prioridad | Lista plana | Organizado por prioridad (Critical/Important/Recommended) |
| Relevancia | Global | Mexico-specific (CENAPRED) + universal (FEMA) |
| Integracion | Standalone | Conectado al score del quiz |
| Diseño | Standard | Consistente con la estetica oscura/naranja de la app |
| Proposito | Productividad | Impacto social + preparacion ante desastres |

### Valor para el Swift Student Challenge

1. **Cierra el loop educativo**: Learn -> Test -> Act. No se queda en la teoria.
2. **Datos reales**: Muestra investigacion seria (FEMA, CENAPRED). Los jueces ven rigor.
3. **Impacto social tangible**: Si alguien REALMENTE arma su kit despues de usar la app, eso es impacto real.
4. **Complejidad tecnica adicional**: Modelo de datos multi-nivel, animaciones con Canvas, progress tracking, navegacion anidada.
5. **Narrativa mas fuerte**: "EarthReady MX no solo te ensena que hacer en un sismo -- te guia paso a paso para prepararte en la vida real."

### Posibles futuras mejoras (fuera de scope del SSC demo)

- Persistencia con `@AppStorage` o `UserDefaults`
- Reminders/notificaciones para revisar el kit cada 3 meses (recomendacion CENAPRED)
- Compartir progreso en redes sociales
- Modo familiar: cada miembro de la familia tiene su propio perfil
- Ubicacion: recomendaciones especificas por zona sismica de Mexico

---

## 12. Fuentes Oficiales

### FEMA (Federal Emergency Management Agency) - Estados Unidos
- **Ready.gov - Earthquakes**: https://www.ready.gov/earthquakes
- **Ready.gov - Emergency Kit**: https://www.ready.gov/kit
- Fuente de: items del kit de emergencia, medidas de seguridad del hogar, protocolo "Drop, Cover, Hold On"

### CENAPRED (Centro Nacional de Prevencion de Desastres) - Mexico
- **Mochila de emergencia**: https://www.gob.mx/cenapred/articulos/sacate-un-10-en-tu-mochila-de-emergencia
- **Plan Familiar de Proteccion Civil**: https://www.gob.mx/cenapred/articulos/plan-familiar-de-proteccion-civil-por-que-es-importante-y-para-que-nos-sirve-206777
- **Folleto Sismos**: https://www.cenapred.unam.mx/es/Publicaciones/archivos/131-131-FOLLETOSISMOS.PDF
- **Plan Familiar PDF**: https://www.cenapred.unam.mx/es/Publicaciones/archivos/392-PLAN-FAMILIAR-DE-PROTECCION-CIVIL.PDF
- Fuente de: mochila de emergencia, plan familiar en 4 pasos, roles familiares, simulacros

### Swift Student Challenge 2026
- **Pagina oficial**: https://developer.apple.com/swift-student-challenge/
- **Criterios**: Innovation, Creativity, Social Impact, Inclusivity
- **Formato**: App Playgrounds, explorables en 3 minutos
- **Fechas**: Submissions abiertas del 6 al 28 de febrero de 2026

### Gamificacion y UX
- Patrones basados en mejores practicas de: Mockplus, CleverTap, Designlab (gamification in UX guides)

### SwiftUI - Patrones de Progreso Circular
- Approach basado en `Circle().trim(from:to:)` con `AngularGradient`
- Patron documentado en: Swift Anytime, Sarunw, Kodeco, Apple Developer Documentation

---

## Notas Finales

- Este documento sirve como referencia completa para la implementacion
- Los items del checklist son datos reales verificados contra fuentes oficiales
- El diseno visual es consistente con la estetica existente de EarthReady MX (dark mode, naranja/amarillo, rounded design)
- Toda la implementacion funciona dentro de las restricciones de App Playground (sin dependencias externas, sin frameworks adicionales, Swift 6, iOS 16+)
- Los 34 items representan un balance entre ser comprensivo y no abrumador para un demo de 3 minutos
