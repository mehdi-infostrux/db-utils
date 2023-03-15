CREATE OR REPLACE PROCEDURE CLONE_SCHEMA_TABLES(target_database_name VARCHAR(200), target_schema_name VARCHAR(200), source_database_name VARCHAR(200), source_schema_name VARCHAR(200))
RETURNS NUMBER(38,0)
LANGUAGE SQL
EXECUTE AS owner
AS DECLARE
  val VARCHAR(20);
  tables_query VARCHAR(2000);
  table_name VARCHAR(200);
  tables_result_set resultset ; 


BEGIN

        tables_query := 'SHOW TABLES in SCHEMA ' || source_database_name || '.' || '"' || source_schema_name || '"' ;
        tables_result_set := (execute immediate :tables_query);
        declare
          cur_tables cursor for tables_result_set; 
          BEGIN 
            for rec_tables in cur_tables loop 
              table_name:=rec_tables."name" ; 
              BEGIN 
                if (rec_tables."kind"!='TRANSIENT') then 
                  execute immediate 'CREATE OR REPLACE TABLE ' || target_database_name ||'.'||'"' || target_schema_name||'"'||'.'||table_name || ' CLONE ' || source_database_name ||'.'|| '"'|| source_schema_name||'"'||'.'||table_name ;
                else 
                  execute immediate 'CREATE OR REPLACE TABLE ' || target_database_name ||'.'||'"' || target_schema_name||'"'||'.'||table_name || ' AS SELECT * FROM  ' || source_database_name ||'.'|| '"'|| source_schema_name||'"'||'.'||table_name ;
                end if ; 
             END;
           end loop ;
          END ; 
        
  END;
