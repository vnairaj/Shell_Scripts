 SET ECHO ON 
 spool /home/oracle/shell_scr/db_harden/OPDIR/HRDSQLDIR/sql_harden_loc_lis.log 
ALTER SYSTEM SET LOCAL_LISTENER='';
spool off
exit;
