# Ventas_Tech_DB - Data Engineering SQL Script

Este repositorio contiene la entrega del **Checkpoint: Script SQL de Ingeniería de Datos** para la certificación en Data Analytics.

## 📌 Contexto
Creación y normalización del modelo relacional para la base de datos `Ventas_Tech_DB` de la cadena de retail de tecnología **TechStore**. Este modelo sirve como base para futuros análisis con SQL (JOINs, agregaciones), limpieza en Power Query y dashboards analíticos en Power BI con DAX.

---

## 🏗️ Modelo de Datos (3NF)

```
[categorias] (1) ──── (N) [productos] (1) ──── (N) [ventas] (N) ──── (1) [clientes]
```

- **Tablas de Dimensión:**
  - `categorias`: Información de familias de productos.
  - `clientes`: Datos de contacto y registro de clientes.
  - `productos`: Catálogo, precios de lista, stock y estado.
- **Tabla de Hechos:**
  - `ventas`: Registro transaccional de ventas unitarias, cantidades y fechas.

---

## 📂 Estructura del Script (`ventas_tech_db.sql`)

El script está dividido en 4 secciones claramente delimitadas:
1. **SECCIÓN 1 - DROP TABLES:** Eliminación condicional de tablas en orden inverso de dependencias para asegurar repetibilidad (`ventas` → `productos` → `clientes` → `categorias`).
2. **SECCIÓN 2 - CREATE TABLES:** Definición DDL con tipos de datos correctos (`DECIMAL(10,2)` para importes, `DATE` para fechas, `BIT` para booleanos), claves primarias (PK) y foráneas (FK).
3. **SECCIÓN 3 - INSERT DATA:** Inserción explícita de los 25 registros en orden lógico de dependencias.
4. **SECCIÓN 4 - VALIDACIÓN:** Consultas `SELECT` para verificar la cantidad de filas cargadas (4, 5, 6 y 10 registros respectivamente).

---

## 🚀 Cómo ejecutar en SQL Server Management Studio (SSMS)

1. Abrí **SQL Server Management Studio (SSMS)** y conectate a tu instancia.
2. Abrí una nueva consulta (*New Query*) y creá la base de datos si no existe:
   ```sql
   CREATE DATABASE Ventas_Tech_DB;
   GO
   USE Ventas_Tech_DB;
   GO
   ```
3. Abrí el archivo [`ventas_tech_db.sql`](./ventas_tech_db.sql) o pegá su contenido.
4. Presioná **Execute (F5)**.
5. Verificá que las cuatro consultas de validación al final devuelvan:
   - `categorias`: 4 filas
   - `clientes`: 5 filas
   - `productos`: 6 filas
   - `ventas`: 10 filas

---

## 📊 Módulo 4: Pre-entrega — Consultas SQL de Negocio (`m4_consultas_negocio.sql`)

Extracción de métricas clave y respuestas analíticas para el equipo comercial de **RetailPro** basadas exclusivamente en la tabla de hechos `ventas`.

El script se encuentra disponible en:
- [`m4_consultas_negocio.sql`](./m4_consultas_negocio.sql)

### 📋 Consultas incluidas

1. **Consulta 1 — Resumen Ejecutivo Mensual:**
   - Agrupación por mes (`MONTH(fecha_venta)`).
   - Cálculo de facturación total (`SUM(cantidad * precio_unitario)`), cantidad de pedidos (`COUNT(id_venta)`) y ticket promedio (`AVG(cantidad * precio_unitario)`).
2. **Consulta 2 — Ranking de Productos (Top 5):**
   - Top 5 de productos por total facturado utilizando `SELECT TOP 5`, `SUM(cantidad)` y `ORDER BY total_facturado DESC`.
3. **Consulta 3 — Clientes Recurrentes:**
   - Identificación de clientes con más de una compra mediante `GROUP BY id_cliente` y `HAVING COUNT(*) > 1`, reportando número de pedidos y monto total acumulado.
4. **Consulta 4 — Meses Por Encima / Por Debajo del Promedio General:**
   - Comparativa matemática mensual utilizando una CTE (`WITH FacturacionMensual AS (...)`) y evaluación condicional con `CASE WHEN` para clasificar si cada mes supera o queda por debajo del promedio mensual global.

### 💡 Hallazgos de Negocio Documentados (Insights)

1. **Concentración de ingresos en Hardware Premium (Principio de Pareto):**
   El producto `id_producto = 1` ('Laptop Pro 15') representa el **55.87%** de la facturación total ($3,600.00 de $6,444.00) con solo 3 unidades vendidas. Los dos productos líderes (`id_producto` 1 y 3) concentran el **76.81%** del ingreso, mientras que accesorios masivos como el Mouse Inalámbrico aportan alto volumen físico (13 unidades) pero bajo porcentaje monetario (5.65%).
2. **Alta fidelización de la base de clientes:**
   El 100% de los clientes activos (5 de 5) realizaron 2 pedidos durante el período analizado. No obstante, existe una disparidad pronunciada en el Customer Lifetime Value (CLV): los clientes 1 y 5 representan el **73.56%** de la facturación total, justificando un programa de fidelización diferenciado.
3. **Estructura y salud del Ticket Promedio:**
   Marzo registró 10 pedidos con un ticket promedio de $644.40, ubicándose en equilibrio/por encima del promedio general. La alta dependencia de equipos de cómputo de precio elevado aconseja implementar estrategias comerciales de venta cruzada (cross-selling) con periféricos e insumos para mitigar la volatilidad de ingresos.
