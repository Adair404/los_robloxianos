-- =========================================================
-- Esquema mejorado de colegio_db
-- Basado en BD/database.sql
-- Requiere MySQL 8.0.16+ para la evaluación de CHECK constraints.
-- =========================================================

CREATE DATABASE IF NOT EXISTS colegio_db
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;
USE colegio_db;

SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS rampas_accesibilidad;
DROP TABLE IF EXISTS anuncios;
DROP TABLE IF EXISTS horarios;
DROP TABLE IF EXISTS curso_alumno;
DROP TABLE IF EXISTS cursos;
DROP TABLE IF EXISTS materias;
DROP TABLE IF EXISTS espacios;
DROP TABLE IF EXISTS usuarios;
DROP TABLE IF EXISTS roles;
SET FOREIGN_KEY_CHECKS = 1;

-- =========================================================
-- 1. ROLES Y USUARIOS
-- =========================================================
CREATE TABLE roles (
    id_rol INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL UNIQUE,
    creado_en TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE = InnoDB;

INSERT INTO roles (nombre) VALUES
    ('dev'),
    ('utp'),
    ('profesor'),
    ('alumno');

CREATE TABLE usuarios (
    id_usuario INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    rut VARCHAR(12) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    nombre VARCHAR(50) NOT NULL,
    apellido VARCHAR(50) NOT NULL,
    email VARCHAR(100) NULL UNIQUE,
    id_rol INT UNSIGNED NOT NULL,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    creado_en TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    actualizado_en TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_usuarios_rol
        FOREIGN KEY (id_rol) REFERENCES roles(id_rol)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    INDEX idx_usuarios_rol (id_rol),
    INDEX idx_usuarios_nombre (apellido, nombre),
    CONSTRAINT chk_usuarios_rut_no_vacio CHECK (CHAR_LENGTH(TRIM(rut)) > 0),
    CONSTRAINT chk_usuarios_nombre_no_vacio CHECK (CHAR_LENGTH(TRIM(nombre)) > 0),
    CONSTRAINT chk_usuarios_apellido_no_vacio CHECK (CHAR_LENGTH(TRIM(apellido)) > 0)
) ENGINE = InnoDB;

-- Estos valores son hashes bcrypt de ejemplo. En producción deben generarse
-- desde la aplicación y nunca deben almacenarse contraseñas en texto plano.
INSERT INTO usuarios (rut, password_hash, nombre, apellido, id_rol) VALUES
    ('1-9', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llCqYyVxR4sC4vQ7fQf6a', 'Daniel', 'Creador', 1),
    ('4-4', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llCqYyVxR4sC4vQ7fQf6a', 'Jefe', 'UTP', 2),
    ('2-7', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llCqYyVxR4sC4vQ7fQf6a', 'Juan', 'Carlos', 3),
    ('3-5', '$2y$10$92IXUNpkjO0rOQ5byMi.Y0oKoEa3Ro9llCqYyVxR4sC4vQ7fQf6a', 'Jorge', 'Badani', 4);

-- =========================================================
-- 2. ESPACIOS Y MAPA
-- =========================================================
CREATE TABLE espacios (
    id_espacio VARCHAR(20) PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    tipo ENUM('AULA', 'ADMINISTRACION', 'TALLER', 'DEPORTE', 'OTRO') NOT NULL,
    pabellon_bloque VARCHAR(5) NULL,
    piso INT NOT NULL DEFAULT 1,
    superficie_util_m2 DECIMAL(7,2) NULL,
    superficie_eje_m2 DECIMAL(7,2) NULL,
    npt DECIMAL(5,2) NULL,
    latitud DECIMAL(10,8) NULL,
    longitud DECIMAL(11,8) NULL,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    creado_en TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_espacios_piso CHECK (piso >= 0),
    CONSTRAINT chk_espacios_superficies CHECK (
        (superficie_util_m2 IS NULL OR superficie_util_m2 >= 0) AND
        (superficie_eje_m2 IS NULL OR superficie_eje_m2 >= 0)
    ),
    CONSTRAINT chk_espacios_coordenadas CHECK (
        (latitud IS NULL AND longitud IS NULL) OR
        (latitud BETWEEN -90 AND 90 AND longitud BETWEEN -180 AND 180)
    ),
    INDEX idx_espacios_tipo (tipo),
    INDEX idx_espacios_pabellon (pabellon_bloque, piso)
) ENGINE = InnoDB;

INSERT INTO espacios
    (id_espacio, nombre, tipo, pabellon_bloque, piso, superficie_util_m2, superficie_eje_m2, npt)
VALUES
    ('DIR', 'Dirección', 'ADMINISTRACION', 'A', 1, 19.90, 21.50, 0.00),
    ('SD', 'Subdirección', 'ADMINISTRACION', 'A', 1, 19.14, 19.50, 0.00),
    ('UTP', 'Unidad Técnico Pedagógica', 'ADMINISTRACION', 'A', 1, 20.00, 21.60, 0.00),
    ('SE', 'Secretaría / Espera', 'ADMINISTRACION', 'A', 1, 13.42, 14.70, 0.00),
    ('ADM1', 'Administración 1', 'ADMINISTRACION', 'A', 1, 11.90, 12.96, 0.00),
    ('A_19', 'Sala A 19', 'AULA', 'J', 1, 49.70, 51.84, -0.60),
    ('A_20', 'Sala A 20', 'AULA', 'J', 1, 49.70, 51.84, -0.60),
    ('A_21', 'Sala A 21', 'AULA', 'J', 1, 49.70, 51.84, -0.60),
    ('A_22', 'Sala A 22', 'AULA', 'J', 1, 49.70, 51.84, -0.60),
    ('A_23', 'Sala A 23', 'AULA', 'J', 1, 49.70, 51.84, -0.60),
    ('A_24', 'Sala A 24', 'AULA', 'J', 1, 49.70, 51.84, -0.60),
    ('A_25', 'Sala A 25', 'AULA', 'B', 1, 49.70, 51.84, -0.26),
    ('A_26', 'Sala A 26', 'AULA', 'B', 1, 49.70, 51.84, -0.26),
    ('A_32', 'Sala A 32', 'AULA', 'B', 1, 51.04, 54.00, -0.26),
    ('A_33', 'Sala A 33', 'AULA', 'L', 1, 51.04, 54.00, -0.02),
    ('ELEC_1', 'Taller de Electricidad', 'TALLER', 'J', 1, 68.44, 72.00, -0.60),
    ('ELECTRON', 'Taller de Electrónica', 'TALLER', 'J', 1, 85.84, 90.00, -0.60),
    ('SCC', 'Sala de Computación / Enlaces', 'TALLER', 'J', 1, 135.04, 142.74, -0.60),
    ('CRI', 'Centro de Recursos (CRA)', 'TALLER', 'I', 1, 53.10, 55.35, -1.05),
    ('GIM', 'Gimnasio', 'DEPORTE', 'K', 1, 0.00, 0.00, -0.34);

-- =========================================================
-- 3. CURSOS Y MATRÍCULA
-- =========================================================
CREATE TABLE cursos (
    id_curso VARCHAR(10) PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    nivel VARCHAR(10) NULL,
    letra CHAR(1) NULL,
    id_profesor_jefe INT UNSIGNED NULL,
    id_sala_base VARCHAR(20) NULL,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    creado_en TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    actualizado_en TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_cursos_profesor_jefe
        FOREIGN KEY (id_profesor_jefe) REFERENCES usuarios(id_usuario)
        ON UPDATE CASCADE ON DELETE SET NULL,
    CONSTRAINT fk_cursos_sala_base
        FOREIGN KEY (id_sala_base) REFERENCES espacios(id_espacio)
        ON UPDATE CASCADE ON DELETE SET NULL,
    INDEX idx_cursos_profesor_jefe (id_profesor_jefe),
    INDEX idx_cursos_sala_base (id_sala_base)
) ENGINE = InnoDB;

INSERT INTO cursos (id_curso, nombre, nivel, letra, id_profesor_jefe, id_sala_base) VALUES
    ('1F', '1° Medio F', '1°', 'F', 3, 'A_32'),
    ('1G', '1° Medio G', '1°', 'G', NULL, 'A_33'),
    ('2A', '2° Medio A', '2°', 'A', NULL, 'A_23'),
    ('2B', '2° Medio B', '2°', 'B', NULL, 'A_24'),
    ('2D', '2° Medio D', '2°', 'D', NULL, 'A_25'),
    ('2E', '2° Medio E', '2°', 'E', NULL, 'A_26'),
    ('2I', '2° Medio I', '2°', 'I', NULL, 'A_21'),
    ('2J', '2° Medio J', '2°', 'J', NULL, 'A_22'),
    ('4F', '4° Medio F', '4°', 'F', NULL, 'A_19'),
    ('4G', '4° Medio G', '4°', 'G', NULL, 'A_20');

CREATE TABLE curso_alumno (
    id_curso VARCHAR(10) NOT NULL,
    id_alumno INT UNSIGNED NOT NULL,
    matriculado_en TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_curso, id_alumno),
    CONSTRAINT fk_curso_alumno_curso
        FOREIGN KEY (id_curso) REFERENCES cursos(id_curso)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_curso_alumno_usuario
        FOREIGN KEY (id_alumno) REFERENCES usuarios(id_usuario)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    INDEX idx_curso_alumno_alumno (id_alumno)
) ENGINE = InnoDB;

INSERT INTO curso_alumno (id_curso, id_alumno) VALUES ('1F', 4);

-- =========================================================
-- 4. MATERIAS Y HORARIOS
-- =========================================================
CREATE TABLE materias (
    id_materia INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    creado_en TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE = InnoDB;

INSERT INTO materias (nombre) VALUES
    ('Matemáticas'),
    ('Lenguaje'),
    ('Electrónica');

CREATE TABLE horarios (
    id_horario INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    id_curso VARCHAR(10) NOT NULL,
    id_materia INT UNSIGNED NOT NULL,
    id_profesor INT UNSIGNED NOT NULL,
    id_espacio VARCHAR(20) NOT NULL,
    dia_semana TINYINT UNSIGNED NOT NULL,
    hora_inicio TIME NOT NULL,
    hora_fin TIME NOT NULL,
    creado_en TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_horarios_curso
        FOREIGN KEY (id_curso) REFERENCES cursos(id_curso)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_horarios_materia
        FOREIGN KEY (id_materia) REFERENCES materias(id_materia)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_horarios_profesor
        FOREIGN KEY (id_profesor) REFERENCES usuarios(id_usuario)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_horarios_espacio
        FOREIGN KEY (id_espacio) REFERENCES espacios(id_espacio)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT chk_horarios_dia CHECK (dia_semana BETWEEN 1 AND 7),
    CONSTRAINT chk_horarios_horas CHECK (hora_inicio < hora_fin),
    INDEX idx_horarios_curso_dia (id_curso, dia_semana, hora_inicio),
    INDEX idx_horarios_profesor_dia (id_profesor, dia_semana, hora_inicio),
    INDEX idx_horarios_espacio_dia (id_espacio, dia_semana, hora_inicio)
) ENGINE = InnoDB;

-- =========================================================
-- 5. ANUNCIOS
-- =========================================================
CREATE TABLE anuncios (
    id_anuncio INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    id_curso VARCHAR(10) NOT NULL,
    id_autor INT UNSIGNED NOT NULL,
    titulo VARCHAR(150) NOT NULL,
    contenido TEXT NOT NULL,
    publicado BOOLEAN NOT NULL DEFAULT TRUE,
    fecha_publicacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    actualizado_en TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_anuncios_curso
        FOREIGN KEY (id_curso) REFERENCES cursos(id_curso)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_anuncios_autor
        FOREIGN KEY (id_autor) REFERENCES usuarios(id_usuario)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    INDEX idx_anuncios_curso_fecha (id_curso, fecha_publicacion),
    INDEX idx_anuncios_autor (id_autor)
) ENGINE = InnoDB;

-- =========================================================
-- 6. ACCESIBILIDAD
-- =========================================================
CREATE TABLE rampas_accesibilidad (
    id_rampa INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    id_espacio VARCHAR(20) NULL,
    ubicacion_descripcion VARCHAR(100) NOT NULL,
    largo_metros DECIMAL(5,2) NOT NULL,
    pendiente_porcentaje DECIMAL(5,2) NOT NULL,
    activa BOOLEAN NOT NULL DEFAULT TRUE,
    creado_en TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_rampas_espacio
        FOREIGN KEY (id_espacio) REFERENCES espacios(id_espacio)
        ON UPDATE CASCADE ON DELETE SET NULL,
    CONSTRAINT chk_rampas_largo CHECK (largo_metros > 0),
    CONSTRAINT chk_rampas_pendiente CHECK (pendiente_porcentaje >= 0),
    INDEX idx_rampas_espacio (id_espacio)
) ENGINE = InnoDB;

INSERT INTO rampas_accesibilidad
    (id_espacio, ubicacion_descripcion, largo_metros, pendiente_porcentaje)
VALUES
    (NULL, 'Rampa Acceso Pabellón B - J', 7.00, 7.80),
    (NULL, 'Rampa Acceso Sector Norte - L', 7.00, 7.80),
    (NULL, 'Rampa Conexión Patio - Pabellón E', 3.00, 11.30);

-- Nota: la aplicación debe validar en una transacción que no existan
-- solapamientos de horario para un curso, profesor o espacio.
