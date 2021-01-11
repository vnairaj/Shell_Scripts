spool /home/oracle/shell_scr/db_harden/rep_sqls/sql_4_10_REV_EXE_ANY_PROC_DBSNMP.log

set echo on

SELECT GRANTEE, PRIVILEGE
FROM DBA_SYS_PRIVS
WHERE PRIVILEGE='EXECUTE ANY PROCEDURE'
AND GRANTEE='DBSNMP';

spool off
set echo off

exit; 
