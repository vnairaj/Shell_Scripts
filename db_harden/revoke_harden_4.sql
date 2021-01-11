
prompt "****************** 4.3.1 Ensure 'SELECT_ANY_DICTIONARY' Is Revoked from Unauthorized 'GRANTEE' ******************"

set lines 200
set heading off
set pages 0
col grantee for a30
col granted_role for a70

spool /home/oracle/shell_scr/db_harden/sql_4_3_1_Rev_SELECT_ANY_DICTIONARY.log

SELECT GRANTEE, PRIVILEGE
FROM DBA_SYS_PRIVS
WHERE PRIVILEGE='SELECT ANY DICTIONARY'
AND GRANTEE NOT IN ('DBA','DBSNMP','OEM_MONITOR',
'OLAPSYS','ORACLE_OCM','SYSMAN','WMSYS');

spool off

prompt "****************** 4.3.2 Ensure 'SELECT ANY TABLE' Is Revoked from Unauthorized 'GRANTEE' ******************"
set lines 200
set heading off
set pages 0
col grantee for a30
col granted_role for a70

spool /home/oracle/shell_scr/db_harden/sql_4_3_2_Rev_SELECT_ANY_TABLE.log

SELECT GRANTEE, PRIVILEGE
FROM DBA_SYS_PRIVS
WHERE PRIVILEGE='SELECT ANY TABLE'
AND GRANTEE NOT IN ('DBA', 'MDSYS', 'SYS', 'IMP_FULL_DATABASE', 'EXP_FULL_DATABASE',
'DATAPUMP_IMP_FULL_DATABASE', 'WMSYS', 'SYSTEM','OLAP_DBA',
'DV_REALM_OWNER');

spool off

prompt "****************** 4.3.3 Ensure 'AUDIT SYSTEM' Is Revoked from Unauthorized 'GRANTEE' ******************"
set lines 200
set heading off
set pages 0
col grantee for a30
col granted_role for a70

spool /home/oracle/shell_scr/db_harden/sql_4_3_3_Rev_AUDIT_SYSTEM.log

SELECT GRANTEE, PRIVILEGE
FROM DBA_SYS_PRIVS
WHERE PRIVILEGE='AUDIT SYSTEM'
AND GRANTEE NOT IN ('DBA','DATAPUMP_IMP_FULL_DATABASE','IMP_FULL_DATABASE',
'SYS','AUDIT_ADMIN');

spool off

prompt "****************** 4.3.4 Ensure 'EXEMPT ACCESS POLICY' Is Revoked from Unauthorized 'GRANTEE' ******************"

set lines 200
set heading off
set pages 0
col grantee for a30
col granted_role for a70

spool /home/oracle/shell_scr/db_harden/sql_4_3_4_Rev_EXEMPT_ACCESS_POLICY.log

SELECT GRANTEE, PRIVILEGE
FROM DBA_SYS_PRIVS
WHERE PRIVILEGE='EXEMPT ACCESS POLICY';

spool off

prompt "****************** 4.3.5 Ensure 'BECOME USER' Is Revoked from Unauthorized 'GRANTEE' ******************"

set lines 200
set heading off
set pages 0
col grantee for a30
col granted_role for a70

spool /home/oracle/shell_scr/db_harden/sql_4_3_5_Rev_BECOME_USER.log

SELECT GRANTEE, PRIVILEGE
FROM DBA_SYS_PRIVS
WHERE PRIVILEGE='BECOME USER'
AND GRANTEE NOT IN ('DBA','SYS','IMP_FULL_DATABASE');

spool off

prompt "****************** 4.3.6 Ensure 'CREATE_PROCEDURE' Is Revoked from Unauthorized 'GRANTEE' ******************"

set lines 200
set heading off
set pages 0
col grantee for a30
col granted_role for a70

spool /home/oracle/shell_scr/db_harden/sql_4_3_6_Rev_CREATE_PROCEDURE.log

