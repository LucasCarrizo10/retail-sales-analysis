# Verificación con archivos reales

El proyecto se reconstruyó a partir de las decisiones y consultas desarrolladas durante el análisis y luego se contrastó con los **dos archivos entregados por el autor**: `retail_store_sales.csv` y `Analisisdeventas.pbix`.

## Ejecución comprobada

- El notebook `notebooks/01_exploracion_y_limpieza.ipynb` fue **ejecutado por completo** sobre el CSV original del usuario.
- Se generó `data/processed/retail_store_sales_clean.csv` sin sobrescribir el original.
- El resultado contiene **12.575 filas y 12 columnas** (11 originales + indicador de recuperación).
- Se recuperaron **604 productos**; quedaron **609 Items sin identificar**.
- Permanecen **604 importes faltantes** y **4.199 descuentos desconocidos**.
- Se evaluaron **11.362 relaciones precio × cantidad = total**, sin diferencias detectadas.
- Los importes conocidos suman **$1.552.071** y las operaciones sin Item identificable acumulan **$79.072,50**.
- La cobertura de fechas es **2022-01-01 a 2025-01-18**.

## Power BI

Se comprobó que el `.pbix` tiene estructura interna legible y contiene tres páginas:

1. `Resumen Comercial` (KPI, barras por categoría, serie temporal y segmentaciones).
2. `Productos y Clientes` (ranking de productos y dispersión).
3. `Canales y medios de pagos` (dona, columnas, matriz y filtro).

**Alcance de verificación:** esta revisión del `.pbix` fue estructural, sin ejecutar Power BI Desktop. No se aseguró una conexión activa a SQL Server ni se volvieron a probar aquí las interacciones entre los objetos visuales. Las capturas incorporadas corresponden al trabajo original del usuario.

## SQL Server

Los archivos `.sql` conservan la lógica final de las consultas realizadas durante el proyecto, pero **no se ejecutaron contra una instancia SQL Server desde este entorno**. El archivo `01_carga_y_validacion.sql` está preparado para volver a validar la carga localmente.

## Publicación y origen de datos

Los CSV se incluyen en **esta copia de trabajo** para facilitar la reproducibilidad local, pero `.gitignore` impide añadirlos de forma automática a Git. Antes de redistribuirlos públicamente —y antes de publicar el `.pbix`, que puede contener datos importados— revisar la licencia y atribución de la fuente, así como los datos de conexión que pueda contener Power BI.
