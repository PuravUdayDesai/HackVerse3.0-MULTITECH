--
-- PostgreSQL database dump
--

-- Dumped from database version 14.2 (Ubuntu 14.2-1.pgdg20.04+1)
-- Dumped by pg_dump version 14.2 (Ubuntu 14.2-1.pgdg20.04+1)

-- Started on 2022-02-27 11:29:42 IST

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'SQL_ASCII';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 4 (class 2615 OID 26288)
-- Name: composter; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA composter;


ALTER SCHEMA composter OWNER TO postgres;

--
-- TOC entry 6 (class 2615 OID 26289)
-- Name: farmer; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA farmer;


ALTER SCHEMA farmer OWNER TO postgres;

--
-- TOC entry 8 (class 2615 OID 26290)
-- Name: gov; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA gov;


ALTER SCHEMA gov OWNER TO postgres;

--
-- TOC entry 5 (class 2615 OID 26291)
-- Name: supplier; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA supplier;


ALTER SCHEMA supplier OWNER TO postgres;

--
-- TOC entry 245 (class 1255 OID 26292)
-- Name: fn_insertComposter(text, text, text, text, text, text, text, text, text, text, text); Type: FUNCTION; Schema: composter; Owner: postgres
--

CREATE FUNCTION composter."fn_insertComposter"("NameIn" text, "ContactNumberIn" text, "EmailIdIn" text, "RegistrationNumberIn" text, "LatitudeIn" text, "LongitudeIn" text, "StateIn" text, "CityIn" text, "AreaIn" text, "StreetIn" text, "PasswordIn" text) RETURNS boolean
    LANGUAGE plpgsql
    AS $$ 
BEGIN
WITH "MainComposter" AS(
INSERT INTO composter.composter_info(name, 
									 contact, 
									 email, 
									 reg_no)
VALUES	(
		"NameIn",
		"ContactNumberIn",
		"EmailIdIn",
		"RegistrationNumberIn"
		)RETURNING id AS "ComposterId"

),
"ComposterLocation" AS(
INSERT INTO composter.composter_loc(id, 
									latitude, 
									longitude, 
									street, 
									area, 
									city, 
									state)
VALUES(
		(SELECT "ComposterId" FROM "MainComposter"),
		"LatitudeIn",
		"LongitudeIn",
		"StreetIn",
		"AreaIn",
		"CityIn",
		"StateIn"
		)RETURNING id AS "ComposterId"
)
INSERT INTO composter.composter_login(id, 
									  username, 
									  password)
VALUES	(
		(SELECT "ComposterId" FROM "ComposterLocation"),
		"EmailIdIn",
		"PasswordIn"
		);

RETURN true;

EXCEPTION WHEN OTHERS THEN
RETURN false;
ROLLBACK;
END;
$$;


ALTER FUNCTION composter."fn_insertComposter"("NameIn" text, "ContactNumberIn" text, "EmailIdIn" text, "RegistrationNumberIn" text, "LatitudeIn" text, "LongitudeIn" text, "StateIn" text, "CityIn" text, "AreaIn" text, "StreetIn" text, "PasswordIn" text) OWNER TO postgres;

--
-- TOC entry 256 (class 1255 OID 26485)
-- Name: fn_addFarmer(text, text, text, text, text, text, text, text, text, text); Type: FUNCTION; Schema: farmer; Owner: postgres
--

CREATE FUNCTION farmer."fn_addFarmer"(farmer_name text, farmer_contact text, survey_id text, password text, latitude text, longitude text, street text, area text, city text, state text) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
--start of INSERT query
BEGIN
WITH  "farmer_main" AS(
INSERT INTO farmer.farmer_info(farmer_name,farmer_contact_number,survey_id) 
VALUES (farmer_name,farmer_contact,survey_id)RETURNING id AS farmer_id),
"farmer_loc" AS( 
INSERT INTO farmer.farmer_location(farmer_id,latitude,longitude,street,area,city,state)
VALUES((SELECT farmer_id FROM farmer_main),latitude,longitude,street,area,city,state) RETURNING farmer_id AS farmer_id)

INSERT INTO farmer.farmer_login(farmer_id,username,password)
VALUES((SELECT farmer_id FROM farmer_loc),survey_id,password);
RETURN true;
EXCEPTION WHEN OTHERS THEN
RETURN false;
ROLLBACK;
END; 

$$;


ALTER FUNCTION farmer."fn_addFarmer"(farmer_name text, farmer_contact text, survey_id text, password text, latitude text, longitude text, street text, area text, city text, state text) OWNER TO postgres;

--
-- TOC entry 254 (class 1255 OID 26294)
-- Name: fn_addSupplier(text, text, text, text, text, text, text, text, text, text, text); Type: FUNCTION; Schema: supplier; Owner: postgres
--

CREATE FUNCTION supplier."fn_addSupplier"(name_in text, contact_number_in text, email_id_in text, reg_no_in text, latitude_in text, longitude_in text, state_in text, city_in text, area_in text, street_in text, password_in text) RETURNS boolean
    LANGUAGE plpgsql
    AS $$--start of INSERT query
BEGIN
--supplier.supplier_info
WITH  "supplier_main" AS(
INSERT INTO supplier.supplier_info (supplier_name,contact,email,reg_no) VALUES(name_in,contact_number_in,email_id_in,reg_no_in) RETURNING id AS supplier_id
                    ),
"supplier_sub" AS(
-- supplier.supplier_loc
INSERT INTO supplier.supplier_loc (id,latitude,longitude,state,city,area,street) VALUES
	((SELECT supplier_id FROM supplier_main),latitude_in,longitude_in,state_in,city_in,area_in,street_in) RETURNING id AS supplier_id
)
INSERT INTO supplier.supplier_login (id,username,password) VALUES ((SELECT supplier_id FROM supplier_sub),email_id_in,password_in);

