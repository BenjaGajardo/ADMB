USE seguridad_plazas;

-- ==========================================================
-- ELIMINACIÓN DE PROCEDIMIENTOS ANTERIORES
-- ==========================================================
DROP PROCEDURE IF EXISTS sp_tipo_usuarios_insertar;
DROP PROCEDURE IF EXISTS sp_tipo_usuarios_listar_activos;
DROP PROCEDURE IF EXISTS sp_tipo_usuarios_borrado_logico;
DROP PROCEDURE IF EXISTS sp_tipo_usuarios_listar_todo;
DROP PROCEDURE IF EXISTS sp_comunas_insertar;
DROP PROCEDURE IF EXISTS sp_comunas_listar_activos;
DROP PROCEDURE IF EXISTS sp_comunas_borrado_logico;
DROP PROCEDURE IF EXISTS sp_comunas_listar_todo;
DROP PROCEDURE IF EXISTS sp_plazas_insertar;
DROP PROCEDURE IF EXISTS sp_plazas_listar_activos;
DROP PROCEDURE IF EXISTS sp_plazas_borrado_logico;
DROP PROCEDURE IF EXISTS sp_plazas_listar_todo;
DROP PROCEDURE IF EXISTS sp_estado_camara_insertar;
DROP PROCEDURE IF EXISTS sp_estado_camara_listar_activos;
DROP PROCEDURE IF EXISTS sp_estado_camara_borrado_logico;
DROP PROCEDURE IF EXISTS sp_estado_camara_listar_todo;
DROP PROCEDURE IF EXISTS sp_camaras_insertar;
DROP PROCEDURE IF EXISTS sp_camaras_listar_activas;
DROP PROCEDURE IF EXISTS sp_camaras_borrado_logico;
DROP PROCEDURE IF EXISTS sp_camaras_listar_todo;
DROP PROCEDURE IF EXISTS sp_personas_insertar;
DROP PROCEDURE IF EXISTS sp_personas_listar_activas;
DROP PROCEDURE IF EXISTS sp_personas_borrado_logico;
DROP PROCEDURE IF EXISTS sp_personas_listar_todo;
DROP PROCEDURE IF EXISTS sp_juntas_vecinos_insertar;
DROP PROCEDURE IF EXISTS sp_juntas_vecinos_listar_activas;
DROP PROCEDURE IF EXISTS sp_juntas_vecinos_borrado_logico;
DROP PROCEDURE IF EXISTS sp_juntas_vecinos_listar_todo;
DROP PROCEDURE IF EXISTS sp_usuarios_insertar;
DROP PROCEDURE IF EXISTS sp_usuarios_listar_activos;
DROP PROCEDURE IF EXISTS sp_usuarios_borrado_logico;
DROP PROCEDURE IF EXISTS sp_usuarios_listar_todo;
DROP PROCEDURE IF EXISTS sp_tipo_reporte_insertar;
DROP PROCEDURE IF EXISTS sp_tipo_reporte_listar_activos;
DROP PROCEDURE IF EXISTS sp_tipo_reporte_borrado_logico;
DROP PROCEDURE IF EXISTS sp_tipo_reporte_listar_todo;
DROP PROCEDURE IF EXISTS sp_reportes_insertar;
DROP PROCEDURE IF EXISTS sp_reportes_listar_activos;
DROP PROCEDURE IF EXISTS sp_reportes_borrado_logico;
DROP PROCEDURE IF EXISTS sp_reportes_listar_todo;

-- ==========================================================
-- PROCEDIMIENTOS ALMACENADOS (Código omitido por brevedad, es el mismo y correcto)
-- ==========================================================
DELIMITER //
CREATE PROCEDURE sp_tipo_usuarios_insertar( IN p_nombre VARCHAR(50), IN p_descripcion VARCHAR(200), IN p_created_by VARCHAR(50) ) BEGIN INSERT INTO tipo_usuarios (nombre, descripcion, created_by, deleted) VALUES (p_nombre, p_descripcion, p_created_by, 0); END//
CREATE PROCEDURE sp_tipo_usuarios_listar_activos() BEGIN SELECT id_tipo_usuario, nombre, descripcion, created_by, created_at FROM tipo_usuarios WHERE deleted = 0 ORDER BY nombre; END//
CREATE PROCEDURE sp_tipo_usuarios_borrado_logico( IN p_id INT ) BEGIN UPDATE tipo_usuarios SET deleted = 1 WHERE id_tipo_usuario = p_id; END//
CREATE PROCEDURE sp_tipo_usuarios_listar_todo() BEGIN SELECT * FROM tipo_usuarios ORDER BY nombre; END//

