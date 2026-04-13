# Modelo de datos base

## Category

Representa una categoria del catalogo.

| Campo | Tipo | Notas |
| --- | --- | --- |
| `id` | `String` | Identificador estable. |
| `name` | `String` | Nombre visible. |
| `icon` | `String` | Recurso o clave de icono. |
| `order` | `Int` | Orden de presentacion. |

## Drawing

Representa un dibujo disponible para colorear.

| Campo | Tipo | Notas |
| --- | --- | --- |
| `id` | `String` | Identificador estable. |
| `categoryId` | `String` | Relacion con `Category`. |
| `title` | `String` | Titulo visible del dibujo. |
| `outlineAsset` | `String` | Ruta del asset visual de lineas. |
| `zoneMapAsset` | `String` | Ruta del asset tecnico de zonas. |
| `difficultyTags` | `Set<DifficultyMode>` | Modos soportados. |

## PaintSession

Representa el progreso local de una sesion de coloreado.

| Campo | Tipo | Notas |
| --- | --- | --- |
| `id` | `String` | Identificador de sesion. |
| `drawingId` | `String` | Dibujo asociado. |
| `mode` | `DifficultyMode` | Modo activo. |
| `lastModifiedEpochMs` | `Long` | Fecha de ultima modificacion. |
| `snapshotPath` | `String?` | Ruta de snapshot renderizado. |
| `actionsPath` | `String?` | Ruta opcional del historial de acciones. |

## PaletteColor

Representa un color seleccionable en la paleta.

| Campo | Tipo | Notas |
| --- | --- | --- |
| `id` | `String` | Identificador estable. |
| `hex` | `String` | Color en formato `#RRGGBB` o `#AARRGGBB`. |
| `order` | `Int` | Orden en la paleta. |
| `isDefault` | `Boolean` | Indica si viene preinstalado. |

## Enumeracion DifficultyMode

- `SIMPLE`: relleno por tap sobre una zona cerrada.
- `MEDIUM`: pincel limitado a una zona activa.
- `ADVANCED`: pintura libre dentro del lienzo.

## Notas de persistencia

- `Category` y `Drawing` pueden inicializarse desde assets empaquetados.
- `PaintSession` se persiste localmente y se restaura al reabrir la app.
- Los snapshots deben almacenarse fuera de la base de datos.
