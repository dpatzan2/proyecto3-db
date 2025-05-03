import streamlit as st
import pandas as pd

def main(run_query):
    st.header("2. Progreso promedio de cursos (rango)")

    # Filtros
    fecha_inicio     = st.date_input("Fecha inicio")
    fecha_fin        = st.date_input("Fecha fin", value=pd.Timestamp.today())
    min_progreso_pct = st.number_input("Progreso mínimo (%)", min_value=0, max_value=100, value=25)
    max_progreso_pct = st.number_input("Progreso máximo (%)", min_value=0, max_value=100, value=75)

    # Consulta con BETWEEN en HAVING
    query = f"""
        SELECT
          c.titulo AS curso,
          ROUND(AVG(i.progreso_porcentaje),2) AS progreso_promedio
        FROM inscripciones i
        JOIN cursos c USING(curso_id)
        WHERE i.fecha_inscripcion BETWEEN '{fecha_inicio}' AND '{fecha_fin}'
        GROUP BY c.titulo
        HAVING AVG(i.progreso_porcentaje) BETWEEN {min_progreso_pct} AND {max_progreso_pct}
        ORDER BY progreso_promedio DESC
    """
    df = run_query(query)

    st.markdown(
        f"**Cursos con progreso promedio entre {min_progreso_pct}% y {max_progreso_pct}%**"
    )
    st.dataframe(df)
