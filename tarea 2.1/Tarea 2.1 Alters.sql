use sistema_ventas;

ALTER TABLE Productos
MODIFY COLUMN precio_producto FLOAT NOT NULL;

ALTER TABLE tipo_usuario
ADD descripcion_tipo VARCHAR(200) NOT NULL AFTER nombre_tipo;

ALTER TABLE tipo_usuario
MODIFY COLUMN descripcion_tipo VARCHAR(200) NOT NULL;


ALTER TABLE usuarios 
ADD contraseña VARCHAR(45) NOT NULL AFTER nombre_tipo;

ALTER TABLE usuarios
MODIFY COLUMN correo VARCHAR(100) NOT NULL;

ALTER TABLE usuarios
MODIFY COLUMN tipo_usuario_id INT NOT NULL AFTER deleted;

ALTER TABLE ventas 
MODIFY COLUMN create_at DATETIME AFTER fecha;

ALTER TABLE Detalle_ventas
ADD CONSTRAINT fk_venta PRIMARY KEY (venta_id);

ALTER TABLE Detalle_ventas
MODIFY COLUMN precio_unitario FLOAT NOT NULL;

ALTER TABLE Productos
MODIFY COLUMN stock INT;

ALTER TABLE detalle_ventas
ADD id_producto INT NOT NULL AFTER producto_id;

ALTER TABLE usuarios
MODIFY COLUMN nombre_producto VARCHAR(100) NOT NULL;
