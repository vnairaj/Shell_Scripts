

spool /home/oracle/shell_scr/db_harden/rep_sqls/sql_3_10_users_default_profile.log

set echo on

SELECT USERNAME
FROM DBA_USERS
WHERE PROFILE='DEFAULT'
AND ACCOUNT_STATUS='OPEN'
AND USERNAME NOT IN
('ANONYMOUS', 'CTXSYS', 'DBSNMP', 'EXFSYS', 'LBACSYS',
'MDSYS', 'MGMT_VIEW','OLAPSYS','OWBSYS', 'ORDPLUGINS',
'ORDSYS', 'OUTLN', 'SI_INFORMTN_SCHEMA','SYS',
'SYSMAN', 'SYSTEM', 'TSMSYS', 'WK_TEST', 'WKSYS',
'WKPROXY', 'WMSYS', 'XDB', 'CISSCAN');

spool off
set echo off

exit; 