CREATE PROCEDURE sp_comunas_insertar( IN p_nombre VARCHAR(100), IN p_created_by VARCHAR(50) ) BEGIN INSERT INTO comunas (nombre, created_by, deleted) VALUES (p_nombre, p_created_by, 0); END//
CREATE PROCEDURE sp_comunas_listar_activos() BEGIN SELECT id_comuna, nombre, created_by, created_at FROM comunas WHERE deleted = 0 ORDER BY nombre; END//
CREATE PROCEDURE sp_comunas_borrado_logico( IN p_id INT ) BEGIN UPDATE comunas SET deleted = 1 WHERE id_comuna = p_id; END//
CREATE PROCEDURE sp_comunas_listar_todo() BEGIN SELECT * FROM comunas ORDER BY nombre; END//

CREATE PROCEDURE sp_plazas_insertar( IN p_nombre VARCHAR(100), IN p_direccion VARCHAR(150), IN p_id_comuna INT, IN p_created_by VARCHAR(50) ) BEGIN INSERT INTO plazas (nombre, direccion, id_comuna, created_by, deleted) VALUES (p_nombre, p_direccion, p_id_comuna, p_created_by, 0); END//
CREATE PROCEDURE sp_plazas_listar_activos() BEGIN SELECT p.*, c.nombre AS nombre_comuna FROM plazas p LEFT JOIN comunas c ON p.id_comuna = c.id_comuna WHERE p.deleted = 0; END//
CREATE PROCEDURE sp_plazas_borrado_logico( IN p_id INT ) BEGIN UPDATE plazas SET deleted = 1 WHERE id_plaza = p_id; END//
CREATE PROCEDURE sp_plazas_listar_todo() BEGIN SELECT * FROM plazas ORDER BY nombre; END//

CREATE PROCEDURE sp_estado_camara_insertar( IN p_nombre VARCHAR(50), IN p_descripcion VARCHAR(255), IN p_created_by VARCHAR(50) ) BEGIN INSERT INTO estado_camara (nombre, descripcion, created_by, deleted) VALUES (p_nombre, p_descripcion, p_created_by, 0); END//
CREATE PROCEDURE sp_estado_camara_listar_activos() BEGIN SELECT id_estado_camara, nombre, descripcion, created_by, created_at FROM estado_camara WHERE deleted = 0 ORDER BY nombre; END//
CREATE PROCEDURE sp_estado_camara_borrado_logico( IN p_id INT ) BEGIN UPDATE estado_camara SET deleted = 1 WHERE id_estado_camara = p_id; END//
CREATE PROCEDURE sp_estado_camara_listar_todo() BEGIN SELECT * FROM estado_camara ORDER BY nombre; END//

CREATE PROCEDURE sp_camaras_insertar( IN p_ubicacion VARCHAR(100), IN p_id_estado_camara INT, IN p_id_plaza INT, IN p_created_by VARCHAR(50) ) BEGIN INSERT INTO camaras (ubicacion, id_estado_camara, id_plaza, created_by, deleted) VALUES (p_ubicacion, p_id_estado_camara, p_id_plaza, p_created_by, 0); END//
CREATE PROCEDURE sp_camaras_listar_activas() BEGIN SELECT c.id_camara, c.ubicacion, e.nombre AS estado, p.nombre AS plaza FROM camaras c LEFT JOIN estado_camara e ON c.id_estado_camara = e.id_estado_camara LEFT JOIN plazas p ON c.id_plaza = p.id_plaza WHERE c.deleted = 0; END//
CREATE PROCEDURE sp_camaras_borrado_logico( IN p_id INT ) BEGIN UPDATE camaras SET deleted = 1 WHERE id_camara = p_id; END//
CREATE PROCEDURE sp_camaras_listar_todo() BEGIN SELECT * FROM camaras ORDER BY ubicacion; END//

CREATE PROCEDURE sp_personas_insertar( IN p_rut VARCHAR(12), IN p_nombre VARCHAR(100), IN p_correo VARCHAR(100), IN p_telefono VARCHAR(15), IN p_direccion VARCHAR(150), IN p_id_comuna INT, IN p_created_by VARCHAR(50) ) BEGIN INSERT INTO personas (rut, nombre, correo, telefono, direccion, id_comuna, created_by, deleted) VALUES (p_rut, p_nombre, p_correo, p_telefono, p_direccion, p_id_comuna, p_created_by, 0); END//
CREATE PROCEDURE sp_personas_listar_activas() BEGIN SELECT p.*, c.nombre AS comuna FROM personas p LEFT JOIN comunas c ON p.id_comuna = c.id_comuna WHERE p.deleted = 0; END//
CREATE PROCEDURE sp_personas_borrado_logico( IN p_id INT ) BEGIN UPDATE personas SET deleted = 1 WHERE id_persona = p_id; END//
CREATE PROCEDURE sp_personas_listar_todo() BEGIN SELECT * FROM personas ORDER BY nombre; END//

