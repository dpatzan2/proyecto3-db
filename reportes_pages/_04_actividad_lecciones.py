import streamlit as st
import pandas as pd

def main(run_query):
    st.header("4. Actividad de lecciones (rango de tiempo promedio)")

    # Filtros de texto/número
    min_tiempo = st.number_input("Tiempo promedio mínimo (min)", min_value=0.0, max_value=999.0, value=10.0)
    max_tiempo = st.number_input("Tiempo promedio máximo (min)", min_value=0.0, max_value=999.0, value=60.0)
    fecha_inicio = st.date_input("Fecha inicio")
    fecha_fin    = st.date_input("Fecha fin", value=pd.Timestamp.today())

    # Consulta: sin filtrar por curso_id, usando HAVING
    query = f"""
        SELECT
          m.curso_id,
          l.titulo AS leccion,
          ROUND(AVG(pl.tiempo_dedicado),2) AS tiempo_promedio,
          COUNT(pl.progreso_id) AS vistas
        FROM progreso_lecciones pl
        JOIN lecciones l     USING(leccion_id)
        JOIN modulos m       USING(modulo_id)
        WHERE pl.ultima_visualizacion BETWEEN '{fecha_inicio}' AND '{fecha_fin}'
        GROUP BY m.curso_id, l.titulo
        HAVING AVG(pl.tiempo_dedicado) BETWEEN {min_tiempo} AND {max_tiempo}
        ORDER BY tiempo_promedio DESC
    """
    df = run_query(query)

    st.markdown(
        f"**Lecciones con tiempo promedio entre {min_tiempo} y {max_tiempo} minutos**"
    )
    st.dataframe(df)
