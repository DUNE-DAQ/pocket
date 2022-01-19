--
-- PostgreSQL database dump
--

-- Dumped from database version 11.10
-- Dumped by pg_dump version 14.1

-- Started on 2022-01-19 15:14:52

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

--
-- TOC entry 205 (class 1259 OID 18275)
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
-- TOC entry 208 (class 1259 OID 18318)
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
-- TOC entry 209 (class 1259 OID 18338)
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
-- TOC entry 211 (class 1259 OID 18371)
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
-- TOC entry 197 (class 1259 OID 18214)
-- Name: AnalysisSource; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public."AnalysisSource" (
    "Id" uuid NOT NULL,
    "Name" character varying(50) NOT NULL,
    "Description" character varying(250)
);


ALTER TABLE public."AnalysisSource" OWNER TO admin;

--
-- TOC entry 203 (class 1259 OID 18244)
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
-- TOC entry 212 (class 1259 OID 20809)
-- Name: DataAnalyse; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public."DataAnalyse" (
    "Id" uuid NOT NULL,
    "AnalyseId" uuid,
    "DataId" uuid,
    description text,
    channel integer NOT NULL,
    "dataDisplayId" uuid
);


ALTER TABLE public."DataAnalyse" OWNER TO admin;

--
-- TOC entry 204 (class 1259 OID 18257)
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
-- TOC entry 210 (class 1259 OID 18356)
-- Name: DataDisplayAnalyse; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public."DataDisplayAnalyse" (
    "Id" uuid NOT NULL,
    "AnalyseId" uuid,
    "DataDisplayId" uuid
);


ALTER TABLE public."DataDisplayAnalyse" OWNER TO admin;

--
-- TOC entry 207 (class 1259 OID 18303)
-- Name: DataDisplayData; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public."DataDisplayData" (
    "Id" uuid NOT NULL,
    "DataId" uuid,
    "DataDisplayId" uuid
);


ALTER TABLE public."DataDisplayData" OWNER TO admin;

--
-- TOC entry 206 (class 1259 OID 18290)
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
-- TOC entry 198 (class 1259 OID 18219)
-- Name: DataSources; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public."DataSources" (
    "Id" uuid NOT NULL,
    "Source" character varying(50) NOT NULL,
    "Description" character varying(250)
);


ALTER TABLE public."DataSources" OWNER TO admin;

--
-- TOC entry 199 (class 1259 OID 18224)
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
-- TOC entry 200 (class 1259 OID 18229)
-- Name: Pannel; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public."Pannel" (
    "Id" uuid NOT NULL,
    "Name" character varying(50) NOT NULL,
    "Description" character varying(250)
);


ALTER TABLE public."Pannel" OWNER TO admin;

--
-- TOC entry 201 (class 1259 OID 18234)
-- Name: Parameter; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public."Parameter" (
    "Id" uuid NOT NULL,
    "Name" character varying(50) NOT NULL,
    "Factor" real NOT NULL
);


ALTER TABLE public."Parameter" OWNER TO admin;

--
-- TOC entry 202 (class 1259 OID 18239)
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
-- TOC entry 196 (class 1259 OID 18209)
-- Name: __EFMigrationsHistory; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public."__EFMigrationsHistory" (
    "MigrationId" character varying(150) NOT NULL,
    "ProductVersion" character varying(32) NOT NULL
);


ALTER TABLE public."__EFMigrationsHistory" OWNER TO admin;

--
-- TOC entry 3052 (class 2606 OID 18279)
-- Name: Analyse PK_Analyse; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public."Analyse"
    ADD CONSTRAINT "PK_Analyse" PRIMARY KEY ("Id");


--
-- TOC entry 3064 (class 2606 OID 18322)
-- Name: AnalysisPannel PK_AnalysisPannel; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public."AnalysisPannel"
    ADD CONSTRAINT "PK_AnalysisPannel" PRIMARY KEY ("Id");


--
-- TOC entry 3068 (class 2606 OID 18345)
-- Name: AnalysisParameter PK_AnalysisParameter; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public."AnalysisParameter"
    ADD CONSTRAINT "PK_AnalysisParameter" PRIMARY KEY ("Id");


