spool /home/oracle/shell_scr/db_harden/rep_sqls/sql_4_2_2_DBMS_BACKUP_RESTORE.log

set echo on

SELECT PRIVILEGE
FROM DBA_TAB_PRIVS
WHERE GRANTEE='PUBLIC'
AND PRIVILEGE='EXECUTE'
AND TABLE_NAME='DBMS_BACKUP_RESTORE';

spool off
set echo off

exit; 
