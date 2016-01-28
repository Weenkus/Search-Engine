--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: fuzzystrmatch; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS fuzzystrmatch WITH SCHEMA public;


--
-- Name: EXTENSION fuzzystrmatch; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION fuzzystrmatch IS 'determine similarities and distance between strings';


--
-- Name: pg_trgm; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA public;


--
-- Name: EXTENSION pg_trgm; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pg_trgm IS 'text similarity measurement and index searching based on trigrams';


--
-- Name: tablefunc; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS tablefunc WITH SCHEMA public;


--
-- Name: EXTENSION tablefunc; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION tablefunc IS 'functions that manipulate whole tables, including crosstab';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: documents; Type: TABLE; Schema: public; Owner: weenkus; Tablespace: 
--

CREATE TABLE documents (
    id integer NOT NULL,
    text character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    texttsv tsvector
);


ALTER TABLE documents OWNER TO weenkus;

--
-- Name: documents_id_seq; Type: SEQUENCE; Schema: public; Owner: weenkus
--

CREATE SEQUENCE documents_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE documents_id_seq OWNER TO weenkus;

--
-- Name: documents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: weenkus
--

ALTER SEQUENCE documents_id_seq OWNED BY documents.id;


--
-- Name: records; Type: TABLE; Schema: public; Owner: weenkus; Tablespace: 
--

CREATE TABLE records (
    id integer NOT NULL,
    search character varying,
    "time" timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    count integer
);


ALTER TABLE records OWNER TO weenkus;

--
-- Name: records_id_seq; Type: SEQUENCE; Schema: public; Owner: weenkus
--

CREATE SEQUENCE records_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE records_id_seq OWNER TO weenkus;

--
-- Name: records_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: weenkus
--

ALTER SEQUENCE records_id_seq OWNED BY records.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: weenkus; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying NOT NULL
);


ALTER TABLE schema_migrations OWNER TO weenkus;

--
-- Name: id; Type: DEFAULT; Schema: public; Owner: weenkus
--

ALTER TABLE ONLY documents ALTER COLUMN id SET DEFAULT nextval('documents_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: weenkus
--

ALTER TABLE ONLY records ALTER COLUMN id SET DEFAULT nextval('records_id_seq'::regclass);


--
-- Data for Name: documents; Type: TABLE DATA; Schema: public; Owner: weenkus
--

COPY documents (id, text, created_at, updated_at, texttsv) FROM stdin;
1	How much duck are there?	2015-10-27 15:31:09.203447	2015-10-27 15:31:09.203447	'How' 'are' 'duck' 'much' 'there?'
2	Today is a beautiful day.	2015-11-01 13:53:38.009198	2015-11-01 13:53:38.009198	'Today' 'a' 'beautiful' 'day.' 'is'
\.


--
-- Name: documents_id_seq; Type: SEQUENCE SET; Schema: public; Owner: weenkus
--

SELECT pg_catalog.setval('documents_id_seq', 2, true);


--
-- Data for Name: records; Type: TABLE DATA; Schema: public; Owner: weenkus
--

COPY records (id, search, "time", created_at, updated_at, count) FROM stdin;
1	'Home & is' | 'duck'	\N	2015-10-27 15:33:50.80329	2015-10-27 15:33:50.80329	\N
2	'duck'	\N	2015-10-27 15:35:41.110083	2015-10-27 15:39:24.155793	1
3	'is & a'	2015-10-29 12:13:07.442742	2015-10-29 12:13:07.464717	2015-10-29 12:13:07.464717	1
4	'duck'	2015-10-29 12:13:16.495581	2015-10-29 12:13:16.496678	2015-10-29 12:13:16.496678	1
5	'duck'	2015-10-29 20:10:55.809608	2015-10-29 20:10:55.816853	2015-10-29 20:10:55.816853	1
6	'duck'	2015-10-29 20:11:02.543839	2015-10-29 20:11:02.544464	2015-10-29 20:11:02.544464	1
7	'Today & is & a & beautiful & day'	2015-10-30 16:53:12.574846	2015-10-30 16:53:12.583133	2015-10-30 16:53:12.583133	1
8	'today & and' | 'beautiful'	2015-10-30 16:53:32.320761	2015-10-30 16:53:32.321392	2015-10-30 16:53:32.321392	1
9	'duck'	2015-10-30 17:39:09.371801	2015-10-30 17:39:09.378225	2015-10-30 17:39:09.378225	1
10	'beautiful'	2015-10-30 22:03:29.873386	2015-10-30 22:03:29.881121	2015-10-30 22:03:29.881121	1
11	'duck'	2015-10-30 22:14:03.970589	2015-10-30 22:14:03.977149	2015-10-30 22:14:03.977149	1
12	'mouse'	2015-11-01 12:22:50.968732	2015-11-01 12:22:51.105571	2015-11-01 12:22:51.105571	1
13	'duck'	2015-11-01 12:23:00.667673	2015-11-01 12:23:00.669174	2015-11-01 12:23:00.669174	1
14	'mouse'	2015-11-01 12:28:23.597623	2015-11-01 12:28:23.598809	2015-11-01 12:28:23.598809	1
15	'today' | 'duck'	2015-11-01 13:53:52.68889	2015-11-01 13:53:52.69606	2015-11-01 13:53:52.69606	1
16	'Hello & World' & 'Ancient' & 'Paradise'	2015-11-01 14:05:20.087776	2015-11-01 14:05:20.088385	2015-11-01 14:05:20.088385	1
17	'duck'	2015-11-01 14:26:40.61462	2015-11-01 14:26:40.622904	2015-11-01 14:26:40.622904	1
\.


--
-- Name: records_id_seq; Type: SEQUENCE SET; Schema: public; Owner: weenkus
--

SELECT pg_catalog.setval('records_id_seq', 17, true);


--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: public; Owner: weenkus
--

COPY schema_migrations (version) FROM stdin;
0
20151022180149
20151027141359
20151027143259
\.


--
-- Name: documents_pkey; Type: CONSTRAINT; Schema: public; Owner: weenkus; Tablespace: 
--

ALTER TABLE ONLY documents
    ADD CONSTRAINT documents_pkey PRIMARY KEY (id);


--
-- Name: records_pkey; Type: CONSTRAINT; Schema: public; Owner: weenkus; Tablespace: 
--

ALTER TABLE ONLY records
    ADD CONSTRAINT records_pkey PRIMARY KEY (id);


--
-- Name: idxtsvec; Type: INDEX; Schema: public; Owner: weenkus; Tablespace: 
--

CREATE INDEX idxtsvec ON documents USING gin (texttsv);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: weenkus; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

