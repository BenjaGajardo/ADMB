-- ==========================================
-- Base de datos: seguridad_plazas
-- Tabla: tipo_reporte
-- ==========================================

-- 1) Crear base y usarla
CREATE DATABASE IF NOT EXISTS seguridad_plazas;
USE seguridad_plazas;

-- 2) Crear tabla si no existe (con estructura mínima)
CREATE TABLE IF NOT EXISTS tipo_reporte (
  id_tipo_reporte INT NOT NULL AUTO_INCREMENT,
  nombre VARCHAR(100) NOT NULL,
  descripcion VARCHAR(255) NULL DEFAULT NULL,
  created_by VARCHAR(50) NULL DEFAULT NULL,
  created_at DATETIME NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by VARCHAR(50) NULL DEFAULT NULL,
  updated_at DATETIME NULL DEFAULT NULL,
  deleted TINYINT(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (id_tipo_reporte),
  UNIQUE INDEX nombre (nombre ASC),
  CHECK (CHAR_LENGTH(nombre) > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 3) Columnas de auditoría y borrado lógico ya incluidas

-- 4) Poblar datos de ejemplo SOLO si está vacía
INSERT INTO tipo_reporte (nombre, descripcion, created_by)
SELECT 'Sospechoso', 'Reporte de persona sospechosa', 'admin'
WHERE NOT EXISTS (SELECT 1 FROM tipo_reporte LIMIT 1);
INSERT INTO tipo_reporte (nombre, descripcion, created_by)
SELECT 'Accidente', 'Reporte de accidente ocurrido', 'admin'
WHERE NOT EXISTS (SELECT 1 FROM tipo_reporte LIMIT 1 OFFSET 1);
INSERT INTO tipo_reporte (nombre, descripcion, created_by)
SELECT 'Objeto Peligroso', 'Reporte de objeto peligroso', 'admin'
WHERE NOT EXISTS (SELECT 1 FROM tipo_reporte LIMIT 1 OFFSET 2);
INSERT INTO tipo_reporte (nombre, descripcion, created_by)
SELECT 'Comportamiento Raro', 'Reporte de comportamiento extraño', 'admin'
WHERE NOT EXISTS (SELECT 1 FROM tipo_reporte LIMIT 1 OFFSET 3);

-- 5) Recrear procedimientos almacenados
DELIMITER $$

-- A) Listar SOLO activos
DROP PROCEDURE IF EXISTS sp_listar_tipo_reporte_activos $$
CREATE PROCEDURE sp_listar_tipo_reporte_activos()
BEGIN
    SELECT id_tipo_reporte, nombre, descripcion, created_by, created_at, updated_by, updated_at
    FROM tipo_reporte
    WHERE deleted = 0
    ORDER BY id_tipo_reporte;
END $$

-- B) Listar TODOS (incluye eliminados)
DROP PROCEDURE IF EXISTS sp_listar_tipo_reporte_todos $$
CREATE PROCEDURE sp_listar_tipo_reporte_todos()
BEGIN
    SELECT id_tipo_reporte, nombre, descripcion, created_by, created_at, updated_by, updated_at, deleted
    FROM tipo_reporte
    ORDER BY id_tipo_reporte;
END $$

-- C) Insertar y devolver ID nuevo (OUT)
DROP PROCEDURE IF EXISTS sp_insertar_tipo_reporte $$
CREATE PROCEDURE sp_insertar_tipo_reporte(
    IN p_nombre VARCHAR(100),
    IN p_descripcion VARCHAR(255),
    IN p_created_by VARCHAR(50),
    OUT p_nuevo_id INT
)
BEGIN
    INSERT INTO tipo_reporte (nombre, descripcion, created_by)
    VALUES (p_nombre, p_descripcion, p_created_by);
    SET p_nuevo_id = LAST_INSERT_ID();
END $$

-- D) Borrado lógico
DROP PROCEDURE IF EXISTS sp_borrado_logico_tipo_reporte $$
CREATE PROCEDURE sp_borrado_logico_tipo_reporte(IN p_id_tipo_reporte INT)
BEGIN
    UPDATE tipo_reporte
    SET deleted = 1,
        updated_at = NOW()
    WHERE id_tipo_reporte = p_id_tipo_reporte AND deleted = 0;
END $$

-- E) Restaurar (opcional)
DROP PROCEDURE IF EXISTS sp_restaurar_tipo_reporte $$
CREATE PROCEDURE sp_restaurar_tipo_reporte(IN p_id_tipo_reporte INT)
BEGIN
    UPDATE tipo_reporte
    SET deleted = 0,
        updated_at = NOW()
    WHERE id_tipo_reporte = p_id_tipo_reporte AND deleted = 1;
END $$

DELIMITER ;
