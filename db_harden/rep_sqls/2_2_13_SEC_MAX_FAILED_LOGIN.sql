spool /home/oracle/shell_scr/db_harden/rep_sqls/sql_2_2_13_Sec_maxfailed_login.log
set echo on

SELECT UPPER(VALUE)
FROM V$PARAMETER
WHERE UPPER(NAME)='SEC_MAX_FAILED_LOGIN_ATTEMPTS';

spool off
set echo off

exit;
