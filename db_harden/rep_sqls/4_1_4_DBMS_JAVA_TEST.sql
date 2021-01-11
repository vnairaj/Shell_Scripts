spool /home/oracle/shell_scr/db_harden/rep_sqls/sql_4_1_4_DBMS_JAVA_TEST.log

set echo on

SELECT PRIVILEGE
FROM DBA_TAB_PRIVS
WHERE GRANTEE='PUBLIC'
AND PRIVILEGE='EXECUTE'
AND TABLE_NAME='DBMS_JAVA_TEST';

spool off
set echo off

exit; 
