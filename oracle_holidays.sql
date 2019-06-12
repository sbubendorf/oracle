-- Show calendar with working day flag on every entry --------------------------
select  orun.id                         as  orun_id,
        orun.mnemonic                   as  orun_key,
        all_days.day                    as  cal_date,
        to_char(all_days.day, 'Dy')     as  weekday,
        holi_days.holiday_cd            as  holiday,
        case when to_char(all_days.day, 'DY') in ('SUN','SAT') or holi_days.day is not null then 0 else 1 end as working_day
from    s_organisation_units            orun
        inner join (
            select  trunc (sysdate - rownum) day
            from    dual 
            connect by rownum < 366
        )   all_days    on 1 = 1
        left join c_holiday_calendars   holi_days on holi_days.day = all_days.day and holi_days.orun_id = orun.id
where   orun.orun_id is not null;        



-- Count the working days between today and the beginning of the travel ---
select  all_days.day,
        case when to_char(all_days.day, 'DY') in ('SUN','SAT') or holi_days.day is not null then 0 else 1 end as working_days
from    s_organisation_units            orun
        inner join (
            select  trunc (sysdate + rownum) day
            from    dual 
            connect by rownum < 30
        )   all_days    on 1 = 1
        left join c_holiday_calendars   holi_days on holi_days.day = all_days.day and holi_days.orun_id = orun.id
where   orun.id = 70001
    and all_days.day between to_date('23.03.2016','dd.mm.yyyy') and to_date('30.03.2016','dd.mm.yyyy')      -- Easter weekend 2016 
;


select  sum(case when to_char(all_days.day, 'DY') in ('SUN','SAT') or holi_days.day is not null then 0 else 1 end) as working_days
from    s_organisation_units            orun
        inner join (
            select  trunc (sysdate - 14 + rownum) day
            from    dual 
            connect by rownum < 30
        )   all_days    on 1 = 1
        left join c_holiday_calendars   holi_days on holi_days.day = all_days.day and holi_days.orun_id = orun.id
where   orun.id = 70001
    and all_days.day between to_date('23.03.2016','dd.mm.yyyy') and to_date('21.03.2016','dd.mm.yyyy')      -- Easter weekend 2016 


