set heading on
spool /home/oracle/shell_scr/db_harden/harden_4.log
set echo on

prompt "****************** 4.1.1 Ensure 'EXECUTE' Is Revoked from 'PUBLIC' on 'DBMS_ADVISOR' ******************"

set echo on
spool /home/oracle/shell_scr/db_harden/sql_4_1_1_Rev_execute_DBMS_ADVISOR.log


REVOKE EXECUTE ON DBMS_ADVISOR FROM PUBLIC;

spool off
set echo off

prompt "****************** 4.1.2 Ensure 'EXECUTE' Is Revoked from 'PUBLIC' on 'DBMS_CRYPTO' ******************"

set echo on
spool /home/oracle/shell_scr/db_harden/sql_4_1_2_Rev_execute_DBMS_CRYPTO.log

REVOKE EXECUTE ON DBMS_CRYPTO FROM PUBLIC;

spool off
set echo off


prompt "****************** 4.1.4 Ensure 'EXECUTE' Is Revoked from 'PUBLIC' on 'DBMS_JAVA_TEST' ******************"

set echo on
spool /home/oracle/shell_scr/db_harden/sql_4_1_4_Rev_execute_DBMS_JAVA_TEST.log

REVOKE EXECUTE ON DBMS_JAVA_TEST FROM PUBLIC;

spool off
set echo off

prompt "****************** 4.1.6 Ensure 'EXECUTE' Is Revoked from 'PUBLIC' on 'DBMS_LDAP' ******************"

set echo on
spool /home/oracle/shell_scr/db_harden/sql_4_1_6_Rev_execute_DBMS_LDAP.log

REVOKE EXECUTE ON DBMS_LDAP FROM PUBLIC;

spool off
set echo off

prompt "****************** 4.1.10 Ensure 'EXECUTE' Is Revoked from 'PUBLIC' on 'DBMS_SCHEDULER' ******************"

set echo on
spool /home/oracle/shell_scr/db_harden/sql_4_1_10_Rev_execute_DBMS_SCHEDULER.log

REVOKE EXECUTE ON DBMS_SCHEDULER FROM PUBLIC;

spool off
set echo off

prompt "****************** 4.1.12 Ensure 'EXECUTE' Is Revoked from 'PUBLIC' on 'DBMS_XMLGEN' ******************"

set echo on
spool /home/oracle/shell_scr/db_harden/sql_4_1_12_Rev_execute_DBMS_XMLGEN.log

REVOKE EXECUTE ON DBMS_XMLGEN FROM PUBLIC;

spool off
set echo off

prompt "****************** 4.1.13 Ensure 'EXECUTE' Is Revoked from 'PUBLIC' on 'DBMS_XMLQUERY' ******************"

set echo on
spool /home/oracle/shell_scr/db_harden/sql_4_1_13_Rev_execute_DBMS_XMLQUERY.log


REVOKE EXECUTE ON DBMS_XMLQUERY FROM PUBLIC;

spool off
set echo off

prompt "****************** 4.1.14 Ensure 'EXECUTE' Is Revoked from 'PUBLIC' on 'UTL_FILE' ******************"

set echo on
spool /home/oracle/shell_scr/db_harden/sql_4_1_14_Rev_execute_UTL_FILE.log

REVOKE EXECUTE ON UTL_FILE FROM PUBLIC;

spool off
set echo off

prompt "****************** 4.1.15 Ensure 'EXECUTE' Is Revoked from 'PUBLIC' on 'UTL_INADDR' ******************"

set echo on
spool /home/oracle/shell_scr/db_harden/sql_4_1_15_Rev_execute_UTL_INADDR.log


REVOKE EXECUTE ON UTL_INADDR FROM PUBLIC;

spool off
set echo off

prompt "****************** 4.1.16 Ensure 'EXECUTE' Is Revoked from 'PUBLIC' on 'UTL_TCP' ******************"

set echo on
spool /home/oracle/shell_scr/db_harden/sql_4_1_16_Rev_execute_UTL_TCP.log

REVOKE EXECUTE ON UTL_TCP FROM PUBLIC;

spool off
set echo off

prompt "****************** 4.1.17 Ensure 'EXECUTE' Is Revoked from 'PUBLIC' on 'UTL_MAIL' ******************"

set echo on
spool /home/oracle/shell_scr/db_harden/sql_4_1_17_Rev_execute_UTL_MAIL.log


REVOKE EXECUTE ON UTL_MAIL FROM PUBLIC;

spool off
set echo off

prompt "****************** 4.1.18 Ensure 'EXECUTE' Is Revoked from 'PUBLIC' on 'UTL_SMTP' ******************"

set echo on
spool /home/oracle/shell_scr/db_harden/sql_4_1_18_Rev_execute_UTL_SMTP.log

REVOKE EXECUTE ON UTL_SMTP FROM PUBLIC;

