import streamlit as st
import pandas as pd

def main(run_query):
    st.header("3. Top estudiantes por calificación final")

    # Filtros
    fecha_inicio  = st.date_input("Fecha inicio")
    fecha_fin     = st.date_input("Fecha fin", value=pd.Timestamp.today())
    min_calif     = st.slider("Calificación mínima", min_value=0.0, max_value=10.0, value=8.0)
    top_n         = st.number_input("Número de estudiantes", min_value=1, max_value=100, value=10)

    # Consulta
    query = f"""
        SELECT e.nombre || ' ' || e.apellido AS estudiante,
               i.calificacion_final
        FROM inscripciones i
        JOIN estudiantes e ON i.estudiante_id = e.estudiante_id
        WHERE i.fecha_inscripcion BETWEEN '{fecha_inicio}' AND '{fecha_fin}'
          AND i.calificacion_final >= {min_calif}
        ORDER BY i.calificacion_final DESC
        LIMIT {top_n}
    """
    df = run_query(query)
    st.table(df)
