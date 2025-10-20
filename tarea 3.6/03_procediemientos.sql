USE seguridad_plazas;

-- ==========================================================
-- PROCEDIMIENTOS ALMACENADOS: TABLA tipo_usuarios
-- ==========================================================

-- ----------------------------------------------------------
-- Procedimiento: sp_tipo_usuarios_insertar
-- Descripción: Inserta un nuevo tipo de usuario en la tabla.
-- ----------------------------------------------------------
DELIMITER //
CREATE PROCEDURE sp_tipo_usuarios_insertar(
  IN p_nombre VARCHAR(50),
  IN p_descripcion VARCHAR(200),
  IN p_created_by VARCHAR(50)
)
BEGIN
  INSERT INTO tipo_usuarios (nombre, descripcion, created_by, deleted)
  VALUES (p_nombre, p_descripcion, p_created_by, 0);
END//
DELIMITER ;

-- ----------------------------------------------------------
-- Procedimiento: sp_tipo_usuarios_listar_activos
-- Descripción: Muestra todos los tipos de usuario activos.
-- ----------------------------------------------------------
DELIMITER //
CREATE PROCEDURE sp_tipo_usuarios_listar_activos()
BEGIN
  SELECT id_tipo_usuario, nombre, descripcion, created_by, created_at
  FROM tipo_usuarios
  WHERE deleted = 0
  ORDER BY nombre;
END//
DELIMITER ;

-- ----------------------------------------------------------
-- Procedimiento: sp_tipo_usuarios_borrado_logico
-- Descripción: Marca un tipo de usuario como eliminado (deleted=1).
-- ----------------------------------------------------------
DELIMITER //
CREATE PROCEDURE sp_tipo_usuarios_borrado_logico(
  IN p_id INT
)
BEGIN
  UPDATE tipo_usuarios
  SET deleted = 1
  WHERE id_tipo_usuario = p_id;
END//
DELIMITER ;

-- ----------------------------------------------------------
-- Procedimiento: sp_tipo_usuarios_listar_todo
-- Descripción: Lista todos los tipos de usuario (activos e inactivos).
-- ----------------------------------------------------------
DELIMITER //
CREATE PROCEDURE sp_tipo_usuarios_listar_todo()
BEGIN
  SELECT * FROM tipo_usuarios
  ORDER BY nombre;
END//
DELIMITER ;



-- ==========================================================
-- PROCEDIMIENTOS ALMACENADOS: TABLA comunas
-- ==========================================================

-- ----------------------------------------------------------
-- Procedimiento: sp_comunas_insertar
-- Descripción: Inserta una nueva comuna.
-- ----------------------------------------------------------
DELIMITER //
CREATE PROCEDURE sp_comunas_insertar(
  IN p_nombre VARCHAR(100),
  IN p_created_by VARCHAR(50)
)
BEGIN
  INSERT INTO comunas (nombre, created_by, deleted)
  VALUES (p_nombre, p_created_by, 0);
END//
DELIMITER ;

-- ----------------------------------------------------------
-- Procedimiento: sp_comunas_listar_activos
-- Descripción: Lista todas las comunas activas.
-- ----------------------------------------------------------
DELIMITER //
CREATE PROCEDURE sp_comunas_listar_activos()
BEGIN
  SELECT id_comuna, nombre, created_by, created_at
  FROM comunas
  WHERE deleted = 0
  ORDER BY nombre;
END//
DELIMITER ;

-- ----------------------------------------------------------
-- Procedimiento: sp_comunas_borrado_logico
-- Descripción: Marca una comuna como eliminada (deleted=1).
-- ----------------------------------------------------------
DELIMITER //
CREATE PROCEDURE sp_comunas_borrado_logico(
  IN p_id INT
)
BEGIN
  UPDATE comunas
  SET deleted = 1
  WHERE id_comuna = p_id;
END//
DELIMITER ;

-- ----------------------------------------------------------
-- Procedimiento: sp_comunas_listar_todo
-- Descripción: Lista todas las comunas (activos e inactivos).
-- ----------------------------------------------------------
DELIMITER //
CREATE PROCEDURE sp_comunas_listar_todo()
BEGIN
  SELECT * FROM comunas
  ORDER BY nombre;
END//
DELIMITER ;



