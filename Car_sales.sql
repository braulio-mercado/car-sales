# CREACIÓN DE LA BASE DE DATOS
create database car_sales;
use car_sales;

# CREACIÓN DE TABLA DE STAGING
create table cs_raw (
car_id			varchar (50),
date_txt		varchar (50),
customer_name	varchar (50),
gender			varchar (50),
annual_income	varchar (50),
dealer_name		varchar (150),
company			varchar (50),
model			varchar (50),
engine_txt		varchar (150),
transmission	varchar (50),
color			varchar (50),
price			varchar (50),
dealer_no		varchar (50),
body_style		varchar (50),
phone			varchar (50),
dealer_region	varchar (50)
);


# CREACIÓN DE TABLAS DE DIMENSIONES
-- Clientes
create table clientes (
id_cliente smallint primary key auto_increment,
nombre_cliente varchar (100) not null,
genero varchar (10),
telefono varchar (10),
ingreso_anual int (10)
);

-- Concesionarios
create table concesionarios (
id_dealer smallint primary key auto_increment,
nombre_dealer varchar (150) not null,
no_dealer varchar (50),
region_dealer varchar (50)
);

-- Modelos
create table modelos (
id_modelo smallint primary key auto_increment,
marca varchar (50) not null,
modelo varchar (100) not null,
motor varchar (100),
transmision varchar (30)
);

-- Ventas
create table ventas (
id_venta INT PRIMARY KEY AUTO_INCREMENT,
fecha_venta DATE NOT NULL,
id_cliente SMALLINT,
id_dealer SMALLINT,
id_modelo SMALLINT,
color VARCHAR(50),
body_style VARCHAR(50),
precio_venta DECIMAL(10, 2),
    
-- Definiendo relaciones (FOREIGN KEYS)
FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente),
FOREIGN KEY (id_dealer) REFERENCES concesionarios(id_dealer),
FOREIGN KEY (id_modelo) REFERENCES modelos(id_modelo)
);


# POBLACIÓN DE TABLAS
-- Clientes
insert into clientes (nombre_cliente, genero, telefono, ingreso_anual)
select distinct customer_name, gender, phone, annual_income from cs_raw;

-- Concesionarios
insert into concesionarios (nombre_dealer, no_dealer, region_dealer)
select distinct dealer_name, dealer_no, dealer_region from cs_raw;

-- Modelos
insert into modelos (marca, modelo, motor, transmision)
select distinct company, model, engine_txt, transmission from cs_raw;

-- Ventas
insert into ventas (fecha_venta, id_cliente, id_dealer, id_modelo, color, body_style, precio_venta)
select 
	STR_TO_DATE(r.date_txt, '%m/%d/%Y'),
    c.id_cliente,
    d.id_dealer,
    m.id_modelo,
    r.color,
    r.body_style,
    CAST(r.price AS DECIMAL(10,2))
from cs_raw r
INNER JOIN clientes c ON r.customer_name = c.nombre_cliente 
                     AND r.phone = c.telefono
INNER JOIN concesionarios d ON r.dealer_name = d.nombre_dealer
INNER JOIN modelos m ON r.company = m.marca 
                     AND r.model = m.modelo 
                     AND r.engine_txt = m.motor;


# CONSULTA DE PRUEBA
-- Reconstrucción del CSV con tablas normalizadas
SELECT 
    v.id_venta,
    v.fecha_venta,
    c.nombre_cliente,
    c.genero,
    c.ingreso_anual,
    d.nombre_dealer,
    m.marca,
    m.modelo,
    m.motor,
    m.transmision,
    v.color,
    v.precio_venta,
    d.no_dealer,
    v.body_style,
    c.telefono,
    d.region_dealer
FROM ventas v
INNER JOIN clientes c ON v.id_cliente = c.id_cliente
INNER JOIN concesionarios d ON v.id_dealer = d.id_dealer
INNER JOIN modelos m ON v.id_modelo = m.id_modelo
LIMIT 100;


# ANÁLISIS DE NEGOCIO
-- VENTAS POR DEALER
SELECT 
    d.id_dealer,
    d.nombre_dealer,
    d.region_dealer,
    COUNT(v.id_venta) AS ventas_del_dealer