SELECT GRANTEE, PRIVILEGE
FROM DBA_SYS_PRIVS
WHERE PRIVILEGE='CREATE PROCEDURE'
AND GRANTEE NOT IN ( 'DBA','DBSNMP','MDSYS','OLAPSYS','OWB$CLIENT',
'OWBSYS','RECOVERY_CATALOG_OWNER','SPATIAL_CSW_ADMIN_USR',
'SPATIAL_WFS_ADMIN_USR','SYS','APEX_030200','APEX_040000',
'APEX_040100','APEX_040200','DVF','RESOURCE','DV_REALM_RESOURCE',
'APEX_GRANTS_FOR_NEW_USERS_ROLE');

spool off

prompt "****************** 4.3.7 Ensure 'ALTER SYSTEM' Is Revoked from Unauthorized 'GRANTEE' ******************"

set lines 200
set heading off
set pages 0
col grantee for a30
col granted_role for a70

spool /home/oracle/shell_scr/db_harden/sql_4_3_7_Rev_ALTER_SYSTEM.log

SELECT GRANTEE, PRIVILEGE
FROM DBA_SYS_PRIVS
WHERE PRIVILEGE='ALTER SYSTEM'
AND GRANTEE NOT IN ('SYS','SYSTEM','APEX_030200','APEX_040000',
'APEX_040100','APEX_040200','DBA','EM_EXPRESS_ALL','SYSBACKUP','GSMADMIN_ROLE',
'GSM_INTERNAL','SYSDG','GSMADMIN_INTERNAL');

spool off

prompt "****************** 4.3.8 Ensure 'CREATE ANY LIBRARY' Is Revoked from Unauthorized 'GRANTEE' ******************"

set lines 200
set heading off
set pages 0
col grantee for a30
col granted_role for a70

spool /home/oracle/shell_scr/db_harden/sql_4_3_8_Rev_CREATE_ANY_LIBRARY.log

SELECT GRANTEE, PRIVILEGE
FROM DBA_SYS_PRIVS
WHERE PRIVILEGE='CREATE ANY LIBRARY'
AND GRANTEE NOT IN ('SYS','SYSTEM','DBA','IMP_FULL_DATABASE');

spool off

prompt "****************** 4.3.9 Ensure 'CREATE LIBRARY' Is Revoked from Unauthorized 'GRANTEE' ******************"

set lines 200
set heading off
set pages 0
col grantee for a30
col granted_role for a70

spool /home/oracle/shell_scr/db_harden/sql_4_3_9_Rev_CREATE_LIBRARY.log

SELECT GRANTEE, PRIVILEGE
FROM DBA_SYS_PRIVS
WHERE PRIVILEGE='CREATE LIBRARY'
AND GRANTEE NOT IN ('SYS','SYSTEM','DBA','MDSYS','SPATIAL_WFS_ADMIN_USR',
'SPATIAL_CSW_ADMIN_USR','DVSYS','GSMADMIN_INTERNAL','XDB');

spool off

prompt "****************** 4.3.10 Ensure 'GRANT ANY OBJECT PRIVILEGE' Is Revoked from Unauthorized 'GRANTEE' ******************"

set lines 200
set heading off
set pages 0
col grantee for a30
col granted_role for a70

spool /home/oracle/shell_scr/db_harden/sql_4_3_10_Rev_GRANT_ANY_OBJ_PRIV.log

SELECT GRANTEE, PRIVILEGE
FROM DBA_SYS_PRIVS
WHERE PRIVILEGE='GRANT ANY OBJECT PRIVILEGE'
AND GRANTEE NOT IN ('DBA','SYS','IMP_FULL_DATABASE','DATAPUMP_IMP_FULL_DATABASE',
'EM_EXPRESS_ALL', 'DV_REALM_OWNER');

spool off

prompt "****************** 4.3.11 Ensure 'GRANT ANY ROLE' Is Revoked from Unauthorized 'GRANTEE' ******************"

set lines 200
set heading off
set pages 0
col grantee for a30
col granted_role for a70

spool /home/oracle/shell_scr/db_harden/sql_4_3_11_Rev_GRANT_ANY_ROLE.log

