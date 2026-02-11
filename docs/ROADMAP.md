# EarthReady MX - Roadmap de Mejoras

## Swift Student Challenge 2025 - Deadline: 28 de Febrero 2026

### Criterios de Evaluación de Apple
| Criterio | Estado Actual | Meta |
|----------|--------------|------|
| **Innovation** | Quiz genérico | Simulación inmersiva con haptics + audio |
| **Creativity** | UI bonita básica | Escenas interactivas, síntesis de audio |
| **Social Impact** | Tema relevante (sismos) | Checklist real de preparación + datos CENAPRED |
| **Inclusivity** | Sin accesibilidad | VoiceOver, Dynamic Type, Reduce Motion |

---

## Arquitectura Actual

```
MyApp.swift → ContentView.swift → SplashView / LearnView / SimulationView / ResultView
                                      ↓
                                  GameState.swift (modelo de datos)
                                  ShakeEffect.swift (animaciones)
```

## Arquitectura Meta

```
MyApp.swift → ContentView.swift → SplashView / LearnView / SimulationView / ResultView / ChecklistView
                                      ↓
                                  GameState.swift (modelo de datos ampliado)
                                  ShakeEffect.swift (animaciones)
                                  HapticManager.swift (CoreHaptics)
                                  SoundManager.swift (AVFoundation audio synthesis)
                                  SceneRenderer.swift (escenas interactivas 2D)
                                  AccessibilityHelpers.swift (utilidades de accesibilidad)
```

---

## Fases de Implementación

### Fase 1: CoreHaptics + Sonidos (2 días) - MAYOR IMPACTO
**Prioridad: CRÍTICA**

Estos dos van juntos porque la experiencia multisensorial (vibración + sonido) es lo que transforma un quiz en una simulación inmersiva.

- [ ] `HapticManager.swift` - Motor de haptics con patrones de sismo
- [ ] `SoundManager.swift` - Síntesis de audio en tiempo real
- [ ] Integrar en SplashView (rumble al inicio)
- [ ] Integrar en SimulationView (vibración durante escenarios)
- [ ] Integrar en ResultView (feedback de celebración)
- [ ] Verificar build en Xcode

**Documentación:** [PLAN_COREHAPTICS.md](./PLAN_COREHAPTICS.md) | [PLAN_SOUNDS.md](./PLAN_SOUNDS.md)

### Fase 2: Simulación Visual Interactiva (3-4 días) - DIFERENCIADOR
**Prioridad: ALTA**

Reemplazar el quiz de opciones múltiples por escenas donde el usuario interactúa con el entorno.

- [ ] Sistema de renderizado de escenas con Canvas/SwiftUI
- [ ] Escena 1: Salón de clases (tap zona segura)
- [ ] Escena 2: Calle/exterior (arrastra personaje)
- [ ] Escena 3: Cocina (múltiples peligros)
- [ ] Escena 4: Oficina (decisión bajo presión)
- [ ] Escena 5: Post-sismo (evaluación de daños)
- [ ] Animaciones de objetos cayendo, grietas, polvo
- [ ] Timer de presión (segundos para reaccionar)
- [ ] Integrar con haptics y sonidos

**Documentación:** [PLAN_INTERACTIVE_SIMULATION.md](./PLAN_INTERACTIVE_SIMULATION.md)

### Fase 3: Accesibilidad (1 día) - CRITERIO DIRECTO
**Prioridad: ALTA**

Mapea directamente al criterio "Inclusivity". Los jueces verifican esto.

- [ ] VoiceOver labels en todos los elementos interactivos
- [ ] Dynamic Type soporte
- [ ] Reduce Motion alternativas
- [ ] Contraste alto
- [ ] Notificaciones de accesibilidad para cambios de estado
- [ ] Testing con VoiceOver activado

**Documentación:** [PLAN_ACCESSIBILITY.md](./PLAN_ACCESSIBILITY.md)

### Fase 4: Checklist de Preparación (1 día) - UTILIDAD REAL
**Prioridad: MEDIA**

Da utilidad real más allá de la app. Los jueces valoran el impacto social tangible.

- [ ] Modelo de datos para checklist categorizado
- [ ] UI de checklist con progreso visual
- [ ] Datos reales de FEMA/CENAPRED
- [ ] Integrar como nueva fase después de resultados
- [ ] Animación de celebración al completar categorías

**Documentación:** [PLAN_CHECKLIST.md](./PLAN_CHECKLIST.md)

### Fase 5: Pulido Final (1-2 días)
**Prioridad: MEDIA**

- [ ] Testing completo en iPad y iPhone
- [ ] Verificar que corre en menos de 3 minutos
- [ ] Verificar tamaño < 25 MB
- [ ] Verificar que funciona offline
- [ ] App icon personalizado
- [ ] README para el submission essay
- [ ] Limpiar código y comentarios

---

## Timeline Estimado

| Fecha | Fase | Entregable |
|-------|------|-----------|
| Feb 11-12 | Fase 1 | CoreHaptics + Sonidos integrados |
| Feb 13-16 | Fase 2 | Simulación visual interactiva |
| Feb 17 | Fase 3 | Accesibilidad completa |
| Feb 18 | Fase 4 | Checklist de preparación |
| Feb 19-20 | Fase 5 | Pulido y testing final |
| Feb 21-27 | Buffer | Ajustes, ensayo, submission |
| **Feb 28** | **Deadline** | **Entregar en Apple** |

---

## Restricciones Técnicas
- **Formato**: App Playground (.swiftpm) en ZIP
- **Tamaño**: Máximo 25 MB
- **Offline**: Debe funcionar sin internet
- **Duración**: Experienciable en 3 minutos
- **Idioma**: Inglés
- **iOS**: 16.0+
- **Swift**: 6.0
- **Sin archivos externos**: Todo generado por código (SF Symbols, síntesis de audio, haptics por código)
- **Individual**: Trabajo de una sola persona

## Frameworks de Apple Utilizados
| Framework | Uso | Estado |
|-----------|-----|--------|
| SwiftUI | UI completa | ✅ Implementado |
| CoreHaptics | Vibración de sismo | 📋 Planeado |
| AVFoundation | Síntesis de audio | 📋 Planeado |
| Accessibility | VoiceOver, Dynamic Type | 📋 Planeado |
