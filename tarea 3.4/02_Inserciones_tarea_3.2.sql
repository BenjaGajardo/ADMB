-- Tipo de usuarios
INSERT INTO tipo_usuarios (nombre, descripcion, created_by) VALUES
('administrador', 'Usuario con todos los permisos', 'sistema'),
('supervisor', 'Supervisor de zona', 'sistema'),
('vecino', 'Vecino que reporta incidentes', 'sistema');

-- Comunas
INSERT INTO comunas (nombre, created_by) VALUES
('Comuna Centro', 'sistema'),
('Comuna Norte', 'sistema');

-- Plazas
INSERT INTO plazas (nombre, direccion, id_comuna, created_by) VALUES
('Plaza Central', 'Calle Falsa 123', 1, 'sistema'),
('Plaza Norte', 'Av. Norte 456', 2, 'sistema');

-- Estado de cámaras
INSERT INTO estado_camara (nombre, descripcion) VALUES
('ACTIVA', 'Cámara funcionando correctamente'),
('INACTIVA', 'Cámara fuera de servicio');

-- Cámaras
INSERT INTO camaras (ubicacion, id_estado_camara, id_plaza, created_by) VALUES
('Entrada Principal', 1, 1, 'sistema'),
('Sector Juegos', 1, 1, 'sistema');

-- Juntas de vecinos
INSERT INTO juntas_vecinos (nombre, id_comuna, created_by) VALUES
('Junta Centro', 1, 'sistema'),
('Junta Norte', 2, 'sistema');

-- Personas
INSERT INTO personas (rut, nombre, correo, telefono, direccion, id_comuna, created_by) VALUES
('12345678-9', 'Juan Perez', 'juan@mail.com', '912345678', 'Calle Falsa 123', 1, 'sistema'),
('98765432-1', 'Maria Lopez', 'maria@mail.com', '987654321', 'Av. Norte 456', 2, 'sistema');

-- Usuarios
INSERT INTO usuarios (id_persona, contrasena, id_tipo_usuario, created_by) VALUES
(1, '1234pass', 1, 'sistema'),
(2, 'abcdpass', 3, 'sistema');

-- Tipo de reporte
INSERT INTO tipo_reporte (nombre, descripcion, created_by) VALUES
('Sospechoso', 'Actividad sospechosa', 'sistema'),
('Accidente', 'Accidente en la plaza', 'sistema');

-- Reportes
INSERT INTO reportes (id_tipo_reporte, descripcion, fecha, hora, id_usuario, id_plaza, created_by) VALUES
(1, 'Persona sospechosa merodeando', '2025-10-07', '15:30:00', 2, 1, 'sistema'),
(2, 'Caída de bicicleta', '2025-10-07', '16:00:00', 2, 1, 'sistema');



-- Ver todos los registros
SELECT * FROM tipo_usuarios;
SELECT * FROM comunas;
SELECT * FROM plazas;
SELECT * FROM estado_camara;
SELECT * FROM camaras;
SELECT * FROM juntas_vecinos;
SELECT * FROM personas;
SELECT * FROM usuarios;
SELECT * FROM tipo_reporte;
SELECT * FROM reportes;


-- -----------------------------------------------------
-- Consultas de registros activos (deleted = 0)
-- -----------------------------------------------------
SELECT * FROM tipo_usuarios WHERE deleted = 0;
SELECT * FROM comunas WHERE deleted = 0;
SELECT * FROM plazas WHERE deleted = 0;
SELECT * FROM estado_camara WHERE deleted = 0;
SELECT * FROM camaras WHERE deleted = 0;
SELECT * FROM juntas_vecinos WHERE deleted = 0;
SELECT * FROM personas WHERE deleted = 0;
SELECT * FROM usuarios WHERE deleted = 0;
SELECT * FROM tipo_reporte WHERE deleted = 0;
SELECT * FROM reportes WHERE deleted = 0;


-- Personas con datos completos (nombre, correo y teléfono)
SELECT id_persona, nombre, correo, telefono
FROM personas
WHERE deleted = 0;

-- Validación de CHECKs de teléfono: mostrar teléfonos inválidos
SELECT nombre, telefono
FROM personas
WHERE deleted = 0 AND telefono NOT REGEXP '^[0-9]{8,15}$';

-- Validación de CHECKs de correo: mostrar correos inválidos
SELECT nombre, correo
FROM personas
WHERE deleted = 0 AND correo IS NOT NULL AND correo NOT REGEXP '^[^@]+@[^@]+\.[^@]+$';