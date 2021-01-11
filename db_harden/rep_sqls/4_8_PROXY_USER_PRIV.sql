spool /home/oracle/shell_scr/db_harden/rep_sqls/sql_4_8_PROXY_USER_PRIV.log

set echo on

SELECT GRANTEE, GRANTED_ROLE
FROM DBA_ROLE_PRIVS
WHERE GRANTEE IN
(
SELECT PROXY
FROM DBA_PROXIES
)
AND GRANTED_ROLE NOT IN ('CONNECT');

spool off
set echo off

exit; 
