--
-- PostgreSQL database dump
--

-- Dumped from database version 11.10
-- Dumped by pg_dump version 13.2

-- Started on 2021-08-25 13:30:44

--- CREATE DATABASE "DbDQMMonitoring";
--- SET search_path = "DbDQMMonitoring";

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

\c DbDQMMonitoring

--
-- TOC entry 205 (class 1259 OID 17271)
-- Name: Analyse; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public."Analyse" (
    "Id" uuid NOT NULL,
    "AnalysisSourceId" uuid,
    "DataId" uuid,
    "Running" real NOT NULL,
    "Name" character varying(50),
    "Description" character varying(250)
);


ALTER TABLE public."Analyse" OWNER TO admin;

--
-- TOC entry 208 (class 1259 OID 17314)
-- Name: AnalysisPannel; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public."AnalysisPannel" (
    "Id" uuid NOT NULL,
    "PannelId" uuid,
    "AnalyseId" uuid,
    "DataDisplayId" uuid
);


ALTER TABLE public."AnalysisPannel" OWNER TO admin;

--
-- TOC entry 209 (class 1259 OID 17334)
-- Name: AnalysisParameter; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public."AnalysisParameter" (
    "Id" uuid NOT NULL,
    "ParameterId" uuid,
    "AnalyseId" uuid,
    "Degree" real NOT NULL,
    "Interval" integer NOT NULL,
    "Type" text
);


ALTER TABLE public."AnalysisParameter" OWNER TO admin;

--
-- TOC entry 211 (class 1259 OID 17367)
-- Name: AnalysisResult; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public."AnalysisResult" (
    "Id" uuid NOT NULL,
    "AnalysisParameterId" uuid,
    "DataPathId" uuid,
    "Decision" text,
    "Confidence" real NOT NULL
);


ALTER TABLE public."AnalysisResult" OWNER TO admin;

--
-- TOC entry 197 (class 1259 OID 17210)
-- Name: AnalysisSource; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public."AnalysisSource" (
    "Id" uuid NOT NULL,
    "Name" character varying(50) NOT NULL,
    "Description" character varying(250)
);


ALTER TABLE public."AnalysisSource" OWNER TO admin;

--
-- TOC entry 203 (class 1259 OID 17240)
-- Name: Data; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public."Data" (
    "Id" uuid NOT NULL,
    "DataSourceId" uuid,
    "RententionTime" text NOT NULL,
    "Name" text NOT NULL
);


ALTER TABLE public."Data" OWNER TO admin;

--
-- TOC entry 204 (class 1259 OID 17253)
-- Name: DataDisplay; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public."DataDisplay" (
    "Id" uuid NOT NULL,
    "DataTypeId" uuid,
    "SamplingProfileId" uuid,
    "PlotLength" integer NOT NULL,
    "Name" text NOT NULL
);


ALTER TABLE public."DataDisplay" OWNER TO admin;

--
-- TOC entry 210 (class 1259 OID 17352)
-- Name: DataDisplayAnalyse; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public."DataDisplayAnalyse" (
    "Id" uuid NOT NULL,
    "AnalyseId" uuid,
    "DataDisplayId" uuid
);


ALTER TABLE public."DataDisplayAnalyse" OWNER TO admin;

--
-- TOC entry 207 (class 1259 OID 17299)
-- Name: DataDisplayData; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public."DataDisplayData" (
    "Id" uuid NOT NULL,
    "DataId" uuid,
    "DataDisplayId" uuid
);


ALTER TABLE public."DataDisplayData" OWNER TO admin;

--
-- TOC entry 206 (class 1259 OID 17286)
-- Name: DataPaths; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public."DataPaths" (
    "Id" uuid NOT NULL,
    "DataId" uuid,
    "WriteTime" text NOT NULL,
    "Path" character varying(256),
    "Storage" character varying(30),
    "Run" integer NOT NULL,
    "SubRun" integer NOT NULL,
    "EventNumber" integer NOT NULL
);


ALTER TABLE public."DataPaths" OWNER TO admin;

--
-- TOC entry 198 (class 1259 OID 17215)
-- Name: DataSources; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public."DataSources" (
    "Id" uuid NOT NULL,
    "Source" character varying(50) NOT NULL,
    "Description" character varying(250)
);


