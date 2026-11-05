# Dashboard de Power BI

- **Archivo:** [`Analisisdeventas.pbix`](Analisisdeventas.pbix), aportado por el autor del proyecto.
- **Páginas verificadas en la estructura del archivo:** `Resumen Comercial`, `Productos y Clientes`, `Canales y medios de pagos`.
- **Origen del modelo:** conexión utilizada por el autor con SQL Server, tabla `dbo.RetailSales_Validada`.
- **Medidas principales:** ingresos registrados, total de transacciones, transacciones con importe y ticket promedio.
- **Nota de apertura:** el reporte puede necesitar reconfigurar el origen de SQL Server a la instancia local del lector. Si el libro contiene datos importados, Power BI puede mostrarlos sin conectarse a SQL hasta la actualización.
- **Alcance de la revisión:** se inspeccionó la estructura interna del `.pbix`; no se ejecutó Power BI Desktop, ni se validaron las interacciones en esta sesión. El autor sí había verificado visualmente dichas interacciones durante el desarrollo.
- **Antes de publicar:** revisar las propiedades de conexión y los permisos de redistribución del dataset; el `.pbix` puede incluir datos importados y metadatos del entorno local.

## Capturas

Véanse las tres capturas preparadas a partir de pantallas del propio proyecto en [`../imagenes/`](../imagenes/). La captura del resumen comercial muestra el filtro del año **2024** activo.
