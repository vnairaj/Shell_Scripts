spool /home/oracle/shell_scr/db_harden/rep_sqls/sql_2_2_15_SEC_PROTOCOL_ERROR_TRACE_ACTION.log
set echo on

SELECT UPPER(VALUE)
FROM V$PARAMETER
WHERE UPPER(NAME)='SEC_PROTOCOL_ERROR_TRACE_ACTION';

spool off
set echo off

exit;

