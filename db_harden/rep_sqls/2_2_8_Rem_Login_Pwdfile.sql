

spool /home/oracle/shell_scr/db_harden/rep_sqls/sql_2_2_8_Rem_LoginPwd_File.log
set echo on

SELECT UPPER(VALUE)
FROM V$PARAMETER
WHERE UPPER(NAME)='REMOTE_LOGIN_PASSWORDFILE';

spool off
set echo off

exit; 