-- ==========================================================
-- PROCEDIMIENTOS ALMACENADOS: TABLA plazas
-- ==========================================================

-- ----------------------------------------------------------
-- Procedimiento: sp_plazas_insertar
-- Descripción: Inserta una nueva plaza asociada a una comuna.
-- ----------------------------------------------------------
DELIMITER //
CREATE PROCEDURE sp_plazas_insertar(
  IN p_nombre VARCHAR(100),
  IN p_direccion VARCHAR(150),
  IN p_id_comuna INT,
  IN p_created_by VARCHAR(50)
)
BEGIN
  INSERT INTO plazas (nombre, direccion, id_comuna, created_by, deleted)
  VALUES (p_nombre, p_direccion, p_id_comuna, p_created_by, 0);
END//
DELIMITER ;

-- ----------------------------------------------------------
-- Procedimiento: sp_plazas_listar_activos
-- Descripción: Muestra todas las plazas activas con su comuna.
-- ----------------------------------------------------------
DELIMITER //
CREATE PROCEDURE sp_plazas_listar_activos()
BEGIN
  SELECT p.*, c.nombre AS nombre_comuna
  FROM plazas p
  LEFT JOIN comunas c ON p.id_comuna = c.id_comuna
  WHERE p.deleted = 0;
END//
DELIMITER ;

-- ----------------------------------------------------------
-- Procedimiento: sp_plazas_borrado_logico
-- Descripción: Marca una plaza como eliminada (deleted=1).
-- ----------------------------------------------------------
DELIMITER //
CREATE PROCEDURE sp_plazas_borrado_logico(
  IN p_id INT
)
BEGIN
  UPDATE plazas
  SET deleted = 1
  WHERE id_plaza = p_id;
END//
DELIMITER ;

-- ----------------------------------------------------------
-- Procedimiento: sp_plazas_listar_todo
-- Descripción: Lista todas las plazas registradas.
-- ----------------------------------------------------------
DELIMITER //
CREATE PROCEDURE sp_plazas_listar_todo()
BEGIN
  SELECT * FROM plazas
  ORDER BY nombre;
END//
DELIMITER ;



-- ==========================================================
-- PROCEDIMIENTOS ALMACENADOS: TABLA estado_camara
-- ==========================================================

-- ----------------------------------------------------------
-- Procedimiento: sp_estado_camara_insertar
-- Descripción: Inserta un nuevo estado de cámara.
-- ----------------------------------------------------------
DELIMITER //
CREATE PROCEDURE sp_estado_camara_insertar(
  IN p_nombre VARCHAR(50),
  IN p_descripcion VARCHAR(255),
  IN p_created_by VARCHAR(50)
)
BEGIN
  INSERT INTO estado_camara (nombre, descripcion, created_by, deleted)
  VALUES (p_nombre, p_descripcion, p_created_by, 0);
END//
DELIMITER ;

-- ----------------------------------------------------------
-- Procedimiento: sp_estado_camara_listar_activos
-- Descripción: Lista los estados de cámara activos.
-- ----------------------------------------------------------
DELIMITER //
CREATE PROCEDURE sp_estado_camara_listar_activos()
BEGIN
  SELECT id_estado_camara, nombre, descripcion, created_by, created_at
  FROM estado_camara
  WHERE deleted = 0
  ORDER BY nombre;
END//
DELIMITER ;

-- ----------------------------------------------------------
-- Procedimiento: sp_estado_camara_borrado_logico
-- Descripción: Marca un estado de cámara como eliminado.
-- ----------------------------------------------------------
DELIMITER //
CREATE PROCEDURE sp_estado_camara_borrado_logico(
  IN p_id INT
)
BEGIN
  UPDATE estado_camara
  SET deleted = 1
  WHERE id_estado_camara = p_id;
END//
DELIMITER ;

-- ----------------------------------------------------------
-- Procedimiento: sp_estado_camara_listar_todo
-- Descripción: Lista todos los estados de cámara.
-- ----------------------------------------------------------
DELIMITER //
CREATE PROCEDURE sp_estado_camara_listar_todo()
BEGIN
  SELECT * FROM estado_camara
  ORDER BY nombre;
END//
DELIMITER ;




-- ==========================================================
-- PROCEDIMIENTOS ALMACENADOS: TABLA camaras
-- ==========================================================

