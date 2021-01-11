

spool /home/oracle/shell_scr/db_harden/rep_sqls/sql_2_2_12_Sec_case_sensLogon.log
set echo on

SELECT UPPER(VALUE)
FROM V$PARAMETER
WHERE UPPER(NAME)='SEC_CASE_SENSITIVE_LOGON';

spool off
set echo off

exit; 
