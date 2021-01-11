

spool /home/oracle/shell_scr/db_harden/rep_sqls/sql_3_5_password_reusetime.log
set echo on

SELECT PROFILE, RESOURCE_NAME, LIMIT
FROM DBA_PROFILES
WHERE RESOURCE_NAME='PASSWORD_REUSE_TIME'
AND
(
LIMIT = 'DEFAULT'
OR LIMIT = 'UNLIMITED'
OR LIMIT < 365
);

spool off
set echo off

exit; 
