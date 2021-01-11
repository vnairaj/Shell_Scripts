spool /home/oracle/shell_scr/db_harden/rep_sqls/sql_4_1_10_DBMS_SCHEDULER.log

set echo on

SELECT PRIVILEGE
FROM DBA_TAB_PRIVS
WHERE GRANTEE='PUBLIC'
AND PRIVILEGE='EXECUTE'
AND TABLE_NAME='DBMS_SCHEDULER';

spool off
set echo off

exit; 