spool off
set echo off

prompt "****************** 4.1.19 Ensure 'EXECUTE' Is Revoked from 'PUBLIC' on 'UTL_DBWS' ******************"

set echo on
spool /home/oracle/shell_scr/db_harden/sql_4_1_19_Rev_execute_UTL_DBWS.log


REVOKE EXECUTE ON UTL_DBWS FROM PUBLIC;

spool off
set echo off

prompt "****************** 4.1.20 Ensure 'EXECUTE' Is Revoked from 'PUBLIC' on 'UTL_ORAMTS' ******************"

set echo on
spool /home/oracle/shell_scr/db_harden/sql_4_1_20_Rev_execute_UTL_ORAMTS.log

REVOKE EXECUTE ON UTL_ORAMTS FROM PUBLIC;

spool off
set echo off

prompt "****************** 4.1.21 Ensure 'EXECUTE' Is Revoked from 'PUBLIC' on 'UTL_HTTP' ******************"

set echo on
spool /home/oracle/shell_scr/db_harden/sql_4_1_21_Rev_execute_UTL_HTTP.log


REVOKE EXECUTE ON UTL_HTTP FROM PUBLIC;

spool off
set echo off

prompt "****************** 4.1.22 Ensure 'EXECUTE' Is Revoked from 'PUBLIC' on 'HTTPURITYPE' ******************"

set echo on
spool /home/oracle/shell_scr/db_harden/sql_4_1_22_Rev_execute_HTTPURITYPE.log


REVOKE EXECUTE ON HTTPURITYPE FROM PUBLIC;

spool off
set echo off

prompt "****************** 4.2.1 Ensure 'EXECUTE' Is Revoked from 'PUBLIC' on 'DBMS_SYS_SQL' ******************"

set echo on
spool /home/oracle/shell_scr/db_harden/sql_4_2_1_Rev_execute_DBMS_SYS_SQL.log

REVOKE EXECUTE ON DBMS_SYS_SQL FROM PUBLIC;

spool off
set echo off

prompt "****************** 4.2.2 Ensure 'EXECUTE' Is Revoked from 'PUBLIC' on 'DBMS_BACKUP_RESTORE' ******************"

set echo on
spool /home/oracle/shell_scr/db_harden/sql_4_2_2_Rev_execute_DBMS_BACKUP_RESTORE.log


REVOKE EXECUTE ON DBMS_BACKUP_RESTORE FROM PUBLIC;

spool off
set echo off

prompt "****************** 4.2.3 Ensure 'EXECUTE' Is Revoked from 'PUBLIC' on 'DBMS_AQADM_SYSCALLS' ******************"

set echo on
spool /home/oracle/shell_scr/db_harden/sql_4_2_3_Rev_execute_DBMS_AQADM_SYSCALLS.log

REVOKE EXECUTE ON DBMS_AQADM_SYSCALLS FROM PUBLIC;

spool off
set echo off

prompt "****************** 4.2.4 Ensure 'EXECUTE' Is Revoked from 'PUBLIC' on 'DBMS_REPACT_SQL_UTL' ******************"

set echo on
spool /home/oracle/shell_scr/db_harden/sql_4_2_4_Rev_execute_DBMS_REPACT_SQL_UTL.log


REVOKE EXECUTE ON DBMS_REPACT_SQL_UTL FROM PUBLIC;

spool off
set echo off

prompt "****************** 4.2.5 Ensure 'EXECUTE' Is Revoked from 'PUBLIC' on 'INITJVMAUX' ******************"

set echo on
spool /home/oracle/shell_scr/db_harden/sql_4_2_5_Rev_execute_INITJVMAUX.log

REVOKE EXECUTE ON INITJVMAUX FROM PUBLIC;

spool off
set echo off

prompt "****************** 4.2.6 Ensure 'EXECUTE' Is Revoked from 'PUBLIC' on 'DBMS_STREAMS_ADM_UTL' ******************"

set echo on
spool /home/oracle/shell_scr/db_harden/sql_4_2_6_Rev_execute_DBMS_STREAMS_ADM_UTL.log


REVOKE EXECUTE ON DBMS_STREAMS_ADM_UTL FROM PUBLIC;

spool off
set echo off

prompt "****************** 4.2.7 Ensure 'EXECUTE' Is Revoked from 'PUBLIC' on 'DBMS_AQADM_SYS' ******************"

set echo on
spool /home/oracle/shell_scr/db_harden/sql_4_2_7_Rev_execute_DBMS_AQADM_SYS.log

REVOKE EXECUTE ON DBMS_AQADM_SYS FROM PUBLIC;

spool off
set echo off

prompt "****************** 4.2.8 Ensure 'EXECUTE' Is Revoked from 'PUBLIC' on 'DBMS_STREAMS_RPC' ******************"

