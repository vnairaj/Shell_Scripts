spool /home/oracle/shell_scr/db_harden/rep_sqls/sql_4_1_2_DBMS_CRYPTO.log

set echo on

SELECT PRIVILEGE
FROM DBA_TAB_PRIVS
WHERE GRANTEE='PUBLIC'
AND TABLE_NAME='DBMS_CRYPTO'; 

spool off
set echo off

exit; 
