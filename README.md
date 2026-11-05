# Retail Store Sales | De datos incompletos a decisiones comerciales

**Proyecto de análisis de datos:** exploración y limpieza con Python/Pandas, validación y análisis en SQL Server, y visualización interactiva en Power BI.

> **Pregunta de negocio:** ¿qué categorías y productos generan mayores ingresos, cómo evolucionan las ventas, qué comportamiento tienen los clientes y qué diferencias existen entre canales y medios de pago?

## Resumen

Se analizaron **12.575 transacciones** de una tienda minorista, correspondientes al período **1 de enero de 2022 al 18 de enero de 2025**. El año 2025 está incompleto; las comparaciones entre años completos se centran en 2022–2024.

El objetivo no fue solamente construir gráficos, sino **convertir información con problemas de calidad en indicadores útiles**, explicando los supuestos, las limitaciones y las decisiones tomadas durante el proceso.

## Herramientas y por qué las elegí

| Herramienta | Uso en el proyecto | Motivo |
|---|---|---|
| **Python + Pandas** | Perfilado, investigación de nulos, transformaciones y exportación del CSV limpio | Permite examinar patrones de datos faltantes y documentar transformaciones reproducibles. |
| **SQL Server + SSMS** | Almacenamiento, comprobaciones posteriores a la carga y consultas comerciales | Permite validar el destino y responder preguntas con agregaciones, CTE y funciones de ventana. |
| **Power BI + DAX** | Dashboard interactivo de tres páginas | Facilita que un usuario de negocio explore indicadores por año y otros filtros, sin leer consultas SQL. |

## Proceso de trabajo

1. **Exploración:** revisión de estructura, tipos, nulos, duplicados y consistencia aritmética.
2. **Limpieza:** recuperación controlada de 604 valores de `Item` mediante combinaciones únicas conocidas de categoría y precio; preservación de nulos que no podían recuperarse con evidencia suficiente.
3. **Preparación:** conversión de fechas, tratamiento nullable de descuentos y creación del indicador `Item_Fue_Recuperado` para trazabilidad.
4. **Carga y validación:** importación a SQL Server, comparación de totales con Pandas y corrección de un problema de interpretación decimal.
5. **Análisis SQL:** respuesta a cinco preguntas de negocio con agregaciones, filtros, CTE, `LAG()` y `ROW_NUMBER()`.
6. **Visualización:** desarrollo de tres páginas en Power BI para comunicar resultados y explorar los datos.

### Un incidente de calidad importante

En la primera importación, el asistente de SQL Server interpretó incorrectamente importes decimales. Una transacción que en Pandas tenía **precio 11, cantidad 5 y total 55** aparecía en SQL Server como **precio 110, cantidad 5 y total 550**.

Aunque llegaron las **12.575 filas** y la igualdad `precio × cantidad = total` seguía cumpliéndose, **los valores no coincidían con el origen**. Se corrigió la carga importando inicialmente precio y total como texto y convirtiéndolos después mediante `TRY_CONVERT(DECIMAL(18,2), ...)`, con verificaciones previas. La tabla validada recuperó el importe agregado esperado de **$1.552.071**.

Este caso reforzó una lección central del proyecto: **validar cantidades de filas no basta; también hay que contrastar valores entre origen y destino**.

## Hallazgos principales

| Pregunta | Hallazgo |
|---|---|
| Categorías | **Butchers** lideró en ingresos registrados, con **$208.118**, sin ser la categoría con más transacciones. |
| Productos | **Item_2_BEV** registró la mayor frecuencia (**130 transacciones**), pero **Item_25_FUR** lideró en ingresos conocidos (**$25.256**). |
| Evolución temporal | **Enero** tuvo el mayor promedio de ingresos mensuales entre 2022 y 2024 (**$49.624,17**). No se afirma estacionalidad definitiva con solo tres años. |
| Clientes | **CUST_05** realizó más transacciones (**544**) y **CUST_24** registró el mayor gasto conocido (**$68.452**). Los 25 clientes aparecen con compras en los 36 meses de 2022–2024. |
| Canales y pagos | **Online** registró **$791.401** frente a **$760.670** de In-store. **Cash** lideró entre los medios de pago con **4.310 transacciones** y **$537.710** de ingresos registrados. |

**Implicación comercial:** la frecuencia de compra y los ingresos son métricas distintas. Antes de recomendar retirar productos o invertir más en un canal, se necesita información sobre **costos, márgenes y gastos operativos**.

## Dashboard Power BI

El informe interactivo está organizado en:

- **Resumen comercial:** indicadores principales, ingresos por categoría y evolución mensual.
- **Productos y clientes:** rankings por ingresos y transacciones, y comparación del comportamiento de clientes.
- **Canales y medios de pago:** participación por canal, ingresos por forma de pago y matriz de comparación cruzada.

