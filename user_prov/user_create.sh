#!/bin/bash
SHELLDIR=/home/oracle/shell_scr/user_prov
mkdir  -p ${SHELLDIR}
grep '=$' $ORACLE_HOME/network/admin/tnsnames.ora | grep ^[a-Z] | tr "=" "\t" | grep -Evi   'st|dr|dg'   > $SHELLDIR/INPFILE.out
#pass=`cat /home/oracle/shell_scr/.pass`



clear
echo "***************************************************************************************"
echo "*                   DATABASE USER CREATION AUTOMATIONION SCRIPT                         *"
echo "*             ! This Script is to create new user in the Oracle Database  !           *"
echo "*                     Please proceed the information's below                          *"
echo "*            PLEASE PAY ATTENTION WHILE YOU INPUT VALUES TO THIS SCRIPT                 *"
echo "***************************************************************************************"


echo " Below are the list of tns entries : "
cat $SHELLDIR/INPFILE.out


printf "Select the DB TNS for creating the user : "
read dbtns


printf "Enter DBA Password: "
read pass

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

model_user()
{
 if  [ -z "${modlusr}" ];
                then

                        printf "Roles to be Granted, EX: ROLE1,ROLE2 (If none - Press Enter): "
                        read grt_role
                        if [ -z "${grt_role}" ]; ################# no role/no model/no tablespace condition
                        then
                        sqlplus -s "sys/${pass}@${dbtns} as sysdba" <<EOF >/dev/null 2>&1
spool $SHELLDIR/create_deftbsp_defrole_$usrnm.log
CREATE USER ${usrnm} IDENTIFIED BY "Temp#123" DEFAULT TABLESPACE $tbsp PASSWORD EXPIRE ACCOUNT UNLOCK;
grant connect to ${usrnm};
spool off
EOF
                                                if [ -f "/home/oracle/shell_scr/user_prov/create_deftbsp_defrole_$usrnm.log" ];then
                                                 val_usrcrt=`grep "ORA-"  $SHELLDIR/create_deftbsp_defrole_$usrnm.log`

                                                                if [ -z "${val_usrcrt}" ];then
                                                                        echo "*************User creation is Successful*************"
                                                                        echo "  The Password is : Temp#123"
                                                                        echo "User has to reset their password at the first logon"
                                                                else
                                                                        echo""
                                                                        echo ""
                                                                        echo " Attention!! USER DEPLOYMENT IS NOT SUCCESSFUL, check the inputs provided"
                                                                        echo "If INPUTS are correct, send the below screenshot to DB team"
                                                                        echo ""
                                                                        cat $SHELLDIR/create_deftbsp_defrole_$usrnm.log
                                                                fi
                                                else

                                                                     echo ""
                                                                echo "Attention!! User creation not successful, give correct inputs"
                                                                echo ""


                                                                fi


                        else    ########If role exists/no model/no tablespace conditioni
                        echo "I am here"
                        sqlplus -s "sys/${pass}@${dbtns} as sysdba" <<EOF >/dev/null 2>&1
spool $SHELLDIR/create_deftbsp_custrole_${usrnm}.log

SELECT USERNAEM,ACCOUNT_STATUS FROM DBA_USERS WHERE USERNAME='${usrnm}';

CREATE USER ${usrnm} IDENTIFIED BY "Temp#123" DEFAULT TABLESPACE $tbsp PASSWORD EXPIRE ACCOUNT UNLOCK;
grant connect,${grt_role}  to ${usrnm};
spool off
EOF

                                                if [ -f $SHELLDIR/create_deftbsp_custrole$usrnm.log ]; then

                                                 val_usrcrt=`grep "ORA-"  $SHELLDIR/create_deftbsp_custrole$usrnm.log`

                                                                if [ -z "${val_usrcrt}" ];then
                                                                        echo "*************User creation is Successful*************"
                                                                        echo "  The Password is : Temp#123"
                                                                        echo "User has to reset their password at the first logon"
                                                                else
                                                                        echo ""
                                                                        echo ""
                                                                        echo " Attention!! USER DEPLOYMENT IS NOT SUCCESSFUL, check the inputs provided"
                                                                        echo ""
                                                                        echo "If INPUTS are correct, send the below screenshot to DB team"
                                                                        cat $SHELLDIR/create_deftbsp_custrole$usrnm.log
                                                        fi

                                                        else
                                                                echo ""
                                                                echo "Attention!! User creation not successful, give correct inputs"
                                                                echo ""
                                                        fi

                                                fi

                else  ########### No tablespace/Model user exists
sqlplus -s "sys/${pass}@${dbtns} as sysdba" <<EOF >/dev/null 2>&1
spool $SHELLDIR/create_deftbsp_norole${usrnm}.log
CREATE USER ${usrnm} IDENTIFIED BY "Temp#123" DEFAULT TABLESPACE $tbsp PASSWORD EXPIRE ACCOUNT UNLOCK;
grant connect  to ${usrnm};
spool off
EOF
                val_usrcrt=`grep "ORA-"  $SHELLDIR/create_deftbsp_norole${usrnm}.log`

                        if [ -z "${val_usrcrt}" ];then
                        sh $SHELLDIR/sql_role.sh

                        cat $SHELLDIR/user_sql_model.log | awk '{ $1=""; $2=""; print}' | sed -e "s/.*/GRANT & TO $usrnm\;/" | grep -v "GRANT   TO"| grep -v "selected." |   sed 's/'"ON PACKAGE BODY"'/'"ON"'/g'  |  sed 's/'"ON PACKAGE"'/'"ON"'/g'| sed 's/'"ON PROCEDURE"'/'"ON"'/g' |  sed 's/'"ON FUNCTION"'/'"ON"'/g' |  sed 's/'"ON TRIGGER"'/'"ON"'/g' |  sed 's/'"ON SYNONYM"'/'"ON"'/g' |  sed 's/'"ON VIEW"'/'"ON"'/g'|  sed 's/'"ON CONSUMER GROUP"'/'"ON"'/g' |  sed 's/'"ON TABLE"'/'"ON"'/g'  > $SHELLDIR/model_grants.sql

                sqlplus -s "sys/${pass}@${dbtns} as sysdba" <<EOF >/dev/null 2>&1
spool model_user_grants_${usrnm}_log.log
set echo on
@$SHELLDIR/model_grants.sql
spool off
EOF
                  echo "*************User creation is Successful*************"
                                                                        echo "  The Password is : Temp#123"
                                                                        echo "User has to reset their password at the first logon"

                echo ""
                echo ""
                echo "**VALIDATE THE GRANTS**"
                echo " Below is the log - If any errors/manual corrections send it to oracle@cloud4c.com"
                cat  model_user_grants_${usrnm}_log.log


                        else
                                echo "Error in User Creation, please find the log below - "
                                cat  $SHELLDIR/create_deftbsp_norole${usrnm}.log
                        fi
                fi
}
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
               tbsp="USERS"
               model_user
        else
               echo ""
                 model_user
        fi
else
        echo "User already exists"
        echo $user_check
fi

}


user_create