--
-- TOC entry 3076 (class 2606 OID 18378)
-- Name: AnalysisResult PK_AnalysisResult; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public."AnalysisResult"
    ADD CONSTRAINT "PK_AnalysisResult" PRIMARY KEY ("Id");


--
-- TOC entry 3031 (class 2606 OID 18218)
-- Name: AnalysisSource PK_AnalysisSource; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public."AnalysisSource"
    ADD CONSTRAINT "PK_AnalysisSource" PRIMARY KEY ("Id");


--
-- TOC entry 3044 (class 2606 OID 18251)
-- Name: Data PK_Data; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public."Data"
    ADD CONSTRAINT "PK_Data" PRIMARY KEY ("Id");


--
-- TOC entry 3081 (class 2606 OID 20816)
-- Name: DataAnalyse PK_DataAnalyse; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public."DataAnalyse"
    ADD CONSTRAINT "PK_DataAnalyse" PRIMARY KEY ("Id");


--
-- TOC entry 3048 (class 2606 OID 18264)
-- Name: DataDisplay PK_DataDisplay; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public."DataDisplay"
    ADD CONSTRAINT "PK_DataDisplay" PRIMARY KEY ("Id");


--
-- TOC entry 3072 (class 2606 OID 18360)
-- Name: DataDisplayAnalyse PK_DataDisplayAnalyse; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public."DataDisplayAnalyse"
    ADD CONSTRAINT "PK_DataDisplayAnalyse" PRIMARY KEY ("Id");


--
-- TOC entry 3059 (class 2606 OID 18307)
-- Name: DataDisplayData PK_DataDisplayData; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public."DataDisplayData"
    ADD CONSTRAINT "PK_DataDisplayData" PRIMARY KEY ("Id");


--
-- TOC entry 3055 (class 2606 OID 18297)
-- Name: DataPaths PK_DataPaths; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public."DataPaths"
    ADD CONSTRAINT "PK_DataPaths" PRIMARY KEY ("Id");


--
-- TOC entry 3033 (class 2606 OID 18223)
-- Name: DataSources PK_DataSources; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public."DataSources"
    ADD CONSTRAINT "PK_DataSources" PRIMARY KEY ("Id");


--
-- TOC entry 3035 (class 2606 OID 18228)
-- Name: DataType PK_DataType; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public."DataType"
    ADD CONSTRAINT "PK_DataType" PRIMARY KEY ("Id");


--
-- TOC entry 3037 (class 2606 OID 18233)
-- Name: Pannel PK_Pannel; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public."Pannel"
    ADD CONSTRAINT "PK_Pannel" PRIMARY KEY ("Id");


--
-- TOC entry 3039 (class 2606 OID 18238)
-- Name: Parameter PK_Parameter; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public."Parameter"
    ADD CONSTRAINT "PK_Parameter" PRIMARY KEY ("Id");


--
-- TOC entry 3041 (class 2606 OID 18243)
-- Name: SamplingProfile PK_SamplingProfile; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public."SamplingProfile"
    ADD CONSTRAINT "PK_SamplingProfile" PRIMARY KEY ("Id");


--
-- TOC entry 3029 (class 2606 OID 18213)
-- Name: __EFMigrationsHistory PK___EFMigrationsHistory; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public."__EFMigrationsHistory"
    ADD CONSTRAINT "PK___EFMigrationsHistory" PRIMARY KEY ("MigrationId");


--
-- TOC entry 3049 (class 1259 OID 18389)
-- Name: IX_Analyse_AnalysisSourceId; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX "IX_Analyse_AnalysisSourceId" ON public."Analyse" USING btree ("AnalysisSourceId");


--
-- TOC entry 3050 (class 1259 OID 18390)
-- Name: IX_Analyse_DataId; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX "IX_Analyse_DataId" ON public."Analyse" USING btree ("DataId");


--
-- TOC entry 3060 (class 1259 OID 18391)
-- Name: IX_AnalysisPannel_AnalyseId; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX "IX_AnalysisPannel_AnalyseId" ON public."AnalysisPannel" USING btree ("AnalyseId");


