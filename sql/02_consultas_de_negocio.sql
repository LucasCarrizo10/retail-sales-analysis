/*
RETAIL STORE SALES — 02. CATEGORÍAS, PRODUCTOS, CLIENTES, CANALES Y PAGOS
Preguntas 1, 2, 4 y 5. Ejecutar luego de 01_carga_y_validacion.sql.
Todas las métricas usan dbo.RetailSales_Validada, NO la primera importación.
SUM y AVG ignoran NULL; COUNT(*) conserva todas las transacciones.
*/
USE RetailStoreDB;
GO

/* PREGUNTA 1 — ¿Qué categorías registran mayores ingresos? */
SELECT
    Category,
    SUM(Total_Spent) AS Ingresos_Registrados,
    COUNT(*) AS Total_Transacciones,
    COUNT(Total_Spent) AS Transacciones_Con_Importe,
    AVG(Total_Spent) AS Ticket_Promedio_Conocido
FROM dbo.RetailSales_Validada
GROUP BY Category
ORDER BY Ingresos_Registrados DESC;
-- Butchers: 208118.00, 1568 transacciones, ticket promedio ~139.12.

/* PREGUNTA 2A — Productos por frecuencia de compra.
   WITH TIES conserva los empates de la décima posición (puede devolver >10).
   No equivale a unidades vendidas. */
SELECT TOP (10) WITH TIES
    Item,
    Category,
    COUNT(*) AS Total_Transacciones
FROM dbo.RetailSales_Validada
WHERE Item IS NOT NULL
GROUP BY Item, Category
ORDER BY Total_Transacciones DESC;
-- Item_2_BEV: 130 transacciones.

/* PREGUNTA 2B — Productos con mayores ingresos conocidos. */
SELECT TOP (10)
    Item,
    Category,
    SUM(Total_Spent) AS Ingresos_Registrados,
    COUNT(*) AS Total_Transacciones,
    COUNT(Total_Spent) AS Transacciones_Con_Importe
FROM dbo.RetailSales_Validada
WHERE Item IS NOT NULL
GROUP BY Item, Category
ORDER BY Ingresos_Registrados DESC, Item ASC;
-- Item_25_FUR: 25256.00. El ranking no incluye los 609 Item nulos.

/* PREGUNTA 2C — Menor frecuencia, sin sugerir eliminación del catálogo. */
SELECT TOP (10)
    Item,
    Category,
    COUNT(*) AS Total_Transacciones,
    SUM(Total_Spent) AS Ingresos_Registrados,
    AVG(Total_Spent) AS Ticket_Promedio_Conocido
FROM dbo.RetailSales_Validada
WHERE Item IS NOT NULL
GROUP BY Item, Category
ORDER BY Total_Transacciones ASC, Item ASC;
-- Item_3_EHE: 5 transacciones, 224.00 de ingresos conocidos.

/* PREGUNTA 4A — Clientes por gasto conocido. */
SELECT TOP (10)
    Customer_ID,
    COUNT(*) AS Total_Transacciones,
    COUNT(Total_Spent) AS Transacciones_Con_Importe,
    SUM(Total_Spent) AS Gasto_Registrado,
    AVG(Total_Spent) AS Ticket_Promedio_Conocido
FROM dbo.RetailSales_Validada
GROUP BY Customer_ID
ORDER BY Gasto_Registrado DESC, Customer_ID ASC;
-- CUST_24: 68452.00 de gasto conocido.

/* PREGUNTA 4B — Clientes por frecuencia (no confundir con gasto). */
SELECT TOP (10)
    Customer_ID,
    COUNT(*) AS Total_Transacciones,
    SUM(Total_Spent) AS Gasto_Registrado
FROM dbo.RetailSales_Validada
GROUP BY Customer_ID
ORDER BY Total_Transacciones DESC, Customer_ID ASC;
-- CUST_05: 544 transacciones.

/* PREGUNTA 4C — Recurrencia mensual, años completos 2022–2024.
   El promedio es por MES ACTIVO, no necesariamente por los 36 meses;
   en este dataset todos los clientes resultaron activos los 36 meses. */
SELECT
    Customer_ID,
    COUNT(*) AS Total_Transacciones,
    COUNT(DISTINCT YEAR(Transaction_Date) * 100 + MONTH(Transaction_Date))
        AS Meses_Con_Compras,
    COUNT(*) * 1.0 /
        NULLIF(COUNT(DISTINCT YEAR(Transaction_Date) * 100 + MONTH(Transaction_Date)), 0)
        AS Transacciones_Por_Mes_Activo
FROM dbo.RetailSales_Validada
WHERE Transaction_Date >= '20220101' AND Transaction_Date < '20250101'
GROUP BY Customer_ID
ORDER BY Meses_Con_Compras DESC, Total_Transacciones DESC, Customer_ID ASC;
-- 25 clientes, todos con compras en los 36 meses.

/* PREGUNTA 5A — Comparación entre canales. */
SELECT
    Location,
    COUNT(*) AS Total_Transacciones,
    COUNT(Total_Spent) AS Transacciones_Con_Importe,
    SUM(Total_Spent) AS Ingresos_Registrados,
    AVG(Total_Spent) AS Ticket_Promedio_Conocido
FROM dbo.RetailSales_Validada
GROUP BY Location
ORDER BY Ingresos_Registrados DESC;
-- Online 791401.00; In-store 760670.00.

/* PREGUNTA 5B — Comparación entre medios de pago. */
SELECT
    Payment_Method,
    COUNT(*) AS Total_Transacciones,
    COUNT(Total_Spent) AS Transacciones_Con_Importe,
    SUM(Total_Spent) AS Ingresos_Registrados,
    AVG(Total_Spent) AS Ticket_Promedio_Conocido
FROM dbo.RetailSales_Validada
GROUP BY Payment_Method
ORDER BY Total_Transacciones DESC;
-- Cash: 4310 transacciones, 537710.00 de ingresos registrados.

/* PREGUNTA 5C — Cruce para la matriz de Power BI. */
SELECT
    Payment_Method,
    Location,
    COUNT(*) AS Total_Transacciones,
    SUM(Total_Spent) AS Ingresos_Registrados
FROM dbo.RetailSales_Validada
GROUP BY Payment_Method, Location
ORDER BY Payment_Method, Location;
