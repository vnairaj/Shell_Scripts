 SET ECHO ON 
 spool /home/oracle/shell_scr/db_harden/OPDIR/HRDSQLDIR/sql_harden_loc_lis.log 
ALTER SYSTEM SET LOCAL_LISTENER='  (DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=vr-mig-01)(PORT=1521)))';
spool off
exit;
