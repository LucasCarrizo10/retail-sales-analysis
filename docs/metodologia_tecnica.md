# Metodología y decisiones técnicas

**Proyecto:** Retail Store Sales  
**Origen de los datos:** dataset de práctica de ventas minoristas utilizado para limpieza y análisis  
**Período observado:** 2022-01-01 a 2025-01-18  
**Registro de trabajo:** decisiones realizadas durante el desarrollo del proyecto con Python/Pandas, SQL Server y Power BI.

## 1. Criterio de elección de herramientas

### Python y Pandas: inspección y preparación

Se eligió Pandas para explorar tipos de datos, contar nulos, examinar **patrones conjuntos de ausencia**, buscar duplicados, comprobar operaciones matemáticas y aplicar cambios sin sobrescribir el dataset original. Se trabajó con una copia (`df_limpio`) para conservar los datos fuente.

### SQL Server y SSMS: almacenamiento y análisis

Se eligió SQL Server para trabajar con datos tipados, validar la carga y practicar consultas orientadas al negocio. Las preguntas se resolvieron con `SUM`, `COUNT`, `AVG`, `GROUP BY`, CTE, `LAG()` y `ROW_NUMBER()`. SSMS permitió inspeccionar los resultados y contrastarlos con Pandas.

### Power BI y DAX: comunicación y exploración

Se utilizó Power BI para crear indicadores dinámicos y filtros, mantener separadas las preguntas comerciales por página y ayudar al gerente a explorar los hallazgos. Las medidas DAX diferencian **transacciones totales** y **transacciones con importe**, evitando confundir frecuencia con datos económicos disponibles.

## 2. Perfilado inicial del dataset

- **12.575 filas**, **11 columnas** originales.
- **0 filas duplicadas** y **0 `Transaction ID` duplicados**.
- **25 clientes** identificados y **8 categorías**.
- `Transaction Date` se recibió como texto y se transformó a `datetime` para análisis temporal.

| Campo | Nulos iniciales | Tratamiento |
|---|---:|---|
| `Item` | 1.213 | Recuperación condicional de 604; 609 permanecen nulos. |
| `Price Per Unit` | 609 | Se conservaron nulos por falta de precio verificable. |
| `Quantity` | 604 | Se conservaron nulos: no existe información suficiente para inferir la cantidad. |
| `Total Spent` | 604 | Se conservaron nulos: no existe información suficiente para recuperar el importe. |
| `Discount Applied` | 4.199 | Se preservó el estado desconocido con tipo `boolean` nullable. |

## 3. Decisiones de limpieza

### 3.1. Identificación de productos faltantes

Se investigó si los registros con `Item` conocido tenían una relación consistente entre `Category`, `Price Per Unit` y el identificador del producto.

En los datos conocidos se encontraron **200 combinaciones de categoría y precio**, cada una asociada a un único identificador de producto. Se utilizó esa correspondencia para recuperar **604 valores** de `Item` faltantes.

**Salvaguardas:**

- No completar si el par categoría/precio no está disponible.
- No completar si una combinación conocida resulta ambigua.
- Guardar el indicador `Item_Fue_Recuperado` para distinguir información original e inferida.
- Reconocer que esta inferencia es **válida bajo el patrón observado**, no una confirmación de un catálogo maestro. Cambios de precios o coincidencias entre productos podrían invalidarla.

Quedaron **609 registros** sin `Item` ni `Price Per Unit`. Dado que conservan `Category`, `Quantity` y `Total Spent`, participan en agregaciones por categoría, pero no se asignan a un producto específico.

### 3.2. Cantidad e importe desconocidos

En **604 transacciones** faltan `Quantity` y `Total Spent`. Conocer un producto y su precio no permite deducir cuántas unidades se vendieron cuando el importe de esa transacción también se desconoce.

**Decisión:** conservar `NULL` en ambos campos. Para evaluar frecuencia de compra se cuentan transacciones con identificador disponible; para ingresos se utilizan solamente importes conocidos. No se imputan promedios ni se inventan montos.