CREATE PROCEDURE sp_juntas_vecinos_insertar( IN p_nombre VARCHAR(100), IN p_id_comuna INT, IN p_created_by VARCHAR(50) ) BEGIN INSERT INTO juntas_vecinos (nombre, id_comuna, created_by, deleted) VALUES (p_nombre, p_id_comuna, p_created_by, 0); END//
CREATE PROCEDURE sp_juntas_vecinos_listar_activas() BEGIN SELECT j.id_junta, j.nombre, c.nombre AS comuna FROM juntas_vecinos j LEFT JOIN comunas c ON j.id_comuna = c.id_comuna WHERE j.deleted = 0; END//
CREATE PROCEDURE sp_juntas_vecinos_borrado_logico( IN p_id INT ) BEGIN UPDATE juntas_vecinos SET deleted = 1 WHERE id_junta = p_id; END//
CREATE PROCEDURE sp_juntas_vecinos_listar_todo() BEGIN SELECT * FROM juntas_vecinos ORDER BY nombre; END//

CREATE PROCEDURE sp_usuarios_insertar( IN p_id_persona INT, IN p_contrasena VARCHAR(255), IN p_id_tipo_usuario INT, IN p_created_by VARCHAR(50) ) BEGIN INSERT INTO usuarios (id_persona, contrasena, id_tipo_usuario, created_by, deleted) VALUES (p_id_persona, p_contrasena, p_id_tipo_usuario, p_created_by, 0); END//
CREATE PROCEDURE sp_usuarios_listar_activos() BEGIN SELECT u.id_usuario, p.rut, p.nombre AS nombre_persona, tu.nombre AS tipo_usuario FROM usuarios u LEFT JOIN tipo_usuarios tu ON u.id_tipo_usuario = tu.id_tipo_usuario LEFT JOIN personas p ON u.id_persona = p.id_persona WHERE u.deleted = 0 ORDER BY p.nombre; END//
CREATE PROCEDURE sp_usuarios_borrado_logico( IN p_id INT ) BEGIN UPDATE usuarios SET deleted = 1 WHERE id_usuario = p_id; END//
CREATE PROCEDURE sp_usuarios_listar_todo() BEGIN SELECT * FROM usuarios ORDER BY id_usuario; END//

CREATE PROCEDURE sp_tipo_reporte_insertar( IN p_nombre VARCHAR(50), IN p_descripcion VARCHAR(200), IN p_created_by VARCHAR(50) ) BEGIN INSERT INTO tipo_reporte (nombre, descripcion, created_by, deleted) VALUES (p_nombre, p_descripcion, p_created_by, 0); END//
CREATE PROCEDURE sp_tipo_reporte_listar_activos() BEGIN SELECT id_tipo_reporte, nombre, descripcion, created_by, created_at FROM tipo_reporte WHERE deleted = 0; END//
CREATE PROCEDURE sp_tipo_reporte_borrado_logico( IN p_id INT ) BEGIN UPDATE tipo_reporte SET deleted = 1 WHERE id_tipo_reporte = p_id; END//
CREATE PROCEDURE sp_tipo_reporte_listar_todo() BEGIN SELECT * FROM tipo_reporte ORDER BY nombre; END//

CREATE PROCEDURE sp_reportes_insertar( IN p_id_plaza INT, IN p_id_usuario INT, IN p_id_tipo_reporte INT, IN p_descripcion TEXT, IN p_created_by VARCHAR(50) ) BEGIN INSERT INTO reportes (id_tipo_reporte, descripcion, fecha, hora, id_usuario, id_plaza, created_by, deleted) VALUES (p_id_tipo_reporte, p_descripcion, CURDATE(), CURTIME(), p_id_usuario, p_id_plaza, p_created_by, 0); END//
CREATE PROCEDURE sp_reportes_listar_activos() BEGIN SELECT r.id_reporte, r.descripcion, r.fecha, r.hora, r.created_at, p.nombre AS nombre_plaza, pr.nombre AS nombre_usuario, tr.nombre AS tipo_reporte FROM reportes r LEFT JOIN plazas p ON r.id_plaza = p.id_plaza LEFT JOIN usuarios u ON r.id_usuario = u.id_usuario LEFT JOIN personas pr ON u.id_persona = pr.id_persona LEFT JOIN tipo_reporte tr ON r.id_tipo_reporte = tr.id_tipo_reporte WHERE r.deleted = 0 ORDER BY r.fecha DESC, r.hora DESC; END//
CREATE PROCEDURE sp_reportes_borrado_logico( IN p_id INT ) BEGIN UPDATE reportes SET deleted = 1 WHERE id_reporte = p_id; END//
CREATE PROCEDURE sp_reportes_listar_todo() BEGIN SELECT * FROM reportes ORDER BY id_reporte DESC; END//
DELIMITER ;

