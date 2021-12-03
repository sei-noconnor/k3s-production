--
-- PostgreSQL database dump
--

-- Dumped from database version 11.9 (Debian 11.9-1.pgdg90+1)
-- Dumped by pg_dump version 13.0

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
-- Name: steamfitter_api; Type: DATABASE; Schema: -; Owner: postgres
--

CREATE DATABASE steamfitter_api WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE = 'en_US.utf8';


ALTER DATABASE steamfitter_api OWNER TO postgres;

\connect steamfitter_api

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
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


SET default_tablespace = '';

--
-- Name: __EFMigrationsHistory; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."__EFMigrationsHistory" (
    "MigrationId" character varying(150) NOT NULL,
    "ProductVersion" character varying(32) NOT NULL
);


ALTER TABLE public."__EFMigrationsHistory" OWNER TO postgres;

--
-- Name: bond_agents; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.bond_agents (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    machine_name text,
    fqdn text,
    guest_ip text,
    vm_ware_uuid uuid NOT NULL,
    vm_ware_name uuid NOT NULL,
    agent_name text,
    agent_version text,
    agent_installed_path text,
    operating_system_id integer,
    checkin_time timestamp without time zone
);


ALTER TABLE public.bond_agents OWNER TO postgres;

--
-- Name: files; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.files (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    date_created timestamp without time zone NOT NULL,
    date_modified timestamp without time zone,
    created_by uuid NOT NULL,
    modified_by uuid,
    name text,
    storage_path text,
    length bigint NOT NULL
);


ALTER TABLE public.files OWNER TO postgres;

--
-- Name: local_user; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.local_user (
    id integer NOT NULL,
    username text,
    domain text,
    is_current boolean NOT NULL,
    bond_agent_id uuid
);


ALTER TABLE public.local_user OWNER TO postgres;

--
-- Name: local_user_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.local_user ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.local_user_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: monitored_tool; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.monitored_tool (
    id integer NOT NULL,
    name text,
    is_running boolean NOT NULL,
    version text,
    location text,
    bond_agent_id uuid
);


ALTER TABLE public.monitored_tool OWNER TO postgres;

--
-- Name: monitored_tool_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.monitored_tool ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.monitored_tool_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: os; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.os (
    id integer NOT NULL,
    platform text,
    service_pack text,
    version text,
    version_string text
);


ALTER TABLE public.os OWNER TO postgres;

--
-- Name: os_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.os ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.os_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: permissions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.permissions (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    key text,
    value text,
    description text,
    read_only boolean NOT NULL,
    created_by uuid DEFAULT '00000000-0000-0000-0000-000000000000'::uuid NOT NULL,
    date_created timestamp without time zone DEFAULT '0001-01-01 00:00:00'::timestamp without time zone NOT NULL,
    date_modified timestamp without time zone,
    modified_by uuid
);


ALTER TABLE public.permissions OWNER TO postgres;

