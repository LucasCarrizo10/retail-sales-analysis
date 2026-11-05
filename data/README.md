# Archivos de datos

- `raw/retail_store_sales.csv`: archivo fuente aportado por el autor, sin modificaciones.
- `processed/retail_store_sales_clean.csv`: salida reproducible del notebook `../notebooks/01_exploracion_y_limpieza.ipynb`.

**Distribución:** ambos CSV están presentes en el paquete descargable para poder ejecutar el proyecto, pero permanecen excluidos de Git por `.gitignore`. Antes de incluirlos en un repositorio público, comprobá los términos de uso de la fuente original.

## SQL Server

Importar el CSV limpio a `dbo.RetailSales_Prueba` con `Price_Per_Unit` y `Total_Spent` como `VARCHAR(50)` y luego ejecutar `../sql/01_carga_y_validacion.sql`. La separación evita la interpretación incorrecta del punto decimal ocurrida durante la primera carga.
