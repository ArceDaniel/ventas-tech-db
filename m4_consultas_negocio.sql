-- =============================================================================
-- PROYECTO RETAILPRO - PRE-ENTREGA 4: Consultas SQL de Negocio
-- Base de Datos: Ventas_Tech_DB
-- Tabla analizada: ventas
-- Motor: SQL Server (T-SQL)
-- =============================================================================
-- Descripción:
-- Este script contiene las consultas analíticas iniciales para el equipo comercial
-- de RetailPro, extrayendo métricas ejecutivas, rankings de productos, fidelidad
-- de clientes y comparativas frente a promedios mensuales a partir de la tabla 'ventas'.
-- =============================================================================

USE Ventas_Tech_DB;
GO

-- =============================================================================
-- CONSULTA 1: Resumen ejecutivo mensual
-- =============================================================================
-- Consigna:
--   Total facturado, cantidad de pedidos y ticket promedio, agrupados por mes.
--   Calculado como cantidad * precio_unitario.
--   Usa alias descriptivos en español y agrupa por mes con MONTH(fecha_venta).
-- =============================================================================

SELECT 
    MONTH(fecha_venta)                  AS mes,
    SUM(cantidad * precio_unitario)     AS total_facturado,
    COUNT(id_venta)                     AS cantidad_pedidos,
    AVG(cantidad * precio_unitario)     AS ticket_promedio
FROM ventas
GROUP BY MONTH(fecha_venta)
ORDER BY mes;
GO


-- =============================================================================
-- CONSULTA 2: Ranking de productos (Top 5 por facturación)
-- =============================================================================
-- Consigna:
--   Top 5 de id_producto por total facturado, mostrando las unidades vendidas
--   (SUM(cantidad)) y el total generado.
--   Usa GROUP BY id_producto, ORDER BY y TOP 5.
-- =============================================================================

SELECT TOP 5
    id_producto,
    SUM(cantidad)                       AS unidades_vendidas,
    SUM(cantidad * precio_unitario)     AS total_facturado
FROM ventas
GROUP BY id_producto
ORDER BY total_facturado DESC;
GO


-- =============================================================================
-- CONSULTA 3: Clientes recurrentes
-- =============================================================================
-- Consigna:
--   id_cliente que hayan realizado más de un pedido, mostrando la cantidad de
--   pedidos y el total gastado.
--   Usa GROUP BY id_cliente y HAVING COUNT(*) > 1.
-- =============================================================================

SELECT 
    id_cliente,
    COUNT(*)                            AS cantidad_pedidos,
    SUM(cantidad * precio_unitario)     AS total_gastado
FROM ventas
GROUP BY id_cliente
HAVING COUNT(*) > 1
ORDER BY total_gastado DESC;
GO


-- =============================================================================
-- CONSULTA 4: Meses por encima/por debajo del promedio mensual general
-- =============================================================================
-- Consigna:
--   Total facturado por mes, con una columna adicional que etiquete con CASE WHEN
--   si ese mes quedó 'Por encima' o 'Por debajo' del promedio mensual general.
--
-- Nota metodológica:
--   Se utiliza una expresión de tabla común (CTE) para calcular primero el total
--   facturado por mes y luego comparar matemáticamente cada mes contra el promedio
--   de la facturación mensual general (AVG(total_facturado)).
-- =============================================================================

WITH FacturacionMensual AS (
    SELECT 
        MONTH(fecha_venta)              AS mes,
        SUM(cantidad * precio_unitario) AS total_facturado
    FROM ventas
    GROUP BY MONTH(fecha_venta)
)
SELECT 
    mes,
    total_facturado,
    CASE 
        WHEN total_facturado >= (SELECT AVG(total_facturado) FROM FacturacionMensual) 
            THEN 'Por encima'
        ELSE 'Por debajo'
    END AS clasificacion_promedio
FROM FacturacionMensual
ORDER BY mes;
GO

