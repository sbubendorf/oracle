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




select  'exec dbms_stats.gather_table_stats(''BSI'', ''' || ob.object_name || ''');' as calc
from    sys.all_objects         ob
        left  join  sys.all_tables  tb  on  tb.owner = ob.owner and tb.table_name = ob.object_name
        left  join  sys.all_views   vw  on  vw.owner = ob.owner and vw.view_name = ob.object_name
        left  join  sys.all_indexes ix  on  ix.owner = ob.owner and ix.index_name = ob.object_name
where   ob.object_type in ('TABLE') -- 'FUNCTION','INDEX','PACKAGE','PACKAGE BODY','PROCEDURE','SEQUENCE','TRIGGER')
    and ob.owner like upper('%')
    and ob.object_name like upper('bsi%customer%')
order   by  ob.object_type,
            ob.owner,
            ob.object_name
            
            
exec dbms_stats.gather_table_stats('BSI', 'BSI_BENEFIT_CUSTOMER');
exec dbms_stats.gather_table_stats('BSI', 'BSI_COURSE_CUSTOMER');
exec dbms_stats.gather_table_stats('BSI', 'BSI_COURSE_QUESTION_CUSTOMER');
exec dbms_stats.gather_table_stats('BSI', 'BSI_CUSTOMER');
exec dbms_stats.gather_table_stats('BSI', 'BSI_CUSTOMER_ADVISOR');
exec dbms_stats.gather_table_stats('BSI', 'BSI_CUSTOMER_ATTRIBUTE');
exec dbms_stats.gather_table_stats('BSI', 'BSI_CUSTOMER_CHANGE');
exec dbms_stats.gather_table_stats('BSI', 'BSI_CUSTOMER_CUSTOMER');
exec dbms_stats.gather_table_stats('BSI', 'BSI_CUSTOMER_CUSTOMER_ATTR');
exec dbms_stats.gather_table_stats('BSI', 'BSI_CUSTOMER_CUSTOMER_LIST');
exec dbms_stats.gather_table_stats('BSI', 'BSI_CUSTOMER_CUSTOMER_ROLE');
exec dbms_stats.gather_table_stats('BSI', 'BSI_CUSTOMER_FIGURE');
exec dbms_stats.gather_table_stats('BSI', 'BSI_CUSTOMER_IMPORT');
exec dbms_stats.gather_table_stats('BSI', 'BSI_CUSTOMER_INTEREST');
exec dbms_stats.gather_table_stats('BSI', 'BSI_CUSTOMER_INTEREST_HISTORY');
exec dbms_stats.gather_table_stats('BSI', 'BSI_CUSTOMER_LIST');
exec dbms_stats.gather_table_stats('BSI', 'BSI_CUSTOMER_SCORE');
exec dbms_stats.gather_table_stats('BSI', 'BSI_CUSTOMER_SEGMENTATION');
exec dbms_stats.gather_table_stats('BSI', 'BSI_CUSTOMER_TRA_RELATION');
exec dbms_stats.gather_table_stats('BSI', 'BSI_DATA_QUA_DUP_CUSTOMER');
exec dbms_stats.gather_table_stats('BSI', 'BSI_DISTRIBUTOR_CUSTOMER');
exec dbms_stats.gather_table_stats('BSI', 'BSI_IMPORT_CUSTOMER');
exec dbms_stats.gather_table_stats('BSI', 'BSI_UC_CUSTOMER');
exec dbms_stats.gather_table_stats('BSI', 'BSI_UC_CUSTOMER_GENDER');
exec dbms_stats.gather_table_stats('BSI', 'BSI_UC_CUSTOMER_ROLE');
exec dbms_stats.gather_table_stats('BSI', 'BSI_UC_CUSTOMER_ROLE_FIELD');
exec dbms_stats.gather_table_stats('BSI', 'BSI_UC_CUSTOMER_SEGMENTATION');
exec dbms_stats.gather_table_stats('BSI', 'BSI_UC_CUSTOMER_TABLE_PAGE');
exec dbms_stats.gather_table_stats('BSI', 'BSI_UC_DWH_REPORT_CUSTOMER');
exec dbms_stats.gather_table_stats('BSI', 'BSI_X_BAD_BP_CUSTOMER');
exec dbms_stats.gather_table_stats('BSI', 'BSI_X_BANKPRODUCT_CUSTOMER');
exec dbms_stats.gather_table_stats('BSI', 'BSI_X_CONTRACT_CUSTOMER');
exec dbms_stats.gather_table_stats('BSI', 'BSI_X_CUSTOMER_ACTIVITY');
exec dbms_stats.gather_table_stats('BSI', 'BSI_X_CUSTOMER_AR_CL_STATUS');
exec dbms_stats.gather_table_stats('BSI', 'BSI_X_CUSTOMER_PRIVAT_NOTES');
exec dbms_stats.gather_table_stats('BSI', 'BSI_X_S1_BP_CUSTOMER');
exec dbms_stats.gather_table_stats('BSI', 'BSI_X_S2_BP_CUSTOMER');
            
