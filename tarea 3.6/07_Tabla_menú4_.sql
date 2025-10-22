-- 1) Crear base y usarla
CREATE DATABASE IF NOT EXISTS seguridad_plaza;
USE seguridad_plaza;

-- 2) Crear tabla si no existe (con estructura mínima)
CREATE TABLE IF NOT EXISTS plazas (
    id_plaza INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    direccion VARCHAR(150) NOT NULL,
    id_comuna INT NULL DEFAULT NULL,
    CONSTRAINT fk_plaza_comuna FOREIGN KEY (id_comuna) REFERENCES comunas(id_comuna)
);

-- 3) Asegurar columnas de auditoría y borrado lógico
ALTER TABLE plazas
  ADD COLUMN eliminado TINYINT(1) NOT NULL DEFAULT 0 AFTER id_comuna,
  ADD COLUMN created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  ADD COLUMN updated_at DATETIME NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  ADD COLUMN deleted_at DATETIME NULL DEFAULT NULL;

-- 4) Poblar datos de ejemplo SOLO si está vacía
INSERT INTO plazas (nombre, direccion, id_comuna)
SELECT 'Plaza de Armas', 'Centro de Santiago', 1
WHERE NOT EXISTS (SELECT 1 FROM plazas LIMIT 1);

INSERT INTO plazas (nombre, direccion, id_comuna)
SELECT 'Plaza Ñuñoa', 'Av. Irarrázaval 3450', 2
WHERE NOT EXISTS (SELECT 1 FROM plazas LIMIT 1 OFFSET 1);

INSERT INTO plazas (nombre, direccion, id_comuna)
SELECT 'Plaza Maipú', 'Pajaritos 2000', 3
WHERE NOT EXISTS (SELECT 1 FROM plazas LIMIT 1 OFFSET 2);

-- 5) Recrear procedimientos almacenados
DELIMITER $$

-- A) Listar SOLO activos
DROP PROCEDURE IF EXISTS sp_listar_plazas_activas $$
CREATE PROCEDURE sp_listar_plazas_activas()
BEGIN
    SELECT id_plaza, nombre, direccion, id_comuna, created_at, updated_at
    FROM plazas
    WHERE eliminado = 0
    ORDER BY id_plaza;
END $$

-- B) Listar TODOS (incluye eliminados)
DROP PROCEDURE IF EXISTS sp_listar_plazas_todos $$
CREATE PROCEDURE sp_listar_plazas_todos()
BEGIN
    SELECT id_plaza, nombre, direccion, id_comuna, eliminado, created_at, updated_at, deleted_at
    FROM plazas
    ORDER BY id_plaza;
END $$

-- C) Insertar y devolver ID nuevo (OUT)
DROP PROCEDURE IF EXISTS sp_insertar_plaza $$
CREATE PROCEDURE sp_insertar_plaza(
    IN  p_nombre VARCHAR(100),
    IN  p_direccion VARCHAR(150),
    IN  p_id_comuna INT,
    OUT p_nuevo_id INT
)
BEGIN
    INSERT INTO plazas (nombre, direccion, id_comuna)
    VALUES (p_nombre, p_direccion, p_id_comuna);

    SET p_nuevo_id = LAST_INSERT_ID();
END $$

-- D) Borrado lógico
DROP PROCEDURE IF EXISTS sp_borrado_logico_plaza $$
CREATE PROCEDURE sp_borrado_logico_plaza(IN p_id INT)
BEGIN
    UPDATE plazas
    SET eliminado = 1,
        deleted_at = NOW()
    WHERE id_plaza = p_id AND eliminado = 0;
END $$

-- E) Restaurar (opcional)
DROP PROCEDURE IF EXISTS sp_restaurar_plaza $$
CREATE PROCEDURE sp_restaurar_plaza(IN p_id INT)
BEGIN
    UPDATE plazas
    SET eliminado = 0,
        deleted_at = NULL
    WHERE id_plaza = p_id AND eliminado = 1;
END $$

DELIMITER ;