-- ----------------------------------------------------------
-- Procedimiento: sp_camaras_insertar
-- Descripción: Inserta una nueva cámara en la base de datos.
-- ----------------------------------------------------------
DELIMITER //
CREATE PROCEDURE sp_camaras_insertar(
  IN p_modelo VARCHAR(100),
  IN p_ubicacion VARCHAR(150),
  IN p_estado INT,
  IN p_id_plaza INT,
  IN p_created_by VARCHAR(50)
)
BEGIN
  INSERT INTO camaras (modelo, ubicacion, id_estado_camara, id_plaza, created_by, deleted)
  VALUES (p_modelo, p_ubicacion, p_estado, p_id_plaza, p_created_by, 0);
END//
DELIMITER ;

-- ----------------------------------------------------------
-- Procedimiento: sp_camaras_listar_activas
-- Descripción: Muestra todas las cámaras activas con su estado y plaza.
-- ----------------------------------------------------------
DELIMITER //
CREATE PROCEDURE sp_camaras_listar_activas()
BEGIN
  SELECT c.id_camara, c.modelo, c.ubicacion,
         e.nombre AS estado, p.nombre AS plaza
  FROM camaras c
  LEFT JOIN estado_camara e ON c.id_estado_camara = e.id_estado_camara
  LEFT JOIN plazas p ON c.id_plaza = p.id_plaza
  WHERE c.deleted = 0;
END//
DELIMITER ;

-- ----------------------------------------------------------
-- Procedimiento: sp_camaras_borrado_logico
-- Descripción: Marca una cámara como eliminada (deleted=1).
-- ----------------------------------------------------------
DELIMITER //
CREATE PROCEDURE sp_camaras_borrado_logico(
  IN p_id INT
)
BEGIN
  UPDATE camaras
  SET deleted = 1
  WHERE id_camara = p_id;
END//
DELIMITER ;

-- ----------------------------------------------------------
-- Procedimiento: sp_camaras_listar_todo
-- Descripción: Lista todas las cámaras registradas (activas e inactivas).
-- ----------------------------------------------------------
DELIMITER //
CREATE PROCEDURE sp_camaras_listar_todo()
BEGIN
  SELECT * FROM camaras
  ORDER BY modelo;
END//
DELIMITER ;



-- ==========================================================
-- PROCEDIMIENTOS ALMACENADOS: TABLA personas
-- ==========================================================

-- ----------------------------------------------------------
-- Procedimiento: sp_personas_insertar
-- Descripción: Inserta una nueva persona con su RUT y datos personales.
-- ----------------------------------------------------------
DELIMITER //
CREATE PROCEDURE sp_personas_insertar(
  IN p_rut VARCHAR(12),
  IN p_nombre VARCHAR(100),
  IN p_apellido VARCHAR(100),
  IN p_direccion VARCHAR(150),
  IN p_telefono VARCHAR(15),
  IN p_id_comuna INT,
  IN p_created_by VARCHAR(50)
)
BEGIN
  INSERT INTO personas (rut, nombre, apellido, direccion, telefono, id_comuna, created_by, deleted)
  VALUES (p_rut, p_nombre, p_apellido, p_direccion, p_telefono, p_id_comuna, p_created_by, 0);
END//
DELIMITER ;

-- ----------------------------------------------------------
-- Procedimiento: sp_personas_listar_activas
-- Descripción: Lista todas las personas activas con su comuna.
-- ----------------------------------------------------------
DELIMITER //
CREATE PROCEDURE sp_personas_listar_activas()
BEGIN
  SELECT p.*, c.nombre AS comuna
  FROM personas p
  LEFT JOIN comunas c ON p.id_comuna = c.id_comuna
  WHERE p.deleted = 0;
END//
DELIMITER ;

-- ----------------------------------------------------------
-- Procedimiento: sp_personas_borrado_logico
-- Descripción: Marca una persona como eliminada (deleted=1).
-- ----------------------------------------------------------
DELIMITER //
CREATE PROCEDURE sp_personas_borrado_logico(
  IN p_id INT
)
BEGIN
  UPDATE personas
  SET deleted = 1
  WHERE id_persona = p_id;
END//
DELIMITER ;

