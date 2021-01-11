spool /home/oracle/shell_scr/db_harden/rep_sqls/sql_4_1_15_UTL_INADDR.log

set echo on

SELECT PRIVILEGE
FROM DBA_TAB_PRIVS
WHERE GRANTEE='PUBLIC'
AND PRIVILEGE='EXECUTE'
AND TABLE_NAME='UTL_INADDR';

spool off
set echo off

exit; 
