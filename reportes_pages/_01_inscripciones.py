import streamlit as st
import pandas as pd

def main(run_query):
    st.header("1. Inscripciones por rango de fechas")

    # Filtros
    fecha_inicio  = st.date_input("Fecha inicio")
    fecha_fin     = st.date_input("Fecha fin", value=pd.Timestamp.today())
    estado        = st.selectbox("Estado", ['pendiente','en_progreso','completado','abandonado'])
    max_registros = st.slider("Máximo registros", min_value=10, max_value=100, value=5, step=5)

    # Consulta
    query = f"""
        SELECT estudiante_id, curso_id, fecha_inscripcion, progreso_porcentaje, estado
        FROM inscripciones
        WHERE fecha_inscripcion BETWEEN '{fecha_inicio}' AND '{fecha_fin}'
          AND estado = '{estado}'
        ORDER BY fecha_inscripcion DESC
        LIMIT {max_registros}
    """
    df = run_query(query)
    st.dataframe(df)
