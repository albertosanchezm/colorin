# Especificacion de zoneMap

## Objetivo

Permitir detectar de forma rapida y determinista la zona tocada por el usuario y aplicar reglas distintas segun el modo de coloreado.

## Formato recomendado

- Tipo de archivo: PNG sin perdida.
- Resolucion: la misma que el `outline` base.
- Fondo: color reservado para "sin zona".
- Cada region pintable usa un color unico y plano.
- No debe haber antialiasing ni transparencias parciales en los bordes.

## Reglas de codificacion

- Cada color distinto equivale a un `zoneId`.
- El color `#00000000` se reserva para "fuera de zona" o transparente.
- No reutilizar el mismo color para dos zonas desconectadas si luego se quieren tratar por separado.
- El contorno visible no se lee desde el `zoneMap`; solo se usa para logica.

## Flujo de lectura

1. El usuario toca una coordenada del lienzo.
2. El sistema transforma la coordenada al espacio del bitmap base.
3. Se lee el pixel correspondiente en el `zoneMap`.
4. Ese color se traduce a `zoneId`.
5. Se aplican las reglas del modo activo.

## Reglas por modo

### SIMPLE

- Leer `zoneId` en el punto pulsado.
- Rellenar la mascara completa de esa zona con el color activo.

### MEDIUM

- Leer `zoneId` en el tap inicial.
- Fijar `activeZoneId`.
- Recortar cada trazo a la mascara de esa zona.

### ADVANCED

- No usar restriccion por `zoneId`.
- Mantener solo el limite fisico del lienzo.

## Validaciones recomendadas

- Verificar que cada dibujo tenga al menos una zona pintable.
- Detectar colores duplicados no deseados.
- Detectar bordes suavizados que introduzcan colores intermedios.
- Validar que `outline` y `zoneMap` tengan la misma resolucion.

## Convencion de assets

Ejemplo:

- `animals/cat_outline.png`
- `animals/cat_zonemap.png`

## Riesgos conocidos

- Si el asset tiene antialiasing, la lectura por pixel puede devolver colores no mapeados.
- Si el `zoneMap` no coincide en tamano con el `outline`, la deteccion sera incorrecta.
