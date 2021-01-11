

spool /home/oracle/shell_scr/db_harden/rep_sqls/sql_2_2_9_os_authent.log
set echo on

SELECT UPPER(VALUE)
FROM V$PARAMETER
WHERE UPPER(NAME)='REMOTE_OS_AUTHENT';

spool off
set echo off

exit; 
