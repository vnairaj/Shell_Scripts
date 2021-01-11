set heading on
spool /home/oracle/shell_scr/db_harden/harden.log
set echo on

prompt "****************** 1.2 Change the Passwords of all default users ******************"

begin
for r_user in
(select username from dba_users_with_defpwd where username not like '%XS$NULL%')
loop
DBMS_OUTPUT.PUT_LINE('Password for user '||r_user.username||' will be changed.');
execute immediate 'alter user "'||r_user.username||'" identified by
"'||DBMS_RANDOM.string('a',16)||'"account lock password expire';
end loop;
end;
/

set echo off
prompt "******************  END OF 1.2 Change the Passwords of all default users ******************"



prompt "****************** 1.3 Ensure All Sample Data And Users Have Been Removed ******************"

spool off

define pwd_system=Oracle123
define spl_file=/home/oracle/shell_scr/db_harden/drop_default.log
@$ORACLE_HOME/demo/schema/drop_sch.sql
set echo on
spool  1.3_sql.log
DROP USER SCOTT CASCADE;
set echo off
prompt "******************  END OF Ensure All Sample Data And Users Have Been Removed ******************"
spool off


prompt "****************** 2.2.1 Ensure 'AUDIT_SYS_OPERATIONS' Is Set to 'TRUE ****************** "

set echo on
spool /home/oracle/shell_scr/db_harden/2.2.1_audit_sys_harden.log

ALTER SYSTEM SET AUDIT_SYS_OPERATIONS = TRUE SCOPE=SPFILE;
spool off
set echo off


set define off
prompt "****************** 2.2.2 Ensure 'DB_AUDIT_TRAIL' Is not set to NONE ******************"

set echo on
spool /home/oracle/shell_scr/db_harden/sql_2_2_2_audit_trail_harden.log


ALTER SYSTEM SET AUDIT_TRAIL =DB,EXTENDED SCOPE = SPFILE;

spool off
set echo off

prompt "****************** 2.2.3 Ensure 'GLOBAL_NAMES' Is not set to TRUE ******************"

set echo on
spool /home/oracle/shell_scr/db_harden/sql_2_2_3_global_names.log

ALTER SYSTEM SET GLOBAL_NAMES = TRUE SCOPE = SPFILE;

spool off
set echo off

prompt "****************** 2.2.6 Ensure 'OS_ROLES' Is Set to 'FALSE' ******************"

set echo on
spool /home/oracle/shell_scr/db_harden/sql_2_2_6_Os_roles.log


ALTER SYSTEM SET OS_ROLES = FALSE SCOPE = SPFILE;

spool off
set echo off

prompt "****************** 2.2.8 Ensure 'REMOTE_LOGIN_PASSWORDFILE' Is Set to 'NONE' ******************"

set echo on
spool /home/oracle/shell_scr/db_harden/sql_2_2_8_Rem_Login_Pwd_File.log


ALTER SYSTEM SET REMOTE_LOGIN_PASSWORDFILE = NONE SCOPE = SPFILE;

spool off
set echo off

prompt "****************** 2.2.9 Ensure 'REMOTE_OS_AUTHENT' Is Set to 'FALSE' ******************"

set echo on
spool /home/oracle/shell_scr/db_harden/sql_2_2_9_os_authent.log


ALTER SYSTEM SET REMOTE_OS_AUTHENT = FALSE SCOPE = SPFILE;

spool off
set echo off

prompt "****************** 2.2.10 Ensure 'REMOTE_OS_ROLES' Is Set to 'FALSE' ******************"

set echo on
spool /home/oracle/shell_scr/db_harden/sql_2_2_10_Rem_OS_roles.log


ALTER SYSTEM SET REMOTE_OS_ROLES = FALSE SCOPE = SPFILE;

spool off
set echo off

prompt "****************** 2.2.11 Ensure 'UTIL_FILE_DIR' Is Empty ******************"

set echo on
spool /home/oracle/shell_scr/db_harden/sql_2_2_11_UTIL_FILE_DIR.log

ALTER SYSTEM SET UTIL_FILE_DIR = '' SCOPE = SPFILE;

spool off
set echo off

prompt "****************** 2.2.12 Ensure 'SEC_CASE_SENSITIVE_LOGON' Is Set to 'TRUE' ******************"

set echo on
spool /home/oracle/shell_scr/db_harden/sql_2_2_12_Sec_case_sensLogon.log


ALTER SYSTEM SET SEC_CASE_SENSITIVE_LOGON = TRUE SCOPE = SPFILE;

spool off
set echo off

prompt "****************** 2.2.13 Ensure 'SEC_MAX_FAILED_LOGIN_ATTEMPTS' Is Set to '10' ******************"

set echo on
spool /home/oracle/shell_scr/db_harden/sql_2_2_13_Sec_maxfailed_login.log


ALTER SYSTEM SET SEC_MAX_FAILED_LOGIN_ATTEMPTS ='10' SCOPE = SPFILE;

spool off
set echo off

prompt "****************** 2.2.14 Ensure 'SEC_PROTOCOL_ERROR_FURTHER_ACTION' Is Set to 'DELAY,3' or 'DROP,3' ******************"

set echo on
spool /home/oracle/shell_scr/db_harden/sql_2_2_14_SEC_PROTOCOL_ERROR_FURTHER_ACTION.log


ALTER SYSTEM SET SEC_PROTOCOL_ERROR_FURTHER_ACTION = 'DELAY,3' SCOPE = SPFILE;
ALTER SYSTEM SET SEC_PROTOCOL_ERROR_FURTHER_ACTION = 'DROP,3' SCOPE = SPFILE;

