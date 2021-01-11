spool /home/oracle/shell_scr/db_harden/rep_sqls/sql_4_3_8_CREATE_ANY_LIBRARY.log

set echo on

SELECT GRANTEE, PRIVILEGE
FROM DBA_SYS_PRIVS
WHERE PRIVILEGE='CREATE ANY LIBRARY'
AND GRANTEE NOT IN ('SYS','SYSTEM','DBA','IMP_FULL_DATABASE');

spool off
set echo off

exit; 
