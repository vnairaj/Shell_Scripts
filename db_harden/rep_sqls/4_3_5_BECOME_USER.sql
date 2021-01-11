spool /home/oracle/shell_scr/db_harden/rep_sqls/sql_4_3_5_BECOME_USER.log

set echo on

SELECT GRANTEE, PRIVILEGE
FROM DBA_SYS_PRIVS
WHERE PRIVILEGE='BECOME USER'
AND GRANTEE NOT IN ('DBA','SYS','IMP_FULL_DATABASE');

spool off
set echo off

exit; 
