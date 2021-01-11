
spool /home/oracle/shell_scr/db_harden/rep_sqls/1_3_DEF_Schem.log
set echo on

SELECT USERNAME FROM ALL_USERS WHERE USERNAME IN ('BI','HR','IX','OE','PM','SCOTT','SH');


spool off
set echo off

exit; 