SELECT GRANTEE, PRIVILEGE
FROM DBA_SYS_PRIVS
WHERE PRIVILEGE='GRANT ANY ROLE'
AND GRANTEE NOT IN ('DBA','SYS','DATAPUMP_IMP_FULL_DATABASE','IMP_FULL_DATABASE',
'SPATIAL_WFS_ADMIN_USR','SPATIAL_CSW_ADMIN_USR',
'GSMADMIN_INTERNAL','DV_REALM_OWNER', 'EM_EXPRESS_ALL', 'DV_OWNER');

spool off

prompt "****************** 4.3.12 Ensure 'GRANT ANY PRIVILEGE' Is Revoked from Unauthorized 'GRANTEE' ******************"

set lines 200
set heading off
set pages 0
col grantee for a30
col granted_role for a70

spool /home/oracle/shell_scr/db_harden/sql_4_3_12_Rev_GRANT_ANY_PRIVILEGE.log

SELECT GRANTEE, PRIVILEGE
FROM DBA_SYS_PRIVS
WHERE PRIVILEGE='GRANT ANY PRIVILEGE'
AND GRANTEE NOT IN ('DBA','SYS','IMP_FULL_DATABASE','DATAPUMP_IMP_FULL_DATABASE',
'DV_REALM_OWNER', 'EM_EXPRESS_ALL');

spool off

prompt "****************** 4.4.1 Ensure 'DELETE_CATALOG_ROLE' Is Revoked from Unauthorized 'GRANTEE' ******************"

set lines 200
set heading off
set pages 0
col grantee for a30
col granted_role for a70

spool /home/oracle/shell_scr/db_harden/sql_4_4_1_Rev_DELETE_CATALOG_ROLE.log

SELECT GRANTEE, GRANTED_ROLE
FROM DBA_ROLE_PRIVS
WHERE granted_role='DELETE_CATALOG_ROLE'
AND GRANTEE NOT IN ('DBA','SYS');

spool off

prompt "****************** 4.4.2 Ensure 'SELECT_CATALOG_ROLE' Is Revoked from Unauthorized 'GRANTEE' ******************"

set lines 200
set heading off
set pages 0
col grantee for a30
col granted_role for a70

spool /home/oracle/shell_scr/db_harden/sql_4_4_2_Rev_SELECT_CATALOG_ROLE.log

SELECT GRANTEE, GRANTED_ROLE
FROM DBA_ROLE_PRIVS
WHERE granted_role='SELECT_CATALOG_ROLE'
AND grantee not in ('DBA','SYS','IMP_FULL_DATABASE','EXP_FULL_DATABASE',
'OEM_MONITOR', 'SYSBACKUP','EM_EXPRESS_BASIC');

spool off

prompt "****************** 4.4.3 Ensure 'EXECUTE_CATALOG_ROLE' Is Revoked from Unauthorized 'GRANTEE' ******************"

set lines 200
set heading off
set pages 0
col grantee for a30
col granted_role for a70

spool /home/oracle/shell_scr/db_harden/sql_4_4_3_Rev_EXECUTE_CATALOG_ROLE.log

SELECT GRANTEE, GRANTED_ROLE
FROM DBA_ROLE_PRIVS
WHERE granted_role='EXECUTE_CATALOG_ROLE'
AND grantee not in ('DBA','SYS','IMP_FULL_DATABASE','EXP_FULL_DATABASE');

spool off

prompt "****************** 4.4.4 Ensure 'DBA' Is Revoked from Unauthorized 'GRANTEE' ******************"

set lines 200
set heading off
set pages 0
col grantee for a30
col granted_role for a70

spool /home/oracle/shell_scr/db_harden/sql_4_4_4_Rev_DBA.log

SELECT GRANTEE, GRANTED_ROLE
FROM DBA_ROLE_PRIVS
WHERE GRANTED_ROLE='DBA'
AND GRANTEE NOT IN ('SYS','SYSTEM');

spool off

prompt "****************** 4.5.1 Ensure 'ALL' Is Revoked from Unauthorized 'GRANTEE' on 'AUD$' ******************"


set lines 200
set heading off
set pages 0
col grantee for a30
col granted_role for a70

spool /home/oracle/shell_scr/db_harden/sql_4_5_1_Rev_ALL_AUD.log

