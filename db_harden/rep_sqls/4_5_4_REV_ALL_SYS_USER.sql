spool /home/oracle/shell_scr/db_harden/rep_sqls/sql_4_5_4_REV_ALL_SYS_USER.log

set echo on

SELECT GRANTEE, PRIVILEGE
FROM DBA_TAB_PRIVS
WHERE TABLE_NAME='USER$'
AND GRANTEE NOT IN ('CTXSYS','XDB','APEX_030200',
'APEX_040000','APEX_040100','APEX_040200','DV_SECANALYST','DVSYS','ORACLE_OCM');

spool off
set echo off

exit; 
