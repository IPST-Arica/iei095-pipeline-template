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
dbt-run:
	docker compose run --rm pipeline bash -c "cd dbt_project && dbt run --profiles-dir ."

dbt-test:
	docker compose run --rm pipeline bash -c "cd dbt_project && dbt test --profiles-dir ."

dbt-docs:
	docker compose run --rm -p 8080:8080 pipeline bash -c "cd dbt_project && dbt docs generate --profiles-dir . && dbt docs serve --profiles-dir . --port 8080 --host 0.0.0.0"
