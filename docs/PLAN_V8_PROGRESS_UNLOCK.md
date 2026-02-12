# Plan V8: Progress Tracking, Unlock System & Checklist Groups

## Resumen

Hacer la experiencia mas interactiva con un sistema de progreso visual en ResultView.
Las secciones se "desbloquean" visualmente conforme el usuario las completa.
Ademas, agregar seleccion por grupo en el Checklist.

---

## Feature 1: Sistema de Progreso Visual en ResultView

### Estado Actual

Los 5 botones de seccion en `ResultView.swift` (lineas 177-324) se ven identicos
sin importar si el usuario ya completo la seccion o no:

| Seccion              | Gradiente actual     | State tracking          |
|----------------------|----------------------|-------------------------|
| Learn Safety         | Orange -> Yellow     | `learnPhasesCompleted`  |
| Build Your Kit       | Green -> Mint        | `kitScore`, `kitEssentialsFound` |
| Practice Drill       | Cyan -> Blue         | `drillCompleted`        |
| Seismic Zones        | Purple -> Indigo     | **NINGUNO**             |
| Room Safety Scanner  | Pink -> Red          | **NINGUNO**             |
| Go to Checklist      | White opacity        | `checklistCategories`   |

### Comportamiento Deseado

**Antes de completar** (estado incompleto):
- Solo se muestra el **contorno/borde** del color de la seccion
- Fondo transparente o muy sutil
- Texto en el color de la seccion (no negro)
- Icono en el color de la seccion
- Se puede presionar (no esta bloqueado, solo visual)

**Despues de completar** (estado completo):
- Gradiente completo como fondo (estado actual)
- Texto negro sobre el gradiente
- Icono de checkmark pequeno junto al titulo
- Efecto visual de "iluminado"

### Archivos a Modificar

#### 1.1 `GameState.swift` - Agregar tracking para Seismic Zones y Room Scanner

Actualmente no hay state para estas dos secciones. Agregar:

```swift
@Published var seismicZonesVisited: Bool = false
@Published var roomScannerUsed: Bool = false
```

Agregar computed property para saber si cada seccion esta completa:

```swift
var isLearnCompleted: Bool {
    learnPhasesCompleted.count == EarthquakePhase.allCases.count
}

var isKitCompleted: Bool {
    kitEssentialsFound >= 10
}

var isDrillCompleted: Bool {
    drillCompleted
}

var isSeismicZonesCompleted: Bool {
    seismicZonesVisited
}

var isRoomScannerCompleted: Bool {
    roomScannerUsed
}

var isChecklistCompleted: Bool {
    checklistPercentage == 100
}
```

Incluir estas propiedades en `resetAll()` para que se reinicien.

#### 1.2 `SeismicZoneView.swift` - Marcar como visitado

Al salir de la vista o al interactuar con al menos una zona, marcar:
```swift
gameState.seismicZonesVisited = true
```

Criterio: el usuario exploro al menos una zona sismica (selecciono un pais).

#### 1.3 `RoomScannerView.swift` - Marcar como usado

Cuando el usuario complete al menos un escaneo (reciba un safety score):
```swift
gameState.roomScannerUsed = true
```

Criterio: el usuario completo al menos un scan de habitacion.

#### 1.4 `ResultView.swift` - Redisenar botones de seccion

Reemplazar los botones actuales con un componente reutilizable que acepte:
- `isCompleted: Bool`
- `title: String`
- `icon: String`
- `gradientColors: [Color]`
- `action: () -> Void`

**Estilo incompleto:**
```swift
HStack(spacing: 8) {
    Image(systemName: icon)
    Text(title)
}
.foregroundColor(gradientColors[0])  // Color de la seccion
.frame(maxWidth: .infinity)
.padding(.vertical, 14)
.background(Color.clear)
.clipShape(RoundedRectangle(cornerRadius: 14))
.overlay(
    RoundedRectangle(cornerRadius: 14)
        .stroke(
            LinearGradient(colors: gradientColors, ...),
            lineWidth: 2
        )
)
```

**Estilo completo:**
```swift
HStack(spacing: 8) {
    Image(systemName: icon)
    Text(title)
    Spacer()
    Image(systemName: "checkmark.circle.fill")
        .foregroundColor(.black.opacity(0.5))
}
.foregroundColor(.black)
.frame(maxWidth: .infinity)
.padding(.vertical, 14)
.background(
    LinearGradient(colors: gradientColors, ...)
)
.clipShape(RoundedRectangle(cornerRadius: 14))
```

