
spool /home/oracle/shell_scr/db_harden/rep_sqls/sql_2_2_4_LOC_LIS.log
set echo on

SELECT UPPER(VALUE)
FROM V$PARAMETER
WHERE UPPER(NAME)='LOCAL_LISTENER';

spool off
set echo off

exit; 
