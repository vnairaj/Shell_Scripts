

spool /home/oracle/shell_scr/db_harden/rep_sqls/sql_2_2_10_Rem_OS_roles.log
set echo on

SELECT UPPER(VALUE)
FROM V$PARAMETER
WHERE UPPER(NAME)='REMOTE_OS_ROLES';

spool off
set echo off

exit; 
