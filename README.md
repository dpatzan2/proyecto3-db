# Plataforma de cursos y seguimiento de estudiantes

Bienvenido a Plataforma de Reportes y Seguimiento de Estudiantes, una aplicación web diseñada para facilitar el análisis en tiempo real del rendimiento académico y la actividad de usuarios en un entorno formativo.

---

## 📂 Estructura del Proyecto

```text
.PROYECTO3-DB/                ← Carpeta raíz del proyecto
├── .streamlit/                     ← Configuración de Streamlit
│   └── secrets.toml                ← Plantilla de credenciales (sin datos reales)
├── data/                           ← Scripts SQL de DDL
│   └── DDL.sql                     ← Definición de esquema
├── sql/                            ← Script SQL de DATA
│   └── DATA.sql                    ← Inserts de prueba (100 registros)
├── reportes_pages/                 ← Páginas de Streamlit (reportes)
│   ├── _01_inscripciones.py        ← Reporte 1: Inscripciones
│   ├── _02_progreso.py             ← Reporte 2: Progreso promedio
│   ├── _03_top_estudiantes.py      ← Reporte 3: Top estudiantes
│   ├── _04_actividad_lecciones.py  ← Reporte 4: Actividad de lecciones
│   └── _05_ingresos.py             ← Reporte 5: Ingresos por curso
├── venv/                           ← Entorno virtual (no subir a Git)
├── streamlit_app.py                ← Punto de entrada y dispatcher de páginas
├── requirements.txt                ← Lista de dependencias pip
├── .gitignore                      ← Archivos/directorios a ignorar
└── README.md                       ← Documentación del proyecto

```
---

## 🧩 Indice
1. Requisitos previos

2. Clonar el repositorio

3. Configuración del entorno virtual

4. Instalación de dependencias

5. Ejecutar DDL y cargar datos de prueba

6. Configurar credenciales de la base de datos

7. Levantar la aplicación Streamlit

---

## 1 Requisitos previos
- Python 3.8+ instalado y accesible desde la línea de comandos.

- PostgreSQL (versión 12+) con acceso de superusuario o permisos para crear esquemas.

- pgAdmin 4 (opcional, para verificar tablas y datos).

- Git instalado para gestionar el repositorio.

## 2 Clonar el repositorio

`git clone https://github.com/dpatzan2/proyecto3-db`

## 3. Configuración del entorno virtual

3.1. Crea el entorno virtual en la carpeta `venv/`:
   - `python -m venv venv`

3.2. Activalo:
   - Windows:
       - `venv\Scripts\activate`
    
  - Linux/Mac:
       - `source venv/bin/activate`

Tras esto, tu prompt mostrará `(venv)` al inicio.

## 4. Instalación de dependencias
Con el entorno activado, instala todo lo necesario:

```
pip install --upgrade pip
pip install -r requirements.txt
```

El archivo `requirements.txt` incluye:

```
streamlit>=1.20
sqlalchemy>=1.4
psycopg2-binary>=2.9
pandas>=1.5
plotly>=5.6
```


## 5. Ejecutar DDL y cargar datos de 

5.1. Conecta con una nueva base de datos con el nombre que desees en PgAdmin

5.2. Abre los archivos `DDL` y `DATA` que estan en las carpetas `sql/` y `data/` respecivamente y correlos en PgAdmin

5.3. Verifica en pgAdmin que las tablas (`inscripciones`, `cursos`, etc.) existen y contienen datos.

## 6. Configurar credenciales de la base de datos

En `.streamlit/secrets.toml` esta un ejemplo de la conexión el cual debera llenar con datos los datos respectivos:

#### .streamlit/secrets.toml
```
[connections.postgresql]
dialect  = "postgresql"
host     = "TU_HOST"        # e.g. localhost
port     = "5432"
database = "TU_BASE_DATOS"  # e.g. Proyecto3
username = "TU_USUARIO"     # e.g. postgres
password = "TU_CONTRASEÑA"  # Tu contraseña de conexión de PgAdmin
```

## 7 Levantar la aplicación Streamlit

7.1. Asegúrate de que el entorno virtual sigue activo.

7.2. Desde la raíz del proyecto, lanza:

   - `streamlit run streamlit_app.py`

7.3. Abre tu navegador en la URL que Streamlit imprima (por defecto http://localhost:8501).
En la barra lateral podrás seleccionar los reportes:

  - Inscripciones

  - Progreso Cursos

  - Top Estudiantes

  - Actividad Lecciones

  - Ingresos Cursos

Cada reporte se calculará en tiempo real con los filtros que indiques.
