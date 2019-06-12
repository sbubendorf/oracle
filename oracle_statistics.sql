-- Set current statistics for given table --------------------------------------
declare
    i_owner             varchar2(100)   := 'HMIDB_LOAD_DATA';
    i_table_name        varchar2(100)   := 'TI_PERFORMANCE';
    --
    o_num_rows          number;
    o_num_blocks        number;
    o_avg_row_len       number;
begin
    dbms_stats.get_table_stats(
        ownname => i_owner,
        tabname => i_table_name,
        numrows => o_num_rows,
        numblks => o_num_blocks,
        avgrlen => o_avg_row_len
    );
    dbms_output.put_line('Number of rows     : ' || o_num_rows);
    dbms_output.put_line('Number of blocks   : ' || o_num_blocks);
    dbms_output.put_line('Average row length : ' || o_avg_row_len);
end;



-- Overwrite current statistics ------------------------------------------------
begin
    dbms_stats.set_table_stats(
        ownname     => 'HMIDB_LOAD_DATA',
        tabname     => 'TI_PERFORMANCE',
        numrows     => 6000,
        numblks     => 1700,
        avgrlen     => 150
    );
end;




begin
    sys.dbms_stats.gather_table_stats 
    (
        ownname             => 'HMIDBDBA',
        tabname             => 'C_CUSTODY_ACC_TRX_DETAILS',
        estimate_percent    => 10,
        method_opt          => 'FOR ALL COLUMNS SIZE 1',
        degree              => 4,
        cascade             => true,
        no_invalidate       => false
    );
end;




select  count(*)
from    c_custody_acc_trxs
where   dm > to_date('20141205093000','yyyymmddhh24miss')
    and um = 'HMIDB_LOAD_DATA'
;


select  count(*)
from    c_custody_acc_values
where   dm > to_date('20141205093000','yyyymmddhh24miss')
    --and dm > sysdate - 1/24/60
    and um = 'HMIDB_LOAD_DATA'
;




select  *
from    s_message_logs
where   processed_at > to_date('20141205093000','yyyymmddhh24miss')
    and application_name not in ('HMIDB_CUSTOMER_LOGIN')
    and login_name is null
order   by  id
;


-- -----------------------------------------------------------------------------
--  Lookup database objects
-- -----------------------------------------------------------------------------
select  ob.object_type,
        ob.owner,
        ob.object_name,
        ob.status,
        case ob.object_type
            when 'INDEX' then ix.num_rows
            when 'TABLE' then tb.num_rows
            else null
        end as num_rows,
        vw.text as source
from    sys.all_objects         ob
        left  join  sys.all_tables  tb  on  tb.owner = ob.owner and tb.table_name = ob.object_name
        left  join  sys.all_views   vw  on  vw.owner = ob.owner and vw.view_name = ob.object_name
        left  join  sys.all_indexes ix  on  ix.owner = ob.owner and ix.index_name = ob.object_name
where   ob.object_type in
        (
            'TABLE',
            null
        )
    and ob.owner like upper('%')
    and ob.object_name like upper('c_custody%')
order   by  ob.object_type,
            ob.owner,
            ob.object_name    


select  orun.mnemonic key, orun.id, orun.bc_no, orun.name, orun.street, orun.city,
        (select count(*) from c_contracts cont where cont.orun_id = orun.id) as num_cont,
        (select count(*) from c_contracts cont where cont.orun_id = orun.id and cont.status = 1) as num_act_cont
from    s_organisation_units            orun
where   orun.orun_id is not null
order   by  orun.orun_id;



select  *
from    s_organisation_units
;