ALTER TABLE public."DataSources" OWNER TO admin;

--
-- TOC entry 199 (class 1259 OID 17220)
-- Name: DataType; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public."DataType" (
    "Id" uuid NOT NULL,
    "Name" character varying(50) NOT NULL,
    "PlottingType" character varying(50) NOT NULL,
    "Description" character varying(200)
);


ALTER TABLE public."DataType" OWNER TO admin;

--
-- TOC entry 200 (class 1259 OID 17225)
-- Name: Pannel; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public."Pannel" (
    "Id" uuid NOT NULL,
    "Name" character varying(50) NOT NULL,
    "Description" character varying(250)
);


ALTER TABLE public."Pannel" OWNER TO admin;

--
-- TOC entry 201 (class 1259 OID 17230)
-- Name: Parameter; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public."Parameter" (
    "Id" uuid NOT NULL,
    "Name" character varying(50) NOT NULL,
    "Factor" real NOT NULL
);


ALTER TABLE public."Parameter" OWNER TO admin;

--
-- TOC entry 202 (class 1259 OID 17235)
-- Name: SamplingProfile; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public."SamplingProfile" (
    "Id" uuid NOT NULL,
    "Name" character varying(50) NOT NULL,
    "PlottingType" character varying(50),
    "Description" character varying(200) NOT NULL,
    "Factor" real NOT NULL
);


ALTER TABLE public."SamplingProfile" OWNER TO admin;

--
-- TOC entry 196 (class 1259 OID 17205)
-- Name: __EFMigrationsHistory; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public."__EFMigrationsHistory" (
    "MigrationId" character varying(150) NOT NULL,
    "ProductVersion" character varying(32) NOT NULL
);


ALTER TABLE public."__EFMigrationsHistory" OWNER TO admin;

--
-- TOC entry 3219 (class 0 OID 17271)
-- Dependencies: 205
-- Data for Name: Analyse; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public."Analyse" ("Id", "AnalysisSourceId", "DataId", "Running", "Name", "Description") FROM stdin;
\.


--
-- TOC entry 3222 (class 0 OID 17314)
-- Dependencies: 208
-- Data for Name: AnalysisPannel; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public."AnalysisPannel" ("Id", "PannelId", "AnalyseId", "DataDisplayId") FROM stdin;
\.


--
-- TOC entry 3223 (class 0 OID 17334)
-- Dependencies: 209
-- Data for Name: AnalysisParameter; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public."AnalysisParameter" ("Id", "ParameterId", "AnalyseId", "Degree", "Interval", "Type") FROM stdin;
\.


--
-- TOC entry 3225 (class 0 OID 17367)
-- Dependencies: 211
-- Data for Name: AnalysisResult; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public."AnalysisResult" ("Id", "AnalysisParameterId", "DataPathId", "Decision", "Confidence") FROM stdin;
\.


--
-- TOC entry 3211 (class 0 OID 17210)
-- Dependencies: 197
-- Data for Name: AnalysisSource; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public."AnalysisSource" ("Id", "Name", "Description") FROM stdin;
\.


--
-- TOC entry 3217 (class 0 OID 17240)
-- Dependencies: 203
-- Data for Name: Data; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public."Data" ("Id", "DataSourceId", "RententionTime", "Name") FROM stdin;
\.


--
-- TOC entry 3218 (class 0 OID 17253)
-- Dependencies: 204
-- Data for Name: DataDisplay; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public."DataDisplay" ("Id", "DataTypeId", "SamplingProfileId", "PlotLength", "Name") FROM stdin;
\.


--
-- TOC entry 3224 (class 0 OID 17352)
-- Dependencies: 210
-- Data for Name: DataDisplayAnalyse; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public."DataDisplayAnalyse" ("Id", "AnalyseId", "DataDisplayId") FROM stdin;
\.


--
-- TOC entry 3221 (class 0 OID 17299)
-- Dependencies: 207
-- Data for Name: DataDisplayData; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public."DataDisplayData" ("Id", "DataId", "DataDisplayId") FROM stdin;
\.


--
-- TOC entry 3220 (class 0 OID 17286)
-- Dependencies: 206
-- Data for Name: DataPaths; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public."DataPaths" ("Id", "DataId", "WriteTime", "Path", "Storage", "Run", "SubRun", "EventNumber") FROM stdin;
\.


