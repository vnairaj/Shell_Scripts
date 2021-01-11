spool /home/oracle/shell_scr/db_harden/rep_sqls/sql_2_2_17_SQL92_SECURITY.log
set echo on

SELECT UPPER(VALUE)
FROM V$PARAMETER
WHERE UPPER(NAME)='SQL92_SECURITY';

spool off
set echo off

exit;
