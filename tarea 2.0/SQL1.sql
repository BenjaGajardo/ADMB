create database sistema_ventas;

use sistema_ventas;

CREATE TABLE tipo_usuario (
id_tipo_usuario INT AUTO_INCREMENT PRIMARY KEY,
nombre_tipo VARCHAR(50) NOT NULL,
created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
ON UPDATE CURRENT_TIMESTAMP, 
created_by INT,
updated_by INT,
deleted BOOLEAN DEFAULT FALSE 
);

CREATE TABLE usuarios (
id_usuario INT AUTO_INCREMENT PRIMARY KEY, 
nombre_tipo VARCHAR(100) NOT NULL, 
correo VARCHAR(100) UNIQUE, 
tipo_usuario_id INT,
created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
ON UPDATE CURRENT_TIMESTAMP, 
created_by INT,
updated_by INT,
deleted BOOLEAN DEFAULT FALSE
);

CREATE table Productos(
id_producto INT AUTO_INCREMENT PRIMARY KEY,
nombre_producto VARCHAR(50) NOT NULL,
precio_producto INT NOT NULL,
stock INT NOT NULL,
create_at DATETIME DEFAULT CURRENT_TIMESTAMP,
update_at DATETIME DEFAULT CURRENT_TIMESTAMP 
ON UPDATE CURRENT_TIMESTAMP,
create_by INT,
update_by INT,
deleted BOOLEAN DEFAULT FALSE
);

CREATE table Ventas(
id_venta INT AUTO_INCREMENT PRIMARY KEY,
usuario_id INT,
create_at DATETIME DEFAULT CURRENT_TIMESTAMP,
fecha DATE NOT NULL,
update_at DATETIME DEFAULT CURRENT_TIMESTAMP
ON UPDATE CURRENT_TIMESTAMP,
create_by INT,
update_by INT,
deleted BOOLEAN DEFAULT FALSE
);

CREATE table Detalle_ventas(
id_detalle_venta INT AUTO_INCREMENT PRIMARY KEY,
venta_id INT,
producto_id INT,
cantidad INT NOT NULL,
precio_unitario INT NOT NULL,
create_at DATETIME DEFAULT CURRENT_TIMESTAMP,
update_at DATETIME DEFAULT CURRENT_TIMESTAMP
ON UPDATE CURRENT_TIMESTAMP,
create_by INT,
update_by INT,
deleted BOOLEAN DEFAULT FALSE
);

ALTER TABLE usuarios
ADD CONSTRAINT fk_usuario_tipo
FOREIGN KEY (tipo_usuario_id) REFERENCES tipo_usuario(id_tipo_usuario);

ALTER TABLE Ventas
ADD CONSTRAINT fk_usuarios
FOREIGN KEY (usuario_id) REFERENCES usuarios(id_usuario);

ALTER TABLE Detalle_ventas
ADD CONSTRAINT fk_venta
FOREIGN KEY (venta_id) REFERENCES Ventas(id_venta);

ALTER TABLE Detalle_ventas
ADD CONSTRAINT fk_producto
FOREIGN KEY (producto_id) REFERENCES Productos(id_producto);



