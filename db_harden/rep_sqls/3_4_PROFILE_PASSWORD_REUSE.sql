

spool /home/oracle/shell_scr/db_harden/rep_sqls/sql_3_4_password_reusemax.log
set echo on

SELECT PROFILE, RESOURCE_NAME, LIMIT
FROM DBA_PROFILES
WHERE PROFILE= 'DEFAULT' AND RESOURCE_NAME='PASSWORD_REUSE_MAX'
AND
(
LIMIT = 'DEFAULT'
OR LIMIT = 'UNLIMITED'
OR LIMIT <= 20
);

spool off
set echo off

exit; 
