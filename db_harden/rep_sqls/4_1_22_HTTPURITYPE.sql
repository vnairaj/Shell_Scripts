spool /home/oracle/shell_scr/db_harden/rep_sqls/sql_4_1_22_HTTPURITYPE.log

set echo on

SELECT PRIVILEGE
FROM DBA_TAB_PRIVS
WHERE GRANTEE='PUBLIC'
AND PRIVILEGE='EXECUTE'
AND TABLE_NAME='HTTPURITYPE';

spool off
set echo off

exit; 
