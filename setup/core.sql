--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = public, pg_catalog;

DROP INDEX public.signersaccount;
DROP INDEX public.priceindex;
DROP INDEX public.paysissuerindex;
DROP INDEX public.ledgersbyseq;
DROP INDEX public.getsissuerindex;
DROP INDEX public.accountlines;
DROP INDEX public.accountbalances;
ALTER TABLE ONLY public.txhistory DROP CONSTRAINT txhistory_pkey;
ALTER TABLE ONLY public.txhistory DROP CONSTRAINT txhistory_ledgerseq_txindex_key;
ALTER TABLE ONLY public.trustlines DROP CONSTRAINT trustlines_pkey;
ALTER TABLE ONLY public.storestate DROP CONSTRAINT storestate_pkey;
ALTER TABLE ONLY public.signers DROP CONSTRAINT signers_pkey;
ALTER TABLE ONLY public.peers DROP CONSTRAINT peers_pkey;
ALTER TABLE ONLY public.offers DROP CONSTRAINT offers_pkey;
ALTER TABLE ONLY public.ledgerheaders DROP CONSTRAINT ledgerheaders_pkey;
ALTER TABLE ONLY public.ledgerheaders DROP CONSTRAINT ledgerheaders_ledgerseq_key;
ALTER TABLE ONLY public.accounts DROP CONSTRAINT accounts_pkey;
DROP TABLE public.txhistory;
DROP TABLE public.trustlines;
DROP TABLE public.storestate;
DROP TABLE public.signers;
DROP TABLE public.peers;
DROP TABLE public.offers;
DROP TABLE public.ledgerheaders;
DROP TABLE public.accounts;
DROP EXTENSION plpgsql;
DROP SCHEMA public;
--
-- Name: public; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA public;


--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA public IS 'standard public schema';


--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: accounts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE accounts (
    accountid character varying(51) NOT NULL,
    balance bigint NOT NULL,
    seqnum bigint NOT NULL,
    numsubentries integer NOT NULL,
    inflationdest character varying(51),
    homedomain character varying(32),
    thresholds text,
    flags integer NOT NULL,
    CONSTRAINT accounts_balance_check CHECK ((balance >= 0)),
    CONSTRAINT accounts_numsubentries_check CHECK ((numsubentries >= 0))
);


--
-- Name: ledgerheaders; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE ledgerheaders (
    ledgerhash character(64) NOT NULL,
    prevhash character(64) NOT NULL,
    bucketlisthash character(64) NOT NULL,
    ledgerseq integer,
    closetime bigint NOT NULL,
    data text NOT NULL,
    CONSTRAINT ledgerheaders_closetime_check CHECK ((closetime >= 0)),
    CONSTRAINT ledgerheaders_ledgerseq_check CHECK ((ledgerseq >= 0))
);


--
-- Name: offers; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE offers (
    accountid character varying(51) NOT NULL,
    offerid bigint NOT NULL,
    paysalphanumcurrency character varying(4),
    paysissuer character varying(51),
    getsalphanumcurrency character varying(4),
    getsissuer character varying(51),
    amount bigint NOT NULL,
    pricen integer NOT NULL,
    priced integer NOT NULL,
    price bigint NOT NULL,
    CONSTRAINT offers_amount_check CHECK ((amount >= 0)),
    CONSTRAINT offers_offerid_check CHECK ((offerid >= 0))
);


--
-- Name: peers; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE peers (
    ip character varying(15) NOT NULL,
    port integer DEFAULT 0 NOT NULL,
    nextattempt timestamp without time zone NOT NULL,
    numfailures integer DEFAULT 0 NOT NULL,
    rank integer DEFAULT 0 NOT NULL,
    CONSTRAINT peers_numfailures_check CHECK ((numfailures >= 0)),
    CONSTRAINT peers_port_check CHECK (((port > 0) AND (port <= 65535))),
    CONSTRAINT peers_rank_check CHECK ((rank >= 0))
);


--
-- Name: signers; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE signers (
    accountid character varying(51) NOT NULL,
    publickey character varying(51) NOT NULL,
    weight integer NOT NULL
);


--
-- Name: storestate; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE storestate (
    statename character(32) NOT NULL,
    state text
);


