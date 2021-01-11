
#!/bin/bash
clear
echo "****************************************************************"
echo "*                                                               *"
echo "*             AUTOMATED     DB Installation                     *"
echo "*                                                               *"
echo "****************************************************************"

echo ""

echo " Please select "Y" Only if below requirements are met: "
echo " 1 - Running this script using root user ?"
echo " 2 - Internet enabled and repo configured on this server ?"
echo " 3 - Downloaded the software already ?"
echo " 4 - Make sure there are no other files except DB Zip file  ?"
echo " 5 - Ensure the Disk and Compute requirements are met ?"
echo ""
printf " ENTER [Y] if all the requirements are met, else Enter [N], Enter [Y]/[N]: "

read down_soft
  orahost=`hostname`



if [ $down_soft = 'Y' ];
then

printf "Enter the exact location of Oracle DB zipfile - "
read down_loc




echo ""
echo "Thanks for Downloading the software, please keep the software in an accesible location by Oracle user"
echo "Also have the location with you as we will require it while execution"
sleep 5

SHELLDIR=/home/oracle/shell_scr/db_auto
DIR11g=${SHELLDIR}/11g_param
DIR12c=${SHELLDIR}/12c_param
DIR18c=${SHELLDIR}/18c_param
DIR19c=${SHELLDIR}/19c_param
pre_req_19c(){
                echo ""
                echo "Proceeding with YUM installation of 19c rpms"
                echo ""
                sh ${DIR19c}/yum_cmd.sh >> ${DIR19c}/yum.log
                echo ""
                        if [ -f ${DIR19c}/yum.log ];
                        then
                        echo ""
                        echo "Below is the YUM output"
                        cat ${DIR19c}/yum.log
                        rm ${DIR19c}/yum.log
                        echo ""
                        sleep 2
                        else

                        echo "YUM execution was not successful, cannot proceed further!"
                        exit

                        fi


                echo ""
                echo "**********SYSCTL CONF Parameters Updated**********"
                echo ""
                cat ${DIR19c}/sysctl_param.par > /etc/sysctl.d/98-oracle.conf
                /sbin/sysctl -p /etc/sysctl.d/98-oracle.conf


                echo ""
                echo ""
                sleep 3
                echo "**********SECURITY LIMITS CONF Parameters Settings**********"
                echo ""
                cat ${DIR19c}/security_limits.par > /etc/security/limits.d/oracle-database-server-19c-preinstall.conf
                cat /etc/security/limits.d/oracle-database-server-19c-preinstall.conf
                echo ""
                echo ""
                sleep 3

}
pre_req_18c(){
                echo ""
                echo "Proceeding with YUM installation of 18c rpms"
                echo ""
                sh ${DIR18c}/yum_cmd.sh >> ${DIR18c}/yum.log
                echo ""
                        if [ -f ${DIR18c}/yum.log ];
                        then
                        echo ""
                        echo "Below is the YUM output"
                        cat ${DIR18c}/yum.log
                        rm ${DIR18c}/yum.log
                        echo ""
                        sleep 2
                        else

                        echo "YUM execution was not successful, cannot proceed further!"
                        exit

                        fi


                echo ""
                echo "**********SYSCTL CONF Parameters Updated**********"
                echo ""
                cat ${DIR18c}/sysctl_param.par > /etc/sysctl.d/98-oracle.conf
                /sbin/sysctl -p /etc/sysctl.d/98-oracle.conf


                echo ""
                echo ""
                sleep 3
                echo "**********SECURITY LIMITS CONF Parameters Settings**********"
                echo ""
                cat ${DIR18c}/security_limits.par > /etc/security/limits.d/oracle-database-server-18c-preinstall.conf
                cat /etc/security/limits.d/oracle-database-server-18c-preinstall.conf
                echo ""
                echo ""
                sleep 3

}

