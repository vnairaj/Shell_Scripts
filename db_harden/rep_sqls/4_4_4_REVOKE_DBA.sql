spool /home/oracle/shell_scr/db_harden/rep_sqls/sql_4_4_4_REVOKE_DBA.log

set echo on

SELECT GRANTEE, GRANTED_ROLE
FROM DBA_ROLE_PRIVS
WHERE GRANTED_ROLE='DBA'
AND GRANTEE NOT IN ('SYS','SYSTEM');

spool off
set echo off

exit; 
