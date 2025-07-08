-- Creación de la base de datos
CREATE DATABASE tarea_base_de_datos;
USE tarea_base_de_datos;

-- Tabla: tipo_usuarios
CREATE TABLE tipo_usuarios (
    id_tipo INT AUTO_INCREMENT NOT NULL PRIMARY KEY, 
    nombre_tipo VARCHAR(50) NOT NULL CHECK (CHAR_LENGTH(nombre_tipo) >= 3), -- Valida que el nombre del tipo tenga al menos 3 caracteres.
    descripcion_tipo VARCHAR(200) NOT NULL CHECK (descripcion_tipo IN (
    'Acceso completo al sistema',
    'Usuario con acceso restringido',
    'Puede revisar y aprobar contenido' 
)), -- Esto asegura que solo se ingresen roles predefinidos, evitando errores de escritura como "admin", "acceso total", etc.
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, 
	created_by INT,
	updated_by INT,
	deleted BOOLEAN DEFAULT FALSE
);

-- Tabla: usuarios (se añade campo created_at con valor por defecto)
CREATE TABLE usuarios (
    id_usuario INT AUTO_INCREMENT NOT NULL PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE CHECK (CHAR_LENGTH(username) >= 3 AND username REGEXP '^[A-Za-z0-9]+$'), -- Requiere que el nombre de usuario tenga al menos 3 caracteres.
    contraseña VARCHAR(200) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE CHECK (email LIKE '%@%.%'), -- Valida que el correo electrónico tenga una estructura mínima correcta:
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, 
	created_by INT,
	updated_by INT,
	deleted BOOLEAN DEFAULT FALSE,
    id_tipo_usuario INT,
    CONSTRAINT fk_usuarios_tipo_usuarios FOREIGN KEY (id_tipo_usuario) REFERENCES tipo_usuarios(id_tipo)
);

-- Tabla: ciudad 
CREATE TABLE ciudad (
    id_ciudad INT AUTO_INCREMENT NOT NULL PRIMARY KEY,
    nombre_ciudad VARCHAR(100) NOT NULL CHECK (length(nombre_ciudad) >= 4), -- Obliga a que el nombre de la ciudad tenga al menos 4 caracteres.
    region VARCHAR(100),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
	updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, 
	created_by INT,
	updated_by INT,
	deleted BOOLEAN DEFAULT FALSE 
);

-- Tabla: personas (relacionada con usuarios y ciudad)
CREATE TABLE personas (
    rut VARCHAR(13) NOT NULL UNIQUE,
    nombre_completo VARCHAR(100) NOT NULL,
    fecha_nac DATE CHECK (fecha_nac >= '1920-01-01'), -- Valida que la fecha de nacimiento no sea anterior al año 1920.
    id_tipo INT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
	updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, 
	created_by INT,
	updated_by INT,
	deleted BOOLEAN DEFAULT FALSE ,
    id_usuario INT,
    id_ciudad INT,
    CONSTRAINT fk_personas_usuarios FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario),
    CONSTRAINT fk_personas_ciudad FOREIGN KEY (id_ciudad) REFERENCES ciudad(id_ciudad)
);