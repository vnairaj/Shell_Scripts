

spool /home/oracle/shell_scr/db_harden/rep_sqls/sql_3_1_failed_login.log
set echo on

SELECT PROFILE, RESOURCE_NAME, LIMIT
FROM DBA_PROFILES
WHERE PROFILE= 'DEFAULT' AND RESOURCE_NAME='FAILED_LOGIN_ATTEMPTS'
AND
(
LIMIT = 'DEFAULT'
OR LIMIT = 'UNLIMITED'
OR LIMIT > 5
);

spool off
set echo off

exit; 