SELECT GRANTEE, PRIVILEGE
FROM DBA_TAB_PRIVS
WHERE TABLE_NAME='AUD$'
AND GRANTEE NOT IN ('DELETE_CATALOG_ROLE');

spool off


prompt "****************** 4.5.2 Ensure 'ALL' Is Revoked from Unauthorized 'GRANTEE' on 'USER_HISTORY$' ******************"


set lines 200
set heading off
set pages 0
col grantee for a30
col granted_role for a70

spool /home/oracle/shell_scr/db_harden/sql_4_5_2_Rev_ALL_USER_HISTORY.log

SELECT GRANTEE, PRIVILEGE
FROM DBA_TAB_PRIVS
WHERE TABLE_NAME='USER_HISTORY$';

spool off

prompt "****************** 4.5.3 Ensure 'ALL' Is Revoked from Unauthorized 'GRANTEE' on 'LINK$' ******************"


set lines 200
set heading off
set pages 0
col grantee for a30
col granted_role for a70

spool /home/oracle/shell_scr/db_harden/sql_4_5_3_Rev_ALL_LINK.log

SELECT GRANTEE, PRIVILEGE
FROM DBA_TAB_PRIVS
WHERE TABLE_NAME='LINK$'
AND GRANTEE NOT IN ('DV_SECANALYST');

spool off


prompt "****************** 4.5.4 Ensure 'ALL' Is Revoked from Unauthorized 'GRANTEE' on 'SYS.USER$' ******************"


set lines 200
set heading off
set pages 0
col grantee for a30
col granted_role for a70

spool /home/oracle/shell_scr/db_harden/sql_4_5_4_Rev_ALL_SYS_USER.log

SELECT GRANTEE, PRIVILEGE
FROM DBA_TAB_PRIVS
WHERE TABLE_NAME='USER$'
AND GRANTEE NOT IN ('CTXSYS','XDB','APEX_030200',
'APEX_040000','APEX_040100','APEX_040200','DV_SECANALYST','DVSYS','ORACLE_OCM');

spool off

prompt "****************** 4.5.5 Ensure 'ALL' Is Revoked from Unauthorized 'GRANTEE' on 'DBA_%' ******************"


set lines 200
set heading off
set pages 0
col grantee for a30
col granted_role for a70
col OWNER for a14
col TABLE_NAME for a40
col GRANTOR for a14
col PRIVILEGE for a14

spool /home/oracle/shell_scr/db_harden/sql_4_5_5_Rev_ALL_DBA.log

SELECT * FROM DBA_TAB_PRIVS
WHERE TABLE_NAME LIKE 'DBA_%'
and GRANTEE NOT IN ('APEX_030200','APPQOSSYS','AQ_ADMINISTRATOR_ROLE','CTXSYS',
'EXFSYS','MDSYS','OLAP_XS_ADMIN','OLAPSYS','ORDSYS','OWB$CLIENT','OWBSYS',
'SELECT_CATALOG_ROLE','WM_ADMIN_ROLE','WMSYS','XDBADMIN','LBACSYS',
'ADM_PARALLEL_EXECUTE_TASK','CISSCANROLE','APEX_040200','SYSKM','ORACLE_OCM',
'DVSYS','GSMADMIN_INTERNAL','XDB','SYSDG','SYS','AUDIT_ADMIN', 'AUDIT_VIEWER',
'CAPTURE_ADMIN', 'DBA', 'DV_ACCTMGR', 'DV_MONITOR', 'DV_SECANALYST');

spool off

prompt "****************** 4.5.6 Ensure 'ALL' Is Revoked from Unauthorized 'GRANTEE' on 'SYS.SCHEDULER$_CREDENTIAL' ******************"


set lines 200
set heading off
set pages 0
col grantee for a30
col granted_role for a70

spool /home/oracle/shell_scr/db_harden/sql_4_5_6_Rev_ALL_SYS_SCHEDULER_CREDENTIAL.log

SELECT GRANTEE, PRIVILEGE
FROM DBA_TAB_PRIVS
WHERE TABLE_NAME='SCHEDULER$_CREDENTIAL';


