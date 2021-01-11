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

        printf " YOU WANT USER TO BE MODELLED: Key Y else press Enter:"
        read modlusr

        printf "Provide the tablespace name in specific if any (If none - press enter) :"
        read tbsp


        if [ -z "${tbsp}" ];  ##### Default tablespace condition
        then
                echo ""
                
		if  [ -z "${modlusr}" ];
		then 
			
			printf "Roles to be Granted, EX: ROLE1,ROLE2 (If none - Press Enter): "
                	read grt_role
                	if [ -z "${grt_role}" ]; ################# no role/no model/no tablespace condition
                	then
		        sqlplus -s "sys/${pass}@${dbtns} as sysdba" <<EOF >/dev/null 2>&1
spool $SHELLDIR/create_deftbsp_defrole_$usrnm.log
CREATE USER ${usrnm} IDENTIFIED BY "Temp#123" DEFAULT TABLESPACE USERS PASSWORD EXPIRE ACCOUNT UNLOCK;
grant connect to ${usrnm};
spool off
EOF
                	else    ########If role exists/no model/no tablespace condition
                	sqlplus -s "sys/${pass}@${dbtns} as sysdba" <<EOF >/dev/null 2>&1
spool $SHELLDIR/create_deftbsp_custrole$usrnm.log
CREATE USER ${usrnm} IDENTIFIED BY "Temp#123" DEFAULT TABLESPACE USERS PASSWORD EXPIRE ACCOUNT UNLOCK;
grant connect,${grt_role}  to ${usrnm};
spool off
EOF
                	fi
                	echo "  The Password is : Temp#123"
                	echo "User has to reset their password at the first logon"

		else  ########### No tablespace/Model user exists
sqlplus -s "sys/${pass}@${dbtns} as sysdba" <<EOF >/dev/null 2>&1
spool $SHELLDIR/create_deftbsp_norole${usrnm}.log
CREATE USER ${usrnm} IDENTIFIED BY "Temp#123" DEFAULT TABLESPACE USERS PASSWORD EXPIRE ACCOUNT UNLOCK;
grant connect  to ${usrnm};
spool off
EOF
		val_usrcrt=`grep "ORA-"  $SHELLDIR/create_deftbsp_norole${usrnm}.log`
	
			if [ -z "${val_usrcrt}" ];then
			sh $SHELLDIR/sql_role.sh

			cat $SHELLDIR/user_sql_model.log | awk '{ $1=""; $2=""; print}' | sed -e "s/.*/GRANT & TO $usrnm\;/" | grep -v "GRANT   TO"| sed 's/'PACKAGE'//g' | sed 's/'BODY'//g' | sed 's/'PROCEDURE'//g' |  sed 's/'FUNCTION'//g' |  sed 's/'TRIGGER'//g' |  sed 's/'SYNONYM'//g' > $SHELLDIR/model_grants.sql

		sqlplus -s "sys/${pass}@${dbtns} as sysdba" <<EOF >/dev/null 2>&1
spool model_user_grants_${usrnm}_log.log
set echo on
@$SHELLDIR/model_grants.sql
spool off
EOF
		echo "*************User Creation Successful*************"
		echo "**Grants Successful**"
		echo " Below is the log"
		cat  model_user_grants_${usrnm}_log.log


			else
				echo "Error in User Creation, please find the log below - "
				cat  $SHELLDIR/create_deftbsp_norole${usrnm}.log
			fi
                fi                
        else
                echo ""
                printf "Roles to be Granted, EX: ROLE1,ROLE2 (If none - Press Enter): "
                read grt_role
                if [ -z "${grt_role}" ]; ################# Default role condition
                then
        sqlplus -s "sys/${pass}@${dbtns} as sysdba" <<EOF >/dev/null 2>&1
spool $SHELLDIR/create_deftbsp_defrole_$usrnm.log
CREATE USER ${usrnm} IDENTIFIED BY "Temp#123" DEFAULT TABLESPACE  ${tbsp}  PASSWORD EXPIRE ACCOUNT UNLOCK;
grant connect to ${usrnm};
spool off
EOF
                else    ########If role exists and Default tablespace condition
                sqlplus -s "sys/${pass}@${dbtns} as sysdba" <<EOF >/dev/null 2>&1
spool $SHELLDIR/create_deftbsp_$usrnm.log
CREATE USER ${usrnm} IDENTIFIED BY "Temp#123" DEFAULT TABLESPACE ${tbsp} PASSWORD EXPIRE ACCOUNT UNLOCK;
grant connect,${grt_role}  to ${usrnm};
spool off
EOF

                fi
                echo "  The Password is : Temp#123"
                echo "User has to reset their password at the first logon"

		fi
else
        echo "User already exists"
        echo $user_check
fi

}


user_create