--
-- TOC entry 3212 (class 0 OID 17215)
-- Dependencies: 198
-- Data for Name: DataSources; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public."DataSources" ("Id", "Source", "Description") FROM stdin;
\.


--
-- TOC entry 3213 (class 0 OID 17220)
-- Dependencies: 199
-- Data for Name: DataType; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public."DataType" ("Id", "Name", "PlottingType", "Description") FROM stdin;
8d83a885-c0aa-4d36-ab49-a93c8525d3f5	Heatmap plot	heatmap	Default heatmap plotting
b0ab9f47-bd2a-462b-aa24-fb52b7184885	Histogram plot	histogram	Default histogram plotting
7592e161-e925-4d58-9c68-0f93431e439c	Scatter plot with lines and markers	lines+markers	Default scatter plotting, Scatter plot with lines and markers
34e44dd0-7219-493e-8cd9-c63d8a0387e3	Scatter plot with lines	lines	Scatter plot without markers (lines only)
0e14499d-8106-4c05-953f-e52a5f91da8b	Scatter plot with markers	markers	Scatter plot without lines (markers only)
\.


--
-- TOC entry 3214 (class 0 OID 17225)
-- Dependencies: 200
-- Data for Name: Pannel; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public."Pannel" ("Id", "Name", "Description") FROM stdin;
\.


--
-- TOC entry 3215 (class 0 OID 17230)
-- Dependencies: 201
-- Data for Name: Parameter; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public."Parameter" ("Id", "Name", "Factor") FROM stdin;
\.


--
-- TOC entry 3216 (class 0 OID 17235)
-- Dependencies: 202
-- Data for Name: SamplingProfile; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public."SamplingProfile" ("Id", "Name", "PlottingType", "Description", "Factor") FROM stdin;
c7b9ec99-1a44-4ef5-8b89-f6a0404fb4d4	Default	Default	Default 1:1 sampling	1
\.


--
-- TOC entry 3210 (class 0 OID 17205)
-- Dependencies: 196
-- Data for Name: __EFMigrationsHistory; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public."__EFMigrationsHistory" ("MigrationId", "ProductVersion") FROM stdin;
20210730141657_initSeed	3.1.15
\.


--
-- TOC entry 3047 (class 2606 OID 17275)
-- Name: Analyse PK_Analyse; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public."Analyse"
    ADD CONSTRAINT "PK_Analyse" PRIMARY KEY ("Id");


--
-- TOC entry 3059 (class 2606 OID 17318)
-- Name: AnalysisPannel PK_AnalysisPannel; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public."AnalysisPannel"
    ADD CONSTRAINT "PK_AnalysisPannel" PRIMARY KEY ("Id");


--
-- TOC entry 3063 (class 2606 OID 17341)
-- Name: AnalysisParameter PK_AnalysisParameter; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public."AnalysisParameter"
    ADD CONSTRAINT "PK_AnalysisParameter" PRIMARY KEY ("Id");


--
-- TOC entry 3071 (class 2606 OID 17374)
-- Name: AnalysisResult PK_AnalysisResult; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public."AnalysisResult"
    ADD CONSTRAINT "PK_AnalysisResult" PRIMARY KEY ("Id");


--
-- TOC entry 3026 (class 2606 OID 17214)
-- Name: AnalysisSource PK_AnalysisSource; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public."AnalysisSource"
    ADD CONSTRAINT "PK_AnalysisSource" PRIMARY KEY ("Id");


--
-- TOC entry 3039 (class 2606 OID 17247)
-- Name: Data PK_Data; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public."Data"
    ADD CONSTRAINT "PK_Data" PRIMARY KEY ("Id");


--
-- TOC entry 3043 (class 2606 OID 17260)
-- Name: DataDisplay PK_DataDisplay; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public."DataDisplay"
    ADD CONSTRAINT "PK_DataDisplay" PRIMARY KEY ("Id");


--
-- TOC entry 3067 (class 2606 OID 17356)
-- Name: DataDisplayAnalyse PK_DataDisplayAnalyse; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public."DataDisplayAnalyse"
    ADD CONSTRAINT "PK_DataDisplayAnalyse" PRIMARY KEY ("Id");


