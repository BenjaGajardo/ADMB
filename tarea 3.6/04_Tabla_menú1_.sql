-- 1) Crear base y usarla
CREATE DATABASE IF NOT EXISTS seguridad_plaza;
USE seguridad_plaza;

-- 2) Crear tabla si no existe (con estructura mínima)
CREATE TABLE IF NOT EXISTS usuarios (
    id_usuario INT AUTO_INCREMENT PRIMARY KEY,
    id_persona INT NOT NULL,
    contrasena VARCHAR(255) NOT NULL,
    id_tipo_usuario INT NOT NULL
);

-- 3) Asegurar columnas de auditoría y borrado lógico (MySQL 8.0.29+: IF NOT EXISTS)
ALTER TABLE usuarios
  ADD COLUMN eliminado  TINYINT(1) NOT NULL DEFAULT 0 AFTER id_tipo_usuario,
  ADD COLUMN created_at DATETIME  NOT NULL DEFAULT CURRENT_TIMESTAMP,
  ADD COLUMN updated_at DATETIME NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  ADD COLUMN deleted_at DATETIME NULL DEFAULT NULL;

-- 4) Poblar datos de ejemplo SOLO si está vacía
INSERT INTO usuarios (id_persona, contrasena, id_tipo_usuario)
SELECT 1, 'admin123', 1
WHERE NOT EXISTS (SELECT 1 FROM usuarios LIMIT 1);
INSERT INTO usuarios (id_persona, contrasena, id_tipo_usuario)
SELECT 2, 'user456', 2
WHERE NOT EXISTS (SELECT 1 FROM usuarios LIMIT 1 OFFSET 1);
INSERT INTO usuarios (id_persona, contrasena, id_tipo_usuario)
SELECT 3, 'soporte789', 3
WHERE NOT EXISTS (SELECT 1 FROM usuarios LIMIT 1 OFFSET 2);

-- 5) Recrear procedimientos almacenados
DELIMITER $$

-- A) Listar SOLO activos
DROP PROCEDURE IF EXISTS sp_listar_usuarios_activos $$
CREATE PROCEDURE sp_listar_usuarios_activos()
BEGIN
    SELECT id_usuario, id_persona, contrasena, id_tipo_usuario, created_at, updated_at
    FROM usuarios
    WHERE eliminado = 0
    ORDER BY id_usuario;
END $$

-- B) Listar TODOS (incluye eliminados)
DROP PROCEDURE IF EXISTS sp_listar_usuarios_todos $$
CREATE PROCEDURE sp_listar_usuarios_todos()
BEGIN
    SELECT id_usuario, id_persona, contrasena, id_tipo_usuario, eliminado, created_at, updated_at, deleted_at
    FROM usuarios
    ORDER BY id_usuario;
END $$

-- C) Insertar y devolver ID nuevo (OUT)
DROP PROCEDURE IF EXISTS sp_insertar_usuario $$
CREATE PROCEDURE sp_insertar_usuario(
    IN  p_id_persona INT,
    IN  p_contrasena VARCHAR(255),
    IN  p_id_tipo_usuario INT,
    OUT p_nuevo_id INT
)
BEGIN
    INSERT INTO usuarios (id_persona, contrasena, id_tipo_usuario)
    VALUES (p_id_persona, p_contrasena, p_id_tipo_usuario);

    SET p_nuevo_id = LAST_INSERT_ID();
END $$

-- D) Borrado lógico
DROP PROCEDURE IF EXISTS sp_borrado_logico_usuario $$
CREATE PROCEDURE sp_borrado_logico_usuario(IN p_id_usuario INT)
BEGIN
    UPDATE usuarios
    SET eliminado = 1,
        deleted_at = NOW()
    WHERE id_usuario = p_id_usuario AND eliminado = 0;
END $$

-- E) Restaurar (opcional)
DROP PROCEDURE IF EXISTS sp_restaurar_usuario $$
CREATE PROCEDURE sp_restaurar_usuario(IN p_id_usuario INT)
BEGIN
    UPDATE usuarios
    SET eliminado = 0,
        deleted_at = NULL
    WHERE id_usuario = p_id_usuario AND eliminado = 1;
END $$

DELIMITER ;
