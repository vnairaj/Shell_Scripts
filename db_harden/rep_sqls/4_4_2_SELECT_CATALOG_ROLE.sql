spool /home/oracle/shell_scr/db_harden/rep_sqls/sql_4_4_2_SELECT_CATALOG_ROLE.log

set echo on

SELECT GRANTEE, GRANTED_ROLE
FROM DBA_ROLE_PRIVS
WHERE granted_role='SELECT_CATALOG_ROLE'
AND grantee not in ('DBA','SYS','IMP_FULL_DATABASE','EXP_FULL_DATABASE',
'OEM_MONITOR', 'SYSBACKUP','EM_EXPRESS_BASIC');

spool off
set echo off

exit; 
