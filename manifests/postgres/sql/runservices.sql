--
-- PostgreSQL database dump
--

-- Dumped from database version 12.8 (Debian 12.8-1.pgdg110+1)
-- Dumped by pg_dump version 12.8 (Debian 12.8-1.pgdg110+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: run_database; Type: DATABASE; Owner: admin
--

CREATE DATABASE run_database;
\connect run_database; 

--
-- Name: run_schema; Type: SCHEMA; Schema: -; Owner: admin
--

CREATE SCHEMA run_schema;


ALTER SCHEMA run_schema OWNER TO admin;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: run_number; Type: TABLE; Schema: run_schema; Owner: admin
--

CREATE TABLE run_schema.run_number (
    rn integer NOT NULL,
    start_time timestamp(6) without time zone NOT NULL,
    flag boolean NOT NULL,
    stop_time timestamp(6) without time zone
);


ALTER TABLE run_schema.run_number OWNER TO admin;

--
-- Name: run_registry_configs; Type: TABLE; Schema: run_schema; Owner: admin
--

CREATE TABLE run_schema.run_registry_configs (
    run_number integer NOT NULL,
    configuration bytea NOT NULL
);


ALTER TABLE run_schema.run_registry_configs OWNER TO admin;

--
-- Name: run_registry_meta; Type: TABLE; Schema: run_schema; Owner: admin
--

CREATE TABLE run_schema.run_registry_meta (
    run_number integer NOT NULL,
    start_time timestamp(6) without time zone NOT NULL,
    stop_time timestamp(6) without time zone,
    detector_id character varying(40) NOT NULL,
    run_type character varying(40) NOT NULL,
    filename character varying(100) NOT NULL,
    software_version character varying(40)
);


ALTER TABLE run_schema.run_registry_meta OWNER TO admin;

--
-- Name: run_number run_number_pkey; Type: CONSTRAINT; Schema: run_schema; Owner: admin
--

ALTER TABLE ONLY run_schema.run_number
    ADD CONSTRAINT run_number_pkey PRIMARY KEY (rn);


--
-- Name: run_registry_meta run_registry_meta_pkey; Type: CONSTRAINT; Schema: run_schema; Owner: admin
--

ALTER TABLE ONLY run_schema.run_registry_meta
    ADD CONSTRAINT run_registry_meta_pkey PRIMARY KEY (run_number);


--
-- Name: run_registry_meta_pk; Type: INDEX; Schema: run_schema; Owner: admin
--

CREATE UNIQUE INDEX run_registry_meta_pk ON run_schema.run_registry_meta USING btree (run_number);


--
-- Name: run_registry_configs run_registry_meta_pk; Type: FK CONSTRAINT; Schema: run_schema; Owner: admin
--

ALTER TABLE ONLY run_schema.run_registry_configs
    ADD CONSTRAINT run_registry_meta_pk FOREIGN KEY (run_number) REFERENCES run_schema.run_registry_meta(run_number);


--
-- PostgreSQL database dump complete
--

