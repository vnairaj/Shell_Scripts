spool /home/oracle/shell_scr/db_harden/rep_sqls/sql_4_5_1_REV_ALL_AUD.log

set echo on

SELECT GRANTEE, PRIVILEGE
FROM DBA_TAB_PRIVS
WHERE TABLE_NAME='AUD$'
AND GRANTEE NOT IN ('DELETE_CATALOG_ROLE');

spool off
set echo off

exit; 
