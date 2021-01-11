spool /home/oracle/shell_scr/db_harden/rep_sqls/sql_4_1_3_DBMS_JAVA.log

set echo on

SELECT PRIVILEGE
FROM DBA_TAB_PRIVS
WHERE GRANTEE='PUBLIC'
AND PRIVILEGE='EXECUTE'
AND TABLE_NAME='DBMS_JAVA'; 


spool off
set echo off

exit; 
