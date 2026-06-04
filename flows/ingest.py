import polars as pl
from prefect import task, flow

@task(name="ingest-superstore")
def ingest_data() -> pl.DataFrame:
    """
    Lee el CSV crudo con Polars, aplica limpieza básica
    y persiste en formato Parquet (columnar y comprimido).
    """
    df = pl.read_csv(
        "data/raw/superstore.csv",
        infer_schema_length=10000,
        null_values=["", "N/A"]
    )

    df = (
        df
        # Convertir la columna 'Order Date' de string a tipo Date
        .with_columns(
            pl.col("Order Date").str.to_date("%Y-%m-%d")
        )
        # Renombrar 'Row ID' a snake_case para compatibilidad con dbt
        .rename({"Row ID": "row_id", "Order ID": "order_id"})
        # Filtrar registros con Sales <= 0 (datos inválidos)
        .filter(pl.col("Sales") > 0)
        # Eliminar duplicados exactos
        .unique()
    )

    # Guardar en formato Parquet: ~5x más rápido de leer que CSV
    df.write_parquet("data/raw/superstore_clean.parquet")

    print(f"✅ Ingesta completada: {df.shape[0]} filas, {df.shape[1]} columnas")
    return df

@flow(name="Ingest Superstore")
def ingest_flow():
    ingest_data()

if __name__ == "__main__":
    ingest_flow()
