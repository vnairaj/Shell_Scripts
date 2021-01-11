spool /home/oracle/shell_scr/db_harden/rep_sqls/sql_2_2_6_Os_roles.log
set echo on
SELECT UPPER(VALUE) FROM V$PARAMETER WHERE UPPER(NAME)='OS_ROLES';
spool off

exit;

