CREATE DATABASE timescaledb_datasource
WITH ENGINE = 'timescaledb',
PARAMETERS = {
  "host": "timescaledb",
  "port": 5432,
  "user": "postgres",
  "password": "password",
  "database": "mydb",
  "schema": "public"
};