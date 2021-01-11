spool /home/oracle/shell_scr/db_harden/rep_sqls/sql_4_3_1_SELECT_ANY_DICTIONARY.log

set echo on

SELECT GRANTEE, PRIVILEGE
FROM DBA_SYS_PRIVS
WHERE PRIVILEGE='SELECT ANY DICTIONARY'
AND GRANTEE NOT IN ('DBA','DBSNMP','OEM_MONITOR',
'OLAPSYS','ORACLE_OCM','SYSMAN','WMSYS');

spool off
set echo off

exit; 