-- ==========================================================
-- PRUEBAS DE PROCEDIMIENTOS ALMACENADOS (CORREGIDO: TRUNCATE TABLE)
-- ==========================================================

-- 1. DESACTIVAR REVISIÓN DE LLAVES FORÁNEAS TEMPORALMENTE
SET FOREIGN_KEY_CHECKS = 0;

-- 2. LIMPIEZA DE DATOS COMPLETA (TRUNCATE TABLE)
-- Soluciona Error Code: 1175 y reinicia AUTO_INCREMENT.
TRUNCATE TABLE reportes;
TRUNCATE TABLE camaras;
TRUNCATE TABLE usuarios;
TRUNCATE TABLE juntas_vecinos;
TRUNCATE TABLE personas;
TRUNCATE TABLE plazas;
TRUNCATE TABLE tipo_reporte;
TRUNCATE TABLE tipo_usuarios;
TRUNCATE TABLE estado_camara;
TRUNCATE TABLE comunas;

-- 3. REACTIVAR REVISIÓN DE LLAVES FORÁNEAS
SET FOREIGN_KEY_CHECKS = 1;

-- 4. INSERCIÓN DE DATOS DE PRUEBA (CALLS)

-- 1. comunas 
CALL sp_comunas_insertar('Comuna Centro', 'admin'); -- id=1
CALL sp_comunas_insertar('Comuna Norte', 'admin'); -- id=2

-- 2. plazas 
CALL sp_plazas_insertar('Plaza Central', 'Calle Falsa 123', 1, 'admin'); -- id=1
CALL sp_plazas_insertar('Plaza Norte', 'Av. Norte 456', 2, 'admin'); -- id=2

-- 3. estado_camara 
CALL sp_estado_camara_insertar('ACTIVA', 'Cámara funcionando correctamente', 'admin'); -- id=1
CALL sp_estado_camara_insertar('INACTIVA', 'Cámara fuera de servicio', 'admin'); -- id=2

-- 4. camaras
CALL sp_camaras_insertar('Entrada principal Plaza Central', 1, 1, 'admin'); -- id=1
CALL sp_camaras_insertar('Zona norte Plaza Central', 1, 1, 'admin'); -- id=2

-- 5. tipo_usuarios 
CALL sp_tipo_usuarios_insertar('Administrador', 'Acceso completo al sistema', 'admin'); -- id=1
CALL sp_tipo_usuarios_insertar('Operador', 'Gestiona cámaras y reportes', 'admin'); -- id=2

-- 6. personas 
CALL sp_personas_insertar('12.345.678-9', 'Juan Pérez', 'juan@correo.cl', '912345678', 'Av. Libertad 123', 1, 'admin'); -- id=1
CALL sp_personas_insertar('11.222.333-4', 'Carlos Soto', 'carlos@soto.cl', '934567890', 'Los Robles 89', 1, 'admin'); -- id=2

-- 7. usuarios 
CALL sp_usuarios_insertar(1, SHA2('1234', 256), 1, 'admin'); -- Juan Pérez (Admin) id=1
CALL sp_usuarios_insertar(2, SHA2('4321', 256), 2, 'admin'); -- Carlos Soto (Operador) id=2

-- 8. tipo_reporte
CALL sp_tipo_reporte_insertar('Falla técnica', 'Reporte por fallas eléctricas o de red', 'admin'); -- id=1
CALL sp_tipo_reporte_insertar('Mantenimiento', 'Mantenimiento preventivo o correctivo', 'admin'); -- id=2

-- 9. reportes 
CALL sp_reportes_insertar(1, 1, 2, 'Necesario aplicar mantención preventiva en Plaza Central', 'admin'); 
CALL sp_reportes_insertar(2, 2, 1, 'Corte de energía en Plaza Norte', 'admin'); 

-- 10. juntas_vecinos 
CALL sp_juntas_vecinos_insertar('Villa Los Robles', 1, 'admin'); 
CALL sp_juntas_vecinos_insertar('Nueva Esperanza', 2, 'admin'); 

SELECT '*** Pruebas de Listado ***';
CALL sp_tipo_usuarios_listar_activos();
CALL sp_comunas_listar_activos();
CALL sp_plazas_listar_activos();
CALL sp_estado_camara_listar_activos();
CALL sp_camaras_listar_activas();
CALL sp_personas_listar_activas();
CALL sp_usuarios_listar_activos();
CALL sp_tipo_reporte_listar_activos();
CALL sp_reportes_listar_activos();
CALL sp_juntas_vecinos_listar_activas();