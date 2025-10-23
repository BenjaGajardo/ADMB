-- ==========================================
-- Base de datos: seguridad_plazas
-- Tabla: plazas
-- ==========================================

-- 1) Crear base y usarla
CREATE DATABASE IF NOT EXISTS seguridad_plazas;
USE seguridad_plazas;

-- 2) Crear tabla si no existe
CREATE TABLE IF NOT EXISTS plazas (
    id_plaza INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    direccion VARCHAR(150) NOT NULL,
    id_comuna INT NULL DEFAULT NULL,
    created_by VARCHAR(50) NULL DEFAULT NULL,
    created_at DATETIME NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(50) NULL DEFAULT NULL,
    updated_at DATETIME NULL DEFAULT NULL,
    deleted TINYINT(1) NOT NULL DEFAULT 0,
    INDEX id_comuna (id_comuna ASC),
    CONSTRAINT plazas_ibfk_1 FOREIGN KEY (id_comuna)
        REFERENCES comunas(id_comuna),
    CHECK (CHAR_LENGTH(nombre) > 0),
    CHECK (CHAR_LENGTH(direccion) > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 3) Poblar datos de ejemplo SOLO si está vacía
INSERT INTO plazas (nombre, direccion, id_comuna, created_by)
SELECT 'Plaza de Armas', 'Av. Libertador Bernardo O''Higgins 1000', 1, 'admin'
WHERE NOT EXISTS (SELECT 1 FROM plazas LIMIT 1);
INSERT INTO plazas (nombre, direccion, id_comuna, created_by)
SELECT 'Plaza Italia', 'Av. Providencia 1500', 2, 'admin'
WHERE NOT EXISTS (SELECT 1 FROM plazas LIMIT 1 OFFSET 1);
INSERT INTO plazas (nombre, direccion, id_comuna, created_by)
SELECT 'Parque Araucano', 'Av. Las Condes 6000', 3, 'admin'
WHERE NOT EXISTS (SELECT 1 FROM plazas LIMIT 1 OFFSET 2);

-- 4) Procedimientos almacenados
DELIMITER $$

-- A) Listar solo plazas activas
DROP PROCEDURE IF EXISTS sp_listar_plazas_activas $$
CREATE PROCEDURE sp_listar_plazas_activas()
BEGIN
    SELECT p.id_plaza, p.nombre, p.direccion, p.id_comuna, c.nombre AS comuna, 
           p.created_by, p.created_at, p.updated_by, p.updated_at
    FROM plazas p
    LEFT JOIN comunas c ON p.id_comuna = c.id_comuna
    WHERE p.deleted = 0
    ORDER BY p.id_plaza;
END $$

-- B) Listar todas las plazas (incluye eliminadas)
DROP PROCEDURE IF EXISTS sp_listar_plazas_todos $$
CREATE PROCEDURE sp_listar_plazas_todos()
BEGIN
    SELECT p.id_plaza, p.nombre, p.direccion, p.id_comuna, c.nombre AS comuna, 
           p.created_by, p.created_at, p.updated_by, p.updated_at, p.deleted
    FROM plazas p
    LEFT JOIN comunas c ON p.id_comuna = c.id_comuna
    ORDER BY p.id_plaza;
END $$

-- C) Insertar nueva plaza y devolver ID
DROP PROCEDURE IF EXISTS sp_insertar_plaza $$
CREATE PROCEDURE sp_insertar_plaza(
    IN p_nombre VARCHAR(100),
    IN p_direccion VARCHAR(150),
    IN p_id_comuna INT,
    IN p_created_by VARCHAR(50),
    OUT p_nuevo_id INT
)
BEGIN
    INSERT INTO plazas (nombre, direccion, id_comuna, created_by)
    VALUES (p_nombre, p_direccion, p_id_comuna, p_created_by);
    SET p_nuevo_id = LAST_INSERT_ID();
END $$

-- D) Borrado lógico
DROP PROCEDURE IF EXISTS sp_borrado_logico_plaza $$
CREATE PROCEDURE sp_borrado_logico_plaza(IN p_id INT)
BEGIN
    UPDATE plazas
    SET deleted = 1,
        updated_at = NOW()
    WHERE id_plaza = p_id AND deleted = 0;
END $$

-- E) Restaurar plaza eliminada
DROP PROCEDURE IF EXISTS sp_restaurar_plaza $$
CREATE PROCEDURE sp_restaurar_plaza(IN p_id INT)
BEGIN
    UPDATE plazas
    SET deleted = 0,
        updated_at = NOW()
    WHERE id_plaza = p_id AND deleted = 1;
END $$

DELIMITER ;
