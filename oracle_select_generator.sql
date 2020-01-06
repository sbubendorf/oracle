-- Generate select clause for a given table with all columns within this table and a translation for UIDs ------------------------------
with 
    w_settings_input as
    (
        select  'bsi_customer'          as  table_name,
                ''          as  table_alias,
                100         as  lob_length
        from    dual
    ),
    w_settings as
    (
        select  s.table_name,
                coalesce(s.table_alias,
                decode(upper(s.table_name),'BSI_ACTION','acti','BSI_ACTION_REACTION','acra','BSI_ACTION_RECIPIENT','acre','BSI_ACTION_RECIPIENT_HISTORY','acrh','BSI_ACTION_REVIEW_STATUS','acrs','BSI_ACTION_RUN','acru','BSI_ACTION_SEARCH','acse','BSI_ADDRESS','addr','BSI_ADDRESS_USAGE','adus','BSI_BENEFIT','bene','BSI_BENEFIT_CHANGE','benc','BSI_BOOKMARK','boma','BSI_BUSINESS','busi','BSI_BUSINESS_CHANGE','busc','BSI_BUSINESS_ROLE','buro','BSI_BUSINESS_STATUS','bust','BSI_CAMPAIGN','camp','BSI_CAMPAIGN_CHANGE','camc','BSI_CASE','cass','BSI_CASE_CHANGE','casc','BSI_CASE_INPUT','caip','BSI_CASE_ITEM','casi','BSI_CASE_LIST','cali','BSI_CASE_LOG','calo','BSI_CASE_MEMO','came','BSI_CASE_MEMO_CHANGE','camc','BSI_CASE_STEP','cast','BSI_CASE_STEP_HISTORY','cash','BSI_CASE_STEP_OUTPUT','caso','BSI_CATEGORY','cate','BSI_CATEGORY_ITEM','cati','BSI_CHANGE_PUBLISH','chpu','BSI_CITY','city','BSI_CODE_TYPE','coty','BSI_COMMUNICATION','comm','BSI_COMMUNICATION_CHANGE','comc','BSI_COMMUNICATION_PARTICIPANT','comp','BSI_COMMUNICATION_REACTION','comr','BSI_COMMUNICATION_STATUS','coms','BSI_CTI_CALL','ctic','BSI_CUSTOMER','cust','BSI_CUSTOMER_ADVISOR','cusa','BSI_CUSTOMER_CHANGE','cusc','BSI_CUSTOMER_CUSTOMER','cucu','BSI_CUSTOMER_CUSTOMER_ROLE','cucr','BSI_CUSTOMER_IMPORT','cusi','BSI_DEEP_LINK','deli','BSI_DEFAULT_ADDRESS_CALC','dadc','BSI_DISTRIBUTOR','dist','BSI_DISTRIBUTOR_CUSTOMER','dicu','BSI_DOCUMENT','docu','BSI_DOCUMENT_CONTENT','docc','BSI_DWH_INDEX','dwhi','BSI_EMPLOYEE','empl','BSI_ETL_LOG','etll','BSI_FOLDER','fold','BSI_FOLDER_CONTENT','folc','BSI_GLOBAL_COUNTER','gloc','BSI_GLOBAL_KEY_STATE','glks','BSI_GLOBAL_TEXT','gltx','BSI_GROUPWARE_ACCOUNT','gwac','BSI_IMPORT_CUSTOMER','imcu','BSI_IMPORT_DATA','imda','BSI_IMPORT_DATA_DUPLICATE','imdd','BSI_IMPORT_DATA_EXISTING','imde','BSI_IMPORT_META','imme','BSI_ITEM_SUMMARY','itsu','BSI_ITEM_SUMMARY_FILTER','itsf','BSI_ITEM_TEMPLATE_LANGUAGE','ittl','BSI_ITEM_TEXT','ittx','BSI_JOB','jobb','BSI_JOB_CHANGE','jobc','BSI_JOB_LOG','jobl','BSI_JOB_RUN','jobr','BSI_JOB_RUN_FILE','jobf','BSI_KNOWLEDGE','know','BSI_KNOWLEDGE_CHANGE','knoc','BSI_KNOWLEDGE_LANGUAGE','knol','BSI_KNOWLEDGE_PROCESS','knop','BSI_NEWSFEED','newf','BSI_NEWSFEED_RESPONSIBLE','nefr','BSI_OPERATION_EXECUTION','opex','BSI_OPT_IN','opti','BSI_ORGANIZATION_UNIT_FLAT','oruf','BSI_PARAMETER','para','BSI_PARAMETER_CHANGE','parc','BSI_PARAMETER_LIST','parl','BSI_PARAMETER_TO_CLUSTER_NODE','parn','BSI_PARAMETER_TO_ROLE','parr','BSI_RULE_EXECUTION','rexe','BSI_RULE_EXECUTION_COMPLETED','rexc','BSI_RULE_LOG','rlog','BSI_RULE_RUN','rrun','BSI_SOURCE_MAPPING','soma','BSI_TASK','tasi','BSI_TASK_CHANGE','tasc','BSI_TASK_PARTICIPANT','tasp','BSI_USER','usrt','BSI_USER_ACL','usra','BSI_USER_OU_ACL','usoa','BSI_USER_PERMISSION_SNAPSHOT','usrp','BSI_USER_ROLE','usro','BSI_USER_SEARCH_PREFERENCE','ussp','BSI_USER_SUBSTITUTE','ussu','xxxx')) as table_alias,
                s.lob_length
        from    w_settings_input    s
    ),
    w_columns as 
    (
        select  tcol.column_id,
                first_value(tcol.column_id) ignore nulls over (partition by tcol.table_name order by tcol.column_id rows between unbounded preceding and unbounded following) as first_column_id,
                last_value(tcol.column_id)  ignore nulls over (partition by tcol.table_name order by tcol.column_id rows between unbounded preceding and unbounded following) as last_column_id,
                lower(tcol.column_name) as column_name,
                lower(coalesce(sett.table_alias,tcol.table_name) || '.' || tcol.column_name) as column_name_full,
                tcol.data_type,
                tcol.owner,
                lower(tcol.table_name) as table_name,
                lower(coalesce(sett.table_alias,sett.table_name)) as table_alias,
                tcol.data_precision,
                tcol.data_scale,
                '''' || regexp_replace(substr(replace(lpad('9',tcol.data_precision+3-mod(tcol.data_precision,3),'9'),'999','G999'),-tcol.data_precision-trunc(tcol.data_precision/3)),'^G','') || case when tcol.data_scale > 0 then rpad('D', tcol.data_scale, '9') else '' end || '''' as number_format,
                sett.lob_length,
                last_value(length(coalesce(sett.table_alias,tcol.table_name) || '.' || tcol.column_name)) ignore nulls over (partition by tcol.table_name order by length(tcol.column_name) rows between unbounded preceding and unbounded following) as max_name_size,
                length(coalesce(sett.table_alias,tcol.table_name) || '.' || tcol.column_name) as name_size                
        from    w_settings                          sett
                inner join  sys.all_tab_columns     tcol    on  tcol.table_name     like upper(sett.table_name)
    )