RETURN true;
EXCEPTION WHEN OTHERS THEN
RETURN false;
ROLLBACK;
END; 

$$;


ALTER FUNCTION supplier."fn_addSupplier"(name_in text, contact_number_in text, email_id_in text, reg_no_in text, latitude_in text, longitude_in text, state_in text, city_in text, area_in text, street_in text, password_in text) OWNER TO postgres;

--
-- TOC entry 255 (class 1255 OID 26295)
-- Name: fn_selectSuppliers(date); Type: FUNCTION; Schema: supplier; Owner: postgres
--

CREATE FUNCTION supplier."fn_selectSuppliers"(date_in date) RETURNS TABLE(init_id bigint, id bigint, supplier_name text, contact text, email text, reg_no text, latitude text, longitude text, state text, city text, area text, street text, dry_waste double precision, wet_waste double precision, date_time timestamp without time zone, description text)
    LANGUAGE sql
    AS $$
SELECT 
supplier.supplier_waste.init_id,
supplier.supplier_info.id,
supplier.supplier_info.supplier_name,
supplier.supplier_info.contact,
supplier.supplier_info.email,
supplier.supplier_info.reg_no,
supplier.supplier_loc.latitude,
supplier.supplier_loc.longitude,
supplier.supplier_loc.state,
supplier.supplier_loc.city,
supplier.supplier_loc.area,
supplier.supplier_loc.street,
supplier.supplier_waste.dry_waste,
supplier.supplier_waste.wet_waste,
supplier.supplier_waste.date_time,
supplier.supplier_waste.description
   FROM supplier.supplier_info
   		JOIN supplier.supplier_loc ON supplier.supplier_info.id=supplier.supplier_loc .id
        JOIN supplier.supplier_waste ON supplier.supplier_info.id=supplier.supplier_waste.id
        WHERE supplier.supplier_info."deleteIndex"=false AND
              supplier.supplier_loc."deleteIndex"=false AND
              supplier.supplier_waste."deleteIndex"=false AND
              date(supplier.supplier_waste.date_time)=date_in 
  
$$;


ALTER FUNCTION supplier."fn_selectSuppliers"(date_in date) OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 213 (class 1259 OID 26296)
-- Name: composter_compost; Type: TABLE; Schema: composter; Owner: postgres
--

CREATE TABLE composter.composter_compost (
    init_id bigint NOT NULL,
    id bigint NOT NULL,
    date_time timestamp without time zone NOT NULL,
    "deleteIndex" boolean DEFAULT false NOT NULL,
    add_or_sub boolean NOT NULL,
    price double precision DEFAULT 0.0 NOT NULL,
    compost_weight double precision DEFAULT 0.0 NOT NULL,
    category text NOT NULL,
    grade text NOT NULL,
    description text,
    entry_date timestamp without time zone NOT NULL,
    inc_id bigint NOT NULL
);


ALTER TABLE composter.composter_compost OWNER TO postgres;

--
-- TOC entry 214 (class 1259 OID 26304)
-- Name: composter_compost_image; Type: TABLE; Schema: composter; Owner: postgres
--

CREATE TABLE composter.composter_compost_image (
    composter_compost_image_id bigint NOT NULL,
    composter_id bigint NOT NULL,
    date_time timestamp without time zone NOT NULL,
    image_url text NOT NULL,
    delete_index boolean DEFAULT false NOT NULL,
    composter_init_id bigint NOT NULL
);


ALTER TABLE composter.composter_compost_image OWNER TO postgres;

--
-- TOC entry 215 (class 1259 OID 26310)
-- Name: composter_compost_image_composter_compost_image_id_seq; Type: SEQUENCE; Schema: composter; Owner: postgres
--

CREATE SEQUENCE composter.composter_compost_image_composter_compost_image_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE composter.composter_compost_image_composter_compost_image_id_seq OWNER TO postgres;

--
-- TOC entry 3484 (class 0 OID 0)
-- Dependencies: 215
-- Name: composter_compost_image_composter_compost_image_id_seq; Type: SEQUENCE OWNED BY; Schema: composter; Owner: postgres
--

ALTER SEQUENCE composter.composter_compost_image_composter_compost_image_id_seq OWNED BY composter.composter_compost_image.composter_compost_image_id;


--
-- TOC entry 241 (class 1259 OID 26465)
-- Name: composter_compost_inc_id_seq; Type: SEQUENCE; Schema: composter; Owner: postgres
--

CREATE SEQUENCE composter.composter_compost_inc_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE composter.composter_compost_inc_id_seq OWNER TO postgres;

--
-- TOC entry 3485 (class 0 OID 0)
-- Dependencies: 241
-- Name: composter_compost_inc_id_seq; Type: SEQUENCE OWNED BY; Schema: composter; Owner: postgres
--

ALTER SEQUENCE composter.composter_compost_inc_id_seq OWNED BY composter.composter_compost.inc_id;


--
-- TOC entry 216 (class 1259 OID 26311)
-- Name: composter_compost_init_id_seq; Type: SEQUENCE; Schema: composter; Owner: postgres
--

CREATE SEQUENCE composter.composter_compost_init_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE composter.composter_compost_init_id_seq OWNER TO postgres;

--
-- TOC entry 3486 (class 0 OID 0)
-- Dependencies: 216
-- Name: composter_compost_init_id_seq; Type: SEQUENCE OWNED BY; Schema: composter; Owner: postgres
--

