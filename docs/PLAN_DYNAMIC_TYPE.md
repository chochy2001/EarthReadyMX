# Plan: Dynamic Type Migration

## Objetivo
Migrar todos los textos de `.system(size:)` fijo a Dynamic Type styles para accesibilidad.

## Archivos a modificar (68 cambios en 5 archivos)

### SplashView.swift (6 cambios)
- 42pt title → `.largeTitle` design rounded weight black
- 16pt subtitle → `.subheadline` design rounded weight medium
- 14pt paragraph → `.footnote` design rounded
- 18pt button → `.body` design rounded weight bold
- 16pt stat value → `.callout` design rounded weight bold + minimumScaleFactor(0.7)
- 11/9pt stat label → `.caption2` weight medium + minimumScaleFactor(0.6)

### LearnView.swift (11 cambios)
- 28pt header → `.title` design rounded weight bold
- 14pt subtitle → `.footnote` design rounded weight medium
- 30pt icon → `.title` (SF Symbol)
- 14pt tab text → `.footnote` design rounded weight semibold + minimumScaleFactor(0.8)
- 12pt completion label → `.caption` weight medium
- 14pt mark button → `.footnote` design rounded weight semibold
- 14pt test button → `.footnote` design rounded weight bold
- 18pt tip icon → `.body`
- 16pt tip title → `.callout` design rounded weight semibold
- 12pt tip preview → `.caption`
- 14pt tip description → `.footnote` design rounded

### SimulationView.swift (15 cambios)
- 24pt header → `.title2` design rounded weight bold
- 14pt subtitle → `.footnote` design rounded weight medium
- 12pt progress → `.caption` design rounded weight bold + minimumScaleFactor(0.7)
- 12pt correct/wrong labels → `.caption` design rounded weight medium
- 18pt/14pt compact card → `.body` / `.footnote`
- 36pt scenario icon → `.largeTitle`
- 17pt scenario text → `.headline` design rounded
- 14pt option icons → `.footnote` weight bold
- 15pt option text → `.subheadline` design rounded weight medium
- 16pt/14pt explanation → `.callout`/`.footnote` design rounded
- 16pt next button → `.callout` design rounded weight bold
- 12pt/14pt timer → `.caption`/`.footnote`

### ResultView.swift (14 cambios)
- 48pt score → `.largeTitle` design rounded weight black + minimumScaleFactor(0.5)
- 16pt score label → `.callout` design rounded weight medium
- 26pt title → `.title2` design rounded weight bold
- 15pt message → `.subheadline` design rounded
- 18pt section headers → `.body` design rounded weight bold
- 20pt icons → `.title3`
- 14pt/12pt scenario labels → `.footnote`/`.caption`
- 16pt prepare button → `.callout` design rounded weight bold
- 14pt start over → `.footnote` design rounded weight semibold
- 13pt share text → `.footnote` design rounded weight medium
- 16pt/14pt/12pt takeaway → `.callout`/`.footnote`/`.caption`

### ChecklistView.swift (22 cambios)
- 24pt header → `.title2` design rounded weight bold
- 13pt subtitle → `.footnote` design rounded weight medium
- 20pt percentage → `.title3` design rounded weight black + minimumScaleFactor(0.7)
- 32pt ring count → `.title` design rounded weight black + minimumScaleFactor(0.5)
- 14pt labels → `.footnote` design rounded weight medium
- 11pt source → `.caption2` design rounded weight medium
- 14pt/16pt buttons/nav → `.footnote`/`.callout`
- 18pt/20pt/16pt/13pt detail → `.body`/`.title3`/`.callout`/`.footnote`
- 11pt priority header → `.caption2` design rounded weight bold
- 20pt/16pt/12pt/14pt card → `.title3`/`.callout`/`.caption`/`.footnote`
- 12pt/14pt/12pt item row → `.caption`/`.footnote`/`.caption`
- 14pt checkbox icon → `.footnote` weight bold

### SceneIllustration.swift - NO TOCAR (decorativo)
