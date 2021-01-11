

spool /home/oracle/shell_scr/db_harden/rep_sqls/sql_3_7_dbauser_password.log
set echo on

SELECT USERNAME
FROM DBA_USERS
WHERE PASSWORD='EXTERNAL';

spool off
set echo off

exit; 