ALTER SEQUENCE composter.composter_compost_init_id_seq OWNED BY composter.composter_compost.init_id;


--
-- TOC entry 217 (class 1259 OID 26312)
-- Name: composter_info; Type: TABLE; Schema: composter; Owner: postgres
--

CREATE TABLE composter.composter_info (
    id bigint NOT NULL,
    name text NOT NULL,
    contact text NOT NULL,
    email text NOT NULL,
    reg_no text NOT NULL
);


ALTER TABLE composter.composter_info OWNER TO postgres;

--
-- TOC entry 218 (class 1259 OID 26317)
-- Name: composter_info_id_seq; Type: SEQUENCE; Schema: composter; Owner: postgres
--

CREATE SEQUENCE composter.composter_info_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE composter.composter_info_id_seq OWNER TO postgres;

--
-- TOC entry 3487 (class 0 OID 0)
-- Dependencies: 218
-- Name: composter_info_id_seq; Type: SEQUENCE OWNED BY; Schema: composter; Owner: postgres
--

ALTER SEQUENCE composter.composter_info_id_seq OWNED BY composter.composter_info.id;


--
-- TOC entry 219 (class 1259 OID 26318)
-- Name: composter_loc; Type: TABLE; Schema: composter; Owner: postgres
--

CREATE TABLE composter.composter_loc (
    id bigint NOT NULL,
    latitude text NOT NULL,
    longitude text NOT NULL,
    street text NOT NULL,
    area text NOT NULL,
    city text NOT NULL,
    delete_index boolean DEFAULT false NOT NULL,
    state text NOT NULL
);


ALTER TABLE composter.composter_loc OWNER TO postgres;

--
-- TOC entry 220 (class 1259 OID 26324)
-- Name: composter_login; Type: TABLE; Schema: composter; Owner: postgres
--

CREATE TABLE composter.composter_login (
    id bigint NOT NULL,
    username text NOT NULL,
    password text NOT NULL,
    delete_index boolean DEFAULT false NOT NULL
);


ALTER TABLE composter.composter_login OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 26330)
-- Name: farmer_info; Type: TABLE; Schema: farmer; Owner: postgres
--

CREATE TABLE farmer.farmer_info (
    id integer NOT NULL,
    farmer_name text NOT NULL,
    farmer_contact_number text NOT NULL,
    "deleteIndex" boolean DEFAULT false NOT NULL,
    survey_id text NOT NULL
);


ALTER TABLE farmer.farmer_info OWNER TO postgres;

--
-- TOC entry 222 (class 1259 OID 26336)
-- Name: farmer_info_id_seq; Type: SEQUENCE; Schema: farmer; Owner: postgres
--

CREATE SEQUENCE farmer.farmer_info_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE farmer.farmer_info_id_seq OWNER TO postgres;

--
-- TOC entry 3488 (class 0 OID 0)
-- Dependencies: 222
-- Name: farmer_info_id_seq; Type: SEQUENCE OWNED BY; Schema: farmer; Owner: postgres
--

ALTER SEQUENCE farmer.farmer_info_id_seq OWNED BY farmer.farmer_info.id;


--
-- TOC entry 223 (class 1259 OID 26337)
-- Name: farmer_location; Type: TABLE; Schema: farmer; Owner: postgres
--

CREATE TABLE farmer.farmer_location (
    id integer NOT NULL,
    farmer_id integer NOT NULL,
    latitude text NOT NULL,
    longitude text NOT NULL,
    street text NOT NULL,
    area text NOT NULL,
    city text NOT NULL,
    state text NOT NULL,
    "deleteIndex" boolean DEFAULT false NOT NULL
);


ALTER TABLE farmer.farmer_location OWNER TO postgres;

--
-- TOC entry 224 (class 1259 OID 26343)
-- Name: farmer_location_id_seq; Type: SEQUENCE; Schema: farmer; Owner: postgres
--

CREATE SEQUENCE farmer.farmer_location_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE farmer.farmer_location_id_seq OWNER TO postgres;

--
-- TOC entry 3489 (class 0 OID 0)
-- Dependencies: 224
-- Name: farmer_location_id_seq; Type: SEQUENCE OWNED BY; Schema: farmer; Owner: postgres
--

ALTER SEQUENCE farmer.farmer_location_id_seq OWNED BY farmer.farmer_location.id;


--
-- TOC entry 225 (class 1259 OID 26344)
-- Name: farmer_login; Type: TABLE; Schema: farmer; Owner: postgres
--

CREATE TABLE farmer.farmer_login (
    id integer NOT NULL,
    username text NOT NULL,
    password text,
    "deleteIndex" boolean DEFAULT false NOT NULL,
    farmer_id bigint NOT NULL
);


ALTER TABLE farmer.farmer_login OWNER TO postgres;

--
-- TOC entry 226 (class 1259 OID 26350)
-- Name: former_login_id_seq; Type: SEQUENCE; Schema: farmer; Owner: postgres
--

CREATE SEQUENCE farmer.former_login_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE farmer.former_login_id_seq OWNER TO postgres;

--
-- TOC entry 3490 (class 0 OID 0)
-- Dependencies: 226
-- Name: former_login_id_seq; Type: SEQUENCE OWNED BY; Schema: farmer; Owner: postgres
--

ALTER SEQUENCE farmer.former_login_id_seq OWNED BY farmer.farmer_login.id;


--
-- TOC entry 227 (class 1259 OID 26351)
-- Name: funds; Type: TABLE; Schema: gov; Owner: postgres
--

CREATE TABLE gov.funds (
    funds double precision NOT NULL,
    composter_id integer NOT NULL,
    id integer NOT NULL
);


