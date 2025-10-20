-- MySQL Script con CHECKs, DEFAULT y auditoría
-- Versión: 1.1
-- =====================================================
-- Script Base de Datos: seguridad_plazas
-- Incluye auditoría, deleted lógico y restricciones CHECK
-- =====================================================

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

CREATE SCHEMA IF NOT EXISTS `seguridad_plazas` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE `seguridad_plazas`;

-- -----------------------------------------------------
-- Table `tipo_usuarios`
-- Define los diferentes tipos de usuarios del sistema.
-- Ej: administrador, supervisor, vecino.
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `tipo_usuarios` (
  `id_tipo_usuario` INT NOT NULL AUTO_INCREMENT,  -- ID único de tipo de usuario
  `nombre` VARCHAR(50) NOT NULL,  -- Nombre del tipo de usuario
  `descripcion` VARCHAR(200) NOT NULL,  -- Descripción del tipo
  `created_by` VARCHAR(50) NULL DEFAULT NULL,  -- Usuario que creó el registro
  `created_at` DATETIME NULL DEFAULT CURRENT_TIMESTAMP,  -- Fecha de creación
  `updated_by` VARCHAR(50) NULL DEFAULT NULL,  -- Usuario que modificó el registro
  `updated_at` DATETIME NULL DEFAULT NULL,  -- Fecha de última modificación
  `deleted` TINYINT(1) NOT NULL DEFAULT 0,  -- 0 = activo, 1 = eliminado lógicamente
  PRIMARY KEY (`id_tipo_usuario`),
  UNIQUE INDEX `nombre` (`nombre` ASC) VISIBLE,
  CHECK (CHAR_LENGTH(nombre) > 0),
  CHECK (CHAR_LENGTH(descripcion) > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- -----------------------------------------------------
-- Table `comunas`
-- Lista de comunas en que se ubican las plazas.
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `comunas` (
  `id_comuna` INT NOT NULL AUTO_INCREMENT,  -- ID único de comuna
  `nombre` VARCHAR(100) NOT NULL,  -- Nombre de la comuna
  `created_by` VARCHAR(50) NULL DEFAULT NULL,  
  `created_at` DATETIME NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_by` VARCHAR(50) NULL DEFAULT NULL,
  `updated_at` DATETIME NULL DEFAULT NULL,
  `deleted` TINYINT(1) NOT NULL DEFAULT 0,  -- 0 = activa, 1 = eliminada
  PRIMARY KEY (`id_comuna`),
  UNIQUE INDEX `nombre` (`nombre` ASC) VISIBLE,
  CHECK (CHAR_LENGTH(nombre) > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- -----------------------------------------------------
-- Table `plazas`
-- Información de cada plaza, incluyendo su comuna asociada.
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `plazas` (
  `id_plaza` INT NOT NULL AUTO_INCREMENT,  -- ID único de la plaza
  `nombre` VARCHAR(100) NOT NULL,  -- Nombre de la plaza
  `direccion` VARCHAR(150) NOT NULL,  -- Dirección física
  `id_comuna` INT NULL DEFAULT NULL,  -- FK a comuna
  `created_by` VARCHAR(50) NULL DEFAULT NULL,
  `created_at` DATETIME NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_by` VARCHAR(50) NULL DEFAULT NULL,
  `updated_at` DATETIME NULL DEFAULT NULL,
  `deleted` TINYINT(1) NOT NULL DEFAULT 0,  -- 0 = activa, 1 = eliminada
  PRIMARY KEY (`id_plaza`),
  INDEX `id_comuna` (`id_comuna` ASC) VISIBLE,
  CONSTRAINT `plazas_ibfk_1`
    FOREIGN KEY (`id_comuna`)
    REFERENCES `comunas` (`id_comuna`),
  CHECK (CHAR_LENGTH(nombre) > 0),
  CHECK (CHAR_LENGTH(direccion) > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- -----------------------------------------------------
-- Table `estado_camara`
-- Lista de posibles estados de las cámaras.
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `estado_camara` (
  `id_estado_camara` INT NOT NULL AUTO_INCREMENT,  -- ID único del estado
  `nombre` VARCHAR(50) NOT NULL,  -- Nombre del estado (ACTIVA/INACTIVA)
  `descripcion` VARCHAR(255) NULL DEFAULT NULL,  -- Descripción del estado
  `created_by` VARCHAR(50) NULL DEFAULT NULL,
  `created_at` DATETIME NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_by` VARCHAR(50) NULL DEFAULT NULL,
  `updated_at` DATETIME NULL DEFAULT NULL,
  `deleted` TINYINT(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id_estado_camara`),
  UNIQUE INDEX `nombre` (`nombre` ASC) VISIBLE,
  CHECK (CHAR_LENGTH(nombre) > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- -----------------------------------------------------
-- Table `camaras`
-- Información de cada cámara de vigilancia en la plaza.
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `camaras` (
  `id_camara` INT NOT NULL AUTO_INCREMENT,  -- ID único de cámara
  `ubicacion` VARCHAR(100) NOT NULL,  -- Ubicación dentro de la plaza
  `id_estado_camara` INT NOT NULL,  -- FK a estado_camara
  `id_plaza` INT NOT NULL,  -- FK a plaza
  `created_by` VARCHAR(50) NULL DEFAULT NULL,
  `created_at` DATETIME NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_by` VARCHAR(50) NULL DEFAULT NULL,
  `updated_at` DATETIME NULL DEFAULT NULL,
  `deleted` TINYINT(1) NOT NULL DEFAULT 0,  -- 0 = activa, 1 = eliminada
  PRIMARY KEY (`id_camara`),
  INDEX `id_plaza` (`id_plaza` ASC) VISIBLE,
  INDEX `id_estado_camara` (`id_estado_camara` ASC) VISIBLE,
  CONSTRAINT `camaras_ibfk_1`
    FOREIGN KEY (`id_plaza`)
    REFERENCES `plazas` (`id_plaza`),
  CONSTRAINT `camaras_ibfk_estado`
    FOREIGN KEY (`id_estado_camara`)
    REFERENCES `estado_camara` (`id_estado_camara`),
  CHECK (CHAR_LENGTH(ubicacion) > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- -----------------------------------------------------
-- Table `juntas_vecinos`
-- Registro de juntas de vecinos por comuna.
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `juntas_vecinos` (
  `id_junta` INT NOT NULL AUTO_INCREMENT,  -- ID único de la junta
  `nombre` VARCHAR(100) NOT NULL,  -- Nombre de la junta
  `id_comuna` INT NOT NULL,  -- FK a comuna
  `created_by` VARCHAR(50) NULL DEFAULT NULL,
  `created_at` DATETIME NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_by` VARCHAR(50) NULL DEFAULT NULL,
  `updated_at` DATETIME NULL DEFAULT NULL,
  `deleted` TINYINT(1) NOT NULL DEFAULT 0,  -- 0 = activa, 1 = eliminada
  PRIMARY KEY (`id_junta`),
  INDEX `id_comuna` (`id_comuna` ASC) VISIBLE,
  CONSTRAINT `juntas_vecinos_ibfk_1`
    FOREIGN KEY (`id_comuna`)
    REFERENCES `comunas` (`id_comuna`),
  CHECK (CHAR_LENGTH(nombre) > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- -----------------------------------------------------
-- Table `personas`
-- Información de vecinos o personas registradas.
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `personas` (
  `id_persona` INT NOT NULL AUTO_INCREMENT, -- RUT único
  `rut` VARCHAR(12) NOT NULL,  -- Nombre completo
  `nombre` VARCHAR(100) NOT NULL,  -- Email
  `correo` VARCHAR(100) NULL DEFAULT NULL,  -- Teléfono
  `telefono` VARCHAR(15) NULL DEFAULT NULL,  -- Dirección
  `direccion` VARCHAR(150) NULL DEFAULT NULL,  -- FK a comuna
  `id_comuna` INT NULL DEFAULT NULL,
  `created_by` VARCHAR(50) NULL DEFAULT NULL,
  `created_at` DATETIME NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_by` VARCHAR(50) NULL DEFAULT NULL,
  `updated_at` DATETIME NULL DEFAULT NULL,
  `deleted` TINYINT(1) NOT NULL DEFAULT 0,  -- 0 = activa, 1 = eliminada
  PRIMARY KEY (`id_persona`),
  UNIQUE INDEX `rut` (`rut` ASC) VISIBLE,
  INDEX `id_comuna` (`id_comuna` ASC) VISIBLE,
  CONSTRAINT `personas_ibfk_1`
    FOREIGN KEY (`id_comuna`)
    REFERENCES `comunas` (`id_comuna`),
  CHECK (CHAR_LENGTH(nombre) > 0),
  CHECK (CHAR_LENGTH(rut) > 0),
  CHECK (telefono REGEXP '^[0-9]{8,15}$' OR telefono IS NULL),
  CHECK (correo REGEXP '^[^@]+@[^@]+\.[^@]+$' OR correo IS NULL)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- -----------------------------------------------------
-- Table `usuarios`
-- Usuarios del sistema vinculados a personas y tipo de usuario.
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `usuarios` (
  `id_usuario` INT NOT NULL AUTO_INCREMENT,
  `id_persona` INT NOT NULL,  -- FK a personas
  `contrasena` VARCHAR(255) NOT NULL,  -- Contraseña del usuario
  `id_tipo_usuario` INT NOT NULL,  -- FK a tipo_usuarios
  `created_by` VARCHAR(50) NULL DEFAULT NULL,
  `created_at` DATETIME NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_by` VARCHAR(50) NULL DEFAULT NULL,
  `updated_at` DATETIME NULL DEFAULT NULL,
  `deleted` TINYINT(1) NOT NULL DEFAULT 0,  -- 0 = activa, 1 = eliminada
  PRIMARY KEY (`id_usuario`),
  UNIQUE INDEX `id_persona` (`id_persona` ASC) VISIBLE,
  INDEX `id_tipo_usuario` (`id_tipo_usuario` ASC) VISIBLE,
  CONSTRAINT `usuarios_ibfk_persona`
    FOREIGN KEY (`id_persona`)
    REFERENCES `personas` (`id_persona`),
  CONSTRAINT `usuarios_ibfk_tipo`
    FOREIGN KEY (`id_tipo_usuario`)
    REFERENCES `tipo_usuarios` (`id_tipo_usuario`),
  CHECK (CHAR_LENGTH(contrasena) > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- -----------------------------------------------------
-- Table `tipo_reporte`
-- Define los diferentes tipos de reportes que se pueden generar.
-- Ej: Sospechoso, Accidente, Objeto Peligroso, Comportamiento Raro.
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `tipo_reporte` (
  `id_tipo_reporte` INT NOT NULL AUTO_INCREMENT,  -- ID único del tipo de reporte
  `nombre` VARCHAR(100) NOT NULL,  -- Nombre del tipo de reporte
  `descripcion` VARCHAR(255) NULL DEFAULT NULL,  -- Descripción del tipo de reporte
  `created_by` VARCHAR(50) NULL DEFAULT NULL,  -- Usuario que creó el registro
  `created_at` DATETIME NULL DEFAULT CURRENT_TIMESTAMP,  -- Fecha de creación
  `updated_by` VARCHAR(50) NULL DEFAULT NULL,  -- Usuario que modificó el registro
  `updated_at` DATETIME NULL DEFAULT NULL,  -- Fecha de última modificación
  `deleted` TINYINT(1) NOT NULL DEFAULT 0,  -- 0 = activo, 1 = eliminado
  PRIMARY KEY (`id_tipo_reporte`),
  UNIQUE INDEX `nombre` (`nombre` ASC) VISIBLE,
  CHECK (CHAR_LENGTH(nombre) > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- -----------------------------------------------------
-- Table `reportes`
-- Registra cada reporte generado en la plaza, vinculado a un tipo de reporte, usuario y plaza.
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `reportes` (
  `id_reporte` INT NOT NULL AUTO_INCREMENT,  -- ID único del reporte
  `id_tipo_reporte` INT NOT NULL,  -- FK a tipo_reporte
  `descripcion` TEXT NULL DEFAULT NULL,  -- Detalle del reporte
  `fecha` DATE NOT NULL,  -- Fecha del reporte
  `hora` TIME NOT NULL,  -- Hora del reporte
  `id_usuario` INT NOT NULL,  -- FK a usuario que genera el reporte
  `id_plaza` INT NOT NULL,  -- FK a plaza donde ocurre
  `created_by` VARCHAR(50) NULL DEFAULT NULL,  -- Usuario que creó el registro
  `created_at` DATETIME NULL DEFAULT CURRENT_TIMESTAMP,  -- Fecha de creación
  `updated_by` VARCHAR(50) NULL DEFAULT NULL,  -- Usuario que modificó el registro
  `updated_at` DATETIME NULL DEFAULT NULL,  -- Fecha de última modificación
  `deleted` TINYINT(1) NOT NULL DEFAULT 0,  -- 0 = activo, 1 = eliminado
  PRIMARY KEY (`id_reporte`),
  INDEX `id_usuario` (`id_usuario` ASC) VISIBLE,
  INDEX `id_plaza` (`id_plaza` ASC) VISIBLE,
  INDEX `id_tipo_reporte` (`id_tipo_reporte` ASC) VISIBLE,
  CONSTRAINT `reportes_ibfk_1`
    FOREIGN KEY (`id_usuario`)
    REFERENCES `usuarios` (`id_usuario`),
  CONSTRAINT `reportes_ibfk_2`
    FOREIGN KEY (`id_plaza`)
    REFERENCES `plazas` (`id_plaza`),
  CONSTRAINT `reportes_ibfk_tipo`
    FOREIGN KEY (`id_tipo_reporte`)
    REFERENCES `tipo_reporte` (`id_tipo_reporte`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