-- ----------------------------------------------------------
-- Procedimiento: sp_personas_listar_todo
-- Descripción: Lista todas las personas registradas.
-- ----------------------------------------------------------
DELIMITER //
CREATE PROCEDURE sp_personas_listar_todo()
BEGIN
  SELECT * FROM personas
  ORDER BY nombre;
END//
DELIMITER ;



-- ==========================================================
-- PROCEDIMIENTOS ALMACENADOS: TABLA reportes
-- ==========================================================

-- ----------------------------------------------------------
-- Procedimiento: sp_reportes_insertar
-- Descripción: Inserta un nuevo reporte vinculado a cámara, usuario y tipo.
-- ----------------------------------------------------------
DELIMITER //
CREATE PROCEDURE sp_reportes_insertar(
  IN p_id_camara INT,
  IN p_id_usuario INT,
  IN p_id_tipo_reporte INT,
  IN p_descripcion TEXT,
  IN p_created_by VARCHAR(50)
)
BEGIN
  INSERT INTO reportes (id_camara, id_usuario, id_tipo_reporte, descripcion, created_by, deleted)
  VALUES (p_id_camara, p_id_usuario, p_id_tipo_reporte, p_descripcion, p_created_by, 0);
END//
DELIMITER ;

-- ----------------------------------------------------------
-- Procedimiento: sp_reportes_listar_activos
-- Descripción: Muestra todos los reportes activos con sus relaciones.
-- ----------------------------------------------------------
DELIMITER //
CREATE PROCEDURE sp_reportes_listar_activos()
BEGIN
  SELECT r.id_reporte, r.descripcion, r.created_at,
         c.modelo AS camara, u.usuario AS usuario,
         tr.nombre AS tipo_reporte
  FROM reportes r
  LEFT JOIN camaras c ON r.id_camara = c.id_camara
  LEFT JOIN usuarios u ON r.id_usuario = u.id_usuario
  LEFT JOIN tipo_reporte tr ON r.id_tipo_reporte = tr.id_tipo_reporte
  WHERE r.deleted = 0;
END//
DELIMITER ;

-- ----------------------------------------------------------
-- Procedimiento: sp_reportes_borrado_logico
-- Descripción: Marca un reporte como eliminado (deleted=1).
-- ----------------------------------------------------------
DELIMITER //
CREATE PROCEDURE sp_reportes_borrado_logico(
  IN p_id INT
)
BEGIN
  UPDATE reportes
  SET deleted = 1
  WHERE id_reporte = p_id;
END//
DELIMITER ;

-- ----------------------------------------------------------
-- Procedimiento: sp_reportes_listar_todo
-- Descripción: Lista todos los reportes registrados (activos e inactivos).
-- ----------------------------------------------------------
DELIMITER //
CREATE PROCEDURE sp_reportes_listar_todo()
BEGIN
  SELECT * FROM reportes
  ORDER BY id_reporte DESC;
END//
DELIMITER ;



-- ==========================================================
-- PROCEDIMIENTOS ALMACENADOS: TABLA juntas_vecinos
-- ==========================================================

-- ----------------------------------------------------------
-- Procedimiento: sp_juntas_vecinos_insertar
-- Descripción: Inserta una nueva junta de vecinos asociada a una comuna.
-- ----------------------------------------------------------
DELIMITER //
CREATE PROCEDURE sp_juntas_vecinos_insertar(
  IN p_nombre VARCHAR(100),
  IN p_direccion VARCHAR(150),
  IN p_id_comuna INT,
  IN p_created_by VARCHAR(50)
)
BEGIN
  INSERT INTO juntas_vecinos (nombre, direccion, id_comuna, created_by, deleted)
  VALUES (p_nombre, p_direccion, p_id_comuna, p_created_by, 0);
END//
DELIMITER ;

-- ----------------------------------------------------------
-- Procedimiento: sp_juntas_vecinos_listar_activas
-- Descripción: Lista las juntas de vecinos activas con su comuna.
-- ----------------------------------------------------------
DELIMITER //
CREATE PROCEDURE sp_juntas_vecinos_listar_activas()
BEGIN
  SELECT j.id_junta, j.nombre, j.direccion, c.nombre AS comuna
  FROM juntas_vecinos j
  LEFT JOIN comunas c ON j.id_comuna = c.id_comuna
  WHERE j.deleted = 0;