ALTER TABLE gov.funds OWNER TO postgres;

--
-- TOC entry 228 (class 1259 OID 26354)
-- Name: funds_id_seq; Type: SEQUENCE; Schema: gov; Owner: postgres
--

CREATE SEQUENCE gov.funds_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE gov.funds_id_seq OWNER TO postgres;

--
-- TOC entry 3491 (class 0 OID 0)
-- Dependencies: 228
-- Name: funds_id_seq; Type: SEQUENCE OWNED BY; Schema: gov; Owner: postgres
--

ALTER SEQUENCE gov.funds_id_seq OWNED BY gov.funds.id;


--
-- TOC entry 229 (class 1259 OID 26355)
-- Name: composter_farmer_transaction; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.composter_farmer_transaction (
    inc_id bigint NOT NULL,
    composter_compost_init_id bigint NOT NULL,
    composter_id bigint NOT NULL,
    farmer_id bigint NOT NULL,
    farmer_name text NOT NULL,
    farmer_contact text NOT NULL,
    date_time timestamp without time zone NOT NULL,
    category text NOT NULL,
    grade text NOT NULL,
    price double precision NOT NULL,
    compost_weight double precision NOT NULL
);


ALTER TABLE public.composter_farmer_transaction OWNER TO postgres;

--
-- TOC entry 230 (class 1259 OID 26360)
-- Name: composter_farmer_transaction_inc_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.composter_farmer_transaction_inc_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.composter_farmer_transaction_inc_id_seq OWNER TO postgres;

--
-- TOC entry 3492 (class 0 OID 0)
-- Dependencies: 230
-- Name: composter_farmer_transaction_inc_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.composter_farmer_transaction_inc_id_seq OWNED BY public.composter_farmer_transaction.inc_id;


--
-- TOC entry 231 (class 1259 OID 26361)
-- Name: supplier_composter_transaction; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.supplier_composter_transaction (
    inc_id bigint NOT NULL,
    supplier_waste_init_id bigint NOT NULL,
    supplier_id bigint NOT NULL,
    composter_id bigint NOT NULL,
    composter_name text NOT NULL,
    composter_emailid text NOT NULL,
    composter_contact text NOT NULL,
    date_time timestamp without time zone,
    dry_waste bigint NOT NULL,
    wet_waste bigint NOT NULL
);


ALTER TABLE public.supplier_composter_transaction OWNER TO postgres;

--
-- TOC entry 232 (class 1259 OID 26366)
-- Name: supplier_composter_transaction_inc_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.supplier_composter_transaction_inc_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.supplier_composter_transaction_inc_id_seq OWNER TO postgres;

--
-- TOC entry 3493 (class 0 OID 0)
-- Dependencies: 232
-- Name: supplier_composter_transaction_inc_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.supplier_composter_transaction_inc_id_seq OWNED BY public.supplier_composter_transaction.inc_id;


--
-- TOC entry 233 (class 1259 OID 26367)
-- Name: supplier_info; Type: TABLE; Schema: supplier; Owner: postgres
--

CREATE TABLE supplier.supplier_info (
    id bigint NOT NULL,
    supplier_name text NOT NULL,
    contact text NOT NULL,
    email text NOT NULL,
    reg_no text NOT NULL,
    "deleteIndex" boolean DEFAULT false NOT NULL
);


ALTER TABLE supplier.supplier_info OWNER TO postgres;

--
-- TOC entry 234 (class 1259 OID 26373)
-- Name: supplier_info_id_seq; Type: SEQUENCE; Schema: supplier; Owner: postgres
--

CREATE SEQUENCE supplier.supplier_info_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE supplier.supplier_info_id_seq OWNER TO postgres;

--
-- TOC entry 3494 (class 0 OID 0)
-- Dependencies: 234
-- Name: supplier_info_id_seq; Type: SEQUENCE OWNED BY; Schema: supplier; Owner: postgres
--

ALTER SEQUENCE supplier.supplier_info_id_seq OWNED BY supplier.supplier_info.id;


--
-- TOC entry 235 (class 1259 OID 26374)
-- Name: supplier_loc; Type: TABLE; Schema: supplier; Owner: postgres
--

CREATE TABLE supplier.supplier_loc (
    id bigint NOT NULL,
    latitude text NOT NULL,
    longitude text NOT NULL,
    street text NOT NULL,
    area text NOT NULL,
    city text NOT NULL,
    "deleteIndex" boolean DEFAULT false NOT NULL,
    state text NOT NULL
);


ALTER TABLE supplier.supplier_loc OWNER TO postgres;

--
-- TOC entry 236 (class 1259 OID 26380)
-- Name: supplier_login; Type: TABLE; Schema: supplier; Owner: postgres
--

CREATE TABLE supplier.supplier_login (
    id bigint NOT NULL,
    username text NOT NULL,
    password text NOT NULL,
    "deleteIndex" boolean DEFAULT false NOT NULL
);


ALTER TABLE supplier.supplier_login OWNER TO postgres;

--
-- TOC entry 237 (class 1259 OID 26386)
-- Name: supplier_waste; Type: TABLE; Schema: supplier; Owner: postgres
--

CREATE TABLE supplier.supplier_waste (
    init_id bigint NOT NULL,
    id bigint NOT NULL,
    date_time timestamp without time zone NOT NULL,
    dry_waste double precision NOT NULL,
    wet_waste double precision NOT NULL,
    "deleteIndex" boolean DEFAULT false NOT NULL,
    description text,
    "addOrSub" boolean NOT NULL,
    entry_date timestamp without time zone NOT NULL
);


ALTER TABLE supplier.supplier_waste OWNER TO postgres;

