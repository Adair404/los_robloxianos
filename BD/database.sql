CREATE DATABASE IF NOT EXISTS colegio_db;
USE colegio_db;

-- ==========================================
-- 1. ROLES Y USUARIOS
-- ==========================================
CREATE TABLE roles (
    id_rol INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL UNIQUE
);

INSERT INTO roles (nombre) VALUES 
('dev'),
('utp'),
('profesor'),
('alumno');

CREATE TABLE usuarios (
    id_usuario INT AUTO_INCREMENT PRIMARY KEY,
    rut VARCHAR(12) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    nombre VARCHAR(50) NOT NULL,
    apellido VARCHAR(50) NOT NULL,
    email VARCHAR(100),
    id_rol INT NOT NULL,
    FOREIGN KEY (id_rol) REFERENCES roles(id_rol)
);

-- Usuarios de prueba
INSERT INTO usuarios (rut, password, nombre, apellido, id_rol) VALUES
('1-9', 'dev123', 'Daniel', 'Creador', 1),
('4-4', 'utp123', 'Jefe', 'UTP', 2),
('2-7', 'profe123', 'Juan', 'Carlos', 3),
('3-5', 'alumno123', 'Jorge', 'Badani', 4);


-- ==========================================
-- 2. ESPACIOS Y MAPA (Reemplaza a la tabla 'salas')
-- ==========================================
CREATE TABLE espacios (
    id_espacio VARCHAR(20) PRIMARY KEY, -- ej: 'A_19', 'DIR', 'GIM'
    nombre VARCHAR(100) NOT NULL,
    tipo VARCHAR(50) NOT NULL,          -- 'AULA', 'ADMINISTRACION', 'TALLER', 'DEPORTE'
    pabellon_bloque VARCHAR(5),
    piso INT DEFAULT 1,
    superficie_util_m2 DECIMAL(5,2),
    superficie_eje_m2 DECIMAL(5,2),
    npt VARCHAR(10),
    latitud DECIMAL(10, 8) NULL,        -- para coordenadas GPS integrada
    longitud DECIMAL(11, 8) NULL
);

INSERT INTO espacios (id_espacio, nombre, tipo, pabellon_bloque, piso, superficie_util_m2, superficie_eje_m2, npt) VALUES
('DIR', 'Dirección', 'ADMINISTRACION', 'A', 1, 19.90, 21.50, '0.00'),
('SD', 'Subdirección', 'ADMINISTRACION', 'A', 1, 19.14, 19.50, '0.00'),
('UTP', 'Unidad Técnico Pedagógica', 'ADMINISTRACION', 'A', 1, 20.00, 21.60, '0.00'),
('SE', 'Secretaría / Espera', 'ADMINISTRACION', 'A', 1, 13.42, 14.70, '0.00'),
('ADM1', 'Administración 1', 'ADMINISTRACION', 'A', 1, 11.90, 12.96, '0.00'),
('A_19', 'Sala A 19', 'AULA', 'J', 1, 49.70, 51.84, '-0.60'),
('A_20', 'Sala A 20', 'AULA', 'J', 1, 49.70, 51.84, '-0.60'),
('A_21', 'Sala A 21', 'AULA', 'J', 1, 49.70, 51.84, '-0.60'),
('A_22', 'Sala A 22', 'AULA', 'J', 1, 49.70, 51.84, '-0.60'),
('A_23', 'Sala A 23', 'AULA', 'J', 1, 49.70, 51.84, '-0.60'),
('A_24', 'Sala A 24', 'AULA', 'J', 1, 49.70, 51.84, '-0.60'),
('A_25', 'Sala A 25', 'AULA', 'B', 1, 49.70, 51.84, '-0.26'),
('A_26', 'Sala A 26', 'AULA', 'B', 1, 49.70, 51.84, '-0.26'),
('A_32', 'Sala A 32', 'AULA', 'B', 1, 51.04, 54.00, '-0.26'),
('A_33', 'Sala A 33', 'AULA', 'L', 1, 51.04, 54.00, '-0.02'),
('ELEC_1', 'Taller de Electricidad', 'TALLER', 'J', 1, 68.44, 72.00, '-0.60'),
('ELECTRON', 'Taller de Electrónica', 'TALLER', 'J', 1, 85.84, 90.00, '-0.60'),
('SCC', 'Sala de Computación / Enlaces', 'TALLER', 'J', 1, 135.04, 142.74, '-0.60'),
('CRI', 'Centro de Recursos (CRA)', 'TALLER', 'I', 1, 53.10, 55.35, '-1.05'),
('GIM', 'Gimnasio', 'DEPORTE', 'K', 1, 0.00, 0.00, '-0.34');


