# Issues V2 - Post Feature Implementation

## 1. Package.swift Warning
- `swiftLanguageVersions` is deprecated
- Debe usar `swiftLanguageModes` en su lugar
- Warning: `init(name:defaultLocalization:platforms:pkgConfig:providers:products:dependencies:targets:swiftLanguageVersions:cLanguageStandard:cxxLanguageStandard:)` is deprecated

## 2. Kit Builder - Drop Zone No Visible
- El "Drop Items Here" (backpack) está oculto en la parte inferior
- Demasiados items en el grid empujan el drop zone fuera de pantalla
- No hay scroll automático al arrastrar hacia abajo
- El usuario no puede ver dónde soltar los items

## 3. Kit Builder - Drop Action No Funciona
- Solo algunos items (Flashlight, Warm Clothes) logran hacer drop exitoso
- La mayoría de los items no registran el drop aunque se suelten sobre la zona correcta
- Posible problema: la detección de `bagFrame` no se actualiza correctamente
  o el hit-test con coordenadas globales falla

## 4. Kit Builder - Sin Botón de Regreso
- No hay manera de regresar al menú anterior desde Kit Builder
- El usuario queda atrapado en la vista sin opción de salir
- Necesita un botón "Back" o "X" para volver a ResultView

## 5. Idioma - Contenido en Español (Debe ser Inglés)
- El Drill tiene instrucciones en español ("¡Agáchate!", "¡Cúbrete!", etc.)
- Stop Drill y Practice Drill tienen texto en español
- **Requerimiento SSC: todo debe estar en inglés**
- Revisar: DrillView.swift, KitBuilderView.swift, SpeechManager.swift
- El TTS debe usar voz en-US en vez de es-MX

## 6. Navegación - No Se Puede Regresar
- Una vez que entras a Kit Builder o Drill, no puedes regresar
- No hay botones de navegación "Back" en las nuevas vistas
- Debe haber forma de regresar desde cada feature al menú anterior

## 7. Haptic Feedback en StatBadge (Splash Screen)
- Los botones de estadísticas (12K+, 3 min, 70%) en SplashView
- Al darles clic debería sentirse haptic feedback (tap)
- Actualmente solo tienen animación visual (expand/collapse)
- Agregar haptic sutil al interactuar

## Prioridad de Resolución
1. Package.swift warning (trivial, rápido)
2. Idioma a inglés (crítico para SSC)
3. Navegación/back buttons (UX crítico)
4. Kit Builder drop zone y drop action (funcionalidad rota)
5. Haptic feedback en StatBadge (mejora UX)
