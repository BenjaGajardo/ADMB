/* =========================
   1) Base de datos
   ========================= */
DROP DATABASE IF EXISTS tienda_demo;
CREATE DATABASE tienda_demo;
USE tienda_demo;

/* =========================
   2) Tablas
   ========================= */
DROP TABLE IF EXISTS producto;
DROP TABLE IF EXISTS categoria;

CREATE TABLE categoria (
  id         INT PRIMARY KEY AUTO_INCREMENT,
  nombre     VARCHAR(100) NOT NULL,
  deleted    TINYINT(1) NOT NULL DEFAULT 0,   -- 0=activo, 1=borrado lógico
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE producto (
  id           INT PRIMARY KEY AUTO_INCREMENT,
  nombre       VARCHAR(120) NOT NULL,
  precio       DECIMAL(10,2) NOT NULL,
  categoria_id INT NOT NULL,
  deleted      TINYINT(1) NOT NULL DEFAULT 0, -- 0=activo, 1=borrado lógico
  created_at   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_producto_categoria
    FOREIGN KEY (categoria_id) REFERENCES categoria(id)
      ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

/* =========================
   3) Datos base (categorías)
   ========================= */
INSERT INTO categoria(nombre) VALUES
 ('Bebidas'), ('Snacks'), ('Limpieza');

/* =========================
   4) Procedimientos
   ========================= */

/* 4.1 Insertar producto (básico, sin validaciones) */
DELIMITER //
CREATE PROCEDURE sp_producto_insertar(
  IN p_nombre VARCHAR(120),
  IN p_precio DECIMAL(10,2),
  IN p_categoria_id INT
)
BEGIN
  INSERT INTO producto(nombre, precio, categoria_id, deleted)
  VALUES (p_nombre, p_precio, p_categoria_id, 0);
END//
DELIMITER ;

/* 4.2 Listar SOLO activos con su categoría (JOIN) */
DELIMITER //
CREATE PROCEDURE sp_producto_listar_activos()
BEGIN
  SELECT 
    p.id,
    p.nombre  AS producto,
    p.precio,
    c.nombre  AS categoria
  FROM producto p
  INNER JOIN categoria c ON p.categoria_id = c.id
  WHERE p.deleted = 0
  ORDER BY p.nombre;
END//
DELIMITER ;

/* 4.3 Borrado lógico: poner deleted = 1 */
DELIMITER //
CREATE PROCEDURE sp_producto_borrado_logico(
  IN p_id INT
)
BEGIN
  UPDATE producto
  SET deleted = 1
  WHERE id = p_id;
END//
DELIMITER ;

/* (Opcional) 4.4 Listar TODOS (activos y borrados) */
DELIMITER //
CREATE PROCEDURE sp_producto_listar_todo()
BEGIN
  SELECT 
    p.id,
    p.nombre  AS producto,
    p.precio,
    c.nombre  AS categoria,
    p.deleted
  FROM producto p
  INNER JOIN categoria c ON p.categoria_id = c.id
  ORDER BY p.nombre;
END//
DELIMITER ;

/* =========================
   5) Pruebas rápidas
   ========================= */

/* Insertar productos usando el SP */
CALL sp_producto_insertar('Agua 1.5L', 900, 1);     -- Bebidas
CALL sp_producto_insertar('Galletas X', 1200, 2);   -- Snacks
CALL sp_producto_insertar('Detergente', 2500, 3);   -- Limpieza

/* Ver todo (activos y borrados) */
SELECT * FROM producto;

/* Ver SOLO activos */
SELECT * FROM producto WHERE deleted = 0;



/* Ver activos con su categoría (JOIN) */
SELECT 
  p.id, p.nombre AS producto, p.precio,
  c.nombre AS categoria
FROM producto p
INNER JOIN categoria c ON p.categoria_id = c.id
WHERE p.deleted = 0
ORDER BY p.nombre;


/* Usar procedimientos de listado */
CALL sp_producto_listar_activos();  -- solo activos
CALL sp_producto_listar_todo();     -- todos

/* Probar borrado lógico y ver efecto */
CALL sp_producto_borrado_logico(1);           -- marca deleted=1 al id=1
CALL sp_producto_listar_activos();            -- ya no debe aparecer el id=1
CALL sp_producto_listar_todo();               -- sí aparece con deleted=1



-- TAREA 
/* 4.1 Insertar Categoria (básico, sin validaciones) */
DELIMITER //
CREATE PROCEDURE sp_categoria_insertar(
  IN p_nombre VARCHAR(100)
)
BEGIN
  INSERT INTO categoria(nombre, deleted)
  VALUES (p_nombre, 0);
END//
DELIMITER ;

/* 4.2 Listar SOLO activos con su categoría (JOIN) */
DELIMITER //
CREATE PROCEDURE sp_categoria_listar_activos()
BEGIN
  SELECT 
    c.id,
    c.nombre  AS categoria,
    c.deleted
  FROM categoria c 
  WHERE c.deleted = 0
  ORDER BY c.nombre;
END//
DELIMITER ;

/* 4.3 Borrado lógico: poner deleted = 1 */
DELIMITER //
CREATE PROCEDURE sp_categoria_borrado_logico(
  IN p_id INT
)
BEGIN
  UPDATE categoria
  SET deleted = 1
  WHERE id = p_id;
END//
DELIMITER ;

/* (Opcional) 4.4 Listar TODOS (activos y borrados) */
DELIMITER //
CREATE PROCEDURE sp_categoria_listar_todo()
BEGIN
  SELECT 
    c.id,
    c.nombre  AS categoria,
    c.deleted
  FROM producto c
  ORDER BY c.nombre;
END//
DELIMITER ;

/* Insertar categoria usando el SP */
CALL sp_categoria_insertar('Carnes');     
CALL sp_categoria_insertar('Dulces');   
CALL sp_categoria_insertar('Quesos');  

/* Ver todo (activos y borrados) */
SELECT * FROM categoria;

/*Ver categorias activas*/
SELECT * FROM categoria WHERE deleted = 0;

