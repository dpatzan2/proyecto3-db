-- Crear extensión para generar UUIDs
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Crear tipos ENUM
CREATE TYPE estado_inscripcion AS ENUM ('pendiente', 'en_progreso', 'completado', 'abandonado');
CREATE TYPE nivel_curso AS ENUM ('principiante', 'intermedio', 'avanzado', 'experto');
CREATE TYPE tipo_contenido AS ENUM ('video', 'lectura', 'quiz', 'tarea');
CREATE TYPE tipo_evaluacion AS ENUM ('examen', 'proyecto', 'tarea', 'quiz');

-- Tabla Estudiantes
CREATE TABLE estudiantes (
  estudiante_id SERIAL PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL,
  apellido VARCHAR(100) NOT NULL,
  email VARCHAR(150) NOT NULL UNIQUE,
  fecha_nacimiento DATE NOT NULL CHECK (fecha_nacimiento <= CURRENT_DATE),
  telefono VARCHAR(20) NOT NULL,
  direccion VARCHAR(255) NOT NULL,
  fecha_registro TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  estado_activo BOOLEAN NOT NULL DEFAULT TRUE,
  promedio_general DECIMAL(5,2) DEFAULT 0.0 CHECK (promedio_general BETWEEN 0 AND 100),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


-- Tabla de Instructores
CREATE TABLE instructores (
  instructor_id SERIAL PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL,
  apellido VARCHAR(100) NOT NULL,
  email VARCHAR(150) NOT NULL UNIQUE,
  especialidad VARCHAR(100) NOT NULL,
  biografia TEXT NOT NULL,
  calificacion_promedio DECIMAL(5,2) DEFAULT 0.0 CHECK (calificacion_promedio BETWEEN 0 AND 5),
  fecha_contratacion DATE NOT NULL,
  estado_activo BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla Cursos
CREATE TABLE cursos (
    curso_id SERIAL PRIMARY KEY,
    titulo VARCHAR(100) NOT NULL UNIQUE,
    descripcion TEXT NOT NULL,
    nivel nivel_curso NOT NULL DEFAULT 'principiante',
    duracion_horas INTEGER NOT NULL CHECK (duracion_horas > 0),
    precio DECIMAL(10,2) NOT NULL CHECK (precio >= 0),
    instructor_id INTEGER NOT NULL,
    fecha_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    estado_activo BOOLEAN NOT NULL DEFAULT true,
    promedio_calificaciones DECIMAL(3,2) CHECK (promedio_calificaciones >= 0 AND promedio_calificaciones <= 5),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (instructor_id) REFERENCES instructores(instructor_id) ON DELETE RESTRICT
);

-- Tabla Módulos
CREATE TABLE modulos (
    modulo_id SERIAL PRIMARY KEY,
    curso_id INTEGER NOT NULL,
    titulo VARCHAR(100) NOT NULL,
    descripcion TEXT NOT NULL,
    orden INTEGER NOT NULL CHECK (orden > 0),
    duracion_horas INTEGER NOT NULL CHECK (duracion_horas > 0),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(curso_id, orden),
    FOREIGN KEY (curso_id) REFERENCES cursos(curso_id) ON DELETE CASCADE
);

-- Tabla Lecciones
CREATE TABLE lecciones (
    leccion_id SERIAL PRIMARY KEY,
    modulo_id INTEGER NOT NULL,
    titulo VARCHAR(100) NOT NULL,
    contenido TEXT NOT NULL,
    duracion_minutos INTEGER NOT NULL CHECK (duracion_minutos > 0),
    orden INTEGER NOT NULL CHECK (orden > 0),
    tipo_contenido tipo_contenido NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(modulo_id, orden),
    FOREIGN KEY (modulo_id) REFERENCES modulos(modulo_id) ON DELETE CASCADE
);

-- Tabla Inscripciones
CREATE TABLE inscripciones (
    inscripcion_id SERIAL PRIMARY KEY,
    estudiante_id INTEGER NOT NULL,
    curso_id INTEGER NOT NULL,
    fecha_inscripcion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_completado TIMESTAMP,
    progreso_porcentaje DECIMAL(5,2) NOT NULL DEFAULT 0 CHECK (progreso_porcentaje >= 0 AND progreso_porcentaje <= 100),
    estado estado_inscripcion NOT NULL DEFAULT 'pendiente',
    calificacion_final DECIMAL(4,2) CHECK (calificacion_final >= 0 AND calificacion_final <= 10),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(estudiante_id, curso_id),
    FOREIGN KEY (estudiante_id) REFERENCES estudiantes(estudiante_id) ON DELETE RESTRICT,
    FOREIGN KEY (curso_id) REFERENCES cursos(curso_id) ON DELETE RESTRICT
);

-- Tabla Evaluaciones
CREATE TABLE evaluaciones (
    evaluacion_id SERIAL PRIMARY KEY,
    curso_id INTEGER NOT NULL,
	instructor_id INTEGER NOT NULL,
    titulo VARCHAR(100) NOT NULL,
    descripcion TEXT NOT NULL,
    tipo_evaluacion tipo_evaluacion NOT NULL,
    puntaje_maximo INTEGER NOT NULL CHECK (puntaje_maximo > 0),
    fecha_limite DATE NOT NULL CHECK (fecha_limite >= CURRENT_DATE),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (curso_id) REFERENCES cursos(curso_id) ON DELETE CASCADE
	FOREIGN KEY (instructor_id) REFERENCES instructores(instructor_id) ON DELETE CASCADE
);

-- Tabla Progreso de Lecciones
CREATE TABLE progreso_lecciones (
    progreso_id SERIAL PRIMARY KEY,
    inscripcion_id INTEGER NOT NULL,
    leccion_id INTEGER NOT NULL,
    estado_completado BOOLEAN NOT NULL DEFAULT false,
    tiempo_dedicado INTEGER NOT NULL DEFAULT 0 CHECK (tiempo_dedicado >= 0),
    ultima_visualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(inscripcion_id, leccion_id),
    FOREIGN KEY (inscripcion_id) REFERENCES inscripciones(inscripcion_id) ON DELETE CASCADE,
    FOREIGN KEY (leccion_id) REFERENCES lecciones(leccion_id) ON DELETE CASCADE
);

-- Tabla Recursos Educativos
CREATE TABLE recursos_educativos (
    recurso_id SERIAL PRIMARY KEY,
    leccion_id INTEGER NOT NULL,
    titulo VARCHAR(100) NOT NULL,
    tipo_recurso VARCHAR(50) NOT NULL,
    url VARCHAR(255) NOT NULL,
    descripcion TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (leccion_id) REFERENCES lecciones(leccion_id) ON DELETE CASCADE
);

-- Tabla Habilidades
CREATE TABLE habilidades (
    habilidad_id SERIAL PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL UNIQUE,
    descripcion TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Tabla Curso-Habilidades
CREATE TABLE curso_habilidades (
    curso_id INTEGER NOT NULL,
    habilidad_id INTEGER NOT NULL,
    nivel_requerido VARCHAR(50) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (curso_id, habilidad_id),
    FOREIGN KEY (curso_id) REFERENCES cursos(curso_id) ON DELETE CASCADE,
    FOREIGN KEY (habilidad_id) REFERENCES habilidades(habilidad_id) ON DELETE CASCADE
);

-- Tabla Comentarios
CREATE TABLE comentarios (
    comentario_id SERIAL PRIMARY KEY,
    curso_id INTEGER NOT NULL,
    estudiante_id INTEGER NOT NULL,
    contenido TEXT NOT NULL,
    calificacion INTEGER NOT NULL CHECK (calificacion >= 1 AND calificacion <= 5),
    fecha_publicacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(curso_id, estudiante_id),
    FOREIGN KEY (curso_id) REFERENCES cursos(curso_id) ON DELETE CASCADE,
    FOREIGN KEY (estudiante_id) REFERENCES estudiantes(estudiante_id) ON DELETE CASCADE
);

-- Tabla Certificados
CREATE TABLE certificados (
    certificado_id SERIAL PRIMARY KEY,
    inscripcion_id INTEGER NOT NULL UNIQUE,
    fecha_emision TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    codigo_verificacion UUID NOT NULL DEFAULT uuid_generate_v4() UNIQUE,
    estado VARCHAR(20) NOT NULL DEFAULT 'emitido' CHECK (estado IN ('emitido', 'revocado')),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (inscripcion_id) REFERENCES inscripciones(inscripcion_id) ON DELETE CASCADE
);



-- Triggers y Funciones

-- 1. Trigger para actualizar promedio_general del estudiante
CREATE OR REPLACE FUNCTION actualizar_promedio_estudiante()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE estudiantes
    SET promedio_general = (
        SELECT AVG(calificacion_final)
        FROM inscripciones
        WHERE estudiante_id = NEW.estudiante_id
        AND calificacion_final IS NOT NULL
    )
    WHERE estudiante_id = NEW.estudiante_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_actualizar_promedio_estudiante
AFTER INSERT OR UPDATE OF calificacion_final
ON inscripciones
FOR EACH ROW
EXECUTE FUNCTION actualizar_promedio_estudiante();

-- 2. Trigger para actualizar calificación promedio del instructor
CREATE OR REPLACE FUNCTION actualizar_calificacion_instructor()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE instructores
    SET calificacion_promedio = (
        SELECT AVG(c.calificacion)
        FROM comentarios c
        INNER JOIN cursos cu ON c.curso_id = cu.curso_id
        WHERE cu.instructor_id = (
            SELECT instructor_id 
            FROM cursos 
            WHERE curso_id = NEW.curso_id
        )
    )
    WHERE instructor_id = (
        SELECT instructor_id 
        FROM cursos 
        WHERE curso_id = NEW.curso_id
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_actualizar_calificacion_instructor
AFTER INSERT OR UPDATE OF calificacion
ON comentarios
FOR EACH ROW
EXECUTE FUNCTION actualizar_calificacion_instructor();

-- 3. Trigger para actualizar automáticamente el estado de inscripción
CREATE OR REPLACE FUNCTION actualizar_estado_inscripcion()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.progreso_porcentaje = 100 THEN
        NEW.estado := 'completado';
        NEW.fecha_completado := CURRENT_TIMESTAMP;
    ELSIF NEW.progreso_porcentaje > 0 THEN
        NEW.estado := 'en_progreso';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_actualizar_estado_inscripcion
BEFORE UPDATE OF progreso_porcentaje
ON inscripciones
FOR EACH ROW
EXECUTE FUNCTION actualizar_estado_inscripcion();