--
-- TOC entry 3054 (class 2606 OID 17303)
-- Name: DataDisplayData PK_DataDisplayData; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public."DataDisplayData"
    ADD CONSTRAINT "PK_DataDisplayData" PRIMARY KEY ("Id");


--
-- TOC entry 3050 (class 2606 OID 17293)
-- Name: DataPaths PK_DataPaths; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public."DataPaths"
    ADD CONSTRAINT "PK_DataPaths" PRIMARY KEY ("Id");


--
-- TOC entry 3028 (class 2606 OID 17219)
-- Name: DataSources PK_DataSources; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public."DataSources"
    ADD CONSTRAINT "PK_DataSources" PRIMARY KEY ("Id");


--
-- TOC entry 3030 (class 2606 OID 17224)
-- Name: DataType PK_DataType; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public."DataType"
    ADD CONSTRAINT "PK_DataType" PRIMARY KEY ("Id");


--
-- TOC entry 3032 (class 2606 OID 17229)
-- Name: Pannel PK_Pannel; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public."Pannel"
    ADD CONSTRAINT "PK_Pannel" PRIMARY KEY ("Id");


--
-- TOC entry 3034 (class 2606 OID 17234)
-- Name: Parameter PK_Parameter; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public."Parameter"
    ADD CONSTRAINT "PK_Parameter" PRIMARY KEY ("Id");


--
-- TOC entry 3036 (class 2606 OID 17239)
-- Name: SamplingProfile PK_SamplingProfile; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public."SamplingProfile"
    ADD CONSTRAINT "PK_SamplingProfile" PRIMARY KEY ("Id");


--
-- TOC entry 3024 (class 2606 OID 17209)
-- Name: __EFMigrationsHistory PK___EFMigrationsHistory; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public."__EFMigrationsHistory"
    ADD CONSTRAINT "PK___EFMigrationsHistory" PRIMARY KEY ("MigrationId");


--
-- TOC entry 3044 (class 1259 OID 17385)
-- Name: IX_Analyse_AnalysisSourceId; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX "IX_Analyse_AnalysisSourceId" ON public."Analyse" USING btree ("AnalysisSourceId");


--
-- TOC entry 3045 (class 1259 OID 17386)
-- Name: IX_Analyse_DataId; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX "IX_Analyse_DataId" ON public."Analyse" USING btree ("DataId");


--
-- TOC entry 3055 (class 1259 OID 17387)
-- Name: IX_AnalysisPannel_AnalyseId; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX "IX_AnalysisPannel_AnalyseId" ON public."AnalysisPannel" USING btree ("AnalyseId");


--
-- TOC entry 3056 (class 1259 OID 17388)
-- Name: IX_AnalysisPannel_DataDisplayId; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX "IX_AnalysisPannel_DataDisplayId" ON public."AnalysisPannel" USING btree ("DataDisplayId");


--
-- TOC entry 3057 (class 1259 OID 17389)
-- Name: IX_AnalysisPannel_PannelId; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX "IX_AnalysisPannel_PannelId" ON public."AnalysisPannel" USING btree ("PannelId");


--
-- TOC entry 3060 (class 1259 OID 17390)
-- Name: IX_AnalysisParameter_AnalyseId; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX "IX_AnalysisParameter_AnalyseId" ON public."AnalysisParameter" USING btree ("AnalyseId");


--
-- TOC entry 3061 (class 1259 OID 17391)
-- Name: IX_AnalysisParameter_ParameterId; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX "IX_AnalysisParameter_ParameterId" ON public."AnalysisParameter" USING btree ("ParameterId");


--
-- TOC entry 3068 (class 1259 OID 17392)
-- Name: IX_AnalysisResult_AnalysisParameterId; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX "IX_AnalysisResult_AnalysisParameterId" ON public."AnalysisResult" USING btree ("AnalysisParameterId");


--
-- TOC entry 3069 (class 1259 OID 17393)
-- Name: IX_AnalysisResult_DataPathId; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX "IX_AnalysisResult_DataPathId" ON public."AnalysisResult" USING btree ("DataPathId");


--
-- TOC entry 3064 (class 1259 OID 17397)
-- Name: IX_DataDisplayAnalyse_AnalyseId; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX "IX_DataDisplayAnalyse_AnalyseId" ON public."DataDisplayAnalyse" USING btree ("AnalyseId");


