
spool /home/oracle/shell_scr/db_harden/rep_sqls/sql_2_2_3_Gb_names.log
set echo on

 SELECT UPPER(VALUE)
FROM V$PARAMETER
WHERE UPPER(NAME)='GLOBAL_NAMES';

spool off
set echo off

exit; 