pre_req_12c(){
                echo ""
                echo "Proceeding with YUM installation of 12c rpms"
                echo ""
                sh ${DIR12c}/yum_cmd.sh >> ${DIR12c}/yum.log
                echo ""
                        if [ -f ${DIR12c}/yum.log ];
                        then
                        echo ""
                        echo "Below is the YUM output"
                        cat ${DIR12c}/yum.log
                        rm ${DIR12c}/yum.log
                        echo ""
                        sleep 2
                        else

                        echo "YUM execution was not successful, cannot proceed further!"
                        exit

                        fi


                echo ""
                echo "**********SYSCTL CONF Parameters Updated**********"
                echo ""
                cat ${DIR12c}/sysctl_param.par > /etc/sysctl.d/98-oracle.conf
                /sbin/sysctl -p /etc/sysctl.d/98-oracle.conf


                echo ""
                echo ""
                sleep 3
                echo "**********SECURITY LIMITS CONF Parameters Settings**********"
                echo ""
                cat ${DIR12c}/security_limits.par > /etc/security/limits.d/oracle-database-server-12cR2-preinstall.conf
                cat /etc/security/limits.d/oracle-database-server-12cR2-preinstall.conf
                echo ""
                echo ""
                sleep 3

}


pre_req_11g(){
                echo ""
                echo "Proceeding with YUM installation of 11g rpms"
                echo ""
                sh ${DIR11g}/yum_cmd.sh >> ${DIR11g}/yum.log
                echo ""
                        if [ -f ${DIR11g}/yum.log ];
                        then
                        echo ""
                        echo "Below is the YUM output"
                        cat ${DIR11g}/yum.log
                        rm ${DIR11g}/yum.log
                        echo ""
                        sleep 2
                        else

                        echo "YUM execution was not successful, cannot proceed further!"
                        exit

                        fi


                echo ""
                echo "**********SYSCTL CONF Parameters Updated**********"
                echo ""
                cat ${DIR11g}/sysctl_param.par > /etc/sysctl.d/98-oracle.conf
                /sbin/sysctl -p /etc/sysctl.d/98-oracle.conf


                echo ""
                echo ""
                sleep 3
                echo "**********SECURITY LIMITS CONF Parameters Settings**********"
                echo ""
                cat ${DIR11g}/security_limits.par > /etc/security/limits.d/oracle-database-server-11gR2-preinstall.conf
                cat /etc/security/limits.d/oracle-database-server-11gR2-preinstall.conf
                echo ""
                echo ""
                sleep 3

}


user_group_add(){
                echo "**********Group Additions**********"
                echo ""
				INSTGROUP=oinstall
				DBAGROUP=dba
				OPERGROUP=oper 
				ORAOWNER=oracle
					getent group ${INSTGROUP}
					if [ "$?" -ne "0" ]; then
					/usr/sbin/groupadd ${INSTGROUP} 2> /dev/null || :
					fi
				getent group ${DBAGROUP}
					if [ "$?" -ne "0" ]; then
					/usr/sbin/groupadd ${DBAGROUP} 2> /dev/null || :
					fi
				getent group ${OPERGROUP}
					if [ "$?" -ne "0" ]; then
					/usr/sbin/groupadd ${OPERGROUP} 2> /dev/null || :
					fi	
					
					
                echo ""
                echo "**********User Addition**********"
                echo ""
                getent passwd ${ORAOWNER}
				if [ "$?" -ne "0" ]; then
				/usr/sbin/useradd -g ${ORAINSTGROUP} -G ${DBAGROUP},${OPERGROUP}
				fi
               

                echo "**********Role of OS User - Oracle**********"
                id oracle > ${SHELLDIR}/oracle_osuser.log
                cat ${SHELLDIR}/oracle_osuser.log
                echo ""
				cnt=`grep oracle ${SHELLDIR}/oracle_osuser.log | wc -l`
				if [ ${cnt} = 1 ];
				then
					echo "User Check - Perfect"
					else
					echo "User check - Not in good shape. Exiting."
					exit;
				fi
				
}