--
-- Name: results; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.results (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    date_created timestamp without time zone NOT NULL,
    date_modified timestamp without time zone,
    created_by uuid NOT NULL,
    modified_by uuid,
    task_id uuid,
    vm_id uuid,
    vm_name text,
    api_url text,
    input_string text,
    expiration_seconds integer NOT NULL,
    iterations integer NOT NULL,
    interval_seconds integer NOT NULL,
    status integer NOT NULL,
    expected_output text,
    actual_output text,
    sent_date timestamp without time zone NOT NULL,
    status_date timestamp without time zone NOT NULL,
    current_iteration integer DEFAULT 0 NOT NULL,
    action integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.results OWNER TO postgres;

--
-- Name: scenario_templates; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.scenario_templates (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    date_created timestamp without time zone NOT NULL,
    date_modified timestamp without time zone,
    created_by uuid NOT NULL,
    modified_by uuid,
    name text,
    description text,
    duration_hours integer,
    default_vm_credential_id uuid
);


ALTER TABLE public.scenario_templates OWNER TO postgres;

--
-- Name: scenarios; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.scenarios (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    date_created timestamp without time zone NOT NULL,
    date_modified timestamp without time zone,
    created_by uuid NOT NULL,
    modified_by uuid,
    name text,
    description text,
    start_date timestamp without time zone NOT NULL,
    end_date timestamp without time zone NOT NULL,
    status integer NOT NULL,
    on_demand boolean NOT NULL,
    scenario_template_id uuid,
    view_id uuid,
    view text,
    default_vm_credential_id uuid
);


ALTER TABLE public.scenarios OWNER TO postgres;

--
-- Name: ssh_port; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ssh_port (
    id integer NOT NULL,
    server text,
    server_port bigint NOT NULL,
    guest text,
    guest_port bigint NOT NULL,
    bond_agent_id uuid
);


ALTER TABLE public.ssh_port OWNER TO postgres;

--
-- Name: ssh_port_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.ssh_port ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.ssh_port_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: tasks; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tasks (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    date_created timestamp without time zone NOT NULL,
    date_modified timestamp without time zone,
    created_by uuid NOT NULL,
    modified_by uuid,
    name text,
    description text,
    scenario_template_id uuid,
    scenario_id uuid,
    user_id uuid,
    action integer NOT NULL,
    vm_mask text,
    api_url text,
    input_string text,
    expected_output text,
    expiration_seconds integer NOT NULL,
    delay_seconds integer NOT NULL,
    interval_seconds integer NOT NULL,
    iterations integer NOT NULL,
    trigger_task_id uuid,
    trigger_condition integer NOT NULL,
    current_iteration integer DEFAULT 0 NOT NULL,
    iteration_termination integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.tasks OWNER TO postgres;

--
-- Name: user_permissions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_permissions (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    user_id uuid NOT NULL,
    permission_id uuid NOT NULL
);


ALTER TABLE public.user_permissions OWNER TO postgres;

--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    date_created timestamp without time zone NOT NULL,
    date_modified timestamp without time zone,
    created_by uuid NOT NULL,
    modified_by uuid,
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name text
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Name: vm_credentials; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.vm_credentials (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    date_created timestamp without time zone NOT NULL,
    date_modified timestamp without time zone,
    created_by uuid NOT NULL,
    modified_by uuid,
    scenario_template_id uuid,
    scenario_id uuid,
    username text,
    password text,
    description text
);


ALTER TABLE public.vm_credentials OWNER TO postgres;

--
-- Data for Name: __EFMigrationsHistory; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."__EFMigrationsHistory" ("MigrationId", "ProductVersion") FROM stdin;
20190729181108_initial	3.1.4
20200207192417_Permissions	3.1.4
20200212191429_BaseToPermissions	3.1.4
20200403151718_cascadeDeletes	3.1.4
20200403162431_hashSets	3.1.4
20200505203415_renameNouns	3.1.4
20200507171421_BondAgents	3.1.4
20200508130711_PlayerNouns	3.1.4
20200513201905_renameIndexes	3.1.4
20200714193257_taskIterations	3.1.4
20200720175527_resultAction	3.1.4
20200721202055_nullTaskId	3.1.4
20200721205434_nullScenarioTemplateId	3.1.4
20200817193341_vmcreds	3.1.4
20200817202203_vmcreds2	3.1.4
\.


--
-- Data for Name: bond_agents; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.bond_agents (id, machine_name, fqdn, guest_ip, vm_ware_uuid, vm_ware_name, agent_name, agent_version, agent_installed_path, operating_system_id, checkin_time) FROM stdin;
\.


--
-- Data for Name: files; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.files (id, date_created, date_modified, created_by, modified_by, name, storage_path, length) FROM stdin;
\.


--
-- Data for Name: local_user; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.local_user (id, username, domain, is_current, bond_agent_id) FROM stdin;
\.


--
-- Data for Name: monitored_tool; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.monitored_tool (id, name, is_running, version, location, bond_agent_id) FROM stdin;
\.


--
-- Data for Name: os; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.os (id, platform, service_pack, version, version_string) FROM stdin;
\.


--
-- Data for Name: permissions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.permissions (id, key, value, description, read_only, created_by, date_created, date_modified, modified_by) FROM stdin;
00000000-0000-0000-0000-000000000001	SystemAdmin	true	Has Full Rights.  Can do everything.	t	00000000-0000-0000-0000-000000000000	2020-10-09 14:06:41.035426	\N	\N
00000000-0000-0000-0000-000000000002	ContentDeveloper	true	Can create/edit/delete an Exercise/Directory/Workspace/File/Module	t	00000000-0000-0000-0000-000000000000	2020-10-09 14:06:41.037246	\N	\N
\.


--
-- Data for Name: results; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.results (id, date_created, date_modified, created_by, modified_by, task_id, vm_id, vm_name, api_url, input_string, expiration_seconds, iterations, interval_seconds, status, expected_output, actual_output, sent_date, status_date, current_iteration, action) FROM stdin;
4b430eb4-6cc4-4b49-9bcd-52f8cf905b90	2020-10-21 19:23:19.899108	\N	9fd3c38e-58b0-4af1-80d1-1895af91f1f9	\N	6c35342a-d528-4913-baa3-1dc7ab810782	42041a90-c9dd-3078-0bd4-ba55a5b9c350	ubuntu-7dd89c5d-e7e0-41ac-988f-226315ff8512	stackstorm	{"Moid":"42041a90-c9dd-3078-0bd4-ba55a5b9c350"}	120	1	0	70		On	2020-10-21 19:23:19.899003	2020-10-21 19:23:26.112587	1	104
\.


--
-- Data for Name: scenario_templates; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.scenario_templates (id, date_created, date_modified, created_by, modified_by, name, description, duration_hours, default_vm_credential_id) FROM stdin;
9188d171-d6c1-4308-969c-5df7926f96ac	2020-10-09 14:24:38.468409	\N	9fd3c38e-58b0-4af1-80d1-1895af91f1f9	\N	Example Scenario	A Example Scenario	4	\N
\.


--
-- Data for Name: scenarios; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.scenarios (id, date_created, date_modified, created_by, modified_by, name, description, start_date, end_date, status, on_demand, scenario_template_id, view_id, view, default_vm_credential_id) FROM stdin;
9fd3c38e-58b0-4af1-80d1-1895af91f1f9	2020-10-09 14:24:16.629513	2020-10-21 19:23:04.064945	9fd3c38e-58b0-4af1-80d1-1895af91f1f9	9fd3c38e-58b0-4af1-80d1-1895af91f1f9	Admin User Scenario	Personal Task Builder Scenario	2020-10-09 18:24:16.629	2120-10-09 18:24:16.629	2	f	\N	7dd89c5d-e7e0-41ac-988f-226315ff8512	\N	\N
3d3bd6cb-fa40-462a-8411-c9666ba9ef37	2020-10-21 19:20:18.857684	2020-10-21 19:24:51.113411	9fd3c38e-58b0-4af1-80d1-1895af91f1f9	9fd3c38e-58b0-4af1-80d1-1895af91f1f9	Example Scenario - Admin - Admin	A Example Scenario	2020-10-21 19:21:20.431174	2020-10-21 19:24:51.113411	4	t	9188d171-d6c1-4308-969c-5df7926f96ac	7dd89c5d-e7e0-41ac-988f-226315ff8512	\N	\N
\.


--
-- Data for Name: ssh_port; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ssh_port (id, server, server_port, guest, guest_port, bond_agent_id) FROM stdin;
\.


--
-- Data for Name: tasks; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tasks (id, date_created, date_modified, created_by, modified_by, name, description, scenario_template_id, scenario_id, user_id, action, vm_mask, api_url, input_string, expected_output, expiration_seconds, delay_seconds, interval_seconds, iterations, trigger_task_id, trigger_condition, current_iteration, iteration_termination) FROM stdin;
fa1415e3-907e-4be0-abff-5c35221ae981	2020-10-09 14:25:31.249958	\N	9fd3c38e-58b0-4af1-80d1-1895af91f1f9	\N	Power On Ubuntu	A example tasks to power on vms with the vm mask of ubuntu	9188d171-d6c1-4308-969c-5df7926f96ac	\N	9fd3c38e-58b0-4af1-80d1-1895af91f1f9	104	ubuntu	stackstorm	{"Moid":"{moid}"}		0	0	0	1	\N	6	0	0
6c35342a-d528-4913-baa3-1dc7ab810782	2020-10-21 19:20:19.358529	2020-10-21 19:20:19.358529	9fd3c38e-58b0-4af1-80d1-1895af91f1f9	9fd3c38e-58b0-4af1-80d1-1895af91f1f9	Power On Ubuntu	A example tasks to power on vms with the vm mask of ubuntu	\N	3d3bd6cb-fa40-462a-8411-c9666ba9ef37	9fd3c38e-58b0-4af1-80d1-1895af91f1f9	104	ubuntu	stackstorm	{"Moid":"{moid}"}		0	0	0	1	\N	6	1	0
6203aa4b-c187-4d49-8139-dc3f6aa8667e	2020-10-21 19:26:50.51603	\N	9fd3c38e-58b0-4af1-80d1-1895af91f1f9	\N	Power Off Ubuntu		9188d171-d6c1-4308-969c-5df7926f96ac	\N	9fd3c38e-58b0-4af1-80d1-1895af91f1f9	103	ubuntu	stackstorm	{"Moid":"{moid}"}		0	0	0	1	\N	6	0	0
dea6f874-5afb-445b-b2e6-fd91e9baed9e	2020-10-21 19:29:07.16477	\N	9fd3c38e-58b0-4af1-80d1-1895af91f1f9	\N	File Upload	Uploads a test file to the home directory of user 'user'	9188d171-d6c1-4308-969c-5df7926f96ac	\N	9fd3c38e-58b0-4af1-80d1-1895af91f1f9	108	ubuntu	stackstorm	{"Moid":"{moid}","Username":"user","Password":"tartans@1","GuestFilePath":"~/test.txt","GuestFileContent":"This is a test file"}		0	0	0	1	\N	6	0	0
1ed42698-c893-4081-a3dd-2b8983af1ead	2020-10-21 19:30:29.377003	\N	9fd3c38e-58b0-4af1-80d1-1895af91f1f9	\N	Get IP addresses	Runs 'ip addr` on Ubuntu hosts	9188d171-d6c1-4308-969c-5df7926f96ac	\N	9fd3c38e-58b0-4af1-80d1-1895af91f1f9	107	ubuntu	stackstorm	{"Moid":"{moid}","Username":"user","Password":"tartans@1","CommandText":"ip addr","CommandArgs":""}		0	0	0	1	\N	6	0	0
\.


--
-- Data for Name: user_permissions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_permissions (id, user_id, permission_id) FROM stdin;
ed4734cd-8172-4fa8-97a7-56b70566afe2	9fd3c38e-58b0-4af1-80d1-1895af91f1f9	00000000-0000-0000-0000-000000000001
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (date_created, date_modified, created_by, modified_by, id, name) FROM stdin;
2020-10-09 14:06:41.03766	\N	00000000-0000-0000-0000-000000000000	\N	9fd3c38e-58b0-4af1-80d1-1895af91f1f9	Admin
\.


--
-- Data for Name: vm_credentials; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.vm_credentials (id, date_created, date_modified, created_by, modified_by, scenario_template_id, scenario_id, username, password, description) FROM stdin;
\.


--
-- Name: local_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.local_user_id_seq', 1, false);


--
-- Name: monitored_tool_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.monitored_tool_id_seq', 1, false);


--
-- Name: os_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.os_id_seq', 1, false);


--
-- Name: ssh_port_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ssh_port_id_seq', 1, false);


--
-- Name: __EFMigrationsHistory PK___EFMigrationsHistory; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."__EFMigrationsHistory"
    ADD CONSTRAINT "PK___EFMigrationsHistory" PRIMARY KEY ("MigrationId");


--
-- Name: bond_agents PK_bond_agents; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bond_agents
    ADD CONSTRAINT "PK_bond_agents" PRIMARY KEY (id);


--
-- Name: files PK_files; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.files
    ADD CONSTRAINT "PK_files" PRIMARY KEY (id);


--
-- Name: local_user PK_local_user; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.local_user
    ADD CONSTRAINT "PK_local_user" PRIMARY KEY (id);


--
-- Name: monitored_tool PK_monitored_tool; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.monitored_tool
    ADD CONSTRAINT "PK_monitored_tool" PRIMARY KEY (id);


--
-- Name: os PK_os; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.os
    ADD CONSTRAINT "PK_os" PRIMARY KEY (id);


--
-- Name: permissions PK_permissions; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.permissions
    ADD CONSTRAINT "PK_permissions" PRIMARY KEY (id);


--
-- Name: results PK_results; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.results
    ADD CONSTRAINT "PK_results" PRIMARY KEY (id);


--
-- Name: scenario_templates PK_scenario_templates; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.scenario_templates
    ADD CONSTRAINT "PK_scenario_templates" PRIMARY KEY (id);


--
-- Name: scenarios PK_scenarios; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.scenarios
    ADD CONSTRAINT "PK_scenarios" PRIMARY KEY (id);


--
-- Name: ssh_port PK_ssh_port; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ssh_port
    ADD CONSTRAINT "PK_ssh_port" PRIMARY KEY (id);


--
-- Name: tasks PK_tasks; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tasks
    ADD CONSTRAINT "PK_tasks" PRIMARY KEY (id);


--
-- Name: user_permissions PK_user_permissions; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_permissions
    ADD CONSTRAINT "PK_user_permissions" PRIMARY KEY (id);


--
-- Name: users PK_users; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT "PK_users" PRIMARY KEY (id);


--
-- Name: vm_credentials PK_vm_credentials; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vm_credentials
    ADD CONSTRAINT "PK_vm_credentials" PRIMARY KEY (id);


--
-- Name: IX_bond_agents_operating_system_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_bond_agents_operating_system_id" ON public.bond_agents USING btree (operating_system_id);


--
-- Name: IX_local_user_bond_agent_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_local_user_bond_agent_id" ON public.local_user USING btree (bond_agent_id);


--
-- Name: IX_monitored_tool_bond_agent_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_monitored_tool_bond_agent_id" ON public.monitored_tool USING btree (bond_agent_id);


--
-- Name: IX_permissions_key_value; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IX_permissions_key_value" ON public.permissions USING btree (key, value);


--
-- Name: IX_results_task_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_results_task_id" ON public.results USING btree (task_id);


--
-- Name: IX_scenarios_scenario_template_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_scenarios_scenario_template_id" ON public.scenarios USING btree (scenario_template_id);


--
-- Name: IX_ssh_port_bond_agent_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_ssh_port_bond_agent_id" ON public.ssh_port USING btree (bond_agent_id);


--
-- Name: IX_tasks_scenario_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_tasks_scenario_id" ON public.tasks USING btree (scenario_id);


--
-- Name: IX_tasks_scenario_template_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_tasks_scenario_template_id" ON public.tasks USING btree (scenario_template_id);


--
-- Name: IX_tasks_trigger_task_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_tasks_trigger_task_id" ON public.tasks USING btree (trigger_task_id);


--
-- Name: IX_tasks_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_tasks_user_id" ON public.tasks USING btree (user_id);


--
-- Name: IX_user_permissions_permission_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_user_permissions_permission_id" ON public.user_permissions USING btree (permission_id);


--
-- Name: IX_user_permissions_user_id_permission_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IX_user_permissions_user_id_permission_id" ON public.user_permissions USING btree (user_id, permission_id);


--
-- Name: IX_users_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IX_users_id" ON public.users USING btree (id);


--
-- Name: IX_vm_credentials_scenario_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_vm_credentials_scenario_id" ON public.vm_credentials USING btree (scenario_id);


--
-- Name: IX_vm_credentials_scenario_template_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_vm_credentials_scenario_template_id" ON public.vm_credentials USING btree (scenario_template_id);


--
-- Name: bond_agents FK_bond_agents_os_operating_system_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bond_agents
    ADD CONSTRAINT "FK_bond_agents_os_operating_system_id" FOREIGN KEY (operating_system_id) REFERENCES public.os(id) ON DELETE RESTRICT;


--
-- Name: local_user FK_local_user_bond_agents_bond_agent_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.local_user
    ADD CONSTRAINT "FK_local_user_bond_agents_bond_agent_id" FOREIGN KEY (bond_agent_id) REFERENCES public.bond_agents(id) ON DELETE RESTRICT;


--
-- Name: monitored_tool FK_monitored_tool_bond_agents_bond_agent_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.monitored_tool
    ADD CONSTRAINT "FK_monitored_tool_bond_agents_bond_agent_id" FOREIGN KEY (bond_agent_id) REFERENCES public.bond_agents(id) ON DELETE RESTRICT;


--
-- Name: results FK_results_tasks_task_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.results
    ADD CONSTRAINT "FK_results_tasks_task_id" FOREIGN KEY (task_id) REFERENCES public.tasks(id) ON DELETE SET NULL;


--
-- Name: scenarios FK_scenarios_scenario_templates_scenario_template_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.scenarios
    ADD CONSTRAINT "FK_scenarios_scenario_templates_scenario_template_id" FOREIGN KEY (scenario_template_id) REFERENCES public.scenario_templates(id) ON DELETE SET NULL;


--
-- Name: ssh_port FK_ssh_port_bond_agents_bond_agent_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ssh_port
    ADD CONSTRAINT "FK_ssh_port_bond_agents_bond_agent_id" FOREIGN KEY (bond_agent_id) REFERENCES public.bond_agents(id) ON DELETE RESTRICT;


--
-- Name: tasks FK_tasks_scenario_templates_scenario_template_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tasks
    ADD CONSTRAINT "FK_tasks_scenario_templates_scenario_template_id" FOREIGN KEY (scenario_template_id) REFERENCES public.scenario_templates(id) ON DELETE CASCADE;


--
-- Name: tasks FK_tasks_scenarios_scenario_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tasks
    ADD CONSTRAINT "FK_tasks_scenarios_scenario_id" FOREIGN KEY (scenario_id) REFERENCES public.scenarios(id) ON DELETE CASCADE;


--
-- Name: tasks FK_tasks_tasks_trigger_task_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tasks
    ADD CONSTRAINT "FK_tasks_tasks_trigger_task_id" FOREIGN KEY (trigger_task_id) REFERENCES public.tasks(id) ON DELETE CASCADE;


--
-- Name: user_permissions FK_user_permissions_permissions_permission_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_permissions
    ADD CONSTRAINT "FK_user_permissions_permissions_permission_id" FOREIGN KEY (permission_id) REFERENCES public.permissions(id) ON DELETE CASCADE;


--
-- Name: user_permissions FK_user_permissions_users_user_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_permissions
    ADD CONSTRAINT "FK_user_permissions_users_user_id" FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: vm_credentials FK_vm_credentials_scenario_templates_scenario_template_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vm_credentials
    ADD CONSTRAINT "FK_vm_credentials_scenario_templates_scenario_template_id" FOREIGN KEY (scenario_template_id) REFERENCES public.scenario_templates(id) ON DELETE CASCADE;


--
-- Name: vm_credentials FK_vm_credentials_scenarios_scenario_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vm_credentials
    ADD CONSTRAINT "FK_vm_credentials_scenarios_scenario_id" FOREIGN KEY (scenario_id) REFERENCES public.scenarios(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

