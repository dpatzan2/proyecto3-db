-- Eliminar objetos existentes
DROP EXTENSION IF EXISTS "uuid-ossp" CASCADE;

DROP TYPE IF EXISTS estado_inscripcion CASCADE;
DROP TYPE IF EXISTS nivel_curso CASCADE;
DROP TYPE IF EXISTS tipo_contenido CASCADE;
DROP TYPE IF EXISTS tipo_evaluacion CASCADE;

DROP TABLE IF EXISTS certificados CASCADE;
DROP TABLE IF EXISTS comentarios CASCADE;
DROP TABLE IF EXISTS curso_habilidades CASCADE;
DROP TABLE IF EXISTS habilidades CASCADE;
DROP TABLE IF EXISTS recursos_educativos CASCADE;
DROP TABLE IF EXISTS progreso_lecciones CASCADE;
DROP TABLE IF EXISTS resultados_evaluaciones CASCADE;
DROP TABLE IF EXISTS evaluaciones CASCADE;
DROP TABLE IF EXISTS inscripciones CASCADE;
DROP TABLE IF EXISTS lecciones CASCADE;
DROP TABLE IF EXISTS modulos CASCADE;
DROP TABLE IF EXISTS cursos CASCADE;
DROP TABLE IF EXISTS instructores CASCADE;
DROP TABLE IF EXISTS estudiante_contactos CASCADE;
DROP TABLE IF EXISTS estudiantes CASCADE;

DROP TRIGGER IF EXISTS trigger_actualizar_promedio_estudiante ON inscripciones;
DROP FUNCTION IF EXISTS actualizar_promedio_estudiante() CASCADE;

DROP TRIGGER IF EXISTS trigger_actualizar_calificacion_instructor ON comentarios;
DROP FUNCTION IF EXISTS actualizar_calificacion_instructor() CASCADE;

DROP TRIGGER IF EXISTS trigger_actualizar_estado_inscripcion ON inscripciones;
DROP FUNCTION IF EXISTS actualizar_estado_inscripcion() CASCADE;

-- Extensión para UUIDs
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ENUMs
CREATE TYPE estado_inscripcion AS ENUM ('pendiente','en_progreso','completado','abandonado');
CREATE TYPE nivel_curso      AS ENUM ('principiante','intermedio','avanzado','experto');
CREATE TYPE tipo_contenido   AS ENUM ('video','lectura','quiz','tarea');
CREATE TYPE tipo_evaluacion  AS ENUM ('examen','proyecto','tarea','quiz');

