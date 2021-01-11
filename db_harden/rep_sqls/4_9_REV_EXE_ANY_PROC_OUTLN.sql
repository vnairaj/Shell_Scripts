spool /home/oracle/shell_scr/db_harden/rep_sqls/sql_4_9_REV_EXE_ANY_PROC_OUTLN.log

set echo on

SELECT GRANTEE, PRIVILEGE
FROM DBA_SYS_PRIVS
WHERE PRIVILEGE='EXECUTE ANY PROCEDURE'
AND GRANTEE='OUTLN';

spool off
set echo off

exit; 
