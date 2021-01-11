spool /home/oracle/shell_scr/db_harden/rep_sqls/sql_4_7_REV_DBA_SYS_PRIVS.log

set echo on

SELECT GRANTEE, PRIVILEGE
FROM DBA_SYS_PRIVS
WHERE ADMIN_OPTION='YES'
AND GRANTEE not in ('AQ_ADMINISTRATOR_ROLE','DBA','OWBSYS',
'SCHEDULER_ADMIN','SYS','SYSTEM','WMSYS',
'APEX_040200','DVSYS','SYSKM','DV_ACCTMGR');

spool off
set echo off

exit; 
