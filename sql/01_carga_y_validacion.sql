/*
RETAIL STORE SALES — 01. CARGA Y VALIDACIÓN

Preparación manual (SSMS > Tasks > Import Flat File):
  1. Exportar data/processed/retail_store_sales_clean.csv desde el notebook.
  2. Importarlo como dbo.RetailSales_Prueba (tabla de staging).
  3. Renombrar las 12 columnas a:
     Transaction_ID, Customer_ID, Category, Item, Price_Per_Unit,
     Quantity, Total_Spent, Payment_Method, Location, Transaction_Date,
     Discount_Applied, Item_Fue_Recuperado.
  4. IMPORTANTE: Price_Per_Unit y Total_Spent como VARCHAR(50) para
     conservar el punto decimal original. Quantity como INT (NULL),
     Transaction_Date como DATE, Discount_Applied como BIT (NULL),
     Item_Fue_Recuperado como BIT NOT NULL; otros campos como VARCHAR.

La primera tabla dbo.RetailSales del proyecto tuvo importes x10 y NO se usa.
Este script NO borra ni sobrescribe tablas existentes.
*/
USE RetailStoreDB;
GO

-- 1. Comprobaciones previas: origen y conversión.
IF OBJECT_ID(N'dbo.RetailSales_Prueba', N'U') IS NULL
    THROW 50001, 'Falta dbo.RetailSales_Prueba: importa primero el CSV limpio con las columnas de importe como VARCHAR.', 1;
GO

SELECT
    COUNT(*) AS Total_Registros,
    SUM(CASE WHEN Price_Per_Unit IS NOT NULL
              AND TRY_CONVERT(DECIMAL(18,2), Price_Per_Unit) IS NULL THEN 1 ELSE 0 END)
        AS Precios_Invalidos,
    SUM(CASE WHEN Total_Spent IS NOT NULL
              AND TRY_CONVERT(DECIMAL(18,2), Total_Spent) IS NULL THEN 1 ELSE 0 END)
        AS Importes_Invalidos,
    SUM(TRY_CONVERT(DECIMAL(18,2), Total_Spent)) AS Ingresos_Origen,
    MIN(TRY_CONVERT(DECIMAL(18,2), Price_Per_Unit)) AS Precio_Minimo,
    MAX(TRY_CONVERT(DECIMAL(18,2), Price_Per_Unit)) AS Precio_Maximo
FROM dbo.RetailSales_Prueba;
-- Esperado: 12575 filas, 0 inválidos, 1552071.00, mínimo 5, máximo 41.

-- Detener la carga si se perderían números o se duplicarían transacciones.
IF EXISTS (
    SELECT 1 FROM dbo.RetailSales_Prueba
    WHERE (Price_Per_Unit IS NOT NULL AND TRY_CONVERT(DECIMAL(18,2), Price_Per_Unit) IS NULL)
       OR (Total_Spent IS NOT NULL AND TRY_CONVERT(DECIMAL(18,2), Total_Spent) IS NULL)
       OR (Quantity IS NOT NULL AND TRY_CONVERT(INT, Quantity) IS NULL)
)
    THROW 50002, 'Hay valores no convertibles en staging; corregirlos antes de crear la tabla validada.', 1;

IF EXISTS (SELECT 1 FROM dbo.RetailSales_Prueba WHERE Transaction_ID IS NULL)
    THROW 50003, 'Hay Transaction_ID nulos en staging.', 1;

IF EXISTS (
    SELECT 1 FROM dbo.RetailSales_Prueba
    GROUP BY Transaction_ID HAVING COUNT(*) > 1
)
    THROW 50004, 'Hay Transaction_ID duplicados en staging.', 1;
GO

-- 2. Crear la tabla final solamente si todavía no existe.
-- SELECT INTO no transfiere restricciones automáticamente.
IF OBJECT_ID(N'dbo.RetailSales_Validada', N'U') IS NULL
BEGIN
    SELECT
        Transaction_ID, Customer_ID, Category, Item,
        TRY_CONVERT(DECIMAL(18,2), Price_Per_Unit) AS Price_Per_Unit,
        TRY_CONVERT(INT, Quantity) AS Quantity,
        TRY_CONVERT(DECIMAL(18,2), Total_Spent) AS Total_Spent,
        Payment_Method, Location, Transaction_Date,
        Discount_Applied, Item_Fue_Recuperado
    INTO dbo.RetailSales_Validada
    FROM dbo.RetailSales_Prueba;
END
ELSE
    PRINT 'dbo.RetailSales_Validada ya existe: no se sobrescribió.';
GO

-- 3. Agregar la restricción de unicidad solo si falta.
IF NOT EXISTS (
    SELECT 1 FROM sys.key_constraints
    WHERE parent_object_id = OBJECT_ID(N'dbo.RetailSales_Validada')
      AND type = 'PK'
)
BEGIN
    ALTER TABLE dbo.RetailSales_Validada
        ALTER COLUMN Transaction_ID VARCHAR(50) NOT NULL;

    ALTER TABLE dbo.RetailSales_Validada
        ADD CONSTRAINT PK_RetailSales_Validada PRIMARY KEY (Transaction_ID);
END;
GO

-- 4. Conciliación con el perfilado final de Pandas.
SELECT
    COUNT(*) AS Total_Registros,
    COUNT(DISTINCT Transaction_ID) AS IDs_Unicos,
    SUM(CASE WHEN Item IS NULL THEN 1 ELSE 0 END) AS Items_Nulos,
    SUM(CASE WHEN Price_Per_Unit IS NULL THEN 1 ELSE 0 END) AS Precios_Nulos,
    SUM(CASE WHEN Quantity IS NULL THEN 1 ELSE 0 END) AS Cantidades_Nulas,
    SUM(CASE WHEN Total_Spent IS NULL THEN 1 ELSE 0 END) AS Importes_Nulos,
    SUM(CASE WHEN Discount_Applied IS NULL THEN 1 ELSE 0 END) AS Descuentos_Desconocidos,
    SUM(CASE WHEN Item_Fue_Recuperado = 1 THEN 1 ELSE 0 END) AS Items_Recuperados,
    SUM(Total_Spent) AS Ingresos_Registrados,
    MIN(Price_Per_Unit) AS Precio_Minimo,
    MAX(Price_Per_Unit) AS Precio_Maximo
FROM dbo.RetailSales_Validada;
-- Esperado: 12575 filas e IDs, nulos (609,609,604,604,4199),
--          604 recuperados, total 1552071.00, precios [5, 41].

SELECT
    COUNT(*) AS Registros_Evaluados,
    SUM(CASE WHEN Total_Spent <> Price_Per_Unit * Quantity THEN 1 ELSE 0 END)
        AS Inconsistencias_Matematicas
FROM dbo.RetailSales_Validada
WHERE Price_Per_Unit IS NOT NULL AND Quantity IS NOT NULL AND Total_Spent IS NOT NULL;
-- Esperado: 11362 registros evaluados, 0 inconsistencias.

SELECT Transaction_ID, Price_Per_Unit, Quantity, Total_Spent
FROM dbo.RetailSales_Validada
WHERE Transaction_ID = 'TXN_1002182';
-- Esperado: 11.00, 5, 55.00. Esta conciliación detectó el error x10.
