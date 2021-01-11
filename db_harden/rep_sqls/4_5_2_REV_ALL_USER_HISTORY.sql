spool /home/oracle/shell_scr/db_harden/rep_sqls/sql_4_5_2_REV_ALL_USER_HISTORY.log

set echo on

SELECT GRANTEE, PRIVILEGE
FROM DBA_TAB_PRIVS
WHERE TABLE_NAME='USER_HISTORY$';

spool off
set echo off

exit; 
