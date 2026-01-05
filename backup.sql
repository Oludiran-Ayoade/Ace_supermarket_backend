--
-- PostgreSQL database dump
--

\restrict iiHS86mw7FrrXk0rOXhiTDR1ppVdWSKMgNdKwyHsvdpsQQG6tnSGbypA0eYj3OG

-- Dumped from database version 18.1
-- Dumped by pg_dump version 18.1 (Homebrew)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
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


--
-- Name: day_of_week; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.day_of_week AS ENUM (
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday',
    'saturday',
    'sunday'
);


ALTER TYPE public.day_of_week OWNER TO postgres;

--
-- Name: shift_type; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.shift_type AS ENUM (
    'day',
    'afternoon',
    'night'
);


ALTER TYPE public.shift_type OWNER TO postgres;

--
-- Name: update_terminated_staff_updated_at(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_terminated_staff_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_terminated_staff_updated_at() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: branches; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.branches (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name character varying(100) NOT NULL,
    location character varying(200) NOT NULL,
    is_active boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.branches OWNER TO postgres;

--
-- Name: departments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.departments (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name character varying(100) NOT NULL,
    description text,
    is_active boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.departments OWNER TO postgres;

--
-- Name: document_access_logs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.document_access_logs (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    user_id uuid NOT NULL,
    accessed_by uuid NOT NULL,
    document_type character varying(100) NOT NULL,
    action character varying(50) NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.document_access_logs OWNER TO postgres;

--
-- Name: TABLE document_access_logs; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.document_access_logs IS 'Audit trail for document access and modifications';


--
-- Name: guarantor_documents; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.guarantor_documents (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    guarantor_id uuid,
    document_type character varying(100) NOT NULL,
    file_name character varying(255) NOT NULL,
    file_path character varying(500) NOT NULL,
    uploaded_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.guarantor_documents OWNER TO postgres;

--
-- Name: guarantors; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.guarantors (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    user_id uuid,
    guarantor_number integer DEFAULT 1 NOT NULL,
    full_name character varying(200) NOT NULL,
    phone_number character varying(20),
    email character varying(255),
    occupation character varying(200),
    relationship character varying(100),
    home_address text,
    sex character varying(20),
    age integer,
    date_of_birth date,
    grade_level character varying(50),
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.guarantors OWNER TO postgres;

--
-- Name: messages; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.messages (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    sender_id uuid NOT NULL,
    title character varying(255) NOT NULL,
    content text NOT NULL,
    target_type character varying(20) DEFAULT 'all'::character varying NOT NULL,
    target_branch_id uuid,
    target_department_id uuid,
    expires_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.messages OWNER TO postgres;

--
-- Name: next_of_kin; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.next_of_kin (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    user_id uuid,
    full_name character varying(200) NOT NULL,
    relationship character varying(100),
    email character varying(255),
    phone_number character varying(20),
    home_address text,
    work_address text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.next_of_kin OWNER TO postgres;

--
-- Name: notifications; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.notifications (
    id integer NOT NULL,
    user_id uuid NOT NULL,
    type character varying(50) NOT NULL,
    title character varying(255) NOT NULL,
    message text,
    is_read boolean DEFAULT false,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    message_id uuid,
    expires_at timestamp with time zone,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.notifications OWNER TO postgres;

--
-- Name: notifications_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.notifications_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.notifications_id_seq OWNER TO postgres;

--
-- Name: notifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.notifications_id_seq OWNED BY public.notifications.id;


--
-- Name: password_reset_otps; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.password_reset_otps (
    id integer NOT NULL,
    email character varying(255) NOT NULL,
    otp character varying(6) NOT NULL,
    expires_at timestamp without time zone NOT NULL,
    used boolean DEFAULT false,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.password_reset_otps OWNER TO postgres;

--
-- Name: password_reset_otps_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.password_reset_otps_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.password_reset_otps_id_seq OWNER TO postgres;

--
-- Name: password_reset_otps_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.password_reset_otps_id_seq OWNED BY public.password_reset_otps.id;


--
-- Name: promotion_history; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.promotion_history (
    id integer NOT NULL,
    user_id uuid NOT NULL,
    previous_role_id uuid,
    new_role_id uuid,
    previous_salary numeric(12,2),
    new_salary numeric(12,2),
    previous_branch_id uuid,
    new_branch_id uuid,
    previous_department_id uuid,
    new_department_id uuid,
    promotion_date date DEFAULT CURRENT_DATE NOT NULL,
    promoted_by uuid,
    reason text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.promotion_history OWNER TO postgres;

--
-- Name: promotion_history_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.promotion_history_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.promotion_history_id_seq OWNER TO postgres;

--
-- Name: promotion_history_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.promotion_history_id_seq OWNED BY public.promotion_history.id;


--
-- Name: roles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.roles (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name character varying(100) NOT NULL,
    category character varying(50) NOT NULL,
    department_id uuid,
    sub_department_id uuid,
    description text,
    is_active boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.roles OWNER TO postgres;

--
-- Name: roster_assignments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.roster_assignments (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    roster_id uuid NOT NULL,
    staff_id uuid NOT NULL,
    day_of_week public.day_of_week NOT NULL,
    shift_type public.shift_type NOT NULL,
    start_time time without time zone NOT NULL,
    end_time time without time zone NOT NULL,
    notes text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.roster_assignments OWNER TO postgres;

--
-- Name: TABLE roster_assignments; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.roster_assignments IS 'Individual shift assignments for staff';


--
-- Name: rosters; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.rosters (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    floor_manager_id uuid NOT NULL,
    department_id uuid,
    branch_id uuid,
    week_start_date date NOT NULL,
    week_end_date date NOT NULL,
    status character varying(50) DEFAULT 'draft'::character varying,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.rosters OWNER TO postgres;

--
-- Name: TABLE rosters; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.rosters IS 'Weekly rosters created by floor managers';


--
-- Name: shift_templates; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.shift_templates (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    floor_manager_id uuid NOT NULL,
    shift_type public.shift_type NOT NULL,
    start_time time without time zone NOT NULL,
    end_time time without time zone NOT NULL,
    is_default boolean DEFAULT false,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.shift_templates OWNER TO postgres;

--
-- Name: TABLE shift_templates; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.shift_templates IS 'Predefined shift times for floor managers';


--
-- Name: sub_departments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sub_departments (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    parent_department_id uuid,
    name character varying(100) NOT NULL,
    description text,
    is_active boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    branch_id uuid,
    manager_id uuid
);


ALTER TABLE public.sub_departments OWNER TO postgres;

--
-- Name: TABLE sub_departments; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.sub_departments IS 'Sub-departments within main departments (e.g., Cinema under Fun & Arcade)';


--
-- Name: terminated_staff; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.terminated_staff (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    full_name character varying(255) NOT NULL,
    email character varying(255) NOT NULL,
    employee_id character varying(50),
    role_name character varying(100),
    department_name character varying(100),
    branch_name character varying(100),
    termination_type character varying(50) NOT NULL,
    termination_reason text NOT NULL,
    termination_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    terminated_by uuid NOT NULL,
    terminated_by_name character varying(255) NOT NULL,
    terminated_by_role character varying(100) NOT NULL,
    last_working_day date,
    final_salary numeric(10,2),
    clearance_status character varying(50) DEFAULT 'pending'::character varying,
    clearance_notes text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.terminated_staff OWNER TO postgres;

--
-- Name: TABLE terminated_staff; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.terminated_staff IS 'Archive of terminated or departed staff members';


--
-- Name: COLUMN terminated_staff.termination_type; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.terminated_staff.termination_type IS 'Type of departure: terminated, resigned, retired, contract_ended';


--
-- Name: COLUMN terminated_staff.clearance_status; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.terminated_staff.clearance_status IS 'Exit clearance status: pending, cleared, issues';


--
-- Name: user_documents; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_documents (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    user_id uuid,
    document_type character varying(100) NOT NULL,
    document_url text NOT NULL,
    public_id character varying(255),
    uploaded_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.user_documents OWNER TO postgres;

--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    email character varying(255) NOT NULL,
    password_hash character varying(255) NOT NULL,
    full_name character varying(200) NOT NULL,
    gender character varying(20),
    date_of_birth date,
    marital_status character varying(50),
    phone_number character varying(20),
    home_address text,
    state_of_origin character varying(100),
    employee_id character varying(50),
    role_id uuid,
    department_id uuid,
    sub_department_id uuid,
    branch_id uuid,
    date_joined date NOT NULL,
    current_salary numeric(12,2),
    course_of_study character varying(200),
    grade character varying(50),
    institution character varying(200),
    is_active boolean DEFAULT true,
    is_terminated boolean DEFAULT false,
    termination_reason text,
    termination_date date,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    last_login timestamp without time zone,
    profile_image_url character varying(500),
    profile_image_public_id character varying(255),
    waec_certificate_url character varying(500),
    waec_certificate_public_id character varying(255),
    neco_certificate_url character varying(500),
    neco_certificate_public_id character varying(255),
    jamb_result_url character varying(500),
    jamb_result_public_id character varying(255),
    degree_certificate_url character varying(500),
    degree_certificate_public_id character varying(255),
    diploma_certificate_url character varying(500),
    diploma_certificate_public_id character varying(255),
    birth_certificate_url character varying(500),
    birth_certificate_public_id character varying(255),
    national_id_url character varying(500),
    national_id_public_id character varying(255),
    passport_url character varying(500),
    passport_public_id character varying(255),
    drivers_license_url character varying(500),
    drivers_license_public_id character varying(255),
    voters_card_url character varying(500),
    voters_card_public_id character varying(255),
    nysc_certificate_url character varying(500),
    nysc_certificate_public_id character varying(255),
    state_of_origin_cert_url character varying(500),
    state_of_origin_cert_public_id character varying(255),
    lga_certificate_url character varying(500),
    lga_certificate_public_id character varying(255),
    resume_url character varying(500),
    resume_public_id character varying(255),
    cover_letter_url character varying(500),
    cover_letter_public_id character varying(255),
    department_scope character varying(20) DEFAULT 'branch'::character varying
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Name: COLUMN users.sub_department_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.users.sub_department_id IS 'For staff assigned to sub-departments like Cinema, Saloon, etc.';


--
-- Name: COLUMN users.profile_image_url; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.users.profile_image_url IS 'Cloudinary URL for user profile image';


--
-- Name: COLUMN users.profile_image_public_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.users.profile_image_public_id IS 'Cloudinary public ID for image deletion';


--
-- Name: COLUMN users.waec_certificate_url; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.users.waec_certificate_url IS 'WAEC certificate document URL';


--
-- Name: COLUMN users.neco_certificate_url; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.users.neco_certificate_url IS 'NECO certificate document URL';


--
-- Name: COLUMN users.jamb_result_url; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.users.jamb_result_url IS 'JAMB result document URL';


--
-- Name: COLUMN users.degree_certificate_url; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.users.degree_certificate_url IS 'Degree certificate document URL';


--
-- Name: COLUMN users.diploma_certificate_url; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.users.diploma_certificate_url IS 'Diploma certificate document URL';


--
-- Name: COLUMN users.birth_certificate_url; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.users.birth_certificate_url IS 'Birth certificate document URL';


--
-- Name: COLUMN users.national_id_url; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.users.national_id_url IS 'National ID document URL';


--
-- Name: COLUMN users.passport_url; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.users.passport_url IS 'International passport document URL';


--
-- Name: COLUMN users.drivers_license_url; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.users.drivers_license_url IS 'Driver license document URL';


--
-- Name: COLUMN users.voters_card_url; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.users.voters_card_url IS 'Voter card document URL';


--
-- Name: COLUMN users.nysc_certificate_url; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.users.nysc_certificate_url IS 'NYSC certificate document URL';


--
-- Name: COLUMN users.state_of_origin_cert_url; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.users.state_of_origin_cert_url IS 'State of origin certificate URL';


--
-- Name: COLUMN users.lga_certificate_url; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.users.lga_certificate_url IS 'LGA certificate document URL';


--
-- Name: COLUMN users.resume_url; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.users.resume_url IS 'Resume/CV document URL';


--
-- Name: COLUMN users.cover_letter_url; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.users.cover_letter_url IS 'Cover letter document URL';


--
-- Name: COLUMN users.department_scope; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.users.department_scope IS 'Scope of department management: branch or all_branches';


--
-- Name: v_terminated_staff_details; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.v_terminated_staff_details AS
 SELECT ts.id,
    ts.user_id,
    ts.full_name,
    ts.email,
    ts.employee_id,
    ts.role_name,
    ts.department_name,
    ts.branch_name,
    ts.termination_type,
    ts.termination_reason,
    ts.termination_date,
    ts.terminated_by,
    ts.terminated_by_name,
    ts.terminated_by_role,
    ts.last_working_day,
    ts.final_salary,
    ts.clearance_status,
    ts.clearance_notes,
    ts.created_at,
    ts.updated_at,
    u.phone_number,
    u.date_of_birth,
    u.gender,
    u.date_joined,
    EXTRACT(year FROM age(ts.termination_date, (u.date_joined)::timestamp without time zone)) AS years_of_service,
    EXTRACT(month FROM age(ts.termination_date, (u.date_joined)::timestamp without time zone)) AS months_of_service
   FROM (public.terminated_staff ts
     LEFT JOIN public.users u ON ((ts.user_id = u.id)))
  ORDER BY ts.termination_date DESC;


ALTER VIEW public.v_terminated_staff_details OWNER TO postgres;

--
-- Name: weekly_reviews; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.weekly_reviews (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    staff_id uuid NOT NULL,
    reviewer_id uuid NOT NULL,
    roster_id uuid,
    week_start_date date NOT NULL,
    week_end_date date NOT NULL,
    rating integer,
    punctuality_rating integer,
    performance_rating integer,
    attitude_rating integer,
    comments text,
    strengths text,
    areas_for_improvement text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT weekly_reviews_attitude_rating_check CHECK (((attitude_rating >= 1) AND (attitude_rating <= 5))),
    CONSTRAINT weekly_reviews_performance_rating_check CHECK (((performance_rating >= 1) AND (performance_rating <= 5))),
    CONSTRAINT weekly_reviews_punctuality_rating_check CHECK (((punctuality_rating >= 1) AND (punctuality_rating <= 5))),
    CONSTRAINT weekly_reviews_rating_check CHECK (((rating >= 1) AND (rating <= 5)))
);


ALTER TABLE public.weekly_reviews OWNER TO postgres;

--
-- Name: TABLE weekly_reviews; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.weekly_reviews IS 'Weekly performance reviews by floor managers';


--
-- Name: notifications id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notifications ALTER COLUMN id SET DEFAULT nextval('public.notifications_id_seq'::regclass);


--
-- Name: password_reset_otps id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.password_reset_otps ALTER COLUMN id SET DEFAULT nextval('public.password_reset_otps_id_seq'::regclass);


--
-- Name: promotion_history id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.promotion_history ALTER COLUMN id SET DEFAULT nextval('public.promotion_history_id_seq'::regclass);


--
-- Data for Name: branches; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.branches (id, name, location, is_active, created_at, updated_at) FROM stdin;
d735da13-cff9-4009-a6dd-4ad59fc9f72b	Ace Mall, Oluyole	Oluyole, Ibadan	t	2025-11-15 16:59:02.606587	2025-11-15 16:59:02.606587
38f86af3-14b1-4fe4-a84f-d895e840b1d1	Ace Mall, Bodija	Bodija, Ibadan	t	2025-11-15 16:59:02.606587	2025-11-15 16:59:02.606587
8b67a276-81d1-4950-88ee-47b7077c0bf2	Ace Mall, Akobo	Akobo, Ibadan	t	2025-11-15 16:59:02.606587	2025-11-15 16:59:02.606587
394d14df-75fd-41e0-847d-cd2f08c5b1af	Ace Mall, Oyo	Oyo Town	t	2025-11-15 16:59:02.606587	2025-11-15 16:59:02.606587
001a6790-0f59-4776-aee9-cb1928290ec9	Ace Mall, Ogbomosho	Ogbomosho	t	2025-11-15 16:59:02.606587	2025-11-15 16:59:02.606587
1bc5af13-0b28-422e-bf26-df270e0a4089	Ace Mall, Ilorin	Ilorin, Kwara	t	2025-11-15 16:59:02.606587	2025-11-15 16:59:02.606587
ff3a7fa2-ee3e-484c-ac9b-548b6b9a6eda	Ace Mall, Iseyin	Iseyin	t	2025-11-15 16:59:02.606587	2025-11-15 16:59:02.606587
96423273-2c53-4067-8481-1e7ac885e3ac	Ace Mall, Saki	Saki	t	2025-11-15 16:59:02.606587	2025-11-15 16:59:02.606587
70777e0c-f350-4f3b-9013-5e8691a96d8c	Ace Mall, Ife	Ile-Ife	t	2025-11-15 16:59:02.606587	2025-11-15 16:59:02.606587
2af15e5d-b67a-493f-8357-feaec629a69a	Ace Mall, Osogbo	Osogbo	t	2025-11-15 16:59:02.606587	2025-11-15 16:59:02.606587
511a5f95-209d-4b8d-b795-990079b07e1e	Ace Mall, Abeokuta	Abeokuta	t	2025-11-15 16:59:02.606587	2025-11-15 16:59:02.606587
9d23f80a-749e-4d59-a26d-85e16a388846	Ace Mall, Ijebu	Ijebu-Ode	t	2025-11-15 16:59:02.606587	2025-11-15 16:59:02.606587
1aa3b0e6-af63-4ae1-b371-90e88880f8f1	Ace Mall, Sagamu	Sagamu	t	2025-11-15 16:59:02.606587	2025-11-15 16:59:02.606587
\.


--
-- Data for Name: departments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.departments (id, name, description, is_active, created_at, updated_at) FROM stdin;
160511a1-5b4f-4af9-bdc7-1764adbe6142	SuperMarket	Retail supermarket operations	t	2025-11-15 16:59:02.610208	2025-11-15 16:59:02.610208
4a2add3f-a2e1-4834-af93-a64c2397e933	Eatery	Restaurant and food services	t	2025-11-15 16:59:02.610208	2025-11-15 16:59:02.610208
3be6b055-b126-4fdf-88a8-152634a678ea	Lounge	Bar and lounge services	t	2025-11-15 16:59:02.610208	2025-11-15 16:59:02.610208
04368807-3180-43b1-927e-eab61dfb4a5b	Fun & Arcade	Entertainment and recreation	t	2025-11-15 16:59:02.610208	2025-11-15 16:59:02.610208
d904023b-1163-46a7-94ae-cd6890690416	Compliance	Compliance and regulatory affairs	t	2025-11-15 16:59:02.610208	2025-11-15 16:59:02.610208
acff245a-4a57-47c5-ab5d-8da6f19d449b	Facility Management	Facility maintenance and security	t	2025-11-15 16:59:02.610208	2025-11-15 16:59:02.610208
\.


--
-- Data for Name: document_access_logs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.document_access_logs (id, user_id, accessed_by, document_type, action, created_at) FROM stdin;
13eb51c2-752b-4fe0-9c5d-a036c2760176	8e57948f-983c-4db3-b517-a46b3d3531b3	97dabb21-c5cd-434c-8bff-ae86b3682018	profile_view	view	2025-12-09 23:39:23.220328
b0743deb-d52d-4c56-94d3-f491ba156ca0	8e57948f-983c-4db3-b517-a46b3d3531b3	97dabb21-c5cd-434c-8bff-ae86b3682018	profile_view	view	2025-12-09 23:41:30.906145
ee75dde1-5b7b-4380-bdd6-a6b29f16dc5c	8e57948f-983c-4db3-b517-a46b3d3531b3	97dabb21-c5cd-434c-8bff-ae86b3682018	profile_view	view	2025-12-10 07:48:27.565153
efbf48b4-c8e7-4771-a70e-b7aad216b77a	97dabb21-c5cd-434c-8bff-ae86b3682018	a04f5bc7-2636-4358-aae3-dc3e1c9968e3	profile_view	view	2025-12-10 07:58:27.176651
cfe3007a-7dd4-4719-819b-f9a5c50653f5	8e57948f-983c-4db3-b517-a46b3d3531b3	a04f5bc7-2636-4358-aae3-dc3e1c9968e3	profile_view	view	2025-12-10 07:59:57.891787
89f165be-7d57-40ee-ae6b-d0cdc4d2e88c	8e57948f-983c-4db3-b517-a46b3d3531b3	a04f5bc7-2636-4358-aae3-dc3e1c9968e3	profile_view	view	2025-12-10 08:02:06.797366
76ff1f94-872d-4727-b243-a6152e5fc741	8e57948f-983c-4db3-b517-a46b3d3531b3	a04f5bc7-2636-4358-aae3-dc3e1c9968e3	profile_view	view	2025-12-10 08:02:19.001889
d5fb4ed7-318c-414f-990d-37dc8430c459	8e57948f-983c-4db3-b517-a46b3d3531b3	a04f5bc7-2636-4358-aae3-dc3e1c9968e3	profile_view	view	2025-12-10 08:02:44.136999
4ea19f11-d4d4-4874-a164-7b6f482d6dda	97dabb21-c5cd-434c-8bff-ae86b3682018	a04f5bc7-2636-4358-aae3-dc3e1c9968e3	profile_view	view	2025-12-10 08:05:16.720402
48fe5f2b-a9fd-4cbb-98a7-9bb42c915408	97dabb21-c5cd-434c-8bff-ae86b3682018	a04f5bc7-2636-4358-aae3-dc3e1c9968e3	profile_view	view	2025-12-10 12:09:37.122476
6211a125-f857-4777-999c-18803203bb56	97dabb21-c5cd-434c-8bff-ae86b3682018	a04f5bc7-2636-4358-aae3-dc3e1c9968e3	profile_view	view	2025-12-10 12:24:12.56176
d4ead2e2-9253-43e3-b04f-8c607dd42d61	97dabb21-c5cd-434c-8bff-ae86b3682018	a04f5bc7-2636-4358-aae3-dc3e1c9968e3	profile_view	view	2025-12-10 12:40:19.046069
cc45699a-ae67-4303-86ad-97653db9e5d7	97dabb21-c5cd-434c-8bff-ae86b3682018	a04f5bc7-2636-4358-aae3-dc3e1c9968e3	profile_view	view	2025-12-10 12:43:43.659926
9e457186-726a-4992-aae5-3a9adf054d34	97dabb21-c5cd-434c-8bff-ae86b3682018	a04f5bc7-2636-4358-aae3-dc3e1c9968e3	profile_view	view	2025-12-10 12:44:05.805744
cdf9f9cb-b03f-4e5e-9261-a3f181ab6080	97dabb21-c5cd-434c-8bff-ae86b3682018	a04f5bc7-2636-4358-aae3-dc3e1c9968e3	profile_view	view	2025-12-10 12:44:29.418986
c36d7774-5dff-4f18-a51c-6db8f33510df	8e57948f-983c-4db3-b517-a46b3d3531b3	a04f5bc7-2636-4358-aae3-dc3e1c9968e3	profile_view	view	2025-12-10 13:05:24.100574
f1f088bb-001b-4b01-82fa-3612e53345c8	8e57948f-983c-4db3-b517-a46b3d3531b3	a04f5bc7-2636-4358-aae3-dc3e1c9968e3	profile_view	view	2025-12-10 13:05:38.385557
2d1d57a2-281d-4f84-bf31-fc2f64b5fd17	8e57948f-983c-4db3-b517-a46b3d3531b3	a04f5bc7-2636-4358-aae3-dc3e1c9968e3	profile_view	view	2025-12-10 13:05:48.076016
0d9138d3-0df3-4a17-ba1d-6316e28bbff7	8e57948f-983c-4db3-b517-a46b3d3531b3	a04f5bc7-2636-4358-aae3-dc3e1c9968e3	profile_view	view	2025-12-11 09:40:37.947377
74d2ea4f-b744-4417-be26-db398a091bf1	8e57948f-983c-4db3-b517-a46b3d3531b3	a04f5bc7-2636-4358-aae3-dc3e1c9968e3	profile_view	view	2025-12-11 09:41:44.61232
34cd9e9d-c9f9-4752-a52e-2839e7448063	97dabb21-c5cd-434c-8bff-ae86b3682018	a04f5bc7-2636-4358-aae3-dc3e1c9968e3	profile_view	view	2025-12-11 09:41:52.993688
b628f249-b4aa-4e95-b297-cdf29a6f12b8	b5d7896a-9217-480e-b4ac-8343141a3333	a04f5bc7-2636-4358-aae3-dc3e1c9968e3	profile_view	view	2025-12-11 13:27:01.150914
ce17aaf3-823f-4757-8d89-10b6e1222457	8e57948f-983c-4db3-b517-a46b3d3531b3	a04f5bc7-2636-4358-aae3-dc3e1c9968e3	profile_view	view	2025-12-11 13:27:41.1856
77b778fb-e8fe-496f-999c-cc97c5ca70d4	97dabb21-c5cd-434c-8bff-ae86b3682018	a04f5bc7-2636-4358-aae3-dc3e1c9968e3	profile_view	view	2025-12-11 13:29:42.398196
0e34e822-e1e2-4706-bc53-01d75449d44d	8e57948f-983c-4db3-b517-a46b3d3531b3	a04f5bc7-2636-4358-aae3-dc3e1c9968e3	profile_view	view	2025-12-11 13:47:03.527394
ec269ac5-5501-4fe0-a2a4-ade5f1079844	97dabb21-c5cd-434c-8bff-ae86b3682018	a04f5bc7-2636-4358-aae3-dc3e1c9968e3	profile_view	view	2025-12-11 13:47:39.944753
53d18542-59dc-46d7-a326-595c18ca3c0f	97dabb21-c5cd-434c-8bff-ae86b3682018	a04f5bc7-2636-4358-aae3-dc3e1c9968e3	profile_view	view	2025-12-11 15:09:34.644153
9012cae3-cfeb-4411-af4f-1069eec274b0	97dabb21-c5cd-434c-8bff-ae86b3682018	a04f5bc7-2636-4358-aae3-dc3e1c9968e3	profile_view	view	2025-12-11 15:28:03.730039
932f8d79-8347-4052-a61b-6debafde9008	97dabb21-c5cd-434c-8bff-ae86b3682018	a04f5bc7-2636-4358-aae3-dc3e1c9968e3	profile_view	view	2025-12-11 15:33:47.613707
2b2d10dd-7cfa-4471-85f1-26e234bf3deb	97dabb21-c5cd-434c-8bff-ae86b3682018	a04f5bc7-2636-4358-aae3-dc3e1c9968e3	profile_view	view	2025-12-11 15:38:17.639337
928fc850-8610-4d75-aebc-7704e6535185	97dabb21-c5cd-434c-8bff-ae86b3682018	a04f5bc7-2636-4358-aae3-dc3e1c9968e3	profile_view	view	2025-12-11 15:59:39.394219
fd256143-b007-4279-9e28-8b06fb81a947	97dabb21-c5cd-434c-8bff-ae86b3682018	a04f5bc7-2636-4358-aae3-dc3e1c9968e3	profile_view	view	2025-12-11 16:04:02.37261
df8ecc30-30ec-4e2e-a73e-3742f519bcdb	97dabb21-c5cd-434c-8bff-ae86b3682018	a04f5bc7-2636-4358-aae3-dc3e1c9968e3	profile_view	view	2025-12-11 17:46:56.829645
4e98da0f-c529-4d24-812c-b25fee9dc38f	97dabb21-c5cd-434c-8bff-ae86b3682018	a04f5bc7-2636-4358-aae3-dc3e1c9968e3	profile_view	view	2025-12-11 17:48:30.575448
789f529a-5545-40b1-a1ef-36e728ae84c9	97dabb21-c5cd-434c-8bff-ae86b3682018	a04f5bc7-2636-4358-aae3-dc3e1c9968e3	profile_view	view	2025-12-11 17:53:47.299692
74f498a8-e9c7-4491-9b2c-03c96e2073c9	97dabb21-c5cd-434c-8bff-ae86b3682018	a04f5bc7-2636-4358-aae3-dc3e1c9968e3	profile_view	view	2025-12-11 18:07:36.209851
05f51b05-2baf-4dbb-9c4c-e1344ea7bf2d	97dabb21-c5cd-434c-8bff-ae86b3682018	a04f5bc7-2636-4358-aae3-dc3e1c9968e3	profile_view	view	2025-12-11 18:15:48.220953
acded071-0f3f-4ea7-9706-1b4623ee0e37	97dabb21-c5cd-434c-8bff-ae86b3682018	a04f5bc7-2636-4358-aae3-dc3e1c9968e3	profile_view	view	2025-12-11 18:17:28.383592
f75f048e-6b6d-431d-9608-ed9975559d18	97dabb21-c5cd-434c-8bff-ae86b3682018	a04f5bc7-2636-4358-aae3-dc3e1c9968e3	profile_view	view	2025-12-11 18:21:11.423136
d57b4dc2-9924-4c44-a5e5-b988eb589e90	97dabb21-c5cd-434c-8bff-ae86b3682018	a04f5bc7-2636-4358-aae3-dc3e1c9968e3	profile_view	view	2025-12-11 18:29:55.267087
e29967f3-bb40-4fb7-8987-da3e7783a100	97dabb21-c5cd-434c-8bff-ae86b3682018	a04f5bc7-2636-4358-aae3-dc3e1c9968e3	profile_view	view	2025-12-11 18:37:44.564632
4c9a7eef-f782-405b-a4ed-180eb5a900da	97dabb21-c5cd-434c-8bff-ae86b3682018	a04f5bc7-2636-4358-aae3-dc3e1c9968e3	profile_view	view	2025-12-11 18:52:58.145201
a17ba8ff-629f-4e8d-8591-bd492f3ea8ab	97dabb21-c5cd-434c-8bff-ae86b3682018	a04f5bc7-2636-4358-aae3-dc3e1c9968e3	profile_view	view	2025-12-11 19:05:33.405347
f2384a9e-26da-477c-ad00-24236ea0f54c	97dabb21-c5cd-434c-8bff-ae86b3682018	a04f5bc7-2636-4358-aae3-dc3e1c9968e3	profile_view	view	2025-12-13 12:18:13.487469
1fc05b83-cd71-4a0e-a4f2-7e87552233b0	97dabb21-c5cd-434c-8bff-ae86b3682018	a04f5bc7-2636-4358-aae3-dc3e1c9968e3	profile_view	view	2025-12-13 12:27:27.569712
b4930465-1d8b-4f69-b1cb-97673579d5ca	97dabb21-c5cd-434c-8bff-ae86b3682018	a04f5bc7-2636-4358-aae3-dc3e1c9968e3	profile_view	view	2025-12-13 12:35:38.058345
8550350e-abbc-4fe9-9971-0e4a111857fe	97dabb21-c5cd-434c-8bff-ae86b3682018	a04f5bc7-2636-4358-aae3-dc3e1c9968e3	profile_view	view	2025-12-13 12:37:50.504021
8931b74f-5f26-4333-ade3-bcc743a29664	97dabb21-c5cd-434c-8bff-ae86b3682018	a04f5bc7-2636-4358-aae3-dc3e1c9968e3	profile_view	view	2025-12-13 12:43:01.446486
7444b529-3fc0-4ff1-a486-d1ea6df17558	97dabb21-c5cd-434c-8bff-ae86b3682018	a04f5bc7-2636-4358-aae3-dc3e1c9968e3	profile_view	view	2025-12-13 22:20:41.842863
cd1de8ab-f8d2-4a42-8e10-5624d31f205c	97dabb21-c5cd-434c-8bff-ae86b3682018	a04f5bc7-2636-4358-aae3-dc3e1c9968e3	profile_view	view	2025-12-13 22:24:26.723044
d6399b19-6473-4964-80b1-421d03098b92	02762b1e-9b2f-4bfe-943c-d6c28827ef96	a04f5bc7-2636-4358-aae3-dc3e1c9968e3	profile_view	view	2025-12-13 22:26:53.45786
47041cb4-f5ef-4501-bbce-dd85957daa82	97dabb21-c5cd-434c-8bff-ae86b3682018	a04f5bc7-2636-4358-aae3-dc3e1c9968e3	profile_view	view	2025-12-13 22:27:00.842792
9284bec8-69b8-414a-bf04-9fda7e45bb38	97dabb21-c5cd-434c-8bff-ae86b3682018	a04f5bc7-2636-4358-aae3-dc3e1c9968e3	profile_view	view	2025-12-13 22:28:07.227229
367ca233-291e-44dd-bbbe-650f5a096051	e6bcd428-3711-4d17-80b4-5fab412563bd	a04f5bc7-2636-4358-aae3-dc3e1c9968e3	profile_view	view	2025-12-13 23:32:39.751562
c513bca5-fcf1-4536-b9dc-5b1d261d94fd	1a6bdfd6-888d-44f7-8f49-eaa05b8af956	a04f5bc7-2636-4358-aae3-dc3e1c9968e3	profile_view	view	2025-12-14 00:18:37.563042
db4da7e8-c090-46f0-b4ca-d3caa303f85b	97dabb21-c5cd-434c-8bff-ae86b3682018	f1361a2d-c534-4cfd-81a0-796ed17b4339	profile_view	view	2025-12-15 10:13:15.773364
2cdd85ed-71ea-4396-b0c6-5040d48f4b4f	1a6bdfd6-888d-44f7-8f49-eaa05b8af956	f1361a2d-c534-4cfd-81a0-796ed17b4339	profile_view	view	2025-12-15 10:14:25.420052
\.


--
-- Data for Name: guarantor_documents; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.guarantor_documents (id, guarantor_id, document_type, file_name, file_path, uploaded_at) FROM stdin;
b125b5f8-567f-41f7-824e-1abb01e1b04a	f7e9fa57-7ec6-4619-bb6d-b6b79b3414e9	passport	akpabio_passport.jpg	https://res.cloudinary.com/desk7uuna/image/upload/v1765319123/ace_mall_staff/passport/yja6zpyyhwlfjx043car.pdf	2025-12-11 15:55:36.744848
f194120f-54f9-4129-96ba-2f8b52b658af	f7e9fa57-7ec6-4619-bb6d-b6b79b3414e9	national_id	akpabio_national_id.jpg	https://res.cloudinary.com/desk7uuna/image/upload/v1765319125/ace_mall_staff/national_id/fvev6auo3rga1gpqbvvs.pdf	2025-12-11 15:55:36.744848
ba114ffe-6cd4-489c-ae1d-405ae93c35fe	f7e9fa57-7ec6-4619-bb6d-b6b79b3414e9	work_id	akpabio_work_id.jpg	https://res.cloudinary.com/desk7uuna/image/upload/v1765319128/ace_mall_staff/birth_certificate/qwip7vbunlu0kmj8bagb.pdf	2025-12-11 15:55:36.744848
29c8639f-7489-40fe-87a9-61dc3686eed7	6e185b38-1354-4819-a1b5-de27ca2d4975	passport	kabiru_passport.jpg	https://res.cloudinary.com/desk7uuna/image/upload/v1765319152/ace_mall_staff/degree_certificate/uu5adv8yqnxgfgmlenin.jpg	2025-12-11 15:55:36.744848
50e5a456-fa38-45d3-a980-1d4d53ddbe87	6e185b38-1354-4819-a1b5-de27ca2d4975	national_id	kabiru_national_id.jpg	https://res.cloudinary.com/desk7uuna/image/upload/v1765319150/ace_mall_staff/nysc_certificate/rwxnol9zyabruunuasob.jpg	2025-12-11 15:55:36.744848
6b61fc41-8992-4b06-ab93-0e8011b9ab6a	6e185b38-1354-4819-a1b5-de27ca2d4975	work_id	kabiru_work_id.pdf	https://res.cloudinary.com/desk7uuna/image/upload/v1765304832/staff_documents/degree_certificate/ugbgemwloyrs1ianukkb.pdf	2025-12-11 15:55:36.744848
\.


--
-- Data for Name: guarantors; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.guarantors (id, user_id, guarantor_number, full_name, phone_number, email, occupation, relationship, home_address, sex, age, date_of_birth, grade_level, created_at, updated_at) FROM stdin;
f7e9fa57-7ec6-4619-bb6d-b6b79b3414e9	97dabb21-c5cd-434c-8bff-ae86b3682018	1	Akpabio simon	080546437846	akpabio@gmail.com	Senate president	Brother	asokoro Abuja	\N	\N	\N	\N	2025-12-10 12:44:29.354637	2025-12-10 12:44:29.354637
6e185b38-1354-4819-a1b5-de27ca2d4975	97dabb21-c5cd-434c-8bff-ae86b3682018	2	Kabiru Sokoto	0804643484	poro@gmail.com	House of assembly	uncle	asokoro,abuja	\N	\N	\N	\N	2025-12-10 12:44:29.355503	2025-12-10 12:44:29.355503
ebcfd27d-000c-4a2c-abfa-73bee42dfe33	8e57948f-983c-4db3-b517-a46b3d3531b3	1	ifeko ifure	0806464843	ife@gmail com	Doctor	wife	USA	\N	\N	\N	\N	2025-12-10 13:05:38.350245	2025-12-10 13:05:38.350245
f47b3d25-e228-4839-99e8-58abe5fc4cd7	8e57948f-983c-4db3-b517-a46b3d3531b3	2	Kabiru Sokoto	080764349464	kabiru@gmail.com	Politician	Uncle	abuja	\N	\N	\N	\N	2025-12-10 13:05:38.355099	2025-12-10 13:05:38.355099
\.


--
-- Data for Name: messages; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.messages (id, sender_id, title, content, target_type, target_branch_id, target_department_id, expires_at, created_at, updated_at) FROM stdin;
4ac8b00f-d8ef-4ee2-8e2d-1c5129df6a58	00feec4b-e498-452b-b081-cf480e16aec2	Test Message	This is a test message	all	\N	\N	2025-12-22 14:13:44.63917+01	2025-12-15 14:13:44.639612+01	2025-12-15 14:13:44.639612+01
272025de-4cde-4c41-a7d0-425556269e82	00feec4b-e498-452b-b081-cf480e16aec2	Test Message	This is a test message	all	\N	\N	2025-12-22 14:14:45.425466+01	2025-12-15 14:14:45.425789+01	2025-12-15 14:14:45.425789+01
9de49003-6a71-4f8a-b7ce-002c97ae9449	f1361a2d-c534-4cfd-81a0-796ed17b4339	Hello	say hiiii	all	\N	\N	2025-12-22 14:21:45.585523+01	2025-12-15 14:21:45.587625+01	2025-12-15 14:21:45.587625+01
56bd55d8-f8fe-49f8-b7eb-0cac7d581639	9f68aa0f-c6c7-4b73-a4d9-d3225b88c2f0	Hello	say hiiii	all	\N	\N	2025-12-22 14:31:55.035925+01	2025-12-15 14:31:55.037795+01	2025-12-15 14:31:55.037795+01
c878a3dd-f365-40e2-aea9-b58f96c6891f	a04f5bc7-2636-4358-aae3-dc3e1c9968e3	uyuyhuhj	gghghghg	all	\N	\N	2025-12-22 14:37:28.228208+01	2025-12-15 14:37:28.229244+01	2025-12-15 14:37:28.229244+01
119441b6-93ba-441c-bb86-5880cf45f708	a04f5bc7-2636-4358-aae3-dc3e1c9968e3	uyuyhuhj	gghghghg	all	\N	\N	2025-12-22 14:38:42.558643+01	2025-12-15 14:38:42.559369+01	2025-12-15 14:38:42.559369+01
ab66556f-de85-421b-a040-fdd31f561cff	a04f5bc7-2636-4358-aae3-dc3e1c9968e3	Babs Pop is here	what should we give him?	all	\N	\N	2025-12-22 14:40:23.873008+01	2025-12-15 14:40:23.875145+01	2025-12-15 14:40:23.875145+01
\.


--
-- Data for Name: next_of_kin; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.next_of_kin (id, user_id, full_name, relationship, email, phone_number, home_address, work_address, created_at, updated_at) FROM stdin;
35030c5a-4728-4df0-9677-b0e6c605bfe2	97dabb21-c5cd-434c-8bff-ae86b3682018	Remi Tinubu	Wife	remi@gmail.com	08046431866	Aso villa	office of the first lady	2025-12-10 12:44:29.353601	2025-12-10 12:44:29.353601
a07652b3-4e97-4eb7-8cde-ebf8ee7739b4	8e57948f-983c-4db3-b517-a46b3d3531b3	Dudu Yemu	Mother	dudu@gmail.com	08076464645	Abuja, Nigeria	Nass,Abuja	2025-12-10 13:05:38.34461	2025-12-10 13:05:38.34461
\.


--
-- Data for Name: notifications; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.notifications (id, user_id, type, title, message, is_read, created_at, message_id, expires_at, updated_at) FROM stdin;
1	e6bcd428-3711-4d17-80b4-5fab412563bd	promotion	Promotion Notification	Mr. Chukwuma Nwosu has promoted you to Floor Manager (SuperMarket)	f	2025-12-13 23:32:19.021042	\N	\N	2025-12-15 14:13:23.293949
2	710974ab-52fc-4726-b50a-b309d5b7d9ba	review	New Performance Review	Mr. Gbenga Afolabi has left a review for your performance (Rating: ⭐⭐⭐)	f	2025-12-14 00:56:12.283567	\N	\N	2025-12-15 14:13:23.293949
3	5eebb1da-4f4a-4422-9d3b-406c89f80c89	promotion	Promotion Notification	Chief Adebayo Williams has promoted you to Assistant Compliance Officer	f	2025-12-15 10:15:05.716629	\N	\N	2025-12-15 14:13:23.293949
4	b5d7896a-9217-480e-b4ac-8343141a3333	message	Test Message	This is a test message	f	2025-12-15 14:14:45.443475	272025de-4cde-4c41-a7d0-425556269e82	2025-12-22 14:14:45.428864+01	2025-12-15 14:14:45.443475
5	8e57948f-983c-4db3-b517-a46b3d3531b3	message	Test Message	This is a test message	f	2025-12-15 14:14:45.449536	272025de-4cde-4c41-a7d0-425556269e82	2025-12-22 14:14:45.428864+01	2025-12-15 14:14:45.449536
6	e6bcd428-3711-4d17-80b4-5fab412563bd	message	Test Message	This is a test message	f	2025-12-15 14:14:45.450109	272025de-4cde-4c41-a7d0-425556269e82	2025-12-22 14:14:45.428864+01	2025-12-15 14:14:45.450109
7	97dabb21-c5cd-434c-8bff-ae86b3682018	message	Test Message	This is a test message	f	2025-12-15 14:14:45.450897	272025de-4cde-4c41-a7d0-425556269e82	2025-12-22 14:14:45.428864+01	2025-12-15 14:14:45.450897
8	23a2c030-e381-40b0-885f-efe8c6ccf388	message	Test Message	This is a test message	f	2025-12-15 14:14:45.451355	272025de-4cde-4c41-a7d0-425556269e82	2025-12-22 14:14:45.428864+01	2025-12-15 14:14:45.451355
9	f50c5c53-dd6a-4380-9d6f-1410b29a7fa4	message	Test Message	This is a test message	f	2025-12-15 14:14:45.451812	272025de-4cde-4c41-a7d0-425556269e82	2025-12-22 14:14:45.428864+01	2025-12-15 14:14:45.451812
10	3edac621-15bc-43a1-9a09-19231b503c80	message	Test Message	This is a test message	f	2025-12-15 14:14:45.452249	272025de-4cde-4c41-a7d0-425556269e82	2025-12-22 14:14:45.428864+01	2025-12-15 14:14:45.452249
11	8ddcb7e7-9941-46bb-866b-6aae3a217a5d	message	Test Message	This is a test message	f	2025-12-15 14:14:45.452595	272025de-4cde-4c41-a7d0-425556269e82	2025-12-22 14:14:45.428864+01	2025-12-15 14:14:45.452595
12	2b9793bf-f240-4cf8-a94a-c4b652f0ae0b	message	Test Message	This is a test message	f	2025-12-15 14:14:45.45301	272025de-4cde-4c41-a7d0-425556269e82	2025-12-22 14:14:45.428864+01	2025-12-15 14:14:45.45301
13	710974ab-52fc-4726-b50a-b309d5b7d9ba	message	Test Message	This is a test message	f	2025-12-15 14:14:45.453556	272025de-4cde-4c41-a7d0-425556269e82	2025-12-22 14:14:45.428864+01	2025-12-15 14:14:45.453556
14	9f68aa0f-c6c7-4b73-a4d9-d3225b88c2f0	message	Test Message	This is a test message	f	2025-12-15 14:14:45.453915	272025de-4cde-4c41-a7d0-425556269e82	2025-12-22 14:14:45.428864+01	2025-12-15 14:14:45.453915
15	805b6158-8b01-4f05-90f2-a0fcad495cb9	message	Test Message	This is a test message	f	2025-12-15 14:14:45.454246	272025de-4cde-4c41-a7d0-425556269e82	2025-12-22 14:14:45.428864+01	2025-12-15 14:14:45.454246
16	a7a5977d-c912-4476-b8c1-89d6a6dec0ee	message	Test Message	This is a test message	f	2025-12-15 14:14:45.454572	272025de-4cde-4c41-a7d0-425556269e82	2025-12-22 14:14:45.428864+01	2025-12-15 14:14:45.454572
17	085df28e-fb49-420c-bea9-0432c9199f40	message	Test Message	This is a test message	f	2025-12-15 14:14:45.454895	272025de-4cde-4c41-a7d0-425556269e82	2025-12-22 14:14:45.428864+01	2025-12-15 14:14:45.454895
18	d2e4dc25-672a-485e-98b8-0126b3f10d28	message	Test Message	This is a test message	f	2025-12-15 14:14:45.455855	272025de-4cde-4c41-a7d0-425556269e82	2025-12-22 14:14:45.428864+01	2025-12-15 14:14:45.455855
19	61bd6a53-cd0b-4af7-9166-c8385d448f8f	message	Test Message	This is a test message	f	2025-12-15 14:14:45.45642	272025de-4cde-4c41-a7d0-425556269e82	2025-12-22 14:14:45.428864+01	2025-12-15 14:14:45.45642
20	891bbc40-a563-4fab-9ca0-a0defd6abbe3	message	Test Message	This is a test message	f	2025-12-15 14:14:45.457027	272025de-4cde-4c41-a7d0-425556269e82	2025-12-22 14:14:45.428864+01	2025-12-15 14:14:45.457027
21	81e8d990-cba5-41df-8c92-f74cdbc3a71a	message	Test Message	This is a test message	f	2025-12-15 14:14:45.457639	272025de-4cde-4c41-a7d0-425556269e82	2025-12-22 14:14:45.428864+01	2025-12-15 14:14:45.457639
22	e116ad22-a5f7-4bcd-9577-8b5f9beeaf46	message	Test Message	This is a test message	f	2025-12-15 14:14:45.458219	272025de-4cde-4c41-a7d0-425556269e82	2025-12-22 14:14:45.428864+01	2025-12-15 14:14:45.458219
23	9b40e7c8-5dde-4b3b-8574-4cdb3453fc31	message	Test Message	This is a test message	f	2025-12-15 14:14:45.458844	272025de-4cde-4c41-a7d0-425556269e82	2025-12-22 14:14:45.428864+01	2025-12-15 14:14:45.458844
24	8f675035-cc06-4b4e-89b6-db4f7c123ed2	message	Test Message	This is a test message	f	2025-12-15 14:14:45.459639	272025de-4cde-4c41-a7d0-425556269e82	2025-12-22 14:14:45.428864+01	2025-12-15 14:14:45.459639
25	376e41c2-4a6e-4010-ba3d-24eb0c509ada	message	Test Message	This is a test message	f	2025-12-15 14:14:45.46034	272025de-4cde-4c41-a7d0-425556269e82	2025-12-22 14:14:45.428864+01	2025-12-15 14:14:45.46034
26	091177fc-3b2c-4858-8ea0-b8f7206b4636	message	Test Message	This is a test message	f	2025-12-15 14:14:45.460992	272025de-4cde-4c41-a7d0-425556269e82	2025-12-22 14:14:45.428864+01	2025-12-15 14:14:45.460992
27	7ef2acf4-d876-4a29-b1f0-db8301f817a6	message	Test Message	This is a test message	f	2025-12-15 14:14:45.462359	272025de-4cde-4c41-a7d0-425556269e82	2025-12-22 14:14:45.428864+01	2025-12-15 14:14:45.462359
28	7b63533f-02f3-4491-9808-64ad90a92334	message	Test Message	This is a test message	f	2025-12-15 14:14:45.462993	272025de-4cde-4c41-a7d0-425556269e82	2025-12-22 14:14:45.428864+01	2025-12-15 14:14:45.462993
29	d2940649-78f0-4418-88b4-7b16a9a7104f	message	Test Message	This is a test message	f	2025-12-15 14:14:45.463545	272025de-4cde-4c41-a7d0-425556269e82	2025-12-22 14:14:45.428864+01	2025-12-15 14:14:45.463545
30	a8f9ccad-6eef-45ea-b1d9-9b24ec7ab5a9	message	Test Message	This is a test message	f	2025-12-15 14:14:45.464134	272025de-4cde-4c41-a7d0-425556269e82	2025-12-22 14:14:45.428864+01	2025-12-15 14:14:45.464134
31	b4801419-3838-4ac9-9c94-b05568dbf2b1	message	Test Message	This is a test message	f	2025-12-15 14:14:45.464748	272025de-4cde-4c41-a7d0-425556269e82	2025-12-22 14:14:45.428864+01	2025-12-15 14:14:45.464748
32	1eab9750-4824-4de4-8168-04591fc249f7	message	Test Message	This is a test message	f	2025-12-15 14:14:45.465211	272025de-4cde-4c41-a7d0-425556269e82	2025-12-22 14:14:45.428864+01	2025-12-15 14:14:45.465211
33	6315b233-5988-421f-9cb9-95a8b68e00ce	message	Test Message	This is a test message	f	2025-12-15 14:14:45.465558	272025de-4cde-4c41-a7d0-425556269e82	2025-12-22 14:14:45.428864+01	2025-12-15 14:14:45.465558
34	ca9c9dd0-bfd0-4436-b804-cfa549e732db	message	Test Message	This is a test message	f	2025-12-15 14:14:45.465947	272025de-4cde-4c41-a7d0-425556269e82	2025-12-22 14:14:45.428864+01	2025-12-15 14:14:45.465947
35	f6702e7d-fe35-4bc2-b78b-5a04809e886c	message	Test Message	This is a test message	f	2025-12-15 14:14:45.466491	272025de-4cde-4c41-a7d0-425556269e82	2025-12-22 14:14:45.428864+01	2025-12-15 14:14:45.466491
36	fbd7dcb6-7dc8-478a-ba23-6fae56403e81	message	Test Message	This is a test message	f	2025-12-15 14:14:45.466832	272025de-4cde-4c41-a7d0-425556269e82	2025-12-22 14:14:45.428864+01	2025-12-15 14:14:45.466832
37	5f3fb9c6-b104-40cb-b27e-ce123ebd7fa6	message	Test Message	This is a test message	f	2025-12-15 14:14:45.467141	272025de-4cde-4c41-a7d0-425556269e82	2025-12-22 14:14:45.428864+01	2025-12-15 14:14:45.467141
38	f8642d75-f69a-487d-b385-661ecf2fc8fc	message	Test Message	This is a test message	f	2025-12-15 14:14:45.467482	272025de-4cde-4c41-a7d0-425556269e82	2025-12-22 14:14:45.428864+01	2025-12-15 14:14:45.467482
39	3b4d200d-8f2c-45c8-a3ae-2816d06f208c	message	Test Message	This is a test message	f	2025-12-15 14:14:45.467823	272025de-4cde-4c41-a7d0-425556269e82	2025-12-22 14:14:45.428864+01	2025-12-15 14:14:45.467823
40	a1ba9ca9-d129-47c4-b6ff-1d3a5fd1e27d	message	Test Message	This is a test message	f	2025-12-15 14:14:45.46814	272025de-4cde-4c41-a7d0-425556269e82	2025-12-22 14:14:45.428864+01	2025-12-15 14:14:45.46814
41	7af931a9-9b6d-464c-928a-56556aa73171	message	Test Message	This is a test message	f	2025-12-15 14:14:45.468783	272025de-4cde-4c41-a7d0-425556269e82	2025-12-22 14:14:45.428864+01	2025-12-15 14:14:45.468783
42	87e45cfe-99c0-46bf-8ea4-a53fb3c757b0	message	Test Message	This is a test message	f	2025-12-15 14:14:45.469558	272025de-4cde-4c41-a7d0-425556269e82	2025-12-22 14:14:45.428864+01	2025-12-15 14:14:45.469558
43	d1b4bda9-e6d2-4b36-a87b-63b34b14a47a	message	Test Message	This is a test message	f	2025-12-15 14:14:45.469888	272025de-4cde-4c41-a7d0-425556269e82	2025-12-22 14:14:45.428864+01	2025-12-15 14:14:45.469888
44	df4b5622-d10a-4be6-b3b9-ae9eb365621f	message	Test Message	This is a test message	f	2025-12-15 14:14:45.470209	272025de-4cde-4c41-a7d0-425556269e82	2025-12-22 14:14:45.428864+01	2025-12-15 14:14:45.470209
45	89dbb74e-de3b-4d24-981c-7638797c1e36	message	Test Message	This is a test message	f	2025-12-15 14:14:45.470837	272025de-4cde-4c41-a7d0-425556269e82	2025-12-22 14:14:45.428864+01	2025-12-15 14:14:45.470837
46	c7733a6f-9d5d-4d39-a724-f85c9d24d139	message	Test Message	This is a test message	f	2025-12-15 14:14:45.471285	272025de-4cde-4c41-a7d0-425556269e82	2025-12-22 14:14:45.428864+01	2025-12-15 14:14:45.471285
47	f4d0a02a-8a68-4eb2-af6e-e4f055c356c1	message	Test Message	This is a test message	f	2025-12-15 14:14:45.471732	272025de-4cde-4c41-a7d0-425556269e82	2025-12-22 14:14:45.428864+01	2025-12-15 14:14:45.471732
48	822a2fa1-b223-4057-aabc-82e54feea196	message	Test Message	This is a test message	f	2025-12-15 14:14:45.472175	272025de-4cde-4c41-a7d0-425556269e82	2025-12-22 14:14:45.428864+01	2025-12-15 14:14:45.472175
49	409f5414-a30a-4090-84cc-73f477407968	message	Test Message	This is a test message	f	2025-12-15 14:14:45.472648	272025de-4cde-4c41-a7d0-425556269e82	2025-12-22 14:14:45.428864+01	2025-12-15 14:14:45.472648
50	0ccaa979-7837-46cf-9514-826710479042	message	Test Message	This is a test message	f	2025-12-15 14:14:45.473105	272025de-4cde-4c41-a7d0-425556269e82	2025-12-22 14:14:45.428864+01	2025-12-15 14:14:45.473105
51	41e8c3cb-f9a4-4f2e-a473-d47e060e89d3	message	Test Message	This is a test message	f	2025-12-15 14:14:45.473557	272025de-4cde-4c41-a7d0-425556269e82	2025-12-22 14:14:45.428864+01	2025-12-15 14:14:45.473557
52	a4b3302a-4c26-4b9e-9205-c726f5b548f0	message	Test Message	This is a test message	f	2025-12-15 14:14:45.474009	272025de-4cde-4c41-a7d0-425556269e82	2025-12-22 14:14:45.428864+01	2025-12-15 14:14:45.474009
53	64c22400-eb47-46b1-93fb-11110d7121f1	message	Test Message	This is a test message	f	2025-12-15 14:14:45.474457	272025de-4cde-4c41-a7d0-425556269e82	2025-12-22 14:14:45.428864+01	2025-12-15 14:14:45.474457
54	9d401424-6da4-4e9a-8568-00174cd56050	message	Test Message	This is a test message	f	2025-12-15 14:14:45.474901	272025de-4cde-4c41-a7d0-425556269e82	2025-12-22 14:14:45.428864+01	2025-12-15 14:14:45.474901
55	f1361a2d-c534-4cfd-81a0-796ed17b4339	message	Test Message	This is a test message	f	2025-12-15 14:14:45.475333	272025de-4cde-4c41-a7d0-425556269e82	2025-12-22 14:14:45.428864+01	2025-12-15 14:14:45.475333
57	02762b1e-9b2f-4bfe-943c-d6c28827ef96	message	Test Message	This is a test message	f	2025-12-15 14:14:45.476211	272025de-4cde-4c41-a7d0-425556269e82	2025-12-22 14:14:45.428864+01	2025-12-15 14:14:45.476211
58	86407ed7-40bf-4420-9053-f64c6121188e	message	Test Message	This is a test message	f	2025-12-15 14:14:45.476598	272025de-4cde-4c41-a7d0-425556269e82	2025-12-22 14:14:45.428864+01	2025-12-15 14:14:45.476598
59	22d26f27-6768-43ec-b08e-4b20b924b76f	message	Test Message	This is a test message	f	2025-12-15 14:14:45.478485	272025de-4cde-4c41-a7d0-425556269e82	2025-12-22 14:14:45.428864+01	2025-12-15 14:14:45.478485
60	c2b365e0-5404-4d85-b9e1-515e0cd9afe9	message	Test Message	This is a test message	f	2025-12-15 14:14:45.478887	272025de-4cde-4c41-a7d0-425556269e82	2025-12-22 14:14:45.428864+01	2025-12-15 14:14:45.478887
61	aefab581-f8c3-42a0-b79a-55d0270f3d00	message	Test Message	This is a test message	f	2025-12-15 14:14:45.479281	272025de-4cde-4c41-a7d0-425556269e82	2025-12-22 14:14:45.428864+01	2025-12-15 14:14:45.479281
62	5be8065b-44d4-4fab-aa82-b64bda2b368a	message	Test Message	This is a test message	f	2025-12-15 14:14:45.479676	272025de-4cde-4c41-a7d0-425556269e82	2025-12-22 14:14:45.428864+01	2025-12-15 14:14:45.479676
63	d9df9370-0442-4365-9ed0-3b59afc81ec1	message	Test Message	This is a test message	f	2025-12-15 14:14:45.480088	272025de-4cde-4c41-a7d0-425556269e82	2025-12-22 14:14:45.428864+01	2025-12-15 14:14:45.480088
64	9c77950e-3ebc-4846-aed1-2faae86cbb37	message	Test Message	This is a test message	f	2025-12-15 14:14:45.480406	272025de-4cde-4c41-a7d0-425556269e82	2025-12-22 14:14:45.428864+01	2025-12-15 14:14:45.480406
65	66024a16-884c-408e-bead-dd134927a58a	message	Test Message	This is a test message	f	2025-12-15 14:14:45.481	272025de-4cde-4c41-a7d0-425556269e82	2025-12-22 14:14:45.428864+01	2025-12-15 14:14:45.481
66	c6fa2131-7fea-459e-9df8-2ff37f1a39bb	message	Test Message	This is a test message	f	2025-12-15 14:14:45.481347	272025de-4cde-4c41-a7d0-425556269e82	2025-12-22 14:14:45.428864+01	2025-12-15 14:14:45.481347
67	694655b7-cfa9-418e-9f29-1753df0adbfd	message	Test Message	This is a test message	f	2025-12-15 14:14:45.481832	272025de-4cde-4c41-a7d0-425556269e82	2025-12-22 14:14:45.428864+01	2025-12-15 14:14:45.481832
68	c84d7da8-2f5e-4123-85c5-989ba74e3520	message	Test Message	This is a test message	f	2025-12-15 14:14:45.482189	272025de-4cde-4c41-a7d0-425556269e82	2025-12-22 14:14:45.428864+01	2025-12-15 14:14:45.482189
69	c58f03b5-12e4-45c5-b71d-21ffeb6b0c40	message	Test Message	This is a test message	f	2025-12-15 14:14:45.482489	272025de-4cde-4c41-a7d0-425556269e82	2025-12-22 14:14:45.428864+01	2025-12-15 14:14:45.482489
70	905773e4-02be-4a57-9046-7bd29db1fa03	message	Test Message	This is a test message	f	2025-12-15 14:14:45.482835	272025de-4cde-4c41-a7d0-425556269e82	2025-12-22 14:14:45.428864+01	2025-12-15 14:14:45.482835
71	243a4471-81e9-469e-ae44-7685b225e07b	message	Test Message	This is a test message	f	2025-12-15 14:14:45.483492	272025de-4cde-4c41-a7d0-425556269e82	2025-12-22 14:14:45.428864+01	2025-12-15 14:14:45.483492
72	afb04864-9ab2-4994-918c-397a2a035d84	message	Test Message	This is a test message	f	2025-12-15 14:14:45.484431	272025de-4cde-4c41-a7d0-425556269e82	2025-12-22 14:14:45.428864+01	2025-12-15 14:14:45.484431
73	5c39ac09-558d-4836-9bb6-f1de81d58f9d	message	Test Message	This is a test message	f	2025-12-15 14:14:45.484766	272025de-4cde-4c41-a7d0-425556269e82	2025-12-22 14:14:45.428864+01	2025-12-15 14:14:45.484766
74	3f324c9c-7c0d-4dbc-8c49-cd943f36fc27	message	Test Message	This is a test message	f	2025-12-15 14:14:45.485089	272025de-4cde-4c41-a7d0-425556269e82	2025-12-22 14:14:45.428864+01	2025-12-15 14:14:45.485089
75	2a643039-c6a0-4791-b022-07b0fbfddd3a	message	Test Message	This is a test message	f	2025-12-15 14:14:45.485522	272025de-4cde-4c41-a7d0-425556269e82	2025-12-22 14:14:45.428864+01	2025-12-15 14:14:45.485522
76	020e710e-e419-4c74-9848-3b00770353c6	message	Test Message	This is a test message	f	2025-12-15 14:14:45.485875	272025de-4cde-4c41-a7d0-425556269e82	2025-12-22 14:14:45.428864+01	2025-12-15 14:14:45.485875
77	f4d858f5-58b1-4727-96d5-5b27be00ebbe	message	Test Message	This is a test message	f	2025-12-15 14:14:45.486539	272025de-4cde-4c41-a7d0-425556269e82	2025-12-22 14:14:45.428864+01	2025-12-15 14:14:45.486539
78	1ca1e403-5ac5-495e-86b5-0e60c397393b	message	Test Message	This is a test message	f	2025-12-15 14:14:45.486837	272025de-4cde-4c41-a7d0-425556269e82	2025-12-22 14:14:45.428864+01	2025-12-15 14:14:45.486837
79	9b36ebb6-1b40-4fa5-8fad-736b04b5b4ea	message	Test Message	This is a test message	f	2025-12-15 14:14:45.487153	272025de-4cde-4c41-a7d0-425556269e82	2025-12-22 14:14:45.428864+01	2025-12-15 14:14:45.487153
80	03613595-b764-4cb5-9d23-ebb2055a9fe1	message	Test Message	This is a test message	f	2025-12-15 14:14:45.487472	272025de-4cde-4c41-a7d0-425556269e82	2025-12-22 14:14:45.428864+01	2025-12-15 14:14:45.487472
81	59775d98-8c8e-4a7b-99ed-11920c2bd80b	message	Test Message	This is a test message	f	2025-12-15 14:14:45.487831	272025de-4cde-4c41-a7d0-425556269e82	2025-12-22 14:14:45.428864+01	2025-12-15 14:14:45.487831
82	b6ac4b5c-2caf-4bd6-83e9-ae3d7df27970	message	Test Message	This is a test message	f	2025-12-15 14:14:45.488158	272025de-4cde-4c41-a7d0-425556269e82	2025-12-22 14:14:45.428864+01	2025-12-15 14:14:45.488158
83	5738ce10-3634-42f7-91d7-91f21cfb64f3	message	Test Message	This is a test message	f	2025-12-15 14:14:45.488455	272025de-4cde-4c41-a7d0-425556269e82	2025-12-22 14:14:45.428864+01	2025-12-15 14:14:45.488455
84	a4f64b75-1bbe-4fb1-80d5-f441b6b9bee2	message	Test Message	This is a test message	f	2025-12-15 14:14:45.488779	272025de-4cde-4c41-a7d0-425556269e82	2025-12-22 14:14:45.428864+01	2025-12-15 14:14:45.488779
86	9a2b27aa-e90a-4409-8373-2be363ee206e	message	Test Message	This is a test message	f	2025-12-15 14:14:45.48941	272025de-4cde-4c41-a7d0-425556269e82	2025-12-22 14:14:45.428864+01	2025-12-15 14:14:45.48941
87	34d7356b-9cea-4a80-a7be-93d7def7d260	message	Test Message	This is a test message	f	2025-12-15 14:14:45.489736	272025de-4cde-4c41-a7d0-425556269e82	2025-12-22 14:14:45.428864+01	2025-12-15 14:14:45.489736
88	489473cf-735a-4831-ac2a-f94ce58afca4	message	Test Message	This is a test message	f	2025-12-15 14:14:45.490032	272025de-4cde-4c41-a7d0-425556269e82	2025-12-22 14:14:45.428864+01	2025-12-15 14:14:45.490032
89	412e9a12-7529-4bc7-85c7-f88df5e191d1	message	Test Message	This is a test message	f	2025-12-15 14:14:45.490312	272025de-4cde-4c41-a7d0-425556269e82	2025-12-22 14:14:45.428864+01	2025-12-15 14:14:45.490312
90	c492c079-7db5-4261-9983-2492048902eb	message	Test Message	This is a test message	f	2025-12-15 14:14:45.490587	272025de-4cde-4c41-a7d0-425556269e82	2025-12-22 14:14:45.428864+01	2025-12-15 14:14:45.490587
91	aecbb92c-bbe9-4a05-9dc2-a1f290e41deb	message	Test Message	This is a test message	f	2025-12-15 14:14:45.491147	272025de-4cde-4c41-a7d0-425556269e82	2025-12-22 14:14:45.428864+01	2025-12-15 14:14:45.491147
92	fac4c4eb-47c1-4552-9e92-3f24ca63a922	message	Test Message	This is a test message	f	2025-12-15 14:14:45.491471	272025de-4cde-4c41-a7d0-425556269e82	2025-12-22 14:14:45.428864+01	2025-12-15 14:14:45.491471
93	552e83ca-0eaa-4d94-87aa-9c4958aa811e	message	Test Message	This is a test message	f	2025-12-15 14:14:45.491797	272025de-4cde-4c41-a7d0-425556269e82	2025-12-22 14:14:45.428864+01	2025-12-15 14:14:45.491797
94	544e6fb5-b91e-43be-89f6-90546a7f0669	message	Test Message	This is a test message	f	2025-12-15 14:14:45.492102	272025de-4cde-4c41-a7d0-425556269e82	2025-12-22 14:14:45.428864+01	2025-12-15 14:14:45.492102
95	e001d25d-7ef8-44c7-8213-2777aa595970	message	Test Message	This is a test message	f	2025-12-15 14:14:45.492406	272025de-4cde-4c41-a7d0-425556269e82	2025-12-22 14:14:45.428864+01	2025-12-15 14:14:45.492406
96	1d71f3e9-7f85-49b8-a65e-b9c819ad19cb	message	Test Message	This is a test message	f	2025-12-15 14:14:45.492754	272025de-4cde-4c41-a7d0-425556269e82	2025-12-22 14:14:45.428864+01	2025-12-15 14:14:45.492754
97	1ebbf9f9-6184-4687-a5cf-a5b7c6d11717	message	Test Message	This is a test message	f	2025-12-15 14:14:45.493099	272025de-4cde-4c41-a7d0-425556269e82	2025-12-22 14:14:45.428864+01	2025-12-15 14:14:45.493099
98	c848bf8a-43a8-4d05-94cc-9d5033405cd7	message	Test Message	This is a test message	f	2025-12-15 14:14:45.493442	272025de-4cde-4c41-a7d0-425556269e82	2025-12-22 14:14:45.428864+01	2025-12-15 14:14:45.493442
99	0919939d-1f4b-485c-b66e-1c24d710930d	message	Test Message	This is a test message	f	2025-12-15 14:14:45.493777	272025de-4cde-4c41-a7d0-425556269e82	2025-12-22 14:14:45.428864+01	2025-12-15 14:14:45.493777
100	8c59a07a-41dc-4d55-b55b-f82800569e9c	message	Test Message	This is a test message	f	2025-12-15 14:14:45.494108	272025de-4cde-4c41-a7d0-425556269e82	2025-12-22 14:14:45.428864+01	2025-12-15 14:14:45.494108
101	6392ac81-e8b5-4b27-a2dc-b0a34a449659	message	Test Message	This is a test message	f	2025-12-15 14:14:45.494451	272025de-4cde-4c41-a7d0-425556269e82	2025-12-22 14:14:45.428864+01	2025-12-15 14:14:45.494451
102	b45f33f6-4f98-4d00-af3d-6bae657c2deb	message	Test Message	This is a test message	f	2025-12-15 14:14:45.4948	272025de-4cde-4c41-a7d0-425556269e82	2025-12-22 14:14:45.428864+01	2025-12-15 14:14:45.4948
103	1e193b09-87bc-48c4-b666-94f910cf5882	message	Test Message	This is a test message	f	2025-12-15 14:14:45.495142	272025de-4cde-4c41-a7d0-425556269e82	2025-12-22 14:14:45.428864+01	2025-12-15 14:14:45.495142
104	cebe720e-d2f1-4b0e-9107-4da7b543fe4b	message	Test Message	This is a test message	f	2025-12-15 14:14:45.495485	272025de-4cde-4c41-a7d0-425556269e82	2025-12-22 14:14:45.428864+01	2025-12-15 14:14:45.495485
105	1a6bdfd6-888d-44f7-8f49-eaa05b8af956	message	Test Message	This is a test message	f	2025-12-15 14:14:45.495827	272025de-4cde-4c41-a7d0-425556269e82	2025-12-22 14:14:45.428864+01	2025-12-15 14:14:45.495827
106	5eebb1da-4f4a-4422-9d3b-406c89f80c89	message	Test Message	This is a test message	f	2025-12-15 14:14:45.496172	272025de-4cde-4c41-a7d0-425556269e82	2025-12-22 14:14:45.428864+01	2025-12-15 14:14:45.496172
107	b5d7896a-9217-480e-b4ac-8343141a3333	message	Hello	say hiiii	f	2025-12-15 14:21:45.614978	9de49003-6a71-4f8a-b7ce-002c97ae9449	2025-12-22 14:21:45.59271+01	2025-12-15 14:21:45.614978
108	8e57948f-983c-4db3-b517-a46b3d3531b3	message	Hello	say hiiii	f	2025-12-15 14:21:45.625726	9de49003-6a71-4f8a-b7ce-002c97ae9449	2025-12-22 14:21:45.59271+01	2025-12-15 14:21:45.625726
109	e6bcd428-3711-4d17-80b4-5fab412563bd	message	Hello	say hiiii	f	2025-12-15 14:21:45.626435	9de49003-6a71-4f8a-b7ce-002c97ae9449	2025-12-22 14:21:45.59271+01	2025-12-15 14:21:45.626435
110	97dabb21-c5cd-434c-8bff-ae86b3682018	message	Hello	say hiiii	f	2025-12-15 14:21:45.627016	9de49003-6a71-4f8a-b7ce-002c97ae9449	2025-12-22 14:21:45.59271+01	2025-12-15 14:21:45.627016
111	23a2c030-e381-40b0-885f-efe8c6ccf388	message	Hello	say hiiii	f	2025-12-15 14:21:45.627437	9de49003-6a71-4f8a-b7ce-002c97ae9449	2025-12-22 14:21:45.59271+01	2025-12-15 14:21:45.627437
112	f50c5c53-dd6a-4380-9d6f-1410b29a7fa4	message	Hello	say hiiii	f	2025-12-15 14:21:45.627841	9de49003-6a71-4f8a-b7ce-002c97ae9449	2025-12-22 14:21:45.59271+01	2025-12-15 14:21:45.627841
113	3edac621-15bc-43a1-9a09-19231b503c80	message	Hello	say hiiii	f	2025-12-15 14:21:45.628201	9de49003-6a71-4f8a-b7ce-002c97ae9449	2025-12-22 14:21:45.59271+01	2025-12-15 14:21:45.628201
114	8ddcb7e7-9941-46bb-866b-6aae3a217a5d	message	Hello	say hiiii	f	2025-12-15 14:21:45.6285	9de49003-6a71-4f8a-b7ce-002c97ae9449	2025-12-22 14:21:45.59271+01	2025-12-15 14:21:45.6285
115	2b9793bf-f240-4cf8-a94a-c4b652f0ae0b	message	Hello	say hiiii	f	2025-12-15 14:21:45.628815	9de49003-6a71-4f8a-b7ce-002c97ae9449	2025-12-22 14:21:45.59271+01	2025-12-15 14:21:45.628815
116	710974ab-52fc-4726-b50a-b309d5b7d9ba	message	Hello	say hiiii	f	2025-12-15 14:21:45.629331	9de49003-6a71-4f8a-b7ce-002c97ae9449	2025-12-22 14:21:45.59271+01	2025-12-15 14:21:45.629331
117	9f68aa0f-c6c7-4b73-a4d9-d3225b88c2f0	message	Hello	say hiiii	f	2025-12-15 14:21:45.629647	9de49003-6a71-4f8a-b7ce-002c97ae9449	2025-12-22 14:21:45.59271+01	2025-12-15 14:21:45.629647
118	805b6158-8b01-4f05-90f2-a0fcad495cb9	message	Hello	say hiiii	f	2025-12-15 14:21:45.629955	9de49003-6a71-4f8a-b7ce-002c97ae9449	2025-12-22 14:21:45.59271+01	2025-12-15 14:21:45.629955
119	a7a5977d-c912-4476-b8c1-89d6a6dec0ee	message	Hello	say hiiii	f	2025-12-15 14:21:45.632839	9de49003-6a71-4f8a-b7ce-002c97ae9449	2025-12-22 14:21:45.59271+01	2025-12-15 14:21:45.632839
120	085df28e-fb49-420c-bea9-0432c9199f40	message	Hello	say hiiii	f	2025-12-15 14:21:45.634702	9de49003-6a71-4f8a-b7ce-002c97ae9449	2025-12-22 14:21:45.59271+01	2025-12-15 14:21:45.634702
121	d2e4dc25-672a-485e-98b8-0126b3f10d28	message	Hello	say hiiii	f	2025-12-15 14:21:45.635304	9de49003-6a71-4f8a-b7ce-002c97ae9449	2025-12-22 14:21:45.59271+01	2025-12-15 14:21:45.635304
122	61bd6a53-cd0b-4af7-9166-c8385d448f8f	message	Hello	say hiiii	f	2025-12-15 14:21:45.635784	9de49003-6a71-4f8a-b7ce-002c97ae9449	2025-12-22 14:21:45.59271+01	2025-12-15 14:21:45.635784
123	891bbc40-a563-4fab-9ca0-a0defd6abbe3	message	Hello	say hiiii	f	2025-12-15 14:21:45.636219	9de49003-6a71-4f8a-b7ce-002c97ae9449	2025-12-22 14:21:45.59271+01	2025-12-15 14:21:45.636219
124	81e8d990-cba5-41df-8c92-f74cdbc3a71a	message	Hello	say hiiii	f	2025-12-15 14:21:45.636773	9de49003-6a71-4f8a-b7ce-002c97ae9449	2025-12-22 14:21:45.59271+01	2025-12-15 14:21:45.636773
125	e116ad22-a5f7-4bcd-9577-8b5f9beeaf46	message	Hello	say hiiii	f	2025-12-15 14:21:45.637238	9de49003-6a71-4f8a-b7ce-002c97ae9449	2025-12-22 14:21:45.59271+01	2025-12-15 14:21:45.637238
126	9b40e7c8-5dde-4b3b-8574-4cdb3453fc31	message	Hello	say hiiii	f	2025-12-15 14:21:45.638411	9de49003-6a71-4f8a-b7ce-002c97ae9449	2025-12-22 14:21:45.59271+01	2025-12-15 14:21:45.638411
127	8f675035-cc06-4b4e-89b6-db4f7c123ed2	message	Hello	say hiiii	f	2025-12-15 14:21:45.639067	9de49003-6a71-4f8a-b7ce-002c97ae9449	2025-12-22 14:21:45.59271+01	2025-12-15 14:21:45.639067
128	376e41c2-4a6e-4010-ba3d-24eb0c509ada	message	Hello	say hiiii	f	2025-12-15 14:21:45.639425	9de49003-6a71-4f8a-b7ce-002c97ae9449	2025-12-22 14:21:45.59271+01	2025-12-15 14:21:45.639425
129	091177fc-3b2c-4858-8ea0-b8f7206b4636	message	Hello	say hiiii	f	2025-12-15 14:21:45.639792	9de49003-6a71-4f8a-b7ce-002c97ae9449	2025-12-22 14:21:45.59271+01	2025-12-15 14:21:45.639792
130	7ef2acf4-d876-4a29-b1f0-db8301f817a6	message	Hello	say hiiii	f	2025-12-15 14:21:45.640577	9de49003-6a71-4f8a-b7ce-002c97ae9449	2025-12-22 14:21:45.59271+01	2025-12-15 14:21:45.640577
131	7b63533f-02f3-4491-9808-64ad90a92334	message	Hello	say hiiii	f	2025-12-15 14:21:45.641022	9de49003-6a71-4f8a-b7ce-002c97ae9449	2025-12-22 14:21:45.59271+01	2025-12-15 14:21:45.641022
132	d2940649-78f0-4418-88b4-7b16a9a7104f	message	Hello	say hiiii	f	2025-12-15 14:21:45.642534	9de49003-6a71-4f8a-b7ce-002c97ae9449	2025-12-22 14:21:45.59271+01	2025-12-15 14:21:45.642534
133	a8f9ccad-6eef-45ea-b1d9-9b24ec7ab5a9	message	Hello	say hiiii	f	2025-12-15 14:21:45.642942	9de49003-6a71-4f8a-b7ce-002c97ae9449	2025-12-22 14:21:45.59271+01	2025-12-15 14:21:45.642942
134	b4801419-3838-4ac9-9c94-b05568dbf2b1	message	Hello	say hiiii	f	2025-12-15 14:21:45.64331	9de49003-6a71-4f8a-b7ce-002c97ae9449	2025-12-22 14:21:45.59271+01	2025-12-15 14:21:45.64331
135	1eab9750-4824-4de4-8168-04591fc249f7	message	Hello	say hiiii	f	2025-12-15 14:21:45.643636	9de49003-6a71-4f8a-b7ce-002c97ae9449	2025-12-22 14:21:45.59271+01	2025-12-15 14:21:45.643636
136	6315b233-5988-421f-9cb9-95a8b68e00ce	message	Hello	say hiiii	f	2025-12-15 14:21:45.644097	9de49003-6a71-4f8a-b7ce-002c97ae9449	2025-12-22 14:21:45.59271+01	2025-12-15 14:21:45.644097
137	ca9c9dd0-bfd0-4436-b804-cfa549e732db	message	Hello	say hiiii	f	2025-12-15 14:21:45.644431	9de49003-6a71-4f8a-b7ce-002c97ae9449	2025-12-22 14:21:45.59271+01	2025-12-15 14:21:45.644431
138	f6702e7d-fe35-4bc2-b78b-5a04809e886c	message	Hello	say hiiii	f	2025-12-15 14:21:45.645241	9de49003-6a71-4f8a-b7ce-002c97ae9449	2025-12-22 14:21:45.59271+01	2025-12-15 14:21:45.645241
139	fbd7dcb6-7dc8-478a-ba23-6fae56403e81	message	Hello	say hiiii	f	2025-12-15 14:21:45.645552	9de49003-6a71-4f8a-b7ce-002c97ae9449	2025-12-22 14:21:45.59271+01	2025-12-15 14:21:45.645552
140	5f3fb9c6-b104-40cb-b27e-ce123ebd7fa6	message	Hello	say hiiii	f	2025-12-15 14:21:45.645832	9de49003-6a71-4f8a-b7ce-002c97ae9449	2025-12-22 14:21:45.59271+01	2025-12-15 14:21:45.645832
141	f8642d75-f69a-487d-b385-661ecf2fc8fc	message	Hello	say hiiii	f	2025-12-15 14:21:45.646136	9de49003-6a71-4f8a-b7ce-002c97ae9449	2025-12-22 14:21:45.59271+01	2025-12-15 14:21:45.646136
142	3b4d200d-8f2c-45c8-a3ae-2816d06f208c	message	Hello	say hiiii	f	2025-12-15 14:21:45.646463	9de49003-6a71-4f8a-b7ce-002c97ae9449	2025-12-22 14:21:45.59271+01	2025-12-15 14:21:45.646463
143	a1ba9ca9-d129-47c4-b6ff-1d3a5fd1e27d	message	Hello	say hiiii	f	2025-12-15 14:21:45.646795	9de49003-6a71-4f8a-b7ce-002c97ae9449	2025-12-22 14:21:45.59271+01	2025-12-15 14:21:45.646795
144	7af931a9-9b6d-464c-928a-56556aa73171	message	Hello	say hiiii	f	2025-12-15 14:21:45.647088	9de49003-6a71-4f8a-b7ce-002c97ae9449	2025-12-22 14:21:45.59271+01	2025-12-15 14:21:45.647088
145	87e45cfe-99c0-46bf-8ea4-a53fb3c757b0	message	Hello	say hiiii	f	2025-12-15 14:21:45.64739	9de49003-6a71-4f8a-b7ce-002c97ae9449	2025-12-22 14:21:45.59271+01	2025-12-15 14:21:45.64739
146	d1b4bda9-e6d2-4b36-a87b-63b34b14a47a	message	Hello	say hiiii	f	2025-12-15 14:21:45.64771	9de49003-6a71-4f8a-b7ce-002c97ae9449	2025-12-22 14:21:45.59271+01	2025-12-15 14:21:45.64771
147	df4b5622-d10a-4be6-b3b9-ae9eb365621f	message	Hello	say hiiii	f	2025-12-15 14:21:45.648075	9de49003-6a71-4f8a-b7ce-002c97ae9449	2025-12-22 14:21:45.59271+01	2025-12-15 14:21:45.648075
148	89dbb74e-de3b-4d24-981c-7638797c1e36	message	Hello	say hiiii	f	2025-12-15 14:21:45.648454	9de49003-6a71-4f8a-b7ce-002c97ae9449	2025-12-22 14:21:45.59271+01	2025-12-15 14:21:45.648454
149	c7733a6f-9d5d-4d39-a724-f85c9d24d139	message	Hello	say hiiii	f	2025-12-15 14:21:45.648984	9de49003-6a71-4f8a-b7ce-002c97ae9449	2025-12-22 14:21:45.59271+01	2025-12-15 14:21:45.648984
150	f4d0a02a-8a68-4eb2-af6e-e4f055c356c1	message	Hello	say hiiii	f	2025-12-15 14:21:45.649355	9de49003-6a71-4f8a-b7ce-002c97ae9449	2025-12-22 14:21:45.59271+01	2025-12-15 14:21:45.649355
151	822a2fa1-b223-4057-aabc-82e54feea196	message	Hello	say hiiii	f	2025-12-15 14:21:45.649859	9de49003-6a71-4f8a-b7ce-002c97ae9449	2025-12-22 14:21:45.59271+01	2025-12-15 14:21:45.649859
152	409f5414-a30a-4090-84cc-73f477407968	message	Hello	say hiiii	f	2025-12-15 14:21:45.650408	9de49003-6a71-4f8a-b7ce-002c97ae9449	2025-12-22 14:21:45.59271+01	2025-12-15 14:21:45.650408
153	0ccaa979-7837-46cf-9514-826710479042	message	Hello	say hiiii	f	2025-12-15 14:21:45.651062	9de49003-6a71-4f8a-b7ce-002c97ae9449	2025-12-22 14:21:45.59271+01	2025-12-15 14:21:45.651062
154	41e8c3cb-f9a4-4f2e-a473-d47e060e89d3	message	Hello	say hiiii	f	2025-12-15 14:21:45.651511	9de49003-6a71-4f8a-b7ce-002c97ae9449	2025-12-22 14:21:45.59271+01	2025-12-15 14:21:45.651511
155	a4b3302a-4c26-4b9e-9205-c726f5b548f0	message	Hello	say hiiii	f	2025-12-15 14:21:45.651843	9de49003-6a71-4f8a-b7ce-002c97ae9449	2025-12-22 14:21:45.59271+01	2025-12-15 14:21:45.651843
156	64c22400-eb47-46b1-93fb-11110d7121f1	message	Hello	say hiiii	f	2025-12-15 14:21:45.652149	9de49003-6a71-4f8a-b7ce-002c97ae9449	2025-12-22 14:21:45.59271+01	2025-12-15 14:21:45.652149
157	9d401424-6da4-4e9a-8568-00174cd56050	message	Hello	say hiiii	f	2025-12-15 14:21:45.652372	9de49003-6a71-4f8a-b7ce-002c97ae9449	2025-12-22 14:21:45.59271+01	2025-12-15 14:21:45.652372
158	00feec4b-e498-452b-b081-cf480e16aec2	message	Hello	say hiiii	f	2025-12-15 14:21:45.652623	9de49003-6a71-4f8a-b7ce-002c97ae9449	2025-12-22 14:21:45.59271+01	2025-12-15 14:21:45.652623
160	02762b1e-9b2f-4bfe-943c-d6c28827ef96	message	Hello	say hiiii	f	2025-12-15 14:21:45.653102	9de49003-6a71-4f8a-b7ce-002c97ae9449	2025-12-22 14:21:45.59271+01	2025-12-15 14:21:45.653102
161	86407ed7-40bf-4420-9053-f64c6121188e	message	Hello	say hiiii	f	2025-12-15 14:21:45.653338	9de49003-6a71-4f8a-b7ce-002c97ae9449	2025-12-22 14:21:45.59271+01	2025-12-15 14:21:45.653338
162	22d26f27-6768-43ec-b08e-4b20b924b76f	message	Hello	say hiiii	f	2025-12-15 14:21:45.653547	9de49003-6a71-4f8a-b7ce-002c97ae9449	2025-12-22 14:21:45.59271+01	2025-12-15 14:21:45.653547
163	c2b365e0-5404-4d85-b9e1-515e0cd9afe9	message	Hello	say hiiii	f	2025-12-15 14:21:45.653796	9de49003-6a71-4f8a-b7ce-002c97ae9449	2025-12-22 14:21:45.59271+01	2025-12-15 14:21:45.653796
164	aefab581-f8c3-42a0-b79a-55d0270f3d00	message	Hello	say hiiii	f	2025-12-15 14:21:45.654047	9de49003-6a71-4f8a-b7ce-002c97ae9449	2025-12-22 14:21:45.59271+01	2025-12-15 14:21:45.654047
165	5be8065b-44d4-4fab-aa82-b64bda2b368a	message	Hello	say hiiii	f	2025-12-15 14:21:45.655935	9de49003-6a71-4f8a-b7ce-002c97ae9449	2025-12-22 14:21:45.59271+01	2025-12-15 14:21:45.655935
166	d9df9370-0442-4365-9ed0-3b59afc81ec1	message	Hello	say hiiii	f	2025-12-15 14:21:45.65647	9de49003-6a71-4f8a-b7ce-002c97ae9449	2025-12-22 14:21:45.59271+01	2025-12-15 14:21:45.65647
167	9c77950e-3ebc-4846-aed1-2faae86cbb37	message	Hello	say hiiii	f	2025-12-15 14:21:45.656975	9de49003-6a71-4f8a-b7ce-002c97ae9449	2025-12-22 14:21:45.59271+01	2025-12-15 14:21:45.656975
168	66024a16-884c-408e-bead-dd134927a58a	message	Hello	say hiiii	f	2025-12-15 14:21:45.657357	9de49003-6a71-4f8a-b7ce-002c97ae9449	2025-12-22 14:21:45.59271+01	2025-12-15 14:21:45.657357
169	c6fa2131-7fea-459e-9df8-2ff37f1a39bb	message	Hello	say hiiii	f	2025-12-15 14:21:45.657754	9de49003-6a71-4f8a-b7ce-002c97ae9449	2025-12-22 14:21:45.59271+01	2025-12-15 14:21:45.657754
170	694655b7-cfa9-418e-9f29-1753df0adbfd	message	Hello	say hiiii	f	2025-12-15 14:21:45.658123	9de49003-6a71-4f8a-b7ce-002c97ae9449	2025-12-22 14:21:45.59271+01	2025-12-15 14:21:45.658123
171	c84d7da8-2f5e-4123-85c5-989ba74e3520	message	Hello	say hiiii	f	2025-12-15 14:21:45.658536	9de49003-6a71-4f8a-b7ce-002c97ae9449	2025-12-22 14:21:45.59271+01	2025-12-15 14:21:45.658536
172	c58f03b5-12e4-45c5-b71d-21ffeb6b0c40	message	Hello	say hiiii	f	2025-12-15 14:21:45.658902	9de49003-6a71-4f8a-b7ce-002c97ae9449	2025-12-22 14:21:45.59271+01	2025-12-15 14:21:45.658902
173	905773e4-02be-4a57-9046-7bd29db1fa03	message	Hello	say hiiii	f	2025-12-15 14:21:45.659231	9de49003-6a71-4f8a-b7ce-002c97ae9449	2025-12-22 14:21:45.59271+01	2025-12-15 14:21:45.659231
174	243a4471-81e9-469e-ae44-7685b225e07b	message	Hello	say hiiii	f	2025-12-15 14:21:45.659523	9de49003-6a71-4f8a-b7ce-002c97ae9449	2025-12-22 14:21:45.59271+01	2025-12-15 14:21:45.659523
175	afb04864-9ab2-4994-918c-397a2a035d84	message	Hello	say hiiii	f	2025-12-15 14:21:45.659745	9de49003-6a71-4f8a-b7ce-002c97ae9449	2025-12-22 14:21:45.59271+01	2025-12-15 14:21:45.659745
176	5c39ac09-558d-4836-9bb6-f1de81d58f9d	message	Hello	say hiiii	f	2025-12-15 14:21:45.660015	9de49003-6a71-4f8a-b7ce-002c97ae9449	2025-12-22 14:21:45.59271+01	2025-12-15 14:21:45.660015
177	3f324c9c-7c0d-4dbc-8c49-cd943f36fc27	message	Hello	say hiiii	f	2025-12-15 14:21:45.660252	9de49003-6a71-4f8a-b7ce-002c97ae9449	2025-12-22 14:21:45.59271+01	2025-12-15 14:21:45.660252
178	2a643039-c6a0-4791-b022-07b0fbfddd3a	message	Hello	say hiiii	f	2025-12-15 14:21:45.660483	9de49003-6a71-4f8a-b7ce-002c97ae9449	2025-12-22 14:21:45.59271+01	2025-12-15 14:21:45.660483
179	020e710e-e419-4c74-9848-3b00770353c6	message	Hello	say hiiii	f	2025-12-15 14:21:45.663002	9de49003-6a71-4f8a-b7ce-002c97ae9449	2025-12-22 14:21:45.59271+01	2025-12-15 14:21:45.663002
180	f4d858f5-58b1-4727-96d5-5b27be00ebbe	message	Hello	say hiiii	f	2025-12-15 14:21:45.663274	9de49003-6a71-4f8a-b7ce-002c97ae9449	2025-12-22 14:21:45.59271+01	2025-12-15 14:21:45.663274
181	1ca1e403-5ac5-495e-86b5-0e60c397393b	message	Hello	say hiiii	f	2025-12-15 14:21:45.663501	9de49003-6a71-4f8a-b7ce-002c97ae9449	2025-12-22 14:21:45.59271+01	2025-12-15 14:21:45.663501
182	9b36ebb6-1b40-4fa5-8fad-736b04b5b4ea	message	Hello	say hiiii	f	2025-12-15 14:21:45.663747	9de49003-6a71-4f8a-b7ce-002c97ae9449	2025-12-22 14:21:45.59271+01	2025-12-15 14:21:45.663747
183	03613595-b764-4cb5-9d23-ebb2055a9fe1	message	Hello	say hiiii	f	2025-12-15 14:21:45.663957	9de49003-6a71-4f8a-b7ce-002c97ae9449	2025-12-22 14:21:45.59271+01	2025-12-15 14:21:45.663957
184	59775d98-8c8e-4a7b-99ed-11920c2bd80b	message	Hello	say hiiii	f	2025-12-15 14:21:45.664173	9de49003-6a71-4f8a-b7ce-002c97ae9449	2025-12-22 14:21:45.59271+01	2025-12-15 14:21:45.664173
185	b6ac4b5c-2caf-4bd6-83e9-ae3d7df27970	message	Hello	say hiiii	f	2025-12-15 14:21:45.664391	9de49003-6a71-4f8a-b7ce-002c97ae9449	2025-12-22 14:21:45.59271+01	2025-12-15 14:21:45.664391
186	5738ce10-3634-42f7-91d7-91f21cfb64f3	message	Hello	say hiiii	f	2025-12-15 14:21:45.6646	9de49003-6a71-4f8a-b7ce-002c97ae9449	2025-12-22 14:21:45.59271+01	2025-12-15 14:21:45.6646
187	a4f64b75-1bbe-4fb1-80d5-f441b6b9bee2	message	Hello	say hiiii	f	2025-12-15 14:21:45.664876	9de49003-6a71-4f8a-b7ce-002c97ae9449	2025-12-22 14:21:45.59271+01	2025-12-15 14:21:45.664876
189	9a2b27aa-e90a-4409-8373-2be363ee206e	message	Hello	say hiiii	f	2025-12-15 14:21:45.66611	9de49003-6a71-4f8a-b7ce-002c97ae9449	2025-12-22 14:21:45.59271+01	2025-12-15 14:21:45.66611
190	34d7356b-9cea-4a80-a7be-93d7def7d260	message	Hello	say hiiii	f	2025-12-15 14:21:45.666397	9de49003-6a71-4f8a-b7ce-002c97ae9449	2025-12-22 14:21:45.59271+01	2025-12-15 14:21:45.666397
191	489473cf-735a-4831-ac2a-f94ce58afca4	message	Hello	say hiiii	f	2025-12-15 14:21:45.666622	9de49003-6a71-4f8a-b7ce-002c97ae9449	2025-12-22 14:21:45.59271+01	2025-12-15 14:21:45.666622
192	412e9a12-7529-4bc7-85c7-f88df5e191d1	message	Hello	say hiiii	f	2025-12-15 14:21:45.666863	9de49003-6a71-4f8a-b7ce-002c97ae9449	2025-12-22 14:21:45.59271+01	2025-12-15 14:21:45.666863
193	c492c079-7db5-4261-9983-2492048902eb	message	Hello	say hiiii	f	2025-12-15 14:21:45.667131	9de49003-6a71-4f8a-b7ce-002c97ae9449	2025-12-22 14:21:45.59271+01	2025-12-15 14:21:45.667131
194	aecbb92c-bbe9-4a05-9dc2-a1f290e41deb	message	Hello	say hiiii	f	2025-12-15 14:21:45.667409	9de49003-6a71-4f8a-b7ce-002c97ae9449	2025-12-22 14:21:45.59271+01	2025-12-15 14:21:45.667409
195	fac4c4eb-47c1-4552-9e92-3f24ca63a922	message	Hello	say hiiii	f	2025-12-15 14:21:45.667672	9de49003-6a71-4f8a-b7ce-002c97ae9449	2025-12-22 14:21:45.59271+01	2025-12-15 14:21:45.667672
196	552e83ca-0eaa-4d94-87aa-9c4958aa811e	message	Hello	say hiiii	f	2025-12-15 14:21:45.667887	9de49003-6a71-4f8a-b7ce-002c97ae9449	2025-12-22 14:21:45.59271+01	2025-12-15 14:21:45.667887
197	544e6fb5-b91e-43be-89f6-90546a7f0669	message	Hello	say hiiii	f	2025-12-15 14:21:45.668103	9de49003-6a71-4f8a-b7ce-002c97ae9449	2025-12-22 14:21:45.59271+01	2025-12-15 14:21:45.668103
198	e001d25d-7ef8-44c7-8213-2777aa595970	message	Hello	say hiiii	f	2025-12-15 14:21:45.668342	9de49003-6a71-4f8a-b7ce-002c97ae9449	2025-12-22 14:21:45.59271+01	2025-12-15 14:21:45.668342
199	1d71f3e9-7f85-49b8-a65e-b9c819ad19cb	message	Hello	say hiiii	f	2025-12-15 14:21:45.669603	9de49003-6a71-4f8a-b7ce-002c97ae9449	2025-12-22 14:21:45.59271+01	2025-12-15 14:21:45.669603
200	1ebbf9f9-6184-4687-a5cf-a5b7c6d11717	message	Hello	say hiiii	f	2025-12-15 14:21:45.669812	9de49003-6a71-4f8a-b7ce-002c97ae9449	2025-12-22 14:21:45.59271+01	2025-12-15 14:21:45.669812
201	c848bf8a-43a8-4d05-94cc-9d5033405cd7	message	Hello	say hiiii	f	2025-12-15 14:21:45.670019	9de49003-6a71-4f8a-b7ce-002c97ae9449	2025-12-22 14:21:45.59271+01	2025-12-15 14:21:45.670019
202	0919939d-1f4b-485c-b66e-1c24d710930d	message	Hello	say hiiii	f	2025-12-15 14:21:45.67023	9de49003-6a71-4f8a-b7ce-002c97ae9449	2025-12-22 14:21:45.59271+01	2025-12-15 14:21:45.67023
203	8c59a07a-41dc-4d55-b55b-f82800569e9c	message	Hello	say hiiii	f	2025-12-15 14:21:45.670455	9de49003-6a71-4f8a-b7ce-002c97ae9449	2025-12-22 14:21:45.59271+01	2025-12-15 14:21:45.670455
204	6392ac81-e8b5-4b27-a2dc-b0a34a449659	message	Hello	say hiiii	f	2025-12-15 14:21:45.670663	9de49003-6a71-4f8a-b7ce-002c97ae9449	2025-12-22 14:21:45.59271+01	2025-12-15 14:21:45.670663
205	b45f33f6-4f98-4d00-af3d-6bae657c2deb	message	Hello	say hiiii	f	2025-12-15 14:21:45.670884	9de49003-6a71-4f8a-b7ce-002c97ae9449	2025-12-22 14:21:45.59271+01	2025-12-15 14:21:45.670884
206	1e193b09-87bc-48c4-b666-94f910cf5882	message	Hello	say hiiii	f	2025-12-15 14:21:45.671118	9de49003-6a71-4f8a-b7ce-002c97ae9449	2025-12-22 14:21:45.59271+01	2025-12-15 14:21:45.671118
207	cebe720e-d2f1-4b0e-9107-4da7b543fe4b	message	Hello	say hiiii	f	2025-12-15 14:21:45.671358	9de49003-6a71-4f8a-b7ce-002c97ae9449	2025-12-22 14:21:45.59271+01	2025-12-15 14:21:45.671358
208	1a6bdfd6-888d-44f7-8f49-eaa05b8af956	message	Hello	say hiiii	f	2025-12-15 14:21:45.671591	9de49003-6a71-4f8a-b7ce-002c97ae9449	2025-12-22 14:21:45.59271+01	2025-12-15 14:21:45.671591
209	5eebb1da-4f4a-4422-9d3b-406c89f80c89	message	Hello	say hiiii	f	2025-12-15 14:21:45.671804	9de49003-6a71-4f8a-b7ce-002c97ae9449	2025-12-22 14:21:45.59271+01	2025-12-15 14:21:45.671804
210	b5d7896a-9217-480e-b4ac-8343141a3333	message	Hello	say hiiii	f	2025-12-15 14:31:55.062295	56bd55d8-f8fe-49f8-b7eb-0cac7d581639	2025-12-22 14:31:55.041771+01	2025-12-15 14:31:55.062295
211	8e57948f-983c-4db3-b517-a46b3d3531b3	message	Hello	say hiiii	f	2025-12-15 14:31:55.069758	56bd55d8-f8fe-49f8-b7eb-0cac7d581639	2025-12-22 14:31:55.041771+01	2025-12-15 14:31:55.069758
212	e6bcd428-3711-4d17-80b4-5fab412563bd	message	Hello	say hiiii	f	2025-12-15 14:31:55.070367	56bd55d8-f8fe-49f8-b7eb-0cac7d581639	2025-12-22 14:31:55.041771+01	2025-12-15 14:31:55.070367
213	97dabb21-c5cd-434c-8bff-ae86b3682018	message	Hello	say hiiii	f	2025-12-15 14:31:55.070883	56bd55d8-f8fe-49f8-b7eb-0cac7d581639	2025-12-22 14:31:55.041771+01	2025-12-15 14:31:55.070883
214	23a2c030-e381-40b0-885f-efe8c6ccf388	message	Hello	say hiiii	f	2025-12-15 14:31:55.071347	56bd55d8-f8fe-49f8-b7eb-0cac7d581639	2025-12-22 14:31:55.041771+01	2025-12-15 14:31:55.071347
215	f50c5c53-dd6a-4380-9d6f-1410b29a7fa4	message	Hello	say hiiii	f	2025-12-15 14:31:55.071786	56bd55d8-f8fe-49f8-b7eb-0cac7d581639	2025-12-22 14:31:55.041771+01	2025-12-15 14:31:55.071786
216	3edac621-15bc-43a1-9a09-19231b503c80	message	Hello	say hiiii	f	2025-12-15 14:31:55.072398	56bd55d8-f8fe-49f8-b7eb-0cac7d581639	2025-12-22 14:31:55.041771+01	2025-12-15 14:31:55.072398
217	8ddcb7e7-9941-46bb-866b-6aae3a217a5d	message	Hello	say hiiii	f	2025-12-15 14:31:55.073081	56bd55d8-f8fe-49f8-b7eb-0cac7d581639	2025-12-22 14:31:55.041771+01	2025-12-15 14:31:55.073081
218	2b9793bf-f240-4cf8-a94a-c4b652f0ae0b	message	Hello	say hiiii	f	2025-12-15 14:31:55.073505	56bd55d8-f8fe-49f8-b7eb-0cac7d581639	2025-12-22 14:31:55.041771+01	2025-12-15 14:31:55.073505
219	710974ab-52fc-4726-b50a-b309d5b7d9ba	message	Hello	say hiiii	f	2025-12-15 14:31:55.073851	56bd55d8-f8fe-49f8-b7eb-0cac7d581639	2025-12-22 14:31:55.041771+01	2025-12-15 14:31:55.073851
220	805b6158-8b01-4f05-90f2-a0fcad495cb9	message	Hello	say hiiii	f	2025-12-15 14:31:55.074153	56bd55d8-f8fe-49f8-b7eb-0cac7d581639	2025-12-22 14:31:55.041771+01	2025-12-15 14:31:55.074153
221	a7a5977d-c912-4476-b8c1-89d6a6dec0ee	message	Hello	say hiiii	f	2025-12-15 14:31:55.074426	56bd55d8-f8fe-49f8-b7eb-0cac7d581639	2025-12-22 14:31:55.041771+01	2025-12-15 14:31:55.074426
222	085df28e-fb49-420c-bea9-0432c9199f40	message	Hello	say hiiii	f	2025-12-15 14:31:55.074702	56bd55d8-f8fe-49f8-b7eb-0cac7d581639	2025-12-22 14:31:55.041771+01	2025-12-15 14:31:55.074702
223	d2e4dc25-672a-485e-98b8-0126b3f10d28	message	Hello	say hiiii	f	2025-12-15 14:31:55.074971	56bd55d8-f8fe-49f8-b7eb-0cac7d581639	2025-12-22 14:31:55.041771+01	2025-12-15 14:31:55.074971
224	61bd6a53-cd0b-4af7-9166-c8385d448f8f	message	Hello	say hiiii	f	2025-12-15 14:31:55.075214	56bd55d8-f8fe-49f8-b7eb-0cac7d581639	2025-12-22 14:31:55.041771+01	2025-12-15 14:31:55.075214
225	891bbc40-a563-4fab-9ca0-a0defd6abbe3	message	Hello	say hiiii	f	2025-12-15 14:31:55.075458	56bd55d8-f8fe-49f8-b7eb-0cac7d581639	2025-12-22 14:31:55.041771+01	2025-12-15 14:31:55.075458
226	81e8d990-cba5-41df-8c92-f74cdbc3a71a	message	Hello	say hiiii	f	2025-12-15 14:31:55.075693	56bd55d8-f8fe-49f8-b7eb-0cac7d581639	2025-12-22 14:31:55.041771+01	2025-12-15 14:31:55.075693
227	e116ad22-a5f7-4bcd-9577-8b5f9beeaf46	message	Hello	say hiiii	f	2025-12-15 14:31:55.076111	56bd55d8-f8fe-49f8-b7eb-0cac7d581639	2025-12-22 14:31:55.041771+01	2025-12-15 14:31:55.076111
228	9b40e7c8-5dde-4b3b-8574-4cdb3453fc31	message	Hello	say hiiii	f	2025-12-15 14:31:55.07639	56bd55d8-f8fe-49f8-b7eb-0cac7d581639	2025-12-22 14:31:55.041771+01	2025-12-15 14:31:55.07639
229	8f675035-cc06-4b4e-89b6-db4f7c123ed2	message	Hello	say hiiii	f	2025-12-15 14:31:55.076691	56bd55d8-f8fe-49f8-b7eb-0cac7d581639	2025-12-22 14:31:55.041771+01	2025-12-15 14:31:55.076691
230	376e41c2-4a6e-4010-ba3d-24eb0c509ada	message	Hello	say hiiii	f	2025-12-15 14:31:55.076962	56bd55d8-f8fe-49f8-b7eb-0cac7d581639	2025-12-22 14:31:55.041771+01	2025-12-15 14:31:55.076962
231	091177fc-3b2c-4858-8ea0-b8f7206b4636	message	Hello	say hiiii	f	2025-12-15 14:31:55.077229	56bd55d8-f8fe-49f8-b7eb-0cac7d581639	2025-12-22 14:31:55.041771+01	2025-12-15 14:31:55.077229
232	7ef2acf4-d876-4a29-b1f0-db8301f817a6	message	Hello	say hiiii	f	2025-12-15 14:31:55.077936	56bd55d8-f8fe-49f8-b7eb-0cac7d581639	2025-12-22 14:31:55.041771+01	2025-12-15 14:31:55.077936
233	7b63533f-02f3-4491-9808-64ad90a92334	message	Hello	say hiiii	f	2025-12-15 14:31:55.078362	56bd55d8-f8fe-49f8-b7eb-0cac7d581639	2025-12-22 14:31:55.041771+01	2025-12-15 14:31:55.078362
234	d2940649-78f0-4418-88b4-7b16a9a7104f	message	Hello	say hiiii	f	2025-12-15 14:31:55.079821	56bd55d8-f8fe-49f8-b7eb-0cac7d581639	2025-12-22 14:31:55.041771+01	2025-12-15 14:31:55.079821
235	a8f9ccad-6eef-45ea-b1d9-9b24ec7ab5a9	message	Hello	say hiiii	f	2025-12-15 14:31:55.080773	56bd55d8-f8fe-49f8-b7eb-0cac7d581639	2025-12-22 14:31:55.041771+01	2025-12-15 14:31:55.080773
236	b4801419-3838-4ac9-9c94-b05568dbf2b1	message	Hello	say hiiii	f	2025-12-15 14:31:55.086286	56bd55d8-f8fe-49f8-b7eb-0cac7d581639	2025-12-22 14:31:55.041771+01	2025-12-15 14:31:55.086286
237	1eab9750-4824-4de4-8168-04591fc249f7	message	Hello	say hiiii	f	2025-12-15 14:31:55.088683	56bd55d8-f8fe-49f8-b7eb-0cac7d581639	2025-12-22 14:31:55.041771+01	2025-12-15 14:31:55.088683
238	6315b233-5988-421f-9cb9-95a8b68e00ce	message	Hello	say hiiii	f	2025-12-15 14:31:55.089261	56bd55d8-f8fe-49f8-b7eb-0cac7d581639	2025-12-22 14:31:55.041771+01	2025-12-15 14:31:55.089261
239	ca9c9dd0-bfd0-4436-b804-cfa549e732db	message	Hello	say hiiii	f	2025-12-15 14:31:55.089531	56bd55d8-f8fe-49f8-b7eb-0cac7d581639	2025-12-22 14:31:55.041771+01	2025-12-15 14:31:55.089531
240	f6702e7d-fe35-4bc2-b78b-5a04809e886c	message	Hello	say hiiii	f	2025-12-15 14:31:55.090075	56bd55d8-f8fe-49f8-b7eb-0cac7d581639	2025-12-22 14:31:55.041771+01	2025-12-15 14:31:55.090075
241	fbd7dcb6-7dc8-478a-ba23-6fae56403e81	message	Hello	say hiiii	f	2025-12-15 14:31:55.090423	56bd55d8-f8fe-49f8-b7eb-0cac7d581639	2025-12-22 14:31:55.041771+01	2025-12-15 14:31:55.090423
242	5f3fb9c6-b104-40cb-b27e-ce123ebd7fa6	message	Hello	say hiiii	f	2025-12-15 14:31:55.090767	56bd55d8-f8fe-49f8-b7eb-0cac7d581639	2025-12-22 14:31:55.041771+01	2025-12-15 14:31:55.090767
243	f8642d75-f69a-487d-b385-661ecf2fc8fc	message	Hello	say hiiii	f	2025-12-15 14:31:55.091092	56bd55d8-f8fe-49f8-b7eb-0cac7d581639	2025-12-22 14:31:55.041771+01	2025-12-15 14:31:55.091092
244	3b4d200d-8f2c-45c8-a3ae-2816d06f208c	message	Hello	say hiiii	f	2025-12-15 14:31:55.091408	56bd55d8-f8fe-49f8-b7eb-0cac7d581639	2025-12-22 14:31:55.041771+01	2025-12-15 14:31:55.091408
245	a1ba9ca9-d129-47c4-b6ff-1d3a5fd1e27d	message	Hello	say hiiii	f	2025-12-15 14:31:55.091752	56bd55d8-f8fe-49f8-b7eb-0cac7d581639	2025-12-22 14:31:55.041771+01	2025-12-15 14:31:55.091752
246	7af931a9-9b6d-464c-928a-56556aa73171	message	Hello	say hiiii	f	2025-12-15 14:31:55.092049	56bd55d8-f8fe-49f8-b7eb-0cac7d581639	2025-12-22 14:31:55.041771+01	2025-12-15 14:31:55.092049
247	87e45cfe-99c0-46bf-8ea4-a53fb3c757b0	message	Hello	say hiiii	f	2025-12-15 14:31:55.09234	56bd55d8-f8fe-49f8-b7eb-0cac7d581639	2025-12-22 14:31:55.041771+01	2025-12-15 14:31:55.09234
248	d1b4bda9-e6d2-4b36-a87b-63b34b14a47a	message	Hello	say hiiii	f	2025-12-15 14:31:55.092661	56bd55d8-f8fe-49f8-b7eb-0cac7d581639	2025-12-22 14:31:55.041771+01	2025-12-15 14:31:55.092661
249	df4b5622-d10a-4be6-b3b9-ae9eb365621f	message	Hello	say hiiii	f	2025-12-15 14:31:55.092964	56bd55d8-f8fe-49f8-b7eb-0cac7d581639	2025-12-22 14:31:55.041771+01	2025-12-15 14:31:55.092964
250	89dbb74e-de3b-4d24-981c-7638797c1e36	message	Hello	say hiiii	f	2025-12-15 14:31:55.093246	56bd55d8-f8fe-49f8-b7eb-0cac7d581639	2025-12-22 14:31:55.041771+01	2025-12-15 14:31:55.093246
251	c7733a6f-9d5d-4d39-a724-f85c9d24d139	message	Hello	say hiiii	f	2025-12-15 14:31:55.093592	56bd55d8-f8fe-49f8-b7eb-0cac7d581639	2025-12-22 14:31:55.041771+01	2025-12-15 14:31:55.093592
252	f4d0a02a-8a68-4eb2-af6e-e4f055c356c1	message	Hello	say hiiii	f	2025-12-15 14:31:55.093898	56bd55d8-f8fe-49f8-b7eb-0cac7d581639	2025-12-22 14:31:55.041771+01	2025-12-15 14:31:55.093898
253	822a2fa1-b223-4057-aabc-82e54feea196	message	Hello	say hiiii	f	2025-12-15 14:31:55.094193	56bd55d8-f8fe-49f8-b7eb-0cac7d581639	2025-12-22 14:31:55.041771+01	2025-12-15 14:31:55.094193
254	409f5414-a30a-4090-84cc-73f477407968	message	Hello	say hiiii	f	2025-12-15 14:31:55.094482	56bd55d8-f8fe-49f8-b7eb-0cac7d581639	2025-12-22 14:31:55.041771+01	2025-12-15 14:31:55.094482
255	0ccaa979-7837-46cf-9514-826710479042	message	Hello	say hiiii	f	2025-12-15 14:31:55.094781	56bd55d8-f8fe-49f8-b7eb-0cac7d581639	2025-12-22 14:31:55.041771+01	2025-12-15 14:31:55.094781
256	41e8c3cb-f9a4-4f2e-a473-d47e060e89d3	message	Hello	say hiiii	f	2025-12-15 14:31:55.095261	56bd55d8-f8fe-49f8-b7eb-0cac7d581639	2025-12-22 14:31:55.041771+01	2025-12-15 14:31:55.095261
257	a4b3302a-4c26-4b9e-9205-c726f5b548f0	message	Hello	say hiiii	f	2025-12-15 14:31:55.095949	56bd55d8-f8fe-49f8-b7eb-0cac7d581639	2025-12-22 14:31:55.041771+01	2025-12-15 14:31:55.095949
258	64c22400-eb47-46b1-93fb-11110d7121f1	message	Hello	say hiiii	f	2025-12-15 14:31:55.096424	56bd55d8-f8fe-49f8-b7eb-0cac7d581639	2025-12-22 14:31:55.041771+01	2025-12-15 14:31:55.096424
259	9d401424-6da4-4e9a-8568-00174cd56050	message	Hello	say hiiii	f	2025-12-15 14:31:55.097645	56bd55d8-f8fe-49f8-b7eb-0cac7d581639	2025-12-22 14:31:55.041771+01	2025-12-15 14:31:55.097645
260	f1361a2d-c534-4cfd-81a0-796ed17b4339	message	Hello	say hiiii	f	2025-12-15 14:31:55.09813	56bd55d8-f8fe-49f8-b7eb-0cac7d581639	2025-12-22 14:31:55.041771+01	2025-12-15 14:31:55.09813
262	00feec4b-e498-452b-b081-cf480e16aec2	message	Hello	say hiiii	f	2025-12-15 14:31:55.099129	56bd55d8-f8fe-49f8-b7eb-0cac7d581639	2025-12-22 14:31:55.041771+01	2025-12-15 14:31:55.099129
263	02762b1e-9b2f-4bfe-943c-d6c28827ef96	message	Hello	say hiiii	f	2025-12-15 14:31:55.099739	56bd55d8-f8fe-49f8-b7eb-0cac7d581639	2025-12-22 14:31:55.041771+01	2025-12-15 14:31:55.099739
264	86407ed7-40bf-4420-9053-f64c6121188e	message	Hello	say hiiii	f	2025-12-15 14:31:55.100439	56bd55d8-f8fe-49f8-b7eb-0cac7d581639	2025-12-22 14:31:55.041771+01	2025-12-15 14:31:55.100439
265	22d26f27-6768-43ec-b08e-4b20b924b76f	message	Hello	say hiiii	f	2025-12-15 14:31:55.100948	56bd55d8-f8fe-49f8-b7eb-0cac7d581639	2025-12-22 14:31:55.041771+01	2025-12-15 14:31:55.100948
266	c2b365e0-5404-4d85-b9e1-515e0cd9afe9	message	Hello	say hiiii	f	2025-12-15 14:31:55.101288	56bd55d8-f8fe-49f8-b7eb-0cac7d581639	2025-12-22 14:31:55.041771+01	2025-12-15 14:31:55.101288
267	aefab581-f8c3-42a0-b79a-55d0270f3d00	message	Hello	say hiiii	f	2025-12-15 14:31:55.101779	56bd55d8-f8fe-49f8-b7eb-0cac7d581639	2025-12-22 14:31:55.041771+01	2025-12-15 14:31:55.101779
268	5be8065b-44d4-4fab-aa82-b64bda2b368a	message	Hello	say hiiii	f	2025-12-15 14:31:55.102119	56bd55d8-f8fe-49f8-b7eb-0cac7d581639	2025-12-22 14:31:55.041771+01	2025-12-15 14:31:55.102119
269	d9df9370-0442-4365-9ed0-3b59afc81ec1	message	Hello	say hiiii	f	2025-12-15 14:31:55.102498	56bd55d8-f8fe-49f8-b7eb-0cac7d581639	2025-12-22 14:31:55.041771+01	2025-12-15 14:31:55.102498
270	9c77950e-3ebc-4846-aed1-2faae86cbb37	message	Hello	say hiiii	f	2025-12-15 14:31:55.102787	56bd55d8-f8fe-49f8-b7eb-0cac7d581639	2025-12-22 14:31:55.041771+01	2025-12-15 14:31:55.102787
271	66024a16-884c-408e-bead-dd134927a58a	message	Hello	say hiiii	f	2025-12-15 14:31:55.103086	56bd55d8-f8fe-49f8-b7eb-0cac7d581639	2025-12-22 14:31:55.041771+01	2025-12-15 14:31:55.103086
272	c6fa2131-7fea-459e-9df8-2ff37f1a39bb	message	Hello	say hiiii	f	2025-12-15 14:31:55.103987	56bd55d8-f8fe-49f8-b7eb-0cac7d581639	2025-12-22 14:31:55.041771+01	2025-12-15 14:31:55.103987
273	694655b7-cfa9-418e-9f29-1753df0adbfd	message	Hello	say hiiii	f	2025-12-15 14:31:55.104427	56bd55d8-f8fe-49f8-b7eb-0cac7d581639	2025-12-22 14:31:55.041771+01	2025-12-15 14:31:55.104427
274	c84d7da8-2f5e-4123-85c5-989ba74e3520	message	Hello	say hiiii	f	2025-12-15 14:31:55.10493	56bd55d8-f8fe-49f8-b7eb-0cac7d581639	2025-12-22 14:31:55.041771+01	2025-12-15 14:31:55.10493
275	c58f03b5-12e4-45c5-b71d-21ffeb6b0c40	message	Hello	say hiiii	f	2025-12-15 14:31:55.1053	56bd55d8-f8fe-49f8-b7eb-0cac7d581639	2025-12-22 14:31:55.041771+01	2025-12-15 14:31:55.1053
276	905773e4-02be-4a57-9046-7bd29db1fa03	message	Hello	say hiiii	f	2025-12-15 14:31:55.106129	56bd55d8-f8fe-49f8-b7eb-0cac7d581639	2025-12-22 14:31:55.041771+01	2025-12-15 14:31:55.106129
277	243a4471-81e9-469e-ae44-7685b225e07b	message	Hello	say hiiii	f	2025-12-15 14:31:55.106411	56bd55d8-f8fe-49f8-b7eb-0cac7d581639	2025-12-22 14:31:55.041771+01	2025-12-15 14:31:55.106411
278	afb04864-9ab2-4994-918c-397a2a035d84	message	Hello	say hiiii	f	2025-12-15 14:31:55.106668	56bd55d8-f8fe-49f8-b7eb-0cac7d581639	2025-12-22 14:31:55.041771+01	2025-12-15 14:31:55.106668
279	5c39ac09-558d-4836-9bb6-f1de81d58f9d	message	Hello	say hiiii	f	2025-12-15 14:31:55.106916	56bd55d8-f8fe-49f8-b7eb-0cac7d581639	2025-12-22 14:31:55.041771+01	2025-12-15 14:31:55.106916
280	3f324c9c-7c0d-4dbc-8c49-cd943f36fc27	message	Hello	say hiiii	f	2025-12-15 14:31:55.107208	56bd55d8-f8fe-49f8-b7eb-0cac7d581639	2025-12-22 14:31:55.041771+01	2025-12-15 14:31:55.107208
281	2a643039-c6a0-4791-b022-07b0fbfddd3a	message	Hello	say hiiii	f	2025-12-15 14:31:55.107562	56bd55d8-f8fe-49f8-b7eb-0cac7d581639	2025-12-22 14:31:55.041771+01	2025-12-15 14:31:55.107562
282	020e710e-e419-4c74-9848-3b00770353c6	message	Hello	say hiiii	f	2025-12-15 14:31:55.108156	56bd55d8-f8fe-49f8-b7eb-0cac7d581639	2025-12-22 14:31:55.041771+01	2025-12-15 14:31:55.108156
283	f4d858f5-58b1-4727-96d5-5b27be00ebbe	message	Hello	say hiiii	f	2025-12-15 14:31:55.108789	56bd55d8-f8fe-49f8-b7eb-0cac7d581639	2025-12-22 14:31:55.041771+01	2025-12-15 14:31:55.108789
284	1ca1e403-5ac5-495e-86b5-0e60c397393b	message	Hello	say hiiii	f	2025-12-15 14:31:55.109275	56bd55d8-f8fe-49f8-b7eb-0cac7d581639	2025-12-22 14:31:55.041771+01	2025-12-15 14:31:55.109275
285	9b36ebb6-1b40-4fa5-8fad-736b04b5b4ea	message	Hello	say hiiii	f	2025-12-15 14:31:55.10987	56bd55d8-f8fe-49f8-b7eb-0cac7d581639	2025-12-22 14:31:55.041771+01	2025-12-15 14:31:55.10987
286	03613595-b764-4cb5-9d23-ebb2055a9fe1	message	Hello	say hiiii	f	2025-12-15 14:31:55.110375	56bd55d8-f8fe-49f8-b7eb-0cac7d581639	2025-12-22 14:31:55.041771+01	2025-12-15 14:31:55.110375
287	59775d98-8c8e-4a7b-99ed-11920c2bd80b	message	Hello	say hiiii	f	2025-12-15 14:31:55.110665	56bd55d8-f8fe-49f8-b7eb-0cac7d581639	2025-12-22 14:31:55.041771+01	2025-12-15 14:31:55.110665
288	b6ac4b5c-2caf-4bd6-83e9-ae3d7df27970	message	Hello	say hiiii	f	2025-12-15 14:31:55.110918	56bd55d8-f8fe-49f8-b7eb-0cac7d581639	2025-12-22 14:31:55.041771+01	2025-12-15 14:31:55.110918
289	5738ce10-3634-42f7-91d7-91f21cfb64f3	message	Hello	say hiiii	f	2025-12-15 14:31:55.111138	56bd55d8-f8fe-49f8-b7eb-0cac7d581639	2025-12-22 14:31:55.041771+01	2025-12-15 14:31:55.111138
290	a4f64b75-1bbe-4fb1-80d5-f441b6b9bee2	message	Hello	say hiiii	f	2025-12-15 14:31:55.111374	56bd55d8-f8fe-49f8-b7eb-0cac7d581639	2025-12-22 14:31:55.041771+01	2025-12-15 14:31:55.111374
292	9a2b27aa-e90a-4409-8373-2be363ee206e	message	Hello	say hiiii	f	2025-12-15 14:31:55.112011	56bd55d8-f8fe-49f8-b7eb-0cac7d581639	2025-12-22 14:31:55.041771+01	2025-12-15 14:31:55.112011
293	34d7356b-9cea-4a80-a7be-93d7def7d260	message	Hello	say hiiii	f	2025-12-15 14:31:55.112246	56bd55d8-f8fe-49f8-b7eb-0cac7d581639	2025-12-22 14:31:55.041771+01	2025-12-15 14:31:55.112246
294	489473cf-735a-4831-ac2a-f94ce58afca4	message	Hello	say hiiii	f	2025-12-15 14:31:55.112577	56bd55d8-f8fe-49f8-b7eb-0cac7d581639	2025-12-22 14:31:55.041771+01	2025-12-15 14:31:55.112577
295	412e9a12-7529-4bc7-85c7-f88df5e191d1	message	Hello	say hiiii	f	2025-12-15 14:31:55.112949	56bd55d8-f8fe-49f8-b7eb-0cac7d581639	2025-12-22 14:31:55.041771+01	2025-12-15 14:31:55.112949
296	c492c079-7db5-4261-9983-2492048902eb	message	Hello	say hiiii	f	2025-12-15 14:31:55.113274	56bd55d8-f8fe-49f8-b7eb-0cac7d581639	2025-12-22 14:31:55.041771+01	2025-12-15 14:31:55.113274
297	aecbb92c-bbe9-4a05-9dc2-a1f290e41deb	message	Hello	say hiiii	f	2025-12-15 14:31:55.113587	56bd55d8-f8fe-49f8-b7eb-0cac7d581639	2025-12-22 14:31:55.041771+01	2025-12-15 14:31:55.113587
298	fac4c4eb-47c1-4552-9e92-3f24ca63a922	message	Hello	say hiiii	f	2025-12-15 14:31:55.113883	56bd55d8-f8fe-49f8-b7eb-0cac7d581639	2025-12-22 14:31:55.041771+01	2025-12-15 14:31:55.113883
299	552e83ca-0eaa-4d94-87aa-9c4958aa811e	message	Hello	say hiiii	f	2025-12-15 14:31:55.114141	56bd55d8-f8fe-49f8-b7eb-0cac7d581639	2025-12-22 14:31:55.041771+01	2025-12-15 14:31:55.114141
300	544e6fb5-b91e-43be-89f6-90546a7f0669	message	Hello	say hiiii	f	2025-12-15 14:31:55.11459	56bd55d8-f8fe-49f8-b7eb-0cac7d581639	2025-12-22 14:31:55.041771+01	2025-12-15 14:31:55.11459
301	e001d25d-7ef8-44c7-8213-2777aa595970	message	Hello	say hiiii	f	2025-12-15 14:31:55.114923	56bd55d8-f8fe-49f8-b7eb-0cac7d581639	2025-12-22 14:31:55.041771+01	2025-12-15 14:31:55.114923
302	1d71f3e9-7f85-49b8-a65e-b9c819ad19cb	message	Hello	say hiiii	f	2025-12-15 14:31:55.11537	56bd55d8-f8fe-49f8-b7eb-0cac7d581639	2025-12-22 14:31:55.041771+01	2025-12-15 14:31:55.11537
303	1ebbf9f9-6184-4687-a5cf-a5b7c6d11717	message	Hello	say hiiii	f	2025-12-15 14:31:55.115693	56bd55d8-f8fe-49f8-b7eb-0cac7d581639	2025-12-22 14:31:55.041771+01	2025-12-15 14:31:55.115693
304	c848bf8a-43a8-4d05-94cc-9d5033405cd7	message	Hello	say hiiii	f	2025-12-15 14:31:55.115989	56bd55d8-f8fe-49f8-b7eb-0cac7d581639	2025-12-22 14:31:55.041771+01	2025-12-15 14:31:55.115989
305	0919939d-1f4b-485c-b66e-1c24d710930d	message	Hello	say hiiii	f	2025-12-15 14:31:55.116368	56bd55d8-f8fe-49f8-b7eb-0cac7d581639	2025-12-22 14:31:55.041771+01	2025-12-15 14:31:55.116368
306	8c59a07a-41dc-4d55-b55b-f82800569e9c	message	Hello	say hiiii	f	2025-12-15 14:31:55.116624	56bd55d8-f8fe-49f8-b7eb-0cac7d581639	2025-12-22 14:31:55.041771+01	2025-12-15 14:31:55.116624
307	6392ac81-e8b5-4b27-a2dc-b0a34a449659	message	Hello	say hiiii	f	2025-12-15 14:31:55.116887	56bd55d8-f8fe-49f8-b7eb-0cac7d581639	2025-12-22 14:31:55.041771+01	2025-12-15 14:31:55.116887
308	b45f33f6-4f98-4d00-af3d-6bae657c2deb	message	Hello	say hiiii	f	2025-12-15 14:31:55.118923	56bd55d8-f8fe-49f8-b7eb-0cac7d581639	2025-12-22 14:31:55.041771+01	2025-12-15 14:31:55.118923
309	1e193b09-87bc-48c4-b666-94f910cf5882	message	Hello	say hiiii	f	2025-12-15 14:31:55.119277	56bd55d8-f8fe-49f8-b7eb-0cac7d581639	2025-12-22 14:31:55.041771+01	2025-12-15 14:31:55.119277
310	cebe720e-d2f1-4b0e-9107-4da7b543fe4b	message	Hello	say hiiii	f	2025-12-15 14:31:55.120658	56bd55d8-f8fe-49f8-b7eb-0cac7d581639	2025-12-22 14:31:55.041771+01	2025-12-15 14:31:55.120658
311	1a6bdfd6-888d-44f7-8f49-eaa05b8af956	message	Hello	say hiiii	f	2025-12-15 14:31:55.121177	56bd55d8-f8fe-49f8-b7eb-0cac7d581639	2025-12-22 14:31:55.041771+01	2025-12-15 14:31:55.121177
312	5eebb1da-4f4a-4422-9d3b-406c89f80c89	message	Hello	say hiiii	f	2025-12-15 14:31:55.143081	56bd55d8-f8fe-49f8-b7eb-0cac7d581639	2025-12-22 14:31:55.041771+01	2025-12-15 14:31:55.143081
313	b5d7896a-9217-480e-b4ac-8343141a3333	message	uyuyhuhj	gghghghg	f	2025-12-15 14:37:28.259777	c878a3dd-f365-40e2-aea9-b58f96c6891f	2025-12-22 14:37:28.234088+01	2025-12-15 14:37:28.259777
314	8e57948f-983c-4db3-b517-a46b3d3531b3	message	uyuyhuhj	gghghghg	f	2025-12-15 14:37:28.266361	c878a3dd-f365-40e2-aea9-b58f96c6891f	2025-12-22 14:37:28.234088+01	2025-12-15 14:37:28.266361
315	e6bcd428-3711-4d17-80b4-5fab412563bd	message	uyuyhuhj	gghghghg	f	2025-12-15 14:37:28.266887	c878a3dd-f365-40e2-aea9-b58f96c6891f	2025-12-22 14:37:28.234088+01	2025-12-15 14:37:28.266887
316	97dabb21-c5cd-434c-8bff-ae86b3682018	message	uyuyhuhj	gghghghg	f	2025-12-15 14:37:28.267294	c878a3dd-f365-40e2-aea9-b58f96c6891f	2025-12-22 14:37:28.234088+01	2025-12-15 14:37:28.267294
317	23a2c030-e381-40b0-885f-efe8c6ccf388	message	uyuyhuhj	gghghghg	f	2025-12-15 14:37:28.267685	c878a3dd-f365-40e2-aea9-b58f96c6891f	2025-12-22 14:37:28.234088+01	2025-12-15 14:37:28.267685
318	f50c5c53-dd6a-4380-9d6f-1410b29a7fa4	message	uyuyhuhj	gghghghg	f	2025-12-15 14:37:28.26849	c878a3dd-f365-40e2-aea9-b58f96c6891f	2025-12-22 14:37:28.234088+01	2025-12-15 14:37:28.26849
319	3edac621-15bc-43a1-9a09-19231b503c80	message	uyuyhuhj	gghghghg	f	2025-12-15 14:37:28.269372	c878a3dd-f365-40e2-aea9-b58f96c6891f	2025-12-22 14:37:28.234088+01	2025-12-15 14:37:28.269372
320	8ddcb7e7-9941-46bb-866b-6aae3a217a5d	message	uyuyhuhj	gghghghg	f	2025-12-15 14:37:28.269996	c878a3dd-f365-40e2-aea9-b58f96c6891f	2025-12-22 14:37:28.234088+01	2025-12-15 14:37:28.269996
321	2b9793bf-f240-4cf8-a94a-c4b652f0ae0b	message	uyuyhuhj	gghghghg	f	2025-12-15 14:37:28.270655	c878a3dd-f365-40e2-aea9-b58f96c6891f	2025-12-22 14:37:28.234088+01	2025-12-15 14:37:28.270655
322	710974ab-52fc-4726-b50a-b309d5b7d9ba	message	uyuyhuhj	gghghghg	f	2025-12-15 14:37:28.271555	c878a3dd-f365-40e2-aea9-b58f96c6891f	2025-12-22 14:37:28.234088+01	2025-12-15 14:37:28.271555
323	9f68aa0f-c6c7-4b73-a4d9-d3225b88c2f0	message	uyuyhuhj	gghghghg	f	2025-12-15 14:37:28.272793	c878a3dd-f365-40e2-aea9-b58f96c6891f	2025-12-22 14:37:28.234088+01	2025-12-15 14:37:28.272793
324	805b6158-8b01-4f05-90f2-a0fcad495cb9	message	uyuyhuhj	gghghghg	f	2025-12-15 14:37:28.274689	c878a3dd-f365-40e2-aea9-b58f96c6891f	2025-12-22 14:37:28.234088+01	2025-12-15 14:37:28.274689
325	a7a5977d-c912-4476-b8c1-89d6a6dec0ee	message	uyuyhuhj	gghghghg	f	2025-12-15 14:37:28.275324	c878a3dd-f365-40e2-aea9-b58f96c6891f	2025-12-22 14:37:28.234088+01	2025-12-15 14:37:28.275324
326	085df28e-fb49-420c-bea9-0432c9199f40	message	uyuyhuhj	gghghghg	f	2025-12-15 14:37:28.275877	c878a3dd-f365-40e2-aea9-b58f96c6891f	2025-12-22 14:37:28.234088+01	2025-12-15 14:37:28.275877
327	d2e4dc25-672a-485e-98b8-0126b3f10d28	message	uyuyhuhj	gghghghg	f	2025-12-15 14:37:28.276329	c878a3dd-f365-40e2-aea9-b58f96c6891f	2025-12-22 14:37:28.234088+01	2025-12-15 14:37:28.276329
261	a04f5bc7-2636-4358-aae3-dc3e1c9968e3	message	Hello	say hiiii	t	2025-12-15 14:31:55.098618	56bd55d8-f8fe-49f8-b7eb-0cac7d581639	2025-12-22 14:31:55.041771+01	2025-12-15 22:05:38.918348
328	61bd6a53-cd0b-4af7-9166-c8385d448f8f	message	uyuyhuhj	gghghghg	f	2025-12-15 14:37:28.276726	c878a3dd-f365-40e2-aea9-b58f96c6891f	2025-12-22 14:37:28.234088+01	2025-12-15 14:37:28.276726
329	891bbc40-a563-4fab-9ca0-a0defd6abbe3	message	uyuyhuhj	gghghghg	f	2025-12-15 14:37:28.27777	c878a3dd-f365-40e2-aea9-b58f96c6891f	2025-12-22 14:37:28.234088+01	2025-12-15 14:37:28.27777
330	81e8d990-cba5-41df-8c92-f74cdbc3a71a	message	uyuyhuhj	gghghghg	f	2025-12-15 14:37:28.278172	c878a3dd-f365-40e2-aea9-b58f96c6891f	2025-12-22 14:37:28.234088+01	2025-12-15 14:37:28.278172
331	e116ad22-a5f7-4bcd-9577-8b5f9beeaf46	message	uyuyhuhj	gghghghg	f	2025-12-15 14:37:28.278776	c878a3dd-f365-40e2-aea9-b58f96c6891f	2025-12-22 14:37:28.234088+01	2025-12-15 14:37:28.278776
332	9b40e7c8-5dde-4b3b-8574-4cdb3453fc31	message	uyuyhuhj	gghghghg	f	2025-12-15 14:37:28.279585	c878a3dd-f365-40e2-aea9-b58f96c6891f	2025-12-22 14:37:28.234088+01	2025-12-15 14:37:28.279585
333	8f675035-cc06-4b4e-89b6-db4f7c123ed2	message	uyuyhuhj	gghghghg	f	2025-12-15 14:37:28.280127	c878a3dd-f365-40e2-aea9-b58f96c6891f	2025-12-22 14:37:28.234088+01	2025-12-15 14:37:28.280127
334	376e41c2-4a6e-4010-ba3d-24eb0c509ada	message	uyuyhuhj	gghghghg	f	2025-12-15 14:37:28.280496	c878a3dd-f365-40e2-aea9-b58f96c6891f	2025-12-22 14:37:28.234088+01	2025-12-15 14:37:28.280496
335	091177fc-3b2c-4858-8ea0-b8f7206b4636	message	uyuyhuhj	gghghghg	f	2025-12-15 14:37:28.280831	c878a3dd-f365-40e2-aea9-b58f96c6891f	2025-12-22 14:37:28.234088+01	2025-12-15 14:37:28.280831
336	7ef2acf4-d876-4a29-b1f0-db8301f817a6	message	uyuyhuhj	gghghghg	f	2025-12-15 14:37:28.281798	c878a3dd-f365-40e2-aea9-b58f96c6891f	2025-12-22 14:37:28.234088+01	2025-12-15 14:37:28.281798
337	7b63533f-02f3-4491-9808-64ad90a92334	message	uyuyhuhj	gghghghg	f	2025-12-15 14:37:28.282148	c878a3dd-f365-40e2-aea9-b58f96c6891f	2025-12-22 14:37:28.234088+01	2025-12-15 14:37:28.282148
338	d2940649-78f0-4418-88b4-7b16a9a7104f	message	uyuyhuhj	gghghghg	f	2025-12-15 14:37:28.282472	c878a3dd-f365-40e2-aea9-b58f96c6891f	2025-12-22 14:37:28.234088+01	2025-12-15 14:37:28.282472
339	a8f9ccad-6eef-45ea-b1d9-9b24ec7ab5a9	message	uyuyhuhj	gghghghg	f	2025-12-15 14:37:28.28278	c878a3dd-f365-40e2-aea9-b58f96c6891f	2025-12-22 14:37:28.234088+01	2025-12-15 14:37:28.28278
340	b4801419-3838-4ac9-9c94-b05568dbf2b1	message	uyuyhuhj	gghghghg	f	2025-12-15 14:37:28.283072	c878a3dd-f365-40e2-aea9-b58f96c6891f	2025-12-22 14:37:28.234088+01	2025-12-15 14:37:28.283072
341	1eab9750-4824-4de4-8168-04591fc249f7	message	uyuyhuhj	gghghghg	f	2025-12-15 14:37:28.283367	c878a3dd-f365-40e2-aea9-b58f96c6891f	2025-12-22 14:37:28.234088+01	2025-12-15 14:37:28.283367
342	6315b233-5988-421f-9cb9-95a8b68e00ce	message	uyuyhuhj	gghghghg	f	2025-12-15 14:37:28.283709	c878a3dd-f365-40e2-aea9-b58f96c6891f	2025-12-22 14:37:28.234088+01	2025-12-15 14:37:28.283709
343	ca9c9dd0-bfd0-4436-b804-cfa549e732db	message	uyuyhuhj	gghghghg	f	2025-12-15 14:37:28.28404	c878a3dd-f365-40e2-aea9-b58f96c6891f	2025-12-22 14:37:28.234088+01	2025-12-15 14:37:28.28404
344	f6702e7d-fe35-4bc2-b78b-5a04809e886c	message	uyuyhuhj	gghghghg	f	2025-12-15 14:37:28.284388	c878a3dd-f365-40e2-aea9-b58f96c6891f	2025-12-22 14:37:28.234088+01	2025-12-15 14:37:28.284388
345	fbd7dcb6-7dc8-478a-ba23-6fae56403e81	message	uyuyhuhj	gghghghg	f	2025-12-15 14:37:28.28468	c878a3dd-f365-40e2-aea9-b58f96c6891f	2025-12-22 14:37:28.234088+01	2025-12-15 14:37:28.28468
346	5f3fb9c6-b104-40cb-b27e-ce123ebd7fa6	message	uyuyhuhj	gghghghg	f	2025-12-15 14:37:28.284987	c878a3dd-f365-40e2-aea9-b58f96c6891f	2025-12-22 14:37:28.234088+01	2025-12-15 14:37:28.284987
347	f8642d75-f69a-487d-b385-661ecf2fc8fc	message	uyuyhuhj	gghghghg	f	2025-12-15 14:37:28.285285	c878a3dd-f365-40e2-aea9-b58f96c6891f	2025-12-22 14:37:28.234088+01	2025-12-15 14:37:28.285285
348	3b4d200d-8f2c-45c8-a3ae-2816d06f208c	message	uyuyhuhj	gghghghg	f	2025-12-15 14:37:28.285586	c878a3dd-f365-40e2-aea9-b58f96c6891f	2025-12-22 14:37:28.234088+01	2025-12-15 14:37:28.285586
349	a1ba9ca9-d129-47c4-b6ff-1d3a5fd1e27d	message	uyuyhuhj	gghghghg	f	2025-12-15 14:37:28.285905	c878a3dd-f365-40e2-aea9-b58f96c6891f	2025-12-22 14:37:28.234088+01	2025-12-15 14:37:28.285905
350	7af931a9-9b6d-464c-928a-56556aa73171	message	uyuyhuhj	gghghghg	f	2025-12-15 14:37:28.286249	c878a3dd-f365-40e2-aea9-b58f96c6891f	2025-12-22 14:37:28.234088+01	2025-12-15 14:37:28.286249
351	87e45cfe-99c0-46bf-8ea4-a53fb3c757b0	message	uyuyhuhj	gghghghg	f	2025-12-15 14:37:28.286547	c878a3dd-f365-40e2-aea9-b58f96c6891f	2025-12-22 14:37:28.234088+01	2025-12-15 14:37:28.286547
352	d1b4bda9-e6d2-4b36-a87b-63b34b14a47a	message	uyuyhuhj	gghghghg	f	2025-12-15 14:37:28.286838	c878a3dd-f365-40e2-aea9-b58f96c6891f	2025-12-22 14:37:28.234088+01	2025-12-15 14:37:28.286838
353	df4b5622-d10a-4be6-b3b9-ae9eb365621f	message	uyuyhuhj	gghghghg	f	2025-12-15 14:37:28.287141	c878a3dd-f365-40e2-aea9-b58f96c6891f	2025-12-22 14:37:28.234088+01	2025-12-15 14:37:28.287141
354	89dbb74e-de3b-4d24-981c-7638797c1e36	message	uyuyhuhj	gghghghg	f	2025-12-15 14:37:28.287477	c878a3dd-f365-40e2-aea9-b58f96c6891f	2025-12-22 14:37:28.234088+01	2025-12-15 14:37:28.287477
355	c7733a6f-9d5d-4d39-a724-f85c9d24d139	message	uyuyhuhj	gghghghg	f	2025-12-15 14:37:28.287865	c878a3dd-f365-40e2-aea9-b58f96c6891f	2025-12-22 14:37:28.234088+01	2025-12-15 14:37:28.287865
356	f4d0a02a-8a68-4eb2-af6e-e4f055c356c1	message	uyuyhuhj	gghghghg	f	2025-12-15 14:37:28.288138	c878a3dd-f365-40e2-aea9-b58f96c6891f	2025-12-22 14:37:28.234088+01	2025-12-15 14:37:28.288138
357	822a2fa1-b223-4057-aabc-82e54feea196	message	uyuyhuhj	gghghghg	f	2025-12-15 14:37:28.288427	c878a3dd-f365-40e2-aea9-b58f96c6891f	2025-12-22 14:37:28.234088+01	2025-12-15 14:37:28.288427
358	409f5414-a30a-4090-84cc-73f477407968	message	uyuyhuhj	gghghghg	f	2025-12-15 14:37:28.288684	c878a3dd-f365-40e2-aea9-b58f96c6891f	2025-12-22 14:37:28.234088+01	2025-12-15 14:37:28.288684
359	0ccaa979-7837-46cf-9514-826710479042	message	uyuyhuhj	gghghghg	f	2025-12-15 14:37:28.288918	c878a3dd-f365-40e2-aea9-b58f96c6891f	2025-12-22 14:37:28.234088+01	2025-12-15 14:37:28.288918
360	41e8c3cb-f9a4-4f2e-a473-d47e060e89d3	message	uyuyhuhj	gghghghg	f	2025-12-15 14:37:28.289344	c878a3dd-f365-40e2-aea9-b58f96c6891f	2025-12-22 14:37:28.234088+01	2025-12-15 14:37:28.289344
361	a4b3302a-4c26-4b9e-9205-c726f5b548f0	message	uyuyhuhj	gghghghg	f	2025-12-15 14:37:28.289583	c878a3dd-f365-40e2-aea9-b58f96c6891f	2025-12-22 14:37:28.234088+01	2025-12-15 14:37:28.289583
362	64c22400-eb47-46b1-93fb-11110d7121f1	message	uyuyhuhj	gghghghg	f	2025-12-15 14:37:28.289853	c878a3dd-f365-40e2-aea9-b58f96c6891f	2025-12-22 14:37:28.234088+01	2025-12-15 14:37:28.289853
363	9d401424-6da4-4e9a-8568-00174cd56050	message	uyuyhuhj	gghghghg	f	2025-12-15 14:37:28.290098	c878a3dd-f365-40e2-aea9-b58f96c6891f	2025-12-22 14:37:28.234088+01	2025-12-15 14:37:28.290098
364	f1361a2d-c534-4cfd-81a0-796ed17b4339	message	uyuyhuhj	gghghghg	f	2025-12-15 14:37:28.290332	c878a3dd-f365-40e2-aea9-b58f96c6891f	2025-12-22 14:37:28.234088+01	2025-12-15 14:37:28.290332
365	00feec4b-e498-452b-b081-cf480e16aec2	message	uyuyhuhj	gghghghg	f	2025-12-15 14:37:28.290557	c878a3dd-f365-40e2-aea9-b58f96c6891f	2025-12-22 14:37:28.234088+01	2025-12-15 14:37:28.290557
366	02762b1e-9b2f-4bfe-943c-d6c28827ef96	message	uyuyhuhj	gghghghg	f	2025-12-15 14:37:28.290784	c878a3dd-f365-40e2-aea9-b58f96c6891f	2025-12-22 14:37:28.234088+01	2025-12-15 14:37:28.290784
367	86407ed7-40bf-4420-9053-f64c6121188e	message	uyuyhuhj	gghghghg	f	2025-12-15 14:37:28.290993	c878a3dd-f365-40e2-aea9-b58f96c6891f	2025-12-22 14:37:28.234088+01	2025-12-15 14:37:28.290993
368	22d26f27-6768-43ec-b08e-4b20b924b76f	message	uyuyhuhj	gghghghg	f	2025-12-15 14:37:28.291239	c878a3dd-f365-40e2-aea9-b58f96c6891f	2025-12-22 14:37:28.234088+01	2025-12-15 14:37:28.291239
369	c2b365e0-5404-4d85-b9e1-515e0cd9afe9	message	uyuyhuhj	gghghghg	f	2025-12-15 14:37:28.291479	c878a3dd-f365-40e2-aea9-b58f96c6891f	2025-12-22 14:37:28.234088+01	2025-12-15 14:37:28.291479
370	aefab581-f8c3-42a0-b79a-55d0270f3d00	message	uyuyhuhj	gghghghg	f	2025-12-15 14:37:28.291693	c878a3dd-f365-40e2-aea9-b58f96c6891f	2025-12-22 14:37:28.234088+01	2025-12-15 14:37:28.291693
371	5be8065b-44d4-4fab-aa82-b64bda2b368a	message	uyuyhuhj	gghghghg	f	2025-12-15 14:37:28.291906	c878a3dd-f365-40e2-aea9-b58f96c6891f	2025-12-22 14:37:28.234088+01	2025-12-15 14:37:28.291906
372	d9df9370-0442-4365-9ed0-3b59afc81ec1	message	uyuyhuhj	gghghghg	f	2025-12-15 14:37:28.292114	c878a3dd-f365-40e2-aea9-b58f96c6891f	2025-12-22 14:37:28.234088+01	2025-12-15 14:37:28.292114
373	9c77950e-3ebc-4846-aed1-2faae86cbb37	message	uyuyhuhj	gghghghg	f	2025-12-15 14:37:28.292321	c878a3dd-f365-40e2-aea9-b58f96c6891f	2025-12-22 14:37:28.234088+01	2025-12-15 14:37:28.292321
374	66024a16-884c-408e-bead-dd134927a58a	message	uyuyhuhj	gghghghg	f	2025-12-15 14:37:28.292532	c878a3dd-f365-40e2-aea9-b58f96c6891f	2025-12-22 14:37:28.234088+01	2025-12-15 14:37:28.292532
375	c6fa2131-7fea-459e-9df8-2ff37f1a39bb	message	uyuyhuhj	gghghghg	f	2025-12-15 14:37:28.292737	c878a3dd-f365-40e2-aea9-b58f96c6891f	2025-12-22 14:37:28.234088+01	2025-12-15 14:37:28.292737
376	694655b7-cfa9-418e-9f29-1753df0adbfd	message	uyuyhuhj	gghghghg	f	2025-12-15 14:37:28.292948	c878a3dd-f365-40e2-aea9-b58f96c6891f	2025-12-22 14:37:28.234088+01	2025-12-15 14:37:28.292948
377	c84d7da8-2f5e-4123-85c5-989ba74e3520	message	uyuyhuhj	gghghghg	f	2025-12-15 14:37:28.29315	c878a3dd-f365-40e2-aea9-b58f96c6891f	2025-12-22 14:37:28.234088+01	2025-12-15 14:37:28.29315
378	c58f03b5-12e4-45c5-b71d-21ffeb6b0c40	message	uyuyhuhj	gghghghg	f	2025-12-15 14:37:28.293354	c878a3dd-f365-40e2-aea9-b58f96c6891f	2025-12-22 14:37:28.234088+01	2025-12-15 14:37:28.293354
379	905773e4-02be-4a57-9046-7bd29db1fa03	message	uyuyhuhj	gghghghg	f	2025-12-15 14:37:28.293563	c878a3dd-f365-40e2-aea9-b58f96c6891f	2025-12-22 14:37:28.234088+01	2025-12-15 14:37:28.293563
380	243a4471-81e9-469e-ae44-7685b225e07b	message	uyuyhuhj	gghghghg	f	2025-12-15 14:37:28.293772	c878a3dd-f365-40e2-aea9-b58f96c6891f	2025-12-22 14:37:28.234088+01	2025-12-15 14:37:28.293772
381	afb04864-9ab2-4994-918c-397a2a035d84	message	uyuyhuhj	gghghghg	f	2025-12-15 14:37:28.293973	c878a3dd-f365-40e2-aea9-b58f96c6891f	2025-12-22 14:37:28.234088+01	2025-12-15 14:37:28.293973
382	5c39ac09-558d-4836-9bb6-f1de81d58f9d	message	uyuyhuhj	gghghghg	f	2025-12-15 14:37:28.294195	c878a3dd-f365-40e2-aea9-b58f96c6891f	2025-12-22 14:37:28.234088+01	2025-12-15 14:37:28.294195
383	3f324c9c-7c0d-4dbc-8c49-cd943f36fc27	message	uyuyhuhj	gghghghg	f	2025-12-15 14:37:28.294588	c878a3dd-f365-40e2-aea9-b58f96c6891f	2025-12-22 14:37:28.234088+01	2025-12-15 14:37:28.294588
384	2a643039-c6a0-4791-b022-07b0fbfddd3a	message	uyuyhuhj	gghghghg	f	2025-12-15 14:37:28.294812	c878a3dd-f365-40e2-aea9-b58f96c6891f	2025-12-22 14:37:28.234088+01	2025-12-15 14:37:28.294812
385	020e710e-e419-4c74-9848-3b00770353c6	message	uyuyhuhj	gghghghg	f	2025-12-15 14:37:28.295042	c878a3dd-f365-40e2-aea9-b58f96c6891f	2025-12-22 14:37:28.234088+01	2025-12-15 14:37:28.295042
386	f4d858f5-58b1-4727-96d5-5b27be00ebbe	message	uyuyhuhj	gghghghg	f	2025-12-15 14:37:28.29545	c878a3dd-f365-40e2-aea9-b58f96c6891f	2025-12-22 14:37:28.234088+01	2025-12-15 14:37:28.29545
387	1ca1e403-5ac5-495e-86b5-0e60c397393b	message	uyuyhuhj	gghghghg	f	2025-12-15 14:37:28.295724	c878a3dd-f365-40e2-aea9-b58f96c6891f	2025-12-22 14:37:28.234088+01	2025-12-15 14:37:28.295724
388	9b36ebb6-1b40-4fa5-8fad-736b04b5b4ea	message	uyuyhuhj	gghghghg	f	2025-12-15 14:37:28.295962	c878a3dd-f365-40e2-aea9-b58f96c6891f	2025-12-22 14:37:28.234088+01	2025-12-15 14:37:28.295962
389	03613595-b764-4cb5-9d23-ebb2055a9fe1	message	uyuyhuhj	gghghghg	f	2025-12-15 14:37:28.29623	c878a3dd-f365-40e2-aea9-b58f96c6891f	2025-12-22 14:37:28.234088+01	2025-12-15 14:37:28.29623
390	59775d98-8c8e-4a7b-99ed-11920c2bd80b	message	uyuyhuhj	gghghghg	f	2025-12-15 14:37:28.296468	c878a3dd-f365-40e2-aea9-b58f96c6891f	2025-12-22 14:37:28.234088+01	2025-12-15 14:37:28.296468
391	b6ac4b5c-2caf-4bd6-83e9-ae3d7df27970	message	uyuyhuhj	gghghghg	f	2025-12-15 14:37:28.296673	c878a3dd-f365-40e2-aea9-b58f96c6891f	2025-12-22 14:37:28.234088+01	2025-12-15 14:37:28.296673
392	5738ce10-3634-42f7-91d7-91f21cfb64f3	message	uyuyhuhj	gghghghg	f	2025-12-15 14:37:28.296864	c878a3dd-f365-40e2-aea9-b58f96c6891f	2025-12-22 14:37:28.234088+01	2025-12-15 14:37:28.296864
393	a4f64b75-1bbe-4fb1-80d5-f441b6b9bee2	message	uyuyhuhj	gghghghg	f	2025-12-15 14:37:28.297045	c878a3dd-f365-40e2-aea9-b58f96c6891f	2025-12-22 14:37:28.234088+01	2025-12-15 14:37:28.297045
395	9a2b27aa-e90a-4409-8373-2be363ee206e	message	uyuyhuhj	gghghghg	f	2025-12-15 14:37:28.297487	c878a3dd-f365-40e2-aea9-b58f96c6891f	2025-12-22 14:37:28.234088+01	2025-12-15 14:37:28.297487
396	34d7356b-9cea-4a80-a7be-93d7def7d260	message	uyuyhuhj	gghghghg	f	2025-12-15 14:37:28.297676	c878a3dd-f365-40e2-aea9-b58f96c6891f	2025-12-22 14:37:28.234088+01	2025-12-15 14:37:28.297676
397	489473cf-735a-4831-ac2a-f94ce58afca4	message	uyuyhuhj	gghghghg	f	2025-12-15 14:37:28.297873	c878a3dd-f365-40e2-aea9-b58f96c6891f	2025-12-22 14:37:28.234088+01	2025-12-15 14:37:28.297873
398	412e9a12-7529-4bc7-85c7-f88df5e191d1	message	uyuyhuhj	gghghghg	f	2025-12-15 14:37:28.298074	c878a3dd-f365-40e2-aea9-b58f96c6891f	2025-12-22 14:37:28.234088+01	2025-12-15 14:37:28.298074
399	c492c079-7db5-4261-9983-2492048902eb	message	uyuyhuhj	gghghghg	f	2025-12-15 14:37:28.298324	c878a3dd-f365-40e2-aea9-b58f96c6891f	2025-12-22 14:37:28.234088+01	2025-12-15 14:37:28.298324
400	aecbb92c-bbe9-4a05-9dc2-a1f290e41deb	message	uyuyhuhj	gghghghg	f	2025-12-15 14:37:28.29852	c878a3dd-f365-40e2-aea9-b58f96c6891f	2025-12-22 14:37:28.234088+01	2025-12-15 14:37:28.29852
401	fac4c4eb-47c1-4552-9e92-3f24ca63a922	message	uyuyhuhj	gghghghg	f	2025-12-15 14:37:28.299398	c878a3dd-f365-40e2-aea9-b58f96c6891f	2025-12-22 14:37:28.234088+01	2025-12-15 14:37:28.299398
402	552e83ca-0eaa-4d94-87aa-9c4958aa811e	message	uyuyhuhj	gghghghg	f	2025-12-15 14:37:28.299774	c878a3dd-f365-40e2-aea9-b58f96c6891f	2025-12-22 14:37:28.234088+01	2025-12-15 14:37:28.299774
403	544e6fb5-b91e-43be-89f6-90546a7f0669	message	uyuyhuhj	gghghghg	f	2025-12-15 14:37:28.300009	c878a3dd-f365-40e2-aea9-b58f96c6891f	2025-12-22 14:37:28.234088+01	2025-12-15 14:37:28.300009
404	e001d25d-7ef8-44c7-8213-2777aa595970	message	uyuyhuhj	gghghghg	f	2025-12-15 14:37:28.300241	c878a3dd-f365-40e2-aea9-b58f96c6891f	2025-12-22 14:37:28.234088+01	2025-12-15 14:37:28.300241
405	1d71f3e9-7f85-49b8-a65e-b9c819ad19cb	message	uyuyhuhj	gghghghg	f	2025-12-15 14:37:28.300455	c878a3dd-f365-40e2-aea9-b58f96c6891f	2025-12-22 14:37:28.234088+01	2025-12-15 14:37:28.300455
406	1ebbf9f9-6184-4687-a5cf-a5b7c6d11717	message	uyuyhuhj	gghghghg	f	2025-12-15 14:37:28.30065	c878a3dd-f365-40e2-aea9-b58f96c6891f	2025-12-22 14:37:28.234088+01	2025-12-15 14:37:28.30065
407	c848bf8a-43a8-4d05-94cc-9d5033405cd7	message	uyuyhuhj	gghghghg	f	2025-12-15 14:37:28.300849	c878a3dd-f365-40e2-aea9-b58f96c6891f	2025-12-22 14:37:28.234088+01	2025-12-15 14:37:28.300849
408	0919939d-1f4b-485c-b66e-1c24d710930d	message	uyuyhuhj	gghghghg	f	2025-12-15 14:37:28.301034	c878a3dd-f365-40e2-aea9-b58f96c6891f	2025-12-22 14:37:28.234088+01	2025-12-15 14:37:28.301034
409	8c59a07a-41dc-4d55-b55b-f82800569e9c	message	uyuyhuhj	gghghghg	f	2025-12-15 14:37:28.302124	c878a3dd-f365-40e2-aea9-b58f96c6891f	2025-12-22 14:37:28.234088+01	2025-12-15 14:37:28.302124
410	6392ac81-e8b5-4b27-a2dc-b0a34a449659	message	uyuyhuhj	gghghghg	f	2025-12-15 14:37:28.302347	c878a3dd-f365-40e2-aea9-b58f96c6891f	2025-12-22 14:37:28.234088+01	2025-12-15 14:37:28.302347
411	b45f33f6-4f98-4d00-af3d-6bae657c2deb	message	uyuyhuhj	gghghghg	f	2025-12-15 14:37:28.302597	c878a3dd-f365-40e2-aea9-b58f96c6891f	2025-12-22 14:37:28.234088+01	2025-12-15 14:37:28.302597
412	1e193b09-87bc-48c4-b666-94f910cf5882	message	uyuyhuhj	gghghghg	f	2025-12-15 14:37:28.302815	c878a3dd-f365-40e2-aea9-b58f96c6891f	2025-12-22 14:37:28.234088+01	2025-12-15 14:37:28.302815
413	cebe720e-d2f1-4b0e-9107-4da7b543fe4b	message	uyuyhuhj	gghghghg	f	2025-12-15 14:37:28.303052	c878a3dd-f365-40e2-aea9-b58f96c6891f	2025-12-22 14:37:28.234088+01	2025-12-15 14:37:28.303052
414	1a6bdfd6-888d-44f7-8f49-eaa05b8af956	message	uyuyhuhj	gghghghg	f	2025-12-15 14:37:28.303259	c878a3dd-f365-40e2-aea9-b58f96c6891f	2025-12-22 14:37:28.234088+01	2025-12-15 14:37:28.303259
415	5eebb1da-4f4a-4422-9d3b-406c89f80c89	message	uyuyhuhj	gghghghg	f	2025-12-15 14:37:28.303446	c878a3dd-f365-40e2-aea9-b58f96c6891f	2025-12-22 14:37:28.234088+01	2025-12-15 14:37:28.303446
416	b5d7896a-9217-480e-b4ac-8343141a3333	message	uyuyhuhj	gghghghg	f	2025-12-15 14:38:42.565034	119441b6-93ba-441c-bb86-5880cf45f708	2025-12-22 14:38:42.563505+01	2025-12-15 14:38:42.565034
417	8e57948f-983c-4db3-b517-a46b3d3531b3	message	uyuyhuhj	gghghghg	f	2025-12-15 14:38:42.567698	119441b6-93ba-441c-bb86-5880cf45f708	2025-12-22 14:38:42.563505+01	2025-12-15 14:38:42.567698
418	e6bcd428-3711-4d17-80b4-5fab412563bd	message	uyuyhuhj	gghghghg	f	2025-12-15 14:38:42.568797	119441b6-93ba-441c-bb86-5880cf45f708	2025-12-22 14:38:42.563505+01	2025-12-15 14:38:42.568797
419	97dabb21-c5cd-434c-8bff-ae86b3682018	message	uyuyhuhj	gghghghg	f	2025-12-15 14:38:42.569841	119441b6-93ba-441c-bb86-5880cf45f708	2025-12-22 14:38:42.563505+01	2025-12-15 14:38:42.569841
420	23a2c030-e381-40b0-885f-efe8c6ccf388	message	uyuyhuhj	gghghghg	f	2025-12-15 14:38:42.570674	119441b6-93ba-441c-bb86-5880cf45f708	2025-12-22 14:38:42.563505+01	2025-12-15 14:38:42.570674
421	f50c5c53-dd6a-4380-9d6f-1410b29a7fa4	message	uyuyhuhj	gghghghg	f	2025-12-15 14:38:42.571301	119441b6-93ba-441c-bb86-5880cf45f708	2025-12-22 14:38:42.563505+01	2025-12-15 14:38:42.571301
422	3edac621-15bc-43a1-9a09-19231b503c80	message	uyuyhuhj	gghghghg	f	2025-12-15 14:38:42.571734	119441b6-93ba-441c-bb86-5880cf45f708	2025-12-22 14:38:42.563505+01	2025-12-15 14:38:42.571734
423	8ddcb7e7-9941-46bb-866b-6aae3a217a5d	message	uyuyhuhj	gghghghg	f	2025-12-15 14:38:42.572529	119441b6-93ba-441c-bb86-5880cf45f708	2025-12-22 14:38:42.563505+01	2025-12-15 14:38:42.572529
424	2b9793bf-f240-4cf8-a94a-c4b652f0ae0b	message	uyuyhuhj	gghghghg	f	2025-12-15 14:38:42.573058	119441b6-93ba-441c-bb86-5880cf45f708	2025-12-22 14:38:42.563505+01	2025-12-15 14:38:42.573058
425	710974ab-52fc-4726-b50a-b309d5b7d9ba	message	uyuyhuhj	gghghghg	f	2025-12-15 14:38:42.5735	119441b6-93ba-441c-bb86-5880cf45f708	2025-12-22 14:38:42.563505+01	2025-12-15 14:38:42.5735
426	9f68aa0f-c6c7-4b73-a4d9-d3225b88c2f0	message	uyuyhuhj	gghghghg	f	2025-12-15 14:38:42.574462	119441b6-93ba-441c-bb86-5880cf45f708	2025-12-22 14:38:42.563505+01	2025-12-15 14:38:42.574462
427	805b6158-8b01-4f05-90f2-a0fcad495cb9	message	uyuyhuhj	gghghghg	f	2025-12-15 14:38:42.575319	119441b6-93ba-441c-bb86-5880cf45f708	2025-12-22 14:38:42.563505+01	2025-12-15 14:38:42.575319
428	a7a5977d-c912-4476-b8c1-89d6a6dec0ee	message	uyuyhuhj	gghghghg	f	2025-12-15 14:38:42.576514	119441b6-93ba-441c-bb86-5880cf45f708	2025-12-22 14:38:42.563505+01	2025-12-15 14:38:42.576514
429	085df28e-fb49-420c-bea9-0432c9199f40	message	uyuyhuhj	gghghghg	f	2025-12-15 14:38:42.577104	119441b6-93ba-441c-bb86-5880cf45f708	2025-12-22 14:38:42.563505+01	2025-12-15 14:38:42.577104
430	d2e4dc25-672a-485e-98b8-0126b3f10d28	message	uyuyhuhj	gghghghg	f	2025-12-15 14:38:42.578981	119441b6-93ba-441c-bb86-5880cf45f708	2025-12-22 14:38:42.563505+01	2025-12-15 14:38:42.578981
431	61bd6a53-cd0b-4af7-9166-c8385d448f8f	message	uyuyhuhj	gghghghg	f	2025-12-15 14:38:42.579648	119441b6-93ba-441c-bb86-5880cf45f708	2025-12-22 14:38:42.563505+01	2025-12-15 14:38:42.579648
432	891bbc40-a563-4fab-9ca0-a0defd6abbe3	message	uyuyhuhj	gghghghg	f	2025-12-15 14:38:42.580165	119441b6-93ba-441c-bb86-5880cf45f708	2025-12-22 14:38:42.563505+01	2025-12-15 14:38:42.580165
433	81e8d990-cba5-41df-8c92-f74cdbc3a71a	message	uyuyhuhj	gghghghg	f	2025-12-15 14:38:42.580579	119441b6-93ba-441c-bb86-5880cf45f708	2025-12-22 14:38:42.563505+01	2025-12-15 14:38:42.580579
434	e116ad22-a5f7-4bcd-9577-8b5f9beeaf46	message	uyuyhuhj	gghghghg	f	2025-12-15 14:38:42.580928	119441b6-93ba-441c-bb86-5880cf45f708	2025-12-22 14:38:42.563505+01	2025-12-15 14:38:42.580928
435	9b40e7c8-5dde-4b3b-8574-4cdb3453fc31	message	uyuyhuhj	gghghghg	f	2025-12-15 14:38:42.581291	119441b6-93ba-441c-bb86-5880cf45f708	2025-12-22 14:38:42.563505+01	2025-12-15 14:38:42.581291
436	8f675035-cc06-4b4e-89b6-db4f7c123ed2	message	uyuyhuhj	gghghghg	f	2025-12-15 14:38:42.581638	119441b6-93ba-441c-bb86-5880cf45f708	2025-12-22 14:38:42.563505+01	2025-12-15 14:38:42.581638
437	376e41c2-4a6e-4010-ba3d-24eb0c509ada	message	uyuyhuhj	gghghghg	f	2025-12-15 14:38:42.582018	119441b6-93ba-441c-bb86-5880cf45f708	2025-12-22 14:38:42.563505+01	2025-12-15 14:38:42.582018
438	091177fc-3b2c-4858-8ea0-b8f7206b4636	message	uyuyhuhj	gghghghg	f	2025-12-15 14:38:42.582487	119441b6-93ba-441c-bb86-5880cf45f708	2025-12-22 14:38:42.563505+01	2025-12-15 14:38:42.582487
439	7ef2acf4-d876-4a29-b1f0-db8301f817a6	message	uyuyhuhj	gghghghg	f	2025-12-15 14:38:42.582963	119441b6-93ba-441c-bb86-5880cf45f708	2025-12-22 14:38:42.563505+01	2025-12-15 14:38:42.582963
440	7b63533f-02f3-4491-9808-64ad90a92334	message	uyuyhuhj	gghghghg	f	2025-12-15 14:38:42.583433	119441b6-93ba-441c-bb86-5880cf45f708	2025-12-22 14:38:42.563505+01	2025-12-15 14:38:42.583433
441	d2940649-78f0-4418-88b4-7b16a9a7104f	message	uyuyhuhj	gghghghg	f	2025-12-15 14:38:42.584061	119441b6-93ba-441c-bb86-5880cf45f708	2025-12-22 14:38:42.563505+01	2025-12-15 14:38:42.584061
442	a8f9ccad-6eef-45ea-b1d9-9b24ec7ab5a9	message	uyuyhuhj	gghghghg	f	2025-12-15 14:38:42.584488	119441b6-93ba-441c-bb86-5880cf45f708	2025-12-22 14:38:42.563505+01	2025-12-15 14:38:42.584488
443	b4801419-3838-4ac9-9c94-b05568dbf2b1	message	uyuyhuhj	gghghghg	f	2025-12-15 14:38:42.584879	119441b6-93ba-441c-bb86-5880cf45f708	2025-12-22 14:38:42.563505+01	2025-12-15 14:38:42.584879
444	1eab9750-4824-4de4-8168-04591fc249f7	message	uyuyhuhj	gghghghg	f	2025-12-15 14:38:42.585313	119441b6-93ba-441c-bb86-5880cf45f708	2025-12-22 14:38:42.563505+01	2025-12-15 14:38:42.585313
445	6315b233-5988-421f-9cb9-95a8b68e00ce	message	uyuyhuhj	gghghghg	f	2025-12-15 14:38:42.585825	119441b6-93ba-441c-bb86-5880cf45f708	2025-12-22 14:38:42.563505+01	2025-12-15 14:38:42.585825
446	ca9c9dd0-bfd0-4436-b804-cfa549e732db	message	uyuyhuhj	gghghghg	f	2025-12-15 14:38:42.58628	119441b6-93ba-441c-bb86-5880cf45f708	2025-12-22 14:38:42.563505+01	2025-12-15 14:38:42.58628
447	f6702e7d-fe35-4bc2-b78b-5a04809e886c	message	uyuyhuhj	gghghghg	f	2025-12-15 14:38:42.586712	119441b6-93ba-441c-bb86-5880cf45f708	2025-12-22 14:38:42.563505+01	2025-12-15 14:38:42.586712
448	fbd7dcb6-7dc8-478a-ba23-6fae56403e81	message	uyuyhuhj	gghghghg	f	2025-12-15 14:38:42.587098	119441b6-93ba-441c-bb86-5880cf45f708	2025-12-22 14:38:42.563505+01	2025-12-15 14:38:42.587098
449	5f3fb9c6-b104-40cb-b27e-ce123ebd7fa6	message	uyuyhuhj	gghghghg	f	2025-12-15 14:38:42.587442	119441b6-93ba-441c-bb86-5880cf45f708	2025-12-22 14:38:42.563505+01	2025-12-15 14:38:42.587442
450	f8642d75-f69a-487d-b385-661ecf2fc8fc	message	uyuyhuhj	gghghghg	f	2025-12-15 14:38:42.587768	119441b6-93ba-441c-bb86-5880cf45f708	2025-12-22 14:38:42.563505+01	2025-12-15 14:38:42.587768
451	3b4d200d-8f2c-45c8-a3ae-2816d06f208c	message	uyuyhuhj	gghghghg	f	2025-12-15 14:38:42.588095	119441b6-93ba-441c-bb86-5880cf45f708	2025-12-22 14:38:42.563505+01	2025-12-15 14:38:42.588095
452	a1ba9ca9-d129-47c4-b6ff-1d3a5fd1e27d	message	uyuyhuhj	gghghghg	f	2025-12-15 14:38:42.588432	119441b6-93ba-441c-bb86-5880cf45f708	2025-12-22 14:38:42.563505+01	2025-12-15 14:38:42.588432
453	7af931a9-9b6d-464c-928a-56556aa73171	message	uyuyhuhj	gghghghg	f	2025-12-15 14:38:42.588768	119441b6-93ba-441c-bb86-5880cf45f708	2025-12-22 14:38:42.563505+01	2025-12-15 14:38:42.588768
454	87e45cfe-99c0-46bf-8ea4-a53fb3c757b0	message	uyuyhuhj	gghghghg	f	2025-12-15 14:38:42.58914	119441b6-93ba-441c-bb86-5880cf45f708	2025-12-22 14:38:42.563505+01	2025-12-15 14:38:42.58914
455	d1b4bda9-e6d2-4b36-a87b-63b34b14a47a	message	uyuyhuhj	gghghghg	f	2025-12-15 14:38:42.589511	119441b6-93ba-441c-bb86-5880cf45f708	2025-12-22 14:38:42.563505+01	2025-12-15 14:38:42.589511
456	df4b5622-d10a-4be6-b3b9-ae9eb365621f	message	uyuyhuhj	gghghghg	f	2025-12-15 14:38:42.590032	119441b6-93ba-441c-bb86-5880cf45f708	2025-12-22 14:38:42.563505+01	2025-12-15 14:38:42.590032
457	89dbb74e-de3b-4d24-981c-7638797c1e36	message	uyuyhuhj	gghghghg	f	2025-12-15 14:38:42.590654	119441b6-93ba-441c-bb86-5880cf45f708	2025-12-22 14:38:42.563505+01	2025-12-15 14:38:42.590654
458	c7733a6f-9d5d-4d39-a724-f85c9d24d139	message	uyuyhuhj	gghghghg	f	2025-12-15 14:38:42.59143	119441b6-93ba-441c-bb86-5880cf45f708	2025-12-22 14:38:42.563505+01	2025-12-15 14:38:42.59143
459	f4d0a02a-8a68-4eb2-af6e-e4f055c356c1	message	uyuyhuhj	gghghghg	f	2025-12-15 14:38:42.591975	119441b6-93ba-441c-bb86-5880cf45f708	2025-12-22 14:38:42.563505+01	2025-12-15 14:38:42.591975
460	822a2fa1-b223-4057-aabc-82e54feea196	message	uyuyhuhj	gghghghg	f	2025-12-15 14:38:42.592477	119441b6-93ba-441c-bb86-5880cf45f708	2025-12-22 14:38:42.563505+01	2025-12-15 14:38:42.592477
461	409f5414-a30a-4090-84cc-73f477407968	message	uyuyhuhj	gghghghg	f	2025-12-15 14:38:42.592933	119441b6-93ba-441c-bb86-5880cf45f708	2025-12-22 14:38:42.563505+01	2025-12-15 14:38:42.592933
462	0ccaa979-7837-46cf-9514-826710479042	message	uyuyhuhj	gghghghg	f	2025-12-15 14:38:42.593363	119441b6-93ba-441c-bb86-5880cf45f708	2025-12-22 14:38:42.563505+01	2025-12-15 14:38:42.593363
463	41e8c3cb-f9a4-4f2e-a473-d47e060e89d3	message	uyuyhuhj	gghghghg	f	2025-12-15 14:38:42.593778	119441b6-93ba-441c-bb86-5880cf45f708	2025-12-22 14:38:42.563505+01	2025-12-15 14:38:42.593778
464	a4b3302a-4c26-4b9e-9205-c726f5b548f0	message	uyuyhuhj	gghghghg	f	2025-12-15 14:38:42.594231	119441b6-93ba-441c-bb86-5880cf45f708	2025-12-22 14:38:42.563505+01	2025-12-15 14:38:42.594231
465	64c22400-eb47-46b1-93fb-11110d7121f1	message	uyuyhuhj	gghghghg	f	2025-12-15 14:38:42.594642	119441b6-93ba-441c-bb86-5880cf45f708	2025-12-22 14:38:42.563505+01	2025-12-15 14:38:42.594642
466	9d401424-6da4-4e9a-8568-00174cd56050	message	uyuyhuhj	gghghghg	f	2025-12-15 14:38:42.595089	119441b6-93ba-441c-bb86-5880cf45f708	2025-12-22 14:38:42.563505+01	2025-12-15 14:38:42.595089
467	f1361a2d-c534-4cfd-81a0-796ed17b4339	message	uyuyhuhj	gghghghg	f	2025-12-15 14:38:42.596858	119441b6-93ba-441c-bb86-5880cf45f708	2025-12-22 14:38:42.563505+01	2025-12-15 14:38:42.596858
468	00feec4b-e498-452b-b081-cf480e16aec2	message	uyuyhuhj	gghghghg	f	2025-12-15 14:38:42.597331	119441b6-93ba-441c-bb86-5880cf45f708	2025-12-22 14:38:42.563505+01	2025-12-15 14:38:42.597331
469	02762b1e-9b2f-4bfe-943c-d6c28827ef96	message	uyuyhuhj	gghghghg	f	2025-12-15 14:38:42.59837	119441b6-93ba-441c-bb86-5880cf45f708	2025-12-22 14:38:42.563505+01	2025-12-15 14:38:42.59837
470	86407ed7-40bf-4420-9053-f64c6121188e	message	uyuyhuhj	gghghghg	f	2025-12-15 14:38:42.598703	119441b6-93ba-441c-bb86-5880cf45f708	2025-12-22 14:38:42.563505+01	2025-12-15 14:38:42.598703
471	22d26f27-6768-43ec-b08e-4b20b924b76f	message	uyuyhuhj	gghghghg	f	2025-12-15 14:38:42.599084	119441b6-93ba-441c-bb86-5880cf45f708	2025-12-22 14:38:42.563505+01	2025-12-15 14:38:42.599084
472	c2b365e0-5404-4d85-b9e1-515e0cd9afe9	message	uyuyhuhj	gghghghg	f	2025-12-15 14:38:42.599438	119441b6-93ba-441c-bb86-5880cf45f708	2025-12-22 14:38:42.563505+01	2025-12-15 14:38:42.599438
473	aefab581-f8c3-42a0-b79a-55d0270f3d00	message	uyuyhuhj	gghghghg	f	2025-12-15 14:38:42.599832	119441b6-93ba-441c-bb86-5880cf45f708	2025-12-22 14:38:42.563505+01	2025-12-15 14:38:42.599832
474	5be8065b-44d4-4fab-aa82-b64bda2b368a	message	uyuyhuhj	gghghghg	f	2025-12-15 14:38:42.60167	119441b6-93ba-441c-bb86-5880cf45f708	2025-12-22 14:38:42.563505+01	2025-12-15 14:38:42.60167
475	d9df9370-0442-4365-9ed0-3b59afc81ec1	message	uyuyhuhj	gghghghg	f	2025-12-15 14:38:42.602244	119441b6-93ba-441c-bb86-5880cf45f708	2025-12-22 14:38:42.563505+01	2025-12-15 14:38:42.602244
476	9c77950e-3ebc-4846-aed1-2faae86cbb37	message	uyuyhuhj	gghghghg	f	2025-12-15 14:38:42.602653	119441b6-93ba-441c-bb86-5880cf45f708	2025-12-22 14:38:42.563505+01	2025-12-15 14:38:42.602653
477	66024a16-884c-408e-bead-dd134927a58a	message	uyuyhuhj	gghghghg	f	2025-12-15 14:38:42.603025	119441b6-93ba-441c-bb86-5880cf45f708	2025-12-22 14:38:42.563505+01	2025-12-15 14:38:42.603025
478	c6fa2131-7fea-459e-9df8-2ff37f1a39bb	message	uyuyhuhj	gghghghg	f	2025-12-15 14:38:42.603437	119441b6-93ba-441c-bb86-5880cf45f708	2025-12-22 14:38:42.563505+01	2025-12-15 14:38:42.603437
479	694655b7-cfa9-418e-9f29-1753df0adbfd	message	uyuyhuhj	gghghghg	f	2025-12-15 14:38:42.603875	119441b6-93ba-441c-bb86-5880cf45f708	2025-12-22 14:38:42.563505+01	2025-12-15 14:38:42.603875
480	c84d7da8-2f5e-4123-85c5-989ba74e3520	message	uyuyhuhj	gghghghg	f	2025-12-15 14:38:42.604333	119441b6-93ba-441c-bb86-5880cf45f708	2025-12-22 14:38:42.563505+01	2025-12-15 14:38:42.604333
481	c58f03b5-12e4-45c5-b71d-21ffeb6b0c40	message	uyuyhuhj	gghghghg	f	2025-12-15 14:38:42.604695	119441b6-93ba-441c-bb86-5880cf45f708	2025-12-22 14:38:42.563505+01	2025-12-15 14:38:42.604695
482	905773e4-02be-4a57-9046-7bd29db1fa03	message	uyuyhuhj	gghghghg	f	2025-12-15 14:38:42.605019	119441b6-93ba-441c-bb86-5880cf45f708	2025-12-22 14:38:42.563505+01	2025-12-15 14:38:42.605019
483	243a4471-81e9-469e-ae44-7685b225e07b	message	uyuyhuhj	gghghghg	f	2025-12-15 14:38:42.605347	119441b6-93ba-441c-bb86-5880cf45f708	2025-12-22 14:38:42.563505+01	2025-12-15 14:38:42.605347
484	afb04864-9ab2-4994-918c-397a2a035d84	message	uyuyhuhj	gghghghg	f	2025-12-15 14:38:42.605689	119441b6-93ba-441c-bb86-5880cf45f708	2025-12-22 14:38:42.563505+01	2025-12-15 14:38:42.605689
485	5c39ac09-558d-4836-9bb6-f1de81d58f9d	message	uyuyhuhj	gghghghg	f	2025-12-15 14:38:42.606141	119441b6-93ba-441c-bb86-5880cf45f708	2025-12-22 14:38:42.563505+01	2025-12-15 14:38:42.606141
486	3f324c9c-7c0d-4dbc-8c49-cd943f36fc27	message	uyuyhuhj	gghghghg	f	2025-12-15 14:38:42.606598	119441b6-93ba-441c-bb86-5880cf45f708	2025-12-22 14:38:42.563505+01	2025-12-15 14:38:42.606598
487	2a643039-c6a0-4791-b022-07b0fbfddd3a	message	uyuyhuhj	gghghghg	f	2025-12-15 14:38:42.606929	119441b6-93ba-441c-bb86-5880cf45f708	2025-12-22 14:38:42.563505+01	2025-12-15 14:38:42.606929
488	020e710e-e419-4c74-9848-3b00770353c6	message	uyuyhuhj	gghghghg	f	2025-12-15 14:38:42.607195	119441b6-93ba-441c-bb86-5880cf45f708	2025-12-22 14:38:42.563505+01	2025-12-15 14:38:42.607195
489	f4d858f5-58b1-4727-96d5-5b27be00ebbe	message	uyuyhuhj	gghghghg	f	2025-12-15 14:38:42.607419	119441b6-93ba-441c-bb86-5880cf45f708	2025-12-22 14:38:42.563505+01	2025-12-15 14:38:42.607419
490	1ca1e403-5ac5-495e-86b5-0e60c397393b	message	uyuyhuhj	gghghghg	f	2025-12-15 14:38:42.607678	119441b6-93ba-441c-bb86-5880cf45f708	2025-12-22 14:38:42.563505+01	2025-12-15 14:38:42.607678
491	9b36ebb6-1b40-4fa5-8fad-736b04b5b4ea	message	uyuyhuhj	gghghghg	f	2025-12-15 14:38:42.607953	119441b6-93ba-441c-bb86-5880cf45f708	2025-12-22 14:38:42.563505+01	2025-12-15 14:38:42.607953
492	03613595-b764-4cb5-9d23-ebb2055a9fe1	message	uyuyhuhj	gghghghg	f	2025-12-15 14:38:42.60842	119441b6-93ba-441c-bb86-5880cf45f708	2025-12-22 14:38:42.563505+01	2025-12-15 14:38:42.60842
493	59775d98-8c8e-4a7b-99ed-11920c2bd80b	message	uyuyhuhj	gghghghg	f	2025-12-15 14:38:42.608719	119441b6-93ba-441c-bb86-5880cf45f708	2025-12-22 14:38:42.563505+01	2025-12-15 14:38:42.608719
494	b6ac4b5c-2caf-4bd6-83e9-ae3d7df27970	message	uyuyhuhj	gghghghg	f	2025-12-15 14:38:42.609427	119441b6-93ba-441c-bb86-5880cf45f708	2025-12-22 14:38:42.563505+01	2025-12-15 14:38:42.609427
495	5738ce10-3634-42f7-91d7-91f21cfb64f3	message	uyuyhuhj	gghghghg	f	2025-12-15 14:38:42.612118	119441b6-93ba-441c-bb86-5880cf45f708	2025-12-22 14:38:42.563505+01	2025-12-15 14:38:42.612118
496	a4f64b75-1bbe-4fb1-80d5-f441b6b9bee2	message	uyuyhuhj	gghghghg	f	2025-12-15 14:38:42.61276	119441b6-93ba-441c-bb86-5880cf45f708	2025-12-22 14:38:42.563505+01	2025-12-15 14:38:42.61276
498	9a2b27aa-e90a-4409-8373-2be363ee206e	message	uyuyhuhj	gghghghg	f	2025-12-15 14:38:42.613684	119441b6-93ba-441c-bb86-5880cf45f708	2025-12-22 14:38:42.563505+01	2025-12-15 14:38:42.613684
499	34d7356b-9cea-4a80-a7be-93d7def7d260	message	uyuyhuhj	gghghghg	f	2025-12-15 14:38:42.614279	119441b6-93ba-441c-bb86-5880cf45f708	2025-12-22 14:38:42.563505+01	2025-12-15 14:38:42.614279
500	489473cf-735a-4831-ac2a-f94ce58afca4	message	uyuyhuhj	gghghghg	f	2025-12-15 14:38:42.615325	119441b6-93ba-441c-bb86-5880cf45f708	2025-12-22 14:38:42.563505+01	2025-12-15 14:38:42.615325
501	412e9a12-7529-4bc7-85c7-f88df5e191d1	message	uyuyhuhj	gghghghg	f	2025-12-15 14:38:42.615763	119441b6-93ba-441c-bb86-5880cf45f708	2025-12-22 14:38:42.563505+01	2025-12-15 14:38:42.615763
502	c492c079-7db5-4261-9983-2492048902eb	message	uyuyhuhj	gghghghg	f	2025-12-15 14:38:42.616279	119441b6-93ba-441c-bb86-5880cf45f708	2025-12-22 14:38:42.563505+01	2025-12-15 14:38:42.616279
503	aecbb92c-bbe9-4a05-9dc2-a1f290e41deb	message	uyuyhuhj	gghghghg	f	2025-12-15 14:38:42.616757	119441b6-93ba-441c-bb86-5880cf45f708	2025-12-22 14:38:42.563505+01	2025-12-15 14:38:42.616757
504	fac4c4eb-47c1-4552-9e92-3f24ca63a922	message	uyuyhuhj	gghghghg	f	2025-12-15 14:38:42.617204	119441b6-93ba-441c-bb86-5880cf45f708	2025-12-22 14:38:42.563505+01	2025-12-15 14:38:42.617204
505	552e83ca-0eaa-4d94-87aa-9c4958aa811e	message	uyuyhuhj	gghghghg	f	2025-12-15 14:38:42.617616	119441b6-93ba-441c-bb86-5880cf45f708	2025-12-22 14:38:42.563505+01	2025-12-15 14:38:42.617616
506	544e6fb5-b91e-43be-89f6-90546a7f0669	message	uyuyhuhj	gghghghg	f	2025-12-15 14:38:42.618095	119441b6-93ba-441c-bb86-5880cf45f708	2025-12-22 14:38:42.563505+01	2025-12-15 14:38:42.618095
507	e001d25d-7ef8-44c7-8213-2777aa595970	message	uyuyhuhj	gghghghg	f	2025-12-15 14:38:42.618581	119441b6-93ba-441c-bb86-5880cf45f708	2025-12-22 14:38:42.563505+01	2025-12-15 14:38:42.618581
508	1d71f3e9-7f85-49b8-a65e-b9c819ad19cb	message	uyuyhuhj	gghghghg	f	2025-12-15 14:38:42.619039	119441b6-93ba-441c-bb86-5880cf45f708	2025-12-22 14:38:42.563505+01	2025-12-15 14:38:42.619039
509	1ebbf9f9-6184-4687-a5cf-a5b7c6d11717	message	uyuyhuhj	gghghghg	f	2025-12-15 14:38:42.619457	119441b6-93ba-441c-bb86-5880cf45f708	2025-12-22 14:38:42.563505+01	2025-12-15 14:38:42.619457
510	c848bf8a-43a8-4d05-94cc-9d5033405cd7	message	uyuyhuhj	gghghghg	f	2025-12-15 14:38:42.619943	119441b6-93ba-441c-bb86-5880cf45f708	2025-12-22 14:38:42.563505+01	2025-12-15 14:38:42.619943
511	0919939d-1f4b-485c-b66e-1c24d710930d	message	uyuyhuhj	gghghghg	f	2025-12-15 14:38:42.620327	119441b6-93ba-441c-bb86-5880cf45f708	2025-12-22 14:38:42.563505+01	2025-12-15 14:38:42.620327
512	8c59a07a-41dc-4d55-b55b-f82800569e9c	message	uyuyhuhj	gghghghg	f	2025-12-15 14:38:42.62069	119441b6-93ba-441c-bb86-5880cf45f708	2025-12-22 14:38:42.563505+01	2025-12-15 14:38:42.62069
513	6392ac81-e8b5-4b27-a2dc-b0a34a449659	message	uyuyhuhj	gghghghg	f	2025-12-15 14:38:42.621062	119441b6-93ba-441c-bb86-5880cf45f708	2025-12-22 14:38:42.563505+01	2025-12-15 14:38:42.621062
514	b45f33f6-4f98-4d00-af3d-6bae657c2deb	message	uyuyhuhj	gghghghg	f	2025-12-15 14:38:42.621577	119441b6-93ba-441c-bb86-5880cf45f708	2025-12-22 14:38:42.563505+01	2025-12-15 14:38:42.621577
515	1e193b09-87bc-48c4-b666-94f910cf5882	message	uyuyhuhj	gghghghg	f	2025-12-15 14:38:42.622073	119441b6-93ba-441c-bb86-5880cf45f708	2025-12-22 14:38:42.563505+01	2025-12-15 14:38:42.622073
516	cebe720e-d2f1-4b0e-9107-4da7b543fe4b	message	uyuyhuhj	gghghghg	f	2025-12-15 14:38:42.622428	119441b6-93ba-441c-bb86-5880cf45f708	2025-12-22 14:38:42.563505+01	2025-12-15 14:38:42.622428
517	1a6bdfd6-888d-44f7-8f49-eaa05b8af956	message	uyuyhuhj	gghghghg	f	2025-12-15 14:38:42.622763	119441b6-93ba-441c-bb86-5880cf45f708	2025-12-22 14:38:42.563505+01	2025-12-15 14:38:42.622763
518	5eebb1da-4f4a-4422-9d3b-406c89f80c89	message	uyuyhuhj	gghghghg	f	2025-12-15 14:38:42.623137	119441b6-93ba-441c-bb86-5880cf45f708	2025-12-22 14:38:42.563505+01	2025-12-15 14:38:42.623137
519	b5d7896a-9217-480e-b4ac-8343141a3333	message	Babs Pop is here	what should we give him?	f	2025-12-15 14:40:23.879981	ab66556f-de85-421b-a040-fdd31f561cff	2025-12-22 14:40:23.87814+01	2025-12-15 14:40:23.879981
520	8e57948f-983c-4db3-b517-a46b3d3531b3	message	Babs Pop is here	what should we give him?	f	2025-12-15 14:40:23.891471	ab66556f-de85-421b-a040-fdd31f561cff	2025-12-22 14:40:23.87814+01	2025-12-15 14:40:23.891471
521	e6bcd428-3711-4d17-80b4-5fab412563bd	message	Babs Pop is here	what should we give him?	f	2025-12-15 14:40:23.892118	ab66556f-de85-421b-a040-fdd31f561cff	2025-12-22 14:40:23.87814+01	2025-12-15 14:40:23.892118
522	97dabb21-c5cd-434c-8bff-ae86b3682018	message	Babs Pop is here	what should we give him?	f	2025-12-15 14:40:23.892626	ab66556f-de85-421b-a040-fdd31f561cff	2025-12-22 14:40:23.87814+01	2025-12-15 14:40:23.892626
523	23a2c030-e381-40b0-885f-efe8c6ccf388	message	Babs Pop is here	what should we give him?	f	2025-12-15 14:40:23.893261	ab66556f-de85-421b-a040-fdd31f561cff	2025-12-22 14:40:23.87814+01	2025-12-15 14:40:23.893261
524	f50c5c53-dd6a-4380-9d6f-1410b29a7fa4	message	Babs Pop is here	what should we give him?	f	2025-12-15 14:40:23.893791	ab66556f-de85-421b-a040-fdd31f561cff	2025-12-22 14:40:23.87814+01	2025-12-15 14:40:23.893791
525	3edac621-15bc-43a1-9a09-19231b503c80	message	Babs Pop is here	what should we give him?	f	2025-12-15 14:40:23.894521	ab66556f-de85-421b-a040-fdd31f561cff	2025-12-22 14:40:23.87814+01	2025-12-15 14:40:23.894521
526	8ddcb7e7-9941-46bb-866b-6aae3a217a5d	message	Babs Pop is here	what should we give him?	f	2025-12-15 14:40:23.894939	ab66556f-de85-421b-a040-fdd31f561cff	2025-12-22 14:40:23.87814+01	2025-12-15 14:40:23.894939
527	2b9793bf-f240-4cf8-a94a-c4b652f0ae0b	message	Babs Pop is here	what should we give him?	f	2025-12-15 14:40:23.895332	ab66556f-de85-421b-a040-fdd31f561cff	2025-12-22 14:40:23.87814+01	2025-12-15 14:40:23.895332
528	710974ab-52fc-4726-b50a-b309d5b7d9ba	message	Babs Pop is here	what should we give him?	f	2025-12-15 14:40:23.895752	ab66556f-de85-421b-a040-fdd31f561cff	2025-12-22 14:40:23.87814+01	2025-12-15 14:40:23.895752
529	9f68aa0f-c6c7-4b73-a4d9-d3225b88c2f0	message	Babs Pop is here	what should we give him?	f	2025-12-15 14:40:23.896187	ab66556f-de85-421b-a040-fdd31f561cff	2025-12-22 14:40:23.87814+01	2025-12-15 14:40:23.896187
530	805b6158-8b01-4f05-90f2-a0fcad495cb9	message	Babs Pop is here	what should we give him?	f	2025-12-15 14:40:23.896661	ab66556f-de85-421b-a040-fdd31f561cff	2025-12-22 14:40:23.87814+01	2025-12-15 14:40:23.896661
531	a7a5977d-c912-4476-b8c1-89d6a6dec0ee	message	Babs Pop is here	what should we give him?	f	2025-12-15 14:40:23.897172	ab66556f-de85-421b-a040-fdd31f561cff	2025-12-22 14:40:23.87814+01	2025-12-15 14:40:23.897172
532	085df28e-fb49-420c-bea9-0432c9199f40	message	Babs Pop is here	what should we give him?	f	2025-12-15 14:40:23.897602	ab66556f-de85-421b-a040-fdd31f561cff	2025-12-22 14:40:23.87814+01	2025-12-15 14:40:23.897602
533	d2e4dc25-672a-485e-98b8-0126b3f10d28	message	Babs Pop is here	what should we give him?	f	2025-12-15 14:40:23.897943	ab66556f-de85-421b-a040-fdd31f561cff	2025-12-22 14:40:23.87814+01	2025-12-15 14:40:23.897943
534	61bd6a53-cd0b-4af7-9166-c8385d448f8f	message	Babs Pop is here	what should we give him?	f	2025-12-15 14:40:23.898289	ab66556f-de85-421b-a040-fdd31f561cff	2025-12-22 14:40:23.87814+01	2025-12-15 14:40:23.898289
535	891bbc40-a563-4fab-9ca0-a0defd6abbe3	message	Babs Pop is here	what should we give him?	f	2025-12-15 14:40:23.898637	ab66556f-de85-421b-a040-fdd31f561cff	2025-12-22 14:40:23.87814+01	2025-12-15 14:40:23.898637
536	81e8d990-cba5-41df-8c92-f74cdbc3a71a	message	Babs Pop is here	what should we give him?	f	2025-12-15 14:40:23.899501	ab66556f-de85-421b-a040-fdd31f561cff	2025-12-22 14:40:23.87814+01	2025-12-15 14:40:23.899501
537	e116ad22-a5f7-4bcd-9577-8b5f9beeaf46	message	Babs Pop is here	what should we give him?	f	2025-12-15 14:40:23.899885	ab66556f-de85-421b-a040-fdd31f561cff	2025-12-22 14:40:23.87814+01	2025-12-15 14:40:23.899885
538	9b40e7c8-5dde-4b3b-8574-4cdb3453fc31	message	Babs Pop is here	what should we give him?	f	2025-12-15 14:40:23.900338	ab66556f-de85-421b-a040-fdd31f561cff	2025-12-22 14:40:23.87814+01	2025-12-15 14:40:23.900338
539	8f675035-cc06-4b4e-89b6-db4f7c123ed2	message	Babs Pop is here	what should we give him?	f	2025-12-15 14:40:23.900801	ab66556f-de85-421b-a040-fdd31f561cff	2025-12-22 14:40:23.87814+01	2025-12-15 14:40:23.900801
540	376e41c2-4a6e-4010-ba3d-24eb0c509ada	message	Babs Pop is here	what should we give him?	f	2025-12-15 14:40:23.901166	ab66556f-de85-421b-a040-fdd31f561cff	2025-12-22 14:40:23.87814+01	2025-12-15 14:40:23.901166
541	091177fc-3b2c-4858-8ea0-b8f7206b4636	message	Babs Pop is here	what should we give him?	f	2025-12-15 14:40:23.901522	ab66556f-de85-421b-a040-fdd31f561cff	2025-12-22 14:40:23.87814+01	2025-12-15 14:40:23.901522
542	7ef2acf4-d876-4a29-b1f0-db8301f817a6	message	Babs Pop is here	what should we give him?	f	2025-12-15 14:40:23.901863	ab66556f-de85-421b-a040-fdd31f561cff	2025-12-22 14:40:23.87814+01	2025-12-15 14:40:23.901863
543	7b63533f-02f3-4491-9808-64ad90a92334	message	Babs Pop is here	what should we give him?	f	2025-12-15 14:40:23.902257	ab66556f-de85-421b-a040-fdd31f561cff	2025-12-22 14:40:23.87814+01	2025-12-15 14:40:23.902257
544	d2940649-78f0-4418-88b4-7b16a9a7104f	message	Babs Pop is here	what should we give him?	f	2025-12-15 14:40:23.902811	ab66556f-de85-421b-a040-fdd31f561cff	2025-12-22 14:40:23.87814+01	2025-12-15 14:40:23.902811
545	a8f9ccad-6eef-45ea-b1d9-9b24ec7ab5a9	message	Babs Pop is here	what should we give him?	f	2025-12-15 14:40:23.903847	ab66556f-de85-421b-a040-fdd31f561cff	2025-12-22 14:40:23.87814+01	2025-12-15 14:40:23.903847
546	b4801419-3838-4ac9-9c94-b05568dbf2b1	message	Babs Pop is here	what should we give him?	f	2025-12-15 14:40:23.90451	ab66556f-de85-421b-a040-fdd31f561cff	2025-12-22 14:40:23.87814+01	2025-12-15 14:40:23.90451
547	1eab9750-4824-4de4-8168-04591fc249f7	message	Babs Pop is here	what should we give him?	f	2025-12-15 14:40:23.905197	ab66556f-de85-421b-a040-fdd31f561cff	2025-12-22 14:40:23.87814+01	2025-12-15 14:40:23.905197
548	6315b233-5988-421f-9cb9-95a8b68e00ce	message	Babs Pop is here	what should we give him?	f	2025-12-15 14:40:23.905698	ab66556f-de85-421b-a040-fdd31f561cff	2025-12-22 14:40:23.87814+01	2025-12-15 14:40:23.905698
549	ca9c9dd0-bfd0-4436-b804-cfa549e732db	message	Babs Pop is here	what should we give him?	f	2025-12-15 14:40:23.906177	ab66556f-de85-421b-a040-fdd31f561cff	2025-12-22 14:40:23.87814+01	2025-12-15 14:40:23.906177
550	f6702e7d-fe35-4bc2-b78b-5a04809e886c	message	Babs Pop is here	what should we give him?	f	2025-12-15 14:40:23.906841	ab66556f-de85-421b-a040-fdd31f561cff	2025-12-22 14:40:23.87814+01	2025-12-15 14:40:23.906841
551	fbd7dcb6-7dc8-478a-ba23-6fae56403e81	message	Babs Pop is here	what should we give him?	f	2025-12-15 14:40:23.907391	ab66556f-de85-421b-a040-fdd31f561cff	2025-12-22 14:40:23.87814+01	2025-12-15 14:40:23.907391
552	5f3fb9c6-b104-40cb-b27e-ce123ebd7fa6	message	Babs Pop is here	what should we give him?	f	2025-12-15 14:40:23.907764	ab66556f-de85-421b-a040-fdd31f561cff	2025-12-22 14:40:23.87814+01	2025-12-15 14:40:23.907764
553	f8642d75-f69a-487d-b385-661ecf2fc8fc	message	Babs Pop is here	what should we give him?	f	2025-12-15 14:40:23.908109	ab66556f-de85-421b-a040-fdd31f561cff	2025-12-22 14:40:23.87814+01	2025-12-15 14:40:23.908109
554	3b4d200d-8f2c-45c8-a3ae-2816d06f208c	message	Babs Pop is here	what should we give him?	f	2025-12-15 14:40:23.908439	ab66556f-de85-421b-a040-fdd31f561cff	2025-12-22 14:40:23.87814+01	2025-12-15 14:40:23.908439
555	a1ba9ca9-d129-47c4-b6ff-1d3a5fd1e27d	message	Babs Pop is here	what should we give him?	f	2025-12-15 14:40:23.908785	ab66556f-de85-421b-a040-fdd31f561cff	2025-12-22 14:40:23.87814+01	2025-12-15 14:40:23.908785
556	7af931a9-9b6d-464c-928a-56556aa73171	message	Babs Pop is here	what should we give him?	f	2025-12-15 14:40:23.90919	ab66556f-de85-421b-a040-fdd31f561cff	2025-12-22 14:40:23.87814+01	2025-12-15 14:40:23.90919
557	87e45cfe-99c0-46bf-8ea4-a53fb3c757b0	message	Babs Pop is here	what should we give him?	f	2025-12-15 14:40:23.909594	ab66556f-de85-421b-a040-fdd31f561cff	2025-12-22 14:40:23.87814+01	2025-12-15 14:40:23.909594
558	d1b4bda9-e6d2-4b36-a87b-63b34b14a47a	message	Babs Pop is here	what should we give him?	f	2025-12-15 14:40:23.909988	ab66556f-de85-421b-a040-fdd31f561cff	2025-12-22 14:40:23.87814+01	2025-12-15 14:40:23.909988
559	df4b5622-d10a-4be6-b3b9-ae9eb365621f	message	Babs Pop is here	what should we give him?	f	2025-12-15 14:40:23.910422	ab66556f-de85-421b-a040-fdd31f561cff	2025-12-22 14:40:23.87814+01	2025-12-15 14:40:23.910422
560	89dbb74e-de3b-4d24-981c-7638797c1e36	message	Babs Pop is here	what should we give him?	f	2025-12-15 14:40:23.910817	ab66556f-de85-421b-a040-fdd31f561cff	2025-12-22 14:40:23.87814+01	2025-12-15 14:40:23.910817
561	c7733a6f-9d5d-4d39-a724-f85c9d24d139	message	Babs Pop is here	what should we give him?	f	2025-12-15 14:40:23.911162	ab66556f-de85-421b-a040-fdd31f561cff	2025-12-22 14:40:23.87814+01	2025-12-15 14:40:23.911162
562	f4d0a02a-8a68-4eb2-af6e-e4f055c356c1	message	Babs Pop is here	what should we give him?	f	2025-12-15 14:40:23.911518	ab66556f-de85-421b-a040-fdd31f561cff	2025-12-22 14:40:23.87814+01	2025-12-15 14:40:23.911518
563	822a2fa1-b223-4057-aabc-82e54feea196	message	Babs Pop is here	what should we give him?	f	2025-12-15 14:40:23.911891	ab66556f-de85-421b-a040-fdd31f561cff	2025-12-22 14:40:23.87814+01	2025-12-15 14:40:23.911891
564	409f5414-a30a-4090-84cc-73f477407968	message	Babs Pop is here	what should we give him?	f	2025-12-15 14:40:23.91227	ab66556f-de85-421b-a040-fdd31f561cff	2025-12-22 14:40:23.87814+01	2025-12-15 14:40:23.91227
565	0ccaa979-7837-46cf-9514-826710479042	message	Babs Pop is here	what should we give him?	f	2025-12-15 14:40:23.912692	ab66556f-de85-421b-a040-fdd31f561cff	2025-12-22 14:40:23.87814+01	2025-12-15 14:40:23.912692
566	41e8c3cb-f9a4-4f2e-a473-d47e060e89d3	message	Babs Pop is here	what should we give him?	f	2025-12-15 14:40:23.913121	ab66556f-de85-421b-a040-fdd31f561cff	2025-12-22 14:40:23.87814+01	2025-12-15 14:40:23.913121
567	a4b3302a-4c26-4b9e-9205-c726f5b548f0	message	Babs Pop is here	what should we give him?	f	2025-12-15 14:40:23.913899	ab66556f-de85-421b-a040-fdd31f561cff	2025-12-22 14:40:23.87814+01	2025-12-15 14:40:23.913899
568	64c22400-eb47-46b1-93fb-11110d7121f1	message	Babs Pop is here	what should we give him?	f	2025-12-15 14:40:23.914378	ab66556f-de85-421b-a040-fdd31f561cff	2025-12-22 14:40:23.87814+01	2025-12-15 14:40:23.914378
569	9d401424-6da4-4e9a-8568-00174cd56050	message	Babs Pop is here	what should we give him?	f	2025-12-15 14:40:23.914781	ab66556f-de85-421b-a040-fdd31f561cff	2025-12-22 14:40:23.87814+01	2025-12-15 14:40:23.914781
570	f1361a2d-c534-4cfd-81a0-796ed17b4339	message	Babs Pop is here	what should we give him?	f	2025-12-15 14:40:23.915193	ab66556f-de85-421b-a040-fdd31f561cff	2025-12-22 14:40:23.87814+01	2025-12-15 14:40:23.915193
571	00feec4b-e498-452b-b081-cf480e16aec2	message	Babs Pop is here	what should we give him?	f	2025-12-15 14:40:23.915579	ab66556f-de85-421b-a040-fdd31f561cff	2025-12-22 14:40:23.87814+01	2025-12-15 14:40:23.915579
572	02762b1e-9b2f-4bfe-943c-d6c28827ef96	message	Babs Pop is here	what should we give him?	f	2025-12-15 14:40:23.915984	ab66556f-de85-421b-a040-fdd31f561cff	2025-12-22 14:40:23.87814+01	2025-12-15 14:40:23.915984
573	86407ed7-40bf-4420-9053-f64c6121188e	message	Babs Pop is here	what should we give him?	f	2025-12-15 14:40:23.91637	ab66556f-de85-421b-a040-fdd31f561cff	2025-12-22 14:40:23.87814+01	2025-12-15 14:40:23.91637
574	22d26f27-6768-43ec-b08e-4b20b924b76f	message	Babs Pop is here	what should we give him?	f	2025-12-15 14:40:23.91679	ab66556f-de85-421b-a040-fdd31f561cff	2025-12-22 14:40:23.87814+01	2025-12-15 14:40:23.91679
575	c2b365e0-5404-4d85-b9e1-515e0cd9afe9	message	Babs Pop is here	what should we give him?	f	2025-12-15 14:40:23.917167	ab66556f-de85-421b-a040-fdd31f561cff	2025-12-22 14:40:23.87814+01	2025-12-15 14:40:23.917167
576	aefab581-f8c3-42a0-b79a-55d0270f3d00	message	Babs Pop is here	what should we give him?	f	2025-12-15 14:40:23.917605	ab66556f-de85-421b-a040-fdd31f561cff	2025-12-22 14:40:23.87814+01	2025-12-15 14:40:23.917605
577	5be8065b-44d4-4fab-aa82-b64bda2b368a	message	Babs Pop is here	what should we give him?	f	2025-12-15 14:40:23.918081	ab66556f-de85-421b-a040-fdd31f561cff	2025-12-22 14:40:23.87814+01	2025-12-15 14:40:23.918081
578	d9df9370-0442-4365-9ed0-3b59afc81ec1	message	Babs Pop is here	what should we give him?	f	2025-12-15 14:40:23.918452	ab66556f-de85-421b-a040-fdd31f561cff	2025-12-22 14:40:23.87814+01	2025-12-15 14:40:23.918452
579	9c77950e-3ebc-4846-aed1-2faae86cbb37	message	Babs Pop is here	what should we give him?	f	2025-12-15 14:40:23.918782	ab66556f-de85-421b-a040-fdd31f561cff	2025-12-22 14:40:23.87814+01	2025-12-15 14:40:23.918782
580	66024a16-884c-408e-bead-dd134927a58a	message	Babs Pop is here	what should we give him?	f	2025-12-15 14:40:23.919111	ab66556f-de85-421b-a040-fdd31f561cff	2025-12-22 14:40:23.87814+01	2025-12-15 14:40:23.919111
581	c6fa2131-7fea-459e-9df8-2ff37f1a39bb	message	Babs Pop is here	what should we give him?	f	2025-12-15 14:40:23.919625	ab66556f-de85-421b-a040-fdd31f561cff	2025-12-22 14:40:23.87814+01	2025-12-15 14:40:23.919625
582	694655b7-cfa9-418e-9f29-1753df0adbfd	message	Babs Pop is here	what should we give him?	f	2025-12-15 14:40:23.920553	ab66556f-de85-421b-a040-fdd31f561cff	2025-12-22 14:40:23.87814+01	2025-12-15 14:40:23.920553
583	c84d7da8-2f5e-4123-85c5-989ba74e3520	message	Babs Pop is here	what should we give him?	f	2025-12-15 14:40:23.921246	ab66556f-de85-421b-a040-fdd31f561cff	2025-12-22 14:40:23.87814+01	2025-12-15 14:40:23.921246
584	c58f03b5-12e4-45c5-b71d-21ffeb6b0c40	message	Babs Pop is here	what should we give him?	f	2025-12-15 14:40:23.921573	ab66556f-de85-421b-a040-fdd31f561cff	2025-12-22 14:40:23.87814+01	2025-12-15 14:40:23.921573
585	905773e4-02be-4a57-9046-7bd29db1fa03	message	Babs Pop is here	what should we give him?	f	2025-12-15 14:40:23.921789	ab66556f-de85-421b-a040-fdd31f561cff	2025-12-22 14:40:23.87814+01	2025-12-15 14:40:23.921789
586	243a4471-81e9-469e-ae44-7685b225e07b	message	Babs Pop is here	what should we give him?	f	2025-12-15 14:40:23.922029	ab66556f-de85-421b-a040-fdd31f561cff	2025-12-22 14:40:23.87814+01	2025-12-15 14:40:23.922029
587	afb04864-9ab2-4994-918c-397a2a035d84	message	Babs Pop is here	what should we give him?	f	2025-12-15 14:40:23.922263	ab66556f-de85-421b-a040-fdd31f561cff	2025-12-22 14:40:23.87814+01	2025-12-15 14:40:23.922263
588	5c39ac09-558d-4836-9bb6-f1de81d58f9d	message	Babs Pop is here	what should we give him?	f	2025-12-15 14:40:23.922623	ab66556f-de85-421b-a040-fdd31f561cff	2025-12-22 14:40:23.87814+01	2025-12-15 14:40:23.922623
589	3f324c9c-7c0d-4dbc-8c49-cd943f36fc27	message	Babs Pop is here	what should we give him?	f	2025-12-15 14:40:23.922853	ab66556f-de85-421b-a040-fdd31f561cff	2025-12-22 14:40:23.87814+01	2025-12-15 14:40:23.922853
590	2a643039-c6a0-4791-b022-07b0fbfddd3a	message	Babs Pop is here	what should we give him?	f	2025-12-15 14:40:23.923215	ab66556f-de85-421b-a040-fdd31f561cff	2025-12-22 14:40:23.87814+01	2025-12-15 14:40:23.923215
591	020e710e-e419-4c74-9848-3b00770353c6	message	Babs Pop is here	what should we give him?	f	2025-12-15 14:40:23.923554	ab66556f-de85-421b-a040-fdd31f561cff	2025-12-22 14:40:23.87814+01	2025-12-15 14:40:23.923554
592	f4d858f5-58b1-4727-96d5-5b27be00ebbe	message	Babs Pop is here	what should we give him?	f	2025-12-15 14:40:23.923826	ab66556f-de85-421b-a040-fdd31f561cff	2025-12-22 14:40:23.87814+01	2025-12-15 14:40:23.923826
593	1ca1e403-5ac5-495e-86b5-0e60c397393b	message	Babs Pop is here	what should we give him?	f	2025-12-15 14:40:23.924166	ab66556f-de85-421b-a040-fdd31f561cff	2025-12-22 14:40:23.87814+01	2025-12-15 14:40:23.924166
594	9b36ebb6-1b40-4fa5-8fad-736b04b5b4ea	message	Babs Pop is here	what should we give him?	f	2025-12-15 14:40:23.924579	ab66556f-de85-421b-a040-fdd31f561cff	2025-12-22 14:40:23.87814+01	2025-12-15 14:40:23.924579
595	03613595-b764-4cb5-9d23-ebb2055a9fe1	message	Babs Pop is here	what should we give him?	f	2025-12-15 14:40:23.924866	ab66556f-de85-421b-a040-fdd31f561cff	2025-12-22 14:40:23.87814+01	2025-12-15 14:40:23.924866
596	59775d98-8c8e-4a7b-99ed-11920c2bd80b	message	Babs Pop is here	what should we give him?	f	2025-12-15 14:40:23.925125	ab66556f-de85-421b-a040-fdd31f561cff	2025-12-22 14:40:23.87814+01	2025-12-15 14:40:23.925125
597	b6ac4b5c-2caf-4bd6-83e9-ae3d7df27970	message	Babs Pop is here	what should we give him?	f	2025-12-15 14:40:23.925405	ab66556f-de85-421b-a040-fdd31f561cff	2025-12-22 14:40:23.87814+01	2025-12-15 14:40:23.925405
598	5738ce10-3634-42f7-91d7-91f21cfb64f3	message	Babs Pop is here	what should we give him?	f	2025-12-15 14:40:23.925669	ab66556f-de85-421b-a040-fdd31f561cff	2025-12-22 14:40:23.87814+01	2025-12-15 14:40:23.925669
599	a4f64b75-1bbe-4fb1-80d5-f441b6b9bee2	message	Babs Pop is here	what should we give him?	f	2025-12-15 14:40:23.926065	ab66556f-de85-421b-a040-fdd31f561cff	2025-12-22 14:40:23.87814+01	2025-12-15 14:40:23.926065
601	9a2b27aa-e90a-4409-8373-2be363ee206e	message	Babs Pop is here	what should we give him?	f	2025-12-15 14:40:23.926526	ab66556f-de85-421b-a040-fdd31f561cff	2025-12-22 14:40:23.87814+01	2025-12-15 14:40:23.926526
602	34d7356b-9cea-4a80-a7be-93d7def7d260	message	Babs Pop is here	what should we give him?	f	2025-12-15 14:40:23.926764	ab66556f-de85-421b-a040-fdd31f561cff	2025-12-22 14:40:23.87814+01	2025-12-15 14:40:23.926764
603	489473cf-735a-4831-ac2a-f94ce58afca4	message	Babs Pop is here	what should we give him?	f	2025-12-15 14:40:23.927011	ab66556f-de85-421b-a040-fdd31f561cff	2025-12-22 14:40:23.87814+01	2025-12-15 14:40:23.927011
604	412e9a12-7529-4bc7-85c7-f88df5e191d1	message	Babs Pop is here	what should we give him?	f	2025-12-15 14:40:23.927261	ab66556f-de85-421b-a040-fdd31f561cff	2025-12-22 14:40:23.87814+01	2025-12-15 14:40:23.927261
605	c492c079-7db5-4261-9983-2492048902eb	message	Babs Pop is here	what should we give him?	f	2025-12-15 14:40:23.927495	ab66556f-de85-421b-a040-fdd31f561cff	2025-12-22 14:40:23.87814+01	2025-12-15 14:40:23.927495
606	aecbb92c-bbe9-4a05-9dc2-a1f290e41deb	message	Babs Pop is here	what should we give him?	f	2025-12-15 14:40:23.927717	ab66556f-de85-421b-a040-fdd31f561cff	2025-12-22 14:40:23.87814+01	2025-12-15 14:40:23.927717
607	fac4c4eb-47c1-4552-9e92-3f24ca63a922	message	Babs Pop is here	what should we give him?	f	2025-12-15 14:40:23.927901	ab66556f-de85-421b-a040-fdd31f561cff	2025-12-22 14:40:23.87814+01	2025-12-15 14:40:23.927901
608	552e83ca-0eaa-4d94-87aa-9c4958aa811e	message	Babs Pop is here	what should we give him?	f	2025-12-15 14:40:23.92816	ab66556f-de85-421b-a040-fdd31f561cff	2025-12-22 14:40:23.87814+01	2025-12-15 14:40:23.92816
609	544e6fb5-b91e-43be-89f6-90546a7f0669	message	Babs Pop is here	what should we give him?	f	2025-12-15 14:40:23.928379	ab66556f-de85-421b-a040-fdd31f561cff	2025-12-22 14:40:23.87814+01	2025-12-15 14:40:23.928379
610	e001d25d-7ef8-44c7-8213-2777aa595970	message	Babs Pop is here	what should we give him?	f	2025-12-15 14:40:23.928775	ab66556f-de85-421b-a040-fdd31f561cff	2025-12-22 14:40:23.87814+01	2025-12-15 14:40:23.928775
611	1d71f3e9-7f85-49b8-a65e-b9c819ad19cb	message	Babs Pop is here	what should we give him?	f	2025-12-15 14:40:23.929011	ab66556f-de85-421b-a040-fdd31f561cff	2025-12-22 14:40:23.87814+01	2025-12-15 14:40:23.929011
612	1ebbf9f9-6184-4687-a5cf-a5b7c6d11717	message	Babs Pop is here	what should we give him?	f	2025-12-15 14:40:23.929232	ab66556f-de85-421b-a040-fdd31f561cff	2025-12-22 14:40:23.87814+01	2025-12-15 14:40:23.929232
613	c848bf8a-43a8-4d05-94cc-9d5033405cd7	message	Babs Pop is here	what should we give him?	f	2025-12-15 14:40:23.929472	ab66556f-de85-421b-a040-fdd31f561cff	2025-12-22 14:40:23.87814+01	2025-12-15 14:40:23.929472
614	0919939d-1f4b-485c-b66e-1c24d710930d	message	Babs Pop is here	what should we give him?	f	2025-12-15 14:40:23.929686	ab66556f-de85-421b-a040-fdd31f561cff	2025-12-22 14:40:23.87814+01	2025-12-15 14:40:23.929686
615	8c59a07a-41dc-4d55-b55b-f82800569e9c	message	Babs Pop is here	what should we give him?	f	2025-12-15 14:40:23.929901	ab66556f-de85-421b-a040-fdd31f561cff	2025-12-22 14:40:23.87814+01	2025-12-15 14:40:23.929901
616	6392ac81-e8b5-4b27-a2dc-b0a34a449659	message	Babs Pop is here	what should we give him?	f	2025-12-15 14:40:23.930075	ab66556f-de85-421b-a040-fdd31f561cff	2025-12-22 14:40:23.87814+01	2025-12-15 14:40:23.930075
617	b45f33f6-4f98-4d00-af3d-6bae657c2deb	message	Babs Pop is here	what should we give him?	f	2025-12-15 14:40:23.93033	ab66556f-de85-421b-a040-fdd31f561cff	2025-12-22 14:40:23.87814+01	2025-12-15 14:40:23.93033
618	1e193b09-87bc-48c4-b666-94f910cf5882	message	Babs Pop is here	what should we give him?	f	2025-12-15 14:40:23.930595	ab66556f-de85-421b-a040-fdd31f561cff	2025-12-22 14:40:23.87814+01	2025-12-15 14:40:23.930595
619	cebe720e-d2f1-4b0e-9107-4da7b543fe4b	message	Babs Pop is here	what should we give him?	f	2025-12-15 14:40:23.930861	ab66556f-de85-421b-a040-fdd31f561cff	2025-12-22 14:40:23.87814+01	2025-12-15 14:40:23.930861
620	1a6bdfd6-888d-44f7-8f49-eaa05b8af956	message	Babs Pop is here	what should we give him?	f	2025-12-15 14:40:23.93115	ab66556f-de85-421b-a040-fdd31f561cff	2025-12-22 14:40:23.87814+01	2025-12-15 14:40:23.93115
621	5eebb1da-4f4a-4422-9d3b-406c89f80c89	message	Babs Pop is here	what should we give him?	f	2025-12-15 14:40:23.931466	ab66556f-de85-421b-a040-fdd31f561cff	2025-12-22 14:40:23.87814+01	2025-12-15 14:40:23.931466
85	8ecec133-b13f-4d69-91f0-21ac9f930ca6	message	Test Message	This is a test message	t	2025-12-15 14:14:45.489096	272025de-4cde-4c41-a7d0-425556269e82	2025-12-22 14:14:45.428864+01	2025-12-15 14:44:10.605137
600	8ecec133-b13f-4d69-91f0-21ac9f930ca6	message	Babs Pop is here	what should we give him?	t	2025-12-15 14:40:23.926308	ab66556f-de85-421b-a040-fdd31f561cff	2025-12-22 14:40:23.87814+01	2025-12-15 14:44:31.948186
188	8ecec133-b13f-4d69-91f0-21ac9f930ca6	message	Hello	say hiiii	t	2025-12-15 14:21:45.665126	9de49003-6a71-4f8a-b7ce-002c97ae9449	2025-12-22 14:21:45.59271+01	2025-12-15 14:44:46.032422
291	8ecec133-b13f-4d69-91f0-21ac9f930ca6	message	Hello	say hiiii	t	2025-12-15 14:31:55.111629	56bd55d8-f8fe-49f8-b7eb-0cac7d581639	2025-12-22 14:31:55.041771+01	2025-12-15 14:44:46.032422
394	8ecec133-b13f-4d69-91f0-21ac9f930ca6	message	uyuyhuhj	gghghghg	t	2025-12-15 14:37:28.297272	c878a3dd-f365-40e2-aea9-b58f96c6891f	2025-12-22 14:37:28.234088+01	2025-12-15 14:44:46.032422
497	8ecec133-b13f-4d69-91f0-21ac9f930ca6	message	uyuyhuhj	gghghghg	t	2025-12-15 14:38:42.613186	119441b6-93ba-441c-bb86-5880cf45f708	2025-12-22 14:38:42.563505+01	2025-12-15 14:44:46.032422
56	a04f5bc7-2636-4358-aae3-dc3e1c9968e3	message	Test Message	This is a test message	t	2025-12-15 14:14:45.475783	272025de-4cde-4c41-a7d0-425556269e82	2025-12-22 14:14:45.428864+01	2025-12-15 22:05:35.644104
159	a04f5bc7-2636-4358-aae3-dc3e1c9968e3	message	Hello	say hiiii	t	2025-12-15 14:21:45.652858	9de49003-6a71-4f8a-b7ce-002c97ae9449	2025-12-22 14:21:45.59271+01	2025-12-15 22:05:37.414255
\.


--
-- Data for Name: password_reset_otps; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.password_reset_otps (id, email, otp, expires_at, used, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: promotion_history; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.promotion_history (id, user_id, previous_role_id, new_role_id, previous_salary, new_salary, previous_branch_id, new_branch_id, previous_department_id, new_department_id, promotion_date, promoted_by, reason, created_at) FROM stdin;
2	e6bcd428-3711-4d17-80b4-5fab412563bd	d4de53c5-3099-4cd3-88fa-758c04ef083f	ba813f53-f592-435d-ba88-d2df338f46b1	120000.00	1000000.00	\N	\N	\N	\N	2025-12-13	a04f5bc7-2636-4358-aae3-dc3e1c9968e3		2025-12-13 23:32:19.021042
3	5eebb1da-4f4a-4422-9d3b-406c89f80c89	20b9e282-3ed8-4297-92ed-aef0391fcd76	a30980e5-2d73-4423-889f-a7e1f2610004	100000.00	1000000.00	\N	\N	\N	\N	2025-12-15	f1361a2d-c534-4cfd-81a0-796ed17b4339	Loren ipsum	2025-12-15 10:15:05.716629
\.


--
-- Data for Name: roles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.roles (id, name, category, department_id, sub_department_id, description, is_active, created_at, updated_at) FROM stdin;
d5d2d106-7491-4c14-8bcf-f0e7b9713feb	HR Administrator	senior_admin	\N	\N	Human Resources Administrator with full system access	t	2025-11-15 16:59:02.616291	2025-11-15 16:59:02.616291
e92cb940-73d7-4a0d-8a75-13c53f4f25f5	Chief Executive Officer	senior_admin	\N	\N	CEO - Top executive officer overseeing all operations	t	2025-11-15 21:21:16.150774	2025-11-15 21:21:16.150774
6bcae336-343e-4b29-8934-738e7f238e0a	Chief Operating Officer	senior_admin	\N	\N	COO - Oversees daily operations across all branches	t	2025-11-15 21:21:16.150774	2025-11-15 21:21:16.150774
ccf26bf4-6062-499f-8329-3ddf4ce9bfa3	Human Resource	senior_admin	\N	\N	HR - Manages all staff recruitment, profiles, and HR functions	t	2025-11-15 21:21:16.150774	2025-11-15 21:21:16.150774
2b3c0f9b-60a2-49d0-9220-5c5675d22710	Auditor	senior_admin	\N	\N	Internal auditor for financial and operational compliance	t	2025-11-15 21:21:16.150774	2025-11-15 21:21:16.150774
9395fcff-0e5e-4317-8e8e-10cea570c44c	Operations Manager (SuperMarket)	admin	160511a1-5b4f-4af9-bdc7-1764adbe6142	\N	Oversees daily operations in SuperMarket	t	2025-11-15 21:21:16.263621	2025-11-15 21:21:16.263621
a976fd8e-0279-4e66-9bec-5abed6853c0e	Admin Officer (SuperMarket)	admin	160511a1-5b4f-4af9-bdc7-1764adbe6142	\N	Administrative support for SuperMarket	t	2025-11-15 21:21:16.263621	2025-11-15 21:21:16.263621
ba813f53-f592-435d-ba88-d2df338f46b1	Floor Manager (SuperMarket)	admin	160511a1-5b4f-4af9-bdc7-1764adbe6142	\N	Manages floor staff and creates rosters for SuperMarket	t	2025-11-15 21:21:16.263621	2025-11-15 21:21:16.263621
d4de53c5-3099-4cd3-88fa-758c04ef083f	Cashier (SuperMarket)	general	160511a1-5b4f-4af9-bdc7-1764adbe6142	\N	Handles customer transactions	t	2025-11-15 21:21:16.263621	2025-11-15 21:21:16.263621
b7e50dac-a86f-49a8-8b34-2c06859cfaca	Baker (SuperMarket)	general	160511a1-5b4f-4af9-bdc7-1764adbe6142	\N	Prepares baked goods	t	2025-11-15 21:21:16.263621	2025-11-15 21:21:16.263621
de90cca0-5317-479d-a773-64073676d800	Customer Service Relations (SuperMarket)	general	160511a1-5b4f-4af9-bdc7-1764adbe6142	\N	Handles customer inquiries and support	t	2025-11-15 21:21:16.263621	2025-11-15 21:21:16.263621
d6f97f97-db9b-4576-b099-dd56ab50b8bd	Supervisor (Eatery)	admin	4a2add3f-a2e1-4834-af93-a64c2397e933	\N	Supervises Eatery staff and operations	t	2025-11-15 21:21:16.263621	2025-11-15 21:21:16.263621
b8f6bb4e-f084-43a8-9887-a4fefa86eb8d	Store Manager (Eatery)	admin	4a2add3f-a2e1-4834-af93-a64c2397e933	\N	Manages Eatery store inventory and supplies	t	2025-11-15 21:21:16.263621	2025-11-15 21:21:16.263621
119faa1c-3d2c-47ec-b7be-0387974af414	Floor Manager (Eatery)	admin	4a2add3f-a2e1-4834-af93-a64c2397e933	\N	Manages floor staff and creates rosters for Eatery	t	2025-11-15 21:21:16.263621	2025-11-15 21:21:16.263621
2f982603-80c6-435f-ad88-bb26e9acbbfa	Cashier (Eatery)	general	4a2add3f-a2e1-4834-af93-a64c2397e933	\N	Handles customer transactions	t	2025-11-15 21:21:16.263621	2025-11-15 21:21:16.263621
62dbcc34-26fd-432a-b7a7-715b93109d53	Baker (Eatery)	general	4a2add3f-a2e1-4834-af93-a64c2397e933	\N	Prepares baked goods	t	2025-11-15 21:21:16.263621	2025-11-15 21:21:16.263621
bfbeec8a-edbf-46d1-8309-e2a37738b57a	Cook (Eatery)	general	4a2add3f-a2e1-4834-af93-a64c2397e933	\N	Prepares meals and dishes	t	2025-11-15 21:21:16.263621	2025-11-15 21:21:16.263621
891ae93e-4f1a-4420-923c-f63a607dea15	Lobby Staff (Eatery)	general	4a2add3f-a2e1-4834-af93-a64c2397e933	\N	Manages lobby area and customer seating	t	2025-11-15 21:21:16.263621	2025-11-15 21:21:16.263621
89576c0b-fdc1-427c-bbcc-3e2aa4a47937	Kitchen Assistant (Eatery)	general	4a2add3f-a2e1-4834-af93-a64c2397e933	\N	Assists in kitchen operations	t	2025-11-15 21:21:16.263621	2025-11-15 21:21:16.263621
8ac63a8d-31d6-40ac-9cba-ec2716dffa9e	Operations Manager (Lounge)	admin	3be6b055-b126-4fdf-88a8-152634a678ea	\N	Oversees daily operations in Lounge	t	2025-11-15 21:21:16.263621	2025-11-15 21:21:16.263621
f6f2c90b-ba4f-4fea-acd3-452a9107b06d	Supervisor (Lounge)	admin	3be6b055-b126-4fdf-88a8-152634a678ea	\N	Supervises Lounge staff and operations	t	2025-11-15 21:21:16.263621	2025-11-15 21:21:16.263621
bc694f45-bb32-4b4e-8ac3-9773e6d7fbb9	Floor Manager (Lounge)	admin	3be6b055-b126-4fdf-88a8-152634a678ea	\N	Manages floor staff and creates rosters for Lounge	t	2025-11-15 21:21:16.263621	2025-11-15 21:21:16.263621
153dc698-430b-4717-82da-374fcfa5b6b5	Cashier (Lounge)	general	3be6b055-b126-4fdf-88a8-152634a678ea	\N	Handles customer transactions	t	2025-11-15 21:21:16.263621	2025-11-15 21:21:16.263621
2df74045-45bb-4507-a5d4-689efb2a1772	Cook (Lounge)	general	3be6b055-b126-4fdf-88a8-152634a678ea	\N	Prepares meals and dishes	t	2025-11-15 21:21:16.263621	2025-11-15 21:21:16.263621
9b6c1ed7-7041-4305-9620-f1011fa5c361	Bartender (Lounge)	general	3be6b055-b126-4fdf-88a8-152634a678ea	\N	Prepares and serves drinks	t	2025-11-15 21:21:16.263621	2025-11-15 21:21:16.263621
20b9e282-3ed8-4297-92ed-aef0391fcd76	Waitress (Lounge)	general	3be6b055-b126-4fdf-88a8-152634a678ea	\N	Serves customers and takes orders	t	2025-11-15 21:21:16.263621	2025-11-15 21:21:16.263621
de6c57d4-0d97-4c7a-9416-69644b1c9a46	DJ (Lounge)	general	3be6b055-b126-4fdf-88a8-152634a678ea	\N	Provides music and entertainment	t	2025-11-15 21:21:16.263621	2025-11-15 21:21:16.263621
451aebee-6d1f-4cd1-9ac1-8cfda37e8abb	Hypeman (Lounge)	general	3be6b055-b126-4fdf-88a8-152634a678ea	\N	Engages and entertains guests	t	2025-11-15 21:21:16.263621	2025-11-15 21:21:16.263621
71206ff6-4c7e-4e1b-a291-a672fbbb13c7	Manager (Cinema)	admin	04368807-3180-43b1-927e-eab61dfb4a5b	a97dd1ad-8b9a-4070-af57-57a2f029d017	Manages Cinema operations	t	2025-11-15 21:21:16.263621	2025-11-15 21:21:16.263621
6c38eff1-8e55-4a02-9a05-248d57c26cdf	Cinema Staff	general	04368807-3180-43b1-927e-eab61dfb4a5b	a97dd1ad-8b9a-4070-af57-57a2f029d017	General cinema operations staff	t	2025-11-15 21:21:16.263621	2025-11-15 21:21:16.263621
a9a8981e-85ee-4257-9f51-aa811061a988	Manager (Photo Studio)	admin	04368807-3180-43b1-927e-eab61dfb4a5b	f79e4638-4c31-484d-a400-771567a430cf	Manages Photo Studio operations	t	2025-11-15 21:21:16.263621	2025-11-15 21:21:16.263621
38c295cd-2db1-4419-bb76-e603674fb694	Photographer	general	04368807-3180-43b1-927e-eab61dfb4a5b	f79e4638-4c31-484d-a400-771567a430cf	Professional photographer	t	2025-11-15 21:21:16.263621	2025-11-15 21:21:16.263621
8e7ac234-0c2f-4500-a386-5670c4225ef8	Studio Staff	general	04368807-3180-43b1-927e-eab61dfb4a5b	f79e4638-4c31-484d-a400-771567a430cf	General photo studio support staff	t	2025-11-15 21:21:16.263621	2025-11-15 21:21:16.263621
1e4366db-e4f0-47e2-a2e2-70c8547ee483	Manager (Saloon)	admin	04368807-3180-43b1-927e-eab61dfb4a5b	c3d4b97f-40e0-4f7a-a935-c45d6602ab1a	Manages Saloon operations	t	2025-11-15 21:21:16.263621	2025-11-15 21:21:16.263621
1ee9125a-fceb-4ec6-b752-8a6c29637123	Hair Stylist	general	04368807-3180-43b1-927e-eab61dfb4a5b	c3d4b97f-40e0-4f7a-a935-c45d6602ab1a	Professional hair stylist	t	2025-11-15 21:21:16.263621	2025-11-15 21:21:16.263621
0d9bdaf1-3662-431d-9425-04e466fa46fb	Barber	general	04368807-3180-43b1-927e-eab61dfb4a5b	c3d4b97f-40e0-4f7a-a935-c45d6602ab1a	Professional barber	t	2025-11-15 21:21:16.263621	2025-11-15 21:21:16.263621
c09723fa-9305-4d5a-97ee-5816b8e2a804	Saloon Staff	general	04368807-3180-43b1-927e-eab61dfb4a5b	c3d4b97f-40e0-4f7a-a935-c45d6602ab1a	General saloon support staff	t	2025-11-15 21:21:16.263621	2025-11-15 21:21:16.263621
d3d91c1f-2351-425c-a59e-d9d1e8924382	Manager (Arcade & Kiddies Park)	admin	04368807-3180-43b1-927e-eab61dfb4a5b	324201e5-d41a-4082-9006-eab2e15f95b5	Manages Arcade and Kiddies Park operations	t	2025-11-15 21:21:16.263621	2025-11-15 21:21:16.263621
a0fc7e97-4fc6-4fcd-a394-121e2ac5e1c9	Gamer	general	04368807-3180-43b1-927e-eab61dfb4a5b	324201e5-d41a-4082-9006-eab2e15f95b5	Arcade game operator and assistant	t	2025-11-15 21:21:16.263621	2025-11-15 21:21:16.263621
49ef7510-7c1c-4eb4-998a-bd86f744a6a3	Arcade Staff	general	04368807-3180-43b1-927e-eab61dfb4a5b	324201e5-d41a-4082-9006-eab2e15f95b5	General arcade support staff	t	2025-11-15 21:21:16.263621	2025-11-15 21:21:16.263621
4aff4bf4-bd45-4b82-90bd-7d34245b43ed	Manager (Casino)	admin	04368807-3180-43b1-927e-eab61dfb4a5b	83100a44-ccde-4cda-a0e7-eee3ec08142c	Manages Casino operations	t	2025-11-15 21:21:16.263621	2025-11-15 21:21:16.263621
3e190f0d-c39e-4655-ab43-ae6cdb5cf65e	Casino Staff	general	04368807-3180-43b1-927e-eab61dfb4a5b	83100a44-ccde-4cda-a0e7-eee3ec08142c	General casino operations staff	t	2025-11-15 21:21:16.263621	2025-11-15 21:21:16.263621
b27462f2-e6a1-44ed-931b-a828aa16de3b	Compliance Officer 1	admin	d904023b-1163-46a7-94ae-cd6890690416	\N	Senior compliance officer	t	2025-11-15 21:21:16.263621	2025-11-15 21:21:16.263621
6c0631da-dced-45b9-ae65-e539e25802ed	Branch Manager	admin	160511a1-5b4f-4af9-bdc7-1764adbe6142	\N	Manages SuperMarket operations at branch level	t	2025-11-15 21:21:16.263621	2025-11-15 21:21:16.263621
a30980e5-2d73-4423-889f-a7e1f2610004	Assistant Compliance Officer	admin	d904023b-1163-46a7-94ae-cd6890690416	\N	Assistant to compliance officer	t	2025-11-15 21:21:16.263621	2025-11-15 21:21:16.263621
83a773db-ed1e-4774-89cb-f7ac0b4438b3	Facility Manager 1	admin	acff245a-4a57-47c5-ab5d-8da6f19d449b	\N	Senior facility manager	t	2025-11-15 21:21:16.263621	2025-11-15 21:21:16.263621
c97a9a69-b3e7-45a8-b77c-d206d02e6696	Facility Manager 2	admin	acff245a-4a57-47c5-ab5d-8da6f19d449b	\N	Secondary facility manager	t	2025-11-15 21:21:16.263621	2025-11-15 21:21:16.263621
cbd88037-bd76-417d-a685-d24ce61e49b7	Security	general	acff245a-4a57-47c5-ab5d-8da6f19d449b	\N	Security personnel	t	2025-11-15 21:21:16.263621	2025-11-15 21:21:16.263621
8e3dcba3-d2a8-405c-b703-86cf8c75ce0e	Cleaner	general	acff245a-4a57-47c5-ab5d-8da6f19d449b	\N	Cleaning and maintenance staff	t	2025-11-15 21:21:16.263621	2025-11-15 21:21:16.263621
41d4f439-b727-4c73-ac9c-c02c7b11b679	Group Head (SuperMarket)	senior_admin	160511a1-5b4f-4af9-bdc7-1764adbe6142	\N	Heads SuperMarket department across all 13 branches	t	2025-11-15 21:21:16.263621	2025-11-15 21:21:16.263621
0929beff-3146-46cc-ba9e-54fe427c0bdb	Group Head (Eatery)	senior_admin	4a2add3f-a2e1-4834-af93-a64c2397e933	\N	Heads Eatery department across all 13 branches	t	2025-11-15 21:21:16.263621	2025-11-15 21:21:16.263621
9ae5dc92-1f89-43cb-896f-9fcc2fe2ab35	Group Head (Lounge)	senior_admin	3be6b055-b126-4fdf-88a8-152634a678ea	\N	Heads Lounge department across all 13 branches	t	2025-11-15 21:21:16.263621	2025-11-15 21:21:16.263621
0baf6193-e074-4e50-85c1-58ef76fd4658	Group Head (Fun & Arcade)	senior_admin	04368807-3180-43b1-927e-eab61dfb4a5b	\N	Heads Fun & Arcade department across all 13 branches	t	2025-11-15 21:21:16.263621	2025-11-15 21:21:16.263621
b7873738-a182-48bb-b8b8-c492f70aae43	Group Head (Compliance)	senior_admin	d904023b-1163-46a7-94ae-cd6890690416	\N	Heads Compliance department across all 13 branches	t	2025-11-15 21:21:16.263621	2025-11-15 21:21:16.263621
927ec215-9fe0-45af-af7c-2c85219def0d	Group Head (Facility Management)	senior_admin	acff245a-4a57-47c5-ab5d-8da6f19d449b	\N	Heads Facility Management across all 13 branches	t	2025-11-15 21:21:16.263621	2025-11-15 21:21:16.263621
\.


--
-- Data for Name: roster_assignments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.roster_assignments (id, roster_id, staff_id, day_of_week, shift_type, start_time, end_time, notes, created_at) FROM stdin;
05365e77-b437-43c2-8e2e-4c681cf93542	a66820f4-0e3a-43b0-a866-c38d38e005b3	710974ab-52fc-4726-b50a-b309d5b7d9ba	monday	day	07:00:00	15:00:00		2025-12-11 13:37:16.750214
8844a76f-0dd1-4d33-963b-d1a038f5e06b	a66820f4-0e3a-43b0-a866-c38d38e005b3	710974ab-52fc-4726-b50a-b309d5b7d9ba	tuesday	afternoon	15:00:00	23:00:00		2025-12-11 13:37:16.750214
b200baab-7436-43e4-a10f-110812e5b0ae	a66820f4-0e3a-43b0-a866-c38d38e005b3	710974ab-52fc-4726-b50a-b309d5b7d9ba	wednesday	afternoon	15:00:00	23:00:00		2025-12-11 13:37:16.750214
0f614d5e-06f0-4dac-8ffc-888e89cf72cb	a66820f4-0e3a-43b0-a866-c38d38e005b3	710974ab-52fc-4726-b50a-b309d5b7d9ba	thursday	afternoon	15:00:00	23:00:00		2025-12-11 13:37:16.750214
c7cec08d-bdf8-444f-b4b1-0cfc9c1c5a66	a66820f4-0e3a-43b0-a866-c38d38e005b3	710974ab-52fc-4726-b50a-b309d5b7d9ba	friday	day	07:00:00	15:00:00		2025-12-11 13:37:16.750214
e48dc594-493a-4878-ba11-48b42e999ea9	a66820f4-0e3a-43b0-a866-c38d38e005b3	710974ab-52fc-4726-b50a-b309d5b7d9ba	saturday	night	23:00:00	07:00:00		2025-12-11 13:37:16.750214
4db23e23-ffad-4425-a3c3-73e47ed057a1	a66820f4-0e3a-43b0-a866-c38d38e005b3	5eebb1da-4f4a-4422-9d3b-406c89f80c89	thursday	day	07:00:00	15:00:00		2025-12-11 13:37:16.750214
\.


--
-- Data for Name: rosters; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.rosters (id, floor_manager_id, department_id, branch_id, week_start_date, week_end_date, status, created_at, updated_at) FROM stdin;
a66820f4-0e3a-43b0-a866-c38d38e005b3	710974ab-52fc-4726-b50a-b309d5b7d9ba	3be6b055-b126-4fdf-88a8-152634a678ea	511a5f95-209d-4b8d-b795-990079b07e1e	2025-12-08	2025-12-14	published	2025-12-11 13:37:16.750214	2025-12-11 13:37:16.750214
0d103be0-a615-477b-9cec-faf7a4a6e3eb	e6bcd428-3711-4d17-80b4-5fab412563bd	160511a1-5b4f-4af9-bdc7-1764adbe6142	8b67a276-81d1-4950-88ee-47b7077c0bf2	2024-12-02	2024-12-08	published	2025-12-13 23:53:48.791817	2025-12-13 23:53:48.791817
0b5611c3-1613-4cce-85a1-a2f487b5cd3a	a7a5977d-c912-4476-b8c1-89d6a6dec0ee	160511a1-5b4f-4af9-bdc7-1764adbe6142	511a5f95-209d-4b8d-b795-990079b07e1e	2024-12-02	2024-12-08	published	2025-12-13 23:53:48.791817	2025-12-13 23:53:48.791817
a5d18015-e011-460f-9b7b-012914f94b1a	085df28e-fb49-420c-bea9-0432c9199f40	3be6b055-b126-4fdf-88a8-152634a678ea	8b67a276-81d1-4950-88ee-47b7077c0bf2	2024-12-02	2024-12-08	published	2025-12-13 23:53:48.791817	2025-12-13 23:53:48.791817
bdc25178-96c8-4f3e-9a42-5e07a2703f6d	d2e4dc25-672a-485e-98b8-0126b3f10d28	160511a1-5b4f-4af9-bdc7-1764adbe6142	8b67a276-81d1-4950-88ee-47b7077c0bf2	2024-12-02	2024-12-08	published	2025-12-13 23:53:48.791817	2025-12-13 23:53:48.791817
5e6a473b-9196-4256-bc95-893699d3fa96	81e8d990-cba5-41df-8c92-f74cdbc3a71a	3be6b055-b126-4fdf-88a8-152634a678ea	38f86af3-14b1-4fe4-a84f-d895e840b1d1	2024-12-02	2024-12-08	published	2025-12-13 23:53:48.791817	2025-12-13 23:53:48.791817
b030e74a-fd69-4f88-a444-d1ed310733c4	710974ab-52fc-4726-b50a-b309d5b7d9ba	3be6b055-b126-4fdf-88a8-152634a678ea	511a5f95-209d-4b8d-b795-990079b07e1e	2024-12-02	2024-12-08	published	2025-12-13 23:53:48.791817	2025-12-13 23:53:48.791817
0df7356b-facc-4f60-9a72-47d84bce413c	091177fc-3b2c-4858-8ea0-b8f7206b4636	160511a1-5b4f-4af9-bdc7-1764adbe6142	38f86af3-14b1-4fe4-a84f-d895e840b1d1	2024-12-02	2024-12-08	published	2025-12-13 23:53:48.791817	2025-12-13 23:53:48.791817
f5c09c8a-1b84-4983-974c-7ab2d44384a1	7ef2acf4-d876-4a29-b1f0-db8301f817a6	3be6b055-b126-4fdf-88a8-152634a678ea	70777e0c-f350-4f3b-9013-5e8691a96d8c	2024-12-02	2024-12-08	published	2025-12-13 23:53:48.791817	2025-12-13 23:53:48.791817
b2844bf4-dde0-41d9-b9cd-397fbb54114c	7b63533f-02f3-4491-9808-64ad90a92334	160511a1-5b4f-4af9-bdc7-1764adbe6142	70777e0c-f350-4f3b-9013-5e8691a96d8c	2024-12-02	2024-12-08	published	2025-12-13 23:53:48.791817	2025-12-13 23:53:48.791817
69b6743e-64ba-4981-8679-31f65abdfa66	d2940649-78f0-4418-88b4-7b16a9a7104f	3be6b055-b126-4fdf-88a8-152634a678ea	9d23f80a-749e-4d59-a26d-85e16a388846	2024-12-02	2024-12-08	published	2025-12-13 23:53:48.791817	2025-12-13 23:53:48.791817
6bbcb759-ff8b-4cff-992e-629fcf5aad96	a8f9ccad-6eef-45ea-b1d9-9b24ec7ab5a9	160511a1-5b4f-4af9-bdc7-1764adbe6142	9d23f80a-749e-4d59-a26d-85e16a388846	2024-12-02	2024-12-08	published	2025-12-13 23:53:48.791817	2025-12-13 23:53:48.791817
db8febb2-94c0-4b52-acd2-5cee56522b22	b4801419-3838-4ac9-9c94-b05568dbf2b1	3be6b055-b126-4fdf-88a8-152634a678ea	1bc5af13-0b28-422e-bf26-df270e0a4089	2024-12-02	2024-12-08	published	2025-12-13 23:53:48.791817	2025-12-13 23:53:48.791817
4018bb9d-7bab-42f6-8461-25ef628a4a61	1eab9750-4824-4de4-8168-04591fc249f7	160511a1-5b4f-4af9-bdc7-1764adbe6142	1bc5af13-0b28-422e-bf26-df270e0a4089	2024-12-02	2024-12-08	published	2025-12-13 23:53:48.791817	2025-12-13 23:53:48.791817
45dcc87e-5562-4a9c-a010-c10f3dd020e8	6315b233-5988-421f-9cb9-95a8b68e00ce	3be6b055-b126-4fdf-88a8-152634a678ea	ff3a7fa2-ee3e-484c-ac9b-548b6b9a6eda	2024-12-02	2024-12-08	published	2025-12-13 23:53:48.791817	2025-12-13 23:53:48.791817
1683342e-ad8d-4ea3-a85b-c9fefbacf43a	f8642d75-f69a-487d-b385-661ecf2fc8fc	160511a1-5b4f-4af9-bdc7-1764adbe6142	ff3a7fa2-ee3e-484c-ac9b-548b6b9a6eda	2024-12-02	2024-12-08	published	2025-12-13 23:53:48.791817	2025-12-13 23:53:48.791817
b03db807-07d5-4eed-9e20-3fe3131f6208	3b4d200d-8f2c-45c8-a3ae-2816d06f208c	3be6b055-b126-4fdf-88a8-152634a678ea	001a6790-0f59-4776-aee9-cb1928290ec9	2024-12-02	2024-12-08	published	2025-12-13 23:53:48.791817	2025-12-13 23:53:48.791817
ea9ae414-f6ff-4a46-bd62-958938c77365	a1ba9ca9-d129-47c4-b6ff-1d3a5fd1e27d	160511a1-5b4f-4af9-bdc7-1764adbe6142	001a6790-0f59-4776-aee9-cb1928290ec9	2024-12-02	2024-12-08	published	2025-12-13 23:53:48.791817	2025-12-13 23:53:48.791817
574d27c8-227b-4bde-aea4-6c00883d08d8	7af931a9-9b6d-464c-928a-56556aa73171	3be6b055-b126-4fdf-88a8-152634a678ea	d735da13-cff9-4009-a6dd-4ad59fc9f72b	2024-12-02	2024-12-08	published	2025-12-13 23:53:48.791817	2025-12-13 23:53:48.791817
f776e1b8-f2e6-4242-b709-e7ec2e381e59	87e45cfe-99c0-46bf-8ea4-a53fb3c757b0	160511a1-5b4f-4af9-bdc7-1764adbe6142	d735da13-cff9-4009-a6dd-4ad59fc9f72b	2024-12-02	2024-12-08	published	2025-12-13 23:53:48.791817	2025-12-13 23:53:48.791817
6c5423be-ff56-494e-be1b-679b3a277e96	d1b4bda9-e6d2-4b36-a87b-63b34b14a47a	3be6b055-b126-4fdf-88a8-152634a678ea	2af15e5d-b67a-493f-8357-feaec629a69a	2024-12-02	2024-12-08	published	2025-12-13 23:53:48.791817	2025-12-13 23:53:48.791817
c09fc5e5-3ec4-4ab8-9c67-c26e37dd54d7	df4b5622-d10a-4be6-b3b9-ae9eb365621f	160511a1-5b4f-4af9-bdc7-1764adbe6142	2af15e5d-b67a-493f-8357-feaec629a69a	2024-12-02	2024-12-08	published	2025-12-13 23:53:48.791817	2025-12-13 23:53:48.791817
1c9956da-8727-4ed7-b482-94034cbb97af	e6bcd428-3711-4d17-80b4-5fab412563bd	160511a1-5b4f-4af9-bdc7-1764adbe6142	8b67a276-81d1-4950-88ee-47b7077c0bf2	2024-12-09	2024-12-15	published	2025-12-13 23:53:48.813976	2025-12-13 23:53:48.813976
618dd883-e5fc-4685-a691-af9b45510637	a7a5977d-c912-4476-b8c1-89d6a6dec0ee	160511a1-5b4f-4af9-bdc7-1764adbe6142	511a5f95-209d-4b8d-b795-990079b07e1e	2024-12-09	2024-12-15	published	2025-12-13 23:53:48.813976	2025-12-13 23:53:48.813976
5515c02b-8817-4b1b-aa89-bf719893a5f3	085df28e-fb49-420c-bea9-0432c9199f40	3be6b055-b126-4fdf-88a8-152634a678ea	8b67a276-81d1-4950-88ee-47b7077c0bf2	2024-12-09	2024-12-15	published	2025-12-13 23:53:48.813976	2025-12-13 23:53:48.813976
7d560dfd-6d50-4dd0-abe9-5e47af0f17f2	d2e4dc25-672a-485e-98b8-0126b3f10d28	160511a1-5b4f-4af9-bdc7-1764adbe6142	8b67a276-81d1-4950-88ee-47b7077c0bf2	2024-12-09	2024-12-15	published	2025-12-13 23:53:48.813976	2025-12-13 23:53:48.813976
10a9f309-1b83-469a-a85a-b43838dcdd8f	81e8d990-cba5-41df-8c92-f74cdbc3a71a	3be6b055-b126-4fdf-88a8-152634a678ea	38f86af3-14b1-4fe4-a84f-d895e840b1d1	2024-12-09	2024-12-15	published	2025-12-13 23:53:48.813976	2025-12-13 23:53:48.813976
7abc3b74-87b5-4e57-beb6-bb389c229b2a	710974ab-52fc-4726-b50a-b309d5b7d9ba	3be6b055-b126-4fdf-88a8-152634a678ea	511a5f95-209d-4b8d-b795-990079b07e1e	2024-12-09	2024-12-15	published	2025-12-13 23:53:48.813976	2025-12-13 23:53:48.813976
7ea93e00-0680-450c-9ed2-d33d2dd13aba	091177fc-3b2c-4858-8ea0-b8f7206b4636	160511a1-5b4f-4af9-bdc7-1764adbe6142	38f86af3-14b1-4fe4-a84f-d895e840b1d1	2024-12-09	2024-12-15	published	2025-12-13 23:53:48.813976	2025-12-13 23:53:48.813976
66a75e3b-01f3-41fc-8374-42c3b9ce5989	7ef2acf4-d876-4a29-b1f0-db8301f817a6	3be6b055-b126-4fdf-88a8-152634a678ea	70777e0c-f350-4f3b-9013-5e8691a96d8c	2024-12-09	2024-12-15	published	2025-12-13 23:53:48.813976	2025-12-13 23:53:48.813976
ccbb7f65-cff3-4ce8-b026-f4309069475b	7b63533f-02f3-4491-9808-64ad90a92334	160511a1-5b4f-4af9-bdc7-1764adbe6142	70777e0c-f350-4f3b-9013-5e8691a96d8c	2024-12-09	2024-12-15	published	2025-12-13 23:53:48.813976	2025-12-13 23:53:48.813976
5ca73f9f-a11e-4faf-b0d8-3f831ff0b5da	d2940649-78f0-4418-88b4-7b16a9a7104f	3be6b055-b126-4fdf-88a8-152634a678ea	9d23f80a-749e-4d59-a26d-85e16a388846	2024-12-09	2024-12-15	published	2025-12-13 23:53:48.813976	2025-12-13 23:53:48.813976
be14ad15-fd4b-4592-b5f5-3690c406443a	a8f9ccad-6eef-45ea-b1d9-9b24ec7ab5a9	160511a1-5b4f-4af9-bdc7-1764adbe6142	9d23f80a-749e-4d59-a26d-85e16a388846	2024-12-09	2024-12-15	published	2025-12-13 23:53:48.813976	2025-12-13 23:53:48.813976
53a8f9dc-7011-4a22-a048-1fa99257d9c9	b4801419-3838-4ac9-9c94-b05568dbf2b1	3be6b055-b126-4fdf-88a8-152634a678ea	1bc5af13-0b28-422e-bf26-df270e0a4089	2024-12-09	2024-12-15	published	2025-12-13 23:53:48.813976	2025-12-13 23:53:48.813976
068271dc-c63c-4fb4-97c6-fd773f14eceb	1eab9750-4824-4de4-8168-04591fc249f7	160511a1-5b4f-4af9-bdc7-1764adbe6142	1bc5af13-0b28-422e-bf26-df270e0a4089	2024-12-09	2024-12-15	published	2025-12-13 23:53:48.813976	2025-12-13 23:53:48.813976
01c94005-2122-47dc-9e13-b5f33ea50b11	6315b233-5988-421f-9cb9-95a8b68e00ce	3be6b055-b126-4fdf-88a8-152634a678ea	ff3a7fa2-ee3e-484c-ac9b-548b6b9a6eda	2024-12-09	2024-12-15	published	2025-12-13 23:53:48.813976	2025-12-13 23:53:48.813976
ff16ab1b-1226-4547-a6bd-28a860ef113f	f8642d75-f69a-487d-b385-661ecf2fc8fc	160511a1-5b4f-4af9-bdc7-1764adbe6142	ff3a7fa2-ee3e-484c-ac9b-548b6b9a6eda	2024-12-09	2024-12-15	published	2025-12-13 23:53:48.813976	2025-12-13 23:53:48.813976
2beec205-dfb1-4225-9e70-620dbf80ea17	3b4d200d-8f2c-45c8-a3ae-2816d06f208c	3be6b055-b126-4fdf-88a8-152634a678ea	001a6790-0f59-4776-aee9-cb1928290ec9	2024-12-09	2024-12-15	published	2025-12-13 23:53:48.813976	2025-12-13 23:53:48.813976
6ca9e643-77d4-41b1-bb61-ea151689f375	a1ba9ca9-d129-47c4-b6ff-1d3a5fd1e27d	160511a1-5b4f-4af9-bdc7-1764adbe6142	001a6790-0f59-4776-aee9-cb1928290ec9	2024-12-09	2024-12-15	published	2025-12-13 23:53:48.813976	2025-12-13 23:53:48.813976
77fee872-1eab-45df-ba38-d7d06ae1d9a2	7af931a9-9b6d-464c-928a-56556aa73171	3be6b055-b126-4fdf-88a8-152634a678ea	d735da13-cff9-4009-a6dd-4ad59fc9f72b	2024-12-09	2024-12-15	published	2025-12-13 23:53:48.813976	2025-12-13 23:53:48.813976
e526ea0d-b956-4835-b8e8-87035549cef1	87e45cfe-99c0-46bf-8ea4-a53fb3c757b0	160511a1-5b4f-4af9-bdc7-1764adbe6142	d735da13-cff9-4009-a6dd-4ad59fc9f72b	2024-12-09	2024-12-15	published	2025-12-13 23:53:48.813976	2025-12-13 23:53:48.813976
0e28305c-0b6e-45cf-a858-bbd1560357a8	d1b4bda9-e6d2-4b36-a87b-63b34b14a47a	3be6b055-b126-4fdf-88a8-152634a678ea	2af15e5d-b67a-493f-8357-feaec629a69a	2024-12-09	2024-12-15	published	2025-12-13 23:53:48.813976	2025-12-13 23:53:48.813976
3b8acbba-3f62-4eb7-9338-88eb2797ea2c	df4b5622-d10a-4be6-b3b9-ae9eb365621f	160511a1-5b4f-4af9-bdc7-1764adbe6142	2af15e5d-b67a-493f-8357-feaec629a69a	2024-12-09	2024-12-15	published	2025-12-13 23:53:48.813976	2025-12-13 23:53:48.813976
\.


--
-- Data for Name: shift_templates; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.shift_templates (id, floor_manager_id, shift_type, start_time, end_time, is_default, created_at, updated_at) FROM stdin;
b3ad1d80-3411-41c7-9d02-161db0c6f616	710974ab-52fc-4726-b50a-b309d5b7d9ba	day	08:00:00	16:00:00	t	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474
4fae3d85-3529-456e-86e2-a544a4db2bbd	a7a5977d-c912-4476-b8c1-89d6a6dec0ee	day	08:00:00	16:00:00	t	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474
9adb82f6-ddcc-4e83-8873-a4a868a436a1	085df28e-fb49-420c-bea9-0432c9199f40	day	08:00:00	16:00:00	t	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474
d79cbb37-fb43-46a3-8ff9-f96ebda6695c	d2e4dc25-672a-485e-98b8-0126b3f10d28	day	08:00:00	16:00:00	t	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474
8db5da3d-037c-4bbb-b669-a4eb5607c96a	81e8d990-cba5-41df-8c92-f74cdbc3a71a	day	08:00:00	16:00:00	t	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474
9a075bf5-20fc-4eed-b814-51f063b7df76	091177fc-3b2c-4858-8ea0-b8f7206b4636	day	08:00:00	16:00:00	t	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474
6a34f5c0-70d0-4fc4-97c0-31bae94c3177	7ef2acf4-d876-4a29-b1f0-db8301f817a6	day	08:00:00	16:00:00	t	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474
24555961-ac68-4b67-a601-e87b9f714e85	7b63533f-02f3-4491-9808-64ad90a92334	day	08:00:00	16:00:00	t	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474
8a823e03-ad03-4e10-989d-3635a745828f	d2940649-78f0-4418-88b4-7b16a9a7104f	day	08:00:00	16:00:00	t	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474
691645a8-1d3d-49d1-84b4-fc67dad2fc0d	a8f9ccad-6eef-45ea-b1d9-9b24ec7ab5a9	day	08:00:00	16:00:00	t	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474
e0d58eda-7fa6-4b77-a75b-7f334405f735	b4801419-3838-4ac9-9c94-b05568dbf2b1	day	08:00:00	16:00:00	t	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474
0c12a7ca-3eec-4022-9aed-0be1b5a1ebc3	1eab9750-4824-4de4-8168-04591fc249f7	day	08:00:00	16:00:00	t	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474
23de63de-1500-4481-ad53-c26f41b6a93e	6315b233-5988-421f-9cb9-95a8b68e00ce	day	08:00:00	16:00:00	t	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474
bfaa26f9-74ba-46b6-8bc2-64dfbb00d74b	f8642d75-f69a-487d-b385-661ecf2fc8fc	day	08:00:00	16:00:00	t	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474
5a888952-d613-4714-94fb-35db3ba50619	3b4d200d-8f2c-45c8-a3ae-2816d06f208c	day	08:00:00	16:00:00	t	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474
d3c90186-b7a8-4678-a287-112837e1cf99	a1ba9ca9-d129-47c4-b6ff-1d3a5fd1e27d	day	08:00:00	16:00:00	t	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474
fbfd2808-9b12-40d9-9541-8d24d0570025	7af931a9-9b6d-464c-928a-56556aa73171	day	08:00:00	16:00:00	t	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474
4fa7da14-c490-4892-a8ad-45a2fa58fb61	87e45cfe-99c0-46bf-8ea4-a53fb3c757b0	day	08:00:00	16:00:00	t	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474
09f6be9d-ddb5-4275-a573-3bd39f3c3c46	d1b4bda9-e6d2-4b36-a87b-63b34b14a47a	day	08:00:00	16:00:00	t	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474
1d5709e4-f334-46b4-a5b0-9cc88f91ed75	df4b5622-d10a-4be6-b3b9-ae9eb365621f	day	08:00:00	16:00:00	t	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474
43be768c-698c-4b81-a73d-8842d81736ba	710974ab-52fc-4726-b50a-b309d5b7d9ba	afternoon	14:00:00	22:00:00	t	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474
7efc1461-0fc4-4956-a58c-8f4a223bbfdd	a7a5977d-c912-4476-b8c1-89d6a6dec0ee	afternoon	14:00:00	22:00:00	t	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474
f3ce921a-e194-48e2-b8b9-e8a6023a742c	085df28e-fb49-420c-bea9-0432c9199f40	afternoon	14:00:00	22:00:00	t	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474
d08048f9-fb9c-40eb-958d-cd7479394ed9	d2e4dc25-672a-485e-98b8-0126b3f10d28	afternoon	14:00:00	22:00:00	t	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474
7833a9fb-8b0d-4fd6-8f28-b312e7287f7d	81e8d990-cba5-41df-8c92-f74cdbc3a71a	afternoon	14:00:00	22:00:00	t	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474
7b23a768-7e02-4c65-b728-e6a02994d830	091177fc-3b2c-4858-8ea0-b8f7206b4636	afternoon	14:00:00	22:00:00	t	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474
7c6262b6-fbe4-4e1e-bba3-59e7b9365c51	7ef2acf4-d876-4a29-b1f0-db8301f817a6	afternoon	14:00:00	22:00:00	t	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474
d0e2d577-bc10-4e5a-afd0-673d9153e01b	7b63533f-02f3-4491-9808-64ad90a92334	afternoon	14:00:00	22:00:00	t	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474
e04a93ad-5014-47ad-ae6c-038111493d8f	d2940649-78f0-4418-88b4-7b16a9a7104f	afternoon	14:00:00	22:00:00	t	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474
a36130f5-940e-432d-8cd9-c9d8dc4f3e33	a8f9ccad-6eef-45ea-b1d9-9b24ec7ab5a9	afternoon	14:00:00	22:00:00	t	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474
41b96095-13ce-40d9-b20b-7755da3c4a7d	b4801419-3838-4ac9-9c94-b05568dbf2b1	afternoon	14:00:00	22:00:00	t	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474
98f78092-c8f6-444f-92d7-58f0f44599e7	1eab9750-4824-4de4-8168-04591fc249f7	afternoon	14:00:00	22:00:00	t	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474
fc2c1a67-d65c-4f2b-9804-01a1bfaa7070	6315b233-5988-421f-9cb9-95a8b68e00ce	afternoon	14:00:00	22:00:00	t	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474
6534ba31-9ba0-43b4-8718-7938f08ee68f	f8642d75-f69a-487d-b385-661ecf2fc8fc	afternoon	14:00:00	22:00:00	t	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474
0bac29b7-276b-4107-adac-c1021cd814f0	3b4d200d-8f2c-45c8-a3ae-2816d06f208c	afternoon	14:00:00	22:00:00	t	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474
8c9635cf-a69e-4120-b6e9-de6b5f32aacd	a1ba9ca9-d129-47c4-b6ff-1d3a5fd1e27d	afternoon	14:00:00	22:00:00	t	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474
94a5d1a9-1285-476b-9785-c76706cfb0ff	7af931a9-9b6d-464c-928a-56556aa73171	afternoon	14:00:00	22:00:00	t	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474
d1af819f-ef99-43da-bd96-c751d85a6de3	87e45cfe-99c0-46bf-8ea4-a53fb3c757b0	afternoon	14:00:00	22:00:00	t	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474
65f319a0-b2b6-4262-b213-d1ab99820e68	d1b4bda9-e6d2-4b36-a87b-63b34b14a47a	afternoon	14:00:00	22:00:00	t	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474
0fa1fd11-30e4-419e-9617-365bfaa077f4	df4b5622-d10a-4be6-b3b9-ae9eb365621f	afternoon	14:00:00	22:00:00	t	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474
ce12ae1d-7b3a-457f-af7c-a4e81da233d0	710974ab-52fc-4726-b50a-b309d5b7d9ba	night	22:00:00	06:00:00	t	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474
fbb8e420-2567-4117-961c-af26958bf88c	a7a5977d-c912-4476-b8c1-89d6a6dec0ee	night	22:00:00	06:00:00	t	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474
39995b9f-abca-4b52-9714-8c7b69b562cc	085df28e-fb49-420c-bea9-0432c9199f40	night	22:00:00	06:00:00	t	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474
8570769f-b46d-4611-a3c5-4dadbf170b2c	d2e4dc25-672a-485e-98b8-0126b3f10d28	night	22:00:00	06:00:00	t	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474
340f4e37-faca-4285-9144-fde7856fce3d	81e8d990-cba5-41df-8c92-f74cdbc3a71a	night	22:00:00	06:00:00	t	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474
be1ec57c-ea1a-46ff-8e4f-5ae2c509de1d	091177fc-3b2c-4858-8ea0-b8f7206b4636	night	22:00:00	06:00:00	t	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474
d1dd27fb-1f1f-4a3a-a5d0-d308f90b6a06	7ef2acf4-d876-4a29-b1f0-db8301f817a6	night	22:00:00	06:00:00	t	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474
536dbe40-cbaa-402a-ae6a-ccf6a63caa64	7b63533f-02f3-4491-9808-64ad90a92334	night	22:00:00	06:00:00	t	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474
2f202a96-e2ec-4dca-89c0-9cf2cde52a3b	d2940649-78f0-4418-88b4-7b16a9a7104f	night	22:00:00	06:00:00	t	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474
10ee5834-4d61-46c8-adc2-e3d11f2cc262	a8f9ccad-6eef-45ea-b1d9-9b24ec7ab5a9	night	22:00:00	06:00:00	t	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474
f804ac56-e183-4808-9d88-cd95bc8276e6	b4801419-3838-4ac9-9c94-b05568dbf2b1	night	22:00:00	06:00:00	t	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474
d372171b-962c-40fb-bdd5-2a15a23aab77	1eab9750-4824-4de4-8168-04591fc249f7	night	22:00:00	06:00:00	t	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474
c45eaa6f-3ba1-47fe-bbda-80fbbac0c413	6315b233-5988-421f-9cb9-95a8b68e00ce	night	22:00:00	06:00:00	t	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474
f3193ad6-221e-4ca0-83e0-07c2d42f2544	f8642d75-f69a-487d-b385-661ecf2fc8fc	night	22:00:00	06:00:00	t	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474
9ad45539-83e2-4753-8411-6e8ffbc4431a	3b4d200d-8f2c-45c8-a3ae-2816d06f208c	night	22:00:00	06:00:00	t	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474
a2e8edf2-54f4-469b-bdbb-12e1128fa72f	a1ba9ca9-d129-47c4-b6ff-1d3a5fd1e27d	night	22:00:00	06:00:00	t	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474
a0c7ccf7-cad6-4f18-ab5a-1e35b9110ea8	7af931a9-9b6d-464c-928a-56556aa73171	night	22:00:00	06:00:00	t	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474
d7bc2cec-c290-40ad-aa69-8c95c01b65b8	87e45cfe-99c0-46bf-8ea4-a53fb3c757b0	night	22:00:00	06:00:00	t	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474
0183df92-46eb-4fac-a326-2655e418a215	d1b4bda9-e6d2-4b36-a87b-63b34b14a47a	night	22:00:00	06:00:00	t	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474
73fe0e36-0744-4dc4-ab5a-6f2180d360e7	df4b5622-d10a-4be6-b3b9-ae9eb365621f	night	22:00:00	06:00:00	t	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474
c9d3aaae-ba0d-4a45-9f59-df4ceae4e43b	89dbb74e-de3b-4d24-981c-7638797c1e36	day	08:00:00	16:00:00	t	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474
58c4d048-f4f4-4975-83dd-4c27bb252945	fbd7dcb6-7dc8-478a-ba23-6fae56403e81	day	08:00:00	16:00:00	t	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474
9468dbc9-5d40-4fc4-8c9e-32687164572d	c7733a6f-9d5d-4d39-a724-f85c9d24d139	day	08:00:00	16:00:00	t	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474
e38b329f-2794-4b33-8aea-495bbcd51dd0	f4d0a02a-8a68-4eb2-af6e-e4f055c356c1	day	08:00:00	16:00:00	t	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474
335556c6-a5b5-45de-a1bd-202b19041c26	822a2fa1-b223-4057-aabc-82e54feea196	day	08:00:00	16:00:00	t	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474
30ac7a82-ac92-490e-83ff-4e339e29ba25	409f5414-a30a-4090-84cc-73f477407968	day	08:00:00	16:00:00	t	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474
7ec4184c-4cf6-4170-ba12-51d5da95c1b5	5f3fb9c6-b104-40cb-b27e-ce123ebd7fa6	day	08:00:00	16:00:00	t	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474
10f63f3d-0a6b-4667-bf29-13c7ad0a00b4	0ccaa979-7837-46cf-9514-826710479042	day	08:00:00	16:00:00	t	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474
74f5e153-3067-4136-b54a-de0045964855	41e8c3cb-f9a4-4f2e-a473-d47e060e89d3	day	08:00:00	16:00:00	t	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474
6abf7d06-a409-4a69-b424-9a2fb72380bc	f6702e7d-fe35-4bc2-b78b-5a04809e886c	day	08:00:00	16:00:00	t	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474
1940438c-cb20-4662-aeda-c7c488132f39	a4b3302a-4c26-4b9e-9205-c726f5b548f0	day	08:00:00	16:00:00	t	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474
b854c69e-3933-4c91-a8b9-9552931a1dc1	64c22400-eb47-46b1-93fb-11110d7121f1	day	08:00:00	16:00:00	t	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474
4d23365f-700d-4ddc-bbb4-399fafae90de	9d401424-6da4-4e9a-8568-00174cd56050	day	08:00:00	16:00:00	t	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474
a451c489-8723-45e4-9416-71cae2bd51a8	ca9c9dd0-bfd0-4436-b804-cfa549e732db	day	08:00:00	16:00:00	t	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474
2134fa8f-cd06-400b-934c-3145ca22c14d	aefab581-f8c3-42a0-b79a-55d0270f3d00	day	08:00:00	16:00:00	t	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474
dfff7c88-6fb2-4872-835d-f5a48f240de4	89dbb74e-de3b-4d24-981c-7638797c1e36	afternoon	14:00:00	22:00:00	t	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474
e090bbb1-4aae-4028-a0c4-612d8049e341	fbd7dcb6-7dc8-478a-ba23-6fae56403e81	afternoon	14:00:00	22:00:00	t	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474
fe74b0d7-2b51-45c7-80a8-81b8aa522507	c7733a6f-9d5d-4d39-a724-f85c9d24d139	afternoon	14:00:00	22:00:00	t	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474
ad86078d-79cc-45fa-a6c0-825725996096	f4d0a02a-8a68-4eb2-af6e-e4f055c356c1	afternoon	14:00:00	22:00:00	t	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474
dba39ea9-8359-460f-bc22-aa5b963377ac	822a2fa1-b223-4057-aabc-82e54feea196	afternoon	14:00:00	22:00:00	t	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474
f841363f-cc1d-4419-94e8-f5e14e5c39a7	409f5414-a30a-4090-84cc-73f477407968	afternoon	14:00:00	22:00:00	t	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474
3e2de401-b662-4ef5-b3ba-722a3e76c831	5f3fb9c6-b104-40cb-b27e-ce123ebd7fa6	afternoon	14:00:00	22:00:00	t	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474
9d00a2ef-e1dc-4802-9844-05fa16d3a9d7	0ccaa979-7837-46cf-9514-826710479042	afternoon	14:00:00	22:00:00	t	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474
fd920eb6-3625-43f3-a5e4-3429239c9834	41e8c3cb-f9a4-4f2e-a473-d47e060e89d3	afternoon	14:00:00	22:00:00	t	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474
b6d162fe-3d80-49d2-9d95-3695bb5e2e03	f6702e7d-fe35-4bc2-b78b-5a04809e886c	afternoon	14:00:00	22:00:00	t	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474
283d9b19-f809-4204-a2ad-2198206d26ce	a4b3302a-4c26-4b9e-9205-c726f5b548f0	afternoon	14:00:00	22:00:00	t	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474
ded11f3d-6360-45e7-b9b7-62bdcb055caa	64c22400-eb47-46b1-93fb-11110d7121f1	afternoon	14:00:00	22:00:00	t	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474
af1d34cc-8385-432c-9022-16d5f92b1e26	9d401424-6da4-4e9a-8568-00174cd56050	afternoon	14:00:00	22:00:00	t	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474
edcfc7a1-e054-49c9-b520-c3b3101527bc	ca9c9dd0-bfd0-4436-b804-cfa549e732db	afternoon	14:00:00	22:00:00	t	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474
58e8ea88-31de-43b8-ae1a-f538198b9dbb	aefab581-f8c3-42a0-b79a-55d0270f3d00	afternoon	14:00:00	22:00:00	t	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474
858a6f60-de91-4339-a7e7-032914945180	89dbb74e-de3b-4d24-981c-7638797c1e36	night	22:00:00	06:00:00	t	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474
8004ee10-fa60-441e-98b4-fe29e129451d	fbd7dcb6-7dc8-478a-ba23-6fae56403e81	night	22:00:00	06:00:00	t	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474
5a17454b-078a-419a-baca-8dbf06a76d2b	c7733a6f-9d5d-4d39-a724-f85c9d24d139	night	22:00:00	06:00:00	t	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474
2928c9cb-3d4d-488e-9634-55da90f46dcc	f4d0a02a-8a68-4eb2-af6e-e4f055c356c1	night	22:00:00	06:00:00	t	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474
7e08a5be-4804-44fe-97a8-8aa79e010e7e	822a2fa1-b223-4057-aabc-82e54feea196	night	22:00:00	06:00:00	t	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474
1f5e52af-636b-448d-9f20-6670e23f88c0	409f5414-a30a-4090-84cc-73f477407968	night	22:00:00	06:00:00	t	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474
915de5fa-9558-4a49-9b2e-66d9fdf750a3	5f3fb9c6-b104-40cb-b27e-ce123ebd7fa6	night	22:00:00	06:00:00	t	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474
61570808-e31c-45c1-a35f-dde250c375b9	0ccaa979-7837-46cf-9514-826710479042	night	22:00:00	06:00:00	t	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474
58953836-faa5-4b31-9cfd-96766165569d	41e8c3cb-f9a4-4f2e-a473-d47e060e89d3	night	22:00:00	06:00:00	t	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474
9cb4eaaf-1389-45ec-b78f-f350509f8b62	f6702e7d-fe35-4bc2-b78b-5a04809e886c	night	22:00:00	06:00:00	t	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474
3548298b-3e62-4437-a4c6-63b0f99ece9d	a4b3302a-4c26-4b9e-9205-c726f5b548f0	night	22:00:00	06:00:00	t	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474
363c53ca-1870-49a7-8e3a-834b78b52160	64c22400-eb47-46b1-93fb-11110d7121f1	night	22:00:00	06:00:00	t	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474
8b44da26-4b8c-4e24-9fb3-33e12d082f8a	9d401424-6da4-4e9a-8568-00174cd56050	night	22:00:00	06:00:00	t	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474
3fe9a8c3-e692-4db3-8ac2-5c209d400366	ca9c9dd0-bfd0-4436-b804-cfa549e732db	night	22:00:00	06:00:00	t	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474
c4966027-4cb7-4bb8-bc7d-25c48867271a	aefab581-f8c3-42a0-b79a-55d0270f3d00	night	22:00:00	06:00:00	t	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474
\.


--
-- Data for Name: sub_departments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sub_departments (id, parent_department_id, name, description, is_active, created_at, updated_at, branch_id, manager_id) FROM stdin;
a97dd1ad-8b9a-4070-af57-57a2f029d017	04368807-3180-43b1-927e-eab61dfb4a5b	Cinema	\N	t	2025-11-15 16:59:02.610875	2025-11-15 16:59:02.610875	\N	\N
f79e4638-4c31-484d-a400-771567a430cf	04368807-3180-43b1-927e-eab61dfb4a5b	Photo Studio	\N	t	2025-11-15 16:59:02.61514	2025-11-15 16:59:02.61514	\N	\N
c3d4b97f-40e0-4f7a-a935-c45d6602ab1a	04368807-3180-43b1-927e-eab61dfb4a5b	Saloon	\N	t	2025-11-15 16:59:02.615426	2025-11-15 16:59:02.615426	\N	\N
324201e5-d41a-4082-9006-eab2e15f95b5	04368807-3180-43b1-927e-eab61dfb4a5b	Arcade and Kiddies Park	\N	t	2025-11-15 16:59:02.615668	2025-11-15 16:59:02.615668	\N	\N
83100a44-ccde-4cda-a0e7-eee3ec08142c	04368807-3180-43b1-927e-eab61dfb4a5b	Casino	\N	t	2025-11-15 16:59:02.615953	2025-11-15 16:59:02.615953	\N	\N
\.


--
-- Data for Name: terminated_staff; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.terminated_staff (id, user_id, full_name, email, employee_id, role_name, department_name, branch_name, termination_type, termination_reason, termination_date, terminated_by, terminated_by_name, terminated_by_role, last_working_day, final_salary, clearance_status, clearance_notes, created_at, updated_at) FROM stdin;
a8cbdf3b-11ce-45a0-9b63-0b20b988a252	1a6bdfd6-888d-44f7-8f49-eaa05b8af956	Mr. Segun Afolabi	waiter.ife1@acesupermarket.com	ACE-WAIT-007	Waitress (Lounge)	Lounge	Ace Mall, Ife	terminated	Loren ipsum	2025-12-06 15:12:13.265504	f1361a2d-c534-4cfd-81a0-796ed17b4339	Chief Adebayo Williams	Chief Executive Officer	2025-12-04	0.00	pending		2025-12-06 15:12:13.265504	2025-12-06 15:12:13.265504
\.


--
-- Data for Name: user_documents; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_documents (id, user_id, document_type, document_url, public_id, uploaded_at) FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, email, password_hash, full_name, gender, date_of_birth, marital_status, phone_number, home_address, state_of_origin, employee_id, role_id, department_id, sub_department_id, branch_id, date_joined, current_salary, course_of_study, grade, institution, is_active, is_terminated, termination_reason, termination_date, created_at, updated_at, last_login, profile_image_url, profile_image_public_id, waec_certificate_url, waec_certificate_public_id, neco_certificate_url, neco_certificate_public_id, jamb_result_url, jamb_result_public_id, degree_certificate_url, degree_certificate_public_id, diploma_certificate_url, diploma_certificate_public_id, birth_certificate_url, birth_certificate_public_id, national_id_url, national_id_public_id, passport_url, passport_public_id, drivers_license_url, drivers_license_public_id, voters_card_url, voters_card_public_id, nysc_certificate_url, nysc_certificate_public_id, state_of_origin_cert_url, state_of_origin_cert_public_id, lga_certificate_url, lga_certificate_public_id, resume_url, resume_public_id, cover_letter_url, cover_letter_public_id, department_scope) FROM stdin;
b5d7896a-9217-480e-b4ac-8343141a3333	ooludiranayoade@gmail.com	$2a$10$qzTGAi2KGs/hAj9HxE6ATeDvHe5CZmjMPDO/0mD4zHUyNVrPKdv4m	Oludiran-Ayoade Olutimileyin	Male	2025-08-07		07060601254			ACE20251209182151	6c0631da-dced-45b9-ae65-e539e25802ed	160511a1-5b4f-4af9-bdc7-1764adbe6142	\N	d735da13-cff9-4009-a6dd-4ad59fc9f72b	2025-12-09	1500000.00				t	f	\N	\N	2025-12-09 18:21:51.928145	2025-12-09 18:56:45.763239	2025-12-09 23:35:26.624487	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	branch
8e57948f-983c-4db3-b517-a46b3d3531b3	mini@gmail.com	$2a$10$CFp.wOQwgs6yqURoKa99mesozwM43RMpH07AOCHHe0O03z88nEIn2	Tamuno Mini	Male	2025-12-03	Married	08058655891	Obiakpor,Porthachort	Edo	ACE202	6c0631da-dced-45b9-ae65-e539e25802ed	160511a1-5b4f-4af9-bdc7-1764adbe6142	\N	38f86af3-14b1-4fe4-a84f-d895e840b1d1	2025-12-09	15000000.00	Civil Engineering	2:1 (Second Class Upper)	Covenant Uni	t	f	\N	\N	2025-12-09 23:25:55.18073	2025-12-10 13:05:38.337586	\N	https://res.cloudinary.com/desk7uuna/image/upload/v1765350163/ace_mall_staff/profile_picture/g4t7bk4jhevipizkpnr2.png	\N	https://res.cloudinary.com/desk7uuna/image/upload/v1765319133/ace_mall_staff/waec_certificate/qnvx5ehgojbwfnaq6ilc.pdf	\N	\N	\N	\N	\N	https://res.cloudinary.com/desk7uuna/image/upload/v1765319152/ace_mall_staff/degree_certificate/uu5adv8yqnxgfgmlenin.jpg	\N	\N	\N	https://res.cloudinary.com/desk7uuna/image/upload/v1765319128/ace_mall_staff/birth_certificate/qwip7vbunlu0kmj8bagb.pdf	\N	https://res.cloudinary.com/desk7uuna/image/upload/v1765319125/ace_mall_staff/national_id/fvev6auo3rga1gpqbvvs.pdf	\N	https://res.cloudinary.com/desk7uuna/image/upload/v1765319123/ace_mall_staff/passport/yja6zpyyhwlfjx043car.pdf	\N	\N	\N	\N	\N	https://res.cloudinary.com/desk7uuna/image/upload/v1765319150/ace_mall_staff/nysc_certificate/rwxnol9zyabruunuasob.jpg	\N	https://res.cloudinary.com/desk7uuna/image/upload/v1765319154/ace_mall_staff/state_of_origin_cert/phreng2hejz2nc8xjjnv.pdf	\N	\N	\N	\N	\N	\N	\N	branch
e6bcd428-3711-4d17-80b4-5fab412563bd	cashier.akobo2@acesupermarket.com	$2a$10$ElkYaw5rar.b92GC6Fp/oeuyQmYleDeQMPhpaO4ngs5HFdlTnSRwS	Miss Bisi Adebayo	Female	1995-05-01	\N	+234-803-400-0004	\N	\N	ACE-CASH-004	ba813f53-f592-435d-ba88-d2df338f46b1	160511a1-5b4f-4af9-bdc7-1764adbe6142	\N	8b67a276-81d1-4950-88ee-47b7077c0bf2	2023-01-21	1000000.00	\N	\N	\N	t	f	\N	\N	2025-12-06 12:17:14.417474	2025-12-13 23:32:19.021042	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	branch
97dabb21-c5cd-434c-8bff-ae86b3682018	olatinubu@gmail.com	$2a$10$XVjLMqq2Av5KWUM.V1S5weLDOyINHVaTQcG6VbpdNljf/wQBI6ZEq	Bola Ahmed Tinubu	Male	1975-09-11	Married	0806424951	Abuja,aso rock	Lagos	ACE20251209192719	41d4f439-b727-4c73-ac9c-c02c7b11b679	160511a1-5b4f-4af9-bdc7-1764adbe6142	\N	\N	2025-12-09	15000000.00	Political Science	2:1 (Second Class Upper)	University of Chicago	t	f	\N	\N	2025-12-09 19:27:19.205408	2025-12-10 12:44:29.35148	2025-12-10 12:28:15.166344	\N	\N	https://res.cloudinary.com/desk7uuna/image/upload/v1765304828/staff_documents/waec_certificate/gn54xchmvka79rrtos0x.pdf	\N	\N	\N	\N	\N	https://res.cloudinary.com/desk7uuna/image/upload/v1765304832/staff_documents/degree_certificate/ugbgemwloyrs1ianukkb.pdf	\N	\N	\N	https://res.cloudinary.com/desk7uuna/image/upload/v1765304826/staff_documents/birth_certificate/ph0uqbqkyjmitbkc2ilx.pdf	\N	https://res.cloudinary.com/desk7uuna/image/upload/v1765304823/staff_documents/national_id/edrbkqwcbcx9eiim7c3s.jpg	\N	https://res.cloudinary.com/desk7uuna/image/upload/v1765304819/staff_documents/passport/nba8zzrisy42tggepooj.jpg	\N	\N	\N	\N	\N	https://res.cloudinary.com/desk7uuna/image/upload/v1765304830/staff_documents/nysc_certificate/rknord9wcifdxw3wtig7.pdf	\N	https://res.cloudinary.com/desk7uuna/image/upload/v1765304835/staff_documents/state_of_origin_cert/szxofqasnxxkdhzj6ywh.pdf	\N	\N	\N	\N	\N	\N	\N	branch
23a2c030-e381-40b0-885f-efe8c6ccf388	bm.osogbo@acesupermarket.com	$2a$10$ElkYaw5rar.b92GC6Fp/oeuyQmYleDeQMPhpaO4ngs5HFdlTnSRwS	Mrs. Kemi Adebayo	Female	1977-09-27	\N	+234-803-200-0010	\N	\N	ACE-BM-010	6c0631da-dced-45b9-ae65-e539e25802ed	160511a1-5b4f-4af9-bdc7-1764adbe6142	\N	2af15e5d-b67a-493f-8357-feaec629a69a	2021-04-11	500000.00	\N	\N	\N	t	f	\N	\N	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	branch
f50c5c53-dd6a-4380-9d6f-1410b29a7fa4	bm.oyo@acesupermarket.com	$2a$10$ElkYaw5rar.b92GC6Fp/oeuyQmYleDeQMPhpaO4ngs5HFdlTnSRwS	Mr. Femi Ogunbiyi	Male	1978-01-05	\N	+234-803-200-0011	\N	\N	ACE-BM-011	6c0631da-dced-45b9-ae65-e539e25802ed	160511a1-5b4f-4af9-bdc7-1764adbe6142	\N	394d14df-75fd-41e0-847d-cd2f08c5b1af	2021-04-21	500000.00	\N	\N	\N	t	f	\N	\N	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	branch
3edac621-15bc-43a1-9a09-19231b503c80	bm.sagamu@acesupermarket.com	$2a$10$ElkYaw5rar.b92GC6Fp/oeuyQmYleDeQMPhpaO4ngs5HFdlTnSRwS	Mrs. Yetunde Olatunji	Female	1978-04-15	\N	+234-803-200-0012	\N	\N	ACE-BM-012	6c0631da-dced-45b9-ae65-e539e25802ed	160511a1-5b4f-4af9-bdc7-1764adbe6142	\N	1aa3b0e6-af63-4ae1-b371-90e88880f8f1	2021-05-01	500000.00	\N	\N	\N	t	f	\N	\N	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	branch
8ddcb7e7-9941-46bb-866b-6aae3a217a5d	bm.saki@acesupermarket.com	$2a$10$ElkYaw5rar.b92GC6Fp/oeuyQmYleDeQMPhpaO4ngs5HFdlTnSRwS	Mr. Biodun Akinola	Male	1978-07-24	\N	+234-803-200-0013	\N	\N	ACE-BM-013	6c0631da-dced-45b9-ae65-e539e25802ed	160511a1-5b4f-4af9-bdc7-1764adbe6142	\N	96423273-2c53-4067-8481-1e7ac885e3ac	2021-05-11	500000.00	\N	\N	\N	t	f	\N	\N	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	branch
2b9793bf-f240-4cf8-a94a-c4b652f0ae0b	bm.abeokuta@acesupermarket.com	$2a$10$ElkYaw5rar.b92GC6Fp/oeuyQmYleDeQMPhpaO4ngs5HFdlTnSRwS	Mr. Adewale Johnson	Male	1975-04-11	\N	+234-803-200-0001	\N	\N	ACE-BM-001	6c0631da-dced-45b9-ae65-e539e25802ed	160511a1-5b4f-4af9-bdc7-1764adbe6142	\N	511a5f95-209d-4b8d-b795-990079b07e1e	2021-01-11	500000.00	\N	\N	\N	t	f	\N	\N	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474	2025-12-15 10:36:57.479083	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	branch
710974ab-52fc-4726-b50a-b309d5b7d9ba	fm.abeokuta.lounge@acesupermarket.com	$2a$10$ElkYaw5rar.b92GC6Fp/oeuyQmYleDeQMPhpaO4ngs5HFdlTnSRwS	Mr. Gbenga Afolabi	Male	1989-03-22	\N	+234-803-300-0001	\N	\N	ACE-FM-001	bc694f45-bb32-4b4e-8ac3-9773e6d7fbb9	3be6b055-b126-4fdf-88a8-152634a678ea	\N	511a5f95-209d-4b8d-b795-990079b07e1e	2022-01-16	330000.00	\N	\N	\N	t	f	\N	\N	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474	2025-12-15 11:55:50.522457	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	branch
9f68aa0f-c6c7-4b73-a4d9-d3225b88c2f0	bm.akobo@acesupermarket.com	$2a$10$ElkYaw5rar.b92GC6Fp/oeuyQmYleDeQMPhpaO4ngs5HFdlTnSRwS	Mrs. Blessing Okoro	Female	1975-07-20	\N	+234-803-200-0002	\N	\N	ACE-BM-002	6c0631da-dced-45b9-ae65-e539e25802ed	160511a1-5b4f-4af9-bdc7-1764adbe6142	\N	8b67a276-81d1-4950-88ee-47b7077c0bf2	2021-01-21	500000.00	\N	\N	\N	t	f	\N	\N	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474	2025-12-15 14:31:40.066054	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	branch
805b6158-8b01-4f05-90f2-a0fcad495cb9	bm.bodija@acesupermarket.com	$2a$10$ElkYaw5rar.b92GC6Fp/oeuyQmYleDeQMPhpaO4ngs5HFdlTnSRwS	Mr. Ibrahim Yusuf	Male	1975-10-28	\N	+234-803-200-0003	\N	\N	ACE-BM-003	6c0631da-dced-45b9-ae65-e539e25802ed	160511a1-5b4f-4af9-bdc7-1764adbe6142	\N	38f86af3-14b1-4fe4-a84f-d895e840b1d1	2021-01-31	500000.00	\N	\N	\N	t	f	\N	\N	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	branch
a7a5977d-c912-4476-b8c1-89d6a6dec0ee	fm.abeokuta.supermarket@acesupermarket.com	$2a$10$ElkYaw5rar.b92GC6Fp/oeuyQmYleDeQMPhpaO4ngs5HFdlTnSRwS	Miss Shade Ogunleye	Female	1989-06-10	\N	+234-803-300-0002	\N	\N	ACE-FM-002	ba813f53-f592-435d-ba88-d2df338f46b1	160511a1-5b4f-4af9-bdc7-1764adbe6142	\N	511a5f95-209d-4b8d-b795-990079b07e1e	2022-01-31	330000.00	\N	\N	\N	t	f	\N	\N	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	branch
085df28e-fb49-420c-bea9-0432c9199f40	fm.akobo.lounge@acesupermarket.com	$2a$10$ElkYaw5rar.b92GC6Fp/oeuyQmYleDeQMPhpaO4ngs5HFdlTnSRwS	Mr. Wale Akinwande	Male	1989-08-29	\N	+234-803-300-0003	\N	\N	ACE-FM-003	bc694f45-bb32-4b4e-8ac3-9773e6d7fbb9	3be6b055-b126-4fdf-88a8-152634a678ea	\N	8b67a276-81d1-4950-88ee-47b7077c0bf2	2022-02-15	330000.00	\N	\N	\N	t	f	\N	\N	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	branch
d2e4dc25-672a-485e-98b8-0126b3f10d28	fm.akobo.supermarket@acesupermarket.com	$2a$10$ElkYaw5rar.b92GC6Fp/oeuyQmYleDeQMPhpaO4ngs5HFdlTnSRwS	Miss Zainab Ibrahim	Female	1989-11-17	\N	+234-803-300-0004	\N	\N	ACE-FM-004	ba813f53-f592-435d-ba88-d2df338f46b1	160511a1-5b4f-4af9-bdc7-1764adbe6142	\N	8b67a276-81d1-4950-88ee-47b7077c0bf2	2022-03-02	330000.00	\N	\N	\N	t	f	\N	\N	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	branch
61bd6a53-cd0b-4af7-9166-c8385d448f8f	bm.ife@acesupermarket.com	$2a$10$ElkYaw5rar.b92GC6Fp/oeuyQmYleDeQMPhpaO4ngs5HFdlTnSRwS	Mrs. Chioma Nwankwo	Female	1976-02-05	\N	+234-803-200-0004	\N	\N	ACE-BM-004	6c0631da-dced-45b9-ae65-e539e25802ed	160511a1-5b4f-4af9-bdc7-1764adbe6142	\N	70777e0c-f350-4f3b-9013-5e8691a96d8c	2021-02-10	500000.00	\N	\N	\N	t	f	\N	\N	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	branch
891bbc40-a563-4fab-9ca0-a0defd6abbe3	bm.ijebu@acesupermarket.com	$2a$10$ElkYaw5rar.b92GC6Fp/oeuyQmYleDeQMPhpaO4ngs5HFdlTnSRwS	Mr. Kunle Adeleke	Male	1976-05-15	\N	+234-803-200-0005	\N	\N	ACE-BM-005	6c0631da-dced-45b9-ae65-e539e25802ed	160511a1-5b4f-4af9-bdc7-1764adbe6142	\N	9d23f80a-749e-4d59-a26d-85e16a388846	2021-02-20	500000.00	\N	\N	\N	t	f	\N	\N	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	branch
81e8d990-cba5-41df-8c92-f74cdbc3a71a	fm.bodija.lounge@acesupermarket.com	$2a$10$ElkYaw5rar.b92GC6Fp/oeuyQmYleDeQMPhpaO4ngs5HFdlTnSRwS	Mr. Damilola Ogunbiyi	Male	1990-02-05	\N	+234-803-300-0005	\N	\N	ACE-FM-005	bc694f45-bb32-4b4e-8ac3-9773e6d7fbb9	3be6b055-b126-4fdf-88a8-152634a678ea	\N	38f86af3-14b1-4fe4-a84f-d895e840b1d1	2022-03-17	330000.00	\N	\N	\N	t	f	\N	\N	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	branch
e116ad22-a5f7-4bcd-9577-8b5f9beeaf46	bm.ilorin@acesupermarket.com	$2a$10$ElkYaw5rar.b92GC6Fp/oeuyQmYleDeQMPhpaO4ngs5HFdlTnSRwS	Mrs. Halima Bello	Female	1976-08-23	\N	+234-803-200-0006	\N	\N	ACE-BM-006	6c0631da-dced-45b9-ae65-e539e25802ed	160511a1-5b4f-4af9-bdc7-1764adbe6142	\N	1bc5af13-0b28-422e-bf26-df270e0a4089	2021-03-02	500000.00	\N	\N	\N	t	f	\N	\N	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	branch
9b40e7c8-5dde-4b3b-8574-4cdb3453fc31	bm.iseyin@acesupermarket.com	$2a$10$ElkYaw5rar.b92GC6Fp/oeuyQmYleDeQMPhpaO4ngs5HFdlTnSRwS	Mr. Segun Ogunleye	Male	1976-12-01	\N	+234-803-200-0007	\N	\N	ACE-BM-007	6c0631da-dced-45b9-ae65-e539e25802ed	160511a1-5b4f-4af9-bdc7-1764adbe6142	\N	ff3a7fa2-ee3e-484c-ac9b-548b6b9a6eda	2021-03-12	500000.00	\N	\N	\N	t	f	\N	\N	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	branch
8f675035-cc06-4b4e-89b6-db4f7c123ed2	bm.ogbomosho@acesupermarket.com	$2a$10$ElkYaw5rar.b92GC6Fp/oeuyQmYleDeQMPhpaO4ngs5HFdlTnSRwS	Mrs. Ronke Ajayi	Female	1977-03-11	\N	+234-803-200-0008	\N	\N	ACE-BM-008	6c0631da-dced-45b9-ae65-e539e25802ed	160511a1-5b4f-4af9-bdc7-1764adbe6142	\N	001a6790-0f59-4776-aee9-cb1928290ec9	2021-03-22	500000.00	\N	\N	\N	t	f	\N	\N	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	branch
376e41c2-4a6e-4010-ba3d-24eb0c509ada	bm.oluyole@acesupermarket.com	$2a$10$ElkYaw5rar.b92GC6Fp/oeuyQmYleDeQMPhpaO4ngs5HFdlTnSRwS	Mr. Adekunle Oladipo	Male	1977-06-19	\N	+234-803-200-0009	\N	\N	ACE-BM-009	6c0631da-dced-45b9-ae65-e539e25802ed	160511a1-5b4f-4af9-bdc7-1764adbe6142	\N	d735da13-cff9-4009-a6dd-4ad59fc9f72b	2021-04-01	500000.00	\N	\N	\N	t	f	\N	\N	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	branch
091177fc-3b2c-4858-8ea0-b8f7206b4636	fm.bodija.supermarket@acesupermarket.com	$2a$10$ElkYaw5rar.b92GC6Fp/oeuyQmYleDeQMPhpaO4ngs5HFdlTnSRwS	Mrs. Omolara Adeyinka	Female	1990-04-26	\N	+234-803-300-0006	\N	\N	ACE-FM-006	ba813f53-f592-435d-ba88-d2df338f46b1	160511a1-5b4f-4af9-bdc7-1764adbe6142	\N	38f86af3-14b1-4fe4-a84f-d895e840b1d1	2022-04-01	330000.00	\N	\N	\N	t	f	\N	\N	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	branch
7ef2acf4-d876-4a29-b1f0-db8301f817a6	fm.ife.lounge@acesupermarket.com	$2a$10$ElkYaw5rar.b92GC6Fp/oeuyQmYleDeQMPhpaO4ngs5HFdlTnSRwS	Mr. Akeem Oladele	Male	1990-07-15	\N	+234-803-300-0007	\N	\N	ACE-FM-007	bc694f45-bb32-4b4e-8ac3-9773e6d7fbb9	3be6b055-b126-4fdf-88a8-152634a678ea	\N	70777e0c-f350-4f3b-9013-5e8691a96d8c	2022-04-16	330000.00	\N	\N	\N	t	f	\N	\N	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	branch
7b63533f-02f3-4491-9808-64ad90a92334	fm.ife.supermarket@acesupermarket.com	$2a$10$ElkYaw5rar.b92GC6Fp/oeuyQmYleDeQMPhpaO4ngs5HFdlTnSRwS	Mrs. Amaka Obi	Female	1990-10-03	\N	+234-803-300-0008	\N	\N	ACE-FM-008	ba813f53-f592-435d-ba88-d2df338f46b1	160511a1-5b4f-4af9-bdc7-1764adbe6142	\N	70777e0c-f350-4f3b-9013-5e8691a96d8c	2022-05-01	330000.00	\N	\N	\N	t	f	\N	\N	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	branch
d2940649-78f0-4418-88b4-7b16a9a7104f	fm.ijebu.lounge@acesupermarket.com	$2a$10$ElkYaw5rar.b92GC6Fp/oeuyQmYleDeQMPhpaO4ngs5HFdlTnSRwS	Mr. Kayode Ajayi	Male	1990-12-22	\N	+234-803-300-0009	\N	\N	ACE-FM-009	bc694f45-bb32-4b4e-8ac3-9773e6d7fbb9	3be6b055-b126-4fdf-88a8-152634a678ea	\N	9d23f80a-749e-4d59-a26d-85e16a388846	2022-05-16	330000.00	\N	\N	\N	t	f	\N	\N	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	branch
a8f9ccad-6eef-45ea-b1d9-9b24ec7ab5a9	fm.ijebu.supermarket@acesupermarket.com	$2a$10$ElkYaw5rar.b92GC6Fp/oeuyQmYleDeQMPhpaO4ngs5HFdlTnSRwS	Mrs. Kemi Oluwole	Female	1991-03-12	\N	+234-803-300-0010	\N	\N	ACE-FM-010	ba813f53-f592-435d-ba88-d2df338f46b1	160511a1-5b4f-4af9-bdc7-1764adbe6142	\N	9d23f80a-749e-4d59-a26d-85e16a388846	2022-05-31	330000.00	\N	\N	\N	t	f	\N	\N	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	branch
b4801419-3838-4ac9-9c94-b05568dbf2b1	fm.ilorin.lounge@acesupermarket.com	$2a$10$ElkYaw5rar.b92GC6Fp/oeuyQmYleDeQMPhpaO4ngs5HFdlTnSRwS	Mr. Gbenga Afolabi	Male	1991-05-31	\N	+234-803-300-0011	\N	\N	ACE-FM-011	bc694f45-bb32-4b4e-8ac3-9773e6d7fbb9	3be6b055-b126-4fdf-88a8-152634a678ea	\N	1bc5af13-0b28-422e-bf26-df270e0a4089	2022-06-15	330000.00	\N	\N	\N	t	f	\N	\N	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	branch
1eab9750-4824-4de4-8168-04591fc249f7	fm.ilorin.supermarket@acesupermarket.com	$2a$10$ElkYaw5rar.b92GC6Fp/oeuyQmYleDeQMPhpaO4ngs5HFdlTnSRwS	Miss Shade Ogunleye	Female	1991-08-19	\N	+234-803-300-0012	\N	\N	ACE-FM-012	ba813f53-f592-435d-ba88-d2df338f46b1	160511a1-5b4f-4af9-bdc7-1764adbe6142	\N	1bc5af13-0b28-422e-bf26-df270e0a4089	2022-06-30	330000.00	\N	\N	\N	t	f	\N	\N	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	branch
6315b233-5988-421f-9cb9-95a8b68e00ce	fm.iseyin.lounge@acesupermarket.com	$2a$10$ElkYaw5rar.b92GC6Fp/oeuyQmYleDeQMPhpaO4ngs5HFdlTnSRwS	Mr. Wale Akinwande	Male	1991-11-07	\N	+234-803-300-0013	\N	\N	ACE-FM-013	bc694f45-bb32-4b4e-8ac3-9773e6d7fbb9	3be6b055-b126-4fdf-88a8-152634a678ea	\N	ff3a7fa2-ee3e-484c-ac9b-548b6b9a6eda	2022-07-15	330000.00	\N	\N	\N	t	f	\N	\N	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	branch
ca9c9dd0-bfd0-4436-b804-cfa549e732db	casino.bodija@acesupermarket.com	$2a$10$ElkYaw5rar.b92GC6Fp/oeuyQmYleDeQMPhpaO4ngs5HFdlTnSRwS	Mrs. Amaka Nwosu	Female	1988-07-16	\N	+234-803-500-0014	\N	\N	ACE-CAS-002	4aff4bf4-bd45-4b82-90bd-7d34245b43ed	04368807-3180-43b1-927e-eab61dfb4a5b	83100a44-ccde-4cda-a0e7-eee3ec08142c	38f86af3-14b1-4fe4-a84f-d895e840b1d1	2022-05-25	360000.00	\N	\N	\N	t	f	\N	\N	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474	2025-12-06 12:19:08.616825	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	branch
f6702e7d-fe35-4bc2-b78b-5a04809e886c	arcade.abeokuta@acesupermarket.com	$2a$10$ElkYaw5rar.b92GC6Fp/oeuyQmYleDeQMPhpaO4ngs5HFdlTnSRwS	Mr. Kunle Adeleke	Male	1990-04-12	\N	+234-803-500-0010	\N	\N	ACE-ARC-001	d3d91c1f-2351-425c-a59e-d9d1e8924382	04368807-3180-43b1-927e-eab61dfb4a5b	\N	511a5f95-209d-4b8d-b795-990079b07e1e	2022-07-15	340000.00	\N	\N	\N	t	f	\N	\N	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474	2025-12-06 12:20:48.616818	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	branch
fbd7dcb6-7dc8-478a-ba23-6fae56403e81	cinema.bodija@acesupermarket.com	$2a$10$ElkYaw5rar.b92GC6Fp/oeuyQmYleDeQMPhpaO4ngs5HFdlTnSRwS	Miss Funke Oladele	Female	1990-07-22	\N	+234-803-500-0002	\N	\N	ACE-CIN-002	71206ff6-4c7e-4e1b-a291-a672fbbb13c7	04368807-3180-43b1-927e-eab61dfb4a5b	a97dd1ad-8b9a-4070-af57-57a2f029d017	38f86af3-14b1-4fe4-a84f-d895e840b1d1	2022-04-15	350000.00	\N	\N	\N	t	f	\N	\N	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474	2025-12-06 12:29:36.303856	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	branch
5f3fb9c6-b104-40cb-b27e-ce123ebd7fa6	saloon.abeokuta@acesupermarket.com	$2a$10$ElkYaw5rar.b92GC6Fp/oeuyQmYleDeQMPhpaO4ngs5HFdlTnSRwS	Miss Blessing Okoro	Female	1992-02-14					ACE-SAL-001	1e4366db-e4f0-47e2-a2e2-70c8547ee483	04368807-3180-43b1-927e-eab61dfb4a5b	c3d4b97f-40e0-4f7a-a935-c45d6602ab1a	511a5f95-209d-4b8d-b795-990079b07e1e	2022-02-28	0.00	\N	\N	\N	t	f	\N	\N	2025-12-06 12:17:14.417474	2025-12-09 16:19:17.725838	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	branch
f8642d75-f69a-487d-b385-661ecf2fc8fc	fm.iseyin.supermarket@acesupermarket.com	$2a$10$ElkYaw5rar.b92GC6Fp/oeuyQmYleDeQMPhpaO4ngs5HFdlTnSRwS	Miss Zainab Ibrahim	Female	1992-01-26	\N	+234-803-300-0014	\N	\N	ACE-FM-014	ba813f53-f592-435d-ba88-d2df338f46b1	160511a1-5b4f-4af9-bdc7-1764adbe6142	\N	ff3a7fa2-ee3e-484c-ac9b-548b6b9a6eda	2022-07-30	330000.00	\N	\N	\N	t	f	\N	\N	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	branch
3b4d200d-8f2c-45c8-a3ae-2816d06f208c	fm.ogbomosho.lounge@acesupermarket.com	$2a$10$ElkYaw5rar.b92GC6Fp/oeuyQmYleDeQMPhpaO4ngs5HFdlTnSRwS	Mr. Damilola Ogunbiyi	Male	1992-04-15	\N	+234-803-300-0015	\N	\N	ACE-FM-015	bc694f45-bb32-4b4e-8ac3-9773e6d7fbb9	3be6b055-b126-4fdf-88a8-152634a678ea	\N	001a6790-0f59-4776-aee9-cb1928290ec9	2022-08-14	330000.00	\N	\N	\N	t	f	\N	\N	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	branch
a1ba9ca9-d129-47c4-b6ff-1d3a5fd1e27d	fm.ogbomosho.supermarket@acesupermarket.com	$2a$10$ElkYaw5rar.b92GC6Fp/oeuyQmYleDeQMPhpaO4ngs5HFdlTnSRwS	Mrs. Omolara Adeyinka	Female	1992-07-04	\N	+234-803-300-0016	\N	\N	ACE-FM-016	ba813f53-f592-435d-ba88-d2df338f46b1	160511a1-5b4f-4af9-bdc7-1764adbe6142	\N	001a6790-0f59-4776-aee9-cb1928290ec9	2022-08-29	330000.00	\N	\N	\N	t	f	\N	\N	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	branch
7af931a9-9b6d-464c-928a-56556aa73171	fm.oluyole.lounge@acesupermarket.com	$2a$10$ElkYaw5rar.b92GC6Fp/oeuyQmYleDeQMPhpaO4ngs5HFdlTnSRwS	Mr. Akeem Oladele	Male	1992-09-22	\N	+234-803-300-0017	\N	\N	ACE-FM-017	bc694f45-bb32-4b4e-8ac3-9773e6d7fbb9	3be6b055-b126-4fdf-88a8-152634a678ea	\N	d735da13-cff9-4009-a6dd-4ad59fc9f72b	2022-09-13	330000.00	\N	\N	\N	t	f	\N	\N	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	branch
87e45cfe-99c0-46bf-8ea4-a53fb3c757b0	fm.oluyole.supermarket@acesupermarket.com	$2a$10$ElkYaw5rar.b92GC6Fp/oeuyQmYleDeQMPhpaO4ngs5HFdlTnSRwS	Mrs. Amaka Obi	Female	1992-12-11	\N	+234-803-300-0018	\N	\N	ACE-FM-018	ba813f53-f592-435d-ba88-d2df338f46b1	160511a1-5b4f-4af9-bdc7-1764adbe6142	\N	d735da13-cff9-4009-a6dd-4ad59fc9f72b	2022-09-28	330000.00	\N	\N	\N	t	f	\N	\N	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	branch
d1b4bda9-e6d2-4b36-a87b-63b34b14a47a	fm.osogbo.lounge@acesupermarket.com	$2a$10$ElkYaw5rar.b92GC6Fp/oeuyQmYleDeQMPhpaO4ngs5HFdlTnSRwS	Mr. Kayode Ajayi	Male	1993-03-01	\N	+234-803-300-0019	\N	\N	ACE-FM-019	bc694f45-bb32-4b4e-8ac3-9773e6d7fbb9	3be6b055-b126-4fdf-88a8-152634a678ea	\N	2af15e5d-b67a-493f-8357-feaec629a69a	2022-10-13	330000.00	\N	\N	\N	t	f	\N	\N	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	branch
df4b5622-d10a-4be6-b3b9-ae9eb365621f	fm.osogbo.supermarket@acesupermarket.com	$2a$10$ElkYaw5rar.b92GC6Fp/oeuyQmYleDeQMPhpaO4ngs5HFdlTnSRwS	Mrs. Kemi Oluwole	Female	1993-05-20	\N	+234-803-300-0020	\N	\N	ACE-FM-020	ba813f53-f592-435d-ba88-d2df338f46b1	160511a1-5b4f-4af9-bdc7-1764adbe6142	\N	2af15e5d-b67a-493f-8357-feaec629a69a	2022-10-28	330000.00	\N	\N	\N	t	f	\N	\N	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	branch
89dbb74e-de3b-4d24-981c-7638797c1e36	cinema.abeokuta@acesupermarket.com	$2a$10$ElkYaw5rar.b92GC6Fp/oeuyQmYleDeQMPhpaO4ngs5HFdlTnSRwS	Mr. Tayo Adeyemi	Male	1988-03-15	\N	+234-803-500-0001	\N	\N	ACE-CIN-001	71206ff6-4c7e-4e1b-a291-a672fbbb13c7	04368807-3180-43b1-927e-eab61dfb4a5b	a97dd1ad-8b9a-4070-af57-57a2f029d017	511a5f95-209d-4b8d-b795-990079b07e1e	2022-06-01	350000.00	\N	\N	\N	t	f	\N	\N	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	branch
c7733a6f-9d5d-4d39-a724-f85c9d24d139	cinema.akobo@acesupermarket.com	$2a$10$ElkYaw5rar.b92GC6Fp/oeuyQmYleDeQMPhpaO4ngs5HFdlTnSRwS	Mr. Segun Afolabi	Male	1987-11-10	\N	+234-803-500-0003	\N	\N	ACE-CIN-003	71206ff6-4c7e-4e1b-a291-a672fbbb13c7	04368807-3180-43b1-927e-eab61dfb4a5b	a97dd1ad-8b9a-4070-af57-57a2f029d017	8b67a276-81d1-4950-88ee-47b7077c0bf2	2022-07-01	350000.00	\N	\N	\N	t	f	\N	\N	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	branch
f4d0a02a-8a68-4eb2-af6e-e4f055c356c1	photostudio.abeokuta@acesupermarket.com	$2a$10$ElkYaw5rar.b92GC6Fp/oeuyQmYleDeQMPhpaO4ngs5HFdlTnSRwS	Mrs. Kemi Adebayo	Female	1989-05-18	\N	+234-803-500-0004	\N	\N	ACE-PHO-001	a9a8981e-85ee-4257-9f51-aa811061a988	04368807-3180-43b1-927e-eab61dfb4a5b	f79e4638-4c31-484d-a400-771567a430cf	511a5f95-209d-4b8d-b795-990079b07e1e	2022-05-10	340000.00	\N	\N	\N	t	f	\N	\N	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	branch
822a2fa1-b223-4057-aabc-82e54feea196	photostudio.bodija@acesupermarket.com	$2a$10$ElkYaw5rar.b92GC6Fp/oeuyQmYleDeQMPhpaO4ngs5HFdlTnSRwS	Mr. Wale Ogunbiyi	Male	1986-09-25	\N	+234-803-500-0005	\N	\N	ACE-PHO-002	a9a8981e-85ee-4257-9f51-aa811061a988	04368807-3180-43b1-927e-eab61dfb4a5b	f79e4638-4c31-484d-a400-771567a430cf	38f86af3-14b1-4fe4-a84f-d895e840b1d1	2022-03-20	340000.00	\N	\N	\N	t	f	\N	\N	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	branch
409f5414-a30a-4090-84cc-73f477407968	photostudio.akobo@acesupermarket.com	$2a$10$ElkYaw5rar.b92GC6Fp/oeuyQmYleDeQMPhpaO4ngs5HFdlTnSRwS	Miss Shade Akinola	Female	1991-12-08	\N	+234-803-500-0006	\N	\N	ACE-PHO-003	a9a8981e-85ee-4257-9f51-aa811061a988	04368807-3180-43b1-927e-eab61dfb4a5b	f79e4638-4c31-484d-a400-771567a430cf	8b67a276-81d1-4950-88ee-47b7077c0bf2	2022-08-15	340000.00	\N	\N	\N	t	f	\N	\N	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	branch
0ccaa979-7837-46cf-9514-826710479042	saloon.bodija@acesupermarket.com	$2a$10$ElkYaw5rar.b92GC6Fp/oeuyQmYleDeQMPhpaO4ngs5HFdlTnSRwS	Mr. Gbenga Fashola	Male	1988-06-30	\N	+234-803-500-0008	\N	\N	ACE-SAL-002	1e4366db-e4f0-47e2-a2e2-70c8547ee483	04368807-3180-43b1-927e-eab61dfb4a5b	c3d4b97f-40e0-4f7a-a935-c45d6602ab1a	38f86af3-14b1-4fe4-a84f-d895e840b1d1	2022-06-10	330000.00	\N	\N	\N	t	f	\N	\N	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	branch
41e8c3cb-f9a4-4f2e-a473-d47e060e89d3	saloon.akobo@acesupermarket.com	$2a$10$ElkYaw5rar.b92GC6Fp/oeuyQmYleDeQMPhpaO4ngs5HFdlTnSRwS	Mrs. Yetunde Olatunji	Female	1987-10-05	\N	+234-803-500-0009	\N	\N	ACE-SAL-003	1e4366db-e4f0-47e2-a2e2-70c8547ee483	04368807-3180-43b1-927e-eab61dfb4a5b	c3d4b97f-40e0-4f7a-a935-c45d6602ab1a	8b67a276-81d1-4950-88ee-47b7077c0bf2	2022-05-20	330000.00	\N	\N	\N	t	f	\N	\N	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	branch
a4b3302a-4c26-4b9e-9205-c726f5b548f0	arcade.bodija@acesupermarket.com	$2a$10$ElkYaw5rar.b92GC6Fp/oeuyQmYleDeQMPhpaO4ngs5HFdlTnSRwS	Miss Zainab Ibrahim	Female	1991-08-20	\N	+234-803-500-0011	\N	\N	ACE-ARC-002	d3d91c1f-2351-425c-a59e-d9d1e8924382	04368807-3180-43b1-927e-eab61dfb4a5b	\N	38f86af3-14b1-4fe4-a84f-d895e840b1d1	2022-04-05	340000.00	\N	\N	\N	t	f	\N	\N	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	branch
64c22400-eb47-46b1-93fb-11110d7121f1	arcade.akobo@acesupermarket.com	$2a$10$ElkYaw5rar.b92GC6Fp/oeuyQmYleDeQMPhpaO4ngs5HFdlTnSRwS	Mr. Biodun Alabi	Male	1989-11-28	\N	+234-803-500-0012	\N	\N	ACE-ARC-003	d3d91c1f-2351-425c-a59e-d9d1e8924382	04368807-3180-43b1-927e-eab61dfb4a5b	\N	8b67a276-81d1-4950-88ee-47b7077c0bf2	2022-06-18	340000.00	\N	\N	\N	t	f	\N	\N	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	branch
9d401424-6da4-4e9a-8568-00174cd56050	casino.abeokuta@acesupermarket.com	$2a$10$ElkYaw5rar.b92GC6Fp/oeuyQmYleDeQMPhpaO4ngs5HFdlTnSRwS	Mr. Chidi Okonkwo	Male	1987-03-22	\N	+234-803-500-0013	\N	\N	ACE-CAS-001	4aff4bf4-bd45-4b82-90bd-7d34245b43ed	04368807-3180-43b1-927e-eab61dfb4a5b	83100a44-ccde-4cda-a0e7-eee3ec08142c	511a5f95-209d-4b8d-b795-990079b07e1e	2022-03-10	360000.00	\N	\N	\N	t	f	\N	\N	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	branch
f1361a2d-c534-4cfd-81a0-796ed17b4339	ceo@acesupermarket.com	$2a$10$ElkYaw5rar.b92GC6Fp/oeuyQmYleDeQMPhpaO4ngs5HFdlTnSRwS	Chief Adebayo Williams	Male	1975-03-15	\N	+234-803-100-0001	\N	\N	ACE-CEO-001	e92cb940-73d7-4a0d-8a75-13c53f4f25f5	\N	\N	\N	2020-01-01	15000000.00	\N	\N	\N	t	f	\N	\N	2025-12-06 12:17:14.417474	2025-12-09 19:40:59.787226	2025-12-15 14:21:31.426222	https://res.cloudinary.com/desk7uuna/image/upload/v1765305657/staff_documents/profile_picture/ykzc20jdziy2id3fjazh.jpg	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	branch
a04f5bc7-2636-4358-aae3-dc3e1c9968e3	hr@acesupermarket.com	$2a$10$ElkYaw5rar.b92GC6Fp/oeuyQmYleDeQMPhpaO4ngs5HFdlTnSRwS	Mr. Chukwuma Nwosu	Male	1982-05-10	\N	+234-803-100-0003	\N	\N	ACE-HR-001	ccf26bf4-6062-499f-8329-3ddf4ce9bfa3	\N	\N	\N	2020-02-01	800000.00	\N	\N	\N	t	f	\N	\N	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474	2025-12-17 10:32:09.177451	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	branch
00feec4b-e498-452b-b081-cf480e16aec2	auditor@acesupermarket.com	$2a$10$ElkYaw5rar.b92GC6Fp/oeuyQmYleDeQMPhpaO4ngs5HFdlTnSRwS	Mr. Tunde Bakare	Male	1980-09-12	\N	+234-803-100-0005	\N	\N	ACE-AUD-001	2b3c0f9b-60a2-49d0-9220-5c5675d22710	\N	\N	\N	2020-03-01	700000.00	\N	\N	\N	t	f	\N	\N	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474	2025-12-15 14:09:13.305015	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	branch
02762b1e-9b2f-4bfe-943c-d6c28827ef96	coo@acesupermarket.com	$2a$10$ElkYaw5rar.b92GC6Fp/oeuyQmYleDeQMPhpaO4ngs5HFdlTnSRwS	Mrs. Folake Okonkwo	Female	1978-07-22	\N	+234-803-100-0002	\N	\N	ACE-COO-001	6bcae336-343e-4b29-8934-738e7f238e0a	\N	\N	\N	2020-01-01	12000000.00	\N	\N	\N	t	f	\N	\N	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	branch
86407ed7-40bf-4420-9053-f64c6121188e	hr2@acesupermarket.com	$2a$10$ElkYaw5rar.b92GC6Fp/oeuyQmYleDeQMPhpaO4ngs5HFdlTnSRwS	Miss Aisha Mohammed	Female	1990-11-18	\N	+234-803-100-0004	\N	\N	ACE-HR-002	ccf26bf4-6062-499f-8329-3ddf4ce9bfa3	\N	\N	\N	2021-03-15	750000.00	\N	\N	\N	t	f	\N	\N	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	branch
22d26f27-6768-43ec-b08e-4b20b924b76f	auditor2@acesupermarket.com	$2a$10$ElkYaw5rar.b92GC6Fp/oeuyQmYleDeQMPhpaO4ngs5HFdlTnSRwS	Mrs. Ngozi Okafor	Female	1983-06-20	\N	+234-803-100-0006	\N	\N	ACE-AUD-002	2b3c0f9b-60a2-49d0-9220-5c5675d22710	\N	\N	\N	2020-04-01	680000.00	\N	\N	\N	t	f	\N	\N	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	branch
c2b365e0-5404-4d85-b9e1-515e0cd9afe9	chairman@acesupermarket.com	$2a$10$ElkYaw5rar.b92GC6Fp/oeuyQmYleDeQMPhpaO4ngs5HFdlTnSRwS	Chief Akinwale Adeyemi	Male	1965-12-05	\N	+234-803-100-0007	\N	\N	ACE-CHR-001	\N	\N	\N	\N	2019-01-01	20000000.00	\N	\N	\N	t	f	\N	\N	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	branch
aefab581-f8c3-42a0-b79a-55d0270f3d00	casino.akobo@acesupermarket.com	$2a$10$ElkYaw5rar.b92GC6Fp/oeuyQmYleDeQMPhpaO4ngs5HFdlTnSRwS	Mr. Lanre Adebisi	Male	1990-09-12	\N	+234-803-500-0015	\N	\N	ACE-CAS-003	4aff4bf4-bd45-4b82-90bd-7d34245b43ed	04368807-3180-43b1-927e-eab61dfb4a5b	83100a44-ccde-4cda-a0e7-eee3ec08142c	8b67a276-81d1-4950-88ee-47b7077c0bf2	2022-07-30	360000.00	\N	\N	\N	t	f	\N	\N	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	branch
5be8065b-44d4-4fab-aa82-b64bda2b368a	cashier.abeokuta2@acesupermarket.com	$2a$10$ElkYaw5rar.b92GC6Fp/oeuyQmYleDeQMPhpaO4ngs5HFdlTnSRwS	Miss Funmi Oladele	Female	1995-03-02	\N	+234-803-400-0002	\N	\N	ACE-CASH-002	d4de53c5-3099-4cd3-88fa-758c04ef083f	160511a1-5b4f-4af9-bdc7-1764adbe6142	\N	511a5f95-209d-4b8d-b795-990079b07e1e	2023-01-11	120000.00	\N	\N	\N	t	f	\N	\N	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	branch
d9df9370-0442-4365-9ed0-3b59afc81ec1	cashier.bodija1@acesupermarket.com	$2a$10$ElkYaw5rar.b92GC6Fp/oeuyQmYleDeQMPhpaO4ngs5HFdlTnSRwS	Mr. Biodun Alabi	Male	1995-05-31	\N	+234-803-400-0005	\N	\N	ACE-CASH-005	d4de53c5-3099-4cd3-88fa-758c04ef083f	160511a1-5b4f-4af9-bdc7-1764adbe6142	\N	38f86af3-14b1-4fe4-a84f-d895e840b1d1	2023-01-26	120000.00	\N	\N	\N	t	f	\N	\N	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	branch
9c77950e-3ebc-4846-aed1-2faae86cbb37	cashier.bodija2@acesupermarket.com	$2a$10$ElkYaw5rar.b92GC6Fp/oeuyQmYleDeQMPhpaO4ngs5HFdlTnSRwS	Miss Funmi Oladele	Female	1995-06-30	\N	+234-803-400-0006	\N	\N	ACE-CASH-006	d4de53c5-3099-4cd3-88fa-758c04ef083f	160511a1-5b4f-4af9-bdc7-1764adbe6142	\N	38f86af3-14b1-4fe4-a84f-d895e840b1d1	2023-01-31	120000.00	\N	\N	\N	t	f	\N	\N	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	branch
66024a16-884c-408e-bead-dd134927a58a	cashier.ife1@acesupermarket.com	$2a$10$ElkYaw5rar.b92GC6Fp/oeuyQmYleDeQMPhpaO4ngs5HFdlTnSRwS	Mr. Tunde Ogunleye	Male	1995-07-30	\N	+234-803-400-0007	\N	\N	ACE-CASH-007	d4de53c5-3099-4cd3-88fa-758c04ef083f	160511a1-5b4f-4af9-bdc7-1764adbe6142	\N	70777e0c-f350-4f3b-9013-5e8691a96d8c	2023-02-05	120000.00	\N	\N	\N	t	f	\N	\N	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	branch
c6fa2131-7fea-459e-9df8-2ff37f1a39bb	cashier.ife2@acesupermarket.com	$2a$10$ElkYaw5rar.b92GC6Fp/oeuyQmYleDeQMPhpaO4ngs5HFdlTnSRwS	Miss Bisi Adebayo	Female	1995-08-29	\N	+234-803-400-0008	\N	\N	ACE-CASH-008	d4de53c5-3099-4cd3-88fa-758c04ef083f	160511a1-5b4f-4af9-bdc7-1764adbe6142	\N	70777e0c-f350-4f3b-9013-5e8691a96d8c	2023-02-10	120000.00	\N	\N	\N	t	f	\N	\N	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	branch
694655b7-cfa9-418e-9f29-1753df0adbfd	cashier.ijebu1@acesupermarket.com	$2a$10$ElkYaw5rar.b92GC6Fp/oeuyQmYleDeQMPhpaO4ngs5HFdlTnSRwS	Mr. Biodun Alabi	Male	1995-09-28	\N	+234-803-400-0009	\N	\N	ACE-CASH-009	d4de53c5-3099-4cd3-88fa-758c04ef083f	160511a1-5b4f-4af9-bdc7-1764adbe6142	\N	9d23f80a-749e-4d59-a26d-85e16a388846	2023-02-15	120000.00	\N	\N	\N	t	f	\N	\N	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	branch
c84d7da8-2f5e-4123-85c5-989ba74e3520	cashier.ijebu2@acesupermarket.com	$2a$10$ElkYaw5rar.b92GC6Fp/oeuyQmYleDeQMPhpaO4ngs5HFdlTnSRwS	Miss Funmi Oladele	Female	1995-10-28	\N	+234-803-400-0010	\N	\N	ACE-CASH-010	d4de53c5-3099-4cd3-88fa-758c04ef083f	160511a1-5b4f-4af9-bdc7-1764adbe6142	\N	9d23f80a-749e-4d59-a26d-85e16a388846	2023-02-20	120000.00	\N	\N	\N	t	f	\N	\N	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	branch
c58f03b5-12e4-45c5-b71d-21ffeb6b0c40	cashier.ilorin1@acesupermarket.com	$2a$10$ElkYaw5rar.b92GC6Fp/oeuyQmYleDeQMPhpaO4ngs5HFdlTnSRwS	Mr. Tunde Ogunleye	Male	1995-11-27	\N	+234-803-400-0011	\N	\N	ACE-CASH-011	d4de53c5-3099-4cd3-88fa-758c04ef083f	160511a1-5b4f-4af9-bdc7-1764adbe6142	\N	1bc5af13-0b28-422e-bf26-df270e0a4089	2023-02-25	120000.00	\N	\N	\N	t	f	\N	\N	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	branch
905773e4-02be-4a57-9046-7bd29db1fa03	cashier.ilorin2@acesupermarket.com	$2a$10$ElkYaw5rar.b92GC6Fp/oeuyQmYleDeQMPhpaO4ngs5HFdlTnSRwS	Miss Bisi Adebayo	Female	1995-12-27	\N	+234-803-400-0012	\N	\N	ACE-CASH-012	d4de53c5-3099-4cd3-88fa-758c04ef083f	160511a1-5b4f-4af9-bdc7-1764adbe6142	\N	1bc5af13-0b28-422e-bf26-df270e0a4089	2023-03-02	120000.00	\N	\N	\N	t	f	\N	\N	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	branch
243a4471-81e9-469e-ae44-7685b225e07b	cashier.iseyin1@acesupermarket.com	$2a$10$ElkYaw5rar.b92GC6Fp/oeuyQmYleDeQMPhpaO4ngs5HFdlTnSRwS	Mr. Biodun Alabi	Male	1996-01-26	\N	+234-803-400-0013	\N	\N	ACE-CASH-013	d4de53c5-3099-4cd3-88fa-758c04ef083f	160511a1-5b4f-4af9-bdc7-1764adbe6142	\N	ff3a7fa2-ee3e-484c-ac9b-548b6b9a6eda	2023-03-07	120000.00	\N	\N	\N	t	f	\N	\N	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	branch
afb04864-9ab2-4994-918c-397a2a035d84	cashier.iseyin2@acesupermarket.com	$2a$10$ElkYaw5rar.b92GC6Fp/oeuyQmYleDeQMPhpaO4ngs5HFdlTnSRwS	Miss Funmi Oladele	Female	1996-02-25	\N	+234-803-400-0014	\N	\N	ACE-CASH-014	d4de53c5-3099-4cd3-88fa-758c04ef083f	160511a1-5b4f-4af9-bdc7-1764adbe6142	\N	ff3a7fa2-ee3e-484c-ac9b-548b6b9a6eda	2023-03-12	120000.00	\N	\N	\N	t	f	\N	\N	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	branch
5c39ac09-558d-4836-9bb6-f1de81d58f9d	cashier.ogbomosho1@acesupermarket.com	$2a$10$ElkYaw5rar.b92GC6Fp/oeuyQmYleDeQMPhpaO4ngs5HFdlTnSRwS	Mr. Tunde Ogunleye	Male	1996-03-26	\N	+234-803-400-0015	\N	\N	ACE-CASH-015	d4de53c5-3099-4cd3-88fa-758c04ef083f	160511a1-5b4f-4af9-bdc7-1764adbe6142	\N	001a6790-0f59-4776-aee9-cb1928290ec9	2023-03-17	120000.00	\N	\N	\N	t	f	\N	\N	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	branch
3f324c9c-7c0d-4dbc-8c49-cd943f36fc27	cashier.ogbomosho2@acesupermarket.com	$2a$10$ElkYaw5rar.b92GC6Fp/oeuyQmYleDeQMPhpaO4ngs5HFdlTnSRwS	Miss Bisi Adebayo	Female	1996-04-25	\N	+234-803-400-0016	\N	\N	ACE-CASH-016	d4de53c5-3099-4cd3-88fa-758c04ef083f	160511a1-5b4f-4af9-bdc7-1764adbe6142	\N	001a6790-0f59-4776-aee9-cb1928290ec9	2023-03-22	120000.00	\N	\N	\N	t	f	\N	\N	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	branch
2a643039-c6a0-4791-b022-07b0fbfddd3a	cashier.oluyole1@acesupermarket.com	$2a$10$ElkYaw5rar.b92GC6Fp/oeuyQmYleDeQMPhpaO4ngs5HFdlTnSRwS	Mr. Biodun Alabi	Male	1996-05-25	\N	+234-803-400-0017	\N	\N	ACE-CASH-017	d4de53c5-3099-4cd3-88fa-758c04ef083f	160511a1-5b4f-4af9-bdc7-1764adbe6142	\N	d735da13-cff9-4009-a6dd-4ad59fc9f72b	2023-03-27	120000.00	\N	\N	\N	t	f	\N	\N	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	branch
020e710e-e419-4c74-9848-3b00770353c6	cashier.oluyole2@acesupermarket.com	$2a$10$ElkYaw5rar.b92GC6Fp/oeuyQmYleDeQMPhpaO4ngs5HFdlTnSRwS	Miss Funmi Oladele	Female	1996-06-24	\N	+234-803-400-0018	\N	\N	ACE-CASH-018	d4de53c5-3099-4cd3-88fa-758c04ef083f	160511a1-5b4f-4af9-bdc7-1764adbe6142	\N	d735da13-cff9-4009-a6dd-4ad59fc9f72b	2023-04-01	120000.00	\N	\N	\N	t	f	\N	\N	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	branch
f4d858f5-58b1-4727-96d5-5b27be00ebbe	cashier.osogbo1@acesupermarket.com	$2a$10$ElkYaw5rar.b92GC6Fp/oeuyQmYleDeQMPhpaO4ngs5HFdlTnSRwS	Mr. Tunde Ogunleye	Male	1996-07-24	\N	+234-803-400-0019	\N	\N	ACE-CASH-019	d4de53c5-3099-4cd3-88fa-758c04ef083f	160511a1-5b4f-4af9-bdc7-1764adbe6142	\N	2af15e5d-b67a-493f-8357-feaec629a69a	2023-04-06	120000.00	\N	\N	\N	t	f	\N	\N	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	branch
1ca1e403-5ac5-495e-86b5-0e60c397393b	cashier.osogbo2@acesupermarket.com	$2a$10$ElkYaw5rar.b92GC6Fp/oeuyQmYleDeQMPhpaO4ngs5HFdlTnSRwS	Miss Bisi Adebayo	Female	1996-08-23	\N	+234-803-400-0020	\N	\N	ACE-CASH-020	d4de53c5-3099-4cd3-88fa-758c04ef083f	160511a1-5b4f-4af9-bdc7-1764adbe6142	\N	2af15e5d-b67a-493f-8357-feaec629a69a	2023-04-11	120000.00	\N	\N	\N	t	f	\N	\N	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	branch
9b36ebb6-1b40-4fa5-8fad-736b04b5b4ea	cashier.oyo1@acesupermarket.com	$2a$10$ElkYaw5rar.b92GC6Fp/oeuyQmYleDeQMPhpaO4ngs5HFdlTnSRwS	Mr. Biodun Alabi	Male	1996-09-22	\N	+234-803-400-0021	\N	\N	ACE-CASH-021	d4de53c5-3099-4cd3-88fa-758c04ef083f	160511a1-5b4f-4af9-bdc7-1764adbe6142	\N	394d14df-75fd-41e0-847d-cd2f08c5b1af	2023-04-16	120000.00	\N	\N	\N	t	f	\N	\N	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	branch
03613595-b764-4cb5-9d23-ebb2055a9fe1	cashier.oyo2@acesupermarket.com	$2a$10$ElkYaw5rar.b92GC6Fp/oeuyQmYleDeQMPhpaO4ngs5HFdlTnSRwS	Miss Funmi Oladele	Female	1996-10-22	\N	+234-803-400-0022	\N	\N	ACE-CASH-022	d4de53c5-3099-4cd3-88fa-758c04ef083f	160511a1-5b4f-4af9-bdc7-1764adbe6142	\N	394d14df-75fd-41e0-847d-cd2f08c5b1af	2023-04-21	120000.00	\N	\N	\N	t	f	\N	\N	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	branch
59775d98-8c8e-4a7b-99ed-11920c2bd80b	cashier.sagamu1@acesupermarket.com	$2a$10$ElkYaw5rar.b92GC6Fp/oeuyQmYleDeQMPhpaO4ngs5HFdlTnSRwS	Mr. Tunde Ogunleye	Male	1996-11-21	\N	+234-803-400-0023	\N	\N	ACE-CASH-023	d4de53c5-3099-4cd3-88fa-758c04ef083f	160511a1-5b4f-4af9-bdc7-1764adbe6142	\N	1aa3b0e6-af63-4ae1-b371-90e88880f8f1	2023-04-26	120000.00	\N	\N	\N	t	f	\N	\N	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	branch
b6ac4b5c-2caf-4bd6-83e9-ae3d7df27970	cashier.sagamu2@acesupermarket.com	$2a$10$ElkYaw5rar.b92GC6Fp/oeuyQmYleDeQMPhpaO4ngs5HFdlTnSRwS	Miss Bisi Adebayo	Female	1996-12-21	\N	+234-803-400-0024	\N	\N	ACE-CASH-024	d4de53c5-3099-4cd3-88fa-758c04ef083f	160511a1-5b4f-4af9-bdc7-1764adbe6142	\N	1aa3b0e6-af63-4ae1-b371-90e88880f8f1	2023-05-01	120000.00	\N	\N	\N	t	f	\N	\N	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	branch
5738ce10-3634-42f7-91d7-91f21cfb64f3	cashier.saki1@acesupermarket.com	$2a$10$ElkYaw5rar.b92GC6Fp/oeuyQmYleDeQMPhpaO4ngs5HFdlTnSRwS	Mr. Biodun Alabi	Male	1997-01-20	\N	+234-803-400-0025	\N	\N	ACE-CASH-025	d4de53c5-3099-4cd3-88fa-758c04ef083f	160511a1-5b4f-4af9-bdc7-1764adbe6142	\N	96423273-2c53-4067-8481-1e7ac885e3ac	2023-05-06	120000.00	\N	\N	\N	t	f	\N	\N	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	branch
a4f64b75-1bbe-4fb1-80d5-f441b6b9bee2	cashier.saki2@acesupermarket.com	$2a$10$ElkYaw5rar.b92GC6Fp/oeuyQmYleDeQMPhpaO4ngs5HFdlTnSRwS	Miss Funmi Oladele	Female	1997-02-19	\N	+234-803-400-0026	\N	\N	ACE-CASH-026	d4de53c5-3099-4cd3-88fa-758c04ef083f	160511a1-5b4f-4af9-bdc7-1764adbe6142	\N	96423273-2c53-4067-8481-1e7ac885e3ac	2023-05-11	120000.00	\N	\N	\N	t	f	\N	\N	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	branch
8ecec133-b13f-4d69-91f0-21ac9f930ca6	cashier.abeokuta1@acesupermarket.com	$2a$10$ElkYaw5rar.b92GC6Fp/oeuyQmYleDeQMPhpaO4ngs5HFdlTnSRwS	Mr. Biodun Alabi	Male	1995-01-31	\N	+234-803-400-0001	\N	\N	ACE-CASH-001	d4de53c5-3099-4cd3-88fa-758c04ef083f	160511a1-5b4f-4af9-bdc7-1764adbe6142	\N	511a5f95-209d-4b8d-b795-990079b07e1e	2023-01-06	120000.00	\N	\N	\N	t	f	\N	\N	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474	2025-12-15 22:07:13.403275	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	branch
9a2b27aa-e90a-4409-8373-2be363ee206e	cashier.akobo1@acesupermarket.com	$2a$10$ElkYaw5rar.b92GC6Fp/oeuyQmYleDeQMPhpaO4ngs5HFdlTnSRwS	Mr. Tunde Ogunleye	Male	1995-04-01	\N	+234-803-400-0003	\N	\N	ACE-CASH-003	d4de53c5-3099-4cd3-88fa-758c04ef083f	160511a1-5b4f-4af9-bdc7-1764adbe6142	\N	8b67a276-81d1-4950-88ee-47b7077c0bf2	2023-01-16	120000.00	\N	\N	\N	t	f	\N	\N	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474	2025-12-15 13:42:02.67698	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	branch
34d7356b-9cea-4a80-a7be-93d7def7d260	waiter.abeokuta1@acesupermarket.com	$2a$10$ElkYaw5rar.b92GC6Fp/oeuyQmYleDeQMPhpaO4ngs5HFdlTnSRwS	Mr. Segun Afolabi	Male	1996-01-26	\N	+234-803-500-0001	\N	\N	ACE-WAIT-001	20b9e282-3ed8-4297-92ed-aef0391fcd76	3be6b055-b126-4fdf-88a8-152634a678ea	\N	511a5f95-209d-4b8d-b795-990079b07e1e	2023-02-06	100000.00	\N	\N	\N	t	f	\N	\N	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	branch
489473cf-735a-4831-ac2a-f94ce58afca4	waiter.akobo1@acesupermarket.com	$2a$10$ElkYaw5rar.b92GC6Fp/oeuyQmYleDeQMPhpaO4ngs5HFdlTnSRwS	Mr. Segun Afolabi	Male	1996-03-16	\N	+234-803-500-0003	\N	\N	ACE-WAIT-003	20b9e282-3ed8-4297-92ed-aef0391fcd76	3be6b055-b126-4fdf-88a8-152634a678ea	\N	8b67a276-81d1-4950-88ee-47b7077c0bf2	2023-02-16	100000.00	\N	\N	\N	t	f	\N	\N	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	branch
412e9a12-7529-4bc7-85c7-f88df5e191d1	waiter.akobo2@acesupermarket.com	$2a$10$ElkYaw5rar.b92GC6Fp/oeuyQmYleDeQMPhpaO4ngs5HFdlTnSRwS	Miss Kemi Adeniyi	Female	1996-04-10	\N	+234-803-500-0004	\N	\N	ACE-WAIT-004	20b9e282-3ed8-4297-92ed-aef0391fcd76	3be6b055-b126-4fdf-88a8-152634a678ea	\N	8b67a276-81d1-4950-88ee-47b7077c0bf2	2023-02-21	100000.00	\N	\N	\N	t	f	\N	\N	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	branch
c492c079-7db5-4261-9983-2492048902eb	waiter.bodija1@acesupermarket.com	$2a$10$ElkYaw5rar.b92GC6Fp/oeuyQmYleDeQMPhpaO4ngs5HFdlTnSRwS	Mr. Segun Afolabi	Male	1996-05-05	\N	+234-803-500-0005	\N	\N	ACE-WAIT-005	20b9e282-3ed8-4297-92ed-aef0391fcd76	3be6b055-b126-4fdf-88a8-152634a678ea	\N	38f86af3-14b1-4fe4-a84f-d895e840b1d1	2023-02-26	100000.00	\N	\N	\N	t	f	\N	\N	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	branch
aecbb92c-bbe9-4a05-9dc2-a1f290e41deb	waiter.bodija2@acesupermarket.com	$2a$10$ElkYaw5rar.b92GC6Fp/oeuyQmYleDeQMPhpaO4ngs5HFdlTnSRwS	Miss Kemi Adeniyi	Female	1996-05-30	\N	+234-803-500-0006	\N	\N	ACE-WAIT-006	20b9e282-3ed8-4297-92ed-aef0391fcd76	3be6b055-b126-4fdf-88a8-152634a678ea	\N	38f86af3-14b1-4fe4-a84f-d895e840b1d1	2023-03-03	100000.00	\N	\N	\N	t	f	\N	\N	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	branch
fac4c4eb-47c1-4552-9e92-3f24ca63a922	waiter.ife2@acesupermarket.com	$2a$10$ElkYaw5rar.b92GC6Fp/oeuyQmYleDeQMPhpaO4ngs5HFdlTnSRwS	Miss Kemi Adeniyi	Female	1996-07-19	\N	+234-803-500-0008	\N	\N	ACE-WAIT-008	20b9e282-3ed8-4297-92ed-aef0391fcd76	3be6b055-b126-4fdf-88a8-152634a678ea	\N	70777e0c-f350-4f3b-9013-5e8691a96d8c	2023-03-13	100000.00	\N	\N	\N	t	f	\N	\N	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	branch
552e83ca-0eaa-4d94-87aa-9c4958aa811e	waiter.ijebu1@acesupermarket.com	$2a$10$ElkYaw5rar.b92GC6Fp/oeuyQmYleDeQMPhpaO4ngs5HFdlTnSRwS	Mr. Segun Afolabi	Male	1996-08-13	\N	+234-803-500-0009	\N	\N	ACE-WAIT-009	20b9e282-3ed8-4297-92ed-aef0391fcd76	3be6b055-b126-4fdf-88a8-152634a678ea	\N	9d23f80a-749e-4d59-a26d-85e16a388846	2023-03-18	100000.00	\N	\N	\N	t	f	\N	\N	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	branch
544e6fb5-b91e-43be-89f6-90546a7f0669	waiter.ijebu2@acesupermarket.com	$2a$10$ElkYaw5rar.b92GC6Fp/oeuyQmYleDeQMPhpaO4ngs5HFdlTnSRwS	Miss Kemi Adeniyi	Female	1996-09-07	\N	+234-803-500-0010	\N	\N	ACE-WAIT-010	20b9e282-3ed8-4297-92ed-aef0391fcd76	3be6b055-b126-4fdf-88a8-152634a678ea	\N	9d23f80a-749e-4d59-a26d-85e16a388846	2023-03-23	100000.00	\N	\N	\N	t	f	\N	\N	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	branch
e001d25d-7ef8-44c7-8213-2777aa595970	waiter.ilorin1@acesupermarket.com	$2a$10$ElkYaw5rar.b92GC6Fp/oeuyQmYleDeQMPhpaO4ngs5HFdlTnSRwS	Mr. Segun Afolabi	Male	1996-10-02	\N	+234-803-500-0011	\N	\N	ACE-WAIT-011	20b9e282-3ed8-4297-92ed-aef0391fcd76	3be6b055-b126-4fdf-88a8-152634a678ea	\N	1bc5af13-0b28-422e-bf26-df270e0a4089	2023-03-28	100000.00	\N	\N	\N	t	f	\N	\N	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	branch
1d71f3e9-7f85-49b8-a65e-b9c819ad19cb	waiter.ilorin2@acesupermarket.com	$2a$10$ElkYaw5rar.b92GC6Fp/oeuyQmYleDeQMPhpaO4ngs5HFdlTnSRwS	Miss Kemi Adeniyi	Female	1996-10-27	\N	+234-803-500-0012	\N	\N	ACE-WAIT-012	20b9e282-3ed8-4297-92ed-aef0391fcd76	3be6b055-b126-4fdf-88a8-152634a678ea	\N	1bc5af13-0b28-422e-bf26-df270e0a4089	2023-04-02	100000.00	\N	\N	\N	t	f	\N	\N	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	branch
1ebbf9f9-6184-4687-a5cf-a5b7c6d11717	waiter.iseyin1@acesupermarket.com	$2a$10$ElkYaw5rar.b92GC6Fp/oeuyQmYleDeQMPhpaO4ngs5HFdlTnSRwS	Mr. Segun Afolabi	Male	1996-11-21	\N	+234-803-500-0013	\N	\N	ACE-WAIT-013	20b9e282-3ed8-4297-92ed-aef0391fcd76	3be6b055-b126-4fdf-88a8-152634a678ea	\N	ff3a7fa2-ee3e-484c-ac9b-548b6b9a6eda	2023-04-07	100000.00	\N	\N	\N	t	f	\N	\N	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	branch
c848bf8a-43a8-4d05-94cc-9d5033405cd7	waiter.iseyin2@acesupermarket.com	$2a$10$ElkYaw5rar.b92GC6Fp/oeuyQmYleDeQMPhpaO4ngs5HFdlTnSRwS	Miss Kemi Adeniyi	Female	1996-12-16	\N	+234-803-500-0014	\N	\N	ACE-WAIT-014	20b9e282-3ed8-4297-92ed-aef0391fcd76	3be6b055-b126-4fdf-88a8-152634a678ea	\N	ff3a7fa2-ee3e-484c-ac9b-548b6b9a6eda	2023-04-12	100000.00	\N	\N	\N	t	f	\N	\N	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	branch
0919939d-1f4b-485c-b66e-1c24d710930d	waiter.ogbomosho1@acesupermarket.com	$2a$10$ElkYaw5rar.b92GC6Fp/oeuyQmYleDeQMPhpaO4ngs5HFdlTnSRwS	Mr. Segun Afolabi	Male	1997-01-10	\N	+234-803-500-0015	\N	\N	ACE-WAIT-015	20b9e282-3ed8-4297-92ed-aef0391fcd76	3be6b055-b126-4fdf-88a8-152634a678ea	\N	001a6790-0f59-4776-aee9-cb1928290ec9	2023-04-17	100000.00	\N	\N	\N	t	f	\N	\N	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	branch
8c59a07a-41dc-4d55-b55b-f82800569e9c	waiter.ogbomosho2@acesupermarket.com	$2a$10$ElkYaw5rar.b92GC6Fp/oeuyQmYleDeQMPhpaO4ngs5HFdlTnSRwS	Miss Kemi Adeniyi	Female	1997-02-04	\N	+234-803-500-0016	\N	\N	ACE-WAIT-016	20b9e282-3ed8-4297-92ed-aef0391fcd76	3be6b055-b126-4fdf-88a8-152634a678ea	\N	001a6790-0f59-4776-aee9-cb1928290ec9	2023-04-22	100000.00	\N	\N	\N	t	f	\N	\N	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	branch
6392ac81-e8b5-4b27-a2dc-b0a34a449659	waiter.oluyole1@acesupermarket.com	$2a$10$ElkYaw5rar.b92GC6Fp/oeuyQmYleDeQMPhpaO4ngs5HFdlTnSRwS	Mr. Segun Afolabi	Male	1997-03-01	\N	+234-803-500-0017	\N	\N	ACE-WAIT-017	20b9e282-3ed8-4297-92ed-aef0391fcd76	3be6b055-b126-4fdf-88a8-152634a678ea	\N	d735da13-cff9-4009-a6dd-4ad59fc9f72b	2023-04-27	100000.00	\N	\N	\N	t	f	\N	\N	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	branch
b45f33f6-4f98-4d00-af3d-6bae657c2deb	waiter.oluyole2@acesupermarket.com	$2a$10$ElkYaw5rar.b92GC6Fp/oeuyQmYleDeQMPhpaO4ngs5HFdlTnSRwS	Miss Kemi Adeniyi	Female	1997-03-26	\N	+234-803-500-0018	\N	\N	ACE-WAIT-018	20b9e282-3ed8-4297-92ed-aef0391fcd76	3be6b055-b126-4fdf-88a8-152634a678ea	\N	d735da13-cff9-4009-a6dd-4ad59fc9f72b	2023-05-02	100000.00	\N	\N	\N	t	f	\N	\N	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	branch
1e193b09-87bc-48c4-b666-94f910cf5882	waiter.osogbo1@acesupermarket.com	$2a$10$ElkYaw5rar.b92GC6Fp/oeuyQmYleDeQMPhpaO4ngs5HFdlTnSRwS	Mr. Segun Afolabi	Male	1997-04-20	\N	+234-803-500-0019	\N	\N	ACE-WAIT-019	20b9e282-3ed8-4297-92ed-aef0391fcd76	3be6b055-b126-4fdf-88a8-152634a678ea	\N	2af15e5d-b67a-493f-8357-feaec629a69a	2023-05-07	100000.00	\N	\N	\N	t	f	\N	\N	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	branch
cebe720e-d2f1-4b0e-9107-4da7b543fe4b	waiter.osogbo2@acesupermarket.com	$2a$10$ElkYaw5rar.b92GC6Fp/oeuyQmYleDeQMPhpaO4ngs5HFdlTnSRwS	Miss Kemi Adeniyi	Female	1997-05-15	\N	+234-803-500-0020	\N	\N	ACE-WAIT-020	20b9e282-3ed8-4297-92ed-aef0391fcd76	3be6b055-b126-4fdf-88a8-152634a678ea	\N	2af15e5d-b67a-493f-8357-feaec629a69a	2023-05-12	100000.00	\N	\N	\N	t	f	\N	\N	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	branch
1a6bdfd6-888d-44f7-8f49-eaa05b8af956	waiter.ife1@acesupermarket.com	$2a$10$ElkYaw5rar.b92GC6Fp/oeuyQmYleDeQMPhpaO4ngs5HFdlTnSRwS	Mr. Segun Afolabi	Male	1996-06-24	\N	+234-803-500-0007	\N	\N	ACE-WAIT-007	20b9e282-3ed8-4297-92ed-aef0391fcd76	3be6b055-b126-4fdf-88a8-152634a678ea	\N	70777e0c-f350-4f3b-9013-5e8691a96d8c	2023-03-08	100000.00	\N	\N	\N	f	f	\N	\N	2025-12-06 12:17:14.417474	2025-12-06 12:17:14.417474	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	branch
5eebb1da-4f4a-4422-9d3b-406c89f80c89	waiter.abeokuta2@acesupermarket.com	$2a$10$ElkYaw5rar.b92GC6Fp/oeuyQmYleDeQMPhpaO4ngs5HFdlTnSRwS	Miss Kemi Adeniyi	Female	1996-02-20	\N	+234-803-500-0002	\N	\N	ACE-WAIT-002	a30980e5-2d73-4423-889f-a7e1f2610004	3be6b055-b126-4fdf-88a8-152634a678ea	\N	511a5f95-209d-4b8d-b795-990079b07e1e	2023-02-11	1000000.00	\N	\N	\N	t	f	\N	\N	2025-12-06 12:17:14.417474	2025-12-15 10:15:05.716629	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	branch
\.


--
-- Data for Name: weekly_reviews; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.weekly_reviews (id, staff_id, reviewer_id, roster_id, week_start_date, week_end_date, rating, punctuality_rating, performance_rating, attitude_rating, comments, strengths, areas_for_improvement, created_at, updated_at) FROM stdin;
c85c2d6f-90e4-4f96-86c9-bbc33519ffa1	8ecec133-b13f-4d69-91f0-21ac9f930ca6	a7a5977d-c912-4476-b8c1-89d6a6dec0ee	\N	2024-12-02	2024-12-08	4	5	4	3	Good performance overall. Some areas need improvement.	Team collaboration, problem solving	Communication with colleagues	2025-12-13 23:55:11.169615	2025-12-13 23:55:11.169615
abb7596b-bdda-42af-aa22-e9d28f141713	5be8065b-44d4-4fab-aa82-b64bda2b368a	a7a5977d-c912-4476-b8c1-89d6a6dec0ee	\N	2024-12-02	2024-12-08	4	5	4	4	Consistent performer. Shows dedication to work.	Attention to detail, reliability	Communication with colleagues	2025-12-13 23:55:11.169615	2025-12-13 23:55:11.169615
c4e24260-ac9a-4513-88a0-9b330a188940	9a2b27aa-e90a-4409-8373-2be363ee206e	d2e4dc25-672a-485e-98b8-0126b3f10d28	\N	2024-12-02	2024-12-08	4	3	3	3	Meets expectations. Continue improving.	Attention to detail, reliability	Documentation and reporting	2025-12-13 23:55:11.169615	2025-12-13 23:55:11.169615
d8b92986-7faa-4924-8ea1-465d559ba284	9a2b27aa-e90a-4409-8373-2be363ee206e	e6bcd428-3711-4d17-80b4-5fab412563bd	\N	2024-12-02	2024-12-08	4	5	4	3	Good performance overall. Some areas need improvement.	Work ethic, positive attitude	Documentation and reporting	2025-12-13 23:55:11.169615	2025-12-13 23:55:11.169615
39f3c004-576b-4818-ad32-d3009d8f52f6	d9df9370-0442-4365-9ed0-3b59afc81ec1	091177fc-3b2c-4858-8ea0-b8f7206b4636	\N	2024-12-02	2024-12-08	3	4	5	3	Shows great initiative and teamwork.	Team collaboration, problem solving	Handling pressure situations	2025-12-13 23:55:11.169615	2025-12-13 23:55:11.169615
ab642456-263a-4787-8dc6-81f16d9b4789	9c77950e-3ebc-4846-aed1-2faae86cbb37	091177fc-3b2c-4858-8ea0-b8f7206b4636	\N	2024-12-02	2024-12-08	5	3	3	3	Consistent performer. Shows dedication to work.	Attention to detail, reliability	Communication with colleagues	2025-12-13 23:55:11.169615	2025-12-13 23:55:11.169615
c1fd3ecd-4193-4fa2-ab13-6e38f85770ac	66024a16-884c-408e-bead-dd134927a58a	7b63533f-02f3-4491-9808-64ad90a92334	\N	2024-12-02	2024-12-08	4	4	5	3	Meets expectations. Continue improving.	Attention to detail, reliability	Handling pressure situations	2025-12-13 23:55:11.169615	2025-12-13 23:55:11.169615
0f2940fc-bca3-47e0-9978-1b771c2f189b	c6fa2131-7fea-459e-9df8-2ff37f1a39bb	7b63533f-02f3-4491-9808-64ad90a92334	\N	2024-12-02	2024-12-08	5	3	5	5	Consistent performer. Shows dedication to work.	Work ethic, positive attitude	Time management	2025-12-13 23:55:11.169615	2025-12-13 23:55:11.169615
98ac24e8-4c7c-42f1-bc6a-ea9abb12d10b	694655b7-cfa9-418e-9f29-1753df0adbfd	a8f9ccad-6eef-45ea-b1d9-9b24ec7ab5a9	\N	2024-12-02	2024-12-08	5	3	4	4	Good performance overall. Some areas need improvement.	Customer service, punctuality	Handling pressure situations	2025-12-13 23:55:11.169615	2025-12-13 23:55:11.169615
b75e0d90-8fe1-4039-a7c4-b1ea2e31a92a	c84d7da8-2f5e-4123-85c5-989ba74e3520	a8f9ccad-6eef-45ea-b1d9-9b24ec7ab5a9	\N	2024-12-02	2024-12-08	5	5	4	5	Good performance overall. Some areas need improvement.	Attention to detail, reliability	Documentation and reporting	2025-12-13 23:55:11.169615	2025-12-13 23:55:11.169615
f4806338-107d-4e9c-b56b-e017acda5af2	c58f03b5-12e4-45c5-b71d-21ffeb6b0c40	1eab9750-4824-4de4-8168-04591fc249f7	\N	2024-12-02	2024-12-08	3	3	3	4	Excellent work this week. Keep it up!	Customer service, punctuality	Communication with colleagues	2025-12-13 23:55:11.169615	2025-12-13 23:55:11.169615
e9babdcf-99b0-4d2f-ac20-99b49b99d227	905773e4-02be-4a57-9046-7bd29db1fa03	1eab9750-4824-4de4-8168-04591fc249f7	\N	2024-12-02	2024-12-08	4	4	3	3	Good performance overall. Some areas need improvement.	Attention to detail, reliability	Communication with colleagues	2025-12-13 23:55:11.169615	2025-12-13 23:55:11.169615
2f6ead7d-0263-49f3-8bff-e8e747523d98	243a4471-81e9-469e-ae44-7685b225e07b	f8642d75-f69a-487d-b385-661ecf2fc8fc	\N	2024-12-02	2024-12-08	5	5	4	3	Excellent work this week. Keep it up!	Attention to detail, reliability	Handling pressure situations	2025-12-13 23:55:11.169615	2025-12-13 23:55:11.169615
16adcaa0-aa05-4678-9d9d-27bdddc5fdfe	afb04864-9ab2-4994-918c-397a2a035d84	f8642d75-f69a-487d-b385-661ecf2fc8fc	\N	2024-12-02	2024-12-08	3	3	4	4	Consistent performer. Shows dedication to work.	Communication skills, adaptability	Documentation and reporting	2025-12-13 23:55:11.169615	2025-12-13 23:55:11.169615
d9b008ac-4b10-4d6c-9997-04d4aa8cfcf4	5c39ac09-558d-4836-9bb6-f1de81d58f9d	a1ba9ca9-d129-47c4-b6ff-1d3a5fd1e27d	\N	2024-12-02	2024-12-08	3	3	3	5	Consistent performer. Shows dedication to work.	Communication skills, adaptability	Time management	2025-12-13 23:55:11.169615	2025-12-13 23:55:11.169615
f9eec560-e14f-40d5-981c-1901cac672d4	3f324c9c-7c0d-4dbc-8c49-cd943f36fc27	a1ba9ca9-d129-47c4-b6ff-1d3a5fd1e27d	\N	2024-12-02	2024-12-08	5	4	4	4	Good performance overall. Some areas need improvement.	Communication skills, adaptability	Taking initiative on tasks	2025-12-13 23:55:11.169615	2025-12-13 23:55:11.169615
022a4ed8-9f7e-44bb-9419-edaac46d4da8	2a643039-c6a0-4791-b022-07b0fbfddd3a	87e45cfe-99c0-46bf-8ea4-a53fb3c757b0	\N	2024-12-02	2024-12-08	4	4	5	3	Shows great initiative and teamwork.	Team collaboration, problem solving	Documentation and reporting	2025-12-13 23:55:11.169615	2025-12-13 23:55:11.169615
d61f6c35-306b-4bde-bd72-e720d5927249	020e710e-e419-4c74-9848-3b00770353c6	87e45cfe-99c0-46bf-8ea4-a53fb3c757b0	\N	2024-12-02	2024-12-08	3	3	4	3	Shows great initiative and teamwork.	Communication skills, adaptability	Time management	2025-12-13 23:55:11.169615	2025-12-13 23:55:11.169615
c1396aae-6729-4d7a-939e-1505b82dc16e	f4d858f5-58b1-4727-96d5-5b27be00ebbe	df4b5622-d10a-4be6-b3b9-ae9eb365621f	\N	2024-12-02	2024-12-08	5	3	5	4	Excellent work this week. Keep it up!	Attention to detail, reliability	Communication with colleagues	2025-12-13 23:55:11.169615	2025-12-13 23:55:11.169615
d5622629-8a64-4bf8-804f-b3854926dfae	1ca1e403-5ac5-495e-86b5-0e60c397393b	df4b5622-d10a-4be6-b3b9-ae9eb365621f	\N	2024-12-02	2024-12-08	4	5	5	4	Consistent performer. Shows dedication to work.	Communication skills, adaptability	Handling pressure situations	2025-12-13 23:55:11.169615	2025-12-13 23:55:11.169615
50e6d209-249a-49a5-98b5-979528fa615e	34d7356b-9cea-4a80-a7be-93d7def7d260	710974ab-52fc-4726-b50a-b309d5b7d9ba	\N	2024-12-02	2024-12-08	4	4	4	3	Shows great initiative and teamwork.	Team collaboration, problem solving	Handling pressure situations	2025-12-13 23:55:11.169615	2025-12-13 23:55:11.169615
db2f5227-6558-4259-af3a-86b269bb3811	5eebb1da-4f4a-4422-9d3b-406c89f80c89	710974ab-52fc-4726-b50a-b309d5b7d9ba	\N	2024-12-02	2024-12-08	5	5	4	5	Good performance overall. Some areas need improvement.	Communication skills, adaptability	Taking initiative on tasks	2025-12-13 23:55:11.169615	2025-12-13 23:55:11.169615
13536b17-098f-4e2f-ad33-b6819c6b5e78	489473cf-735a-4831-ac2a-f94ce58afca4	085df28e-fb49-420c-bea9-0432c9199f40	\N	2024-12-02	2024-12-08	3	3	4	4	Shows great initiative and teamwork.	Work ethic, positive attitude	Time management	2025-12-13 23:55:11.169615	2025-12-13 23:55:11.169615
27f922e5-0284-44f2-8592-442a14a3e6b6	412e9a12-7529-4bc7-85c7-f88df5e191d1	085df28e-fb49-420c-bea9-0432c9199f40	\N	2024-12-02	2024-12-08	4	4	3	5	Shows great initiative and teamwork.	Attention to detail, reliability	Handling pressure situations	2025-12-13 23:55:11.169615	2025-12-13 23:55:11.169615
c594f275-8a02-4f7f-a3f7-c551c874603e	c492c079-7db5-4261-9983-2492048902eb	81e8d990-cba5-41df-8c92-f74cdbc3a71a	\N	2024-12-02	2024-12-08	5	4	5	5	Shows great initiative and teamwork.	Team collaboration, problem solving	Taking initiative on tasks	2025-12-13 23:55:11.169615	2025-12-13 23:55:11.169615
897917fa-0f4f-4e5d-bb8e-0716a65e7c50	aecbb92c-bbe9-4a05-9dc2-a1f290e41deb	81e8d990-cba5-41df-8c92-f74cdbc3a71a	\N	2024-12-02	2024-12-08	4	4	5	3	Shows great initiative and teamwork.	Team collaboration, problem solving	Communication with colleagues	2025-12-13 23:55:11.169615	2025-12-13 23:55:11.169615
38af8c03-0b7e-4b14-a4ce-c86576d38d72	fac4c4eb-47c1-4552-9e92-3f24ca63a922	7ef2acf4-d876-4a29-b1f0-db8301f817a6	\N	2024-12-02	2024-12-08	3	4	3	4	Reliable team member. Good customer service.	Team collaboration, problem solving	Communication with colleagues	2025-12-13 23:55:11.169615	2025-12-13 23:55:11.169615
db605a0e-635c-4c37-9fd7-cc6609d423a5	552e83ca-0eaa-4d94-87aa-9c4958aa811e	d2940649-78f0-4418-88b4-7b16a9a7104f	\N	2024-12-02	2024-12-08	5	3	3	5	Reliable team member. Good customer service.	Communication skills, adaptability	Documentation and reporting	2025-12-13 23:55:11.169615	2025-12-13 23:55:11.169615
c35dbc70-540d-428e-abd2-00e16f81ecb4	544e6fb5-b91e-43be-89f6-90546a7f0669	d2940649-78f0-4418-88b4-7b16a9a7104f	\N	2024-12-02	2024-12-08	4	4	5	5	Reliable team member. Good customer service.	Team collaboration, problem solving	Time management	2025-12-13 23:55:11.169615	2025-12-13 23:55:11.169615
406a4310-4fa1-4626-a764-12a866f7d981	e001d25d-7ef8-44c7-8213-2777aa595970	b4801419-3838-4ac9-9c94-b05568dbf2b1	\N	2024-12-02	2024-12-08	4	4	4	3	Shows great initiative and teamwork.	Customer service, punctuality	Taking initiative on tasks	2025-12-13 23:55:11.169615	2025-12-13 23:55:11.169615
2b805070-4a19-472a-bf11-9063c9c38481	1d71f3e9-7f85-49b8-a65e-b9c819ad19cb	b4801419-3838-4ac9-9c94-b05568dbf2b1	\N	2024-12-02	2024-12-08	3	5	4	4	Consistent performer. Shows dedication to work.	Communication skills, adaptability	Communication with colleagues	2025-12-13 23:55:11.169615	2025-12-13 23:55:11.169615
e11ae965-ef94-496d-bad9-b89f6d9dac30	1ebbf9f9-6184-4687-a5cf-a5b7c6d11717	6315b233-5988-421f-9cb9-95a8b68e00ce	\N	2024-12-02	2024-12-08	3	4	3	4	Good performance overall. Some areas need improvement.	Communication skills, adaptability	Communication with colleagues	2025-12-13 23:55:11.169615	2025-12-13 23:55:11.169615
28dfe89a-48c7-4060-b554-73e05840f7e8	c848bf8a-43a8-4d05-94cc-9d5033405cd7	6315b233-5988-421f-9cb9-95a8b68e00ce	\N	2024-12-02	2024-12-08	4	4	3	4	Shows great initiative and teamwork.	Team collaboration, problem solving	Documentation and reporting	2025-12-13 23:55:11.169615	2025-12-13 23:55:11.169615
db1dae7d-9540-4cb8-9dbe-478b0dc1c7d8	0919939d-1f4b-485c-b66e-1c24d710930d	3b4d200d-8f2c-45c8-a3ae-2816d06f208c	\N	2024-12-02	2024-12-08	4	4	4	4	Shows great initiative and teamwork.	Communication skills, adaptability	Time management	2025-12-13 23:55:11.169615	2025-12-13 23:55:11.169615
9750f3ce-de2d-4cfb-bc37-f3d92b6a2218	8c59a07a-41dc-4d55-b55b-f82800569e9c	3b4d200d-8f2c-45c8-a3ae-2816d06f208c	\N	2024-12-02	2024-12-08	5	3	4	3	Excellent work this week. Keep it up!	Team collaboration, problem solving	Time management	2025-12-13 23:55:11.169615	2025-12-13 23:55:11.169615
09424cd4-af93-4384-a91f-d4ce77f8d14b	8ecec133-b13f-4d69-91f0-21ac9f930ca6	a7a5977d-c912-4476-b8c1-89d6a6dec0ee	\N	2024-12-09	2024-12-15	5	5	5	5	Good performance this week.	\N	\N	2025-12-13 23:55:30.476245	2025-12-13 23:55:30.476245
99496e13-056a-4213-a2b8-f935b6dd24d0	5be8065b-44d4-4fab-aa82-b64bda2b368a	a7a5977d-c912-4476-b8c1-89d6a6dec0ee	\N	2024-12-09	2024-12-15	4	4	4	4	Good performance this week.	\N	\N	2025-12-13 23:55:30.476245	2025-12-13 23:55:30.476245
20f37439-0326-4262-966d-211eebefb4d2	9a2b27aa-e90a-4409-8373-2be363ee206e	d2e4dc25-672a-485e-98b8-0126b3f10d28	\N	2024-12-09	2024-12-15	3	4	4	5	Good performance this week.	\N	\N	2025-12-13 23:55:30.476245	2025-12-13 23:55:30.476245
2964ebe0-e329-432a-8c6a-80bbc43a58bb	9a2b27aa-e90a-4409-8373-2be363ee206e	e6bcd428-3711-4d17-80b4-5fab412563bd	\N	2024-12-09	2024-12-15	4	5	3	5	Good performance this week.	\N	\N	2025-12-13 23:55:30.476245	2025-12-13 23:55:30.476245
98df15a6-cef5-4112-81d2-4f50a5449ac5	d9df9370-0442-4365-9ed0-3b59afc81ec1	091177fc-3b2c-4858-8ea0-b8f7206b4636	\N	2024-12-09	2024-12-15	4	4	4	4	Good performance this week.	\N	\N	2025-12-13 23:55:30.476245	2025-12-13 23:55:30.476245
014127fd-8d9e-4fac-9f9d-bcb5867aa4cb	9c77950e-3ebc-4846-aed1-2faae86cbb37	091177fc-3b2c-4858-8ea0-b8f7206b4636	\N	2024-12-09	2024-12-15	5	4	4	4	Good performance this week.	\N	\N	2025-12-13 23:55:30.476245	2025-12-13 23:55:30.476245
58379c96-d8c0-468b-b7c1-75fe534d77ab	66024a16-884c-408e-bead-dd134927a58a	7b63533f-02f3-4491-9808-64ad90a92334	\N	2024-12-09	2024-12-15	4	4	4	4	Good performance this week.	\N	\N	2025-12-13 23:55:30.476245	2025-12-13 23:55:30.476245
4b9a73c8-c558-4f7c-8f3d-79febcd66ba0	c6fa2131-7fea-459e-9df8-2ff37f1a39bb	7b63533f-02f3-4491-9808-64ad90a92334	\N	2024-12-09	2024-12-15	3	4	4	5	Good performance this week.	\N	\N	2025-12-13 23:55:30.476245	2025-12-13 23:55:30.476245
28c42ffe-a79e-48b3-9c38-de69864f7d3c	694655b7-cfa9-418e-9f29-1753df0adbfd	a8f9ccad-6eef-45ea-b1d9-9b24ec7ab5a9	\N	2024-12-09	2024-12-15	4	5	4	3	Good performance this week.	\N	\N	2025-12-13 23:55:30.476245	2025-12-13 23:55:30.476245
3b98f4d9-939f-4951-867e-0dd2d3e469a4	c84d7da8-2f5e-4123-85c5-989ba74e3520	a8f9ccad-6eef-45ea-b1d9-9b24ec7ab5a9	\N	2024-12-09	2024-12-15	3	5	3	4	Good performance this week.	\N	\N	2025-12-13 23:55:30.476245	2025-12-13 23:55:30.476245
3fb70ddc-b61f-40bb-ad0d-64eb6d3b6aa8	c58f03b5-12e4-45c5-b71d-21ffeb6b0c40	1eab9750-4824-4de4-8168-04591fc249f7	\N	2024-12-09	2024-12-15	3	5	4	4	Good performance this week.	\N	\N	2025-12-13 23:55:30.476245	2025-12-13 23:55:30.476245
095b5a0f-8d8a-4b12-8398-4cc0a67d54a4	905773e4-02be-4a57-9046-7bd29db1fa03	1eab9750-4824-4de4-8168-04591fc249f7	\N	2024-12-09	2024-12-15	3	3	4	4	Good performance this week.	\N	\N	2025-12-13 23:55:30.476245	2025-12-13 23:55:30.476245
bbd81fc4-d5a7-4cf7-897d-21d9477bf7b7	243a4471-81e9-469e-ae44-7685b225e07b	f8642d75-f69a-487d-b385-661ecf2fc8fc	\N	2024-12-09	2024-12-15	4	4	4	3	Good performance this week.	\N	\N	2025-12-13 23:55:30.476245	2025-12-13 23:55:30.476245
0b8a5ce6-b24d-4625-afd9-6c58fc96ae06	afb04864-9ab2-4994-918c-397a2a035d84	f8642d75-f69a-487d-b385-661ecf2fc8fc	\N	2024-12-09	2024-12-15	3	4	4	3	Good performance this week.	\N	\N	2025-12-13 23:55:30.476245	2025-12-13 23:55:30.476245
7cd9e9da-3ac3-46df-a8d9-5f3125625f2e	5c39ac09-558d-4836-9bb6-f1de81d58f9d	a1ba9ca9-d129-47c4-b6ff-1d3a5fd1e27d	\N	2024-12-09	2024-12-15	4	5	3	5	Good performance this week.	\N	\N	2025-12-13 23:55:30.476245	2025-12-13 23:55:30.476245
c00b53b0-ce75-43d5-b806-6b4b66f93539	3f324c9c-7c0d-4dbc-8c49-cd943f36fc27	a1ba9ca9-d129-47c4-b6ff-1d3a5fd1e27d	\N	2024-12-09	2024-12-15	3	5	5	3	Good performance this week.	\N	\N	2025-12-13 23:55:30.476245	2025-12-13 23:55:30.476245
220dc9da-7463-4f96-838f-a6ccef187665	2a643039-c6a0-4791-b022-07b0fbfddd3a	87e45cfe-99c0-46bf-8ea4-a53fb3c757b0	\N	2024-12-09	2024-12-15	3	3	5	5	Good performance this week.	\N	\N	2025-12-13 23:55:30.476245	2025-12-13 23:55:30.476245
ba3a1037-d197-4bba-b09e-5a0df956d366	020e710e-e419-4c74-9848-3b00770353c6	87e45cfe-99c0-46bf-8ea4-a53fb3c757b0	\N	2024-12-09	2024-12-15	4	4	4	4	Good performance this week.	\N	\N	2025-12-13 23:55:30.476245	2025-12-13 23:55:30.476245
f9bc1bbf-3cfa-4293-97bd-0716f1991950	f4d858f5-58b1-4727-96d5-5b27be00ebbe	df4b5622-d10a-4be6-b3b9-ae9eb365621f	\N	2024-12-09	2024-12-15	4	5	4	4	Good performance this week.	\N	\N	2025-12-13 23:55:30.476245	2025-12-13 23:55:30.476245
a104ac2f-e002-46d7-bd47-e453ff421920	1ca1e403-5ac5-495e-86b5-0e60c397393b	df4b5622-d10a-4be6-b3b9-ae9eb365621f	\N	2024-12-09	2024-12-15	5	3	4	4	Good performance this week.	\N	\N	2025-12-13 23:55:30.476245	2025-12-13 23:55:30.476245
2beff455-3b95-472d-a3ba-1877720bbfc3	34d7356b-9cea-4a80-a7be-93d7def7d260	710974ab-52fc-4726-b50a-b309d5b7d9ba	\N	2024-12-09	2024-12-15	4	3	4	4	Good performance this week.	\N	\N	2025-12-13 23:55:30.476245	2025-12-13 23:55:30.476245
fcd62d91-7541-487f-be23-cd4014ae0321	5eebb1da-4f4a-4422-9d3b-406c89f80c89	710974ab-52fc-4726-b50a-b309d5b7d9ba	\N	2024-12-09	2024-12-15	3	3	3	5	Good performance this week.	\N	\N	2025-12-13 23:55:30.476245	2025-12-13 23:55:30.476245
803ffdfd-b4b0-4c22-ab6a-522fa8b3431f	489473cf-735a-4831-ac2a-f94ce58afca4	085df28e-fb49-420c-bea9-0432c9199f40	\N	2024-12-09	2024-12-15	5	3	4	4	Good performance this week.	\N	\N	2025-12-13 23:55:30.476245	2025-12-13 23:55:30.476245
7f2e1f6a-3e72-4a02-b94a-42099f0ee351	412e9a12-7529-4bc7-85c7-f88df5e191d1	085df28e-fb49-420c-bea9-0432c9199f40	\N	2024-12-09	2024-12-15	4	4	4	4	Good performance this week.	\N	\N	2025-12-13 23:55:30.476245	2025-12-13 23:55:30.476245
436cb9a5-f137-4caf-8315-9edf835ddf41	c492c079-7db5-4261-9983-2492048902eb	81e8d990-cba5-41df-8c92-f74cdbc3a71a	\N	2024-12-09	2024-12-15	5	5	3	3	Good performance this week.	\N	\N	2025-12-13 23:55:30.476245	2025-12-13 23:55:30.476245
215e3411-9113-4cbf-a83d-81c798fb6d03	aecbb92c-bbe9-4a05-9dc2-a1f290e41deb	81e8d990-cba5-41df-8c92-f74cdbc3a71a	\N	2024-12-09	2024-12-15	4	4	3	3	Good performance this week.	\N	\N	2025-12-13 23:55:30.476245	2025-12-13 23:55:30.476245
4525b58f-8269-44b3-bfa2-37a2fa239c33	fac4c4eb-47c1-4552-9e92-3f24ca63a922	7ef2acf4-d876-4a29-b1f0-db8301f817a6	\N	2024-12-09	2024-12-15	4	4	4	5	Good performance this week.	\N	\N	2025-12-13 23:55:30.476245	2025-12-13 23:55:30.476245
b5cbc09b-f1a0-45c6-b58c-fee4f30cbaaf	552e83ca-0eaa-4d94-87aa-9c4958aa811e	d2940649-78f0-4418-88b4-7b16a9a7104f	\N	2024-12-09	2024-12-15	5	3	3	4	Good performance this week.	\N	\N	2025-12-13 23:55:30.476245	2025-12-13 23:55:30.476245
84faa4f9-77f7-494b-987d-7a61f6911366	544e6fb5-b91e-43be-89f6-90546a7f0669	d2940649-78f0-4418-88b4-7b16a9a7104f	\N	2024-12-09	2024-12-15	3	4	4	3	Good performance this week.	\N	\N	2025-12-13 23:55:30.476245	2025-12-13 23:55:30.476245
748a4098-37b1-48f4-b4e2-26fb3b1955e7	e001d25d-7ef8-44c7-8213-2777aa595970	b4801419-3838-4ac9-9c94-b05568dbf2b1	\N	2024-12-09	2024-12-15	3	3	4	4	Good performance this week.	\N	\N	2025-12-13 23:55:30.476245	2025-12-13 23:55:30.476245
3e74369c-dbee-4393-b92a-50488c9b2876	1d71f3e9-7f85-49b8-a65e-b9c819ad19cb	b4801419-3838-4ac9-9c94-b05568dbf2b1	\N	2024-12-09	2024-12-15	4	3	3	4	Good performance this week.	\N	\N	2025-12-13 23:55:30.476245	2025-12-13 23:55:30.476245
5e4a3b34-69b5-4712-a6e6-b605330792ea	1ebbf9f9-6184-4687-a5cf-a5b7c6d11717	6315b233-5988-421f-9cb9-95a8b68e00ce	\N	2024-12-09	2024-12-15	5	4	4	4	Good performance this week.	\N	\N	2025-12-13 23:55:30.476245	2025-12-13 23:55:30.476245
c1b7311c-58da-4278-9e87-195088ed7cc5	c848bf8a-43a8-4d05-94cc-9d5033405cd7	6315b233-5988-421f-9cb9-95a8b68e00ce	\N	2024-12-09	2024-12-15	3	4	4	4	Good performance this week.	\N	\N	2025-12-13 23:55:30.476245	2025-12-13 23:55:30.476245
f989b221-ea8c-4c26-bac3-1367d1956709	0919939d-1f4b-485c-b66e-1c24d710930d	3b4d200d-8f2c-45c8-a3ae-2816d06f208c	\N	2024-12-09	2024-12-15	4	4	3	5	Good performance this week.	\N	\N	2025-12-13 23:55:30.476245	2025-12-13 23:55:30.476245
eb1ce5f8-60f5-4471-973f-199bdf093145	8c59a07a-41dc-4d55-b55b-f82800569e9c	3b4d200d-8f2c-45c8-a3ae-2816d06f208c	\N	2024-12-09	2024-12-15	4	3	3	4	Good performance this week.	\N	\N	2025-12-13 23:55:30.476245	2025-12-13 23:55:30.476245
42a2aa4a-1768-4e3e-8890-318a0f122d95	6392ac81-e8b5-4b27-a2dc-b0a34a449659	7af931a9-9b6d-464c-928a-56556aa73171	\N	2024-12-09	2024-12-15	4	3	4	4	Good performance this week.	\N	\N	2025-12-13 23:55:30.476245	2025-12-13 23:55:30.476245
0ed48f18-59fc-46d4-a68c-73f73432e638	b45f33f6-4f98-4d00-af3d-6bae657c2deb	7af931a9-9b6d-464c-928a-56556aa73171	\N	2024-12-09	2024-12-15	5	5	5	3	Good performance this week.	\N	\N	2025-12-13 23:55:30.476245	2025-12-13 23:55:30.476245
74786490-0c64-4d96-aaab-a618ae4a0f9d	1e193b09-87bc-48c4-b666-94f910cf5882	d1b4bda9-e6d2-4b36-a87b-63b34b14a47a	\N	2024-12-09	2024-12-15	5	4	4	3	Good performance this week.	\N	\N	2025-12-13 23:55:30.476245	2025-12-13 23:55:30.476245
58b816f6-88a6-4463-b715-379fda878b45	cebe720e-d2f1-4b0e-9107-4da7b543fe4b	d1b4bda9-e6d2-4b36-a87b-63b34b14a47a	\N	2024-12-09	2024-12-15	4	5	3	5	Good performance this week.	\N	\N	2025-12-13 23:55:30.476245	2025-12-13 23:55:30.476245
52534375-927e-4912-8325-769f6b5eaffe	8ecec133-b13f-4d69-91f0-21ac9f930ca6	a7a5977d-c912-4476-b8c1-89d6a6dec0ee	\N	2024-11-25	2024-12-01	3	3	3	5	Steady improvement shown.	\N	\N	2025-12-13 23:55:30.488689	2025-12-13 23:55:30.488689
ef8e2047-b686-4bef-ae10-6ea5b77bd1bd	5be8065b-44d4-4fab-aa82-b64bda2b368a	a7a5977d-c912-4476-b8c1-89d6a6dec0ee	\N	2024-11-25	2024-12-01	3	4	5	4	Steady improvement shown.	\N	\N	2025-12-13 23:55:30.488689	2025-12-13 23:55:30.488689
1c1d5f01-7eba-4d37-aaab-cd3e49c4270e	9a2b27aa-e90a-4409-8373-2be363ee206e	d2e4dc25-672a-485e-98b8-0126b3f10d28	\N	2024-11-25	2024-12-01	3	5	3	4	Steady improvement shown.	\N	\N	2025-12-13 23:55:30.488689	2025-12-13 23:55:30.488689
bfb93a2f-6dac-4acf-b26e-cb52424ed5d9	9a2b27aa-e90a-4409-8373-2be363ee206e	e6bcd428-3711-4d17-80b4-5fab412563bd	\N	2024-11-25	2024-12-01	4	3	4	3	Steady improvement shown.	\N	\N	2025-12-13 23:55:30.488689	2025-12-13 23:55:30.488689
d5ae5459-3b5d-44f3-9c6a-41eb4d5b5798	d9df9370-0442-4365-9ed0-3b59afc81ec1	091177fc-3b2c-4858-8ea0-b8f7206b4636	\N	2024-11-25	2024-12-01	3	4	4	3	Steady improvement shown.	\N	\N	2025-12-13 23:55:30.488689	2025-12-13 23:55:30.488689
c3898080-a4ec-4796-9845-da82b75e5850	9c77950e-3ebc-4846-aed1-2faae86cbb37	091177fc-3b2c-4858-8ea0-b8f7206b4636	\N	2024-11-25	2024-12-01	4	5	5	3	Steady improvement shown.	\N	\N	2025-12-13 23:55:30.488689	2025-12-13 23:55:30.488689
9bc18ff5-5ece-4c49-95a3-720e78df3292	66024a16-884c-408e-bead-dd134927a58a	7b63533f-02f3-4491-9808-64ad90a92334	\N	2024-11-25	2024-12-01	3	2	4	3	Steady improvement shown.	\N	\N	2025-12-13 23:55:30.488689	2025-12-13 23:55:30.488689
93a0e7b5-14c9-43af-a2ff-abce153c2fa2	c6fa2131-7fea-459e-9df8-2ff37f1a39bb	7b63533f-02f3-4491-9808-64ad90a92334	\N	2024-11-25	2024-12-01	4	4	4	5	Steady improvement shown.	\N	\N	2025-12-13 23:55:30.488689	2025-12-13 23:55:30.488689
1e9cb205-03aa-423d-9817-338fbf9eb9c2	694655b7-cfa9-418e-9f29-1753df0adbfd	a8f9ccad-6eef-45ea-b1d9-9b24ec7ab5a9	\N	2024-11-25	2024-12-01	2	4	4	2	Steady improvement shown.	\N	\N	2025-12-13 23:55:30.488689	2025-12-13 23:55:30.488689
f5fbf34d-b97a-4e76-8ebd-a569f44fb0ca	c84d7da8-2f5e-4123-85c5-989ba74e3520	a8f9ccad-6eef-45ea-b1d9-9b24ec7ab5a9	\N	2024-11-25	2024-12-01	4	3	3	5	Steady improvement shown.	\N	\N	2025-12-13 23:55:30.488689	2025-12-13 23:55:30.488689
959e8db4-2ebd-467b-bd58-dd87230af5d6	c58f03b5-12e4-45c5-b71d-21ffeb6b0c40	1eab9750-4824-4de4-8168-04591fc249f7	\N	2024-11-25	2024-12-01	4	4	4	4	Steady improvement shown.	\N	\N	2025-12-13 23:55:30.488689	2025-12-13 23:55:30.488689
1782d65b-32c9-434f-80ee-a46c0959c58d	905773e4-02be-4a57-9046-7bd29db1fa03	1eab9750-4824-4de4-8168-04591fc249f7	\N	2024-11-25	2024-12-01	4	4	4	4	Steady improvement shown.	\N	\N	2025-12-13 23:55:30.488689	2025-12-13 23:55:30.488689
fde80a27-cb15-4903-997e-33e1c5957281	243a4471-81e9-469e-ae44-7685b225e07b	f8642d75-f69a-487d-b385-661ecf2fc8fc	\N	2024-11-25	2024-12-01	2	3	3	5	Steady improvement shown.	\N	\N	2025-12-13 23:55:30.488689	2025-12-13 23:55:30.488689
e0add6af-f4c4-4810-9995-0a30d4ae1f02	afb04864-9ab2-4994-918c-397a2a035d84	f8642d75-f69a-487d-b385-661ecf2fc8fc	\N	2024-11-25	2024-12-01	3	4	2	3	Steady improvement shown.	\N	\N	2025-12-13 23:55:30.488689	2025-12-13 23:55:30.488689
f095e3c6-0f1e-44ae-9dfe-8824eeaf696d	5c39ac09-558d-4836-9bb6-f1de81d58f9d	a1ba9ca9-d129-47c4-b6ff-1d3a5fd1e27d	\N	2024-11-25	2024-12-01	3	4	2	4	Steady improvement shown.	\N	\N	2025-12-13 23:55:30.488689	2025-12-13 23:55:30.488689
3fda6ee8-e680-4a54-b3d3-6ed1860318d2	3f324c9c-7c0d-4dbc-8c49-cd943f36fc27	a1ba9ca9-d129-47c4-b6ff-1d3a5fd1e27d	\N	2024-11-25	2024-12-01	5	2	5	5	Steady improvement shown.	\N	\N	2025-12-13 23:55:30.488689	2025-12-13 23:55:30.488689
b9696f45-3a4c-49a2-948b-71c8e48e9246	2a643039-c6a0-4791-b022-07b0fbfddd3a	87e45cfe-99c0-46bf-8ea4-a53fb3c757b0	\N	2024-11-25	2024-12-01	2	4	3	3	Steady improvement shown.	\N	\N	2025-12-13 23:55:30.488689	2025-12-13 23:55:30.488689
c6cea2a1-bff3-4452-b2b1-ad0fb358aaf6	020e710e-e419-4c74-9848-3b00770353c6	87e45cfe-99c0-46bf-8ea4-a53fb3c757b0	\N	2024-11-25	2024-12-01	4	4	3	3	Steady improvement shown.	\N	\N	2025-12-13 23:55:30.488689	2025-12-13 23:55:30.488689
c5bcbba6-ad05-4869-b6f2-69b1699236d1	f4d858f5-58b1-4727-96d5-5b27be00ebbe	df4b5622-d10a-4be6-b3b9-ae9eb365621f	\N	2024-11-25	2024-12-01	3	4	5	3	Steady improvement shown.	\N	\N	2025-12-13 23:55:30.488689	2025-12-13 23:55:30.488689
07df1f6b-65a5-4d2d-8df3-001201975cd1	1ca1e403-5ac5-495e-86b5-0e60c397393b	df4b5622-d10a-4be6-b3b9-ae9eb365621f	\N	2024-11-25	2024-12-01	3	3	2	2	Steady improvement shown.	\N	\N	2025-12-13 23:55:30.488689	2025-12-13 23:55:30.488689
93e9430c-a5c7-44e6-8d1a-ba107ca64c0b	34d7356b-9cea-4a80-a7be-93d7def7d260	710974ab-52fc-4726-b50a-b309d5b7d9ba	\N	2024-11-25	2024-12-01	2	3	3	5	Steady improvement shown.	\N	\N	2025-12-13 23:55:30.488689	2025-12-13 23:55:30.488689
ba562f07-bd62-4dad-8149-00afac57263b	5eebb1da-4f4a-4422-9d3b-406c89f80c89	710974ab-52fc-4726-b50a-b309d5b7d9ba	\N	2024-11-25	2024-12-01	5	5	4	4	Steady improvement shown.	\N	\N	2025-12-13 23:55:30.488689	2025-12-13 23:55:30.488689
575579e7-1932-4814-9743-c5bf3d08b3d9	489473cf-735a-4831-ac2a-f94ce58afca4	085df28e-fb49-420c-bea9-0432c9199f40	\N	2024-11-25	2024-12-01	5	4	5	4	Steady improvement shown.	\N	\N	2025-12-13 23:55:30.488689	2025-12-13 23:55:30.488689
5a0e5390-50c5-4b6b-b3e4-6829f5e6d11c	412e9a12-7529-4bc7-85c7-f88df5e191d1	085df28e-fb49-420c-bea9-0432c9199f40	\N	2024-11-25	2024-12-01	3	3	3	4	Steady improvement shown.	\N	\N	2025-12-13 23:55:30.488689	2025-12-13 23:55:30.488689
4765f53c-b6c6-4b56-bdac-88ffaf5088c7	c492c079-7db5-4261-9983-2492048902eb	81e8d990-cba5-41df-8c92-f74cdbc3a71a	\N	2024-11-25	2024-12-01	4	2	2	2	Steady improvement shown.	\N	\N	2025-12-13 23:55:30.488689	2025-12-13 23:55:30.488689
538b4f74-13d0-4e5a-9d4d-a01b739493a9	aecbb92c-bbe9-4a05-9dc2-a1f290e41deb	81e8d990-cba5-41df-8c92-f74cdbc3a71a	\N	2024-11-25	2024-12-01	3	4	4	5	Steady improvement shown.	\N	\N	2025-12-13 23:55:30.488689	2025-12-13 23:55:30.488689
62a0f10b-d14a-48fc-93de-48b2a07d9909	fac4c4eb-47c1-4552-9e92-3f24ca63a922	7ef2acf4-d876-4a29-b1f0-db8301f817a6	\N	2024-11-25	2024-12-01	3	3	2	2	Steady improvement shown.	\N	\N	2025-12-13 23:55:30.488689	2025-12-13 23:55:30.488689
d1a3adb0-6908-4f16-861d-09ddaa15b463	552e83ca-0eaa-4d94-87aa-9c4958aa811e	d2940649-78f0-4418-88b4-7b16a9a7104f	\N	2024-11-25	2024-12-01	3	5	4	2	Steady improvement shown.	\N	\N	2025-12-13 23:55:30.488689	2025-12-13 23:55:30.488689
533ad510-e08b-432e-916e-410a37642dc9	544e6fb5-b91e-43be-89f6-90546a7f0669	d2940649-78f0-4418-88b4-7b16a9a7104f	\N	2024-11-25	2024-12-01	3	3	3	4	Steady improvement shown.	\N	\N	2025-12-13 23:55:30.488689	2025-12-13 23:55:30.488689
42e4bf9b-6e39-42c2-a930-9a19a389408e	e001d25d-7ef8-44c7-8213-2777aa595970	b4801419-3838-4ac9-9c94-b05568dbf2b1	\N	2024-11-25	2024-12-01	4	3	4	4	Steady improvement shown.	\N	\N	2025-12-13 23:55:30.488689	2025-12-13 23:55:30.488689
e5baa917-d067-48a4-afa4-8c950f14cb2a	1d71f3e9-7f85-49b8-a65e-b9c819ad19cb	b4801419-3838-4ac9-9c94-b05568dbf2b1	\N	2024-11-25	2024-12-01	3	3	5	5	Steady improvement shown.	\N	\N	2025-12-13 23:55:30.488689	2025-12-13 23:55:30.488689
27c80ad4-c5d9-439e-ab3f-c2e9f564a74f	1ebbf9f9-6184-4687-a5cf-a5b7c6d11717	6315b233-5988-421f-9cb9-95a8b68e00ce	\N	2024-11-25	2024-12-01	3	5	3	3	Steady improvement shown.	\N	\N	2025-12-13 23:55:30.488689	2025-12-13 23:55:30.488689
0460614f-773a-43d2-bf9e-b9e700b48a7b	c848bf8a-43a8-4d05-94cc-9d5033405cd7	6315b233-5988-421f-9cb9-95a8b68e00ce	\N	2024-11-25	2024-12-01	5	4	2	2	Steady improvement shown.	\N	\N	2025-12-13 23:55:30.488689	2025-12-13 23:55:30.488689
673c98a8-735b-4c4a-b790-353aea33067b	0919939d-1f4b-485c-b66e-1c24d710930d	3b4d200d-8f2c-45c8-a3ae-2816d06f208c	\N	2024-11-25	2024-12-01	2	3	3	3	Steady improvement shown.	\N	\N	2025-12-13 23:55:30.488689	2025-12-13 23:55:30.488689
3573167d-cb2e-430e-9f81-ee25ab0d98d7	8c59a07a-41dc-4d55-b55b-f82800569e9c	3b4d200d-8f2c-45c8-a3ae-2816d06f208c	\N	2024-11-25	2024-12-01	5	4	3	3	Steady improvement shown.	\N	\N	2025-12-13 23:55:30.488689	2025-12-13 23:55:30.488689
9f4e3c18-40a1-4e55-8d54-bc8d31d59bce	6392ac81-e8b5-4b27-a2dc-b0a34a449659	7af931a9-9b6d-464c-928a-56556aa73171	\N	2024-11-25	2024-12-01	4	3	4	2	Steady improvement shown.	\N	\N	2025-12-13 23:55:30.488689	2025-12-13 23:55:30.488689
fd7dcc99-e745-4532-99cb-bff27c723695	b45f33f6-4f98-4d00-af3d-6bae657c2deb	7af931a9-9b6d-464c-928a-56556aa73171	\N	2024-11-25	2024-12-01	4	2	3	4	Steady improvement shown.	\N	\N	2025-12-13 23:55:30.488689	2025-12-13 23:55:30.488689
5b92ba53-4cf5-482b-8676-d836b432f897	1e193b09-87bc-48c4-b666-94f910cf5882	d1b4bda9-e6d2-4b36-a87b-63b34b14a47a	\N	2024-11-25	2024-12-01	4	4	4	2	Steady improvement shown.	\N	\N	2025-12-13 23:55:30.488689	2025-12-13 23:55:30.488689
8159f3d6-ad9d-4e68-a75b-3ecbd5511a31	cebe720e-d2f1-4b0e-9107-4da7b543fe4b	d1b4bda9-e6d2-4b36-a87b-63b34b14a47a	\N	2024-11-25	2024-12-01	3	4	3	4	Steady improvement shown.	\N	\N	2025-12-13 23:55:30.488689	2025-12-13 23:55:30.488689
53aa6df8-50bb-415d-99dd-8289d37b5df7	710974ab-52fc-4726-b50a-b309d5b7d9ba	710974ab-52fc-4726-b50a-b309d5b7d9ba	\N	2025-12-14	2025-12-20	3	3	3	3	Gym!	\N	\N	2025-12-14 00:56:12.214066	2025-12-14 00:56:12.214066
\.


--
-- Name: notifications_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.notifications_id_seq', 621, true);


--
-- Name: password_reset_otps_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.password_reset_otps_id_seq', 1, false);


--
-- Name: promotion_history_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.promotion_history_id_seq', 3, true);


--
-- Name: branches branches_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.branches
    ADD CONSTRAINT branches_name_key UNIQUE (name);


--
-- Name: branches branches_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.branches
    ADD CONSTRAINT branches_pkey PRIMARY KEY (id);


--
-- Name: departments departments_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.departments
    ADD CONSTRAINT departments_name_key UNIQUE (name);


--
-- Name: departments departments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.departments
    ADD CONSTRAINT departments_pkey PRIMARY KEY (id);


--
-- Name: document_access_logs document_access_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.document_access_logs
    ADD CONSTRAINT document_access_logs_pkey PRIMARY KEY (id);


--
-- Name: guarantor_documents guarantor_documents_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.guarantor_documents
    ADD CONSTRAINT guarantor_documents_pkey PRIMARY KEY (id);


--
-- Name: guarantors guarantors_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.guarantors
    ADD CONSTRAINT guarantors_pkey PRIMARY KEY (id);


--
-- Name: messages messages_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_pkey PRIMARY KEY (id);


--
-- Name: next_of_kin next_of_kin_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.next_of_kin
    ADD CONSTRAINT next_of_kin_pkey PRIMARY KEY (id);


--
-- Name: notifications notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);


--
-- Name: password_reset_otps password_reset_otps_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.password_reset_otps
    ADD CONSTRAINT password_reset_otps_email_key UNIQUE (email);


--
-- Name: password_reset_otps password_reset_otps_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.password_reset_otps
    ADD CONSTRAINT password_reset_otps_pkey PRIMARY KEY (id);


--
-- Name: promotion_history promotion_history_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.promotion_history
    ADD CONSTRAINT promotion_history_pkey PRIMARY KEY (id);


--
-- Name: roles roles_name_department_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_department_id_key UNIQUE (name, department_id);


--
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- Name: roster_assignments roster_assignments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roster_assignments
    ADD CONSTRAINT roster_assignments_pkey PRIMARY KEY (id);


--
-- Name: rosters rosters_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rosters
    ADD CONSTRAINT rosters_pkey PRIMARY KEY (id);


--
-- Name: shift_templates shift_templates_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shift_templates
    ADD CONSTRAINT shift_templates_pkey PRIMARY KEY (id);


--
-- Name: sub_departments sub_departments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sub_departments
    ADD CONSTRAINT sub_departments_pkey PRIMARY KEY (id);


--
-- Name: terminated_staff terminated_staff_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.terminated_staff
    ADD CONSTRAINT terminated_staff_pkey PRIMARY KEY (id);


--
-- Name: shift_templates unique_manager_shift_type; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shift_templates
    ADD CONSTRAINT unique_manager_shift_type UNIQUE (floor_manager_id, shift_type);


--
-- Name: rosters unique_roster_week; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rosters
    ADD CONSTRAINT unique_roster_week UNIQUE (floor_manager_id, week_start_date);


--
-- Name: roster_assignments unique_staff_day_shift; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roster_assignments
    ADD CONSTRAINT unique_staff_day_shift UNIQUE (roster_id, staff_id, day_of_week, shift_type);


--
-- Name: weekly_reviews unique_staff_week_review; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.weekly_reviews
    ADD CONSTRAINT unique_staff_week_review UNIQUE (staff_id, week_start_date, reviewer_id);


--
-- Name: user_documents user_documents_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_documents
    ADD CONSTRAINT user_documents_pkey PRIMARY KEY (id);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_employee_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_employee_id_key UNIQUE (employee_id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: weekly_reviews weekly_reviews_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.weekly_reviews
    ADD CONSTRAINT weekly_reviews_pkey PRIMARY KEY (id);


--
-- Name: idx_document_access_by; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_document_access_by ON public.document_access_logs USING btree (accessed_by);


--
-- Name: idx_document_access_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_document_access_date ON public.document_access_logs USING btree (created_at);


--
-- Name: idx_document_access_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_document_access_user ON public.document_access_logs USING btree (user_id);


--
-- Name: idx_password_reset_otps_email; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_password_reset_otps_email ON public.password_reset_otps USING btree (email);


--
-- Name: idx_password_reset_otps_expires_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_password_reset_otps_expires_at ON public.password_reset_otps USING btree (expires_at);


--
-- Name: idx_roster_assignments_day; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_roster_assignments_day ON public.roster_assignments USING btree (day_of_week);


--
-- Name: idx_roster_assignments_roster; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_roster_assignments_roster ON public.roster_assignments USING btree (roster_id);


--
-- Name: idx_roster_assignments_staff; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_roster_assignments_staff ON public.roster_assignments USING btree (staff_id);


--
-- Name: idx_rosters_manager; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_rosters_manager ON public.rosters USING btree (floor_manager_id);


--
-- Name: idx_rosters_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_rosters_status ON public.rosters USING btree (status);


--
-- Name: idx_rosters_week; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_rosters_week ON public.rosters USING btree (week_start_date, week_end_date);


--
-- Name: idx_shift_templates_manager; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_shift_templates_manager ON public.shift_templates USING btree (floor_manager_id);


--
-- Name: idx_terminated_staff_branch; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_terminated_staff_branch ON public.terminated_staff USING btree (branch_name);


--
-- Name: idx_terminated_staff_department; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_terminated_staff_department ON public.terminated_staff USING btree (department_name);


--
-- Name: idx_terminated_staff_termination_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_terminated_staff_termination_date ON public.terminated_staff USING btree (termination_date);


--
-- Name: idx_terminated_staff_termination_type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_terminated_staff_termination_type ON public.terminated_staff USING btree (termination_type);


--
-- Name: idx_terminated_staff_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_terminated_staff_user_id ON public.terminated_staff USING btree (user_id);


--
-- Name: idx_users_is_active; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_users_is_active ON public.users USING btree (is_active);


--
-- Name: idx_users_profile_image; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_users_profile_image ON public.users USING btree (profile_image_url) WHERE (profile_image_url IS NOT NULL);


--
-- Name: idx_users_sub_department; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_users_sub_department ON public.users USING btree (sub_department_id);


--
-- Name: idx_weekly_reviews_rating; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_weekly_reviews_rating ON public.weekly_reviews USING btree (rating);


--
-- Name: idx_weekly_reviews_reviewer; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_weekly_reviews_reviewer ON public.weekly_reviews USING btree (reviewer_id);


--
-- Name: idx_weekly_reviews_staff; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_weekly_reviews_staff ON public.weekly_reviews USING btree (staff_id);


--
-- Name: idx_weekly_reviews_week; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_weekly_reviews_week ON public.weekly_reviews USING btree (week_start_date, week_end_date);


--
-- Name: terminated_staff trigger_update_terminated_staff_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trigger_update_terminated_staff_updated_at BEFORE UPDATE ON public.terminated_staff FOR EACH ROW EXECUTE FUNCTION public.update_terminated_staff_updated_at();


--
-- Name: document_access_logs document_access_logs_accessed_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.document_access_logs
    ADD CONSTRAINT document_access_logs_accessed_by_fkey FOREIGN KEY (accessed_by) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: document_access_logs document_access_logs_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.document_access_logs
    ADD CONSTRAINT document_access_logs_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: guarantor_documents guarantor_documents_guarantor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.guarantor_documents
    ADD CONSTRAINT guarantor_documents_guarantor_id_fkey FOREIGN KEY (guarantor_id) REFERENCES public.guarantors(id) ON DELETE CASCADE;


--
-- Name: guarantors guarantors_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.guarantors
    ADD CONSTRAINT guarantors_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: messages messages_sender_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_sender_id_fkey FOREIGN KEY (sender_id) REFERENCES public.users(id);


--
-- Name: messages messages_target_branch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_target_branch_id_fkey FOREIGN KEY (target_branch_id) REFERENCES public.branches(id);


--
-- Name: messages messages_target_department_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_target_department_id_fkey FOREIGN KEY (target_department_id) REFERENCES public.departments(id);


--
-- Name: next_of_kin next_of_kin_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.next_of_kin
    ADD CONSTRAINT next_of_kin_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: notifications notifications_message_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_message_id_fkey FOREIGN KEY (message_id) REFERENCES public.messages(id);


--
-- Name: notifications notifications_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: promotion_history promotion_history_new_branch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.promotion_history
    ADD CONSTRAINT promotion_history_new_branch_id_fkey FOREIGN KEY (new_branch_id) REFERENCES public.branches(id);


--
-- Name: promotion_history promotion_history_new_department_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.promotion_history
    ADD CONSTRAINT promotion_history_new_department_id_fkey FOREIGN KEY (new_department_id) REFERENCES public.departments(id);


--
-- Name: promotion_history promotion_history_new_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.promotion_history
    ADD CONSTRAINT promotion_history_new_role_id_fkey FOREIGN KEY (new_role_id) REFERENCES public.roles(id);


--
-- Name: promotion_history promotion_history_previous_branch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.promotion_history
    ADD CONSTRAINT promotion_history_previous_branch_id_fkey FOREIGN KEY (previous_branch_id) REFERENCES public.branches(id);


--
-- Name: promotion_history promotion_history_previous_department_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.promotion_history
    ADD CONSTRAINT promotion_history_previous_department_id_fkey FOREIGN KEY (previous_department_id) REFERENCES public.departments(id);


--
-- Name: promotion_history promotion_history_previous_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.promotion_history
    ADD CONSTRAINT promotion_history_previous_role_id_fkey FOREIGN KEY (previous_role_id) REFERENCES public.roles(id);


--
-- Name: promotion_history promotion_history_promoted_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.promotion_history
    ADD CONSTRAINT promotion_history_promoted_by_fkey FOREIGN KEY (promoted_by) REFERENCES public.users(id);


--
-- Name: promotion_history promotion_history_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.promotion_history
    ADD CONSTRAINT promotion_history_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: roles roles_department_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_department_id_fkey FOREIGN KEY (department_id) REFERENCES public.departments(id);


--
-- Name: roles roles_sub_department_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_sub_department_id_fkey FOREIGN KEY (sub_department_id) REFERENCES public.sub_departments(id);


--
-- Name: roster_assignments roster_assignments_roster_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roster_assignments
    ADD CONSTRAINT roster_assignments_roster_id_fkey FOREIGN KEY (roster_id) REFERENCES public.rosters(id) ON DELETE CASCADE;


--
-- Name: roster_assignments roster_assignments_staff_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roster_assignments
    ADD CONSTRAINT roster_assignments_staff_id_fkey FOREIGN KEY (staff_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: rosters rosters_branch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rosters
    ADD CONSTRAINT rosters_branch_id_fkey FOREIGN KEY (branch_id) REFERENCES public.branches(id) ON DELETE SET NULL;


--
-- Name: rosters rosters_department_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rosters
    ADD CONSTRAINT rosters_department_id_fkey FOREIGN KEY (department_id) REFERENCES public.departments(id) ON DELETE SET NULL;


--
-- Name: rosters rosters_floor_manager_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rosters
    ADD CONSTRAINT rosters_floor_manager_id_fkey FOREIGN KEY (floor_manager_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: shift_templates shift_templates_floor_manager_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shift_templates
    ADD CONSTRAINT shift_templates_floor_manager_id_fkey FOREIGN KEY (floor_manager_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: sub_departments sub_departments_branch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sub_departments
    ADD CONSTRAINT sub_departments_branch_id_fkey FOREIGN KEY (branch_id) REFERENCES public.branches(id) ON DELETE CASCADE;


--
-- Name: sub_departments sub_departments_department_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sub_departments
    ADD CONSTRAINT sub_departments_department_id_fkey FOREIGN KEY (parent_department_id) REFERENCES public.departments(id) ON DELETE CASCADE;


--
-- Name: sub_departments sub_departments_manager_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sub_departments
    ADD CONSTRAINT sub_departments_manager_id_fkey FOREIGN KEY (manager_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: terminated_staff terminated_staff_terminated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.terminated_staff
    ADD CONSTRAINT terminated_staff_terminated_by_fkey FOREIGN KEY (terminated_by) REFERENCES public.users(id);


--
-- Name: terminated_staff terminated_staff_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.terminated_staff
    ADD CONSTRAINT terminated_staff_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: user_documents user_documents_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_documents
    ADD CONSTRAINT user_documents_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: users users_branch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_branch_id_fkey FOREIGN KEY (branch_id) REFERENCES public.branches(id);


--
-- Name: users users_department_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_department_id_fkey FOREIGN KEY (department_id) REFERENCES public.departments(id);


--
-- Name: users users_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.roles(id);


--
-- Name: users users_sub_department_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_sub_department_id_fkey FOREIGN KEY (sub_department_id) REFERENCES public.sub_departments(id);


--
-- Name: weekly_reviews weekly_reviews_reviewer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.weekly_reviews
    ADD CONSTRAINT weekly_reviews_reviewer_id_fkey FOREIGN KEY (reviewer_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: weekly_reviews weekly_reviews_roster_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.weekly_reviews
    ADD CONSTRAINT weekly_reviews_roster_id_fkey FOREIGN KEY (roster_id) REFERENCES public.rosters(id) ON DELETE SET NULL;


--
-- Name: weekly_reviews weekly_reviews_staff_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.weekly_reviews
    ADD CONSTRAINT weekly_reviews_staff_id_fkey FOREIGN KEY (staff_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict iiHS86mw7FrrXk0rOXhiTDR1ppVdWSKMgNdKwyHsvdpsQQG6tnSGbypA0eYj3OG

