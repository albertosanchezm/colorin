# Fase 0 - Diseno tecnico

## Objetivo

Dejar definidos los cimientos del proyecto para arrancar el MVP sin rehacer decisiones base en Fase 1.

## Entregables

- Estructura modular inicial del proyecto Android.
- Convenciones de arquitectura por capas.
- Contrato de datos del dominio.
- Especificacion de assets de dibujo y `zoneMap`.

## Arquitectura propuesta

- `app`: arranque, navegacion, DI y composicion global.
- `core_model`: modelos de dominio puros y enums compartidos.
- `core_data`: repositorios, acceso local, Room y carga de assets.
- `core_ui`: componentes Compose reutilizables y tema visual.
- `feature_catalog`: categorias y listado de dibujos.
- `feature_paint`: lienzo, herramientas y reglas de coloreado.
- `feature_progress`: restauracion de sesiones y galeria local.

## Principios

- Mantener el dominio desacoplado de Android siempre que sea posible.
- Concentrar la logica de coloreado en `feature_paint`.
- Tratar `outline` y `zoneMap` como recursos versionables y validados.
- Separar metadatos persistidos de artefactos pesados como snapshots.

## Decisiones tecnicas iniciales

- Lenguaje: Kotlin.
- UI: Jetpack Compose.
- Estado: `ViewModel` + `StateFlow`.
- Persistencia: Room para metadatos y disco para snapshots y assets.
- Render: Compose Canvas con procesamiento por zonas en memoria.

## Resultado esperado al cerrar Fase 0

- El proyecto ya puede compilar su estructura base.
- El equipo dispone de un contrato de datos estable para empezar Fase 1.
- Existe una especificacion clara para producir dibujos y `zoneMap`.
