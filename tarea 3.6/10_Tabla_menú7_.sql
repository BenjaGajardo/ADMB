-- ==========================================
-- Base de datos: seguridad_plazas
-- Tabla: juntas_vecinos
-- ==========================================

-- 1) Crear base y usarla
CREATE DATABASE IF NOT EXISTS seguridad_plazas;
USE seguridad_plazas;

-- 2) Crear tabla si no existe (con estructura mínima)
CREATE TABLE IF NOT EXISTS juntas_vecinos (
    id_junta INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    id_comuna INT NOT NULL,
    created_by VARCHAR(50) NULL DEFAULT NULL,
    created_at DATETIME NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(50) NULL DEFAULT NULL,
    updated_at DATETIME NULL DEFAULT NULL,
    deleted TINYINT(1) NOT NULL DEFAULT 0,
    INDEX id_comuna (id_comuna),
    CONSTRAINT juntas_vecinos_ibfk_1 FOREIGN KEY (id_comuna)
        REFERENCES comunas(id_comuna),
    CHECK (CHAR_LENGTH(nombre) > 0)
);

-- 3) Poblar datos de ejemplo SOLO si está vacía
INSERT INTO juntas_vecinos (nombre, id_comuna, created_by)
SELECT 'Junta Centro', 1, 'admin'
WHERE NOT EXISTS (SELECT 1 FROM juntas_vecinos LIMIT 1);
INSERT INTO juntas_vecinos (nombre, id_comuna, created_by)
SELECT 'Junta Norte', 2, 'admin'
WHERE NOT EXISTS (SELECT 1 FROM juntas_vecinos LIMIT 1 OFFSET 1);
INSERT INTO juntas_vecinos (nombre, id_comuna, created_by)
SELECT 'Junta Sur', 3, 'admin'
WHERE NOT EXISTS (SELECT 1 FROM juntas_vecinos LIMIT 1 OFFSET 2);

-- 4) Recrear procedimientos almacenados
DELIMITER $$

-- A) Listar SOLO activas
DROP PROCEDURE IF EXISTS sp_listar_juntas_vecinos_activas $$
CREATE PROCEDURE sp_listar_juntas_vecinos_activas()
BEGIN
    SELECT id_junta, nombre, id_comuna, created_by, created_at, updated_by, updated_at
    FROM juntas_vecinos
    WHERE deleted = 0
    ORDER BY id_junta;
END $$

-- B) Listar TODOS (incluye eliminadas)
DROP PROCEDURE IF EXISTS sp_listar_juntas_vecinos_todas $$
CREATE PROCEDURE sp_listar_juntas_vecinos_todas()
BEGIN
    SELECT id_junta, nombre, id_comuna, created_by, created_at, updated_by, updated_at, deleted
    FROM juntas_vecinos
    ORDER BY id_junta;
END $$

-- C) Insertar y devolver ID nuevo (OUT)
DROP PROCEDURE IF EXISTS sp_insertar_junta_vecinos $$
CREATE PROCEDURE sp_insertar_junta_vecinos(
    IN p_nombre VARCHAR(100),
    IN p_id_comuna INT,
    IN p_created_by VARCHAR(50),
    OUT p_nuevo_id INT
)
BEGIN
    INSERT INTO juntas_vecinos (nombre, id_comuna, created_by)
    VALUES (p_nombre, p_id_comuna, p_created_by);
    SET p_nuevo_id = LAST_INSERT_ID();
END $$

-- D) Borrado lógico
DROP PROCEDURE IF EXISTS sp_borrado_logico_junta_vecinos $$
CREATE PROCEDURE sp_borrado_logico_junta_vecinos(IN p_id INT)
BEGIN
    UPDATE juntas_vecinos
    SET deleted = 1,
        updated_at = NOW()
    WHERE id_junta = p_id AND deleted = 0;
END $$

-- E) Restaurar (opcional)
DROP PROCEDURE IF EXISTS sp_restaurar_junta_vecinos $$
CREATE PROCEDURE sp_restaurar_junta_vecinos(IN p_id INT)
BEGIN
    UPDATE juntas_vecinos
    SET deleted = 0,
        updated_at = NOW()
    WHERE id_junta = p_id AND deleted = 1;
END $$

DELIMITER ;