-- Tabla Estudiantes
CREATE TABLE estudiantes (
  estudiante_id    SERIAL   PRIMARY KEY,
  nombre           VARCHAR(100) NOT NULL,
  apellido         VARCHAR(100) NOT NULL,
  email            VARCHAR(150) NOT NULL UNIQUE,
  fecha_nacimiento DATE NOT NULL CHECK (fecha_nacimiento <= CURRENT_DATE),
  direccion        VARCHAR(255) NOT NULL,
  fecha_registro   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  estado_activo    BOOLEAN NOT NULL DEFAULT TRUE,
  promedio_general DECIMAL(5,2) DEFAULT 0.0 CHECK (promedio_general BETWEEN 0 AND 100),
  created_at       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Atributo multivaluado: Métodos de Contacto del Estudiante
CREATE TABLE estudiante_contactos (
  contacto_id    SERIAL PRIMARY KEY,
  estudiante_id  INTEGER NOT NULL REFERENCES estudiantes(estudiante_id) ON DELETE CASCADE,
  tipo_contacto  VARCHAR(20) NOT NULL,         -- e.g. 'teléfono', 'email alternativo', 'skype'
  valor          VARCHAR(200) NOT NULL,        -- número o dirección
  created_at     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Instructores
CREATE TABLE instructores (
  instructor_id       SERIAL PRIMARY KEY,
  nombre              VARCHAR(100) NOT NULL,
  apellido            VARCHAR(100) NOT NULL,
  email               VARCHAR(150) NOT NULL UNIQUE,
  especialidad        VARCHAR(100) NOT NULL,
  biografia           TEXT NOT NULL,
  calificacion_promedio DECIMAL(5,2) DEFAULT 0.0 CHECK (calificacion_promedio BETWEEN 0 AND 5),
  fecha_contratacion  DATE NOT NULL,
  estado_activo       BOOLEAN NOT NULL DEFAULT TRUE,
  created_at          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Cursos
CREATE TABLE cursos (
  curso_id               SERIAL PRIMARY KEY,
  titulo                 VARCHAR(100) NOT NULL UNIQUE,
  descripcion            TEXT NOT NULL,
  nivel                  nivel_curso NOT NULL DEFAULT 'principiante',
  duracion_horas         INTEGER NOT NULL CHECK (duracion_horas > 0),
  precio                 DECIMAL(10,2) NOT NULL CHECK (precio >= 0),
  instructor_id          INTEGER NOT NULL REFERENCES instructores(instructor_id) ON DELETE RESTRICT,
  fecha_creacion         TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  estado_activo          BOOLEAN NOT NULL DEFAULT TRUE,
  promedio_calificaciones DECIMAL(3,2) CHECK (promedio_calificaciones BETWEEN 0 AND 5),
  created_at             TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Módulos
CREATE TABLE modulos (
  modulo_id     SERIAL PRIMARY KEY,
  curso_id      INTEGER NOT NULL REFERENCES cursos(curso_id) ON DELETE CASCADE,
  titulo        VARCHAR(100) NOT NULL,
  descripcion   TEXT NOT NULL,
  orden         INTEGER NOT NULL CHECK (orden > 0),
  duracion_horas INTEGER NOT NULL CHECK (duracion_horas > 0),
  created_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(curso_id, orden)
);

-- Lecciones
CREATE TABLE lecciones (
  leccion_id      SERIAL PRIMARY KEY,
  modulo_id       INTEGER NOT NULL REFERENCES modulos(modulo_id) ON DELETE CASCADE,
  titulo          VARCHAR(100) NOT NULL,
  contenido       TEXT NOT NULL,
  duracion_minutos INTEGER NOT NULL CHECK (duracion_minutos > 0),
  orden           INTEGER NOT NULL CHECK (orden > 0),
  tipo_contenido  tipo_contenido NOT NULL,
  created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(modulo_id, orden)
);

-- Inscripciones
CREATE TABLE inscripciones (
  inscripcion_id     SERIAL PRIMARY KEY,
  estudiante_id      INTEGER NOT NULL REFERENCES estudiantes(estudiante_id) ON DELETE RESTRICT,
  curso_id           INTEGER NOT NULL REFERENCES cursos(curso_id) ON DELETE RESTRICT,
  fecha_inscripcion  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  fecha_completado   TIMESTAMP,
  progreso_porcentaje DECIMAL(5,2) NOT NULL DEFAULT 0 CHECK (progreso_porcentaje BETWEEN 0 AND 100),
  estado             estado_inscripcion NOT NULL DEFAULT 'pendiente',
  calificacion_final DECIMAL(4,2) CHECK (calificacion_final BETWEEN 0 AND 10),
  created_at         TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(estudiante_id, curso_id)
);

-- Evaluaciones
CREATE TABLE evaluaciones (
  evaluacion_id   SERIAL PRIMARY KEY,
  curso_id        INTEGER NOT NULL REFERENCES cursos(curso_id) ON DELETE CASCADE,
  instructor_id   INTEGER NOT NULL REFERENCES instructores(instructor_id) ON DELETE CASCADE,
  titulo          VARCHAR(100) NOT NULL,
  descripcion     TEXT NOT NULL,
  tipo_evaluacion tipo_evaluacion NOT NULL,
  puntaje_maximo  INTEGER NOT NULL CHECK (puntaje_maximo > 0),
  fecha_limite    DATE NOT NULL CHECK (fecha_limite >= CURRENT_DATE),
  created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Resultados de Evaluaciones (otra tabla de cruce)
CREATE TABLE resultados_evaluaciones (
  resultado_id     SERIAL PRIMARY KEY,
  evaluacion_id    INTEGER NOT NULL REFERENCES evaluaciones(evaluacion_id) ON DELETE CASCADE,
  estudiante_id    INTEGER NOT NULL REFERENCES estudiantes(estudiante_id) ON DELETE CASCADE,
  puntaje_obtenido DECIMAL(5,2) NOT NULL CHECK (puntaje_obtenido >= 0),
  fecha_realizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  comentarios      TEXT,
  created_at       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(evaluacion_id, estudiante_id)
);

-- Progreso de Lecciones
CREATE TABLE progreso_lecciones (
  progreso_id        SERIAL PRIMARY KEY,
  inscripcion_id     INTEGER NOT NULL REFERENCES inscripciones(inscripcion_id) ON DELETE CASCADE,
  leccion_id         INTEGER NOT NULL REFERENCES lecciones(leccion_id) ON DELETE CASCADE,
  estado_completado  BOOLEAN NOT NULL DEFAULT FALSE,
  tiempo_dedicado    INTEGER NOT NULL DEFAULT 0 CHECK (tiempo_dedicado >= 0),
  ultima_visualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_at         TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(inscripcion_id, leccion_id)
);

-- Recursos Educativos
CREATE TABLE recursos_educativos (
  recurso_id    SERIAL PRIMARY KEY,
  leccion_id    INTEGER NOT NULL REFERENCES lecciones(leccion_id) ON DELETE CASCADE,
  titulo        VARCHAR(100) NOT NULL,
  tipo_recurso  VARCHAR(50) NOT NULL,
  url           VARCHAR(255) NOT NULL,
  descripcion   TEXT,
  created_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Habilidades
CREATE TABLE habilidades (
  habilidad_id SERIAL PRIMARY KEY,
  nombre        VARCHAR(50) NOT NULL UNIQUE,
  descripcion   TEXT,
  created_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Curso-Habilidades (tabla de cruce)
CREATE TABLE curso_habilidades (
  curso_id      INTEGER NOT NULL REFERENCES cursos(curso_id) ON DELETE CASCADE,
  habilidad_id  INTEGER NOT NULL REFERENCES habilidades(habilidad_id) ON DELETE CASCADE,
  nivel_requerido VARCHAR(50) NOT NULL,
  created_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY(curso_id, habilidad_id)
);

-- Comentarios
CREATE TABLE comentarios (
  comentario_id    SERIAL PRIMARY KEY,
  curso_id         INTEGER NOT NULL REFERENCES cursos(curso_id) ON DELETE CASCADE,
  estudiante_id    INTEGER NOT NULL REFERENCES estudiantes(estudiante_id) ON DELETE CASCADE,
  contenido        TEXT NOT NULL,
  calificacion     INTEGER NOT NULL CHECK (calificacion BETWEEN 1 AND 5),
  fecha_publicacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_at       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(curso_id, estudiante_id)
);

-- Certificados
CREATE TABLE certificados (
  certificado_id     SERIAL PRIMARY KEY,
  inscripcion_id     INTEGER NOT NULL REFERENCES inscripciones(inscripcion_id) ON DELETE CASCADE UNIQUE,
  fecha_emision      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  codigo_verificacion UUID NOT NULL DEFAULT uuid_generate_v4() UNIQUE,
  estado             VARCHAR(20) NOT NULL DEFAULT 'emitido'
                         CHECK (estado IN ('emitido','revocado')),
  created_at         TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- ========== Triggers / Funciones ==========

-- 1) Actualiza promedio_general del estudiante
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
END; $$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_actualizar_promedio_estudiante
  AFTER INSERT OR UPDATE OF calificacion_final
  ON inscripciones
  FOR EACH ROW EXECUTE FUNCTION actualizar_promedio_estudiante();

-- 2) Actualiza calificacion_promedio del instructor
CREATE OR REPLACE FUNCTION actualizar_calificacion_instructor()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE instructores
  SET calificacion_promedio = (
    SELECT AVG(c.calificacion)
    FROM comentarios c
      JOIN cursos cu ON c.curso_id = cu.curso_id
    WHERE cu.instructor_id = 
      (SELECT instructor_id FROM cursos WHERE curso_id = NEW.curso_id)
  )
  WHERE instructor_id = 
    (SELECT instructor_id FROM cursos WHERE curso_id = NEW.curso_id);
  RETURN NEW;
END; $$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_actualizar_calificacion_instructor
  AFTER INSERT OR UPDATE OF calificacion
  ON comentarios
  FOR EACH ROW EXECUTE FUNCTION actualizar_calificacion_instructor();

-- 3) Estado automático de la inscripción
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
END; $$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_actualizar_estado_inscripcion
  BEFORE UPDATE OF progreso_porcentaje
  ON inscripciones
  FOR EACH ROW EXECUTE FUNCTION actualizar_estado_inscripcion();

-- 4) Atributo derivado: total_lecciones por curso (vista)
CREATE VIEW vista_total_lecciones AS
SELECT
  c.curso_id,
  COUNT(l.leccion_id) AS total_lecciones
FROM cursos c
LEFT JOIN modulos m ON m.curso_id = c.curso_id
LEFT JOIN lecciones l ON l.modulo_id = m.modulo_id
GROUP BY c.curso_id;
