-- ==========================================
-- Base de datos: seguridad_plazas
-- Tabla: reportes
-- ==========================================

-- 1) Crear base y usarla
CREATE DATABASE IF NOT EXISTS seguridad_plazas;
USE seguridad_plazas;

-- 2) Crear tabla si no existe (con estructura mínima)
CREATE TABLE IF NOT EXISTS reportes (
  id_reporte INT NOT NULL AUTO_INCREMENT,
  id_tipo_reporte INT NOT NULL,
  descripcion TEXT NULL DEFAULT NULL,
  fecha DATE NOT NULL,
  hora TIME NOT NULL,
  id_usuario INT NOT NULL,
  id_plaza INT NOT NULL,
  created_by VARCHAR(50) NULL DEFAULT NULL,
  created_at DATETIME NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by VARCHAR(50) NULL DEFAULT NULL,
  updated_at DATETIME NULL DEFAULT NULL,
  deleted TINYINT(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (id_reporte),
  INDEX id_usuario (id_usuario ASC),
  INDEX id_plaza (id_plaza ASC),
  INDEX id_tipo_reporte (id_tipo_reporte ASC),
  CONSTRAINT reportes_ibfk_1 FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario),
  CONSTRAINT reportes_ibfk_2 FOREIGN KEY (id_plaza) REFERENCES plazas(id_plaza),
  CONSTRAINT reportes_ibfk_tipo FOREIGN KEY (id_tipo_reporte) REFERENCES tipo_reporte(id_tipo_reporte)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 3) Columnas de auditoría y borrado lógico ya incluidas

-- 4) Poblar datos de ejemplo SOLO si está vacía
INSERT INTO reportes (id_tipo_reporte, descripcion, fecha, hora, id_usuario, id_plaza, created_by)
SELECT 1, 'Persona sospechosa merodeando', '2025-10-22', '14:30:00', 1, 1, 'admin'
WHERE NOT EXISTS (SELECT 1 FROM reportes LIMIT 1);

INSERT INTO reportes (id_tipo_reporte, descripcion, fecha, hora, id_usuario, id_plaza, created_by)
SELECT 2, 'Accidente leve en la plaza', '2025-10-22', '16:00:00', 1, 2, 'admin'
WHERE NOT EXISTS (SELECT 1 FROM reportes LIMIT 1 OFFSET 1);

-- 5) Recrear procedimientos almacenados
DELIMITER $$

-- A) Listar SOLO activos
DROP PROCEDURE IF EXISTS sp_listar_reportes_activos $$
CREATE PROCEDURE sp_listar_reportes_activos()
BEGIN
    SELECT id_reporte, id_tipo_reporte, descripcion, fecha, hora, id_usuario, id_plaza, created_by, created_at, updated_by, updated_at
    FROM reportes
    WHERE deleted = 0
    ORDER BY id_reporte;
END $$

-- B) Listar TODOS (incluye eliminados)
DROP PROCEDURE IF EXISTS sp_listar_reportes_todos $$
CREATE PROCEDURE sp_listar_reportes_todos()
BEGIN
    SELECT id_reporte, id_tipo_reporte, descripcion, fecha, hora, id_usuario, id_plaza, created_by, created_at, updated_by, updated_at, deleted
    FROM reportes
    ORDER BY id_reporte;
END $$

-- C) Insertar y devolver ID nuevo (OUT)
DROP PROCEDURE IF EXISTS sp_insertar_reporte $$
CREATE PROCEDURE sp_insertar_reporte(
    IN p_id_tipo_reporte INT,
    IN p_descripcion TEXT,
    IN p_fecha DATE,
    IN p_hora TIME,
    IN p_id_usuario INT,
    IN p_id_plaza INT,
    IN p_created_by VARCHAR(50),
    OUT p_nuevo_id INT
)
BEGIN
    INSERT INTO reportes (id_tipo_reporte, descripcion, fecha, hora, id_usuario, id_plaza, created_by)
    VALUES (p_id_tipo_reporte, p_descripcion, p_fecha, p_hora, p_id_usuario, p_id_plaza, p_created_by);
    SET p_nuevo_id = LAST_INSERT_ID();
END $$

-- D) Borrado lógico
DROP PROCEDURE IF EXISTS sp_borrado_logico_reporte $$
CREATE PROCEDURE sp_borrado_logico_reporte(IN p_id_reporte INT)
BEGIN
    UPDATE reportes
    SET deleted = 1,
        updated_at = NOW()
    WHERE id_reporte = p_id_reporte AND deleted = 0;
END $$

-- E) Restaurar (opcional)
DROP PROCEDURE IF EXISTS sp_restaurar_reporte $$
CREATE PROCEDURE sp_restaurar_reporte(IN p_id_reporte INT)
BEGIN
    UPDATE reportes
    SET deleted = 0,
        updated_at = NOW()
    WHERE id_reporte = p_id_reporte AND deleted = 1;
END $$

DELIMITER ;
