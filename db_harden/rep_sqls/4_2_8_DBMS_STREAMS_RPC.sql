spool /home/oracle/shell_scr/db_harden/rep_sqls/sql_4_2_8_DBMS_STREAMS_RPC.log

set echo on

SELECT PRIVILEGE
FROM DBA_TAB_PRIVS
WHERE GRANTEE='PUBLIC'
AND PRIVILEGE='EXECUTE'
AND TABLE_NAME='DBMS_STREAMS_RPC';

spool off
set echo off

exit; 
