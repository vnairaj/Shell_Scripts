

spool /home/oracle/shell_scr/db_harden/rep_sqls/sql_3_9_sessionsper_user.log
set echo on

SELECT PROFILE, RESOURCE_NAME, LIMIT
FROM DBA_PROFILES
WHERE PROFILE= 'DEFAULT' AND RESOURCE_NAME='SESSIONS_PER_USER'
AND
(
LIMIT = 'DEFAULT'
OR LIMIT = 'UNLIMITED'
OR LIMIT > 10
);

spool off
set echo off

exit; 
