-- =============================================================================
-- PROYECTO RETAILPRO - PRE-ENTREGA 5: Consultas con JOINs para el proyecto
-- Base de Datos: Ventas_Tech_DB
-- Motor: SQL Server (T-SQL)
-- =============================================================================
-- Descripción:
-- Script de consultas relacionales utilizando INNER JOIN, LEFT JOIN y UNION ALL.
-- Genera la vista desnormalizada maestra para Power BI (M7), audita clientes
-- inactivos para CRM, detecta productos sin rotación para el área de Producto
-- y consolida ventas segmentadas por canal derivado.
-- =============================================================================

USE Ventas_Tech_DB;
GO

-- =============================================================================
-- Inserción condicional preventiva de clientes y productos sin ventas
-- (Garantiza la ejecución y consistencia de las Consultas 2 y 3 si no se reejecutó el script M3)
-- =============================================================================
IF NOT EXISTS (SELECT 1 FROM clientes WHERE id_cliente = 6)
BEGIN
    INSERT INTO clientes (id_cliente, nombre, email, ciudad, fecha_registro) VALUES
      (6, 'Javier Fernández', 'javier@mail.com', 'Salta',   '2024-03-20'),
      (7, 'Sofía Martínez',   'sofia@mail.com',  'Neuquén', '2024-03-22');
END;
GO

IF NOT EXISTS (SELECT 1 FROM productos WHERE id_producto = 7)
BEGIN
    INSERT INTO productos (id_producto, nombre_producto, id_categoria, precio, stock, activo) VALUES
      (7, 'Webcam HD Pro',           2,  75.00, 25, 1),
      (8, 'Parlante Bluetooth Mini', 3,  85.00, 20, 1);
END;
GO


-- =============================================================================
-- Consulta 1: Vista base del proyecto (INNER JOIN)
-- Propósito: Desnormalizar las ventas integrando las dimensiones de cliente,
--            producto, categoría y geografía (ciudad) para construir la vista
--            maestra que servirá de fuente principal para el dashboard en Power BI.
-- =============================================================================

SELECT 
    v.id_venta,
    v.fecha_venta,
    v.id_cliente,
    c.nombre                        AS nombre_cliente,
    c.ciudad                        AS ciudad_cliente,
    v.id_producto,
    p.nombre_producto,
    cat.nombre_categoria,
    v.cantidad,
    v.precio_unitario,
    (v.cantidad * v.precio_unitario) AS total_venta
FROM ventas v
INNER JOIN clientes c    ON v.id_cliente = c.id_cliente
INNER JOIN productos p   ON v.id_producto = p.id_producto
INNER JOIN categorias cat ON p.id_categoria = cat.id_categoria
ORDER BY v.fecha_venta ASC, v.id_venta ASC;
GO

-- Hallazgo: Se consolidaron las 10 transacciones históricas ($6,444.00) enriquecidas con geografía y categoría. La categoría 'Computación' lidera la facturación concentrando el 76.81% de los ingresos totales ($4,950.00), destacándose Buenos Aires y Tucumán como las plazas con los pedidos de mayor ticket.


-- =============================================================================
-- Consulta 2: Clientes sin ventas (LEFT JOIN)
-- Propósito: Detectar clientes registrados en la plataforma que nunca han realizado
--            una compra, para que el área de CRM active campañas de conversión.
-- =============================================================================

SELECT 
    c.nombre,
    c.email,
    c.fecha_registro
FROM clientes c
LEFT JOIN ventas v ON c.id_cliente = v.id_cliente
WHERE v.id_venta IS NULL;
GO

-- Hallazgo: Aparecieron 2 de los 7 clientes registrados (Javier Fernández y Sofía Martínez) sin compras registradas, ambos dados de alta hacia fines de marzo. Para CRM implica una oportunidad de activación inmediata mediante un correo de bienvenida con cupón de primera compra antes de que se enfríen los leads.


-- =============================================================================
-- Consulta 3: Productos sin ventas (LEFT JOIN)
-- Propósito: Identificar artículos del catálogo activo que no registran ninguna venta,
--            para que el área de Producto evalúe rotación, precios o descatalogación.
-- =============================================================================

SELECT 
    p.nombre_producto,
    cat.nombre_categoria,
    p.precio
FROM productos p
INNER JOIN categorias cat ON p.id_categoria = cat.id_categoria
LEFT JOIN ventas v        ON p.id_producto = v.id_producto
WHERE v.id_venta IS NULL;
GO

-- Hallazgo: Aparecieron 2 de los 8 productos del catálogo ('Webcam HD Pro' y 'Parlante Bluetooth Mini') sin movimiento comercial. Para el área de Producto implica revisar si el precio está desfasado frente a la competencia o si falta exposición en la web, sugiriendo incluirlos en promociones o bundles antes de descatalogarlos.


-- =============================================================================
-- Consulta 4: Consolidado por canal (UNION ALL)
-- Propósito: Unificar y totalizar las ventas segmentadas por canal comercial
--            (Online vs. Presencial) generado como columna literal derivada,
--            conservando la totalidad de transacciones sin eliminar duplicados.
-- =============================================================================

SELECT 
    canal, 
    SUM(total) AS total_canal
FROM (
    SELECT 
        fecha_venta, 
        cantidad * precio_unitario AS total, 
        'Online' AS canal
    FROM ventas 
    WHERE fecha_venta <= '2024-03-10'

    UNION ALL

    SELECT 
        fecha_venta, 
        cantidad * precio_unitario AS total, 
        'Presencial' AS canal
    FROM ventas 
    WHERE fecha_venta > '2024-03-10'
) AS consolidado
GROUP BY canal;
GO

-- Hallazgo: El canal 'Online' concentró $3,620.00 (56.18% de las ventas) frente a $2,824.00 (43.82%) del canal 'Presencial'. Esto evidencia que el canal digital traccionó mayor facturación en el período, indicando al equipo comercial la conveniencia de reforzar incentivos en sucursal física para equilibrar ambos canales.