db_version_manual_loc() {
                                                                        echo ""

                                                                                                                                                printf "ORAINVENTORY LOCATION (default loc - /u01/app/oraInventory) : "
                                                                        read orainv
                                                                        if [ -z $orainv ];
                                                                        then
                                                                                orainv="/u01/app/oraInventory"
                                                                                echo " Your Oracle Inventory is set to default value -  ${orainv}"
										mkdir -p ${orainv}
                                                                        else
                                                                                mkdir -p ${orainv}
										echo "ORACLE Inventory value is set to ${orainv}"
										
                                                                        echo ""
                                                                        fi


                                                                        printf "ORACLE_BASE LOCATION (default loc - /u01/app/oracle) : "
                                                                        read orabase
                                                                        if [ -z $orabase ];
                                                                        then
                                                                                orabase="/u01/app/oracle"
                                                                                echo " Your Oracle base is set to default value -  ${orabase}"
										mkdir -p ${orabase}
										chown -R oracle:oinstall ${orabase}
                                                                        else
                                                                                echo "ORACLE BASE value is set to ${orabase}"
										mkdir -p ${orabase}
										chown -R oracle:oinstall ${orabase}


                                                                        echo ""
                                                                        fi
                                                                        printf "ORACLE_HOME LOCATION (default loc - /u01/app/oracle/product/${db_ver}/db_1) "
                                                                        read orahome
                                                                        echo ""
                                                                            if [ -z $orahome ];
                                                                        then
                                                                                orahome="/u01/app/oracle/product/${db_ver}/db_1"
                                                                                echo " Your Oracle base is set to default value -  ${orahome}"
                                                                                mkdir -p  ${orahome}
                                                                                chown -R oracle:oinstall ${orahome}
                                                                                echo "Directory has been created and ownership is changed"
                                                                        else
                                                                                echo "ORACLE Home value is set to ${orahome}"
                                                                                mkdir -p  ${orahome}
                                                                                chown -R oracle:oinstall ${orahome}
                                                                                echo "Directory has been created and ownership is changed"

                                                                        echo ""
                                                                        fi

                                                                        echo ""
                                                                        printf "Enter the Installer - [SE]/[EE]: "
                                                                        read orainstaller
                                                                             if [ -z $orainstaller ];
                                                                        then
                                                                                orainstaller="EE"
                                                                                echo " Your Oracle Edition is set to default value -  ${orainstaller}"
                                                                        else
                                                                                echo "ORACLE Edition  value is set to ${orainstaller}"

                                                                        echo ""
                                                                        fi


                                                                        echo "Installing the Mandatory pre-requisites...!"
                                                                        echo ""
                                                                        echo "Pushing the status on Screen.."
                                                                        echo ""
                                                                        user_group_add  #Function Call of User_group
                                                                        pre_req_${ver}     #Function Call of Pre-Req
                                                                        bashprof_set
                                                                        #ora_unzip
																		latest_ora_unzip
}

db_auto_loc () {
 echo "You have Chose Option - 1: ${db_ver}"
                                                                                                                                                 orainv="/u01/app/oraInventory"
                                                                                orabase="/u01/app/oracle"
                                                                                echo "ORACLE BASE value is set to - ${orabase}"
                                                                                orahome="/u01/app/oracle/product/${db_ver}/db_1"
                                                                                echo " Your Oracle base is set to - ${orahome}"
                                                                                mkdir -p ${orabase}
										mkdir -p ${orainv}
										mkdir -p  ${orahome}
                                                                                chown -R oracle:oinstall ${orabase}
									        chown -R oracle:oinstall ${orahome}		
                                                                                echo "Directory has been created and ownership is changed"

                                                                         echo ""
                                                                         orainstaller="EE"
                                                                         echo " Your Oracle Edition is set to default value -  ${orainstaller}"

                                                                        echo "Installing the Mandatory pre-requisites...!"
                                                                        echo ""
                                                                        echo "Pushing the status on Screen.."
                                                                        echo ""
                                                                        user_group_add  #Function Call of User_group
                                                                        pre_req_${ver}     #Function Call of Pre-Req
                                                                        bashprof_set
                                                                        latest_ora_unzip
}