#### 1.5 Accesibilidad

- VoiceOver debe anunciar el estado: "Learn Safety Protocols, completed" vs "Learn Safety Protocols, not completed"
- Los botones incompletos NO estan deshabilitados, solo tienen diferente estilo visual
- Mantener `accessibilityHint` con instrucciones claras

---

## Feature 2: Seleccion por Grupo en Checklist

### Estado Actual

`ChecklistView.swift` (lineas 365-390) agrupa items por prioridad:
- **Critical** (rojo): Items criticos
- **Important** (naranja): Items importantes
- **Recommended** (azul): Items recomendados

Actualmente solo se pueden marcar items **uno por uno** tocando cada checkbox.

### Comportamiento Deseado

Agregar un boton "Select All" / "Deselect All" en el header de cada grupo de prioridad.
Al presionar, marca/desmarca todos los items de ese grupo dentro de la categoria actual.

### Archivo a Modificar

#### 2.1 `ChecklistView.swift` - Agregar boton de grupo

En cada header de grupo de prioridad (lineas ~401-420), agregar un boton:

```swift
// En el header de cada grupo de prioridad
HStack {
    // Icon y label existentes del grupo
    Image(systemName: priority.iconName)
    Text(priority.displayName)

    Spacer()

    // NUEVO: Boton para marcar/desmarcar grupo
    Button(action: {
        toggleGroup(priority: priority, in: categoryIndex)
    }) {
        Text(allItemsCompleted ? "Uncheck All" : "Check All")
            .font(.caption)
    }
}
```

#### 2.2 `ChecklistView.swift` o `GameState.swift` - Logica de toggle grupo

```swift
func toggleChecklistGroup(categoryIndex: Int, priority: ChecklistPriority) {
    let items = checklistCategories[categoryIndex].items
        .enumerated()
        .filter { $0.element.priority == priority }

    let allCompleted = items.allSatisfy { $0.element.isCompleted }

    for (index, _) in items {
        checklistCategories[categoryIndex].items[index].isCompleted = !allCompleted
    }
}
```

#### 2.3 Accesibilidad

- El boton "Check All" / "Uncheck All" debe tener accessibilityLabel claro
- Anunciar cuantos items se marcaron/desmarcaron

---

## Feature 3: Persistencia del Progreso (ya existente)

Verificar que `seismicZonesVisited` y `roomScannerUsed` se incluyan en:
- `saveToDisk()` / `loadFromDisk()` si existe persistencia
- `resetAll()` para reinicio completo

---

## Orden de Implementacion

Cada feature es independiente y puede implementarse en paralelo:

### Agente 1: Progress State Tracking
- **Archivos**: `GameState.swift`, `SeismicZoneView.swift`, `RoomScannerView.swift`
- **Tarea**: Agregar `seismicZonesVisited`, `roomScannerUsed`, computed properties `isXCompleted`, actualizar `resetAll()`
- **Dependencias**: Ninguna

### Agente 2: ResultView Visual Unlock System
- **Archivos**: `ResultView.swift`
- **Tarea**: Redisenar botones con estilo incompleto (borde) vs completo (gradiente), accesibilidad
- **Dependencias**: Agente 1 (necesita las computed properties)

### Agente 3: Checklist Group Selection
- **Archivos**: `ChecklistView.swift`, `GameState.swift`
- **Tarea**: Agregar botones "Check All"/"Uncheck All" por grupo de prioridad
- **Dependencias**: Ninguna

### Agente 4: Verificacion y Testing
- **Tarea**: Typecheck completo, verificar accesibilidad, probar flujo completo
- **Dependencias**: Agentes 1, 2, 3

---

## Criterios de Aceptacion

- [ ] Botones en ResultView se ven con borde/contorno cuando la seccion NO esta completa
- [ ] Botones en ResultView se ven con gradiente completo + checkmark cuando la seccion SI esta completa
- [ ] Seismic Zones se marca como visitado al explorar una zona
- [ ] Room Scanner se marca como usado al completar un scan
- [ ] Checklist tiene botones "Check All"/"Uncheck All" por grupo de prioridad
- [ ] VoiceOver anuncia estado de completado en cada boton de seccion
- [ ] `resetAll()` reinicia todo el progreso incluyendo nuevas propiedades
- [ ] Typecheck pasa sin errores
- [ ] Todo el flujo navegacion funciona correctamente