spool off


prompt "****************** 4.5.7 Ensure 'SYS.USER$MIG' Has Been Dropped ******************"


set lines 200
set heading off
set pages 0
col grantee for a30
col granted_role for a70

spool /home/oracle/shell_scr/db_harden/sql_4_5_7_Drop_SYS_USER_MIG.log

SELECT OWNER, TABLE_NAME
FROM ALL_TABLES
WHERE OWNER='SYS'
AND TABLE_NAME='USER$MIG';

spool off

prompt "****************** 4.6 Ensure '%ANY%' Is Revoked from Unauthorized 'GRANTEE' ******************"

set lines 200
set heading off
set pages 0
col grantee for a30
col granted_role for a70
col PRIVILEGE for a40

spool /home/oracle/shell_scr/db_harden/sql_4_6_Rev_ANY.log

SELECT GRANTEE, PRIVILEGE
FROM DBA_SYS_PRIVS
WHERE PRIVILEGE LIKE '%ANY%'
AND GRANTEE NOT IN ('AQ_ADMINISTRATOR_ROLE','DBA','DBSNMP','EXFSYS',
'EXP_FULL_DATABASE','IMP_FULL_DATABASE','DATAPUMP_IMP_FULL_DATABASE',
'JAVADEBUGPRIV','MDSYS','OEM_MONITOR','OLAPSYS','OLAP_DBA','ORACLE_OCM',
'OWB$CLIENT','OWBSYS','SCHEDULER_ADMIN','SPATIAL_CSW_ADMIN_USR',
'SPATIAL_WFS_ADMIN_USR','SYS','SYSMAN','SYSTEM','WMSYS','APEX_030200',
'APEX_040000','APEX_040100','APEX_040200','LBACSYS',
'SYSBACKUP','CTXSYS','OUTLN','DVSYS','ORDPLUGINS','ORDSYS',
'GSMADMIN_INTERNAL','XDB','SYSDG','AUDIT_ADMIN','DV_OWNER','DV_REALM_OWNER',
'EM_EXPRESS_ALL', 'RECOVERY_CATALOG_OWNER');

spool off

prompt "****************** 4.7 Ensure 'DBA_SYS_PRIVS.%' Is Revoked from Unauthorized 'GRANTEE' with 'ADMIN_OPTION' Set to 'YES' ******************"


set lines 200
set heading off
set pages 0
col grantee for a30
col granted_role for a70

spool /home/oracle/shell_scr/db_harden/sql_4_7_Rev_ADMIN_OPTION_YES.log

SELECT GRANTEE, PRIVILEGE
FROM DBA_SYS_PRIVS
WHERE ADMIN_OPTION='YES'
AND GRANTEE not in ('AQ_ADMINISTRATOR_ROLE','DBA','OWBSYS',
'SCHEDULER_ADMIN','SYS','SYSTEM','WMSYS',
'APEX_040200','DVSYS','SYSKM','DV_ACCTMGR');

spool off


prompt "****************** 4.8 Ensure Proxy Users Have Only 'CONNECT' Privilege ******************"


set lines 200
set heading off
set pages 0
col grantee for a30
col granted_role for a70

spool /home/oracle/shell_scr/db_harden/sql_4_8_Rev_CONNECT_Priv.log

SELECT GRANTEE, GRANTED_ROLE
FROM DBA_ROLE_PRIVS
WHERE GRANTEE IN
(
SELECT PROXY
FROM DBA_PROXIES
)
AND GRANTED_ROLE NOT IN ('CONNECT');

spool off


prompt "****************** 4.9 Ensure 'EXECUTE ANY PROCEDURE' Is Revoked from 'OUTLN' ******************"


set lines 200
set heading off
set pages 0
col grantee for a30
col granted_role for a70

spool /home/oracle/shell_scr/db_harden/sql_4_9_Rev_EXECUTE_ANY_PROCEDURE_OUTLN.log

SELECT GRANTEE, PRIVILEGE
FROM DBA_SYS_PRIVS
WHERE PRIVILEGE='EXECUTE ANY PROCEDURE'
AND GRANTEE='OUTLN';


exit;