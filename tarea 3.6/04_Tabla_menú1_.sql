-- ==========================================
-- Base de datos: seguridad_plazas
-- Tabla: usuario
-- ==========================================

-- 1) Crear base y usarla
CREATE DATABASE IF NOT EXISTS seguridad_plazas;
USE seguridad_plazas;

-- 2) Crear tabla si no existe (con estructura mínima)
CREATE TABLE IF NOT EXISTS usuarios (
  id_usuario INT NOT NULL AUTO_INCREMENT,
  id_persona INT NOT NULL,
  contrasena VARCHAR(255) NOT NULL,
  id_tipo_usuario INT NOT NULL,
  created_by VARCHAR(50) NULL DEFAULT NULL,
  created_at DATETIME NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by VARCHAR(50) NULL DEFAULT NULL,
  updated_at DATETIME NULL DEFAULT NULL,
  deleted TINYINT(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (id_usuario),
  UNIQUE INDEX id_persona (id_persona ASC),
  INDEX id_tipo_usuario (id_tipo_usuario ASC),
  CONSTRAINT usuarios_ibfk_persona FOREIGN KEY (id_persona) REFERENCES personas(id_persona),
  CONSTRAINT usuarios_ibfk_tipo FOREIGN KEY (id_tipo_usuario) REFERENCES tipo_usuarios(id_tipo_usuario),
  CHECK (CHAR_LENGTH(contrasena) > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 3) Asegurar columnas de auditoría y borrado lógico (ya incluidas arriba)

-- 4) Poblar datos de ejemplo SOLO si está vacía
INSERT INTO usuarios (id_persona, contrasena, id_tipo_usuario, created_by)
SELECT 1, 'pass123', 1, 'admin'
WHERE NOT EXISTS (SELECT 1 FROM usuarios LIMIT 1);
INSERT INTO usuarios (id_persona, contrasena, id_tipo_usuario, created_by)
SELECT 2, 'abc456', 2, 'admin'
WHERE NOT EXISTS (SELECT 1 FROM usuarios LIMIT 1 OFFSET 1);

-- 5) Recrear procedimientos almacenados
DELIMITER $$

-- A) Listar SOLO activos
DROP PROCEDURE IF EXISTS sp_listar_usuarios_activos $$
CREATE PROCEDURE sp_listar_usuarios_activos()
BEGIN
    SELECT id_usuario, id_persona, contrasena, id_tipo_usuario, created_by, created_at, updated_by, updated_at
    FROM usuarios
    WHERE deleted = 0
    ORDER BY id_usuario;
END $$

-- B) Listar TODOS (incluye eliminados)
DROP PROCEDURE IF EXISTS sp_listar_usuarios_todos $$
CREATE PROCEDURE sp_listar_usuarios_todos()
BEGIN
    SELECT id_usuario, id_persona, contrasena, id_tipo_usuario, created_by, created_at, updated_by, updated_at, deleted
    FROM usuarios
    ORDER BY id_usuario;
END $$

-- C) Insertar y devolver ID nuevo (OUT)
DROP PROCEDURE IF EXISTS sp_insertar_usuario $$
CREATE PROCEDURE sp_insertar_usuario(
    IN p_id_persona INT,
    IN p_contrasena VARCHAR(255),
    IN p_id_tipo_usuario INT,
    IN p_created_by VARCHAR(50),
    OUT p_nuevo_id INT
)
BEGIN
    INSERT INTO usuarios (id_persona, contrasena, id_tipo_usuario, created_by)
    VALUES (p_id_persona, p_contrasena, p_id_tipo_usuario, p_created_by);
    SET p_nuevo_id = LAST_INSERT_ID();
END $$

-- D) Borrado lógico
DROP PROCEDURE IF EXISTS sp_borrado_logico_usuario $$
CREATE PROCEDURE sp_borrado_logico_usuario(IN p_id_usuario INT)
BEGIN
    UPDATE usuarios
    SET deleted = 1,
        updated_at = NOW()
    WHERE id_usuario = p_id_usuario AND deleted = 0;
END $$

-- E) Restaurar (opcional)
DROP PROCEDURE IF EXISTS sp_restaurar_usuario $$
CREATE PROCEDURE sp_restaurar_usuario(IN p_id_usuario INT)
BEGIN
    UPDATE usuarios
    SET deleted = 0,
        updated_at = NOW()
    WHERE id_usuario = p_id_usuario AND deleted = 1;
END $$

DELIMITER ;
