CREATE OR REPLACE PROCEDURE MANAGEMENT.CLONING.CLONE_TEAM_TABLES(TEAM VARCHAR(16777216), ENV VARCHAR(16777216))
RETURNS NUMBER(38,0)
LANGUAGE SQL
EXECUTE AS owner
AS DECLARE
  val VARCHAR(20);
  cur CURSOR FOR
    SELECT 'INGEST' as layer
    UNION
    SELECT 'CLEAN'
    UNION
    SELECT 'ANALYZE'
    union 
    SELECT 'INTEGRATE'
    UNION
    SELECT 'NORMALIZE' ;
  schema_name VARCHAR(100);
  prod_database_name varchar(100);
  schema_query varchar(100);
  target_database_name varchar(100);
  schemas_result_set resultset ; 
  tables_query varchar(100);
  table_name varchar(100);
  tables_result_set resultset ; 


BEGIN
  open  cur ;   
  for rec_db in cur loop

    val := rec_db.layer;
    -- Create the database
    target_database_name := team || '_' || env || '_' || rec_db.layer;
    prod_database_name := team || '_' || 'PROD' || '_' || rec_db.layer;
    EXECUTE IMMEDIATE 'CREATE DATABASE IF NOT EXISTS ' || target_database_name;

    schema_query := 'SHOW SCHEMAS in DATABASE ' || prod_database_name;
    schemas_result_set := (execute immediate :schema_query);
    -- Get the list of schemas from the production database
    declare
      cur_schemas CURSOR FOR schemas_result_set;
      --open cur_schemas; 
    begin
        for rec_schemas in cur_schemas loop
          schema_name := rec_schemas."name" ; 
        
        insert into log values ('0',:target_database_name, :schema_name) ; 
    begin
        if (schema_name != 'INFORMATION_SCHEMA' AND schema_name != 'PUBLIC') then
        EXECUTE IMMEDIATE 'CREATE SCHEMA IF NOT EXISTS ' || target_database_name  || '.' || '"' || schema_name || '"' ;
        tables_query := 'SHOW TABLES in SCHEMA ' || prod_database_name || '.' || '"' || schema_name || '"' ;
        tables_result_set := (execute immediate :tables_query);
        declare
          cur_tables cursor for tables_result_set; 
          BEGIN 
            for rec_tables in cur_tables loop 
              table_name:=rec_tables."name" ; 
              BEGIN 
                if (rec_tables."kind"!='TRANSIENT') then 
                  execute immediate 'CREATE OR REPLACE TABLE ' || target_database_name ||'.'||'"' || schema_name||'"'||'.'||table_name || ' CLONE ' || prod_database_name ||'.'|| '"'|| schema_name||'"'||'.'||table_name ;
                else 
                  execute immediate 'CREATE OR REPLACE TABLE ' || target_database_name ||'.'||'"' || schema_name||'"'||'.'||table_name || ' AS SELECT * FROM  ' || prod_database_name ||'.'|| '"'|| schema_name||'"'||'.'||table_name ;
                end if ; 
             END;
           end loop ;
          END ; 
        
        end if ; 
    end ; 
    end loop ;
    end ;  
  end loop ;
END;
