CREATE SKILL text2sql_skill
USING
  type     = 'text2sql',
  database = 'timescaledb_datasource',
  tables = ['drv','scinfo','sce','info','data'],
  description = 'A skill for converting natural language queries into SQL queries.';