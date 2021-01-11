
spool /home/oracle/shell_scr/db_harden/rep_sqls/1_2_DEF_Sql.log
set echo on 
SELECT USERNAME FROM DBA_USERS_WITH_DEFPWD WHERE USERNAME NOT LIKE '%XS$NULL%';
spool off

exit;