--
-- Name: trustlines; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE trustlines (
    accountid character varying(51) NOT NULL,
    issuer character varying(51) NOT NULL,
    alphanumcurrency character varying(4) NOT NULL,
    tlimit bigint DEFAULT 0 NOT NULL,
    balance bigint DEFAULT 0 NOT NULL,
    flags integer NOT NULL,
    CONSTRAINT trustlines_balance_check CHECK ((balance >= 0)),
    CONSTRAINT trustlines_tlimit_check CHECK ((tlimit >= 0))
);


--
-- Name: txhistory; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE txhistory (
    txid character(64) NOT NULL,
    ledgerseq integer NOT NULL,
    txindex integer NOT NULL,
    txbody text NOT NULL,
    txresult text NOT NULL,
    txmeta text NOT NULL,
    CONSTRAINT txhistory_ledgerseq_check CHECK ((ledgerseq >= 0))
);


--
-- Data for Name: accounts; Type: TABLE DATA; Schema: public; Owner: -
--

COPY accounts (accountid, balance, seqnum, numsubentries, inflationdest, homedomain, thresholds, flags) FROM stdin;
gspbxqXqEUZkiCCEFFCN9Vu4FLucdjLLdLcsV6E82Qc1T7ehsTC	99999989999999990	1	0	\N		01000000	0
gvzUnhCUGULxYq7irGK2Ng1uWRrrgvB2VPDJXTwkeHe9dvS3YP	9999999970	12884901891	2	\N		01000202	0
\.


--
-- Data for Name: ledgerheaders; Type: TABLE DATA; Schema: public; Owner: -
--

COPY ledgerheaders (ledgerhash, prevhash, bucketlisthash, ledgerseq, closetime, data) FROM stdin;
41310a0181a3a82ff13c049369504e978734cf17da1baf02f7e4d881e8608371	0000000000000000000000000000000000000000000000000000000000000000	e71064e28d0740ac27cf07b267200ea9b8916ad1242195c015fa3012086588d3	1	0	AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA5xBk4o0HQKwnzweyZyAOqbiRatEkIZXAFfowEghliNMAAAABAAAAAAAAAAABY0V4XYoAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACgCYloA=
d0f4702d2dbcba7c52fcc0f0cefc4c1aab457aeb97350ef7f8674f47e4b42268	41310a0181a3a82ff13c049369504e978734cf17da1baf02f7e4d881e8608371	24128cf784e4c94f58a5a72a5036a54e82b2e37c1b1b327bd8af8ab48684abf6	2	1433541183	QTEKAYGjqC/xPASTaVBOl4c0zxfaG68C9+TYgehgg3HWnizXf2VvYXCoygkt/wDezda8dXZTRIUXo6e9UAqQU+OwxEKY/BwUmvv0yJlvuSQnrkHkZJuTTKSVmRt4UrhVJBKM94TkyU9YpacqUDalToKy43wbGzJ72K+KtIaEq/YAAAACAAAAAFVyGj8BY0V4XYoAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACgCYloA=
310973d0ba49af5bf4422874480c0ea29a1ccbcd61ad1a814357d82eb612ae4f	d0f4702d2dbcba7c52fcc0f0cefc4c1aab457aeb97350ef7f8674f47e4b42268	10091acefa63b60a56546e1c0e07d87c65b29d3716f687b9f8017cc077e86005	3	1433541184	0PRwLS28unxS/MDwzvxMGqtFeuuXNQ73+GdPR+S0ImiHV6gaqQDaoxAbETs6xc6tgDQ2N/NOZaL4Zoi5Lna+DSvuFyXWSIMvtE19xAAWZ2ym0NNcYJS/LGVejA74Gnz3EAkazvpjtgpWVG4cDgfYfGWynTcW9oe5+AF8wHfoYAUAAAADAAAAAFVyGkABY0V4XYoAAAAAAAAAAAAKAAAAAAAAAAAAAAAAAAAACgCYloA=
dad2fee1cede7fea2b6dc0dfa359333e1fb50b7ac48d125d0e9e6d127fde2187	310973d0ba49af5bf4422874480c0ea29a1ccbcd61ad1a814357d82eb612ae4f	40c0fea04c0e48d984f5b7e5a5cdf2fa7b935a51eae372075ee12f847abdfb93	4	1433541185	MQlz0LpJr1v0Qih0SAwOopocy81hrRqBQ1fYLrYSrk8eTZm476ptvtdnVCaBuEi4/wGvXIZnR8O3bLUpOFq6h8+RI9TlTExwd7TqlMWzE4gl4JwBZb4VmtEHXPl9TReCQMD+oEwOSNmE9bflpc3y+nuTWlHq43IHXuEvhHq9+5MAAAAEAAAAAFVyGkEBY0V4XYoAAAAAAAAAAAAoAAAAAAAAAAAAAAAAAAAACgCYloA=
\.


