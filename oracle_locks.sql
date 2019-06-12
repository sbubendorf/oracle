select  nvl(s.username,'Internal')                                              username, 
        nvl(s.terminal,'None')                                                  terminal, 
        'alter system kill session ''' || l.sid || ',' || s.serial# || ''';'    kill_command, 
        u.name || '.' || substr(t.name,1,20)                                    table_name, 
        decode(l.lmode,
            1, 'No Lock', 
            2, 'Row Share', 
            3, 'Row Exclusive', 
            4, 'Share', 
            5, 'Share Row Exclusive', 
            6, 'Exclusive',
            null)                                                               lock_mode, 
       decode(l.request,
            1 , 'No Lock', 
            2 , 'Row Share', 
            3 , 'Row Exclusive', 
            4 , 'Share', 
            5 , 'Share Row Exclusive', 
            6 , 'Exclusive',
            null)                                                               request 
from    v$lock                  l  
        inner join  v$session   s   on  s.sid = l.sid 
        inner join  sys.obj$    t   on  t.obj# = decode(l.id2,0,l.id1,l.id2)
        inner join  sys.user$   u   on  u.user# = t.owner#  
where   s.type != 'BACKGROUND'
    and u.name not in ('SYS') 
order by 1,2,5 



select  sessions_current "Users logged on"
from    v$license;

select  count(*) "Users running"
from    v$session_wait
where   wait_time != 0
 
select  substr(w.sid,1,5) "Sid",
        substr(s.username,1,15) "User",
        substr(s.event,1,40) "Event",
        s.seconds_in_wait "Wait [s]"
from    v$session_wait          w 
        inner join  v$session   s   on  s.sid = w.sid
where   s.state = 'WAITING'
    and s.event not like 'SQL*Net%'
    and s.event != 'client message'
    and s.event not like '%mon timer'
    and s.event != 'rdbms ipc message'
    and s.event != 'Null Event'
    
    
select  count(*) "Users waiting for locks"
from    v$session
where   lockwait is not null;