--
-- TOC entry 238 (class 1259 OID 26392)
-- Name: supplier_waste_images; Type: TABLE; Schema: supplier; Owner: postgres
--

CREATE TABLE supplier.supplier_waste_images (
    supplier_id bigint NOT NULL,
    date_time timestamp without time zone NOT NULL,
    image_url text NOT NULL,
    supplier_waste_image_id bigint NOT NULL,
    delete_index boolean DEFAULT false NOT NULL
);


ALTER TABLE supplier.supplier_waste_images OWNER TO postgres;

--
-- TOC entry 239 (class 1259 OID 26398)
-- Name: supplier_waste_images_supplier_waste_image_id_seq; Type: SEQUENCE; Schema: supplier; Owner: postgres
--

CREATE SEQUENCE supplier.supplier_waste_images_supplier_waste_image_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE supplier.supplier_waste_images_supplier_waste_image_id_seq OWNER TO postgres;

--
-- TOC entry 3495 (class 0 OID 0)
-- Dependencies: 239
-- Name: supplier_waste_images_supplier_waste_image_id_seq; Type: SEQUENCE OWNED BY; Schema: supplier; Owner: postgres
--

ALTER SEQUENCE supplier.supplier_waste_images_supplier_waste_image_id_seq OWNED BY supplier.supplier_waste_images.supplier_waste_image_id;


--
-- TOC entry 240 (class 1259 OID 26399)
-- Name: supplier_waste_new1_init_id_seq; Type: SEQUENCE; Schema: supplier; Owner: postgres
--

CREATE SEQUENCE supplier.supplier_waste_new1_init_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE supplier.supplier_waste_new1_init_id_seq OWNER TO postgres;

--
-- TOC entry 3496 (class 0 OID 0)
-- Dependencies: 240
-- Name: supplier_waste_new1_init_id_seq; Type: SEQUENCE OWNED BY; Schema: supplier; Owner: postgres
--

ALTER SEQUENCE supplier.supplier_waste_new1_init_id_seq OWNED BY supplier.supplier_waste.init_id;


--
-- TOC entry 3253 (class 2604 OID 26400)
-- Name: composter_compost init_id; Type: DEFAULT; Schema: composter; Owner: postgres
--

ALTER TABLE ONLY composter.composter_compost ALTER COLUMN init_id SET DEFAULT nextval('composter.composter_compost_init_id_seq'::regclass);


--
-- TOC entry 3254 (class 2604 OID 26466)
-- Name: composter_compost inc_id; Type: DEFAULT; Schema: composter; Owner: postgres
--

ALTER TABLE ONLY composter.composter_compost ALTER COLUMN inc_id SET DEFAULT nextval('composter.composter_compost_inc_id_seq'::regclass);


--
-- TOC entry 3256 (class 2604 OID 26401)
-- Name: composter_compost_image composter_compost_image_id; Type: DEFAULT; Schema: composter; Owner: postgres
--

ALTER TABLE ONLY composter.composter_compost_image ALTER COLUMN composter_compost_image_id SET DEFAULT nextval('composter.composter_compost_image_composter_compost_image_id_seq'::regclass);


--
-- TOC entry 3257 (class 2604 OID 26402)
-- Name: composter_info id; Type: DEFAULT; Schema: composter; Owner: postgres
--

ALTER TABLE ONLY composter.composter_info ALTER COLUMN id SET DEFAULT nextval('composter.composter_info_id_seq'::regclass);


--
-- TOC entry 3261 (class 2604 OID 26403)
-- Name: farmer_info id; Type: DEFAULT; Schema: farmer; Owner: postgres
--

ALTER TABLE ONLY farmer.farmer_info ALTER COLUMN id SET DEFAULT nextval('farmer.farmer_info_id_seq'::regclass);


--
-- TOC entry 3263 (class 2604 OID 26404)
-- Name: farmer_location id; Type: DEFAULT; Schema: farmer; Owner: postgres
--

ALTER TABLE ONLY farmer.farmer_location ALTER COLUMN id SET DEFAULT nextval('farmer.farmer_location_id_seq'::regclass);


--
-- TOC entry 3265 (class 2604 OID 26405)
-- Name: farmer_login id; Type: DEFAULT; Schema: farmer; Owner: postgres
--

ALTER TABLE ONLY farmer.farmer_login ALTER COLUMN id SET DEFAULT nextval('farmer.former_login_id_seq'::regclass);


--
-- TOC entry 3266 (class 2604 OID 26406)
-- Name: funds id; Type: DEFAULT; Schema: gov; Owner: postgres
--

ALTER TABLE ONLY gov.funds ALTER COLUMN id SET DEFAULT nextval('gov.funds_id_seq'::regclass);


--
-- TOC entry 3267 (class 2604 OID 26407)
-- Name: composter_farmer_transaction inc_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.composter_farmer_transaction ALTER COLUMN inc_id SET DEFAULT nextval('public.composter_farmer_transaction_inc_id_seq'::regclass);


--
-- TOC entry 3268 (class 2604 OID 26408)
-- Name: supplier_composter_transaction inc_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.supplier_composter_transaction ALTER COLUMN inc_id SET DEFAULT nextval('public.supplier_composter_transaction_inc_id_seq'::regclass);


--
-- TOC entry 3270 (class 2604 OID 26409)
-- Name: supplier_info id; Type: DEFAULT; Schema: supplier; Owner: postgres
--

ALTER TABLE ONLY supplier.supplier_info ALTER COLUMN id SET DEFAULT nextval('supplier.supplier_info_id_seq'::regclass);


--
-- TOC entry 3274 (class 2604 OID 26410)
-- Name: supplier_waste init_id; Type: DEFAULT; Schema: supplier; Owner: postgres
--

