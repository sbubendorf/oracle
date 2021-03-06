-- -----------------------------------------------------------------------------
--  Oracle date handling
-- -----------------------------------------------------------------------------

-- Crate test table ------------------------------------------------------------

drop table sbu_date;

create table sbu_date
(
    id          number,
    date_start  date,
    date_end    date,
    time_start  timestamp,
    time_end    timestamp,
    day_start   date,
    day_end     date
);

-- Fill random date ranges into test table -------------------------------------

truncate table sbu_date;
    
declare
    l_time_max      date    := to_date('20190101','yyyymmdd');
    l_time_from     date;
    l_time_to       date;
    --
    function get_random_ts(i_range_from date, i_range_to date) 
    return date
    is
    begin
        return i_range_from + dbms_random.value(0,i_range_to-i_range_from);
    end get_random_ts;
begin
    for i in 1..500 loop
        l_time_from := get_random_ts(l_time_max, l_time_max+dbms_random.value(0,1));
        l_time_to := get_random_ts(l_time_from, l_time_from+dbms_random.value(0,2));
        l_time_max := l_time_to;
        insert into sbu_date 
            values(
                i, 
                l_time_from, 
                l_time_to, 
                cast(l_time_from as timestamp) + numtodsinterval(dbms_random.value(0,1), 'SECOND'), 
                cast(l_time_to   as timestamp) + numtodsinterval(dbms_random.value(0,1), 'SECOND'),
                trunc(l_time_from),
                trunc(l_time_to) 
            );
    end loop;
    commit;
end;

select  *
from    sbu_date
;


select  round(date '9999-01-01','CC')   as minimum_date,
        trunc(date '-4712-1-1','CC')    as maximum_date
from dual;


-- Truncating dates ----------------
select  d.date_start,
        trunc(d.date_start,'YEAR')      as  start_of_year,
        trunc(d.date_start,'MONTH')     as  start_of_month,
        trunc(d.date_start,'Q')         as  start_of_quarter,
        trunc(d.date_start,'W')         as  start_of_week
from    sbu_date    d
;

select  d.date_start,  
        d.day_start + 1                         next_day,
        d.day_start - 1                         last_day,
        next_day(d.day_start, 'FRI')            next_friday,
        last_day(d.day_start)                   end_month,
        trunc(d.day_start,'mm')                 start_month,
        --
        d.date_start + interval '20' second     plus_20_seconds,
        d.date_start + interval '20' minute     plus_20_minutes,
        d.date_start + interval '20' hour       plus_20_hours,                   
        d.date_start + interval '5'  day        plus_5_days,
      --sysdate + interval '2'  month,                  -- ##### Adding 1 month to 31.01.2018 will fail because 31.02.2018 does not exists!! Use add_months instead
      --sysdate + interval '1'  year,                   -- ##### Adding 1 year to 29.02.2016 will fail because 29.02.2017 does not exists!!!
        --
        add_months(d.date_start, 2)             plus_2_months,
        add_months(d.date_start, 12)            plus_1_year
from    sbu_date    d
;


-- Difference now from start of current month ----------------------------------
select  d.date_start,
        d.date_end,
        d.date_end - d.date_start                   as diff_days,
        trunc((d.date_end - d.date_start) * 24   )  as diff_hours,
        trunc((d.date_end - d.date_start) * 1440 )  as diff_minutes,
        trunc((d.date_end - d.date_start) * 86400)  as diff_seconds
from    sbu_date    d


with
    function get_millis_between(i_from timestamp, i_to timestamp) return number is
    begin
        return round(
            extract( day    from i_to - i_from) * 24 * 60 * 60 * 1000 +
            extract( hour   from i_to - i_from)      * 60 * 60 * 1000 +
            extract( minute from i_to - i_from)           * 60 * 1000 +
            extract( second from i_to - i_from)                * 1000
        );
    end;
    function get_seconds_between(i_from timestamp, i_to timestamp) return number is
    begin
        return round(
            extract( day    from i_to - i_from) * 24 * 60 * 60 +
            extract( hour   from i_to - i_from)      * 60 * 60 +
            extract( minute from i_to - i_from)           * 60 +
            extract( second from i_to - i_from)             
        );
    end;
    function get_minutes_between(i_from timestamp, i_to timestamp) return number is
    begin
        return round(
            extract( day    from i_to - i_from) * 24 * 60 +
            extract( hour   from i_to - i_from)      * 60 +
            extract( minute from i_to - i_from)          
        );
    end;
    function get_hours_between(i_from timestamp, i_to timestamp) return number is
    begin
        return round(
            extract( day    from i_to - i_from) * 24 +
            extract( hour   from i_to - i_from)
        );
    end;
select  d.date_start,
        d.date_end,
        get_millis_between(d.time_start, d.time_end)        as  millis_between,
        get_seconds_between(d.time_start, d.time_end)       as  seconds_between,
        get_minutes_between(d.time_start, d.time_end)       as  minutes_between,
        get_hours_between(d.time_start, d.time_end)         as  hours_between,
        null
from    sbu_date    d
;



-- Get the number of milliseconds since 01.01.1970 -----------------------------
select  ((trunc(systimestamp) - to_date('19700101','yyyymmdd')) * 24 * 60 * 60 * 1000) + 
        (to_number(to_char(systimestamp,'sssss')) * 1000 + to_number(to_char(systimestamp,'ff3'))) 
from    dual
;

-- Show time difference between to dates ---------------------------------------
select  evt_start,
        evt_end,
        evt_end - evt_start as evt_diff,
        trunc((evt_end - evt_start) * 24)               as diff_hours,
        mod(trunc((evt_end - evt_start) * 1440), 60)    as diff_minutes,
        mod(trunc((evt_end - evt_start) * 86400), 60)   as diff_seconds
