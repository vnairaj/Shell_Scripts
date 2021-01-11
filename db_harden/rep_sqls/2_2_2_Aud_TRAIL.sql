
spool /home/oracle/shell_scr/db_harden/rep_sqls/sql_2_2_2_Aud_SYS.log
set echo on

 SELECT UPPER(VALUE)
FROM V$PARAMETER
WHERE UPPER(NAME)='AUDIT_TRAIL';

spool off
set echo off

exit; 
