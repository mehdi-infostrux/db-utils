CREATE OR REPLACE PROCEDURE CLONE_TABLE(target_database_name VARCHAR(200), target_schema_name VARCHAR(200),  target_table_name VARCHAR(200),
 source_database_name VARCHAR(200), source_schema_name VARCHAR(200),  source_table_name VARCHAR(200)  )
RETURNS NUMBER(38,0)
LANGUAGE SQL
EXECUTE AS owner
AS DECLARE
  val VARCHAR(20);

BEGIN
    execute immediate 'CREATE OR REPLACE TABLE ' || target_database_name ||'.'||'"' || target_schema_name||'"'||'.'||target_table_name || ' CLONE  ' || source_database_name ||'.'|| '"'|| source_schema_name||'"'||'.'|| source_table_name ;
END;
