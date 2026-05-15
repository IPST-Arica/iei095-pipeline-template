.PHONY: build verify ingest pipeline dashboard jupyter clean

build:
	docker compose build

verify:
	docker compose run --rm pipeline python --version
	docker compose run --rm pipeline python -c "import polars, duckdb, prefect, dash; print('✅ Todas las librerías OK')"

ingest:
	docker compose run --rm pipeline python -m flows.ingest

pipeline:
	docker compose run --rm pipeline python -m flows.pipeline

dashboard:
	docker compose up dashboard

jupyter:
	docker compose up jupyter

clean:
	rm -f data/raw/*.parquet
	rm -f data/transformed/*.duckdb
	rm -rf dbt_project/target/ dbt_project/logs/