bashprof_set(){
                                echo "**********Bash Settings**********"
                                cp /home/oracle/.bash_profile /home/oracle/.bash_profile_$(date '+%d%m%Y')
                                #echo "ORACLE_BASE=${orabase}" > $SHELLDIR/setenv.sh
                                #echo "ORACLE_HOME=${orahome}" >> $SHELLDIR/setenv.sh
                                #echo "\$PATH=\$ORACLE_HOME/bin:\$PATH" >> $SHELLDIR/setenv.sh
                                 echo "/home/oracle/shell_scr/db_auto/setenv.sh"  >> /home/oracle/.bash_profile
                                chown -R oracle:oinstall /home/oracle/.bash_profile
                                #chown -R oracle:oinstall /home/oracle/shell_scr/db_auto/setenv.sh
                               # tail -20 /home/oracle/.bash_profile
}

ora_unzip (){
                                echo "Actual Installation using oracle user begins here..."

                                                                echo "Download location is ${down_loc}"
                                rm -rf ${down_loc}/database
                                unzip -q  ${down_loc}/*zip  -d ${down_loc}
                                echo ""
                               echo ""**********Unzip completed  "**********"

                               chown -R oracle:oinstall ${down_loc}
                               sleep 2
                        echo ""
                        echo ""
                        echo "Working on runinstaller"

                                su - oracle -c  "${down_loc}/database/runInstaller -silent  -ignorePrereq -waitforcompletion   -responseFile ${down_loc}/database/response/db_install.rsp ORACLE_HOSTNAME=${orahost} UNIX_GROUP_NAME=oinstall INVENTORY_LOCATION=${orainv} SELECTED_LANGUAGES=en,en_GB ORACLE_HOME=$orahome ORACLE_BASE=${orabase} oracle.install.db.InstallEdition=${orainstaller}  oracle.install.db.OSDBA_GROUP=dba oracle.install.db.OSBACKUPDBA_GROUP=dba    oracle.install.db.OSDGDBA_GROUP=dba  oracle.install.db.OSKMDBA_GROUP=dba      oracle.install.db.OSRACDBA_GROUP=dba    SECURITY_UPDATES_VIA_MYORACLESUPPORT=false  DECLINE_SECURITY_UPDATES=true oracle.install.option=INSTALL_DB_SWONLY " | tee ${SHELLDIR}/installer.log

                                        root_scr_ex=`grep root.sh  ${SHELLDIR}/installer.log  | awk {'print $2'}`

                                                sh $root_scr_ex

 echo "********************* Script Execution Complete *******z****************************************"


}

latest_ora_unzip (){
                                echo "Actual Installation using oracle user begins here..."

                                                                echo "Download location is ${down_loc}"
                                rm -rf ${down_loc}/database
                                unzip -q  ${down_loc}/*zip  -d ${orahome}
                                echo ""
                               echo ""**********Unzip completed  "**********"

				chown -R oracle:oinstall ${orahome}
                               sleep 2
                        echo ""
                        echo ""
                        echo "Working on runinstaller"
						run=`find ${orahome} -name "runInstaller" | grep -v oui`
						echo {$run}
						resp_file=`find ${orahome} -name "db_install.rsp" | grep -v inv`
						echo "response file ${resp_file}"

                                su - oracle -c  "${run}  -silent  -ignorePrereq -waitforcompletion   -responseFile ${resp_file}  ORACLE_HOSTNAME=${orahost} UNIX_GROUP_NAME=oinstall INVENTORY_LOCATION=${orainv} SELECTED_LANGUAGES=en,en_GB ORACLE_HOME=$orahome ORACLE_BASE=${orabase} oracle.install.db.InstallEdition=${orainstaller}  oracle.install.db.OSDBA_GROUP=dba oracle.install.db.OSBACKUPDBA_GROUP=dba    oracle.install.db.OSDGDBA_GROUP=dba  oracle.install.db.OSKMDBA_GROUP=dba      oracle.install.db.OSRACDBA_GROUP=dba    SECURITY_UPDATES_VIA_MYORACLESUPPORT=false  DECLINE_SECURITY_UPDATES=true oracle.install.option=INSTALL_DB_SWONLY " | tee ${SHELLDIR}/installer.log
					inst_scr_ex=`grep orainstRoot.sh ${SHELLDIR}/installer.log  | awk {'print $2'}`
					root_scr_ex=`grep root.sh  ${SHELLDIR}/installer.log  | awk {'print $2'} | head -1`
					echo "Inventory script - ${inst_scr_ex}"
					echo "root Script - $root_scr_ex"
										if [ -z ${inst_scr_ex} ]; 
										then
										echo "OraInst script not found"
										else	
											sh ${inst_scr_ex}
										fi
										
										if [ -z ${root_scr_ex} ]; 
										then
										echo "Installation not perfect. Root script not found, troubleshoot installation logs in /tmp and start installation manually"
										else	
											sh ${root_scr_ex}
											 echo "********************* Script Execution Complete ***************************"

										fi
										
										
										
                                           



}


printf  "Enter the Version you wanted to install [11g] | [12c] | [18c] | [19c] - "
read dbversion
if [ $dbversion = "11g" ] || [ $dbversion = "11G" ];
then 
	
	ver="11g"
elif [ $dbversion = "12c" ] || [ $dbversion = "12C" ]; then
	ver="12c"
elif [ $dbversion = "18c" ] || [ $dbversion = "18C" ];	then
	ver="18c"
else 
	ver="19c"
	
fi

case $dbversion in

        "11g" | "11G") echo "Select the subversion you want to install"
                                                echo " [1] DB - 11.1.0"
                                                echo " [2] DB - 11.2.0"
												
                                                printf "Enter Your Choice [1] or [2]:"
                                                read choice
                                                                                                printf "Do you want to go for default installation (Recommended/Default - Y), Your choice [Y]/[N]:"
                                                                                                read inst_type

                                                                                                if [ $inst_type = 'N' ];
                                                                                                then
                                                case $choice in
                                                         "1") echo ""
                                                                                                                                        db_ver="11.1.0"
                                                                        echo "You have Chose Option - 1: ${db_ver}"
                                                                        echo "Going forward if you hit enter with no values will be treated as default setting"
                                                                        echo ""
                                                                       db_version_manual_loc
                                                                ;;
                                                        "2") echo ""
                                                                                                                                                db_ver="11.2.0"
                                                                        echo "You have Chose Option - 1: ${db_ver}"
                                                                        echo "Going forward if you hit enter with no values will be treated as default setting"
                                                                        echo ""
                                                                       db_version_manual_loc

                                                                                                                                                echo ""

                                                                ;;
                                                                esac




                                                                                else

                                                                                                      case $choice in
                                                         "1") echo ""
                                                                       db_ver="11.1.0"

                                                                                db_auto_loc

                                                                ;;
                                                        "2") echo ""

                                                                                                                                             db_ver="11.2.0"

                                                                                db_auto_loc
                                                                                                                                        ;;

                                                                esac
                                                        fi
                ;;
        "12c" | "12C" ) echo "Select the subversion you want to install"
                                                echo " [1] DB - 12.1.0"
                                                echo " [2] DB - 12.2.0"
                                                printf "Enter Your Choice [1] or [2]:"
                                                read choice
                                                                                                printf "Do you want to go for default installation (Recommended/Default - Y), Your choice [Y]/[N]:"
                                                                                                read inst_type

                                                                                                if [ $inst_type = 'N' ];
                                                                                                then
                                                case $choice in
                                                         "1") echo ""
                                                                                                                                        db_ver="12.1.0"
                                                                        echo "You have Chose Option - 1: ${db_ver}"
                                                                        echo "Going forward if you hit enter with no values will be treated as default setting"
                                                                        echo ""
                                                                       db_version_manual_loc
                                                                ;;
                                                        "2") echo ""
                                                                                                                                                db_ver="12.2.0"
                                                                        echo "You have Chose Option - 1: ${db_ver}"
                                                                        echo "Going forward if you hit enter with no values will be treated as default setting"
                                                                        echo ""
                                                                       db_version_manual_loc

                                                                                                                                                echo ""

                                                                ;;
                                                                esac




                                                                                else

                                                                                                      case $choice in
                                                         "1") echo ""
                                                                       db_ver="12.1.0"

                                                                                db_auto_loc

                                                                ;;
                                                        "2") echo ""

                                                                                                                                                db_ver="12.2.0"

                                                                                db_auto_loc
                                                                                                                                        ;;

                                                                esac
                                                        fi
                ;;
	
	
			        "18c" | "18c" ) echo "Select the subversion you want to install"
                                                echo " [1] DB - 18.0.0"
												echo " [2] DB - 18.3.0"
                                                printf "Enter Your Choice [1] or [2]:"
                                                read choice
                                                                                                printf "Do you want to go for default installation (Recommended/Default - Y), Your choice [Y]/[N]:"
                                                                                                read inst_type

                                                                                                if [ $inst_type = 'N' ];
                                                                                                then
                                                case $choice in
                                                         "1") echo ""
                                                                                                                                        db_ver="18.0.0"
                                                                        echo "You have Chose Option - 1: ${db_ver}"
                                                                        echo "Going forward if you hit enter with no values will be treated as default setting"
                                                                        echo ""
                                                                       db_version_manual_loc
                                                                ;;
                                                        "2") echo ""
                                                                                                                                                db_ver="18.3.0"
                                                                        echo "You have Chose Option - 1: ${db_ver}"
                                                                        echo "Going forward if you hit enter with no values will be treated as default setting"
                                                                        echo ""
                                                                       db_version_manual_loc

                                                                                                                                                echo ""

                                                                ;;
                                                                esac




                                                                                else

                                                                                                      case $choice in
                                                         "1") echo ""
                                                                       db_ver="18.0.0"

                                                                                db_auto_loc

                                                                ;;
                                                        "2") echo ""

                                                                                                                                                db_ver="18.3.0"

                                                                                db_auto_loc
                                                                                                                                        ;;

                                                                esac
                                                        fi
                ;;
	
		
			        "19c" | "19c" ) echo "Select the subversion you want to install"
                                                echo " [1] DB - 19.0.0"
												echo " [2] DB - 19.3.0"
                                                printf "Enter Your Choice [1] or [2]:"
                                                read choice
                                                                                                printf "Do you want to go for default installation (Recommended/Default - Y), Your choice [Y]/[N]:"
                                                                                                read inst_type

                                                                                                if [ $inst_type = 'N' ];
                                                                                                then
                                                case $choice in
                                                         "1") echo ""
                                                                                                                                        db_ver="19.0.0"
                                                                        echo "You have Chose Option - 1: ${db_ver}"
                                                                        echo "Going forward if you hit enter with no values will be treated as default setting"
                                                                        echo ""
                                                                       db_version_manual_loc
                                                                ;;
                                                        "2") echo ""
                                                                                                                                                db_ver="19.3.0"
                                                                        echo "You have Chose Option - 1: ${db_ver}"
                                                                        echo "Going forward if you hit enter with no values will be treated as default setting"
                                                                        echo ""
                                                                       db_version_manual_loc

                                                                                                                                                echo ""

                                                                ;;
                                                                esac




                                                                                else

                                                                                                      case $choice in
                                                         "1") echo ""
                                                                       db_ver="19.0.0"

                                                                                db_auto_loc

                                                                ;;
                                                        "2") echo ""

                                                                                                                                                db_ver="19.3.0"

                                                                                db_auto_loc
                                                                                                                                        ;;

                                                                esac
                                                        fi
                ;;
	
	
	
	
        *)
                echo ""
                echo "Invalid Choice... Try again!!"
                ;;
esac




else
echo ""
echo ""
echo "Attention!!!!!!!"
echo "Work on the requirements and comeback to the script only once they are met else you may face abnormalities while Installation"
echo ""

sleep 4

echo "***********Thank you***********"


fi

