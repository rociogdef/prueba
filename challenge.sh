#!/bin/bash
export PGHOST=127.0.0.1
export PGPORT=5432
export PGDATABASE=bd_chbous
export PGUSER=postgres
export PGPASSWORD=facil680

excelfile=$1
export directorio="c:/challenge/"
export dirtemp="c:/dirtemp"
export dir1=c:/challenge
export archivo=registros_incorrectos.csv
procesados="procesados"


if [ -f $excelfile ]
then
   cp $excelfile $dirtemp
else
   echo "No existe el archivo $excelfile"
   exit 1
fi


$directorio/python.exe $directorio/valida_header.py $excelfile

#[ $? -ne 0 ] && echo "Error en la validacion del encabezado" && exit 1
[ $? -ne 0 ] && exit 1

PROC_ID=`psql -f $directorio/carga_y_calculos.sql`
[ $? -ne 0 ] && echo "Existe un error en la carga y calculos del archivo CSV." && exit 1

if [ -d $dirtemp/"procesados/" ]
then
   echo  $dirtemp/"procesados/"
else
   mkdir $dirtemp/"procesados/"
fi


mv $excelfile $dirtemp/"procesados"
retVal=$?
[ $retVal -ne 0 ] && echo "No es posible mover el archivo al directorio de archivos procesados" && exit 1

exit 0