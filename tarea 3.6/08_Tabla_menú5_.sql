-- ==========================================
-- Base de datos: seguridad_plazas
-- Tabla: camaras
-- ==========================================

-- 1) Crear base y usarla
CREATE DATABASE IF NOT EXISTS seguridad_plazas;
USE seguridad_plazas;

-- 2) Crear tabla si no existe
CREATE TABLE IF NOT EXISTS camaras (
    id_camara INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    ubicacion VARCHAR(100) NOT NULL,
    id_estado_camara INT NOT NULL,
    id_plaza INT NOT NULL,
    created_by VARCHAR(50) NULL DEFAULT NULL,
    created_at DATETIME NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(50) NULL DEFAULT NULL,
    updated_at DATETIME NULL DEFAULT NULL,
    deleted TINYINT(1) NOT NULL DEFAULT 0,
    INDEX id_plaza (id_plaza ASC),
    INDEX id_estado_camara (id_estado_camara ASC),
    CONSTRAINT camaras_ibfk_1 FOREIGN KEY (id_plaza) REFERENCES plazas(id_plaza),
    CONSTRAINT camaras_ibfk_estado FOREIGN KEY (id_estado_camara) REFERENCES estado_camara(id_estado_camara),
    CHECK (CHAR_LENGTH(ubicacion) > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 3) Poblar datos de ejemplo SOLO si está vacía
INSERT INTO camaras (ubicacion, id_estado_camara, id_plaza, created_by)
SELECT 'Entrada principal', 1, 1, 'admin'
WHERE NOT EXISTS (SELECT 1 FROM camaras LIMIT 1);

INSERT INTO camaras (ubicacion, id_estado_camara, id_plaza, created_by)
SELECT 'Estacionamiento', 1, 1, 'admin'
WHERE NOT EXISTS (SELECT 1 FROM camaras LIMIT 1 OFFSET 1);

-- 4) Procedimientos almacenados
DELIMITER $$

-- A) Listar solo cámaras activas
DROP PROCEDURE IF EXISTS sp_listar_camaras_activas $$
CREATE PROCEDURE sp_listar_camaras_activas()
BEGIN
    SELECT c.id_camara, c.ubicacion, c.id_estado_camara, c.id_plaza,
           c.created_by, c.created_at, c.updated_by, c.updated_at
    FROM camaras c
    WHERE c.deleted = 0
    ORDER BY c.id_camara;
END $$

-- B) Listar todas las cámaras (incluye eliminadas)
DROP PROCEDURE IF EXISTS sp_listar_camaras_todas $$
CREATE PROCEDURE sp_listar_camaras_todas()
BEGIN
    SELECT c.id_camara, c.ubicacion, c.id_estado_camara, c.id_plaza,
           c.created_by, c.created_at, c.updated_by, c.updated_at, c.deleted
    FROM camaras c
    ORDER BY c.id_camara;
END $$

-- C) Insertar nueva cámara y devolver ID
DROP PROCEDURE IF EXISTS sp_insertar_camara $$
CREATE PROCEDURE sp_insertar_camara(
    IN p_ubicacion VARCHAR(100),
    IN p_id_estado_camara INT,
    IN p_id_plaza INT,
    IN p_created_by VARCHAR(50),
    OUT p_nuevo_id INT
)
BEGIN
    INSERT INTO camaras (ubicacion, id_estado_camara, id_plaza, created_by)
    VALUES (p_ubicacion, p_id_estado_camara, p_id_plaza, p_created_by);
    SET p_nuevo_id = LAST_INSERT_ID();
END $$

-- D) Borrado lógico
DROP PROCEDURE IF EXISTS sp_borrado_logico_camara $$
CREATE PROCEDURE sp_borrado_logico_camara(IN p_id INT)
BEGIN
    UPDATE camaras
    SET deleted = 1,
        updated_at = NOW()
    WHERE id_camara = p_id AND deleted = 0;
END $$

-- E) Restaurar cámara eliminada
DROP PROCEDURE IF EXISTS sp_restaurar_camara $$
CREATE PROCEDURE sp_restaurar_camara(IN p_id INT)
BEGIN
    UPDATE camaras
    SET deleted = 0,
        updated_at = NOW()
    WHERE id_camara = p_id AND deleted = 1;
END $$

DELIMITER ;