spool off
set echo off

prompt "****************** 2.2.15 Ensure 'SEC_PROTOCOL_ERROR_TRACE_ACTION' Is Set to 'LOG' ******************"

set echo on
spool /home/oracle/shell_scr/db_harden/sql_2_2_15_SEC_PROTOCOL_ERROR_TRACE_ACTION.log


ALTER SYSTEM SET SEC_PROTOCOL_ERROR_TRACE_ACTION=LOG SCOPE = BOTH;

spool off
set echo off

prompt "****************** 2.2.16 Ensure 'SEC_RETURN_SERVER_RELEASE_BANNER' Is Set to 'FALSE' ******************"

set echo on
spool /home/oracle/shell_scr/db_harden/sql_2_2_16_SEC_RETURN_SERVER_RELEASE_BANNER.log


ALTER SYSTEM SET SEC_RETURN_SERVER_RELEASE_BANNER = FALSE SCOPE = SPFILE;

spool off
set echo off

prompt "****************** 2.2.17 Ensure 'SQL92_SECURITY' Is Set to 'FALSE' ******************"

set echo on
spool /home/oracle/shell_scr/db_harden/sql_2_2_17_SQL92_SECURITY.log


ALTER SYSTEM SET SQL92_SECURITY = FALSE SCOPE = SPFILE;

spool off
set echo off

prompt "****************** 2.2.18 Ensure '_TRACE_FILES_PUBLIC' Is Set to 'FALSE' ******************"

set echo on
spool /home/oracle/shell_scr/db_harden/sql_2_2_18_TRACE_FILES_PUBLIC.log


ALTER SYSTEM SET "_trace_files_public" = FALSE SCOPE = SPFILE;

spool off
set echo off

prompt "****************** 2.2.19 Ensure 'RESOURCE_LIMIT' Is Set to 'TRUE' ******************"

set echo on
spool /home/oracle/shell_scr/db_harden/sql_2_2_19_RESOURCE_LIMIT.log


ALTER SYSTEM SET RESOURCE_LIMIT = TRUE SCOPE = SPFILE;

spool off
set echo off

prompt "******************  END OF Module Section 2 ******************"


prompt "****************** 3.1 Ensure 'FAILED_LOGIN_ATTEMPTS' Is Less than or Equal to '5' ******************"

set echo on
spool /home/oracle/shell_scr/db_harden/sql_3_1_FAILED_LOGIN_ATTEMPTS.log


ALTER PROFILE DEFAULT LIMIT FAILED_LOGIN_ATTEMPTS 5;

spool off
set echo off

prompt "****************** 3.2 Ensure 'PASSWORD_LOCK_TIME' Is Greater than or Equal to '1' ******************"

set echo on
spool /home/oracle/shell_scr/db_harden/sql_3_2_PASSWORD_LOCK_TIME.log


ALTER PROFILE DEFAULT LIMIT PASSWORD_LOCK_TIME 1;

spool off
set echo off

prompt "****************** 3.3 Ensure 'PASSWORD_LIFE_TIME' Is Less than or Equal to '90' ******************"

set echo on
spool /home/oracle/shell_scr/db_harden/sql_3_2_PASSWORD_LIFE_TIME.log


ALTER PROFILE DEFAULT LIMIT PASSWORD_LIFE_TIME 90;

spool off
set echo off

prompt "****************** 3.4 Ensure 'PASSWORD_REUSE_MAX' Is Greater than or Equal to '20' ******************"

set echo on
spool /home/oracle/shell_scr/db_harden/sql_3_4_PASSWORD_REUSE_MAX.log


ALTER PROFILE DEFAULT LIMIT PASSWORD_REUSE_MAX 10;

spool off
set echo off

prompt "****************** 3.5 Ensure 'PASSWORD_REUSE_TIME' Is Greater than or Equal to '365' ******************"

set echo on
spool /home/oracle/shell_scr/db_harden/sql_3_5_PASSWORD_REUSE_TIME.log


ALTER PROFILE DEFAULT LIMIT PASSWORD_REUSE_TIME 365;

spool off
set echo off

prompt "****************** 3.6 Ensure 'PASSWORD_GRACE_TIME' Is Greater than or Equal to '5' ******************"

set echo on
spool /home/oracle/shell_scr/db_harden/sql_3_6_PASSWORD_GRACE_TIME.log


ALTER PROFILE DEFAULT LIMIT PASSWORD_GRACE_TIME 5;

spool off
set echo off

prompt "****************** 3.9 Ensure 'SESSIONS_PER_USER' Is Less than or Qual to '10' ******************"

set echo on
spool /home/oracle/shell_scr/db_harden/sql_3_9_SESSIONS_PER_USER.log


ALTER PROFILE DEFAULT LIMIT SESSIONS_PER_USER 10;

spool off
set echo off
prompt "****************** 3.9 Ensure 'PASSWORD_VERIFY_FUNCTION' Is Set for All Profiles ******************"

set echo on
spool /home/oracle/shell_scr/db_harden/sql_3_8_PASSWORD_VERIFY_FUNCTION.log

ALTER PROFILE DEFAULT LIMIT PASSWORD_VERIFY_FUNCTION VERIFY_FUNCTION;

spool off
set echo off

prompt "****************** 3.10 Ensure No Users Are Assigned the 'DEFAULT' Profile ******************"

set echo on
spool /home/oracle/shell_scr/db_harden/sql_3_10_Users_Profile.log


ALTER PROFILE DEFAULT LIMIT SESSIONS_PER_USER 10;

spool off
set echo off


exit;