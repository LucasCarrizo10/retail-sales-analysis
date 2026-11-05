# Informe de resultados — Retail Store Sales

**Datos analizados:** 12.575 transacciones del 01/01/2022 al 18/01/2025. Se utiliza el dataset limpiado, con **$1.552.071 de importes conocidos**. Las cifras con el símbolo `$` respetan la presentación elegida en el proyecto y no identifican una moneda nacional.

## 1. ¿Qué categorías generan mayores ingresos?

**Butchers** lidera con **$208.118** de ingresos registrados y 1.568 transacciones totales. Su ticket promedio sobre las 1.496 transacciones con importe asciende aproximadamente a **$139,12**, mayor que el resto de categorías. La frecuencia de compra y el ingreso registrado deben analizarse por separado. La suma por categoría incluye los importes de transacciones cuyo producto individual es desconocido.

## 2. ¿Qué productos tienen mayor y menor desempeño?

- **Mayor frecuencia:** `Item_2_BEV`, presente en **130 transacciones** (126 con importe conocido).
- **Mayor importe conocido:** `Item_25_FUR`, con **$25.256** (119 transacciones, 113 con importe).
- **Menor frecuencia entre productos identificados:** `Item_3_EHE`, con **5 transacciones** y **$224** de ingresos registrados.

No se recomienda eliminar productos únicamente por su volumen de operaciones. Faltan costos, márgenes y datos de rotación. Hay **609 transacciones sin producto identificable** y otras **604 con importes faltantes**, por lo que los rankings económicos tienen limitaciones.

## 3. ¿Cómo evolucionaron los ingresos?

Entre **2022 y 2024**, enero tuvo el **mayor promedio mensual** de ingresos registrados (**$49.624,17**), mientras que octubre presentó el menor (**$39.804,50**). Enero lideró en 2022 y 2023; diciembre lideró en 2024. Es una señal inicial, no una prueba concluyente de estacionalidad.

Para comparar el período parcial de 2025, se contrastaron **los días 1–18 de enero** de cada año. La variación interanual de importes registrados fue **+1,78%** en 2023, **−9,94%** en 2024 y **−3,58%** en 2025. La última variación no debe extrapolarse a todo el año. La cantidad de operaciones sin importe también cambió entre períodos.

## 4. ¿Cómo se comportan los clientes?

El cliente `CUST_05` realizó **544 transacciones**, la mayor frecuencia del dataset. `CUST_24` registró el **mayor gasto conocido**, **$68.452**, con 543 transacciones. Los **25 clientes** aparecen con actividad en los **36 meses** de 2022–2024. La recurrencia registrada no equivale automáticamente a fidelidad y, por tratarse de un dataset de práctica, no se deben inferir motivaciones o causalidad.

## 5. ¿Qué diferencias existen entre los canales y los medios de pago?

- **Online:** 6.354 transacciones y **$791.401** de ingresos registrados.
- **In-store:** 6.221 transacciones y **$760.670** de ingresos registrados.
- **Cash:** 4.310 transacciones y **$537.710** de ingresos registrados, el mayor valor entre los métodos.

El canal online representa aproximadamente el **50,99%** de los ingresos conocidos. No hay datos de costos, comisiones, envío, infraestructura o márgenes para concluir qué canal o método es más rentable. La matriz del dashboard permite observar ingresos cruzados por canal y medio de pago.

## Recomendaciones y límites

1. Complementar con **costos de producto, inventario y márgenes** antes de tomar decisiones sobre el catálogo.
2. Estimar la **rentabilidad por canal** incorporando logística, comisiones, procesamiento y mantenimiento.
3. Mejorar la **captura de datos de operaciones**, especialmente importe, producto y descuentos, y monitorear las diferencias entre origen y destino en futuras integraciones.
4. Profundizar el análisis de actividad mensual antes de ajustar niveles de inventario o promociones por posible estacionalidad.

Los resultados proceden de los registros disponibles; los importes faltantes **no se reemplazaron por cero** y la relación de descuentos con el total no pudo verificarse.
