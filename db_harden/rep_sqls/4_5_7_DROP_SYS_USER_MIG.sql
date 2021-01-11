spool /home/oracle/shell_scr/db_harden/rep_sqls/sql_4_5_7_DROP_SYS_USER_MIG.log

set echo on

SELECT OWNER, TABLE_NAME
FROM ALL_TABLES
WHERE OWNER='SYS'
AND TABLE_NAME='USER$MIG';

spool off
set echo off

exit; 
