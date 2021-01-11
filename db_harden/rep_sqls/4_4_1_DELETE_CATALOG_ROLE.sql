spool /home/oracle/shell_scr/db_harden/rep_sqls/sql_4_4_1_DELETE_CATALOG_ROLE.log

set echo on

SELECT GRANTEE, GRANTED_ROLE
FROM DBA_ROLE_PRIVS
WHERE granted_role='DELETE_CATALOG_ROLE'
AND GRANTEE NOT IN ('DBA','SYS');

spool off
set echo off

exit; 