ALTER TABLE ONLY supplier.supplier_waste ALTER COLUMN init_id SET DEFAULT nextval('supplier.supplier_waste_new1_init_id_seq'::regclass);


--
-- TOC entry 3276 (class 2604 OID 26411)
-- Name: supplier_waste_images supplier_waste_image_id; Type: DEFAULT; Schema: supplier; Owner: postgres
--

ALTER TABLE ONLY supplier.supplier_waste_images ALTER COLUMN supplier_waste_image_id SET DEFAULT nextval('supplier.supplier_waste_images_supplier_waste_image_id_seq'::regclass);


--
-- TOC entry 3450 (class 0 OID 26296)
-- Dependencies: 213
-- Data for Name: composter_compost; Type: TABLE DATA; Schema: composter; Owner: postgres
--

COPY composter.composter_compost (init_id, id, date_time, "deleteIndex", add_or_sub, price, compost_weight, category, grade, description, entry_date, inc_id) FROM stdin;
\.


--
-- TOC entry 3451 (class 0 OID 26304)
-- Dependencies: 214
-- Data for Name: composter_compost_image; Type: TABLE DATA; Schema: composter; Owner: postgres
--

COPY composter.composter_compost_image (composter_compost_image_id, composter_id, date_time, image_url, delete_index, composter_init_id) FROM stdin;
\.


--
-- TOC entry 3454 (class 0 OID 26312)
-- Dependencies: 217
-- Data for Name: composter_info; Type: TABLE DATA; Schema: composter; Owner: postgres
--

COPY composter.composter_info (id, name, contact, email, reg_no) FROM stdin;
\.


--
-- TOC entry 3456 (class 0 OID 26318)
-- Dependencies: 219
-- Data for Name: composter_loc; Type: TABLE DATA; Schema: composter; Owner: postgres
--

COPY composter.composter_loc (id, latitude, longitude, street, area, city, delete_index, state) FROM stdin;
\.


--
-- TOC entry 3457 (class 0 OID 26324)
-- Dependencies: 220
-- Data for Name: composter_login; Type: TABLE DATA; Schema: composter; Owner: postgres
--

COPY composter.composter_login (id, username, password, delete_index) FROM stdin;
\.


--
-- TOC entry 3458 (class 0 OID 26330)
-- Dependencies: 221
-- Data for Name: farmer_info; Type: TABLE DATA; Schema: farmer; Owner: postgres
--

COPY farmer.farmer_info (id, farmer_name, farmer_contact_number, "deleteIndex", survey_id) FROM stdin;
\.


--
-- TOC entry 3460 (class 0 OID 26337)
-- Dependencies: 223
-- Data for Name: farmer_location; Type: TABLE DATA; Schema: farmer; Owner: postgres
--

COPY farmer.farmer_location (id, farmer_id, latitude, longitude, street, area, city, state, "deleteIndex") FROM stdin;
\.


--
-- TOC entry 3462 (class 0 OID 26344)
-- Dependencies: 225
-- Data for Name: farmer_login; Type: TABLE DATA; Schema: farmer; Owner: postgres
--

COPY farmer.farmer_login (id, username, password, "deleteIndex", farmer_id) FROM stdin;
\.


--
-- TOC entry 3464 (class 0 OID 26351)
-- Dependencies: 227
-- Data for Name: funds; Type: TABLE DATA; Schema: gov; Owner: postgres
--

COPY gov.funds (funds, composter_id, id) FROM stdin;
\.


--
-- TOC entry 3466 (class 0 OID 26355)
-- Dependencies: 229
-- Data for Name: composter_farmer_transaction; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.composter_farmer_transaction (inc_id, composter_compost_init_id, composter_id, farmer_id, farmer_name, farmer_contact, date_time, category, grade, price, compost_weight) FROM stdin;
\.


--
-- TOC entry 3468 (class 0 OID 26361)
-- Dependencies: 231
-- Data for Name: supplier_composter_transaction; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.supplier_composter_transaction (inc_id, supplier_waste_init_id, supplier_id, composter_id, composter_name, composter_emailid, composter_contact, date_time, dry_waste, wet_waste) FROM stdin;
\.


--
-- TOC entry 3470 (class 0 OID 26367)
-- Dependencies: 233
-- Data for Name: supplier_info; Type: TABLE DATA; Schema: supplier; Owner: postgres
--

COPY supplier.supplier_info (id, supplier_name, contact, email, reg_no, "deleteIndex") FROM stdin;
\.


--
-- TOC entry 3472 (class 0 OID 26374)
-- Dependencies: 235
-- Data for Name: supplier_loc; Type: TABLE DATA; Schema: supplier; Owner: postgres
--

COPY supplier.supplier_loc (id, latitude, longitude, street, area, city, "deleteIndex", state) FROM stdin;
\.


--
-- TOC entry 3473 (class 0 OID 26380)
-- Dependencies: 236
-- Data for Name: supplier_login; Type: TABLE DATA; Schema: supplier; Owner: postgres
--

COPY supplier.supplier_login (id, username, password, "deleteIndex") FROM stdin;
\.


--
-- TOC entry 3474 (class 0 OID 26386)
-- Dependencies: 237
-- Data for Name: supplier_waste; Type: TABLE DATA; Schema: supplier; Owner: postgres
--

COPY supplier.supplier_waste (init_id, id, date_time, dry_waste, wet_waste, "deleteIndex", description, "addOrSub", entry_date) FROM stdin;
\.


--
-- TOC entry 3475 (class 0 OID 26392)
-- Dependencies: 238
-- Data for Name: supplier_waste_images; Type: TABLE DATA; Schema: supplier; Owner: postgres
--