--
-- Data for Name: offers; Type: TABLE DATA; Schema: public; Owner: -
--

COPY offers (accountid, offerid, paysalphanumcurrency, paysissuer, getsalphanumcurrency, getsissuer, amount, pricen, priced, price) FROM stdin;
\.


--
-- Data for Name: peers; Type: TABLE DATA; Schema: public; Owner: -
--

COPY peers (ip, port, nextattempt, numfailures, rank) FROM stdin;
\.


--
-- Data for Name: signers; Type: TABLE DATA; Schema: public; Owner: -
--

COPY signers (accountid, publickey, weight) FROM stdin;
gvzUnhCUGULxYq7irGK2Ng1uWRrrgvB2VPDJXTwkeHe9dvS3YP	gsrdnm5JmRFkepYJij3M4mMg593jpuqDmUXe3EvqN5wj8jWG5MV	1
gvzUnhCUGULxYq7irGK2Ng1uWRrrgvB2VPDJXTwkeHe9dvS3YP	gsZrG87FxpoRr4ZTB4PnyYxEGEf4ihJQk9RbfNSwKDNHD85Cqba	1
\.


--
-- Data for Name: storestate; Type: TABLE DATA; Schema: public; Owner: -
--

COPY storestate (statename, state) FROM stdin;
databaseinitialized             	true
forcescponnextlaunch            	false
lastclosedledger                	dad2fee1cede7fea2b6dc0dfa359333e1fb50b7ac48d125d0e9e6d127fde2187
historyarchivestate             	{\n    "version": 0,\n    "currentLedger": 4,\n    "currentBuckets": [\n        {\n            "curr": "3f2c61a77f9a6be8e9df5199a6a1b2f8c7e0065d3f74f0714bf50672462a9871",\n            "next": {\n                "state": 0\n            },\n            "snap": "28c7708b4e2963e17dda45e8287e02323d6cdabe571a199419f8e6b648360414"\n        },\n        {\n            "curr": "dbbd826d458ade51d4a8cfc70260528fb788d3eb80c9a73e49a4cbba1a8f566c",\n            "next": {\n                "state": 1,\n                "output": "28c7708b4e2963e17dda45e8287e02323d6cdabe571a199419f8e6b648360414"\n            },\n            "snap": "0000000000000000000000000000000000000000000000000000000000000000"\n        },\n        {\n            "curr": "0000000000000000000000000000000000000000000000000000000000000000",\n            "next": {\n                "state": 0\n            },\n            "snap": "0000000000000000000000000000000000000000000000000000000000000000"\n        },\n        {\n            "curr": "0000000000000000000000000000000000000000000000000000000000000000",\n            "next": {\n                "state": 0\n            },\n            "snap": "0000000000000000000000000000000000000000000000000000000000000000"\n        },\n        {\n            "curr": "0000000000000000000000000000000000000000000000000000000000000000",\n            "next": {\n                "state": 0\n            },\n            "snap": "0000000000000000000000000000000000000000000000000000000000000000"\n        },\n        {\n            "curr": "0000000000000000000000000000000000000000000000000000000000000000",\n            "next": {\n                "state": 0\n            },\n            "snap": "0000000000000000000000000000000000000000000000000000000000000000"\n        },\n        {\n            "curr": "0000000000000000000000000000000000000000000000000000000000000000",\n            "next": {\n                "state": 0\n            },\n            "snap": "0000000000000000000000000000000000000000000000000000000000000000"\n        },\n        {\n            "curr": "0000000000000000000000000000000000000000000000000000000000000000",\n            "next": {\n                "state": 0\n            },\n            "snap": "0000000000000000000000000000000000000000000000000000000000000000"\n        },\n        {\n            "curr": "0000000000000000000000000000000000000000000000000000000000000000",\n            "next": {\n                "state": 0\n            },\n            "snap": "0000000000000000000000000000000000000000000000000000000000000000"\n        },\n        {\n            "curr": "0000000000000000000000000000000000000000000000000000000000000000",\n            "next": {\n                "state": 0\n            },\n            "snap": "0000000000000000000000000000000000000000000000000000000000000000"\n        },\n        {\n            "curr": "0000000000000000000000000000000000000000000000000000000000000000",\n            "next": {\n                "state": 0\n            },\n            "snap": "0000000000000000000000000000000000000000000000000000000000000000"\n        }\n    ]\n}
\.


