#!/bin/bash
SHELLDIR=/home/oracle/shell_scr/user_prov
mkdir  -p ${SHELLDIR}
grep '=$' $ORACLE_HOME/network/admin/tnsnames.ora | grep ^[A-Z] | tr "=" "\t" | grep -Evi   'st|dr|dg' | head -1 > $SHELLDIR/INPFILE.out
pass=`cat /home/oracle/shell_scr/.pass`



clear
echo "***************************************************************************************"
echo "*                   DATABASE USER CREATION AUTOMATIONION SCRIPT                         *"
echo "*             ! This Script is to create new user in the Oracle Database  !           *"
echo "*                     Please proceed the information's below                            *"
echo "***************************************************************************************"


echo " Below are the list of tns entries : "
cat $SHELLDIR/INPFILE.out


printf "Select the DB TNS for creating the user : "
read dbtns

printf "Provide the username to be created in DB (UPPER CASE ONLY): "
read usrnm



sqlplus -s "sys/${pass}@${dbtns} as sysdba" <<EOF > /dev/null 2>&1

set pages 0
set head off
set lines 200
col username for a40

spool $SHELLDIR/user_info.log
select username from dba_users where username='${usrnm}';

spool off
EOF


user_check=`cat $SHELLDIR/user_info.log | head -2 | tail -1`


check_str="no rows selected"


user_create()
{
if [ "$user_check" == "no rows selected" ];
then

       # printf "Provide the username to be modelled (If none - press enter ) :"
       # read modlusr

        printf "Provide the tablespace name in specific if any (If none - press enter) :"
        read tbsp
		
		
        if [ -z "${tbsp}" ];  ##### Default tablespace condition
        then
		echo ""
		printf "Roles to be Granted, EX: ROLE1,ROLE2 (If none - Press Enter): "
		read grt_role
		if [ -z "${grt_role}" ]; ################# Default role condition
		then
        sqlplus -s "sys/${pass}@${dbtns} as sysdba" <<EOF >/dev/null 2>&1
spool $SHELLDIR/create_deftbsp_defrole_$usrnm.log
CREATE USER ${usrnm} IDENTIFIED BY "Temp#123" DEFAULT TABLESPACE USERS PASSWORD EXPIRE ACCOUNT UNLOCK;
grant connect to ${usrnm};
spool off
EOF
		else    ########If role exists and Default tablespace condition
		sqlplus -s "sys/${pass}@${dbtns} as sysdba" <<EOF >/dev/null 2>&1
spool $SHELLDIR/create_deftbsp_$usrnm.log
CREATE USER ${usrnm} IDENTIFIED BY "Temp#123" DEFAULT TABLESPACE USERS PASSWORD EXPIRE ACCOUNT UNLOCK;
grant ${grt_role}  to ${usrnm};
spool off
EOF
		
		echo "  The Password is : Temp#123"
		echo "User has to reset their password at the first logon"
	
	else 
		echo ""
                printf "Roles to be Granted, EX: ROLE1,ROLE2 (If none - Press Enter): "
                read grt_role
                if [ -z "${grt_role}" ]; ################# Default role condition
                then
        sqlplus -s "sys/${pass}@${dbtns} as sysdba" <<EOF >/dev/null 2>&1
spool $SHELLDIR/create_deftbsp_defrole_$usrnm.log
CREATE USER ${usrnm} IDENTIFIED BY "Temp#123" DEFAULT ${tbsp} USERS PASSWORD EXPIRE ACCOUNT UNLOCK;
grant connect to ${usrnm};
spool off
EOF
                else    ########If role exists and Default tablespace condition
                sqlplus -s "sys/${pass}@${dbtns} as sysdba" <<EOF >/dev/null 2>&1
spool $SHELLDIR/create_deftbsp_$usrnm.log
CREATE USER ${usrnm} IDENTIFIED BY "Temp#123" DEFAULT TABLESPACE ${tbsp} PASSWORD EXPIRE ACCOUNT UNLOCK;
grant ${grt_role}  to ${usrnm};
spool off
EOF
	        

		echo "  The Password is : Temp#123"
		echo "User has to reset their password at the first logon"
        	fi

else
        echo "User already exists"
        echo $user_check
fi

}


user_create



