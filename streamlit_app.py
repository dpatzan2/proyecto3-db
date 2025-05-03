import streamlit as st

# ─── 1. Configurar página ───────────────────────────────────────────────────
st.set_page_config(
    page_title="Reportes Plataforma",
    layout="wide",
    initial_sidebar_state="expanded"
)

# ─── 2. Crear conexión a la DB ─────────────────────────────────────────────
# Usa el alias "postgresql" definido en .streamlit/secrets.toml
conn = st.connection("postgresql", type="sql")

@st.cache_data(ttl=600)
def run_query(query: str):
    """
    Ejecuta la consulta SQL y devuelve un DataFrame de pandas.
    """
    return conn.query(query)

# ─── 3. Menú lateral ─────────────────────────────────────────────────────────
st.sidebar.title("Reportes")
page = st.sidebar.radio("Ir a:", [
    "1. Inscripciones",
    "2. Progreso Cursos",
    "3. Top Estudiantes",
    "4. Actividad Lecciones",
    "5. Ingresos Cursos"
])

# ─── 4. Despacho a páginas ───────────────────────────────────────────────────
if page == "1. Inscripciones":
    import reportes_pages._01_inscripciones as mod
    mod.main(run_query)
elif page == "2. Progreso Cursos":
    import reportes_pages._02_progreso as mod
    mod.main(run_query)
elif page == "3. Top Estudiantes":
    import reportes_pages._03_top_estudiantes as mod
    mod.main(run_query)
elif page == "4. Actividad Lecciones":
    import reportes_pages._04_actividad_lecciones as mod
    mod.main(run_query)
elif page == "5. Ingresos Cursos":
    import reportes_pages._05_ingresos as mod
    mod.main(run_query)
