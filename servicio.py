import openpyxl
import csv
import sys
import re
import json
import datetime
#import sqlalchemy as sa
from sqlalchemy.sql.functions import current_time
from sqlalchemy import create_engine
from flask import Flask,jsonify



app = Flask(__name__)

def Imprimir_reg(rs,titulo):
  print(titulo)
  results = rs.fetchone()
  while(results):
    print(results)
    results= rs.fetchone()
  return    

@app.route('/')
def Principal():
  return "Pagina principal"
  
@app.route('/adeudos/<string:nfolio>')
def resultados(nfolio):

  engine = create_engine('postgresql+pg8000://postgres:facil680@localhost:5432/bd_chbous')
  try:
    conn = engine.connect()
  except Exception as ex:
    print(ex)
    return jsonify({'mensaje': 'No es posible conectarse a la base de datos'})

  if(nfolio.isnumeric()== False):
     return jsonify({'mensaje': 'No es un folio numérico'})
 
  rs = conn.execute('select * from challenge_bous.adeudos_totales where folio = '+ nfolio)
  cur_at = rs.fetchone()
  if cur_at :
    mdic = {}
    
    mdic["adeudos totales"]={'numero de registros':cur_at.numero_registros, 'folio': cur_at.folio, 'adeudo total': 0 if cur_at.numero_registros == 0 else '${:,}'.format(cur_at.adeudo_total) }
    rs = conn.execute('select * from challenge_bous.adeudos_ciudad where folio = '+ nfolio)
    mdic["adeudos por ciudad"]=[]
    for cur_ac in rs :
        mdic["adeudos por ciudad"].append({'ciudad': cur_ac.ciudad, 'adeudo': '${:,}'.format(cur_ac.adeudo_ciudad), 'porcentaje': "{}%".format(cur_ac.porcentaje_ciudad)})
    rs = conn.execute('select * from challenge_bous.adeudos_empresa where folio = '+ nfolio)
    mdic["adeudos por empresa"]=[]
    for cursor in rs :
        mdic["adeudos por empresa"].append({'empresa': cursor.empresa, 'adeudo': '${:,}'.format(cursor.adeudo_empresa), 'porcentaje': "{}%".format(cursor.porcentaje_empresa)})    
         
    conn.close()
    return jsonify(mdic)
  
  else: 
   conn.close()   
   return jsonify({'mensaje': 'Folio no encontrado'})


if __name__ == '__main__':
   app.run(debug=True, port=4000)
