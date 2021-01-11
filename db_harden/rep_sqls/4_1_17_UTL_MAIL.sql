spool /home/oracle/shell_scr/db_harden/rep_sqls/sql_4_1_17_UTL_MAIL.log

set echo on

SELECT PRIVILEGE
FROM DBA_TAB_PRIVS
WHERE GRANTEE='PUBLIC'
AND PRIVILEGE='EXECUTE'
AND TABLE_NAME='UTL_MAIL';

spool off
set echo off

exit; 
