

spool /home/oracle/shell_scr/db_harden/rep_sqls/sql_3_6_password_gracetime.log
set echo on

SELECT PROFILE, RESOURCE_NAME, LIMIT
FROM DBA_PROFILES
WHERE RESOURCE_NAME='PASSWORD_GRACE_TIME'
AND
(
LIMIT = 'DEFAULT'
OR LIMIT = 'UNLIMITED'
OR LIMIT > 5
);

spool off
set echo off

exit; 
