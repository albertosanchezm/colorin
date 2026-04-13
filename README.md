# Colorin

Bases de desarrollo para una app Android de colorear para niños.

## 1) Objetivo del producto
Crear una aplicación móvil Android orientada a niños para colorear dibujos por temáticas, con tres modos de dificultad:

- **Nivel sencillo**: tap sobre una zona cerrada para rellenarla con un color.
- **Nivel intermedio**: pintura con dedo, pero con restricción para no salirse de una zona seleccionada.
- **Nivel avanzado**: pintura libre sin restricciones.

## 2) Alcance funcional (MVP)

### Funcionalidades principales
1. **Catálogo de dibujos categorizados**
   - Temáticas iniciales: animales, vehículos, naturaleza, fantasía.
   - Pantalla de categorías y pantalla de listado de dibujos.

2. **Editor de coloreado**
   - Paleta de colores (12–24 colores iniciales).
   - Herramientas básicas: deshacer, rehacer, borrar zona, guardar progreso.
   - Selector de nivel (sencillo, intermedio, avanzado).

3. **Persistencia local**
   - Guardado automático del progreso de cada dibujo.
   - Reanudación de dibujo desde el último estado.

4. **Perfil infantil simple (opcional en MVP)**
   - Nombre/avatar local.
   - Historial de dibujos completados.

## 3) Propuesta técnica

### Stack recomendado
- **Lenguaje**: Kotlin.
- **UI**: Jetpack Compose.
- **Arquitectura**: Clean Architecture + MVVM.
- **Estado**: StateFlow / ViewModel.
- **Persistencia**: Room (metadatos) + almacenamiento de bitmaps/SVG en disco.
- **Render gráfico**: Canvas de Compose + motor de máscaras por zonas.

### Módulos sugeridos
- `app`: navegación, inyección y bootstrap.
- `feature_catalog`: categorías y selección de dibujo.
- `feature_paint`: lienzo, herramientas y lógica de coloreado.
- `feature_progress`: guardado/carga y galería de resultados.
- `core_model`: entidades de dominio.
- `core_data`: repositorios y fuentes locales.
- `core_ui`: componentes reutilizables.

## 4) Modelo de datos base

### Entidades principales
- **Category**: `id`, `name`, `icon`, `order`.
- **Drawing**: `id`, `categoryId`, `title`, `outlineAsset`, `zoneMapAsset`, `difficultyTags`.
- **PaintSession**: `id`, `drawingId`, `mode`, `lastModified`, `snapshotPath`, `actions`.
- **PaletteColor**: `id`, `hex`, `order`, `isDefault`.

### Formato de recursos de dibujo
Se recomienda usar dos capas por dibujo:
1. **Outline (visual)**: imagen/SVG de líneas.
2. **Zone map (técnica)**: mapa de zonas con color-id único por región (no visible al usuario).

Esto permite identificar qué zona toca el niño y aplicar reglas por nivel.

## 5) Lógica por niveles

### Nivel sencillo (relleno por tap)
- Flujo:
  1. Niño selecciona color.
  2. Toca una zona cerrada.
  3. El sistema detecta `zoneId` por coordenada y rellena toda la zona.
- Técnica:
  - Búsqueda de zona por lectura de píxel en `zoneMap`.
  - Relleno inmediato de la máscara de esa zona en la capa de pintura.

### Nivel intermedio (pincel restringido)
- Flujo:
  1. Niño selecciona color.
  2. Selecciona zona (tap inicial).
  3. Pinta con dedo solo dentro de la zona.
- Técnica:
  - Mantener `activeZoneId`.
  - Cada trazo se recorta con una máscara binaria de la zona.
  - Si el trazo sale, se ignora fuera de la máscara.

### Nivel avanzado (pintura libre)
- Flujo:
  1. Niño selecciona color.
  2. Pinta libremente.
- Técnica:
  - No aplicar máscara por zona.
  - Solo límites del lienzo.

## 6) Requisitos no funcionales
- **Rendimiento**: 60 FPS objetivo en dispositivos gama media.
- **Latencia táctil**: respuesta del trazo < 16ms ideal.
- **Estabilidad**: recuperación ante cierre inesperado (autosave).
- **Accesibilidad infantil**:
  - Botones grandes.
  - Poco texto, más iconografía.
  - Feedback sonoro/visual simple.
- **Modo offline**: catálogo y coloreado totalmente local.

## 7) QA y pruebas

### Pruebas unitarias
- Detección de zona por coordenada.
- Aplicación de máscara en nivel intermedio.
- Comportamiento de deshacer/rehacer.

### Pruebas instrumentadas/UI
- Flujo completo por cada nivel.
- Guardado y reanudación de sesión.
- Rotación de pantalla / background-foreground.

### Pruebas de usuario
- Sesiones con niños (5–8 años) supervisadas.
- Métricas: tiempo de completar, errores de interacción, abandono.

## 8) Hoja de ruta por fases
1. **Fase 0 (1 semana): Diseño técnico**
   - Definir formato de assets de dibujo y POC de lienzo.
2. **Fase 1 (2–3 semanas): MVP funcional**
   - Catálogo + nivel sencillo + guardado básico.
3. **Fase 2 (2 semanas): Nivel intermedio**
   - Máscaras por zona + optimización de trazos.
4. **Fase 3 (1–2 semanas): Nivel avanzado y pulido UX**
   - Pintura libre + mejoras de interfaz infantil.
5. **Fase 4 (1 semana): QA final y publicación interna**

## 9) Riesgos y mitigaciones
- **Riesgo**: assets con zonas mal cerradas.
  - **Mitigación**: validación automática de `zoneMap` al importar dibujos.
- **Riesgo**: consumo elevado de memoria en bitmaps.
  - **Mitigación**: tamaños máximos por lienzo y cache controlada.
- **Riesgo**: trazos poco fluidos en equipos modestos.
  - **Mitigación**: simplificación de path y render incremental.

## 10) Siguientes pasos inmediatos
1. Definir contrato de datos de `Drawing` y formato de `zoneMap`.
2. Implementar prototipo de `PaintCanvas` con los 3 modos.
3. Crear lote inicial de 20 dibujos en 4 temáticas.
4. Montar pruebas con 3–5 usuarios infantiles para validar UX temprana.
