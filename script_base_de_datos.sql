CREATE DATABASE  bd_chbous;
CREATE SCHEMA IF NOT EXISTS challenge_bous;


CREATE TABLE  IF NOT EXISTS challenge_bous.adeudos
(
    cliente character varying,
    contrato character varying,
    fecha_compra character varying,
    ciudad character varying,
    empresa character varying,
    adeudo character varying
);

CREATE TABLE  IF NOT EXISTS challenge_bous.registros_correctos
(
    cliente character varying,
    contrato character varying,
    fecha_compra date,
    ciudad character varying,
    empresa character varying,
    adeudo  decimal
);

CREATE TABLE  IF NOT EXISTS challenge_bous.registros_incorrectos
(
    cliente character varying,
    contrato character varying,
    fecha_compra character varying,
    ciudad character varying,
    empresa character varying,
    adeudo character varying
);

CREATE TABLE IF NOT EXISTS challenge_bous.adeudos_totales
(
    folio serial PRIMARY KEY,
    numero_registros integer,
    adeudo_total decimal
);    
     
CREATE TABLE IF NOT EXISTS challenge_bous.adeudos_ciudad
( 
    folio integer,
    ciudad character varying,
    adeudo_ciudad decimal,
    porcentaje_ciudad decimal
);    

CREATE TABLE IF NOT EXISTS challenge_bous.adeudos_empresa
( 
    folio integer,
    empresa character varying,
    adeudo_empresa decimal,
    porcentaje_empresa decimal
);    