from    (
            select  to_date('2019.12.15 23:15:24','yyyy.mm.dd hh24:mi:ss') evt_start,
                    to_date('2019.12.16 02:15:25','yyyy.mm.dd hh24:mi:ss') evt_end
            from    dual
        ); 

select  evt_start,
        evt_end,
        evt_end - evt_start as evt_diff,
        extract(hour from (evt_end - evt_start))        as diff_hours,
        extract(minute from (evt_end - evt_start))      as diff_minutes,
        extract(second from (evt_end - evt_start))      as diff_seconds
from    (
            select  cast(to_date('2019.12.15 23:15:24','yyyy.mm.dd hh24:mi:ss') as timestamp) evt_start,
                    cast(to_date('2019.12.16 02:15:23','yyyy.mm.dd hh24:mi:ss') as timestamp) evt_end
            from    dual
        ); 




/*

Element         Description

AM              Meridian indicator without periods.
A.M.            Meridian indicator with periods.
D               Day of week (1-7).
DAY             Name of day.
DD              Day of month (1-31).
DDD             Day of year (1-366).
DL              Returns a value in the long date format, which is an extension of Oracle Database's DATE format, determined by the current value of the NLS_DATE_FORMAT parameter. Makes the appearance of the date components (day name, month number, and so forth) depend on the NLS_TERRITORY and NLS_LANGUAGE parameters. For example, in the AMERICAN_AMERICA locale, this is equivalent to specifying the format 'fmDay, Month dd, yyyy'. In the GERMAN_GERMANY locale, it is equivalent to specifying the format 'fmDay, dd. Month yyyy'.
                Restriction: You can specify this format only with the TS element, separated by white space.
DS              Returns a value in the short date format. Makes the appearance of the date components (day name, month number, and so forth) depend on the NLS_TERRITORY and NLS_LANGUAGE parameters. For example, in the AMERICAN_AMERICA locale, this is equivalent to specifying the format 'MM/DD/RRRR'. In the ENGLISH_UNITED_KINGDOM locale, it is equivalent to specifying the format 'DD/MM/RRRR'.
                Restriction: You can specify this format only with the TS element, separated by white space.
DY              Abbreviated name of day.
FF [1..9]       Fractional seconds; no radix character is printed. Use the X format element to add the radix character. Use the numbers 1 to 9 after FF to specify the number of digits in the fractional second portion of the datetime value returned. If you do not specify a digit, then Oracle Database uses the precision specified for the datetime datatype or the datatype's default precision. Valid in timestamp and interval formats, but not in DATE formats.
                Examples: 'HH:MI:SS.FF'
                SELECT TO_CHAR(SYSTIMESTAMP, 'SS.FF3') from dual;
FM              Returns a value with no leading or trailing blanks.
                See Also: Additional discussion on this format model modifier in the Oracle Database SQL Language Reference
FX              Requires exact matching between the character data and the format model.
                See Also: Additional discussion on this format model modifier in the Oracle Database SQL Language Reference
HH              Hour of day (1-12).
HH24            Hour of day (0-23).
IW              Week of year (1-52 or 1-53) based on the ISO standard.
IYY / IY / I    Last 3, 2, or 1 digit(s) of ISO year.
IYYY            4-digit year based on the ISO standard.
J               Julian day; the number of days since January 1, 4712 BC. Number specified with J must be integers.
MI              Minute (0-59).
MM              Month (01-12; January = 01).
MON             Abbreviated name of month.
MONTH           Name of month.
Q               Quarter of year (1, 2, 3, 4; January - March = 1).
RM              Roman numeral month (I-XII; January = I).
RR              Lets you store 20th century dates in the 21st century using only two digits.
                See Also: Additional discussion on RR datetime format element in the Oracle Database SQL Language Reference
RRRR            Round year. Accepts either 4-digit or 2-digit input. If 2-digit, provides the same return as RR. If you do not want this functionality, then enter the 4-digit year.
SS              Second (0-59).
SSSSS           Seconds past midnight (0-86399).
TS              Returns a value in the short time format. Makes the appearance of the time components (hour, minutes, and so forth) depend on the NLS_TERRITORY and NLS_LANGUAGE initialization parameters.
                Restriction: You can specify this format only with the DL or DS element, separated by white space.
TZD             Daylight savings information. The TZD value is an abbreviated time zone string with daylight saving information. It must correspond with the region specified in TZR. Valid in timestamp and interval formats, but not in DATE formats.
                Example: PST (for US/Pacific standard time); PDT (for US/Pacific daylight time).
TZH             Time zone hour. (See TZM format element.) Valid in timestamp and interval formats, but not in DATE formats. Example: 'HH:MI:SS.FFTZH:TZM'.
TZM             Time zone minute. (See TZH format element.) Valid in timestamp and interval formats, but not in DATE formats. Example: 'HH:MI:SS.FFTZH:TZM'.
TZR             Time zone region information. The value must be one of the time zone regions supported in the database. Valid in timestamp and interval formats, but not in DATE formats. Example: US/Pacific
WW              Week of year (1-53) where week 1 starts on the first day of the year and continues to the seventh day of the year.
W               Week of month (1-5) where week 1 starts on the first day of the month and ends on the seventh.
YEAR / SYEAR    Year, spelled out; S prefixes BC dates with a minus sign (-).
YYYY / SYYYY    4-digit year; S prefixes BC dates with a minus sign.
YYY / YY / Y    Last 3, 2, or 1 digit(s) of year

*/


select  to_date(,'J')
from    dual
;