select  case when first_column_id = column_id then 'select  ' else '        ' end || 
        case  
            when data_type = 'CLOB' then 'to_char(substr('
            when data_type = 'NUMBER' and data_scale > 0 then 'to_char(' 
            else '' 
        end ||  
        column_name_full || 
        case  
            when data_type = 'CLOB' then ', 1,' || to_char(lob_length,'9999') || '))' || lpad('as ', max_name_size-name_size+40,' ') || column_name
            when data_type = 'NUMBER' and data_scale > 0 then rpad(',', max_name_size-name_size, ' ') || number_format || ')' || rpad(' ', max_name_size-length(number_format)+19, ' ') || 'as ' || column_name 
            else '' 
        end ||  
        case when column_name like '%_uid' then rpad(',', max_name_size-name_size+8, ' ') || 'bsiutl_uctext(' || 
            column_name_full || ',246)' || 
            rpad(' ', max_name_size-name_size+1, ' ') || 'as ' || 
            replace(column_name,'_uid', '_name') else '' end || 
        case when last_column_id = column_id then chr(10) || 'from    ' || table_name || ' ' || table_alias else ',' end 
            as sel_clause
from    w_columns
order   by  column_id;



            
            



decode(upper(tcol.table_name),
'BSI_ACTION','acti',
'BSI_ACTION_REACTION','acra',
'BSI_ACTION_RECIPIENT','acre',
'BSI_ACTION_RECIPIENT_HISTORY','acrh',
'BSI_ACTION_REVIEW_STATUS','acrs',
'BSI_ACTION_RUN','acru',
'BSI_ACTION_SEARCH','acse',
'BSI_ADDRESS','addr',
'BSI_ADDRESS_USAGE','adus',
'BSI_BENEFIT','bene',
'BSI_BENEFIT_CHANGE','benc',
'BSI_BOOKMARK','boma',
'BSI_BUSINESS','busi',
'BSI_BUSINESS_CHANGE','busc',
'BSI_BUSINESS_ROLE','buro',
'BSI_BUSINESS_STATUS','bust',
'BSI_CAMPAIGN','camp',
'BSI_CAMPAIGN_CHANGE','camc',
'BSI_CASE','cass',
'BSI_CASE_CHANGE','casc',
'BSI_CASE_INPUT','caip',
'BSI_CASE_ITEM','casi',
'BSI_CASE_LIST','cali',
'BSI_CASE_LOG','calo',
'BSI_CASE_MEMO','came',
'BSI_CASE_MEMO_CHANGE','camc',
'BSI_CASE_STEP','cast',
'BSI_CASE_STEP_HISTORY','cash',
'BSI_CASE_STEP_OUTPUT','caso',
'BSI_CATEGORY','cate',
'BSI_CATEGORY_ITEM','cati',
'BSI_CHANGE_PUBLISH','chpu',
'BSI_CITY','city',
'BSI_CODE_TYPE','coty',
'BSI_COMMUNICATION','comm',
'BSI_COMMUNICATION_CHANGE','comc',
'BSI_COMMUNICATION_PARTICIPANT','comp',
'BSI_COMMUNICATION_REACTION','comr',
'BSI_COMMUNICATION_STATUS','coms',
'BSI_CTI_CALL','ctic',
'BSI_CUSTOMER','cust',
'BSI_CUSTOMER_ADVISOR','cusa',
'BSI_CUSTOMER_CHANGE','cusc',
'BSI_CUSTOMER_CUSTOMER','cucu',
'BSI_CUSTOMER_CUSTOMER_ROLE','cucr',
'BSI_CUSTOMER_IMPORT','cusi',
'BSI_DEEP_LINK','deli',
'BSI_DEFAULT_ADDRESS_CALC','dadc',
'BSI_DISTRIBUTOR','dist',
'BSI_DISTRIBUTOR_CUSTOMER','dicu',
'BSI_DOCUMENT','docu',
'BSI_DOCUMENT_CONTENT','docc',
'BSI_DWH_INDEX','dwhi',
'BSI_EMPLOYEE','empl',
'BSI_ETL_LOG','etll',
'BSI_FOLDER','fold',
'BSI_FOLDER_CONTENT','folc',
'BSI_GLOBAL_COUNTER','gloc',
'BSI_GLOBAL_KEY_STATE','glks',
'BSI_GLOBAL_TEXT','gltx',
'BSI_GROUPWARE_ACCOUNT','gwac',
'BSI_IMPORT_CUSTOMER','imcu',
'BSI_IMPORT_DATA','imda',
'BSI_IMPORT_DATA_DUPLICATE','imdd',
'BSI_IMPORT_DATA_EXISTING','imde',
'BSI_IMPORT_META','imme',
'BSI_ITEM_SUMMARY','itsu',
'BSI_ITEM_SUMMARY_FILTER','itsf',
'BSI_ITEM_TEMPLATE_LANGUAGE','ittl',
'BSI_ITEM_TEXT','ittx',
'BSI_JOB','jobb',
'BSI_JOB_CHANGE','jobc',
'BSI_JOB_LOG','jobl',
'BSI_JOB_RUN','jobr',
'BSI_JOB_RUN_FILE','jobf',
'BSI_KNOWLEDGE','know',
'BSI_KNOWLEDGE_CHANGE','knoc',
'BSI_KNOWLEDGE_LANGUAGE','knol',
'BSI_KNOWLEDGE_PROCESS','knop',
'BSI_NEWSFEED','newf',
'BSI_NEWSFEED_RESPONSIBLE','nefr',
'BSI_OPERATION_EXECUTION','opex',
'BSI_OPT_IN','opti',
'BSI_ORGANIZATION_UNIT_FLAT','oruf',
'BSI_PARAMETER','para',
'BSI_PARAMETER_CHANGE','parc',
'BSI_PARAMETER_LIST','parl',
'BSI_PARAMETER_TO_CLUSTER_NODE','parn',
'BSI_PARAMETER_TO_ROLE','parr',
'BSI_RULE_EXECUTION','rexe',
'BSI_RULE_EXECUTION_COMPLETED','rexc',
'BSI_RULE_LOG','rlog',
'BSI_RULE_RUN','rrun',
'BSI_SOURCE_MAPPING','soma',
'BSI_TASK','tasi',
'BSI_TASK_CHANGE','tasc',
'BSI_TASK_PARTICIPANT','tasp',
'BSI_USER','usrt',
'BSI_USER_ACL','usra',
'BSI_USER_OU_ACL','usoa',
'BSI_USER_PERMISSION_SNAPSHOT','usrp',
'BSI_USER_ROLE','usro',
'BSI_USER_SEARCH_PREFERENCE','ussp',
'BSI_USER_SUBSTITUTE','ussu',
