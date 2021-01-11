spool /home/oracle/shell_scr/db_harden/rep_sqls/sql_4_1_5_DBMS_JOB.log

set echo on

SELECT PRIVILEGE
FROM DBA_TAB_PRIVS
WHERE GRANTEE='PUBLIC'
AND PRIVILEGE='EXECUTE'
AND TABLE_NAME='DBMS_JOB';

spool off
set echo off

exit; 
