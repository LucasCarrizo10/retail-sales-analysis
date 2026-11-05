# Consultas SQL — Retail Store Sales

**Motor:** Microsoft SQL Server. **Base:** `RetailStoreDB`. **Tabla final:** `dbo.RetailSales_Validada`.

## Orden de ejecución

1. Ejecutar el notebook `../notebooks/01_exploracion_y_limpieza.ipynb`, para exportar `data/processed/retail_store_sales_clean.csv`.
2. En SSMS, usar **Import Flat File** e importar ese CSV como `dbo.RetailSales_Prueba`. Renombrar las 12 columnas al esquema indicado en `01_carga_y_validacion.sql`. Es fundamental importar `Price_Per_Unit` y `Total_Spent` como `VARCHAR(50)` para preservar el separador decimal, como se hizo al corregir el problema de la primera carga.
3. Ejecutar **`01_carga_y_validacion.sql`**: comprueba valores numéricos, crea `dbo.RetailSales_Validada` sin sobrescribir tablas existentes y comprueba integridad, nulos e importes.
4. Ejecutar **`02_consultas_de_negocio.sql`**: categorías, productos, clientes, canales y medios de pago.
5. Ejecutar **`03_analisis_temporal.sql`**: meses, rankings mensuales, períodos equivalentes y variación con `LAG()`.

## Qué se omitió intencionalmente

- Consultas de prueba que no se utilizaron para tomar decisiones.
- Rankings ordenados por una métrica equivocada durante el aprendizaje.
- Consultas repetidas antes de corregir la tabla con importes multiplicados por diez.
- Pruebas `SELECT TOP 10 *` y validaciones redundantes: se sustituyeron por controles reproducibles.

> `COUNT(*)` mide transacciones, incluso sin importe; `COUNT(Total_Spent)` cuenta únicamente las transacciones con un importe disponible. Los **604 importes faltantes** permanecen desconocidos y **no se imputan**.

La tabla original incorrecta (`dbo.RetailSales`) no se usa en ningún script de análisis. El nombre `RetailSales_Prueba` identifica la importación de staging del CSV limpio.