set echo on
spool /home/oracle/shell_scr/db_harden/sql_4_2_8_Rev_execute_DBMS_STREAMS_RPC.log

REVOKE EXECUTE ON DBMS_STREAMS_RPC FROM PUBLIC;

spool off
set echo off

prompt "****************** 4.2.9 Ensure 'EXECUTE' Is Revoked from 'PUBLIC' on 'DBMS_PRVTAQIM' ******************"

set echo on
spool /home/oracle/shell_scr/db_harden/sql_4_2_9_Rev_execute_DBMS_PRVTAQIM.log


REVOKE EXECUTE ON DBMS_PRVTAQIM FROM PUBLIC;

spool off
set echo off

prompt "****************** 4.2.10 Ensure 'EXECUTE' Is Revoked from 'PUBLIC' on 'LTADM' ******************"

set echo on
spool /home/oracle/shell_scr/db_harden/sql_4_2_10_Rev_execute_LTADM.log

REVOKE EXECUTE ON LTADM FROM PUBLIC;

spool off
set echo off

prompt "****************** 4.2.11 Ensure 'EXECUTE' Is Revoked from 'PUBLIC' on 'WWV_DBMS_SQL' ******************"

set echo on
spool /home/oracle/shell_scr/db_harden/sql_4_2_11_Rev_execute_WWV_DBMS_SQL.log


REVOKE EXECUTE ON WWV_DBMS_SQL FROM PUBLIC;

spool off
set echo off

prompt "****************** 4.2.12 Ensure 'EXECUTE' Is Revoked from 'PUBLIC' on 'WWV_EXECUTE_IMMEDIATE' ******************"

set echo on
spool /home/oracle/shell_scr/db_harden/sql_4_2_12_Rev_execute_WWV_EXECUTE_IMMEDIATE.log

REVOKE EXECUTE ON WWV_EXECUTE_IMMEDIATE FROM PUBLIC;

spool off
set echo off

prompt "****************** 4.2.13 Ensure 'EXECUTE' Is Revoked from 'PUBLIC' on 'DBMS_IJOB' ******************"

set echo on
spool /home/oracle/shell_scr/db_harden/sql_4_2_13_Rev_execute_DBMS_IJOB.log


REVOKE EXECUTE ON DBMS_IJOB FROM PUBLIC;

spool off
set echo off

prompt "****************** 4.2.14 Ensure 'EXECUTE' Is Revoked from 'PUBLIC' on 'DBMS_FILE_TRANSFER' ******************"

set echo on
spool /home/oracle/shell_scr/db_harden/sql_4_2_14_Rev_execute_DBMS_FILE_TRANSFER.log

REVOKE EXECUTE ON DBMS_FILE_TRANSFER FROM PUBLIC;

spool off
set echo off

prompt "****************** 4.9 Ensure 'EXECUTE ANY PROCEDURE' Is Revoked from 'OUTLN' ******************"

set echo on
spool /home/oracle/shell_scr/db_harden/sql_4_9_Rev_EXEC_ANY_PROC.log

REVOKE EXECUTE ANY PROCEDURE FROM OUTLN;

spool off
set echo off


prompt "****************** 4.10 Ensure 'EXECUTE' Is Revoked from 'PUBLIC' on 'DBMS_FILE_TRANSFER' ******************"

set echo on
spool /home/oracle/shell_scr/db_harden/sql_4_2_14_Rev_execute_DBMS_FILE_TRANSFER.log

REVOKE EXECUTE ANY PROCEDURE FROM DBSNMP;

spool off
set echo off

prompt "****************** 5.1 Enable 'USER' Audit Option ******************"

set echo on
spool /home/oracle/shell_scr/db_harden/sql_5_1_Audit_user.log

AUDIT USER;

spool off
set echo off

prompt "****************** 5.2 Enable 'ALTER USER' Audit Option ******************"

set echo on
spool /home/oracle/shell_scr/db_harden/sql_5_2_Audit_alter_User.log

AUDIT ALTER USER;

spool off
set echo off

prompt "****************** 5.3 Enable 'DROP USER' Audit Option ******************"

set echo on
spool /home/oracle/shell_scr/db_harden/sql_5_3_Audit_drop_user.log

AUDIT DROP USER;

spool off
set echo off

prompt "****************** 5.4 Enable 'ROLE' Audit Option ******************"

set echo on
spool /home/oracle/shell_scr/db_harden/sql_5_4_Audit_role.log

AUDIT ROLE;

spool off
set echo off

prompt "****************** 5.5 Enable 'SYSTEM GRANT' Audit Option ******************"

set echo on
spool /home/oracle/shell_scr/db_harden/sql_5_5_System_grant.log

AUDIT SYSTEM GRANT;

spool off
set echo off

prompt "****************** 5.6 Enable 'PROFILE' Audit Option ******************"

