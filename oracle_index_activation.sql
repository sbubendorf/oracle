-- Active all disabled function based indices ----------------------------------
declare 
    sql_s varchar2 (500 char); 
    cursor ind
        is 
          select *
          from all_indexes
          where owner = 'HMIDBDBA'
          and index_type = 'FUNCTION-BASED NORMAL'
          and funcidx_status = 'DISABLED'
          ;
begin 
    for ind_rec in ind 
    loop 
        sql_s := 'alter index HMIDBDBA.' || ind_rec.index_name || ' enable'; 
        execute immediate sql_s; 
        dbms_output.put_line('Index ' || ind_rec.index_name || ' updated.'); 
    end loop; 
end; 