--
-- TOC entry 3061 (class 1259 OID 18392)
-- Name: IX_AnalysisPannel_DataDisplayId; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX "IX_AnalysisPannel_DataDisplayId" ON public."AnalysisPannel" USING btree ("DataDisplayId");


--
-- TOC entry 3062 (class 1259 OID 18393)
-- Name: IX_AnalysisPannel_PannelId; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX "IX_AnalysisPannel_PannelId" ON public."AnalysisPannel" USING btree ("PannelId");


--
-- TOC entry 3065 (class 1259 OID 18394)
-- Name: IX_AnalysisParameter_AnalyseId; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX "IX_AnalysisParameter_AnalyseId" ON public."AnalysisParameter" USING btree ("AnalyseId");


--
-- TOC entry 3066 (class 1259 OID 18395)
-- Name: IX_AnalysisParameter_ParameterId; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX "IX_AnalysisParameter_ParameterId" ON public."AnalysisParameter" USING btree ("ParameterId");


--
-- TOC entry 3073 (class 1259 OID 18396)
-- Name: IX_AnalysisResult_AnalysisParameterId; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX "IX_AnalysisResult_AnalysisParameterId" ON public."AnalysisResult" USING btree ("AnalysisParameterId");


--
-- TOC entry 3074 (class 1259 OID 18397)
-- Name: IX_AnalysisResult_DataPathId; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX "IX_AnalysisResult_DataPathId" ON public."AnalysisResult" USING btree ("DataPathId");


--
-- TOC entry 3077 (class 1259 OID 20827)
-- Name: IX_DataAnalyse_AnalyseId; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX "IX_DataAnalyse_AnalyseId" ON public."DataAnalyse" USING btree ("AnalyseId");


--
-- TOC entry 3078 (class 1259 OID 20828)
-- Name: IX_DataAnalyse_DataId; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX "IX_DataAnalyse_DataId" ON public."DataAnalyse" USING btree ("DataId");


--
-- TOC entry 3079 (class 1259 OID 20829)
-- Name: IX_DataAnalyse_dataDisplayId; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX "IX_DataAnalyse_dataDisplayId" ON public."DataAnalyse" USING btree ("dataDisplayId");


--
-- TOC entry 3069 (class 1259 OID 18401)
-- Name: IX_DataDisplayAnalyse_AnalyseId; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX "IX_DataDisplayAnalyse_AnalyseId" ON public."DataDisplayAnalyse" USING btree ("AnalyseId");


--
-- TOC entry 3070 (class 1259 OID 18402)
-- Name: IX_DataDisplayAnalyse_DataDisplayId; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX "IX_DataDisplayAnalyse_DataDisplayId" ON public."DataDisplayAnalyse" USING btree ("DataDisplayId");


--
-- TOC entry 3056 (class 1259 OID 18403)
-- Name: IX_DataDisplayData_DataDisplayId; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX "IX_DataDisplayData_DataDisplayId" ON public."DataDisplayData" USING btree ("DataDisplayId");


--
-- TOC entry 3057 (class 1259 OID 18404)
-- Name: IX_DataDisplayData_DataId; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX "IX_DataDisplayData_DataId" ON public."DataDisplayData" USING btree ("DataId");


--
-- TOC entry 3045 (class 1259 OID 18399)
-- Name: IX_DataDisplay_DataTypeId; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX "IX_DataDisplay_DataTypeId" ON public."DataDisplay" USING btree ("DataTypeId");


--
-- TOC entry 3046 (class 1259 OID 18400)
-- Name: IX_DataDisplay_SamplingProfileId; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX "IX_DataDisplay_SamplingProfileId" ON public."DataDisplay" USING btree ("SamplingProfileId");


--
-- TOC entry 3053 (class 1259 OID 18405)
-- Name: IX_DataPaths_DataId; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX "IX_DataPaths_DataId" ON public."DataPaths" USING btree ("DataId");


--
-- TOC entry 3042 (class 1259 OID 18398)
-- Name: IX_Data_DataSourceId; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX "IX_Data_DataSourceId" ON public."Data" USING btree ("DataSourceId");


