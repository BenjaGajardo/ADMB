CREATE DATABASE IF NOT EXISTS viajes_db;
USE viajes_db;

CREATE TABLE personas (
    RUT INT PRIMARY KEY,
    nombre VARCHAR(45),
    apellido VARCHAR(45),
    fecha_de_nacimiento DATE,
    create_datetime TIMESTAMP 
);

CREATE TABLE tipo_usuarios (
    idtipo_usuarios INT PRIMARY KEY AUTO_INCREMENT,
    nombre_tipo_usuarios VARCHAR(45),
    descripcion_tipo_usuarios VARCHAR(255),
    create_datetime TIMESTAMP
);

CREATE TABLE usuarios (
    id_usuarios INT PRIMARY KEY AUTO_INCREMENT,
    nombre_usuario VARCHAR(45),
    apellido_usuario VARCHAR(45),
    contraseña VARCHAR(45),
    email VARCHAR(45),
    create_datetime TIMESTAMP,
    tipo_usuarios_idtipo_usuarios INT,
    personas_RUT INT,
    FOREIGN KEY (tipo_usuarios_idtipo_usuarios) REFERENCES tipo_usuarios(idtipo_usuarios) ON DELETE CASCADE,
    FOREIGN KEY (personas_RUT) REFERENCES personas(RUT) ON DELETE CASCADE
);

CREATE TABLE aeropuertos (
    idaeropuertos INT PRIMARY KEY AUTO_INCREMENT,
    nombre_aeropuerto VARCHAR(100),
    ubicacion VARCHAR(100),
    created TIMESTAMP 
);

CREATE TABLE registro_de_viajes (
    idregistro_de_viajes INT PRIMARY KEY AUTO_INCREMENT,
    visa VARCHAR(45),
    fecha_de_viaje_inicio DATETIME,
    fecha_de_viaje_final DATETIME,
    create_datetime TIMESTAMP
);

CREATE TABLE viajes (
    idviajes INT PRIMARY KEY AUTO_INCREMENT,
    numero_de_asiento INT,
    numero_de_ticket VARCHAR(45),
    descripcion_del_viaje VARCHAR(255),
    pais VARCHAR(45),
    costo INT,
    create_datetime TIMESTAMP,
    idregistro_de_viajes INT,
    origen INT,
    destino INT,
    FOREIGN KEY (idregistro_de_viajes) REFERENCES registro_de_viajes(idregistro_de_viajes) ON DELETE CASCADE,
    FOREIGN KEY (origen) REFERENCES aeropuertos(idaeropuertos) ON DELETE CASCADE,
    FOREIGN KEY (destino) REFERENCES aeropuertos(idaeropuertos) ON DELETE CASCADE
);

CREATE TABLE pasaje_de_viaje (
    idpasaje_de_viaje INT PRIMARY KEY AUTO_INCREMENT,
    nombre_pasaje_de_viaje VARCHAR(45),
    descripcion_pasaje_de_viaje VARCHAR(255),
    create_datetime TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    idviajes INT,
    FOREIGN KEY (idviajes) REFERENCES viajes(idviajes) ON DELETE CASCADE
);


