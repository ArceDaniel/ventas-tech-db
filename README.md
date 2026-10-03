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
