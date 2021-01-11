

spool /home/oracle/shell_scr/db_harden/rep_sqls/sql_3_3_password_lock.log
set echo on

SELECT PROFILE, RESOURCE_NAME, LIMIT
FROM DBA_PROFILES
WHERE RESOURCE_NAME='PASSWORD_LIFE_TIME'
AND
(
LIMIT = 'DEFAULT'
OR LIMIT = 'UNLIMITED'
OR LIMIT > 90
);

spool off
set echo off

exit; 
