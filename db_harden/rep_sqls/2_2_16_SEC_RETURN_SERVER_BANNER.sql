spool /home/oracle/shell_scr/db_harden/rep_sqls/sql_2_2_16_SEC_RETURN_SERVER_RELEASE_BANNER.log
set echo on

SELECT UPPER(VALUE)
FROM V$PARAMETER
WHERE UPPER(NAME)='SEC_RETURN_SERVER_RELEASE_BANNER';

spool off
set echo off

exit;