FROM concesionarios d
LEFT JOIN ventas v ON d.id_dealer = v.id_dealer
GROUP BY d.id_dealer
ORDER BY ventas_del_dealer DESC
LIMIT 100;

-- VENTAS TOTALES Y TICKET PROMEDIO POR MARCA
SELECT 
    m.marca,
    COUNT(v.id_venta) AS unidades_vendidas,
    ROUND(SUM(v.precio_venta), 2) AS ingreso_total,
    ROUND(AVG(v.precio_venta), 2) AS precio_promedio
FROM ventas v
INNER JOIN modelos m ON v.id_modelo = m.id_modelo
GROUP BY m.marca
ORDER BY unidades_vendidas DESC;

-- TOP 5 MODELOS MÁS VENDIDOS
SELECT 
    m.marca,
    m.modelo,
    COUNT(v.id_venta) AS unidades_vendidas,
    ROUND(AVG(v.precio_venta), 2) AS precio_promedio
FROM ventas v
INNER JOIN modelos m ON v.id_modelo = m.id_modelo
GROUP BY m.marca, m.modelo
ORDER BY unidades_vendidas DESC
LIMIT 5;

-- CLIENTES POR GÉNERO Y MARCA PREFERIDA
SELECT 
    c.genero,
    m.marca,
    COUNT(v.id_venta) AS compras,
    ROUND(AVG(c.ingreso_anual), 2) AS ingreso_promedio
FROM ventas v
INNER JOIN clientes c ON v.id_cliente = c.id_cliente
INNER JOIN modelos m ON v.id_modelo = m.id_modelo
GROUP BY c.genero, m.marca
ORDER BY c.genero, compras DESC;

-- CLIENTES CON MAYOR GASTO TOTAL (TOP 10)
SELECT 
    c.nombre_cliente,
    c.genero,
    c.ingreso_anual,
    COUNT(v.id_venta) AS autos_comprados,
    ROUND(SUM(v.precio_venta), 2) AS gasto_total
FROM clientes c
INNER JOIN ventas v ON c.id_cliente = v.id_cliente
GROUP BY c.id_cliente
ORDER BY gasto_total DESC
LIMIT 10;

-- Distribución de clientes por género
SELECT 
    c.genero,
    COUNT(DISTINCT c.id_cliente) AS total_clientes_unicos,
    COUNT(v.id_venta) AS total_compras,
    ROUND(AVG(c.ingreso_anual), 0) AS ingreso_promedio,
    ROUND(AVG(v.precio_venta), 2) AS ticket_promedio,
    ROUND(SUM(v.precio_venta), 2) AS ingreso_total_generado
FROM clientes c
INNER JOIN ventas v ON c.id_cliente = v.id_cliente
GROUP BY c.genero;

-- Segmentación de clientes por nivel de ingreso
SELECT 
    CASE 
        WHEN c.ingreso_anual < 50000 THEN 'Bajo (<50k)'
        WHEN c.ingreso_anual BETWEEN 50000 AND 100000 THEN 'Medio (50k-100k)'
        WHEN c.ingreso_anual BETWEEN 100001 AND 150000 THEN 'Medio-Alto (100k-150k)'
        WHEN c.ingreso_anual BETWEEN 150001 AND 200000 THEN 'Alto (150k-200k)'
        ELSE 'Muy Alto (>200k)'
    END AS segmento_ingreso,
    COUNT(DISTINCT c.id_cliente) AS clientes_unicos,
    COUNT(v.id_venta) AS compras_totales,
    ROUND(AVG(v.precio_venta), 2) AS ticket_promedio,
    ROUND(SUM(v.precio_venta), 2) AS ingreso_total_segmento,
    ROUND(100.0 * SUM(v.precio_venta) / (SELECT SUM(precio_venta) FROM ventas), 2) AS porcentaje_del_total_ventas
FROM clientes c
INNER JOIN ventas v ON c.id_cliente = v.id_cliente
GROUP BY segmento_ingreso
ORDER BY ticket_promedio DESC;

-- Preferencia de transmisión y relación con ingreso del cliente
SELECT 
    m.transmision,
    COUNT(v.id_venta) AS unidades_vendidas,
    ROUND(AVG(c.ingreso_anual), 0) AS ingreso_promedio_cliente,
    ROUND(AVG(v.precio_venta), 2) AS precio_promedio,
    ROUND(100.0 * COUNT(v.id_venta) / (SELECT COUNT(*) FROM ventas), 2) AS porcentaje_del_mercado
