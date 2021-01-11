spool /home/oracle/shell_scr/db_harden/rep_sqls/sql_4_1_8_DBMS_OBFUSCATION_TOOLKIT.log

set echo on

SELECT PRIVILEGE
FROM DBA_TAB_PRIVS
WHERE GRANTEE='PUBLIC'
AND PRIVILEGE='EXECUTE'
AND TABLE_NAME='DBMS_OBFUSCATION_TOOLKIT';

spool off
set echo off

exit; 
