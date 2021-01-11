

spool /home/oracle/shell_scr/db_harden/rep_sqls/sql_3_2_password_lock.log
set echo on

SELECT PROFILE, RESOURCE_NAME, LIMIT
FROM DBA_PROFILES
WHERE PROFILE= 'DEFAULT' AND RESOURCE_NAME='PASSWORD_LOCK_TIME'
AND
(
LIMIT = 'DEFAULT'
OR LIMIT = 'UNLIMITED'
OR LIMIT < 1
);

spool off
set echo off

exit; 
