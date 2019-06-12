-- =============================================================================
--  Oracle Session Handling
-- =============================================================================


-- -----------------------------------------------------------------------------
--  total cursors open, by session
select  s.sid,
        s.serial#, 
        s.username,
        s.osuser, 
        s.machine,
        s.terminal,
        s.program,
        a.value as cursors
from    v$session                   s
        inner join  v$sesstat       a   on  a.sid = s.sid 
        inner join  v$statname      b   on  b.statistic# = a.statistic# 
where   b.name = 'opened cursors current'
order   by  cursors desc


-- -----------------------------------------------------------------------------
--  Oracle Parameters
select  *
from    v$parameter
order   by  name


-- -----------------------------------------------------------------------------
--  Oracle Session History
select  u.name,
        s.*
from    sys.wrh$_active_session_history s
        inner join  sys.user$ u on u.user# = s.user_id
where   sample_time > trunc(sysdate)-1
order   by  sample_time   