-- ==========================================
-- 3. CURSOS (Estructura Unificada)
-- ==========================================
CREATE TABLE cursos (
    id_curso VARCHAR(10) PRIMARY KEY,   -- ej: '1F', '2A'
    nombre VARCHAR(50) NOT NULL,        -- ej: '1° Medio F'
    nivel VARCHAR(10),                  -- '1°', '2°', etc.
    letra CHAR(1),                      -- 'F', 'G', etc.
    id_profesor_jefe INT NULL,
    id_sala_base VARCHAR(20) NULL,
    FOREIGN KEY (id_profesor_jefe) REFERENCES usuarios(id_usuario),
    FOREIGN KEY (id_sala_base) REFERENCES espacios(id_espacio)
);

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
    id_alumno INT NOT NULL,
    PRIMARY KEY (id_curso, id_alumno),
    FOREIGN KEY (id_curso) REFERENCES cursos(id_curso),
    FOREIGN KEY (id_alumno) REFERENCES usuarios(id_usuario)
);

-- Asignar alumno de prueba (Jorge Badani) al curso 1F
INSERT INTO curso_alumno (id_curso, id_alumno) VALUES ('1F', 4);


-- ==========================================
-- 4. MATERIAS Y HORARIOS
-- ==========================================
CREATE TABLE materias (
    id_materia INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL
);

INSERT INTO materias (nombre) VALUES 
('Matemáticas'), 
('Lenguaje'), 
('Electrónica');

CREATE TABLE horarios (
    id_horario INT AUTO_INCREMENT PRIMARY KEY,
    id_curso VARCHAR(10) NOT NULL,
    id_materia INT NOT NULL,
    id_profesor INT NOT NULL,
    id_espacio VARCHAR(20) NOT NULL,    -- Vinculado a 'espacios'
    dia_semana TINYINT NOT NULL,        -- 1: Lunes, 2: Martes...
    hora_inicio TIME NOT NULL,
    hora_fin TIME NOT NULL,
    FOREIGN KEY (id_curso) REFERENCES cursos(id_curso),
    FOREIGN KEY (id_materia) REFERENCES materias(id_materia),
    FOREIGN KEY (id_profesor) REFERENCES usuarios(id_usuario),
    FOREIGN KEY (id_espacio) REFERENCES espacios(id_espacio)
);


-- ==========================================
-- 5. ANUNCIOS Y ACCESIBILIDAD
-- ==========================================
CREATE TABLE anuncios (
    id_anuncio INT AUTO_INCREMENT PRIMARY KEY,
    id_curso VARCHAR(10) NOT NULL,
    id_autor INT NOT NULL,
    titulo VARCHAR(150) NOT NULL,
    contenido TEXT NOT NULL,
    fecha_publicacion DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_curso) REFERENCES cursos(id_curso),
    FOREIGN KEY (id_autor) REFERENCES usuarios(id_usuario)
);

CREATE TABLE rampas_accesibilidad (
    id_rampa INT AUTO_INCREMENT PRIMARY KEY,
    ubicacion_descripcion VARCHAR(100),
    largo_metros DECIMAL(4,2),
    pendiente_porcentaje DECIMAL(4,2)
);

INSERT INTO rampas_accesibilidad (ubicacion_descripcion, largo_metros, pendiente_porcentaje) VALUES
('Rampa Acceso Pabellón B - J', 7.00, 7.80),
('Rampa Acceso Sector Norte - L', 7.00, 7.80),
('Rampa Conexión Patio - Pabellón E', 3.00, 11.30);