END//
DELIMITER ;

-- ----------------------------------------------------------
-- Procedimiento: sp_juntas_vecinos_borrado_logico
-- Descripción: Marca una junta de vecinos como eliminada (deleted=1).
-- ----------------------------------------------------------
DELIMITER //
CREATE PROCEDURE sp_juntas_vecinos_borrado_logico(
  IN p_id INT
)
BEGIN
  UPDATE juntas_vecinos
  SET deleted = 1
  WHERE id_junta = p_id;
END//
DELIMITER ;

-- ----------------------------------------------------------
-- Procedimiento: sp_juntas_vecinos_listar_todo
-- Descripción: Lista todas las juntas registradas.
-- ----------------------------------------------------------
DELIMITER //
CREATE PROCEDURE sp_juntas_vecinos_listar_todo()
BEGIN
  SELECT * FROM juntas_vecinos
  ORDER BY nombre;
END//
DELIMITER ;


-- ==========================================================
-- PROCEDIMIENTOS ALMACENADOS: TABLA usuarios
-- ==========================================================

-- ----------------------------------------------------------
-- Procedimiento: sp_usuarios_insertar
-- Descripción: Inserta un nuevo usuario con referencia a persona y tipo.
-- ----------------------------------------------------------
DELIMITER //
CREATE PROCEDURE sp_usuarios_insertar(
  IN p_id_persona INT,
  IN p_usuario VARCHAR(50),
  IN p_contrasena VARCHAR(100),
  IN p_id_tipo_usuario INT,
  IN p_created_by VARCHAR(50)
)
BEGIN
  INSERT INTO usuarios (id_persona, usuario, contrasena, id_tipo_usuario, created_by, deleted)
  VALUES (p_id_persona, p_usuario, p_contrasena, p_id_tipo_usuario, p_created_by, 0);
END//
DELIMITER ;

-- ----------------------------------------------------------
-- Procedimiento: sp_usuarios_listar_activos
-- Descripción: Lista los usuarios activos con datos de persona y tipo.
-- ----------------------------------------------------------
DELIMITER //
CREATE PROCEDURE sp_usuarios_listar_activos()
BEGIN
  SELECT u.id_usuario, u.usuario, tu.nombre AS tipo_usuario,
         p.nombre, p.apellido
  FROM usuarios u
  LEFT JOIN tipo_usuarios tu ON u.id_tipo_usuario = tu.id_tipo_usuario
  LEFT JOIN personas p ON u.id_persona = p.id_persona
  WHERE u.deleted = 0;
END//
DELIMITER ;

-- ----------------------------------------------------------
-- Procedimiento: sp_usuarios_borrado_logico
-- Descripción: Marca un usuario como eliminado (deleted=1).
-- ----------------------------------------------------------
DELIMITER //
CREATE PROCEDURE sp_usuarios_borrado_logico(
  IN p_id INT
)
BEGIN
  UPDATE usuarios
  SET deleted = 1
  WHERE id_usuario = p_id;
END//
DELIMITER ;

-- ----------------------------------------------------------
-- Procedimiento: sp_usuarios_listar_todo
-- Descripción: Lista todos los usuarios registrados.
-- ----------------------------------------------------------
DELIMITER //
CREATE PROCEDURE sp_usuarios_listar_todo()
BEGIN
  SELECT * FROM usuarios
  ORDER BY usuario;
END//
DELIMITER ;



-- ==========================================================
-- PROCEDIMIENTOS ALMACENADOS: TABLA tipo_reporte
-- ==========================================================

-- ----------------------------------------------------------
-- Procedimiento: sp_tipo_reporte_insertar
-- Descripción: Inserta un nuevo tipo de reporte.
-- ----------------------------------------------------------
DELIMITER //
CREATE PROCEDURE sp_tipo_reporte_insertar(
  IN p_nombre VARCHAR(50),
  IN p_descripcion VARCHAR(200),
  IN p_created_by VARCHAR(50)
)
BEGIN
  INSERT INTO tipo_reporte (nombre, descripcion, created_by, deleted)
  VALUES (p_nombre, p_descripcion, p_created_by, 0);
END//
DELIMITER ;

