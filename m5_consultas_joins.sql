USE Ventas_Tech_DB

-- CONSULTA 1 --
-- VISTA BASE DEL PROYECTO (INNER JOIN)
-- PROPOSITO: GENERAR LA VISTA TOTAL DE LOS DATOS
SELECT v.fecha_venta
, c.id_cliente
,c.nombre AS nombre_cliente
,c.ciudad
,p.nombre_producto
,cat.nombre_categoria
,v.cantidad
,v.precio_unitario
,(v.cantidad * v.precio_unitario) AS total_venta
FROM ventas AS v
INNER JOIN clientes AS c ON v.id_cliente = c.id_cliente
INNER JOIN productos AS p ON v.id_producto = p.id_producto
INNER JOIN categorias AS cat ON p.id_categoria = cat.id_categoria;

-- Hallazgo: Todas las ventas cruzaron correctamente (10 registros). La facturación está muy concentrada en Computación ($4.950), mientras que Accesorios aporta $744, Almacenamiento $390 y Audio $360.


-- CONSULTA 2 --
-- CLIENTES SIN VENTAS (LEFT JOIN)
-- PROPOSITO: DETECTAR CLIENTES REGISTRADOS QUE NUNCA COMPRARON PARA QUE EL AREA CORRESPONDIENTE DETERMINE QUE HACER

SELECT c.nombre
, c.email
,c.fecha_registro 
FROM clientes AS c
LEFT JOIN ventas AS v ON c.id_cliente = v.id_cliente
WHERE v.id_cliente IS  NULL;

-- Hallazgo: 0 clientes devueltos.  Todos los clientes registrados hicieron una compra


-- CONSULTA 3 -- 
-- PRODUCTOS SIN VENTAS (LEFT JOIN)
-- PROPOSITO: IDENTIFICAR ARTICULOS SIN MOVIMIENTO PARA QUE EL AREA CORRESPONDIENTE DETERMINE LAS ACCIONES A LLEVAR A CABO. 

SELECT p.nombre_producto
, cat.nombre_categoria
,p.precio
FROM productos AS p
LEFT JOIN categorias AS cat ON p.id_categoria = cat.id_categoria
LEFT JOIN ventas AS v ON p.id_producto = v.id_producto
WHERE v.id_producto IS NULL;

-- Hallazgo: 0 productos devueltos.  No hay articulos sin movimientos. 


-- CONSULTA 4 -- 
-- CONSOLIDADO POR CANAL (UNION ALL)
-- PROPOSITO: SEGMENTAR Y COMPARAR EL TOTAL DE FACTURACION DIVIDIENDO EL NEGOCIO ENTRE VENTAS PRESENCIALES (LOCAL EN BUENOS AIRES) Y VENTAS ONLINE (INTERIOR)


SELECT canal
,SUM(total) AS total_canal
FROM (
SELECT v.fecha_venta
,(v.cantidad * v.precio_unitario) AS total
,'Presencial (Buenos Aires)' AS canal
FROM ventas AS v
INNER JOIN clientes AS c ON v.id_cliente = c.id_cliente
WHERE c.ciudad = 'Buenos Aires'
UNION ALL
SELECT v.fecha_venta
,(v.cantidad * v.precio_unitario) AS total
,'Online (Interior)' AS canal
FROM ventas AS v
 INNER JOIN 
clientes AS c ON v.id_cliente = c.id_cliente
WHERE c.ciudad != 'Buenos Aires'
) AS consolidado
GROUP BY  canal;

-- Hallazgo: El canal online (envios al interior) tracciona el mayor volumen de ingresos con $3.804, superando la venta en el local (Buenos Aires) con $2.640. 