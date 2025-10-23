-- ==========================================
-- Base de datos: seguridad_plazas
-- Tabla: tipo_usuarios
-- ==========================================

-- 1) Crear base y usarla
CREATE DATABASE IF NOT EXISTS seguridad_plazas;
USE seguridad_plazas;

-- 2) Crear tabla si no existe (con estructura mínima)
CREATE TABLE IF NOT EXISTS tipo_usuarios (
  id_tipo_usuario INT NOT NULL AUTO_INCREMENT,
  nombre VARCHAR(50) NOT NULL,
  descripcion VARCHAR(200) NOT NULL,
  created_by VARCHAR(50) NULL DEFAULT NULL,
  created_at DATETIME NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by VARCHAR(50) NULL DEFAULT NULL,
  updated_at DATETIME NULL DEFAULT NULL,
  deleted TINYINT(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (id_tipo_usuario),
  UNIQUE INDEX nombre (nombre ASC),
  CHECK (CHAR_LENGTH(nombre) > 0),
  CHECK (CHAR_LENGTH(descripcion) > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 3) Asegurar columnas de auditoría y borrado lógico (ya incluidas arriba)

-- 4) Poblar datos de ejemplo SOLO si está vacía
INSERT INTO tipo_usuarios (nombre, descripcion, created_by)
SELECT 'Administrador', 'Usuario con todos los permisos', 'admin'
WHERE NOT EXISTS (SELECT 1 FROM tipo_usuarios LIMIT 1);
INSERT INTO tipo_usuarios (nombre, descripcion, created_by)
SELECT 'Vecino', 'Usuario regular', 'admin'
WHERE NOT EXISTS (SELECT 1 FROM tipo_usuarios LIMIT 1 OFFSET 1);

-- 5) Recrear procedimientos almacenados
DELIMITER $$

-- A) Listar SOLO activos
DROP PROCEDURE IF EXISTS sp_listar_tipo_usuarios_activos $$
CREATE PROCEDURE sp_listar_tipo_usuarios_activos()
BEGIN
    SELECT id_tipo_usuario, nombre, descripcion, created_by, created_at, updated_by, updated_at
    FROM tipo_usuarios
    WHERE deleted = 0
    ORDER BY id_tipo_usuario;
END $$

-- B) Listar TODOS (incluye eliminados)
DROP PROCEDURE IF EXISTS sp_listar_tipo_usuarios_todos $$
CREATE PROCEDURE sp_listar_tipo_usuarios_todos()
BEGIN
    SELECT id_tipo_usuario, nombre, descripcion, created_by, created_at, updated_by, updated_at, deleted
    FROM tipo_usuarios
    ORDER BY id_tipo_usuario;
END $$

-- C) Insertar y devolver ID nuevo (OUT)
DROP PROCEDURE IF EXISTS sp_insertar_tipo_usuario $$
CREATE PROCEDURE sp_insertar_tipo_usuario(
    IN p_nombre VARCHAR(50),
    IN p_descripcion VARCHAR(200),
    IN p_created_by VARCHAR(50),
    OUT p_nuevo_id INT
)
BEGIN
    INSERT INTO tipo_usuarios (nombre, descripcion, created_by)
    VALUES (p_nombre, p_descripcion, p_created_by);
    SET p_nuevo_id = LAST_INSERT_ID();
END $$

-- D) Borrado lógico
DROP PROCEDURE IF EXISTS sp_borrado_logico_tipo_usuario $$
CREATE PROCEDURE sp_borrado_logico_tipo_usuario(IN p_id_tipo_usuario INT)
BEGIN
    UPDATE tipo_usuarios
    SET deleted = 1,
        updated_at = NOW()
    WHERE id_tipo_usuario = p_id_tipo_usuario AND deleted = 0;
END $$

-- E) Restaurar (opcional)
DROP PROCEDURE IF EXISTS sp_restaurar_tipo_usuario $$
CREATE PROCEDURE sp_restaurar_tipo_usuario(IN p_id_tipo_usuario INT)
BEGIN
    UPDATE tipo_usuarios
    SET deleted = 0,
        updated_at = NOW()
    WHERE id_tipo_usuario = p_id_tipo_usuario AND deleted = 1;
END $$

DELIMITER ;