-- ----------------------------------------------------------
-- Procedimiento: sp_tipo_reporte_listar_activos
-- Descripción: Lista los tipos de reporte activos.
-- ----------------------------------------------------------
DELIMITER //
CREATE PROCEDURE sp_tipo_reporte_listar_activos()
BEGIN
  SELECT id_tipo_reporte, nombre, descripcion, created_by, created_at
  FROM tipo_reporte
  WHERE deleted = 0;
END//
DELIMITER ;

-- ----------------------------------------------------------
-- Procedimiento: sp_tipo_reporte_borrado_logico
-- Descripción: Marca un tipo de reporte como eliminado.
-- ----------------------------------------------------------
DELIMITER //
CREATE PROCEDURE sp_tipo_reporte_borrado_logico(
  IN p_id INT
)
BEGIN
  UPDATE tipo_reporte
  SET deleted = 1
  WHERE id_tipo_reporte = p_id;
END//
DELIMITER ;

-- ----------------------------------------------------------
-- Procedimiento: sp_tipo_reporte_listar_todo
-- Descripción: Lista todos los tipos de reporte.
-- ----------------------------------------------------------
DELIMITER //
CREATE PROCEDURE sp_tipo_reporte_listar_todo()
BEGIN
  SELECT * FROM tipo_reporte
  ORDER BY nombre;
END//
DELIMITER ;


-- ==========================================================
-- Prueba de PROCEDIMIENTOS: tipo_usuarios
-- ==========================================================

-- Insertar registros
CALL sp_tipo_usuarios_insertar('Administrador', 'Acceso completo al sistema', 'admin');
CALL sp_tipo_usuarios_insertar('Operador', 'Gestiona cámaras y reportes', 'admin');
CALL sp_tipo_usuarios_insertar('Invitado', 'Solo puede visualizar información', 'admin');

-- Listar activos
CALL sp_tipo_usuarios_listar_activos();

-- Borrado lógico (ejemplo: eliminar tipo con id=2)
CALL sp_tipo_usuarios_borrado_logico(2);

-- Listar todos (activos e inactivos)
CALL sp_tipo_usuarios_listar_todo();


-- ==========================================================
-- Prueba de PROCEDIMIENTOS: camaras
-- ==========================================================

-- Insertar registros
CALL sp_camaras_insertar('Hikvision DS-2CD', 'Entrada principal', 1, 1, 'admin');
CALL sp_camaras_insertar('Dahua IPC-HFW', 'Zona norte', 1, 1, 'admin');
CALL sp_camaras_insertar('TP-Link Tapo', 'Estacionamiento', 2, 2, 'admin');

-- Listar cámaras activas
CALL sp_camaras_listar_activas();

-- Borrado lógico (ejemplo: cámara id=3)
CALL sp_camaras_borrado_logico(3);

-- Listar todas (activas e inactivas)
CALL sp_camaras_listar_todo();


-- ==========================================================
-- Prueba de PROCEDIMIENTOS: juntas_vecinos
-- ==========================================================

-- Insertar registros
CALL sp_juntas_vecinos_insertar('Villa Los Robles', 'Calle 12 Oriente 124', 1, 'admin');
CALL sp_juntas_vecinos_insertar('Nueva Esperanza', 'Av. Central 520', 2, 'admin');
CALL sp_juntas_vecinos_insertar('El Bosque', 'Camino El Árbol 87', 1, 'admin');

-- Listar activas
CALL sp_juntas_vecinos_listar_activas();

-- Borrado lógico (ejemplo: junta id=1)
CALL sp_juntas_vecinos_borrado_logico(1);

-- Listar todas
CALL sp_juntas_vecinos_listar_todo();


-- ==========================================================
-- Prueba de PROCEDIMIENTOS: personas
-- ==========================================================

-- Insertar registros
CALL sp_personas_insertar('12.345.678-9', 'Juan', 'Pérez', 'Av. Libertad 123', '912345678', 1, 'admin');
CALL sp_personas_insertar('9.876.543-2', 'María', 'López', 'Calle Falsa 456', '987654321', 2, 'admin');
CALL sp_personas_insertar('11.222.333-4', 'Carlos', 'Soto', 'Los Robles 89', '934567890', 1, 'admin');

-- Listar activas
CALL sp_personas_listar_activas();