--
-- Data for Name: trustlines; Type: TABLE DATA; Schema: public; Owner: -
--

COPY trustlines (accountid, issuer, alphanumcurrency, tlimit, balance, flags) FROM stdin;
\.


--
-- Data for Name: txhistory; Type: TABLE DATA; Schema: public; Owner: -
--

COPY txhistory (txid, ledgerseq, txindex, txbody, txresult, txmeta) FROM stdin;
22032a3050968119db445ecb83a425927c3b94fa6740f58dfa0f3150fec57dca	3	1	iZsoQO1WNsVt3F8Usjl1958bojiNJpTkxW7N3clg5e8AAAAKAAAAAAAAAAEAAAAAAAAAAAAAAAEAAAAAAAAAAHqU+VJ1nnP8r/7f4kE2J/XZthwovrXlAhCOjqr84fwwAAAAAlQL5AAAAAABiZsoQMf38F7+r6C3jEGwByJRU36cbLpnwbZZ3GMwtkBjDFSely9oPiwunEyS2EZXmFAjsRA/MGgAIFGn6blEqh88sw0=	IgMqMFCWgRnbRF7Lg6Qlknw7lPpnQPWN+g8xUP7FfcoAAAAAAAAACgAAAAAAAAABAAAAAAAAAAAAAAAA	AAAAAgAAAAAAAAAAepT5UnWec/yv/t/iQTYn9dm2HCi+teUCEI6Oqvzh/DAAAAACVAvkAAAAAAMAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAQAAAACJmyhA7VY2xW3cXxSyOXX3nxuiOI0mlOTFbs3dyWDl7wFjRXYJfhv2AAAAAAAAAAEAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAA=
5ef9465a257e7b6335e72164a14367fa12adc18e5e27b7797ef00bdc8565e8df	4	1	epT5UnWec/yv/t/iQTYn9dm2HCi+teUCEI6Oqvzh/DAAAAAKAAAAAwAAAAEAAAAAAAAAAAAAAAEAAAAAAAAABAAAAAAAAAABAAAAAAAAAAEAAAAAAAAAAAAAAAAAAAAB3am2U85CInpUJV/3yF1KdK/VEPOqqayL7TSdS/jhyMAAAAABAAAAAXqU+VL5Sw0HGz+ePJZebxhQrRwMdnp9MCCz69nkS9SHL2fAKjX0qx+uoXQh7UG7Sc4FxeJH62oY4YU7TY1gYKekRCYF	XvlGWiV+e2M15yFkoUNn+hKtwY5eJ7d5fvAL3IVl6N8AAAAAAAAACgAAAAAAAAABAAAAAAAAAAQAAAAA	AAAAAQAAAAEAAAAAepT5UnWec/yv/t/iQTYn9dm2HCi+teUCEI6Oqvzh/DAAAAACVAvj9gAAAAMAAAABAAAAAQAAAAAAAAAAAQAAAAAAAAAAAAAB3am2U85CInpUJV/3yF1KdK/VEPOqqayL7TSdS/jhyMAAAAAB
30cd73d20e18957ca469d7058901ae7530ce119ba4703056db46546a005e14f6	4	2	epT5UnWec/yv/t/iQTYn9dm2HCi+teUCEI6Oqvzh/DAAAAAKAAAAAwAAAAIAAAAAAAAAAAAAAAEAAAAAAAAABAAAAAAAAAABAAAAAAAAAAEAAAAAAAAAAAAAAAAAAAABzeS554NEC6o5XbkfY+Efq2Ffgc1yDefYFF1Ozzdpk9UAAAABAAAAAXqU+VLYzQB2CrDcG0IPKZ6rOpOZWpAPNZTi6RTZ6ilwlbEivxKgesow3KikchkNbbwAAtVEu8dWGam7Ryhz9oklYlcE	MM1z0g4YlXykadcFiQGudTDOEZukcDBW20ZUagBeFPYAAAAAAAAACgAAAAAAAAABAAAAAAAAAAQAAAAA	AAAAAQAAAAEAAAAAepT5UnWec/yv/t/iQTYn9dm2HCi+teUCEI6Oqvzh/DAAAAACVAvj7AAAAAMAAAACAAAAAgAAAAAAAAAAAQAAAAAAAAAAAAACzeS554NEC6o5XbkfY+Efq2Ffgc1yDefYFF1Ozzdpk9UAAAAB3am2U85CInpUJV/3yF1KdK/VEPOqqayL7TSdS/jhyMAAAAAB
15441b27c0a968bc780f61e5ebabe0dac020c33ba7ed688ab99c6a514f7668ae	4	3	epT5UnWec/yv/t/iQTYn9dm2HCi+teUCEI6Oqvzh/DAAAAAKAAAAAwAAAAMAAAAAAAAAAAAAAAEAAAAAAAAABAAAAAAAAAABAAAAAAAAAAEAAAAAAAAAAQEAAgIAAAAAAAAAAAAAAAF6lPlSrDVG2KDolnlVfMqq7ylyAT9XPHCtoRlK1xH3WTEZllxyktZP59wgK+CSTdFlYuavqWaQuk/R98o7lDHsyoXCDw==	FUQbJ8CpaLx4D2Hl66vg2sAgwzun7WiKuZxqUU92aK4AAAAAAAAACgAAAAAAAAABAAAAAAAAAAQAAAAA	AAAAAQAAAAEAAAAAepT5UnWec/yv/t/iQTYn9dm2HCi+teUCEI6Oqvzh/DAAAAACVAvj4gAAAAMAAAADAAAAAgAAAAAAAAAAAQACAgAAAAAAAAACzeS554NEC6o5XbkfY+Efq2Ffgc1yDefYFF1Ozzdpk9UAAAAB3am2U85CInpUJV/3yF1KdK/VEPOqqayL7TSdS/jhyMAAAAAB
\.


