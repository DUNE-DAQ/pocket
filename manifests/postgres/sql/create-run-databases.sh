#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
CREATE DATABASE run_database;
\c run_database;

CREATE SCHEMA run_schema;

CREATE TABLE run_schema.run_registry_meta(
    run_number INT PRIMARY KEY NOT NULL,
    start_time TIMESTAMP (6) NOT NULL,
    stop_time TIMESTAMP (6),
    detector_id VARCHAR (40) NOT NULL,
    run_type VARCHAR (40) NOT NULL,
    filename VARCHAR (100) NOT NULL,
    software_version VARCHAR (40)
);

CREATE UNIQUE INDEX run_registry_meta_pk ON run_schema.run_registry_meta (run_number);

CREATE TABLE run_schema.run_registry_configs(
  run_number INT NOT NULL,
  configuration BYTEA NOT NULL,
  CONSTRAINT run_registry_meta_pk
    FOREIGN KEY(run_number)
       REFERENCES run_schema.run_registry_meta(run_number)
);

\dt+ run_schema.*

EOSQL