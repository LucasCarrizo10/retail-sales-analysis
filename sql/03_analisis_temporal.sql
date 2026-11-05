/*
RETAIL STORE SALES — 03. EVOLUCIÓN TEMPORAL
Pregunta 3. Diferenciar años completos (2022–2024) de 2025 parcial.
*/
USE RetailStoreDB;
GO

/* 3A. Cobertura temporal y total anual de referencia. */
SELECT
    YEAR(Transaction_Date) AS Anio,
    MIN(Transaction_Date) AS Primera_Fecha,
    MAX(Transaction_Date) AS Ultima_Fecha,
    COUNT(*) AS Total_Transacciones,
    SUM(Total_Spent) AS Ingresos_Registrados
FROM dbo.RetailSales_Validada
GROUP BY YEAR(Transaction_Date)
ORDER BY Anio;
-- En 2025 la última fecha observada es 2025-01-18.

/* 3B. Promedio mensual de ingresos considerando solo 2022–2024.
   Primero sumamos cada año/mes y DESPUÉS promediamos entre años. */
WITH Ventas_Mensuales AS (
    SELECT
        YEAR(Transaction_Date) AS Anio,
        MONTH(Transaction_Date) AS Mes,
        SUM(Total_Spent) AS Ingresos_Registrados
    FROM dbo.RetailSales_Validada
    WHERE Transaction_Date >= '20220101' AND Transaction_Date < '20250101'
    GROUP BY YEAR(Transaction_Date), MONTH(Transaction_Date)
)
SELECT
    Mes,
    AVG(Ingresos_Registrados) AS Promedio_Ingresos_2022_2024
FROM Ventas_Mensuales
GROUP BY Mes
ORDER BY Promedio_Ingresos_2022_2024 DESC;
-- Enero ~49624.17; octubre ~39804.50.

/* 3C. Los tres mejores meses de cada año, usando una función de ventana.
   ROW_NUMBER reinicia el orden por año; en caso de empate, preferimos mes menor. */
WITH Ventas_Mensuales AS (
    SELECT
        YEAR(Transaction_Date) AS Anio,
        MONTH(Transaction_Date) AS Mes,
        SUM(Total_Spent) AS Ingresos_Registrados
    FROM dbo.RetailSales_Validada
    WHERE Transaction_Date >= '20220101' AND Transaction_Date < '20250101'
    GROUP BY YEAR(Transaction_Date), MONTH(Transaction_Date)
),
Ranking_Mensual AS (
    SELECT
        Anio, Mes, Ingresos_Registrados,
        ROW_NUMBER() OVER (
            PARTITION BY Anio
            ORDER BY Ingresos_Registrados DESC, Mes ASC
        ) AS Posicion
    FROM Ventas_Mensuales
)
SELECT Anio, Mes, Ingresos_Registrados, Posicion
FROM Ranking_Mensual
WHERE Posicion <= 3
ORDER BY Anio, Posicion;
-- Enero lidera 2022 y 2023; diciembre lidera 2024.

/* 3D. Comparar períodos equivalentes: del 1 al 18 de enero de cada año.
   No comparar 2025 parcial contra 2024 completo. LAG da NULL para 2022,
   porque no hay 2021 en el dataset. NULLIF evita dividir por cero. */
WITH Enero_Comparable AS (
    SELECT
        YEAR(Transaction_Date) AS Anio,
        SUM(Total_Spent) AS Ingresos_Registrados,
        COUNT(*) AS Total_Transacciones,
        COUNT(Total_Spent) AS Transacciones_Con_Importe,
        AVG(Total_Spent) AS Ticket_Promedio_Conocido
    FROM dbo.RetailSales_Validada
    WHERE MONTH(Transaction_Date) = 1 AND DAY(Transaction_Date) <= 18
    GROUP BY YEAR(Transaction_Date)
),
Comparacion AS (
    SELECT
        Anio, Ingresos_Registrados, Total_Transacciones,
        Transacciones_Con_Importe, Ticket_Promedio_Conocido,
        LAG(Ingresos_Registrados) OVER (ORDER BY Anio) AS Ingresos_Anio_Anterior
    FROM Enero_Comparable
)
SELECT
    Anio,
    Ingresos_Registrados,
    Total_Transacciones,
    Transacciones_Con_Importe,
    Ticket_Promedio_Conocido,
    Ingresos_Anio_Anterior,
    ROUND(
        (Ingresos_Registrados - Ingresos_Anio_Anterior) * 100.0 /
        NULLIF(Ingresos_Anio_Anterior, 0), 2
    ) AS Variacion_Porcentual
FROM Comparacion
ORDER BY Anio;
-- 2023 +1.78%; 2024 -9.94%; 2025 -3.58% (solo 1–18 enero).
