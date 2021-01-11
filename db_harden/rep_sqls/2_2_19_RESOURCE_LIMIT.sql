spool /home/oracle/shell_scr/db_harden/rep_sqls/sql_2_2_19_RESOURCE_LIMIT.log
set echo on

SELECT UPPER(VALUE)
FROM V$PARAMETER
WHERE UPPER(NAME)='RESOURCE_LIMIT';
spool off
set echo off

exit;
