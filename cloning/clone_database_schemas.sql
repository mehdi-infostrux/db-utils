CREATE OR REPLACE PROCEDURE CLONE_DATABASE_SCHEMAS(target_database VARCHAR(200), source_database VARCHAR(200))
RETURNS NUMBER(38,0)
LANGUAGE SQL
EXECUTE AS owner
AS DECLARE
  val VARCHAR(20);
  schema_name VARCHAR(100);
  prod_database_name varchar(100);
  schema_query varchar(100);
  target_database_name varchar(100);
  schemas_result_set resultset ; 
  tables_query varchar(100);
  table_name varchar(100);
  tables_result_set resultset ; 


BEGIN
    schema_query := 'SHOW SCHEMAS in DATABASE ' || prod_database_name;
    schemas_result_set := (execute immediate :schema_query);
    -- Get the list of schemas from the production database
    declare
      cur_schemas CURSOR FOR schemas_result_set;
      --open cur_schemas; 
    begin
        for rec_schemas in cur_schemas loop
          schema_name := rec_schemas."name" ; 
        
    begin
        if (schema_name != 'INFORMATION_SCHEMA' AND schema_name != 'PUBLIC') then
          clone_schema_tables(target_database, schema_name, source_database, schema_name);
        
        end if ; 
    end ; 
    end loop ;
    end ;  
  
END;