-- Borrado lógico (ejemplo: persona id=2)
CALL sp_personas_borrado_logico(2);

-- Listar todas
CALL sp_personas_listar_todo();


-- ==========================================================
-- PROCEDIMIENTOS: usuarios
-- ==========================================================

-- Insertar registros
-- (debes tener creadas personas y tipos de usuario para que los IDs existan)
CALL sp_usuarios_insertar(1, 'juanp', '1234', 1, 'admin');
CALL sp_usuarios_insertar(2, 'marial', 'abcd', 3, 'admin');
CALL sp_usuarios_insertar(3, 'carloss', '4321', 2, 'admin');

-- Listar usuarios activos
CALL sp_usuarios_listar_activos();

-- Borrado lógico (ejemplo: usuario id=3)
CALL sp_usuarios_borrado_logico(3);

-- Listar todos
CALL sp_usuarios_listar_todo();


-- ==========================================================
-- PROCEDIMIENTOS: tipo_reporte
-- ==========================================================

-- Insertar registros
CALL sp_tipo_reporte_insertar('Falla técnica', 'Reporte por fallas eléctricas o de red', 'admin');
CALL sp_tipo_reporte_insertar('Mantenimiento', 'Mantenimiento preventivo o correctivo', 'admin');
CALL sp_tipo_reporte_insertar('Vandalismo', 'Daños intencionales detectados', 'admin');

-- Listar tipos activos
CALL sp_tipo_reporte_listar_activos();

-- Borrado lógico (ejemplo: tipo id=1)
CALL sp_tipo_reporte_borrado_logico(1);

-- Listar todos
CALL sp_tipo_reporte_listar_todo();


-- ==========================================================
-- PROCEDIMIENTOS: reportes
-- ==========================================================

-- Insertar registros
-- (asegúrate de tener IDs válidos de cámara, usuario y tipo de reporte)
CALL sp_reportes_insertar(1, 1, 2, 'Cámara desconectada desde las 22:00', 'admin');
CALL sp_reportes_insertar(2, 2, 3, 'Lente roto por impacto', 'admin');
CALL sp_reportes_insertar(3, 1, 2, 'Baja calidad de imagen por humedad', 'admin');

-- Listar reportes activos
CALL sp_reportes_listar_activos();

-- Borrado lógico (ejemplo: reporte id=2)
CALL sp_reportes_borrado_logico(2);

-- Listar todos
CALL sp_reportes_listar_todo();


-- ==========================================================
-- TABLA: plazas
-- ==========================================================

-- Insertar registros
CALL sp_plazas_insertar('Plaza Central', 'Calle Falsa 123', 1, 'admin');
CALL sp_plazas_insertar('Plaza Norte', 'Av. Norte 456', 2, 'admin');
CALL sp_plazas_insertar('Plaza Sur', 'Calle Sur 789', 1, 'admin');

-- Listar activos
CALL sp_plazas_listar_activos();

-- Borrado lógico (ejemplo: id=3)
CALL sp_plazas_borrado_logico(3);

-- Listar todos
CALL sp_plazas_listar_todo();


-- ==========================================================
-- TABLA: estado_camara
-- ==========================================================

-- Insertar registros
CALL sp_estado_camara_insertar('ACTIVA', 'Cámara funcionando correctamente', 'admin');
CALL sp_estado_camara_insertar('INACTIVA', 'Cámara fuera de servicio', 'admin');
CALL sp_estado_camara_insertar('MANTENCIÓN', 'Cámara en mantenimiento', 'admin');

-- Listar activos
CALL sp_estado_camara_listar_activos();

-- Borrado lógico (ejemplo: id=3)
CALL sp_estado_camara_borrado_logico(3);

-- Listar todos
CALL sp_estado_camara_listar_todo();


-- ==========================================================
-- TABLA: comunas
-- ==========================================================

-- Insertar registros
CALL sp_comunas_insertar('Comuna Centro', 'admin');
CALL sp_comunas_insertar('Comuna Norte', 'admin');
CALL sp_comunas_insertar('Comuna Sur', 'admin');

-- Listar activos
CALL sp_comunas_listar_activos();

-- Borrado lógico (ejemplo: id=3)
CALL sp_comunas_borrado_logico(3);

-- Listar todos
CALL sp_comunas_listar_todo();
