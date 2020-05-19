CREATE SEQUENCE url_id_seq
    INCREMENT 1
    START 1
    MINVALUE 1
    MAXVALUE 2147483647
    CACHE 1;

CREATE TABLE url
(
    url character varying(2084) NOT NULL,
    id integer NOT NULL DEFAULT nextval('url_id_seq'::regclass),
    CONSTRAINT url_pkey PRIMARY KEY (id)
);