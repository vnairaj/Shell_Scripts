spool /home/oracle/shell_scr/db_harden/rep_sqls/sql_4_3_3_AUDIT_SYSTEM.log

set echo on

SELECT GRANTEE, PRIVILEGE
FROM DBA_SYS_PRIVS
WHERE PRIVILEGE='AUDIT SYSTEM'
AND GRANTEE NOT IN ('DBA','DATAPUMP_IMP_FULL_DATABASE','IMP_FULL_DATABASE',
'SYS','AUDIT_ADMIN');

spool off
set echo off

exit; 