El archivo [.pbix](powerbi/Analisisdeventas.pbix) y las capturas están incorporados de Power BI; no están incluidos en esta carpeta base.

## Calidad de datos y limitaciones

- **604** valores de producto se recuperaron mediante una correspondencia inferida de **categoría + precio**; idealmente se validaría contra un catálogo oficial.
- **609** transacciones permanecen sin producto identificado. Sus importes registrados suman **$79.072,50** (**5,09%** del total conocido), por lo que los rankings por producto son incompletos.
- **604** transacciones carecen de cantidad e importe; no se inventaron valores para completarlas.
- **4.199** registros tienen estado de descuento desconocido. No se pudo determinar si `Total_Spent` refleja descuentos aplicados.
- No se dispone de **costos** para evaluar rentabilidad de productos, clientes o canales.
- **2025** comprende solo hasta el **18 de enero** y no se compara directamente contra años completos.

> Los importes se presentan como **ingresos registrados**, no como una estimación de facturación total ni de utilidad. El símbolo `$` sigue la presentación utilizada en el análisis; no presupone una moneda nacional específica.

## Organización del repositorio

```text
retail-sales-analysis/
├── README.md
├── requirements.txt
├── data/
│   ├── raw/retail_store_sales.csv                 # Copia local, ignorada por Git
│   └── processed/retail_store_sales_clean.csv    # Generada y validada
├── docs/
│   ├── metodologia_tecnica.md
│   └── verificacion_con_archivos_reales.md
├── notebooks/01_exploracion_y_limpieza.ipynb
├── sql/
│   ├── 01_carga_y_validacion.sql
│   ├── 02_consultas_de_negocio.sql
│   └── 03_analisis_temporal.sql
├── powerbi/Analisisdeventas.pbix
├── reportes/
│   ├── resumen_ejecutivo.md
│   └── informe_de_resultados.md
└── imagenes/                                    # Capturas de las tres páginas
```

## Reproducibilidad

1. Usar el dataset de práctica **Retail Store Sales: Dirty for Data Cleaning**. En esta copia de trabajo ya está disponible en `data/raw/`; al publicar en GitHub, cada lector deberá obtenerlo de la fuente original hasta que se verifique su licencia.
2. Guardarlo como **`data/raw/retail_store_sales.csv`**. Instalar las dependencias desde `requirements.txt` y ejecutar [`notebooks/01_exploracion_y_limpieza.ipynb`](notebooks/01_exploracion_y_limpieza.ipynb). El notebook realiza las transformaciones, valida los conteos originales y exporta el CSV limpio.
3. Importar `data/processed/retail_store_sales_clean.csv` mediante SSMS a `dbo.RetailSales_Prueba`. **Importar `Price_Per_Unit` y `Total_Spent` como `VARCHAR(50)`**, renombrando los encabezados según las instrucciones de [`sql/README.md`](sql/README.md).
4. Ejecutar [`sql/01_carga_y_validacion.sql`](sql/01_carga_y_validacion.sql), que convierte los importes a `DECIMAL(18,2)`, crea la tabla validada y verifica su consistencia.
5. Ejecutar [`sql/02_consultas_de_negocio.sql`](sql/02_consultas_de_negocio.sql) y [`sql/03_analisis_temporal.sql`](sql/03_analisis_temporal.sql).
6. Abrir [`powerbi/Analisisdeventas.pbix`](powerbi/Analisisdeventas.pbix) y, si corresponde, configurar su conexión a la instancia SQL Server local.

**Verificación real:** el notebook se ejecutó correctamente con el CSV aportado por el autor y generó los totales esperados; los scripts SQL no se reejecutaron contra una instancia SQL Server en esta sesión. El `.pbix` recibido se inspeccionó estructuralmente y contiene las tres páginas descritas, pero no se abrió en Power BI Desktop desde este entorno. Detalles en [`docs/verificacion_con_archivos_reales.md`](docs/verificacion_con_archivos_reales.md).

**Publicación:** los dos CSV se incluyen en la descarga para uso local, pero están excluidos de Git. Revisar la licencia y atribución del dataset antes de redistribuirlo y revisar el `.pbix` antes de publicarlo, ya que puede incorporar datos y referencias al servidor local.

## Documentación complementaria

Ver [Metodología y decisiones técnicas](docs/metodologia_tecnica.md), [Verificación con archivos originales](docs/verificacion_con_archivos_reales.md), [Resumen ejecutivo](reportes/resumen_ejecutivo.md) e [Informe de resultados](reportes/informe_de_resultados.md).
