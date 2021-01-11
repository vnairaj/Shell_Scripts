spool /home/oracle/shell_scr/db_harden/rep_sqls/sql_4_5_6_REV_ALL_SYS_SCHEDULER_CREDENTIAL.log

set echo on

SELECT GRANTEE, PRIVILEGE
FROM DBA_TAB_PRIVS
WHERE TABLE_NAME='SCHEDULER$_CREDENTIAL';

spool off
set echo off

exit; 
