spool /home/oracle/shell_scr/db_harden/rep_sqls/sql_4_2_13_DBMS_IJOB.log

set echo on

SELECT PRIVILEGE
FROM DBA_TAB_PRIVS
WHERE GRANTEE='PUBLIC'
AND PRIVILEGE='EXECUTE'
AND TABLE_NAME='DBMS_IJOB';

spool off
set echo off

exit; 
