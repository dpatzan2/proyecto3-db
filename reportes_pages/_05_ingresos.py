import streamlit as st
import pandas as pd

def main(run_query):
    st.header("5. Ingresos por curso (rango de precio)")

    fecha_inicio = st.date_input("Fecha inicio")
    fecha_fin    = st.date_input("Fecha fin", value=pd.Timestamp.today())
    min_precio   = st.number_input("Precio mínimo", min_value=0.0, max_value=10000.0, value=0.0, step=1.0)
    max_precio   = st.number_input("Precio máximo", min_value=0.0, max_value=10000.0, value=500.0, step=1.0)

    query = f"""
        SELECT
          c.curso_id,
          c.titulo AS curso,
          ROUND(SUM(c.precio),2) AS total_ingresos,
          c.precio AS precio_unitario
        FROM inscripciones i
        JOIN cursos c USING(curso_id)
        WHERE i.fecha_inscripcion BETWEEN '{fecha_inicio}' AND '{fecha_fin}'
          AND c.precio BETWEEN {min_precio} AND {max_precio}
        GROUP BY c.curso_id, c.titulo, c.precio
        ORDER BY total_ingresos DESC
    """
    df = run_query(query)

    st.markdown(f"**Cursos con precio entre {min_precio} y {max_precio}**")
    st.dataframe(df[['curso_id','curso','precio_unitario','total_ingresos']])

    st.markdown("### Gráfico de ingresos")
    st.line_chart(df.set_index('curso')['total_ingresos'])
