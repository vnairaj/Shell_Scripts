spool /home/oracle/shell_scr/db_harden/rep_sqls/sql_4_1_13_DBMS_XMLQUERY.log

set echo on

SELECT PRIVILEGE
FROM DBA_TAB_PRIVS
WHERE GRANTEE='PUBLIC'
AND PRIVILEGE='EXECUTE'
AND TABLE_NAME='DBMS_XMLQUERY';

spool off
set echo off

exit; 
