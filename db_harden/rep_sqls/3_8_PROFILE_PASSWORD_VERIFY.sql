

spool /home/oracle/shell_scr/db_harden/rep_sqls/sql_3_8_password_verifyfunction.log
set echo on

SELECT PROFILE, RESOURCE_NAME
FROM DBA_PROFILES
WHERE PROFILE= 'DEFAULT' AND RESOURCE_NAME='PASSWORD_VERIFY_FUNCTION'
AND (LIMIT = 'DEFAULT' OR LIMIT = 'NULL');

spool off
set echo off

exit; 
