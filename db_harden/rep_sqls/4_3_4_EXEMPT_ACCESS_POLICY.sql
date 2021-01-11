spool /home/oracle/shell_scr/db_harden/rep_sqls/sql_4_3_4_EXEMPT_ACCESS_POLICY.log

set echo on

SELECT GRANTEE, PRIVILEGE
FROM DBA_SYS_PRIVS
WHERE PRIVILEGE='EXEMPT ACCESS POLICY';

spool off
set echo off

exit; 
