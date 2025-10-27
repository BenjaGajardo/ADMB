-- ==========================================
-- Base de datos: seguridad_plazas
-- Tabla: personas
-- ==========================================

-- 1) Crear base y usarla
CREATE DATABASE IF NOT EXISTS seguridad_plazas;
USE seguridad_plazas;

-- 2) Crear tabla si no existe
CREATE TABLE IF NOT EXISTS personas (
    id_persona INT AUTO_INCREMENT PRIMARY KEY,
    rut VARCHAR(12) NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    correo VARCHAR(100) NULL DEFAULT NULL,
    telefono VARCHAR(15) NULL DEFAULT NULL,
    direccion VARCHAR(150) NULL DEFAULT NULL,
    id_comuna INT NULL DEFAULT NULL,
    eliminado TINYINT(1) NOT NULL DEFAULT 0,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
    deleted_at DATETIME NULL DEFAULT NULL
);

-- 3) Poblar datos de ejemplo
INSERT INTO personas (rut, nombre, correo, telefono, direccion, id_comuna)
SELECT '11111111-1', 'Juan Pérez', 'juanperez@mail.com', '987654321', 'Av. Siempre Viva 123', 1
WHERE NOT EXISTS (SELECT 1 FROM personas WHERE id_persona = 1);

INSERT INTO personas (rut, nombre, correo, telefono, direccion, id_comuna)
SELECT '22222222-2', 'Ana Gómez', 'anagomez@mail.com', '912345678', 'Calle Falsa 456', 2
WHERE NOT EXISTS (SELECT 1 FROM personas WHERE id_persona = 2);

INSERT INTO personas (rut, nombre, correo, telefono, direccion, id_comuna)
SELECT '33333333-3', 'Carlos Rojas', 'carlosrojas@mail.com', '923456789', 'Pasaje Los Álamos 789', 3
WHERE NOT EXISTS (SELECT 1 FROM personas WHERE id_persona = 3);

-- 4) Procedimientos almacenados
DELIMITER $$

-- A) Listar personas activas
DROP PROCEDURE IF EXISTS sp_listar_personas_activas $$
CREATE PROCEDURE sp_listar_personas_activas()
BEGIN
    SELECT id_persona, rut, nombre, correo, telefono, direccion, id_comuna, created_at, updated_at
    FROM personas
    WHERE eliminado = 0
    ORDER BY id_persona;
END $$

-- B) Listar todas las personas
DROP PROCEDURE IF EXISTS sp_listar_personas_todos $$
CREATE PROCEDURE sp_listar_personas_todos()
BEGIN
    SELECT id_persona, rut, nombre, correo, telefono, direccion, id_comuna, eliminado, created_at, updated_at, deleted_at
    FROM personas
    ORDER BY id_persona;
END $$

-- C) Insertar persona y devolver ID
DROP PROCEDURE IF EXISTS sp_insertar_persona $$
CREATE PROCEDURE sp_insertar_persona(
    IN p_rut VARCHAR(12),
    IN p_nombre VARCHAR(100),
    IN p_correo VARCHAR(100),
    IN p_telefono VARCHAR(15),
    IN p_direccion VARCHAR(150),
    IN p_id_comuna INT,
    OUT p_nuevo_id INT
)
BEGIN
    INSERT INTO personas (rut, nombre, correo, telefono, direccion, id_comuna)
    VALUES (p_rut, p_nombre, p_correo, p_telefono, p_direccion, p_id_comuna);

    SET p_nuevo_id = LAST_INSERT_ID();
END $$

-- D) Borrado lógico
DROP PROCEDURE IF EXISTS sp_borrado_logico_persona $$
CREATE PROCEDURE sp_borrado_logico_persona(IN p_id INT)
BEGIN
    UPDATE personas
    SET eliminado = 1,
        deleted_at = NOW()
    WHERE id_persona = p_id AND eliminado = 0;
END $$

-- E) Restaurar persona
DROP PROCEDURE IF EXISTS sp_restaurar_persona $$
CREATE PROCEDURE sp_restaurar_persona(IN p_id INT)
BEGIN
    UPDATE personas
    SET eliminado = 0,
        deleted_at = NULL
    WHERE id_persona = p_id AND eliminado = 1;
END $$

DELIMITER ;
