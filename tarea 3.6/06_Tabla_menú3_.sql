-- 1) Crear base y usarla
CREATE DATABASE IF NOT EXISTS seguridad_plaza;
USE seguridad_plaza;

-- 2) Crear tabla si no existe (con estructura mínima)
CREATE TABLE IF NOT EXISTS comunas (
    id_comuna INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL
);

-- 3) Asegurar columnas de auditoría y borrado lógico (MySQL 8.0.29+: IF NOT EXISTS)
ALTER TABLE comunas
  ADD COLUMN eliminado  TINYINT(1) NOT NULL DEFAULT 0 AFTER nombre,
  ADD COLUMN created_at DATETIME  NOT NULL DEFAULT CURRENT_TIMESTAMP,
  ADD COLUMN updated_at DATETIME NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  ADD COLUMN deleted_at DATETIME NULL DEFAULT NULL;

-- 4) Poblar datos de ejemplo SOLO si está vacía
INSERT INTO comunas (nombre)
SELECT 'Santiago'
WHERE NOT EXISTS (SELECT 1 FROM comunas LIMIT 1);

INSERT INTO comunas (nombre)
SELECT 'Providencia'
WHERE NOT EXISTS (SELECT 1 FROM comunas LIMIT 1 OFFSET 1);

INSERT INTO comunas (nombre)
SELECT 'Las Condes'
WHERE NOT EXISTS (SELECT 1 FROM comunas LIMIT 1 OFFSET 2);

-- 5) Recrear procedimientos almacenados
DELIMITER $$

-- A) Listar SOLO activos
DROP PROCEDURE IF EXISTS sp_listar_comunas_activas $$
CREATE PROCEDURE sp_listar_comunas_activas()
BEGIN
    SELECT id_comuna, nombre, created_at, updated_at
    FROM comunas
    WHERE eliminado = 0
    ORDER BY id_comuna;
END $$

-- B) Listar TODOS (incluye eliminados)
DROP PROCEDURE IF EXISTS sp_listar_comunas_todos $$
CREATE PROCEDURE sp_listar_comunas_todos()
BEGIN
    SELECT id_comuna, nombre, eliminado, created_at, updated_at, deleted_at
    FROM comunas
    ORDER BY id_comuna;
END $$

-- C) Insertar y devolver ID nuevo (OUT)
DROP PROCEDURE IF EXISTS sp_insertar_comuna $$
CREATE PROCEDURE sp_insertar_comuna(
    IN  p_nombre VARCHAR(100),
    OUT p_nuevo_id INT
)
BEGIN
    INSERT INTO comunas (nombre)
    VALUES (p_nombre);

    SET p_nuevo_id = LAST_INSERT_ID();
END $$

-- D) Borrado lógico
DROP PROCEDURE IF EXISTS sp_borrado_logico_comuna $$
CREATE PROCEDURE sp_borrado_logico_comuna(IN p_id INT)
BEGIN
    UPDATE comunas
    SET eliminado = 1,
        deleted_at = NOW()
    WHERE id_comuna = p_id AND eliminado = 0;
END $$

-- E) Restaurar (opcional)
DROP PROCEDURE IF EXISTS sp_restaurar_comuna $$
CREATE PROCEDURE sp_restaurar_comuna(IN p_id INT)
BEGIN
    UPDATE comunas
    SET eliminado = 0,
        deleted_at = NULL
    WHERE id_comuna = p_id AND eliminado = 1;
END $$

DELIMITER ;