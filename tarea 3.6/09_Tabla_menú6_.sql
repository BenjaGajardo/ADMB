-- ==========================================
-- Base de datos: seguridad_plazas
-- Tabla: estado_camara
-- ==========================================

-- 1) Crear base y usarla
CREATE DATABASE IF NOT EXISTS seguridad_plazas;
USE seguridad_plazas;

-- 2) Crear tabla si no existe
CREATE TABLE IF NOT EXISTS estado_camara (
    id_estado_camara INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    descripcion VARCHAR(255) NULL DEFAULT NULL,
    created_by VARCHAR(50) NULL DEFAULT NULL,
    created_at DATETIME NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(50) NULL DEFAULT NULL,
    updated_at DATETIME NULL DEFAULT NULL,
    deleted TINYINT(1) NOT NULL DEFAULT 0,
    UNIQUE INDEX nombre (nombre ASC),
    CHECK (CHAR_LENGTH(nombre) > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 3) Poblar datos de ejemplo SOLO si está vacía
INSERT INTO estado_camara (nombre, descripcion, created_by)
SELECT 'ACTIVA', 'Cámara funcionando correctamente', 'admin'
WHERE NOT EXISTS (SELECT 1 FROM estado_camara LIMIT 1);

INSERT INTO estado_camara (nombre, descripcion, created_by)
SELECT 'INACTIVA', 'Cámara fuera de servicio', 'admin'
WHERE NOT EXISTS (SELECT 1 FROM estado_camara LIMIT 1 OFFSET 1);

-- 4) Procedimientos almacenados
DELIMITER $$

-- A) Listar solo estados activos
DROP PROCEDURE IF EXISTS sp_listar_estado_camara_activos $$
CREATE PROCEDURE sp_listar_estado_camara_activos()
BEGIN
    SELECT id_estado_camara, nombre, descripcion, created_by, created_at, updated_by, updated_at
    FROM estado_camara
    WHERE deleted = 0
    ORDER BY id_estado_camara;
END $$

-- B) Listar todos los estados (incluye eliminados)
DROP PROCEDURE IF EXISTS sp_listar_estado_camara_todos $$
CREATE PROCEDURE sp_listar_estado_camara_todos()
BEGIN
    SELECT id_estado_camara, nombre, descripcion, created_by, created_at, updated_by, updated_at, deleted
    FROM estado_camara
    ORDER BY id_estado_camara;
END $$

-- C) Insertar nuevo estado y devolver ID
DROP PROCEDURE IF EXISTS sp_insertar_estado_camara $$
CREATE PROCEDURE sp_insertar_estado_camara(
    IN p_nombre VARCHAR(50),
    IN p_descripcion VARCHAR(255),
    IN p_created_by VARCHAR(50),
    OUT p_nuevo_id INT
)
BEGIN
    INSERT INTO estado_camara (nombre, descripcion, created_by)
    VALUES (p_nombre, p_descripcion, p_created_by);
    SET p_nuevo_id = LAST_INSERT_ID();
END $$

-- D) Borrado lógico
DROP PROCEDURE IF EXISTS sp_borrado_logico_estado_camara $$
CREATE PROCEDURE sp_borrado_logico_estado_camara(IN p_id INT)
BEGIN
    UPDATE estado_camara
    SET deleted = 1,
        updated_at = NOW()
    WHERE id_estado_camara = p_id AND deleted = 0;
END $$

-- E) Restaurar estado eliminado
DROP PROCEDURE IF EXISTS sp_restaurar_estado_camara $$
CREATE PROCEDURE sp_restaurar_estado_camara(IN p_id INT)
BEGIN
    UPDATE estado_camara
    SET deleted = 0,
        updated_at = NOW()
    WHERE id_estado_camara = p_id AND deleted = 1;
END $$

DELIMITER ;

