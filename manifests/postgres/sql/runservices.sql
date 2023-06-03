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
-- Name: runservices; Type: DATABASE; Schema: -; Owner: admin
--

CREATE DATABASE runservices WITH TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'en_US.utf8' LC_CTYPE = 'en_US.utf8';


ALTER DATABASE runservices OWNER TO admin;

\connect runservices

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

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: run_number; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.run_number (
    run_number integer NOT NULL,
    start_time timestamp(6) without time zone NOT NULL,
    flag integer DEFAULT 0 NOT NULL,
    stop_time timestamp(6) without time zone NOT NULL
);


ALTER TABLE public.run_number OWNER TO admin;

--
-- Name: run_registry_configs; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.run_registry_configs (
    run_number integer NOT NULL,
    configuration bytea NOT NULL
);

ALTER TABLE public.run_registry_configs OWNER TO admin;

--
-- Name: run_registry_meta; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.run_registry_meta (
    run_number integer NOT NULL,
    start_time timestamp(6) without time zone NOT NULL,
    stop_time timestamp(6) without time zone,
    detector_id character varying(40) NOT NULL,
    run_type character varying(40) NOT NULL,
    filename character varying(100) NOT NULL,
    software_version character varying(40)
);


ALTER TABLE public.run_registry_meta OWNER TO admin;

--
-- Data for Name: run_number; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.run_number (run_number, start_time, flag, stop_time) FROM stdin;
\.


--
-- Data for Name: run_registry_configs; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.run_registry_configs (run_number, configuration) FROM stdin;
\.


--
-- Data for Name: run_registry_meta; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.run_registry_meta (run_number, start_time, stop_time, detector_id, run_type, filename, software_version) FROM stdin;
\.


--
-- Name: run_registry_meta run_registry_meta_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.run_registry_meta
    ADD CONSTRAINT run_registry_meta_pkey PRIMARY KEY (run_number);


--
-- Name: run_registry_meta_pk; Type: INDEX; Schema: public; Owner: admin
--

CREATE UNIQUE INDEX run_registry_meta_pk ON public.run_registry_meta USING btree (run_number);


--
-- Name: run_registry_configs run_registry_configs_fk1; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.run_registry_configs
    ADD CONSTRAINT run_registry_configs_fk1 FOREIGN KEY (run_number) REFERENCES public.run_registry_meta(run_number);


--
-- PostgreSQL database dump complete
--