--
-- TOC entry 3085 (class 2606 OID 18280)
-- Name: Analyse FK_Analyse_AnalysisSource_AnalysisSourceId; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public."Analyse"
    ADD CONSTRAINT "FK_Analyse_AnalysisSource_AnalysisSourceId" FOREIGN KEY ("AnalysisSourceId") REFERENCES public."AnalysisSource"("Id") ON DELETE CASCADE;


--
-- TOC entry 3086 (class 2606 OID 18285)
-- Name: Analyse FK_Analyse_Data_DataId; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public."Analyse"
    ADD CONSTRAINT "FK_Analyse_Data_DataId" FOREIGN KEY ("DataId") REFERENCES public."Data"("Id") ON DELETE CASCADE;


--
-- TOC entry 3090 (class 2606 OID 18323)
-- Name: AnalysisPannel FK_AnalysisPannel_Analyse_AnalyseId; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public."AnalysisPannel"
    ADD CONSTRAINT "FK_AnalysisPannel_Analyse_AnalyseId" FOREIGN KEY ("AnalyseId") REFERENCES public."Analyse"("Id") ON DELETE RESTRICT;


--
-- TOC entry 3091 (class 2606 OID 18328)
-- Name: AnalysisPannel FK_AnalysisPannel_DataDisplay_DataDisplayId; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public."AnalysisPannel"
    ADD CONSTRAINT "FK_AnalysisPannel_DataDisplay_DataDisplayId" FOREIGN KEY ("DataDisplayId") REFERENCES public."DataDisplay"("Id") ON DELETE CASCADE;


--
-- TOC entry 3092 (class 2606 OID 18333)
-- Name: AnalysisPannel FK_AnalysisPannel_Pannel_PannelId; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public."AnalysisPannel"
    ADD CONSTRAINT "FK_AnalysisPannel_Pannel_PannelId" FOREIGN KEY ("PannelId") REFERENCES public."Pannel"("Id") ON DELETE CASCADE;


--
-- TOC entry 3093 (class 2606 OID 18346)
-- Name: AnalysisParameter FK_AnalysisParameter_Analyse_AnalyseId; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public."AnalysisParameter"
    ADD CONSTRAINT "FK_AnalysisParameter_Analyse_AnalyseId" FOREIGN KEY ("AnalyseId") REFERENCES public."Analyse"("Id") ON DELETE CASCADE;


--
-- TOC entry 3094 (class 2606 OID 18351)
-- Name: AnalysisParameter FK_AnalysisParameter_Parameter_ParameterId; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public."AnalysisParameter"
    ADD CONSTRAINT "FK_AnalysisParameter_Parameter_ParameterId" FOREIGN KEY ("ParameterId") REFERENCES public."Parameter"("Id") ON DELETE CASCADE;


--
-- TOC entry 3097 (class 2606 OID 18379)
-- Name: AnalysisResult FK_AnalysisResult_AnalysisParameter_AnalysisParameterId; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public."AnalysisResult"
    ADD CONSTRAINT "FK_AnalysisResult_AnalysisParameter_AnalysisParameterId" FOREIGN KEY ("AnalysisParameterId") REFERENCES public."AnalysisParameter"("Id") ON DELETE RESTRICT;


--
-- TOC entry 3098 (class 2606 OID 18384)
-- Name: AnalysisResult FK_AnalysisResult_DataPaths_DataPathId; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public."AnalysisResult"
    ADD CONSTRAINT "FK_AnalysisResult_DataPaths_DataPathId" FOREIGN KEY ("DataPathId") REFERENCES public."DataPaths"("Id") ON DELETE CASCADE;


--
-- TOC entry 3099 (class 2606 OID 20817)
-- Name: DataAnalyse FK_DataAnalyse_Analyse_AnalyseId; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public."DataAnalyse"
    ADD CONSTRAINT "FK_DataAnalyse_Analyse_AnalyseId" FOREIGN KEY ("AnalyseId") REFERENCES public."Analyse"("Id") ON DELETE RESTRICT;


--
-- TOC entry 3100 (class 2606 OID 20822)
-- Name: DataAnalyse FK_DataAnalyse_DataDisplay_DataId; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public."DataAnalyse"
    ADD CONSTRAINT "FK_DataAnalyse_DataDisplay_DataId" FOREIGN KEY ("DataId") REFERENCES public."DataDisplay"("Id") ON DELETE RESTRICT;