/*
-- Alternativa equivalente utilizando subconsultas derivadas (Subquery en FROM):
SELECT 
    mes,
    total_facturado,
    CASE 
        WHEN total_facturado >= (
            SELECT AVG(total_mes) 
            FROM (
                SELECT SUM(cantidad * precio_unitario) AS total_mes 
                FROM ventas 
                GROUP BY MONTH(fecha_venta)
            ) AS sub_promedios
        ) THEN 'Por encima'
        ELSE 'Por debajo'
    END AS clasificacion_promedio
FROM (
    SELECT 
        MONTH(fecha_venta)              AS mes,
        SUM(cantidad * precio_unitario) AS total_facturado
    FROM ventas
    GROUP BY MONTH(fecha_venta)
) AS ventas_por_mes
ORDER BY mes;
*/


-- =============================================================================
-- BLOQUE DE CIERRE: Hallazgos de negocio para el equipo comercial de RetailPro
-- =============================================================================
-- 
-- 1. CONCENTRACIÓN DE INGRESOS EN HARDWARE PREMIUM (PARETO 80/20):
--    El producto id_producto = 1 ('Laptop Pro 15') lidera ampliamente la facturación 
--    con $3,600.00, lo que representa el 55.87% del total de las ventas ($6,444.00) 
--    con tan solo 3 unidades vendidas en 2 pedidos. Sumado al id_producto = 3 
--    ('Monitor 4K 27', con $1,350.00), los dos productos principales concentran el 
--    76.81% de los ingresos totales de la empresa. En contraposición, los periféricos 
--    como el id_producto = 2 ('Mouse Inalámbrico') presentan alta rotación en volumen 
--    (13 unidades vendidas), pero aportan únicamente $364.00 (5.65% de la facturación).
--    *Acción sugerida:* Diseñar bundles o combos que combinen laptops y monitores 
--    con periféricos para incrementar el margen neto y la salida de accesorios.
--
-- 2. EXCELENTE RETENCIÓN DE CLIENTES CON MARCADA DISPARIDAD EN TICKET (CLV):
--    El 100% de los clientes registrados activos (5 de 5) son clientes recurrentes, 
--    ya que cada uno de ellos ha realizado exactamente 2 pedidos en el período analizado 
--    (cumpliendo la condición HAVING COUNT(*) > 1). Sin embargo, existe una fuerte 
--    segmentación en el gasto acumulado: los clientes id_cliente = 1 ($2,640.00) e 
--    id_cliente = 5 ($2,100.00) aportan juntos el 73.56% de la facturación global, 
--    mientras que los clientes 2, 3 y 4 promedian compras menores a $700.00.
--    *Acción sugerida:* Implementar un programa de fidelización VIP para los clientes 
--    1 y 5 para asegurar su recompra corporativa, y ofrecer incentivos de financiamiento 
--    o descuentos escalonados a los clientes 2, 3 y 4 para elevar su ticket.
--
-- 3. ESTABILIDAD Y ESTRUCTURA DEL TICKET PROMEDIO MENSUAL:
--    Durante el mes analizado (marzo, mes 3), se registró una facturación total de 
--    $6,444.00 distribuida en 10 pedidos, arrojando un ticket promedio saludable de 
--    $644.40 por transacción. En la comparativa frente al promedio mensual general, 
--    marzo se posiciona 'Por encima' (o en nivel de equilibrio con la línea base histórica). 
--    Dado que el modelo actual depende de transacciones esporádicas de alto valor unitario, 
--    RetailPro presenta una alta sensibilidad a la variabilidad de la demanda de hardware.
--    *Acción sugerida:* Fortalecer la venta recurrente de insumos, garantías extendidas 
--    y accesorios de cómputo para garantizar un flujo de caja base más predecible ante 
--    posibles caídas estacionales en la venta de equipos principales.
-- =============================================================================
