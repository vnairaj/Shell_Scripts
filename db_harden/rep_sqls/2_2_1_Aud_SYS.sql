
spool /home/oracle/shell_scr/db_harden/rep_sqls/2_2_1_Aud_SYS.log
set echo on

SELECT UPPER(VALUE) FROM V$PARAMETER WHERE UPPER(NAME) = 'AUDIT_SYS_OPERATIONS';

spool off
set echo off

exit; 
