"""Run each query in sql/ against the raw CSVs with DuckDB and print the results.

Usage (from anywhere):  python sql/run_queries.py

00_setup.sql creates the views the queries read; every other numbered file is one query.
The raw data itself is tested by dbt (dbt/models/staging/sources.yml and dbt/tests/).
"""
import os
import pathlib

import duckdb

SQL_DIR = pathlib.Path(__file__).resolve().parent


def main():
    os.chdir(SQL_DIR.parent)             # CSV paths in 00_setup.sql are relative to the repo root
    con = duckdb.connect()               # in-memory: nothing to install or clean up
    con.execute((SQL_DIR / '00_setup.sql').read_text())

    for path in sorted(SQL_DIR.glob('[0-9]*.sql')):
        if path.name == '00_setup.sql':
            continue
        df = con.sql(path.read_text()).df()
        print(f'\n=== {path.name}  ({len(df)} rows)')
        print(df.to_string(index=False) if len(df) else '(no rows)')


if __name__ == '__main__':
    main()
