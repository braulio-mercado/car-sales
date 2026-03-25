# Análisis de Ventas de Autos

## Descripción del Proyecto
Análisis de tendencias de ventas globales de autos utilizando datos de Kaggle. El proyecto incluye la creación de una base de datos relacional, procesos ETL y consultas analíticas para extraer insights de negocio.

## Tecnologías Utilizadas
- MySQL
- SQL (DDL, DML, JOINs, funciones de agregación)

## Estructura de la Base de Datos
Se diseñó un esquema normalizado con las siguientes tablas:
	- **clientes**: Información demográfica de los compradores
	- **concesionarios**: Datos de los puntos de venta
	- **modelos**: Especificaciones de los vehículos
	- **ventas**: Transacciones registradas

## Principales Hallazgos
1. **Marcas líderes**: Chevrolet, Dodge y Ford representan el mayor volumen de ventas
2. **Perfil de clientes**:
- **Clientes por género**: Existe un mayor número de clientes masculinos, el cual representa el 78.6% contando con un ingreso promedio representativo de 53% del total.
- **Segmentación de clientes**: El mayor volumen de ventas está dado por clientes con ingresos muy altos (>$200k), el volumen de ventas por parte de este segmento es del 78%.
- **Preferencia de transmisión**: Vehículos con transmisión automática son los preferidos por los clientes, ya que cuentan con el 52.6% del ingreso total en ventas.
3. **Estacionalidad**: Las ventas alcanzan su punto máximo en los meses de marzo, septiembre y noviembre, con un incremento de entre el 82.1% y 120.31% respecto al promedio anual, sugiriendo oportunidades para campañas promocionales en temporada baja.

## Limitaciones
El campo `dealer_region` presentó inconsistencias en los datos fuente, por lo que no se realizó análisis por región.

## Cómo Ejecutar este Proyecto
1. Clona o descarga este repositorio
2. Abre MySQL Workbench (o tu cliente SQL preferido)
3. Ejecuta el archivo `car_sales_completo.sql` en orden secuencial
4. Las consultas de análisis se encuentran al final del archivo en la sección "ANÁLISIS DE NEGOCIO"

El archivo está organizado en secciones:
- Creación de base de datos
- Tabla de staging
- Tablas normalizadas (clientes, concesionarios, modelos, ventas)
- Población de datos
- Consultas analíticas

## Autor
Braulio Alejandro Mercado Capulin
LinkedIn: www.linkedin.com/in/braulio-a-mercado