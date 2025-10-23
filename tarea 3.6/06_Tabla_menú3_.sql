-- ==========================================
-- Base de datos: seguridad_plazas
-- Tabla: comunas
-- ==========================================

-- 1) Crear base y usarla
CREATE DATABASE IF NOT EXISTS seguridad_plazas;
USE seguridad_plazas;

-- 2) Crear tabla si no existe
CREATE TABLE IF NOT EXISTS comunas (
    id_comuna INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    created_by VARCHAR(50) NULL DEFAULT NULL,
    created_at DATETIME NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(50) NULL DEFAULT NULL,
    updated_at DATETIME NULL DEFAULT NULL,
    deleted TINYINT(1) NOT NULL DEFAULT 0,
    UNIQUE INDEX nombre (nombre ASC),
    CHECK (CHAR_LENGTH(nombre) > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 3) Poblar datos de ejemplo SOLO si está vacía
INSERT INTO comunas (nombre, created_by)
SELECT 'Santiago', 'admin'
WHERE NOT EXISTS (SELECT 1 FROM comunas LIMIT 1);
INSERT INTO comunas (nombre, created_by)
SELECT 'Providencia', 'admin'
WHERE NOT EXISTS (SELECT 1 FROM comunas LIMIT 1 OFFSET 1);
INSERT INTO comunas (nombre, created_by)
SELECT 'Las Condes', 'admin'
WHERE NOT EXISTS (SELECT 1 FROM comunas LIMIT 1 OFFSET 2);

-- 4) Procedimientos almacenados
DELIMITER $$

-- A) Listar solo comunas activas
DROP PROCEDURE IF EXISTS sp_listar_comunas_activas $$
CREATE PROCEDURE sp_listar_comunas_activas()
BEGIN
    SELECT id_comuna, nombre, created_by, created_at, updated_by, updated_at
    FROM comunas
    WHERE deleted = 0
    ORDER BY id_comuna;
END $$

-- B) Listar todas las comunas (incluye eliminadas)
DROP PROCEDURE IF EXISTS sp_listar_comunas_todos $$
CREATE PROCEDURE sp_listar_comunas_todos()
BEGIN
    SELECT id_comuna, nombre, created_by, created_at, updated_by, updated_at, deleted
    FROM comunas
    ORDER BY id_comuna;
END $$

-- C) Insertar nueva comuna y devolver ID
DROP PROCEDURE IF EXISTS sp_insertar_comuna $$
CREATE PROCEDURE sp_insertar_comuna(
    IN p_nombre VARCHAR(100),
    IN p_created_by VARCHAR(50),
    OUT p_nuevo_id INT
)
BEGIN
    INSERT INTO comunas (nombre, created_by) VALUES (p_nombre, p_created_by);
    SET p_nuevo_id = LAST_INSERT_ID();
END $$

-- D) Borrado lógico
DROP PROCEDURE IF EXISTS sp_borrado_logico_comuna $$
CREATE PROCEDURE sp_borrado_logico_comuna(IN p_id INT)
BEGIN
    UPDATE comunas
    SET deleted = 1,
        updated_at = NOW()
    WHERE id_comuna = p_id AND deleted = 0;
END $$

-- E) Restaurar comuna eliminada
DROP PROCEDURE IF EXISTS sp_restaurar_comuna $$
CREATE PROCEDURE sp_restaurar_comuna(IN p_id INT)
BEGIN
    UPDATE comunas
    SET deleted = 0,
        updated_at = NOW()
    WHERE id_comuna = p_id AND deleted = 1;
END $$

DELIMITER ;