COPY supplier.supplier_waste_images (supplier_id, date_time, image_url, supplier_waste_image_id, delete_index) FROM stdin;
\.


--
-- TOC entry 3497 (class 0 OID 0)
-- Dependencies: 215
-- Name: composter_compost_image_composter_compost_image_id_seq; Type: SEQUENCE SET; Schema: composter; Owner: postgres
--

SELECT pg_catalog.setval('composter.composter_compost_image_composter_compost_image_id_seq', 5, true);


--
-- TOC entry 3498 (class 0 OID 0)
-- Dependencies: 241
-- Name: composter_compost_inc_id_seq; Type: SEQUENCE SET; Schema: composter; Owner: postgres
--

SELECT pg_catalog.setval('composter.composter_compost_inc_id_seq', 27, true);


--
-- TOC entry 3499 (class 0 OID 0)
-- Dependencies: 216
-- Name: composter_compost_init_id_seq; Type: SEQUENCE SET; Schema: composter; Owner: postgres
--

SELECT pg_catalog.setval('composter.composter_compost_init_id_seq', 12, true);


--
-- TOC entry 3500 (class 0 OID 0)
-- Dependencies: 218
-- Name: composter_info_id_seq; Type: SEQUENCE SET; Schema: composter; Owner: postgres
--

SELECT pg_catalog.setval('composter.composter_info_id_seq', 7, true);


--
-- TOC entry 3501 (class 0 OID 0)
-- Dependencies: 222
-- Name: farmer_info_id_seq; Type: SEQUENCE SET; Schema: farmer; Owner: postgres
--

SELECT pg_catalog.setval('farmer.farmer_info_id_seq', 8, true);


--
-- TOC entry 3502 (class 0 OID 0)
-- Dependencies: 224
-- Name: farmer_location_id_seq; Type: SEQUENCE SET; Schema: farmer; Owner: postgres
--

SELECT pg_catalog.setval('farmer.farmer_location_id_seq', 8, true);


--
-- TOC entry 3503 (class 0 OID 0)
-- Dependencies: 226
-- Name: former_login_id_seq; Type: SEQUENCE SET; Schema: farmer; Owner: postgres
--

SELECT pg_catalog.setval('farmer.former_login_id_seq', 8, true);


--
-- TOC entry 3504 (class 0 OID 0)
-- Dependencies: 228
-- Name: funds_id_seq; Type: SEQUENCE SET; Schema: gov; Owner: postgres
--

SELECT pg_catalog.setval('gov.funds_id_seq', 11, true);


--
-- TOC entry 3505 (class 0 OID 0)
-- Dependencies: 230
-- Name: composter_farmer_transaction_inc_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.composter_farmer_transaction_inc_id_seq', 12, true);


--
-- TOC entry 3506 (class 0 OID 0)
-- Dependencies: 232
-- Name: supplier_composter_transaction_inc_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.supplier_composter_transaction_inc_id_seq', 3, true);


--
-- TOC entry 3507 (class 0 OID 0)
-- Dependencies: 234
-- Name: supplier_info_id_seq; Type: SEQUENCE SET; Schema: supplier; Owner: postgres
--

SELECT pg_catalog.setval('supplier.supplier_info_id_seq', 12, true);


--
-- TOC entry 3508 (class 0 OID 0)
-- Dependencies: 239
-- Name: supplier_waste_images_supplier_waste_image_id_seq; Type: SEQUENCE SET; Schema: supplier; Owner: postgres
--

SELECT pg_catalog.setval('supplier.supplier_waste_images_supplier_waste_image_id_seq', 13, true);


--
-- TOC entry 3509 (class 0 OID 0)
-- Dependencies: 240
-- Name: supplier_waste_new1_init_id_seq; Type: SEQUENCE SET; Schema: supplier; Owner: postgres
--

SELECT pg_catalog.setval('supplier.supplier_waste_new1_init_id_seq', 10, true);


--
-- TOC entry 3281 (class 2606 OID 26413)
-- Name: composter_info U_RegistrationNumber; Type: CONSTRAINT; Schema: composter; Owner: postgres
--

ALTER TABLE ONLY composter.composter_info
    ADD CONSTRAINT "U_RegistrationNumber" UNIQUE (reg_no);


--
-- TOC entry 3279 (class 2606 OID 26415)
-- Name: composter_compost_image composter_compost_image_pkey; Type: CONSTRAINT; Schema: composter; Owner: postgres
--

ALTER TABLE ONLY composter.composter_compost_image
    ADD CONSTRAINT composter_compost_image_pkey PRIMARY KEY (composter_compost_image_id);


--
-- TOC entry 3283 (class 2606 OID 26417)
-- Name: composter_info composter_info_pkey; Type: CONSTRAINT; Schema: composter; Owner: postgres
--

ALTER TABLE ONLY composter.composter_info
    ADD CONSTRAINT composter_info_pkey PRIMARY KEY (id);


--
-- TOC entry 3285 (class 2606 OID 26419)
-- Name: farmer_info farmer_info_pkey; Type: CONSTRAINT; Schema: farmer; Owner: postgres
--

ALTER TABLE ONLY farmer.farmer_info
    ADD CONSTRAINT farmer_info_pkey PRIMARY KEY (id);


--
-- TOC entry 3287 (class 2606 OID 26421)
-- Name: farmer_location farmer_location_pkey; Type: CONSTRAINT; Schema: farmer; Owner: postgres
--

ALTER TABLE ONLY farmer.farmer_location
    ADD CONSTRAINT farmer_location_pkey PRIMARY KEY (id);


