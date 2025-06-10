Create database tarea;
use tarea;


CREATE TABLE tipo_usuarios (
    id_tipo INT PRIMARY KEY AUTO_INCREMENT,
    descripcion VARCHAR(50) NOT NULL CHECK (descripcion IN ('Estudiante', 'Profesor', 'Administrador')),
    nivel_acceso TINYINT CHECK (nivel_acceso BETWEEN 1 AND 3)
);


CREATE TABLE usuarios (
    id_usuario INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL CHECK (CHAR_LENGTH(nombre) >= 3 AND nombre REGEXP '^[A-Za-z ]+$'),
    email VARCHAR(100) NOT NULL UNIQUE CHECK (email LIKE '%@%.%'),
    fecha_registro DATE DEFAULT (CURRENT_DATE),
    activo BOOLEAN DEFAULT TRUE,
    edad TINYINT CHECK (edad BETWEEN 13 AND 100),
    id_tipo INT,
    FOREIGN KEY (id_tipo) REFERENCES tipo_usuarios(id_tipo)
);

CREATE TABLE cursos (
    id_curso INT PRIMARY KEY AUTO_INCREMENT,
    titulo VARCHAR(200) NOT NULL CHECK (CHAR_LENGTH(titulo) BETWEEN 5 AND 200),
    duracion_horas DECIMAL(4,2) CHECK (duracion_horas > 0 AND duracion_horas <= 100),
    nivel VARCHAR(20) CHECK (nivel IN ('Principiante', 'Intermedio', 'Avanzado')),
    precio DECIMAL(10,2) CHECK (precio >= 0),
    fecha_publicacion DATE CHECK (fecha_publicacion >= '2020-01-01'),
    CHECK (
        (nivel = 'Principiante' AND precio <= 50) OR
        (nivel IN ('Intermedio', 'Avanzado') AND precio <= 200)
    )
);




