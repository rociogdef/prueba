delete from challenge_bous.adeudos;
delete from challenge_bous.registros_correctos;
delete from challenge_bous.registros_incorrectos;

\copy challenge_bous.adeudos from 'c:/challenge/adeudos_aux.csv' with delimiter ',' csv encoding 'windows-1251';

--Valida un registro
create or replace function valida_registro(reg Record) returns integer as $$
declare
b date;
begin
   
  IF (reg.cliente !~ '^[[:alpha:][:space:]]*$' or reg.cliente IS NULL) THEN
      return -1;
  END IF;

  IF (reg.contrato !~ '^[[:alnum:][:space:]-]*$' or reg.cliente IS NULL) THEN
      return -2;
  END IF;

 
  IF (reg.ciudad !~'^[[:alpha:][:space:]]*$' or reg.ciudad IS NULL) THEN
      return -4;
  END IF;
  
  IF (reg.empresa !~ '^[[:alnum:][:space:]-]*$' or reg.empresa IS NULL) THEN
      return -5;
  end if;

  IF (reg.adeudo !~ '^[0-9]*$' or reg.adeudo IS NULL) THEN
          return -6;
  END IF;

  IF(reg.fecha_compra IS NULL) THEN 
     return -3;
  END IF; 

  b=reg.fecha_compra::date;
  return 0;
  exception when others then
    return -3; 
   
return 0;   
end $$
language plpgsql;


--Lee los registros de la tabla adeudos y los separa en las tablas de registros correctoS e incorrectos
create or replace function valida_datos() returns boolean as $$
declare
reg Record;
val integer;
cur_adeudo Cursor for select * from challenge_bous.adeudos;
BEGIN
  FOR reg in cur_adeudo LOOP
    val = valida_registro(reg);
  
    if val = 0 then
      insert into challenge_bous.registros_correctos VALUES (reg.cliente, reg.contrato, reg.fecha_compra::date, reg.ciudad, reg.empresa, reg.adeudo::decimal);
    else  
     -- RAISE NOTICE 'error % reg %',val, reg.cliente;
      insert into challenge_bous.registros_incorrectos VALUES (reg.cliente, reg.contrato, reg.fecha_compra, reg.ciudad, reg.empresa, reg.adeudo);
    end if;

     
  END LOOP;
  return true;
END
$$ LANGUAGE plpgsql;  

-- Genera los calculos a partir de los registros correctos
create or replace function genera_resultados() returns integer as $$
declare
reg  Record;


BEGIN
  INSERT INTO challenge_bous.adeudos_totales (numero_registros, adeudo_total)
    SELECT  COUNT(*), SUM(adeudo) FROM challenge_bous.registros_correctos RETURNING * into reg;
  --RAISE NOTICE 'Folio % , nregistros %, total adeudo %', reg.folio, reg.numero_registros, reg.adeudo_total;

  INSERT INTO challenge_bous.adeudos_ciudad 
    SELECT reg.folio, ciudad, sum(adeudo), TRUNC((sum(adeudo)/reg.adeudo_total)*100,2) FROM challenge_bous.registros_correctos GROUP BY ciudad;

  INSERT INTO challenge_bous.adeudos_empresa 
    SELECT reg.folio, empresa, sum(adeudo), TRUNC((sum(adeudo)/reg.adeudo_total)*100,2) FROM challenge_bous.registros_correctos GROUP BY empresa;  
 
  RAISE NOTICE 'El folio de ejecución es: %', reg.folio;


 

return reg.folio;
END
$$ LANGUAGE plpgsql;  

select valida_datos();
select genera_resultados();

\copy challenge_bous.registros_incorrectos to 'C:\challenge\Reg_incorrectos.csv' WITH (FORMAT CSV, HEADER);
\copy challenge_bous.registros_correctos to 'C:\challenge\Reg_correctos.csv' WITH (FORMAT CSV, HEADER);