--
-- TOC entry 3102 (class 2606 OID 20835)
-- Name: DataAnalyse FK_DataAnalyse_DataDisplay_dataDisplayId; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public."DataAnalyse"
    ADD CONSTRAINT "FK_DataAnalyse_DataDisplay_dataDisplayId" FOREIGN KEY ("dataDisplayId") REFERENCES public."DataDisplay"("Id") ON DELETE RESTRICT;


--
-- TOC entry 3101 (class 2606 OID 20830)
-- Name: DataAnalyse FK_DataAnalyse_Data_DataId; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public."DataAnalyse"
    ADD CONSTRAINT "FK_DataAnalyse_Data_DataId" FOREIGN KEY ("DataId") REFERENCES public."Data"("Id") ON DELETE RESTRICT;


--
-- TOC entry 3095 (class 2606 OID 18361)
-- Name: DataDisplayAnalyse FK_DataDisplayAnalyse_Analyse_AnalyseId; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public."DataDisplayAnalyse"
    ADD CONSTRAINT "FK_DataDisplayAnalyse_Analyse_AnalyseId" FOREIGN KEY ("AnalyseId") REFERENCES public."Analyse"("Id") ON DELETE CASCADE;


--
-- TOC entry 3096 (class 2606 OID 18366)
-- Name: DataDisplayAnalyse FK_DataDisplayAnalyse_DataDisplay_DataDisplayId; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public."DataDisplayAnalyse"
    ADD CONSTRAINT "FK_DataDisplayAnalyse_DataDisplay_DataDisplayId" FOREIGN KEY ("DataDisplayId") REFERENCES public."DataDisplay"("Id") ON DELETE CASCADE;


--
-- TOC entry 3088 (class 2606 OID 18308)
-- Name: DataDisplayData FK_DataDisplayData_DataDisplay_DataDisplayId; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public."DataDisplayData"
    ADD CONSTRAINT "FK_DataDisplayData_DataDisplay_DataDisplayId" FOREIGN KEY ("DataDisplayId") REFERENCES public."DataDisplay"("Id") ON DELETE CASCADE;


--
-- TOC entry 3089 (class 2606 OID 18313)
-- Name: DataDisplayData FK_DataDisplayData_Data_DataId; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public."DataDisplayData"
    ADD CONSTRAINT "FK_DataDisplayData_Data_DataId" FOREIGN KEY ("DataId") REFERENCES public."Data"("Id") ON DELETE CASCADE;


--
-- TOC entry 3083 (class 2606 OID 18265)
-- Name: DataDisplay FK_DataDisplay_DataType_DataTypeId; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public."DataDisplay"
    ADD CONSTRAINT "FK_DataDisplay_DataType_DataTypeId" FOREIGN KEY ("DataTypeId") REFERENCES public."DataType"("Id") ON DELETE CASCADE;


--
-- TOC entry 3084 (class 2606 OID 18270)
-- Name: DataDisplay FK_DataDisplay_SamplingProfile_SamplingProfileId; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public."DataDisplay"
    ADD CONSTRAINT "FK_DataDisplay_SamplingProfile_SamplingProfileId" FOREIGN KEY ("SamplingProfileId") REFERENCES public."SamplingProfile"("Id") ON DELETE CASCADE;


--
-- TOC entry 3087 (class 2606 OID 18298)
-- Name: DataPaths FK_DataPaths_Data_DataId; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public."DataPaths"
    ADD CONSTRAINT "FK_DataPaths_Data_DataId" FOREIGN KEY ("DataId") REFERENCES public."Data"("Id") ON DELETE CASCADE;


--
-- TOC entry 3082 (class 2606 OID 18252)
-- Name: Data FK_Data_DataSources_DataSourceId; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public."Data"
    ADD CONSTRAINT "FK_Data_DataSources_DataSourceId" FOREIGN KEY ("DataSourceId") REFERENCES public."DataSources"("Id") ON DELETE CASCADE;


-- Completed on 2022-01-19 15:14:54

--
-- PostgreSQL database dump complete
--

