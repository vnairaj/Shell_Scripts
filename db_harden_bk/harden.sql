

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


spool /home/oracle/shell_scr/db_harden/sql_2_2_5_O7_DICT.log
prompt "****************** 2.2.5 Ensure 'O7_DICTIONARY_ACCESSIBILITY' IS set to FALSE ******************"
set echo on
ALTER SYSTEM SET O7_DICTIONARY_ACCESSIBILITY=FALSE SCOPE = SPFILE;


spool off
set echo off






exit;