set echo on
spool /home/oracle/shell_scr/db_harden/sql_5_6_Audit_profile.log

AUDIT PROFILE;

spool off
set echo off

prompt "****************** 5.7 Enable 'ALTER PROFILE' Audit Option ******************"

set echo on
spool /home/oracle/shell_scr/db_harden/sql_5_7_Audit_alter_profile.log

AUDIT ALTER PROFILE;

spool off
set echo off

prompt "****************** 5.8 Enable 'DROP PROFILE' Audit Option ******************"

set echo on
spool /home/oracle/shell_scr/db_harden/sql_5_8_Audit_drop_profile.log

AUDIT DROP PROFILE;

spool off
set echo off


prompt "****************** 5.9 Enable 'DATABASE LINK' Audit Option ******************"

set echo on
spool /home/oracle/shell_scr/db_harden/sql_5_9_Audit_DATABASE_LINK.log

AUDIT DATABASE LINK;

spool off
set echo off

prompt "****************** 5.10 Enable 'PUBLIC DATABASE LINK' Audit Option ******************"

set echo on
spool /home/oracle/shell_scr/db_harden/sql_5_10_Audit_PUBLIC_DATABASE_LINK.log

AUDIT PUBLIC DATABASE LINK;

spool off
set echo off

prompt "****************** 5.11 Enable 'PUBLIC SYNONYM' Audit Option ******************"

set echo on
spool /home/oracle/shell_scr/db_harden/sql_5_11_Audit_PUBLIC_SYNONYM.log

AUDIT PUBLIC SYNONYM;

spool off
set echo off

prompt "****************** 5.12 Enable 'SYNONYM' Audit Option ******************"

set echo on
spool /home/oracle/shell_scr/db_harden/sql_5_12_Audit_SYNONYM.log

AUDIT SYNONYM;

spool off
set echo off

prompt "****************** 5.13 Enable 'GRANT DIRECTORY' Audit Option ******************"

set echo on
spool /home/oracle/shell_scr/db_harden/sql_5_13_Audit_System_GRANT_DIR.log

AUDIT GRANT DIRECTORY;

spool off
set echo off

prompt "****************** 5.14 Enable 'SELECT ANY DICTIONARY' Audit Option ******************"

set echo on
spool /home/oracle/shell_scr/db_harden/sql_5_14_Audit_SELECT_ANY_DICT.log

AUDIT SELECT ANY DICTIONARY;

spool off
set echo off

prompt "****************** 5.15 Enable 'GRANT ANY OBJECT PRIVILEGE' Audit Option ******************"

set echo on
spool /home/oracle/shell_scr/db_harden/sql_5_15_Audit_GRANT_ANY_OBJ_PRIV.log

AUDIT GRANT ANY OBJECT PRIVILEGE;

spool off
set echo off

prompt "****************** 5.16 Enable 'GRANT ANY PRIVILEGE' Audit Option ******************"

set echo on
spool /home/oracle/shell_scr/db_harden/sql_5_16_Audit_GRANT_ANY_PRIV.log

AUDIT DROP PROFILE;

spool off
set echo off

prompt "****************** 5.17 Enable 'DROP ANY PROCEDURE' Audit Option ******************"

set echo on
spool /home/oracle/shell_scr/db_harden/sql_5_17_Audit_DROP_ANY_PROC.log

AUDIT DROP ANY PROCEDURE;

spool off
set echo off

prompt "****************** 5.18 Enable 'ALL' Audit Option on 'SYS.AUD$' ******************"

set echo on
spool /home/oracle/shell_scr/db_harden/sql_5_18_Audit_ALL_SYS_AUD.log

AUDIT ALL ON SYS.AUD$ BY ACCESS;

spool off
set echo off

prompt "****************** 5.19 Enable 'PROCEDURE' Audit Option ******************"

set echo on
spool /home/oracle/shell_scr/db_harden/sql_5_19_Audit_PROCEDURE.log

AUDIT PROCEDURE;

spool off
set echo off

prompt "****************** 5.20 Enable 'ALTER SYSTEM' Audit Option ******************"

set echo on
spool /home/oracle/shell_scr/db_harden/sql_5_20_Audit_ALTER_SYSTEM.log

AUDIT ALTER SYSTEM;

spool off
set echo off

prompt "****************** 5.21 Enable 'TRIGGER' Audit Option ******************"

set echo on
spool /home/oracle/shell_scr/db_harden/sql_5_21_Audit_TRIGGER.log

AUDIT TRIGGER;

spool off
set echo off

prompt "****************** 5.22 Enable 'CREATE SESSION' Audit Option ******************"

set echo on
spool /home/oracle/shell_scr/db_harden/sql_5_22_Audit_CREATE_SESSION.log

AUDIT SESSION;

spool off
set echo off

exit;