--
-- TOC entry 3065 (class 1259 OID 17398)
-- Name: IX_DataDisplayAnalyse_DataDisplayId; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX "IX_DataDisplayAnalyse_DataDisplayId" ON public."DataDisplayAnalyse" USING btree ("DataDisplayId");


--
-- TOC entry 3051 (class 1259 OID 17399)
-- Name: IX_DataDisplayData_DataDisplayId; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX "IX_DataDisplayData_DataDisplayId" ON public."DataDisplayData" USING btree ("DataDisplayId");


--
-- TOC entry 3052 (class 1259 OID 17400)
-- Name: IX_DataDisplayData_DataId; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX "IX_DataDisplayData_DataId" ON public."DataDisplayData" USING btree ("DataId");


--
-- TOC entry 3040 (class 1259 OID 17395)
-- Name: IX_DataDisplay_DataTypeId; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX "IX_DataDisplay_DataTypeId" ON public."DataDisplay" USING btree ("DataTypeId");


--
-- TOC entry 3041 (class 1259 OID 17396)
-- Name: IX_DataDisplay_SamplingProfileId; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX "IX_DataDisplay_SamplingProfileId" ON public."DataDisplay" USING btree ("SamplingProfileId");


--
-- TOC entry 3048 (class 1259 OID 17401)
-- Name: IX_DataPaths_DataId; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX "IX_DataPaths_DataId" ON public."DataPaths" USING btree ("DataId");


--
-- TOC entry 3037 (class 1259 OID 17394)
-- Name: IX_Data_DataSourceId; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX "IX_Data_DataSourceId" ON public."Data" USING btree ("DataSourceId");


--
-- TOC entry 3075 (class 2606 OID 17276)
-- Name: Analyse FK_Analyse_AnalysisSource_AnalysisSourceId; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public."Analyse"
    ADD CONSTRAINT "FK_Analyse_AnalysisSource_AnalysisSourceId" FOREIGN KEY ("AnalysisSourceId") REFERENCES public."AnalysisSource"("Id") ON DELETE CASCADE;


--
-- TOC entry 3076 (class 2606 OID 17281)
-- Name: Analyse FK_Analyse_Data_DataId; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public."Analyse"
    ADD CONSTRAINT "FK_Analyse_Data_DataId" FOREIGN KEY ("DataId") REFERENCES public."Data"("Id") ON DELETE CASCADE;


--
-- TOC entry 3080 (class 2606 OID 17319)
-- Name: AnalysisPannel FK_AnalysisPannel_Analyse_AnalyseId; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public."AnalysisPannel"
    ADD CONSTRAINT "FK_AnalysisPannel_Analyse_AnalyseId" FOREIGN KEY ("AnalyseId") REFERENCES public."Analyse"("Id") ON DELETE RESTRICT;


--
-- TOC entry 3081 (class 2606 OID 17324)
-- Name: AnalysisPannel FK_AnalysisPannel_DataDisplay_DataDisplayId; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public."AnalysisPannel"
    ADD CONSTRAINT "FK_AnalysisPannel_DataDisplay_DataDisplayId" FOREIGN KEY ("DataDisplayId") REFERENCES public."DataDisplay"("Id") ON DELETE CASCADE;


--
-- TOC entry 3082 (class 2606 OID 17329)
-- Name: AnalysisPannel FK_AnalysisPannel_Pannel_PannelId; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public."AnalysisPannel"
    ADD CONSTRAINT "FK_AnalysisPannel_Pannel_PannelId" FOREIGN KEY ("PannelId") REFERENCES public."Pannel"("Id") ON DELETE CASCADE;


--
-- TOC entry 3083 (class 2606 OID 17342)
-- Name: AnalysisParameter FK_AnalysisParameter_Analyse_AnalyseId; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public."AnalysisParameter"
    ADD CONSTRAINT "FK_AnalysisParameter_Analyse_AnalyseId" FOREIGN KEY ("AnalyseId") REFERENCES public."Analyse"("Id") ON DELETE CASCADE;


--
-- TOC entry 3084 (class 2606 OID 17347)
-- Name: AnalysisParameter FK_AnalysisParameter_Parameter_ParameterId; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public."AnalysisParameter"
    ADD CONSTRAINT "FK_AnalysisParameter_Parameter_ParameterId" FOREIGN KEY ("ParameterId") REFERENCES public."Parameter"("Id") ON DELETE CASCADE;


