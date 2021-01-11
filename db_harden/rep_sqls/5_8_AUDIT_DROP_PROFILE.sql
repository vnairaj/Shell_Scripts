spool /home/oracle/shell_scr/db_harden/rep_sqls/sql_5_8_AUDIT_DROP_PROFILE.log

set echo on

SELECT AUDIT_OPTION, SUCCESS, FAILURE
FROM DBA_STMT_AUDIT_OPTS
WHERE AUDIT_OPTION='DROP PROFILE'
AND USER_NAME IS NULL
AND PROXY_NAME IS NULL
AND SUCCESS = 'BY ACCESS'
AND FAILURE = 'BY ACCESS';

spool off
set echo off

exit; 