--
-- TOC entry 3291 (class 2606 OID 26423)
-- Name: farmer_login former_login_pkey; Type: CONSTRAINT; Schema: farmer; Owner: postgres
--

ALTER TABLE ONLY farmer.farmer_login
    ADD CONSTRAINT former_login_pkey PRIMARY KEY (id);


--
-- TOC entry 3294 (class 2606 OID 26425)
-- Name: composter_farmer_transaction composter_farmer_transaction_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.composter_farmer_transaction
    ADD CONSTRAINT composter_farmer_transaction_pkey PRIMARY KEY (inc_id);


--
-- TOC entry 3296 (class 2606 OID 26427)
-- Name: supplier_composter_transaction supplier_composter_transaction_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.supplier_composter_transaction
    ADD CONSTRAINT supplier_composter_transaction_pkey PRIMARY KEY (inc_id);


--
-- TOC entry 3298 (class 2606 OID 26429)
-- Name: supplier_info UQ_email; Type: CONSTRAINT; Schema: supplier; Owner: postgres
--

ALTER TABLE ONLY supplier.supplier_info
    ADD CONSTRAINT "UQ_email" UNIQUE (email);


--
-- TOC entry 3300 (class 2606 OID 26431)
-- Name: supplier_info UQ_reg_no; Type: CONSTRAINT; Schema: supplier; Owner: postgres
--

ALTER TABLE ONLY supplier.supplier_info
    ADD CONSTRAINT "UQ_reg_no" UNIQUE (reg_no);


--
-- TOC entry 3302 (class 2606 OID 26433)
-- Name: supplier_info supplier_info_pkey; Type: CONSTRAINT; Schema: supplier; Owner: postgres
--

ALTER TABLE ONLY supplier.supplier_info
    ADD CONSTRAINT supplier_info_pkey PRIMARY KEY (id);


--
-- TOC entry 3304 (class 2606 OID 26435)
-- Name: supplier_waste_images supplier_waste_images_pkey; Type: CONSTRAINT; Schema: supplier; Owner: postgres
--

ALTER TABLE ONLY supplier.supplier_waste_images
    ADD CONSTRAINT supplier_waste_images_pkey PRIMARY KEY (supplier_waste_image_id);


--
-- TOC entry 3277 (class 1259 OID 26436)
-- Name: fki_FK_compost_info; Type: INDEX; Schema: composter; Owner: postgres
--

CREATE INDEX "fki_FK_compost_info" ON composter.composter_compost USING btree (id);


--
-- TOC entry 3289 (class 1259 OID 26479)
-- Name: fki_FK_farmer_login_info; Type: INDEX; Schema: farmer; Owner: postgres
--

CREATE INDEX "fki_FK_farmer_login_info" ON farmer.farmer_login USING btree (farmer_id);


--
-- TOC entry 3288 (class 1259 OID 26437)
-- Name: fki_FK_location_info; Type: INDEX; Schema: farmer; Owner: postgres
--

CREATE INDEX "fki_FK_location_info" ON farmer.farmer_location USING btree (farmer_id);


--
-- TOC entry 3292 (class 1259 OID 26438)
-- Name: fki_FK_gov_composter; Type: INDEX; Schema: gov; Owner: postgres
--

CREATE INDEX "fki_FK_gov_composter" ON gov.funds USING btree (composter_id);


--
-- TOC entry 3305 (class 2606 OID 26439)
-- Name: composter_compost FK_compost_info; Type: FK CONSTRAINT; Schema: composter; Owner: postgres
--

ALTER TABLE ONLY composter.composter_compost
    ADD CONSTRAINT "FK_compost_info" FOREIGN KEY (id) REFERENCES composter.composter_info(id);


--
-- TOC entry 3307 (class 2606 OID 26474)
-- Name: farmer_login FK_farmer_login_info; Type: FK CONSTRAINT; Schema: farmer; Owner: postgres
--

ALTER TABLE ONLY farmer.farmer_login
    ADD CONSTRAINT "FK_farmer_login_info" FOREIGN KEY (farmer_id) REFERENCES farmer.farmer_info(id);


--
-- TOC entry 3306 (class 2606 OID 26444)
-- Name: farmer_location FK_location_info; Type: FK CONSTRAINT; Schema: farmer; Owner: postgres
--

ALTER TABLE ONLY farmer.farmer_location
    ADD CONSTRAINT "FK_location_info" FOREIGN KEY (farmer_id) REFERENCES farmer.farmer_info(id);


--
-- TOC entry 3308 (class 2606 OID 26449)
-- Name: supplier_loc supplier_id; Type: FK CONSTRAINT; Schema: supplier; Owner: postgres
--

ALTER TABLE ONLY supplier.supplier_loc
    ADD CONSTRAINT supplier_id FOREIGN KEY (id) REFERENCES supplier.supplier_info(id);


--
-- TOC entry 3309 (class 2606 OID 26454)
-- Name: supplier_login supplier_id; Type: FK CONSTRAINT; Schema: supplier; Owner: postgres
--

ALTER TABLE ONLY supplier.supplier_login
    ADD CONSTRAINT supplier_id FOREIGN KEY (id) REFERENCES supplier.supplier_info(id);


--
-- TOC entry 3310 (class 2606 OID 26459)
-- Name: supplier_waste supplier_id; Type: FK CONSTRAINT; Schema: supplier; Owner: postgres
--

ALTER TABLE ONLY supplier.supplier_waste
    ADD CONSTRAINT supplier_id FOREIGN KEY (id) REFERENCES supplier.supplier_info(id);


-- Completed on 2022-02-27 11:29:43 IST

--
-- PostgreSQL database dump complete
--

