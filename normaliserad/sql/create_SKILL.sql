CREATE SKILL text2sql_skill
USING
  type     = 'text2sql',
  database = 'timescaledb_datasource',
  tables = ['drv','scinfo','site','sce','info','dataintegrity','data_int','data_float','data_string','data_date'],
  description = 'drv(id, name, type, created, retired) scinfo(id, scid, cell, produktions_linje, omrade, tillgang, sensor, datatype, querymode, created, retired) site(scid, name) sce(id, scid) info(id, scid, cell, produktions_linje, omrade, tillgang, sensor, datatype, querymode, created, retired) status(id, descr) data_int(info_id,t_stamp,data,int_id) data_float(info_id,t_stamp,data,float_id) data_string(info_id,t_stamp,data,string_id) data_date(info_id,t_stamp,data,date_id)';