--
-- Name: accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY accounts
    ADD CONSTRAINT accounts_pkey PRIMARY KEY (accountid);


--
-- Name: ledgerheaders_ledgerseq_key; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY ledgerheaders
    ADD CONSTRAINT ledgerheaders_ledgerseq_key UNIQUE (ledgerseq);


--
-- Name: ledgerheaders_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY ledgerheaders
    ADD CONSTRAINT ledgerheaders_pkey PRIMARY KEY (ledgerhash);


--
-- Name: offers_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY offers
    ADD CONSTRAINT offers_pkey PRIMARY KEY (offerid);


--
-- Name: peers_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY peers
    ADD CONSTRAINT peers_pkey PRIMARY KEY (ip, port);


--
-- Name: signers_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY signers
    ADD CONSTRAINT signers_pkey PRIMARY KEY (accountid, publickey);


--
-- Name: storestate_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY storestate
    ADD CONSTRAINT storestate_pkey PRIMARY KEY (statename);


--
-- Name: trustlines_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY trustlines
    ADD CONSTRAINT trustlines_pkey PRIMARY KEY (accountid, issuer, alphanumcurrency);


--
-- Name: txhistory_ledgerseq_txindex_key; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY txhistory
    ADD CONSTRAINT txhistory_ledgerseq_txindex_key UNIQUE (ledgerseq, txindex);


--
-- Name: txhistory_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY txhistory
    ADD CONSTRAINT txhistory_pkey PRIMARY KEY (txid, ledgerseq);


--
-- Name: accountbalances; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX accountbalances ON accounts USING btree (balance);


--
-- Name: accountlines; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX accountlines ON trustlines USING btree (accountid);


--
-- Name: getsissuerindex; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX getsissuerindex ON offers USING btree (getsissuer);


--
-- Name: ledgersbyseq; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX ledgersbyseq ON ledgerheaders USING btree (ledgerseq);


--
-- Name: paysissuerindex; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX paysissuerindex ON offers USING btree (paysissuer);


--
-- Name: priceindex; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX priceindex ON offers USING btree (price);


--
-- Name: signersaccount; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX signersaccount ON signers USING btree (accountid);


--
-- Name: public; Type: ACL; Schema: -; Owner: -
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM nullstyle;
GRANT ALL ON SCHEMA public TO nullstyle;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