### 3.3. Descuentos

Se encontraron **4.199 valores faltantes** en `Discount Applied`. Se conservaron como desconocidos (`pd.NA`); no se reemplazaron por `False`, porque *sin descuento* y *sin información del descuento* no son equivalentes.

La igualdad entre precio, cantidad e importe de los registros completos no prueba que se hayan descontado promociones correctamente. El dataset no aporta porcentajes o montos de descuento suficientes para verificarlo.

### 3.4. Fechas, tipos y duplicados

- `Transaction Date` se convirtió a `datetime`; no aparecieron fechas inválidas en el control efectuado.
- `Discount Applied` pasó a booleano nullable.
- Para exportar `Quantity` con nulos, se utilizó el entero nullable de Pandas (`Int64`), evitando valores escritos con sufijo `.0`.
- No se detectaron duplicados de fila ni de identificador de transacción.
- Las columnas `Category`, `Payment Method` y `Location` no tenían nulos ni espacios externos; se mantuvieron.

### 3.5. Consistencia matemática

En **11.362 registros** había información completa en `Price Per Unit`, `Quantity` y `Total Spent`. En todos ellos se verificó:

```text
Total Spent = Price Per Unit × Quantity
```

Se obtuvo **0 diferencias matemáticas**. Las otras **1.213 filas** no tenían todos los campos necesarios para realizar esta prueba. La consistencia aritmética interna, por sí sola, no confirma que los valores originales sean correctos.

## 4. Incidente de importación en SQL Server

### 4.1. Qué ocurrió

La primera carga conservó **12.575 registros**, pero algunos importes aparecían multiplicados por diez. El origen exacto del comportamiento no quedó confirmado; una interpretación del separador decimal o una configuración regional durante la importación es una hipótesis probable.

Caso contrastado por `Transaction_ID = TXN_1002182`:

| Campo | Pandas | Primera importación SQL |
|---|---:|---:|
| Precio por unidad | 11,00 | 110,00 |
| Cantidad | 5 | 5 |
| Importe | 55,00 | 550,00 |

El total general también difería:

- **Pandas:** $1.552.071.
- **Primera tabla SQL:** $15.520.710.

### 4.2. Por qué pasó inadvertido al principio

Se habían comprobado los conteos, los duplicados y la relación `precio × cantidad = importe`. Todos esos controles podían pasar incluso si **precio e importe se multiplicaban por diez simultáneamente**.

**Lección:** contrastar además totales, rangos y muestras a nivel transacción entre el origen y el destino.

### 4.3. Cómo se resolvió

1. Se mantuvo intacta la tabla incorrecta mientras se investigaba.
2. Se volvió a importar el CSV a `RetailSales_Prueba`, con `Price_Per_Unit` y `Total_Spent` como `VARCHAR` para preservar el texto original.
3. Se comprobó la transacción de referencia: `11.0`, `5`, `55.0`.
4. Se verificó la conversión mediante `TRY_CONVERT(DECIMAL(18,2), ...)`.
5. Se obtuvieron **0 conversiones inválidas**, un mínimo de precio de **5,00**, un máximo de **41,00** y el total esperado de **$1.552.071**.
6. Se creó `RetailSales_Validada` a partir de la tabla de prueba con tipos numéricos correctos.
7. Se volvieron a comprobar las **12.575 filas**, los **12.575 IDs únicos** y los mismos conteos de nulos que en Pandas.

**Consideración de modelado:** `SELECT INTO` crea una tabla nueva, pero no transfiere automáticamente las restricciones, como la clave primaria. Deben verificarse y agregarse explícitamente si se requieren.

## 5. Reglas de interpretación de los indicadores

