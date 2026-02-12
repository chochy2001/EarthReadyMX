# Issues V3 - Rediseño de Flujo + Video + Mejoras

## Feedback del Usuario (Jorge)

### 1. Flujo Actual es Aburrido
- Después del splash, ir directo al "Safety Protocol" (Learn) es aburrido
- No hay contexto emocional antes de empezar a aprender
- El usuario quiere algo más impactante antes del contenido educativo

### 2. Nuevo Flujo Propuesto
```
Splash → Video Impactante (sismo 2017) → Quiz → Safety Protocol → Kit Builder → Drill → Checklist
```

**Cambios:**
- DESPUÉS del splash: mostrar un video/animación impactante sobre el sismo de 2017 en CDMX
- El video debe explicar qué pasó, la gente afectada, la devastación
- DESPUÉS del video: ir directo al Quiz (simulation) para probar conocimientos
- DESPUÉS del quiz: ahora sí el Safety Protocol (learn) para enseñar lo correcto
- Después del Safety Protocol: Kit Builder, Drill, Checklist

### 3. Video/Animación del Sismo 2017
- Debe ser atractivo e impactante
- Contar la historia del sismo 7.1 del 19 de septiembre de 2017
- 250+ vidas perdidas
- Mostrar la importancia de la preparación
- Investigar Remotion (https://www.remotion.dev/docs/ai/claude-code) para crear el video
- El video debe ser emocional y motivar al usuario a aprender

### 4. Completar el Ciclo de la App
- Cuando el usuario termina todo (100% preparedness), solo hay "Start Over"
- Considerar: qué pasa cuando ya completaste todo?
- Mejorar la experiencia de "completado"

## Consideraciones Técnicas
- SSC tiene límite de 25MB para el bundle
- Un video MP4 puede ser muy pesado
- Alternativa: animación nativa en SwiftUI (tipo storytelling animado)
- Remotion genera videos en React/JS - hay que ver si es viable para .swiftpm
- Si el video es demasiado pesado, usar animación programática con SwiftUI

## Prioridades
1. Investigar Remotion y viabilidad
2. Definir el contenido del video/animación
3. Rediseñar el flujo de navegación (AppPhase)
4. Implementar video/animación
5. Reordenar fases
6. Mejorar experiencia de completado
