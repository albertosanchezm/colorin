# TODO - Colorin

## Prioridad Alta

- [x] Preparar base del proyecto Android con `Kotlin`, `Jetpack Compose` y estructura modular.
- [x] Configurar arquitectura base con `MVVM`, navegación e inyección de dependencias.
- [x] Crear módulos: `app`, `feature_catalog`, `feature_paint`, `feature_progress`, `core_model`, `core_data`, `core_ui`.
- [x] Definir entidades principales: `Category`, `Drawing`, `PaintSession`, `PaletteColor`.
- [x] Diseñar contrato de datos de `Drawing`, incluyendo `outlineAsset`, `zoneMapAsset` y `difficultyTags`.
- [x] Definir formato técnico de `zoneMap` para identificar zonas por `zoneId`.
- [x] Crear cargador local de assets de dibujo.

## MVP Funcional

- [x] Implementar pantalla de categorías.
- [x] Implementar pantalla de listado de dibujos por categoría.
- [x] Implementar navegación desde catálogo hasta editor de coloreado.
- [x] Crear `PaintCanvas` base con render del dibujo y capa de pintura.
- [x] Implementar paleta inicial de 12 a 24 colores.
- [x] Implementar selección de color.
- [x] Implementar modo sencillo: tap sobre zona y relleno completo.
- [x] Implementar detección de zona por coordenada usando `zoneMap`.
- [x] Añadir selector de nivel: sencillo, intermedio y avanzado.
- [ ] Configurar `Room` para metadatos de sesiones y catálogo local.
- [x] Guardar progreso automáticamente.
- [x] Restaurar la última sesión de dibujo.
- [ ] Guardar snapshots de pintura en disco.

## Modos de Pintura

- [ ] Implementar modo intermedio: selección de zona activa y pincel restringido.
- [ ] Implementar máscara binaria por zona para recorte de trazos.
- [ ] Implementar modo avanzado: pintura libre dentro del lienzo.
- [ ] Añadir herramientas básicas: deshacer, rehacer, borrar zona y limpiar.
- [ ] Evaluar persistencia del historial de acciones para restaurar deshacer/rehacer.

## Contenido

- [ ] Crear categorías iniciales: animales, vehículos, naturaleza, fantasía.
- [ ] Preparar lote inicial de 20 dibujos.
- [ ] Generar `outline` visual y `zoneMap` técnico para cada dibujo.
- [ ] Añadir validación automática para detectar zonas mal cerradas o inválidas.

## UX Infantil

- [ ] Diseñar interfaz con botones grandes e iconografía clara.
- [ ] Reducir texto y priorizar elementos visuales.
- [ ] Añadir feedback visual y sonoro simple.
- [ ] Revisar usabilidad en móvil y tablet Android.

## QA

- [ ] Añadir tests unitarios para detección de zonas por coordenada.
- [ ] Añadir tests para máscara y recorte en nivel intermedio.
- [ ] Añadir tests para deshacer/rehacer.
- [ ] Añadir tests instrumentados para flujo completo de cada nivel.
- [ ] Añadir tests de guardado y reanudación.
- [ ] Validar rotación de pantalla y paso a segundo plano.
- [ ] Probar con usuarios infantiles y recoger métricas básicas.

## Fases Recomendadas

### Fase 0

- [x] Base del proyecto, modelo de datos y formato de assets.

### Fase 1

- [x] Catálogo + editor con nivel sencillo + guardado básico.

### Fase 2

- [ ] Nivel intermedio con máscaras por zona.

### Fase 3

- [ ] Nivel avanzado y pulido de UX.

### Fase 4

- [ ] Pruebas, optimización y preparación interna.

## Primer Sprint Sugerido

- [ ] Crear estructura del proyecto y módulos.
- [ ] Definir modelos `Drawing` y `PaintSession`.
- [ ] Definir formato de `zoneMap`.
- [x] Implementar catálogo básico.
- [x] Implementar `PaintCanvas` mínimo.
- [x] Implementar modo sencillo con relleno por tap.
- [x] Guardar progreso local básico.