--
-- TOC entry 3087 (class 2606 OID 17375)
-- Name: AnalysisResult FK_AnalysisResult_AnalysisParameter_AnalysisParameterId; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public."AnalysisResult"
    ADD CONSTRAINT "FK_AnalysisResult_AnalysisParameter_AnalysisParameterId" FOREIGN KEY ("AnalysisParameterId") REFERENCES public."AnalysisParameter"("Id") ON DELETE RESTRICT;


--
-- TOC entry 3088 (class 2606 OID 17380)
-- Name: AnalysisResult FK_AnalysisResult_DataPaths_DataPathId; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public."AnalysisResult"
    ADD CONSTRAINT "FK_AnalysisResult_DataPaths_DataPathId" FOREIGN KEY ("DataPathId") REFERENCES public."DataPaths"("Id") ON DELETE CASCADE;


--
-- TOC entry 3085 (class 2606 OID 17357)
-- Name: DataDisplayAnalyse FK_DataDisplayAnalyse_Analyse_AnalyseId; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public."DataDisplayAnalyse"
    ADD CONSTRAINT "FK_DataDisplayAnalyse_Analyse_AnalyseId" FOREIGN KEY ("AnalyseId") REFERENCES public."Analyse"("Id") ON DELETE CASCADE;


--
-- TOC entry 3086 (class 2606 OID 17362)
-- Name: DataDisplayAnalyse FK_DataDisplayAnalyse_DataDisplay_DataDisplayId; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public."DataDisplayAnalyse"
    ADD CONSTRAINT "FK_DataDisplayAnalyse_DataDisplay_DataDisplayId" FOREIGN KEY ("DataDisplayId") REFERENCES public."DataDisplay"("Id") ON DELETE CASCADE;


--
-- TOC entry 3078 (class 2606 OID 17304)
-- Name: DataDisplayData FK_DataDisplayData_DataDisplay_DataDisplayId; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public."DataDisplayData"
    ADD CONSTRAINT "FK_DataDisplayData_DataDisplay_DataDisplayId" FOREIGN KEY ("DataDisplayId") REFERENCES public."DataDisplay"("Id") ON DELETE CASCADE;


--
-- TOC entry 3079 (class 2606 OID 17309)
-- Name: DataDisplayData FK_DataDisplayData_Data_DataId; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public."DataDisplayData"
    ADD CONSTRAINT "FK_DataDisplayData_Data_DataId" FOREIGN KEY ("DataId") REFERENCES public."Data"("Id") ON DELETE CASCADE;


--
-- TOC entry 3073 (class 2606 OID 17261)
-- Name: DataDisplay FK_DataDisplay_DataType_DataTypeId; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public."DataDisplay"
    ADD CONSTRAINT "FK_DataDisplay_DataType_DataTypeId" FOREIGN KEY ("DataTypeId") REFERENCES public."DataType"("Id") ON DELETE CASCADE;


--
-- TOC entry 3074 (class 2606 OID 17266)
-- Name: DataDisplay FK_DataDisplay_SamplingProfile_SamplingProfileId; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public."DataDisplay"
    ADD CONSTRAINT "FK_DataDisplay_SamplingProfile_SamplingProfileId" FOREIGN KEY ("SamplingProfileId") REFERENCES public."SamplingProfile"("Id") ON DELETE CASCADE;


--
-- TOC entry 3077 (class 2606 OID 17294)
-- Name: DataPaths FK_DataPaths_Data_DataId; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public."DataPaths"
    ADD CONSTRAINT "FK_DataPaths_Data_DataId" FOREIGN KEY ("DataId") REFERENCES public."Data"("Id") ON DELETE CASCADE;


--
-- TOC entry 3072 (class 2606 OID 17248)
-- Name: Data FK_Data_DataSources_DataSourceId; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public."Data"
    ADD CONSTRAINT "FK_Data_DataSources_DataSourceId" FOREIGN KEY ("DataSourceId") REFERENCES public."DataSources"("Id") ON DELETE CASCADE;


-- Completed on 2021-08-25 13:30:45

--
-- PostgreSQL database dump complete
--

