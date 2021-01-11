spool /home/oracle/shell_scr/db_harden/rep_sqls/sql_4_5_3_REV_ALL_LINK.log

set echo on

SELECT GRANTEE, PRIVILEGE
FROM DBA_TAB_PRIVS
WHERE TABLE_NAME='LINK$'
AND GRANTEE NOT IN ('DV_SECANALYST');

spool off
set echo off

exit; 