| Indicador | Cálculo | Precaución |
|---|---|---|
| Transacciones | `COUNT(*)` o `COUNTROWS()` | Incluye operaciones sin importe. |
| Transacciones con importe | `COUNT(Total_Spent)` | No mide todas las compras; solo las de importe conocido. |
| Ingresos registrados | `SUM(Total_Spent)` | Ignora `NULL`; no equivale necesariamente a facturación completa. |
| Ticket promedio conocido | `AVG(Total_Spent)` o ingresos / transacciones con importe | Calculado solamente con transacciones cuyo importe está disponible. |
| Frecuencia por producto | Conteo de transacciones con `Item` identificado | Los 609 `Item` desconocidos no pueden asignarse a productos. |

Se identificaron **$79.072,50** con importe pero sin producto identificado, equivalentes al **5,09% de los ingresos registrados**. Por ello, un ranking por producto puede subestimar ingresos individuales.

## 6. Análisis temporal

Los datos cubren desde el **1 de enero de 2022** hasta el **18 de enero de 2025**. Las comparaciones de años completos se realizaron entre **2022, 2023 y 2024**.

Para contrastar 2025 con años anteriores se comparó el **mismo tramo del 1 al 18 de enero** en cada año. Allí, los ingresos registrados variaron **−9,94% en 2024 frente a 2023** y **−3,58% en 2025 frente a 2024**.

El mayor promedio mensual entre 2022 y 2024 fue **enero ($49.624,17)**. Es un posible indicio de estacionalidad, pero no una prueba concluyente: solo se dispone de tres años completos y existen registros con importes faltantes.

## 7. Diseño de Power BI

- **Página 1 — Resumen comercial:** cuatro tarjetas KPI, ingresos por categoría y evolución mensual con fecha `Inicio_Mes`.
- **Página 2 — Productos y clientes:** rankings por ingresos y frecuencia, más dispersión de clientes por transacciones e ingresos.
- **Página 3 — Canales y medios de pago:** dona con participación por canal, columnas por medio de pago y matriz cruzada.

Se mantuvieron tres páginas para preservar legibilidad y evitar una página única saturada. Se eligieron barras para rankings, línea para secuencia temporal, dispersión para relación entre dos métricas y dona para la participación de **solo dos canales**.

El informe incluye segmentación por año. Al interpretar el gráfico temporal se debe recordar que 2025 es un período parcial.

## 8. Conclusiones, recomendaciones y trabajo pendiente

Los ingresos registrados permiten señalar categorías, productos y segmentos destacados, pero **no permiten concluir rentabilidad** sin costos y márgenes.

Próximos pasos analíticos útiles:

1. Incorporar catálogo maestro de productos y control de cambios de precios.
2. Recuperar registros faltantes desde el sistema de facturación, si existe una fuente confiable.
3. Añadir costos unitarios, gastos operativos y comisiones para evaluar rentabilidad.
4. Incorporar una tabla calendario y métricas de calidad de datos en Power BI.
5. Automatizar validaciones antes y después de cargas futuras.

## 9. Archivos técnicos y evidencia

La versión consolidada del notebook se encuentra en [`../notebooks/01_exploracion_y_limpieza.ipynb`](../notebooks/01_exploracion_y_limpieza.ipynb); las consultas curadas y agrupadas están en [`../sql/README.md`](../sql/README.md), [`../sql/01_carga_y_validacion.sql`](../sql/01_carga_y_validacion.sql), [`../sql/02_consultas_de_negocio.sql`](../sql/02_consultas_de_negocio.sql) y [`../sql/03_analisis_temporal.sql`](../sql/03_analisis_temporal.sql).

El notebook fue **reconstruido a partir del proceso explicado durante el proyecto** y se comprobó técnicamente con un ejemplo sintético pequeño; **no se dispone del CSV real en esta conversación para reejecutar sus 12.575 registros**. El propio notebook incluye controles que deben coincidir con los resultados ya validados antes de exportar.

Quedan por incorporar los archivos originales `.pbix`, el informe final y capturas finales. Tampoco se distribuye el CSV original sin revisar los derechos de reutilización.