FROM ventas v
INNER JOIN clientes c ON v.id_cliente = c.id_cliente
INNER JOIN modelos m ON v.id_modelo = m.id_modelo
GROUP BY m.transmision;

-- ESTILO DE CARROCERÍA MÁS VENDIDO POR REGIÓN
SELECT 
    d.region_dealer,
    v.body_style,
    COUNT(v.id_venta) AS unidades_vendidas,
    ROUND(AVG(v.precio_venta), 2) AS precio_promedio
FROM ventas v
INNER JOIN concesionarios d ON v.id_dealer = d.id_dealer
GROUP BY d.region_dealer, v.body_style
ORDER BY d.region_dealer, unidades_vendidas DESC;

-- COMBINACIONES DE COLOR Y CARROCERÍA MÁS POPULARES
SELECT 
    v.color,
    v.body_style,
    COUNT(v.id_venta) AS unidades_vendidas,
    RANK() OVER (ORDER BY COUNT(v.id_venta) DESC) AS popularidad
FROM ventas v
GROUP BY v.color, v.body_style
ORDER BY unidades_vendidas DESC
LIMIT 10;

-- VENTAS ANUALES Y CRECIMIENTO INTERANUAL
SELECT 
    YEAR(v.fecha_venta) AS año,
    MONTH(v.fecha_venta) AS mes,
    COUNT(v.id_venta) AS ventas_mes,
    LAG(COUNT(v.id_venta)) OVER (ORDER BY YEAR(v.fecha_venta), MONTH(v.fecha_venta)) AS ventas_mes_anterior,
    ROUND(
        100.0 * (COUNT(v.id_venta) - LAG(COUNT(v.id_venta)) OVER (ORDER BY YEAR(v.fecha_venta), MONTH(v.fecha_venta))) 
        / NULLIF(LAG(COUNT(v.id_venta)) OVER (ORDER BY YEAR(v.fecha_venta), MONTH(v.fecha_venta)), 0), 
        2
    ) AS crecimiento_porcentual
FROM ventas v
GROUP BY año, mes
ORDER BY año, mes;

-- RANKING DEALERS POR DESEMPEÑO
SELECT 
    d.nombre_dealer,
    d.region_dealer,
    COUNT(v.id_venta) AS total_ventas,
    ROUND(SUM(v.precio_venta), 2) AS ingreso_total,
    ROUND(AVG(v.precio_venta), 2) AS ticket_promedio,
    RANK() OVER (ORDER BY COUNT(v.id_venta) DESC) AS ranking_volumen,
    RANK() OVER (ORDER BY SUM(v.precio_venta) DESC) AS ranking_ingreso
FROM concesionarios d
INNER JOIN ventas v ON d.id_dealer = v.id_dealer
GROUP BY d.id_dealer
ORDER BY total_ventas DESC
LIMIT 10;

-- MARCAS CON MAOR CRECIMIENTO 2023 VS 2022
WITH ventas_por_marca AS (
    SELECT 
        m.marca,
        YEAR(v.fecha_venta) AS año,
        COUNT(v.id_venta) AS ventas
    FROM ventas v
    INNER JOIN modelos m ON v.id_modelo = m.id_modelo
    WHERE YEAR(v.fecha_venta) IN (2022, 2023)
    GROUP BY m.marca, YEAR(v.fecha_venta)
)
SELECT 
    v2022.marca,
    COALESCE(v2022.ventas, 0) AS ventas_2022,
    COALESCE(v2023.ventas, 0) AS ventas_2023,
    ROUND(
        100.0 * (COALESCE(v2023.ventas, 0) - COALESCE(v2022.ventas, 0)) 
        / NULLIF(v2022.ventas, 0), 
        2
    ) AS crecimiento_porcentual
FROM (SELECT * FROM ventas_por_marca WHERE año = 2022) v2022
LEFT JOIN (SELECT * FROM ventas_por_marca WHERE año = 2023) v2023 
    ON v2022.marca = v2023.marca
ORDER BY crecimiento_porcentual DESC;