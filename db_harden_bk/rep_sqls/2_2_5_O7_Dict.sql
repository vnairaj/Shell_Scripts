
spool /home/oracle/shell_scr/db_harden/rep_sqls/sql_2_2_5_O7_Dict.log
set echo on

SELECT UPPER(VALUE)
FROM V$PARAMETER
WHERE UPPER(NAME)='O7_DICTIONARY_ACCESSIBILITY';


spool off
set echo off

exit; 
