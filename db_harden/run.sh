#!/bin/bash
SHELLDIR=/home/oracle/shell_scr/db_harden
FINALDIR=${SHELLDIR}/OPDIR
HARDENDIR=${FINALDIR}/HRDSQLDIR
REPSQLDIR=${SHELLDIR}/rep_sqls
mkdir  -p ${SHELLDIR}
mkdir  -p ${FINALDIR}
mkdir  -p ${HARDENDIR}
cat /etc/oratab | grep -v + | tail -1 | tr ":"  "\n" | head -1 > ${SHELLDIR}/DBNAME.out
cat /etc/oratab | grep -v + | tail -1 | tr ":"  "\n" | head -2 | tail -1  > ${SHELLDIR}/OHOME.out

rm -rf ${FINALDIR}/*.log

DBNAME=`cat ${SHELLDIR}/DBNAME.out`
OHOME=`cat ${SHELLDIR}/OHOME.out`

clear
echo "***************************************************************************************"
echo "*                   DATABASE HARDENING AUTOMATIONION SCRIPT                         *"
echo "*             ! This Script is to harden params in the Oracle Database as per CSI  !           *"
echo "*                     Please proceed the information's below                          *"
echo "*            No Intervention required                                             *"
echo "***************************************************************************************"

REP_Fn_1_patch_artifact(){
echo "****************************************************************************************" > ${FINALDIR}/1_patch_artifact.log
echo ""
echo ""  >> ${FINALDIR}/1_patch_artifact.log

echo "  1. Patching Information "  >> ${FINALDIR}/1_patch_artifact.log

echo ""  >> ${FINALDIR}/1_patch_artifact.log
echo ""  >> ${FINALDIR}/1_patch_artifact.log

${OHOME}/OPatch/opatch lsinventory | grep -A 34 "Local Machine Information"  >> ${FINALDIR}/1_patch_artifact.log

patch_appl=`${OHOME}/OPatch/opatch lsinventory | grep applied | head -1`

patch_in_sec=`echo ${patch_appl} | cut -d " " -f7,8,9`

curr_sec=`date +%s`
patch_in_sec=`date -d "$dat" +%s`

echo "" >> ${FINALDIR}/1_patch_artifact.log
echo >> ${FINALDIR}/1_patch_artifact.log

 diff_var=`expr ${curr_sec} - ${patch_in_sec}`

                if [ ${diff_var} -gt 10520000  ];
                then
                echo " 1. Patching Information - NOT AS PER CIS STANDARDS.. Need Attention!! "  > ${FINALDIR}/CIS_Failure.log
                                echo " 1. Patching Information - NOT AS PER CIS STANDARDS.. Need Attention!! "  >> ${FINALDIR}/1_patch_artifact.log
                else
                echo " 1. Patching Information - AS PER CIS STANDARDS." > ${FINALDIR}/CIS_Success.log
                                echo " 1. Patching Information - AS PER CIS STANDARDS"  >> ${FINALDIR}/1_patch_artifact.log
                fi

echo ""  >> ${FINALDIR}/1_patch_artifact.log

echo ""

echo ""

echo "*************************** End of this module 1.1 check....***************************" >> ${FINALDIR}/1_patch_artifact.log
echo "*********************************************************************************" >>  ${FINALDIR}/1_patch_artifact.log
}

######################### 1.1 ENDS HERE ##############################################################

REP_Fn_1_2_DEF_Pass(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/1_2_Def_Pass.sql


checker=`cat ${REPSQLDIR}/1_2_DEF_Sql.log | grep "no rows selected" | wc -l`

cat ${REPSQLDIR}/1_2_DEF_Sql.log  >> ${FINALDIR}/1_2_DEF_Pass.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/1_2_DEF_Pass.log
         echo " 1.2 Ensure All Default Passwords are changed - AS PER CIS STANDARDS" >>  ${FINALDIR}/CIS_Success.log
            echo " 1.2 Ensure All Default Passwords are changed - AS PER CIS STANDARDS" >>  ${FINALDIR}/1_2_DEF_Pass.log
        else
        echo ""  >>  ${FINALDIR}/1_2_DEF_Pass.log

        echo " 1.2  Ensure All Default Passwords are changed - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/CIS_Failure.log
                echo " 1.2  Ensure All Default Passwords are changed - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/1_2_DEF_Pass.log
        fi


echo ""

echo ""


echo "" >> ${FINALDIR}/1_2_DEF_Pass.log
echo "***************************End of this module 1.2 check....***************************" >> ${FINALDIR}/1_2_DEF_Pass.log


echo "*********************************************************************************" >> ${FINALDIR}/1_2_DEF_Pass.log

}

######################### 1.2 ENDS HERE ##############################################################

REP_Fn_1_3_DEF_SCHEM_DROP(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/1_3_Def_Schem.sql


checker=`cat ${REPSQLDIR}/1_3_DEF_Schem.log | grep "no rows selected" | wc -l`

cat ${REPSQLDIR}/1_3_DEF_Schem.log  >> ${FINALDIR}/1_3_DEF_SCHEM_DROP.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/1_3_DEF_SCHEM_DROP.log
         echo " 1.3 Ensure All Default schemas are dropped - AS PER CIS STANDARDS" >>  ${FINALDIR}/CIS_Success.log
            echo " 1.3 Ensure All Default schemas are dropped  - AS PER CIS STANDARDS" >>  ${FINALDIR}/1_3_DEF_SCHEM_DROP.log
        else
        echo ""  >>  ${FINALDIR}/1_3_DEF_SCHEM_DROP.log

        echo " 1.3 Ensure All Default schemas are dropped  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/CIS_Failure.log
                echo " 1.3 Ensure All Default schemas are dropped  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/1_3_DEF_SCHEM_DROP.log
        fi


echo "" >> ${FINALDIR}/1_3_DEF_SCHEM_DROP.log


echo ""



echo ""

echo "*************************** End of this module 1.3 check ***************************" >> ${FINALDIR}/1_3_DEF_SCHEM_DROP.log

echo "*********************************************************************************" >> ${FINALDIR}/1_3_DEF_SCHEM_DROP.log

}

######################### 1.3 ENDS HERE ##############################################################

REP_Fn_2_1_LIST_HARD() {

LIS_OWNER=`ps -ef | grep tnslsnr  | grep -v grep | awk {'print $1'}`

LIS_NAME=`ps -ef | grep tnslsnr  | grep -v grep | awk {'print $9'}`

${OHOME}/bin/lsnrctl status ${LIS}


LIS_PART_HOME=`ps -ef | grep tnslsnr  | grep -v grep | awk {'print $8'} | awk '{ sub("/[^/]*$", ""); print }' | awk '{ sub("/[^/]*$", ""); print }'`
LIS_LOCATION=${LIS_PART_HOME}/network/admin/listener.ora

checker=`sudo grep -i "SECURE_CONTROL_${LIS_NAME}" ${LIS_LOCATION} | wc -l`
checker_desc=`sudo grep -i "SECURE_CONTROL" ${LIS_LOCATION}`

ext_proc_check=`sudo grep -i "extproc" ${LIS_LOCATION} | wc -l`
ext_proc_check_desc=`sudo grep -i "extproc" ${LIS_LOCATION}`


admin_check=`sudo grep -i "admin_restrictions" ${LIS_LOCATION} | wc -l`
admin_check_desc=`sudo grep -i "admin_restrictions" ${LIS_LOCATION}`


sec_reg_check=`sudo grep -i "secure_register" ${LIS_LOCATION} | wc -l`
sec_reg_check_desc=`sudo grep -i "secure_register" ${LIS_LOCATION}`




if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/2_1_1_SECURE_LIST.log
         echo " 2.1.1 Ensure Secure Control Listener is Set  - AS PER CIS STANDARDS" >>  ${FINALDIR}/CIS_Success.log
            echo " 2.1.1 Ensure Secure Control Listener is Set   - AS PER CIS STANDARDS" >>  ${FINALDIR}/2_1_1_SECURE_LIST.log
        else
        echo ""  >>  ${FINALDIR}/2_1_1_SECURE_LIST.log

        echo " 2.1.1 Ensure Secure Control Listener is Set   - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/CIS_Failure.log
                echo " 2.1.1 Ensure Secure Control Listener is Set   - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/2_1_1_SECURE_LIST.log
        fi


echo "" >> ${FINALDIR}/2_1_1_SECURE_LIST.log
echo " ${checker_desc} " >> ${FINALDIR}/2_1_1_SECURE_LIST.log
echo ""

echo ""


if [ ${ext_proc_check} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/2_1_2_EXTPROC_LIST.log
         echo " 2.1.2 Ensure Extproc is removed  - NOT AS PER CIS STANDARDS.. Need Attention" >>  ${FINALDIR}/CIS_Failure.log
            echo " 2.1.2 Ensure Extproc is removed   - NOT AS PER CIS STANDARDS.. Need Attention" >>  ${FINALDIR}/2_1_2_EXTPROC_LIST.log
        else
        echo ""  >>  ${FINALDIR}/2_1_2_EXTPROC_LIST.log

        echo " 2.1.2 Ensure Extproc is removed   -  AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
                echo " 2.1.2 Ensure Extproc is removed   -  AS PER CIS STANDARDS " >>  ${FINALDIR}/2_1_2_EXTPROC_LIST.log
fi


echo ""

echo ""



if [ ${admin_check} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/2_1_3_ADMIN_RESTRCT_LIST.log
         echo " 2.1.3 Ensure Admin restriction is Set  -  AS PER CIS STANDARDS" >>  ${FINALDIR}/CIS_Success.log
            echo " 2.1.3 Ensure Admin restriction is Set   -  AS PER CIS STANDARDS" >>  ${FINALDIR}/2_1_3_ADMIN_RESTRCT_LIST.log
        else
        echo ""  >>  ${FINALDIR}/2_1_3_ADMIN_RESTRCT_LIST.log

        echo " 2.1.3 Ensure Admin restriction is Set   - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/CIS_Failure.log
                echo " 2.1.3 Ensure Admin restriction is Set   - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/2_1_3_ADMIN_RESTRCT_LIST.log
fi
echo " ${admin_check_desc} " >> ${FINALDIR}/2_1_3_ADMIN_RESTRCT_LIST.log

echo ""

echo ""


if [ ${sec_reg_check} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/2_1_4_SECURE_REG.log
         echo " 2.1.4 Ensure Secure Registration is Set to TCP/IPC -  AS PER CIS STANDARDS" >>  ${FINALDIR}/CIS_Success.log
            echo " 2.1.4 Ensure Secure Registration is Set to TCP/IPC -  AS PER CIS STANDARDS" >>  ${FINALDIR}/2_1_4_SECURE_REG.log
        else
        echo ""  >>  ${FINALDIR}/2_1_4_SECURE_REG.log

        echo " 2.1.4 Ensure Secure Registration is Set to TCP/IPC - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/CIS_Failure.log
                echo " 2.1.4 Ensure Secure Registration is Set to TCP/IPC - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/2_1_4_SECURE_REG.log
fi

echo " ${sec_reg_check_desc} " >> ${FINALDIR}/2_1_4_SECURE_REG.log
echo ""

echo ""






echo " *************************** End of this module 2.1.1, 2.1.2, 2.1.3 and 2.1.4 check..***************************" >> ${FINALDIR}/2_1_4_SECURE_REG.log

echo ""

echo "*******************************"



}

######################### 2.1.1 ENDS HERE ##############################################################

REP_Fn_2_2_1_AUDSYS(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/2_2_1_Aud_SYS.sql


checker=`cat ${REPSQLDIR}/2_2_1_Aud_SYS.log | grep -i "TRUE" | wc -l`

cat ${REPSQLDIR}/2_2_1_Aud_SYS.log  >> ${FINALDIR}/2_2_1_AUDSYS.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/2_2_1_AUDSYS.log
         echo " 2.2.1 Ensure SYS AUDIT OPERATION ARE ENABLED - AS PER CIS STANDARDS" >>  ${FINALDIR}/CIS_Success.log
            echo "2.2.1 Ensure SYS AUDIT OPERATION ARE ENABLED  - AS PER CIS STANDARDS" >>  ${FINALDIR}/2_2_1_AUDSYS.log
        else
        echo ""  >>  ${FINALDIR}/2_2_1_AUDSYS.log

        echo " 2.2.1 Ensure SYS AUDIT OPERATION ARE ENABLED   - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/CIS_Failure.log
                echo " 2.2.1 Ensure SYS AUDIT OPERATION ARE ENABLED   - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/2_2_1_AUDSYS.log
        fi


echo "" >> ${FINALDIR}/2_2_1_AUDSYS.log


echo ""



echo ""

echo "*************************** End of this module 2.2.1 check ***************************" >> ${FINALDIR}/2_2_1_AUDSYS.log

echo "*********************************************************************************" >> ${FINALDIR}/2_2_1_AUDSYS.log

}

REP_Fn_2_2_2_AUDTRAIL(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/2_2_2_Aud_TRAIL.sql


checker=`cat ${REPSQLDIR}/sql_2_2_2_Aud_SYS.log | grep -i "None" | wc -l`

cat ${REPSQLDIR}/sql_2_2_2_Aud_SYS.log  >> ${FINALDIR}/2_2_2_AUDTRAIL.log


if [ ${checker} != 1 ];
        then
        echo ""  >>  ${FINALDIR}/2_2_2_AUDTRAIL.log
         echo " 2.2.2 Ensure AUDIT Trail is not set to NONE  - AS PER CIS STANDARDS" >>  ${FINALDIR}/CIS_Success.log
            echo "2.2.2 Ensure AUDIT Trail is not set to NONE  - AS PER CIS STANDARDS" >>  ${FINALDIR}/2_2_2_AUDTRAIL.log
        else
        echo ""  >>  ${FINALDIR}/2_2_2_AUDTRAIL.log

        echo " 2.2.2 Ensure AUDIT Trail is not set to NONE    - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/CIS_Failure.log
                echo " 2.2.2 Ensure AUDIT Trail is not set to NONE   - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/2_2_2_AUDTRAIL.log
        fi


echo "" >> ${FINALDIR}/2_2_2_AUDTRAIL.log


echo ""



echo ""

echo "*************************** End of this module 2.2.2 check ***************************" >> ${FINALDIR}/2_2_2_AUDTRAIL.log

echo "*********************************************************************************" >> ${FINALDIR}/2_2_2_AUDTRAIL.log

}

REP_Fn_2_2_3_GLOB_NAM(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/2_2_3_Gb_names.sql


checker=`cat ${REPSQLDIR}/sql_2_2_3_Gb_names.log | grep -i "True" | wc -l`

cat ${REPSQLDIR}/sql_2_2_2_Aud_SYS.log  >> ${FINALDIR}/2_2_3_GLOB_NAM.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/2_2_3_GLOB_NAM.log
         echo " 2.2.3 Ensure Global Names are set to True - AS PER CIS STANDARDS" >>  ${FINALDIR}/CIS_Success.log
            echo "2.2.3 Ensure Global Names are set to True - AS PER CIS STANDARDS" >>  ${FINALDIR}/2_2_3_GLOB_NAM.log
        else
        echo ""  >>  ${FINALDIR}/2_2_3_GLOB_NAM.log

        echo " 2.2.3 Ensure Global Names are set to True   - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/CIS_Failure.log
                echo " 2.2.3 Ensure Global Names are set to True  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/2_2_3_GLOB_NAM.log
        fi


echo "" >> ${FINALDIR}/2_2_3_GLOB_NAM.log


echo ""



echo ""

echo "*************************** End of this module 2.2.3 check ***************************" >> ${FINALDIR}/2_2_3_GLOB_NAM.log

echo "*********************************************************************************" >> ${FINALDIR}/2_2_3_GLOB_NAM.log

}

REP_Fn_2_2_4_LOC_LIS(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/2_2_4_Loc_Lis.sql


checker=`cat ${REPSQLDIR}/sql_2_2_4_LOC_LIS.log | grep -i "Description" | wc -l`

cat ${REPSQLDIR}/sql_2_2_4_LOC_LIS.log  >> ${FINALDIR}/2_2_4_LOC_LIS.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/2_2_4_LOC_LIS.log
         echo " 2.2.4 Ensure Local Listener is set to appropriate value - AS PER CIS STANDARDS" >>  ${FINALDIR}/CIS_Success.log
         echo "2.2.4 Ensure Local Listener is set to appropriate value  - AS PER CIS STANDARDS" >>  ${FINALDIR}/2_2_4_LOC_LIS.log
        else
        echo ""  >>  ${FINALDIR}/2_2_4_LOC_LIS.log

        echo " 2.2.4 Ensure Local Listener is set to appropriate value   - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/CIS_Failure.log
                echo " 2.2.4 Ensure Local Listener is set to appropriate value   - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/2_2_4_LOC_LIS.log
        fi


echo "" >> ${FINALDIR}/2_2_4_LOC_LIS.log


echo ""



echo ""

echo "*************************** End of this module 2.2.4 check ***************************" >> ${FINALDIR}/2_2_4_LOC_LIS.log

echo "*********************************************************************************" >> ${FINALDIR}/2_2_4_LOC_LIS.log

}

Exec_Fn_1_HARDEN(){


${OHOME}/bin/sqlplus "/ as sysdba"  @${SHELLDIR}/harden.sql
${OHOME}/bin/sqlplus "/ as sysdba"  @${SHELLDIR}/harden_4.sql
${OHOME}/bin/sqlplus "/ as sysdba"  @${SHELLDIR}/revoke_harden_4.sql

  if [ -f ${HARDENDIR}/HARDEN_1_2_DEF_Sql.log ]
  then
  cat ${HARDENDIR}/HARDEN_1_2_DEF_Sql.log  > ${FINALDIR}/HARDENING_SQL.log
  else
  echo " Hardening Script has not executed "
  fi
}

Exec_Fn_REV_HARDEN_4(){

echo "set echo on" > ${SHELLDIR}/revoke_harden.sql

echo "spool ${SHELLDIR}/revoke_harden.log" >> ${SHELLDIR}/revoke_harden.sql


cat /home/oracle/shell_scr/db_harden/sql_4_3_1_Rev_SELECT_ANY_DICTIONARY.log | grep -v selected |  awk {'print "revoke " $2,$3,$4,$5,$6,$7 " from " $1 ";"'} | grep -v "revoke       from ;" >> ${SHELLDIR}/revoke_harden.sql

cat /home/oracle/shell_scr/db_harden/sql_4_3_2_Rev_SELECT_ANY_TABLE.log | grep -v selected |  awk {'print "revoke " $2,$3,$4,$5,$6,$7 " from " $1 ";"'} | grep -v "revoke       from ;" >> ${SHELLDIR}/revoke_harden.sql

cat /home/oracle/shell_scr/db_harden/sql_4_3_3_Rev_AUDIT_SYSTEM.log | grep -v selected |  awk {'print "revoke " $2,$3,$4,$5,$6,$7 " from " $1 ";"'} | grep -v "revoke       from ;" >> ${SHELLDIR}/revoke_harden.sql

cat /home/oracle/shell_scr/db_harden/sql_4_3_4_Rev_EXEMPT_ACCESS_POLICY.log | grep -v selected |  awk {'print "revoke " $2,$3,$4,$5,$6,$7 " from " $1 ";"'} | grep -v "revoke       from ;" >> ${SHELLDIR}/revoke_harden.sql

cat /home/oracle/shell_scr/db_harden/sql_4_3_5_Rev_BECOME_USER.log | grep -v selected |  awk {'print "revoke " $2,$3,$4,$5,$6,$7 " from " $1 ";"'} | grep -v "revoke       from ;" >> ${SHELLDIR}/revoke_harden.sql

cat /home/oracle/shell_scr/db_harden/sql_4_3_6_Rev_CREATE_PROCEDURE.log | grep -v selected |  awk {'print "revoke " $2,$3,$4,$5,$6,$7 " from " $1 ";"'} | grep -v "revoke       from ;" >> ${SHELLDIR}/revoke_harden.sql

cat /home/oracle/shell_scr/db_harden/sql_4_3_7_Rev_ALTER_SYSTEM.log | grep -v selected |  awk {'print "revoke " $2,$3,$4,$5,$6,$7 " from " $1 ";"'} | grep -v "revoke       from ;" >> ${SHELLDIR}/revoke_harden.sql

cat /home/oracle/shell_scr/db_harden/sql_4_3_8_Rev_CREATE_ANY_LIBRARY.log | grep -v selected |  awk {'print "revoke " $2,$3,$4,$5,$6,$7 " from " $1 ";"'} | grep -v "revoke       from ;" >> ${SHELLDIR}/revoke_harden.sql

cat /home/oracle/shell_scr/db_harden/sql_4_3_9_Rev_CREATE_LIBRARY.log | grep -v selected |  awk {'print "revoke " $2,$3,$4,$5,$6,$7 " from " $1 ";"'} | grep -v "revoke       from ;" >> ${SHELLDIR}/revoke_harden.sql

cat /home/oracle/shell_scr/db_harden/sql_4_3_10_Rev_GRANT_ANY_OBJ_PRIV.log | grep -v selected |  awk {'print "revoke " $2,$3,$4,$5,$6,$7 " from " $1 ";"'} | grep -v "revoke       from ;" >> ${SHELLDIR}/revoke_harden.sql

cat /home/oracle/shell_scr/db_harden/sql_4_3_11_Rev_GRANT_ANY_ROLE.log | grep -v selected |  awk {'print "revoke " $2,$3,$4,$5,$6,$7 " from " $1 ";"'} | grep -v "revoke       from ;" >> ${SHELLDIR}/revoke_harden.sql

cat /home/oracle/shell_scr/db_harden/sql_4_3_12_Rev_GRANT_ANY_PRIVILEGE.log | grep -v selected |  awk {'print "revoke " $2,$3,$4,$5,$6,$7 " from " $1 ";"'} | grep -v "revoke       from ;" >> ${SHELLDIR}/revoke_harden.sql

cat /home/oracle/shell_scr/db_harden/sql_4_4_1_Rev_DELETE_CATALOG_ROLE.log | grep -v selected |  awk {'print "revoke " $2,$3,$4,$5,$6,$7 " from " $1 ";"'} | grep -v "revoke       from ;" >> ${SHELLDIR}/revoke_harden.sql

cat /home/oracle/shell_scr/db_harden/sql_4_4_2_Rev_SELECT_CATALOG_ROLE.log | grep -v selected |  awk {'print "revoke " $2,$3,$4,$5,$6,$7 " from " $1 ";"'} | grep -v "revoke       from ;" >> ${SHELLDIR}/revoke_harden.sql

cat /home/oracle/shell_scr/db_harden/sql_4_4_3_Rev_EXECUTE_CATALOG_ROLE.log | grep -v selected |  awk {'print "revoke " $2,$3,$4,$5,$6,$7 " from " $1 ";"'} | grep -v "revoke       from ;" >> ${SHELLDIR}/revoke_harden.sql

cat /home/oracle/shell_scr/db_harden/sql_4_4_4_Rev_DBA.log | grep -v selected |  awk {'print "revoke " $2,$3,$4,$5,$6,$7 " from " $1 ";"'} | grep -v "revoke       from ;" >> ${SHELLDIR}/revoke_harden.sql

cat /home/oracle/shell_scr/db_harden/sql_4_5_1_Rev_ALL_AUD.log | grep -v selected |  awk {'print "revoke " $2,$3,$4,$5,$6,$7 " from " $1 ";"'} | grep -v "revoke       from ;" >> ${SHELLDIR}/revoke_harden.sql

cat /home/oracle/shell_scr/db_harden/sql_4_5_2_Rev_ALL_USER_HISTORY.log | grep -v selected |  awk {'print "revoke " $2,$3,$4,$5,$6,$7 " from " $1 ";"'} | grep -v "revoke       from ;" >> ${SHELLDIR}/revoke_harden.sql

cat /home/oracle/shell_scr/db_harden/sql_4_5_3_Rev_ALL_LINK.log | grep -v selected |  awk {'print "revoke " $2,$3,$4,$5,$6,$7 " from " $1 ";"'} | grep -v "revoke       from ;" >> ${SHELLDIR}/revoke_harden.sql

cat /home/oracle/shell_scr/db_harden/sql_4_5_4_Rev_ALL_SYS_USER.log | grep -v selected |  awk {'print "revoke " $2,$3,$4,$5,$6,$7 " from " $1 ";"'} | grep -v "revoke       from ;" >> ${SHELLDIR}/revoke_harden.sql

cat /home/oracle/shell_scr/db_harden/sql_4_5_5_Rev_ALL_DBA.log | grep -v selected |  awk {'print "revoke all on "$3" from " $1 ";"'} | grep -v "revoke       from ;" >> ${SHELLDIR}/revoke_harden.sql

cat /home/oracle/shell_scr/db_harden/sql_4_5_6_Rev_ALL_SYS_SCHEDULER_CREDENTIAL.log | grep -v selected |  awk {'print "revoke " $2,$3,$4,$5,$6,$7 " from " $1 ";"'} | grep -v "revoke       from ;" >> ${SHELLDIR}/revoke_harden.sql

cat /home/oracle/shell_scr/db_harden/sql_4_5_7_Drop_SYS_USER_MIG.log | grep -v selected |  awk {'print "revoke " $2,$3,$4,$5,$6,$7 " from " $1 ";"'} | grep -v "revoke       from ;" >> ${SHELLDIR}/revoke_harden.sql

cat /home/oracle/shell_scr/db_harden/sql_4_6_Rev_ANY.log | grep -v selected |  awk {'print "revoke " $2,$3,$4,$5,$6,$7 " from " $1 ";"'} | grep -v "revoke       from ;" >> ${SHELLDIR}/revoke_harden.sql

cat /home/oracle/shell_scr/db_harden/sql_4_7_Rev_ADMIN_OPTION_YES.log | grep -v selected |  awk {'print "revoke " $2,$3,$4,$5,$6,$7 " from " $1 ";"'} | grep -v "revoke       from ;" >> ${SHELLDIR}/revoke_harden.sql

cat /home/oracle/shell_scr/db_harden/sql_4_8_Rev_CONNECT_Priv.log | grep -v selected |  awk {'print "revoke " $2,$3,$4,$5,$6,$7 " from " $1 ";"'} | grep -v "revoke       from ;" >> ${SHELLDIR}/revoke_harden.sql

cat /home/oracle/shell_scr/db_harden/sql_4_9_Rev_EXECUTE_ANY_PROCEDURE_OUTLN.log | grep -v selected |  awk {'print "revoke " $2,$3,$4,$5,$6,$7 " from " $1 ";"'} | grep -v "revoke       from ;" >> ${SHELLDIR}/revoke_harden.sql

echo "spool off"  >> revoke_harden.sql

echo "exit" >> revoke_harden.sql

${OHOME}/bin/sqlplus "/ as sysdba"  @${SHELLDIR}/revoke_harden.sql

cat ${SHELLDIR}/revoke_harden.log  >> ${FINALDIR}/revoke_harden.log

echo "" >> ${FINALDIR}/revoke_harden.log

echo ""

echo ""

echo "*************************** Revoke Hardening Sestion Ends here ***************************" >> ${FINALDIR}/revoke_harden.log

echo "*********************************************************************************" >> ${FINALDIR}/revoke_harden.log

}

Exec_fn_2_1_LIST_HARD(){

LIS_OWNER=`ps -ef | grep tnslsnr  | grep -v grep | awk {'print $1'}`

LIS_NAME=`ps -ef | grep tnslsnr  | grep -v grep | awk {'print $9'}`

${OHOME}/bin/lsnrctl status ${LIS}


LIS_PART_HOME=`ps -ef | grep tnslsnr  | grep -v grep | awk {'print $8'} | awk '{ sub("/[^/]*$", ""); print }' | awk '{ sub("/[^/]*$", ""); print }'`
LIS_LOCATION=${LIS_PART_HOME}/network/admin/listener.ora
TEMP_LIST_LOCATION=${LIS_PART_HOME}/network/admin/test.out
cp ${LIS_LOCATION} ${LIS_LOCATION}.bk

 sed '/EXTPROC/d'  ${LIS_LOCATION} > ${TEMP_LIST_LOCATION}
 sed '/EXTPROC1/d'  ${LIS_LOCATION} > ${TEMP_LIST_LOCATION}
 mv ${TEMP_LIST_LOCATION}   ${LIS_LOCATION}

 echo  "SECURE_CONTROL_${LIS_NAME}=TCPS" >> ${LIS_LOCATION}
 echo  "ADMIN_RESTRICTIONS_${LIS_NAME}=ON" >> ${LIS_LOCATION}
 echo  "SECURE_REGISTER_${LIS_NAME}=IPC"  >> ${LIS_LOCATION}


}

Exec_fn_2_2_4_LOC_LIST(){

LIS_OWNER=`ps -ef | grep tnslsnr  | grep -v grep | awk {'print $1'}`

LIS_NAME=`ps -ef | grep tnslsnr  | grep -v grep | awk {'print $9'}`

#LOC_VAR=`${OHOME}/bin/lsnrctl status ${LIS} | grep -i Description`
LOC_VAR=`${OHOME}/bin/lsnrctl status ${LIS_NAME} |  grep -v "Connecting to" | grep -i "description"`


echo " SET ECHO ON " > ${SHELLDIR}/harden_loc_lis.sql
echo " spool ${HARDENDIR}/sql_harden_loc_lis.log " >> ${SHELLDIR}/harden_loc_lis.sql
echo "ALTER SYSTEM SET LOCAL_LISTENER='$LOC_VAR';" >> ${SHELLDIR}/harden_loc_lis.sql
echo "spool off" >> ${SHELLDIR}/harden_loc_lis.sql
echo "exit;" >> ${SHELLDIR}/harden_loc_lis.sql

${OHOME}/bin/sqlplus "/ as sysdba"  @${SHELLDIR}/harden_loc_lis.sql

 if [ -f ${HARDENDIR}/sql_harden_loc_lis.log ]
  then
  cat ${HARDENDIR}/sql_harden_loc_lis.log  >> ${FINALDIR}/HARDENING_SQL.log
  else
  echo " Local Listener Hardening Script has not executed"
  fi


}

REP_Fn_2_2_6_OS_ROLE(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/2_2_6_OS_ROLE.sql


checker=`cat ${REPSQLDIR}/sql_2_2_6_os_roles.log | grep -i "FALSE" | wc -l`

cat ${REPSQLDIR}/sql_2_2_6_os_roles.log  >> ${FINALDIR}/2_2_6_OS_ROLE.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/2_2_6_OS_ROLE.log
         echo " 2.2.6 Ensure OS_ROLES Is Set to FALSE - AS PER CIS STANDARDS" >>  ${FINALDIR}/CIS_Success.log
            echo " 2.2.6 Ensure OS_ROLES Is Set to FALSE - AS PER CIS STANDARDS" >>  ${FINALDIR}/2_2_6_OS_ROLE.log
        else
        echo ""  >>  ${FINALDIR}/2_2_6_OS_ROLE.log

        echo " 2.2.6 Ensure OS_ROLES Is Set to FALSE   - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/CIS_Failure.log
                echo " 2.2.6 Ensure OS_ROLES Is Set to FALSE  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/2_2_6_OS_ROLE.log
        fi


echo "" >> ${FINALDIR}/2_2_6_OS_ROLE.log


echo ""



echo ""

echo "*************************** End of this module 2.2.6 check ***************************" >> ${FINALDIR}/2_2_6_OS_ROLE.log

echo "*********************************************************************************" >> ${FINALDIR}/2_2_6_OS_ROLE.log

}

REP_Fn_2_2_7_DICTIONARY_ACCESSIBILITY(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/2_2_7_DICTIONARY_ACCESSIBILITY.sql


checker=`cat ${REPSQLDIR}/sql_2_2_7_dict_access.log | grep -i "FALSE" | wc -l`

cat ${REPSQLDIR}/sql_2_2_7_dict_access.log  >> ${FINALDIR}/2_2_7_DICTIONARY_ACCESSIBILITY.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/2_2_7_DICTIONARY_ACCESSIBILITY.log
         echo " 2.2.7 Ensure O7_DICTIONARY_ACCESSIBILITY Is Set to FALSE - AS PER CIS STANDARDS" >>  ${FINALDIR}/CIS_Success.log
            echo " 2.2.7 Ensure O7_DICTIONARY_ACCESSIBILITY Is Set to FALSE - AS PER CIS STANDARDS" >>  ${FINALDIR}/2_2_7_DICTIONARY_ACCESSIBILITY.log
        else
        echo ""  >>  ${FINALDIR}/2_2_7_DICTIONARY_ACCESSIBILITY.log

        echo " 2.2.7 Ensure O7_DICTIONARY_ACCESSIBILITY Is Set to FALSE   - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/CIS_Failure.log
                echo " 2.2.7 Ensure O7_DICTIONARY_ACCESSIBILITY Is Set to FALSE  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/2_2_7_DICTIONARY_ACCESSIBILITY.log
        fi


echo "" >> ${FINALDIR}/2_2_7_DICTIONARY_ACCESSIBILITY.log


echo ""



echo ""

echo "*************************** End of this module 2.2.7 check ***************************" >> ${FINALDIR}/2_2_7_DICTIONARY_ACCESSIBILITY.log

echo "*********************************************************************************" >> ${FINALDIR}/2_2_7_DICTIONARY_ACCESSIBILITY.log

}

REP_Fn_2_2_8_Rem_Login_Pwdfile(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/2_2_8_Rem_Login_Pwdfile.sql


checker=`cat ${REPSQLDIR}/sql_2_2_8_Rem_LoginPwd_File.log | grep -i "NONE" | wc -l`

cat ${REPSQLDIR}/sql_2_2_8_Rem_LoginPwd_File.log  >> ${FINALDIR}/2_2_8_Rem_Login_Pwdfile.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/2_2_8_Rem_Login_Pwdfile.log
         echo " 2.2.8 Ensure REMOTE_LOGIN_PASSWORDFILE Is Set to NONE - AS PER CIS STANDARDS" >>  ${FINALDIR}/CIS_Success.log
            echo "2.2.8 Ensure REMOTE_LOGIN_PASSWORDFILE Is Set to NONE - AS PER CIS STANDARDS" >>  ${FINALDIR}/2_2_8_Rem_Login_Pwdfile.log
        else
        echo ""  >>  ${FINALDIR}/2_2_8_Rem_Login_Pwdfile.log

        echo " 2.2.8 Ensure REMOTE_LOGIN_PASSWORDFILE Is Set to NONE   - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/CIS_Failure.log
                echo " 2.2.8 Ensure REMOTE_LOGIN_PASSWORDFILE Is Set to NONE  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/2_2_8_Rem_Login_Pwdfile.log
        fi


echo "" >> ${FINALDIR}/2_2_8_Rem_Login_Pwdfile.log


echo ""



echo ""

echo "*************************** End of this module 2.2.8 check ***************************" >> ${FINALDIR}/2_2_8_Rem_Login_Pwdfile.log

echo "*********************************************************************************" >> ${FINALDIR}/2_2_8_Rem_Login_Pwdfile.log

}

REP_Fn_2_2_9_REM_OS_AUTH(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/2_2_9_rem_OS_Authent.sql


checker=`cat ${REPSQLDIR}/sql_2_2_9_os_authent.log | grep -i "FALSE" | wc -l`

cat ${REPSQLDIR}/sql_2_2_9_os_authent.log  >> ${FINALDIR}/2_2_9_REM_OS.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/2_2_9_REM_OS.log
         echo " 2.2.9 Ensure REMOTE_OS_AUTHENT Is Set to FALSE - AS PER CIS STANDARDS" >>  ${FINALDIR}/CIS_Success.log
            echo "2.2.9 Ensure REMOTE_OS_AUTHENT Is Set to FALSE - AS PER CIS STANDARDS" >>  ${FINALDIR}/2_2_9_REM_OS.log
        else
        echo ""  >>  ${FINALDIR}/2_2_9_REM_OS.log

        echo " 2.2.9 Ensure REMOTE_OS_AUTHENT Is Set to FALSE   - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/CIS_Failure.log
                echo " Ensure REMOTE_OS_AUTHENT Is Set to FALSE  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/2_2_9_REM_OS.log
        fi


echo "" >> ${FINALDIR}/2_2_9_REM_OS.log


echo ""



echo ""

echo "*************************** End of this module 2.2.9 check ***************************" >> ${FINALDIR}/2_2_9_REM_OS.log

echo "*********************************************************************************" >> ${FINALDIR}/2_2_9_REM_OS.log

}

REP_Fn_2_2_10_REM_OS_ROLES(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/2_2_10_rem_OS_roles.sql


checker=`cat ${REPSQLDIR}/sql_2_2_10_Rem_OS_roles.log | grep -i "FALSE" | wc -l`

cat ${REPSQLDIR}/sql_2_2_10_Rem_OS_roles.log  >> ${FINALDIR}/2_2_10_REM_OS_ROLES.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/2_2_10_REM_OS_ROLES.log
         echo " 2.2.10 Ensure REMOTE_OS_ROLES Is Set to FALSE - AS PER CIS STANDARDS" >>  ${FINALDIR}/CIS_Success.log
            echo "2.2.9 Ensure REMOTE_OS_ROLES Is Set to FALSE - AS PER CIS STANDARDS" >>  ${FINALDIR}/2_2_10_REM_OS_ROLES.log
        else
        echo ""  >>  ${FINALDIR}/2_2_10_REM_OS_ROLES.log

        echo " 2.2.9 Ensure Ensure REMOTE_OS_ROLES Is Set to FALSE   - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/CIS_Failure.log
                echo " 2.2.9 Ensure Ensure REMOTE_OS_ROLES Is Set to FALSE  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/2_2_10_REM_OS_ROLES.log
        fi


echo "" >> ${FINALDIR}/2_2_10_REM_OS_ROLES.log


echo ""



echo ""

echo "*************************** End of this module 2.2.10 check ***************************" >> ${FINALDIR}/2_2_10_REM_OS_ROLES.log

echo "*********************************************************************************" >> ${FINALDIR}/2_2_10_REM_OS_ROLES.log

}

REP_Fn_2_2_12_SEC_CASE_SENSITIVE_LOGON(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/2_2_12_SEC_CASE_SENSITIVE_LOGON.sql


checker=`cat ${REPSQLDIR}/sql_2_2_12_Sec_case_sensLogon.log | grep -i "TRUE" | wc -l`

cat ${REPSQLDIR}/sql_2_2_12_Sec_case_sensLogon.log  >> ${FINALDIR}/2_2_12_SEC_CASE_SENSITIVE_LOGON.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/2_2_12_SEC_CASE_SENSITIVE_LOGON.log
         echo " 2.2.12 Ensure SEC_CASE_SENSITIVE_LOGON Is Set to TRUE  - AS PER CIS STANDARDS" >>  ${FINALDIR}/CIS_Success.log
            echo " 2.2.12 Ensure SEC_CASE_SENSITIVE_LOGON Is Set to TRUE - AS PER CIS STANDARDS" >>  ${FINALDIR}/2_2_12_SEC_CASE_SENSITIVE_LOGON.log
        else
        echo ""  >>  ${FINALDIR}/2_2_12_SEC_CASE_SENSITIVE_LOGON.log

        echo " 2.2.12 Ensure SEC_CASE_SENSITIVE_LOGON Is Set to TRUE   - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/CIS_Failure.log
                echo " 2.2.12 Ensure SEC_CASE_SENSITIVE_LOGON Is Set to TRUE  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/2_2_12_SEC_CASE_SENSITIVE_LOGON.log
        fi


echo "" >> ${FINALDIR}/2_2_12_SEC_CASE_SENSITIVE_LOGON.log


echo ""



echo ""

echo "*************************** End of this module 2.2.12 check ***************************" >> ${FINALDIR}/2_2_12_SEC_CASE_SENSITIVE_LOGON.log

echo "*********************************************************************************" >> ${FINALDIR}/2_2_12_SEC_CASE_SENSITIVE_LOGON.log

}

REP_Fn_2_2_13_SEC_MAX_FAILED_LOGIN(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/2_2_13_SEC_MAX_FAILED_LOGIN.sql


checker=`cat ${REPSQLDIR}/sql_2_2_13_Sec_maxfailed_login.log | grep -i "10" | wc -l`

cat ${REPSQLDIR}/sql_2_2_13_Sec_maxfailed_login.log  >> ${FINALDIR}/2_2_13_SEC_MAX_FAILED_LOGIN.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/2_2_13_SEC_MAX_FAILED_LOGIN.log
         echo " 2.2.13 Ensure SEC_MAX_FAILED_LOGIN_ATTEMPTS Is Set to 10 - AS PER CIS STANDARDS" >>  ${FINALDIR}/CIS_Success.log
            echo " 2.2.13 Ensure SEC_MAX_FAILED_LOGIN_ATTEMPTS Is Set to 10 - AS PER CIS STANDARDS" >>  ${FINALDIR}/2_2_13_SEC_MAX_FAILED_LOGIN.log
        else
        echo ""  >>  ${FINALDIR}/2_2_13_SEC_MAX_FAILED_LOGIN.log

        echo " 2.2.13 Ensure SEC_MAX_FAILED_LOGIN_ATTEMPTS Is Set to 10   - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/CIS_Failure.log
                echo " 2.2.13 Ensure SEC_MAX_FAILED_LOGIN_ATTEMPTS Is Set to 10  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/2_2_13_SEC_MAX_FAILED_LOGIN.log
        fi


echo "" >> ${FINALDIR}/2_2_13_SEC_MAX_FAILED_LOGIN.log


echo ""



echo ""

echo "*************************** End of this module 2.2.13 check ***************************" >> ${FINALDIR}/2_2_13_SEC_MAX_FAILED_LOGIN.log

echo "*********************************************************************************" >> ${FINALDIR}/2_2_13_SEC_MAX_FAILED_LOGIN.log

}

REP_Fn_2_2_14_SEC_ERROR_FURTHER_ACTION(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/2_2_14_SEC_ERROR_FURTHER_ACTION.sql


checker=`cat ${REPSQLDIR}/sql_2_2_14_SEC_PROTOCOL_ERROR_FURTHER_ACTION.log | grep -E '(DROP,3)|(DELAY,3)' | wc -l`

cat ${REPSQLDIR}/sql_2_2_14_SEC_PROTOCOL_ERROR_FURTHER_ACTION.log  >> ${FINALDIR}/2_2_14_SEC_ERROR_FURTHER_ACTION.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/2_2_14_SEC_ERROR_FURTHER_ACTION.log
         echo " 2.2.14 Ensure SEC_PROTOCOL_ERROR_FURTHER_ACTION Is Set to (DELAY,3) or (DROP,3) - AS PER CIS STANDARDS" >>  ${FINALDIR}/CIS_Success.log
            echo " 2.2.14 Ensure SEC_PROTOCOL_ERROR_FURTHER_ACTION Is Set to (DELAY,3) or (DROP,3) - AS PER CIS STANDARDS" >>  ${FINALDIR}/2_2_14_SEC_ERROR_FURTHER_ACTION.log
        else
        echo ""  >>  ${FINALDIR}/2_2_14_SEC_ERROR_FURTHER_ACTION.log

        echo " 2.2.14 Ensure SEC_PROTOCOL_ERROR_FURTHER_ACTION Is Set to (DELAY,3) or (DROP,3)  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/CIS_Failure.log
                echo " 2.2.14 Ensure SEC_PROTOCOL_ERROR_FURTHER_ACTION Is Set to (DELAY,3) or (DROP,3)  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/2_2_14_SEC_ERROR_FURTHER_ACTION.log
        fi


echo "" >> ${FINALDIR}/2_2_14_SEC_ERROR_FURTHER_ACTION.log


echo ""



echo ""

echo "*************************** End of this module 2.2.14 check ***************************" >> ${FINALDIR}/2_2_14_SEC_ERROR_FURTHER_ACTION.log

echo "*********************************************************************************" >> ${FINALDIR}/2_2_14_SEC_ERROR_FURTHER_ACTION.log

}

REP_Fn_2_2_15_SEC_ERROR_TRACE_ACTION(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/2_2_15_SEC_ERROR_TRACE_ACTION.sql


checker=`cat ${REPSQLDIR}/sql_2_2_15_SEC_PROTOCOL_ERROR_TRACE_ACTION.log | grep -i "LOG" | wc -l`

cat ${REPSQLDIR}/sql_2_2_15_SEC_PROTOCOL_ERROR_TRACE_ACTION.log  >> ${FINALDIR}/2_2_15_SEC_ERROR_TRACE_ACTION.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/2_2_15_SEC_ERROR_TRACE_ACTION.log
         echo " 2.2.15 Ensure SEC_PROTOCOL_ERROR_TRACE_ACTION Is Set to LOG - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 2.2.15 Ensure SEC_PROTOCOL_ERROR_TRACE_ACTION Is Set to LOG - AS PER CIS STANDARDS" >>  ${FINALDIR}/2_2_15_SEC_ERROR_TRACE_ACTION.log
        else
        echo ""  >>  ${FINALDIR}/2_2_15_SEC_ERROR_TRACE_ACTION.log

        echo " 2.2.15 Ensure SEC_PROTOCOL_ERROR_TRACE_ACTION Is Set to LOG  - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
                echo " 2.2.15 Ensure SEC_PROTOCOL_ERROR_TRACE_ACTION Is Set to LOG  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/2_2_15_SEC_ERROR_TRACE_ACTION.log
        fi


echo "" >> ${FINALDIR}/2_2_15_SEC_ERROR_TRACE_ACTION.log


echo ""



echo ""

echo "*************************** End of this module 2.2.15 check ***************************" >> ${FINALDIR}/2_2_15_SEC_ERROR_TRACE_ACTION.log

echo "*********************************************************************************" >> ${FINALDIR}/2_2_15_SEC_ERROR_TRACE_ACTION.log

}

REP_Fn_2_2_16_SEC_RETURN_SERVER_BANNER(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/2_2_16_SEC_RETURN_SERVER_BANNER.sql


checker=`cat ${REPSQLDIR}/sql_2_2_16_SEC_RETURN_SERVER_RELEASE_BANNER.log | grep -i "FALSE" | wc -l`

cat ${REPSQLDIR}/sql_2_2_16_SEC_RETURN_SERVER_RELEASE_BANNER.log  >> ${FINALDIR}/2_2_16_SEC_RETURN_SERVER_BANNER.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/2_2_16_SEC_RETURN_SERVER_BANNER.log
         echo " 2.2.16 Ensure SEC_RETURN_SERVER_RELEASE_BANNER Is Set to FALSE - AS PER CIS STANDARDS" >>  ${FINALDIR}/CIS_Success.log
            echo " 2.2.16 Ensure SEC_RETURN_SERVER_RELEASE_BANNER Is Set to FALSE - AS PER CIS STANDARDS" >>  ${FINALDIR}/2_2_16_SEC_RETURN_SERVER_BANNER.log
        else
        echo ""  >>  ${FINALDIR}/2_2_16_SEC_RETURN_SERVER_BANNER.log

        echo " 2.2.16 Ensure SEC_RETURN_SERVER_RELEASE_BANNER Is Set to FALSE  - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
                echo " 2.2.16 Ensure SEC_RETURN_SERVER_RELEASE_BANNER Is Set to FALSE  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/2_2_16_SEC_RETURN_SERVER_BANNER.log
        fi


echo "" >> ${FINALDIR}/2_2_16_SEC_RETURN_SERVER_BANNER.log


echo ""



echo ""

echo "*************************** End of this module 2.2.16 check ***************************" >> ${FINALDIR}/2_2_16_SEC_RETURN_SERVER_BANNER.log

echo "*********************************************************************************" >> ${FINALDIR}/2_2_16_SEC_RETURN_SERVER_BANNER.log

}

REP_Fn_2_2_17_SQL92_SECURITY(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/2_2_17_SQL92_SECURITY.sql


checker=`cat ${REPSQLDIR}/sql_2_2_17_SQL92_SECURITY.log | grep -i "FALSE" | wc -l`

cat ${REPSQLDIR}/sql_2_2_17_SQL92_SECURITY.log  >> ${FINALDIR}/2_2_17_SQL92_SECURITY.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/2_2_17_SQL92_SECURITY.log
         echo " 2.2.17 Ensure SQL92_SECURITY Is Set to FALSE - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 2.2.17 Ensure SQL92_SECURITY Is Set to FALSE - AS PER CIS STANDARDS " >>  ${FINALDIR}/2_2_17_SQL92_SECURITY.log
        else
        echo ""  >>  ${FINALDIR}/2_2_17_SQL92_SECURITY.log

        echo " 2.2.17 Ensure SQL92_SECURITY Is Set to FALSE  - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
                echo " 2.2.17 Ensure SQL92_SECURITY Is Set to FALSE  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/2_2_17_SQL92_SECURITY.log
        fi


echo "" >> ${FINALDIR}/2_2_17_SQL92_SECURITY.log


echo ""



echo ""

echo "*************************** End of this module 2.2.17 check ***************************" >> ${FINALDIR}/2_2_17_SQL92_SECURITY.log

echo "*********************************************************************************" >> ${FINALDIR}/2_2_17_SQL92_SECURITY.log

}

REP_Fn_2_2_18_TRACE_FILES_PUBLIC(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/2_2_18_TRACE_FILES_PUBLIC.sql


checker=`cat ${REPSQLDIR}/sql_2_2_18_TRACE_FILES_PUBLIC.log | grep trace_files_public | grep -i "FALSE" | wc -l`

cat ${REPSQLDIR}/sql_2_2_18_TRACE_FILES_PUBLIC.log  >> ${FINALDIR}/2_2_18_TRACE_FILES_PUBLIC.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/2_2_18_TRACE_FILES_PUBLIC.log
         echo " 2.2.18 Ensure _TRACE_FILES_PUBLIC Is Set to FALSE - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 2.2.18 Ensure _TRACE_FILES_PUBLIC Is Set to FALSE - AS PER CIS STANDARDS " >>  ${FINALDIR}/2_2_18_TRACE_FILES_PUBLIC.log
        else
        echo ""  >>  ${FINALDIR}/2_2_18_TRACE_FILES_PUBLIC.log

        echo " 2.2.18 Ensure _TRACE_FILES_PUBLIC Is Set to FALSE  - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
                echo " 2.2.18 Ensure _TRACE_FILES_PUBLIC Is Set to FALSE  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/2_2_18_TRACE_FILES_PUBLIC.log
        fi


echo "" >> ${FINALDIR}/2_2_18_TRACE_FILES_PUBLIC.log


echo ""



echo ""

echo "*************************** End of this module 2.2.18 check ***************************" >> ${FINALDIR}/2_2_18_TRACE_FILES_PUBLIC.log

echo "*********************************************************************************" >> ${FINALDIR}/2_2_18_TRACE_FILES_PUBLIC.log

}

REP_Fn_2_2_19_RESOURCE_LIMIT(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/2_2_19_RESOURCE_LIMIT.sql


checker=`cat ${REPSQLDIR}/sql_2_2_19_RESOURCE_LIMIT.log | grep -i "TRUE" | wc -l`

cat ${REPSQLDIR}/sql_2_2_19_RESOURCE_LIMIT.log  >> ${FINALDIR}/2_2_19_RESOURCE_LIMIT.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/2_2_19_RESOURCE_LIMIT.log
         echo " 2.2.19 Ensure RESOURCE_LIMIT Is Set to TRUE - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 2.2.19 Ensure RESOURCE_LIMIT Is Set to TRUE - AS PER CIS STANDARDS " >>  ${FINALDIR}/2_2_19_RESOURCE_LIMIT.log
        else
        echo ""  >>  ${FINALDIR}/2_2_19_RESOURCE_LIMIT.log

        echo " 2.2.19 Ensure RESOURCE_LIMIT Is Set to TRUE  - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
                echo " 2.2.19 Ensure RESOURCE_LIMIT Is Set to TRUE  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/2_2_19_RESOURCE_LIMIT.log
        fi


echo "" >> ${FINALDIR}/2_2_19_RESOURCE_LIMIT.log


echo ""



echo ""

echo "*************************** End of this module 2.2.19 check ***************************" >> ${FINALDIR}/2_2_19_RESOURCE_LIMIT.log

echo "*********************************************************************************" >> ${FINALDIR}/2_2_19_RESOURCE_LIMIT.log

}

######################### SECTION 2 ENDS HERE #########################


REP_Fn_3_1_PROFILE_FAILED_LOGIN(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/3_1_PROFILE_FAILED_LOGIN.sql


checker=`cat ${REPSQLDIR}/sql_3_1_failed_login.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_3_1_failed_login.log  >> ${FINALDIR}/3_1_PROFILE_FAILED_LOGIN.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/3_1_PROFILE_FAILED_LOGIN.log
         echo " 3.1 Ensure FAILED_LOGIN_ATTEMPTS Is Less than or Equal to 5 - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 3.1 Ensure FAILED_LOGIN_ATTEMPTS Is Less than or Equal to 5 - AS PER CIS STANDARDS " >>  ${FINALDIR}/3_1_PROFILE_FAILED_LOGIN.log
        else
        echo ""  >>  ${FINALDIR}/3_1_PROFILE_FAILED_LOGIN.log

        echo " 3.1 Ensure FAILED_LOGIN_ATTEMPTS Is Less than or Equal to 5  - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
                echo " 3.1 Ensure FAILED_LOGIN_ATTEMPTS Is Less than or Equal to 5  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/3_1_PROFILE_FAILED_LOGIN.log
        fi


echo "" >> ${FINALDIR}/3_1_PROFILE_FAILED_LOGIN.log


echo ""



echo ""

echo "*************************** End of this module 3.1 check ***************************" >> ${FINALDIR}/3_1_PROFILE_FAILED_LOGIN.log

echo "*********************************************************************************" >> ${FINALDIR}/3_1_PROFILE_FAILED_LOGIN.log

}

REP_Fn_3_2_PROFILE_PASSWORD_LOCK(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/3_2_PROFILE_PASSWORD_LOCK.sql


checker=`cat ${REPSQLDIR}/sql_3_2_password_lock.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_3_2_password_lock.log  >> ${FINALDIR}/3_2_PROFILE_PASSWORD_LOCK.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/3_2_PROFILE_PASSWORD_LOCK.log
         echo " 3.2 Ensure PASSWORD_LOCK_TIME Is Greater than or Equal to 1 - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 3.2 Ensure PASSWORD_LOCK_TIME Is Greater than or Equal to 1 - AS PER CIS STANDARDS " >>  ${FINALDIR}/3_2_PROFILE_PASSWORD_LOCK.log
        else
        echo ""  >>  ${FINALDIR}/3_2_PROFILE_PASSWORD_LOCK.log

        echo " 3.2 Ensure PASSWORD_LOCK_TIME Is Greater than or Equal to 1  - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
                echo " 3.2 Ensure PASSWORD_LOCK_TIME Is Greater than or Equal to 1  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/3_2_PROFILE_PASSWORD_LOCK.log
        fi


echo "" >> ${FINALDIR}/3_2_PROFILE_PASSWORD_LOCK.log


echo ""



echo ""

echo "*************************** End of this module 3.2 check ***************************" >> ${FINALDIR}/3_2_PROFILE_PASSWORD_LOCK.log

echo "*********************************************************************************" >> ${FINALDIR}/3_2_PROFILE_PASSWORD_LOCK.log

}

REP_Fn_3_3_PROFILE_PASSWORD_LIFE(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/3_3_PROFILE_PASSWORD_LIFE.sql


checker=`cat ${REPSQLDIR}/sql_3_3_password_lock.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_3_3_password_lock.log  >> ${FINALDIR}/3_3_PROFILE_PASSWORD_LIFE.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/3_3_PROFILE_PASSWORD_LIFE.log
         echo " 3.3 Ensure PASSWORD_LIFE_TIME Is Less than or Equal to 90 - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 3.3 Ensure PASSWORD_LIFE_TIME Is Less than or Equal to 90 - AS PER CIS STANDARDS " >>  ${FINALDIR}/3_3_PROFILE_PASSWORD_LIFE.log
        else
        echo ""  >>  ${FINALDIR}/3_3_PROFILE_PASSWORD_LIFE.log

        echo " 3.3 Ensure PASSWORD_LIFE_TIME Is Less than or Equal to 90  - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
                echo " 3.3 Ensure PASSWORD_LIFE_TIME Is Less than or Equal to 90  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/3_3_PROFILE_PASSWORD_LIFE.log
        fi


echo "" >> ${FINALDIR}/3_3_PROFILE_PASSWORD_LIFE.log


echo ""



echo ""

echo "*************************** End of this module 3.3 check ***************************" >> ${FINALDIR}/3_3_PROFILE_PASSWORD_LIFE.log

echo "*********************************************************************************" >> ${FINALDIR}/3_3_PROFILE_PASSWORD_LIFE.log

}

REP_Fn_3_4_PROFILE_PASSWORD_REUSE(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/3_4_PROFILE_PASSWORD_REUSE.sql


checker=`cat ${REPSQLDIR}/sql_3_4_password_reusemax.log | grep -i "20" | wc -l`

cat ${REPSQLDIR}/sql_3_4_password_reusemax.log  >> ${FINALDIR}/3_4_PROFILE_PASSWORD_REUSE.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/3_4_PROFILE_PASSWORD_REUSE.log
         echo " 3.4 Ensure PASSWORD_REUSE_MAX Is Greater than or Equal to 20 - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 3.4 Ensure PASSWORD_REUSE_MAX Is Greater than or Equal to 20 - AS PER CIS STANDARDS " >>  ${FINALDIR}/3_4_PROFILE_PASSWORD_REUSE.log
        else
        echo ""  >>  ${FINALDIR}/3_4_PROFILE_PASSWORD_REUSE.log

        echo " 3.4 Ensure PASSWORD_REUSE_MAX Is Greater than or Equal to 20  - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
                echo " 3.4 Ensure PASSWORD_REUSE_MAX Is Greater than or Equal to 20  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/3_4_PROFILE_PASSWORD_REUSE.log
        fi


echo "" >> ${FINALDIR}/3_4_PROFILE_PASSWORD_REUSE.log


echo ""



echo ""

echo "*************************** End of this module 3.4 check ***************************" >> ${FINALDIR}/3_4_PROFILE_PASSWORD_REUSE.log

echo "*********************************************************************************" >> ${FINALDIR}/3_4_PROFILE_PASSWORD_REUSE.log

}

REP_Fn_3_5_PROFILE_PASSWORD_REUSE_TIME(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/3_5_PROFILE_PASSWORD_REUSE_TIME.sql


checker=`cat ${REPSQLDIR}/sql_3_5_password_reusetime.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_3_5_password_reusetime.log  >> ${FINALDIR}/3_5_PROFILE_PASSWORD_REUSE_TIME.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/3_5_PROFILE_PASSWORD_REUSE_TIME.log
         echo " 3.5 Ensure PASSWORD_REUSE_TIME Is Greater than or Equal to 365 - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 3.5 Ensure PASSWORD_REUSE_TIME Is Greater than or Equal to 365 - AS PER CIS STANDARDS " >>  ${FINALDIR}/3_5_PROFILE_PASSWORD_REUSE_TIME.log
        else
        echo ""  >>  ${FINALDIR}/3_5_PROFILE_PASSWORD_REUSE_TIME.log

        echo " 3.5 Ensure PASSWORD_REUSE_TIME Is Greater than or Equal to 365  - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
                echo " 3.5 Ensure PASSWORD_REUSE_TIME Is Greater than or Equal to 365  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/3_5_PROFILE_PASSWORD_REUSE_TIME.log
        fi


echo "" >> ${FINALDIR}/3_5_PROFILE_PASSWORD_REUSE_TIME.log


echo ""



echo ""

echo "*************************** End of this module 3.5 check ***************************" >> ${FINALDIR}/3_5_PROFILE_PASSWORD_REUSE_TIME.log

echo "*********************************************************************************" >> ${FINALDIR}/3_5_PROFILE_PASSWORD_REUSE_TIME.log

}

REP_Fn_3_6_PROFILE_PASSWORD_GRACE_TIME(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/3_6_PROFILE_PASSWORD_GRACE_TIME.sql


checker=`cat ${REPSQLDIR}/sql_3_6_password_gracetime.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_3_6_password_gracetime.log  >> ${FINALDIR}/3_6_PROFILE_PASSWORD_GRACE_TIME.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/3_6_PROFILE_PASSWORD_GRACE_TIME.log
         echo " 3.6 Ensure PASSWORD_GRACE_TIME Is Greater than or Equal to 5 - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 3.6 Ensure PASSWORD_GRACE_TIME Is Greater than or Equal to 5 - AS PER CIS STANDARDS " >>  ${FINALDIR}/3_6_PROFILE_PASSWORD_GRACE_TIME.log
        else
        echo ""  >>  ${FINALDIR}/3_6_PROFILE_PASSWORD_GRACE_TIME.log

        echo " 3.6 Ensure PASSWORD_GRACE_TIME Is Greater than or Equal to 5  - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
                echo " 3.6 Ensure PASSWORD_GRACE_TIME Is Greater than or Equal to 5  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/3_6_PROFILE_PASSWORD_GRACE_TIME.log
        fi


echo "" >> ${FINALDIR}/3_6_PROFILE_PASSWORD_GRACE_TIME.log


echo ""



echo ""

echo "*************************** End of this module 3.6 check ***************************" >> ${FINALDIR}/3_6_PROFILE_PASSWORD_GRACE_TIME.log

echo "*********************************************************************************" >> ${FINALDIR}/3_6_PROFILE_PASSWORD_GRACE_TIME.log

}

REP_Fn_3_7_DBA_USERS_PASSWORD(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/3_7_DBA_USERS_PASSWORD.sql


checker=`cat ${REPSQLDIR}/sql_3_7_dbauser_password.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_3_7_dbauser_password.log  >> ${FINALDIR}/3_7_DBA_USERS_PASSWORD.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/3_7_DBA_USERS_PASSWORD.log
         echo " 3.7 Ensure DBA_USERS.PASSWORD Is Not Set to EXTERNAL for Any User - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 3.7 Ensure DBA_USERS.PASSWORD Is Not Set to EXTERNAL for Any User - AS PER CIS STANDARDS " >>  ${FINALDIR}/3_7_DBA_USERS_PASSWORD.log
        else
        echo ""  >>  ${FINALDIR}/3_7_DBA_USERS_PASSWORD.log

        echo " 3.7 Ensure DBA_USERS.PASSWORD Is Not Set to EXTERNAL for Any User  - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
                echo " 3.7 Ensure DBA_USERS.PASSWORD Is Not Set to EXTERNAL for Any User  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/3_7_DBA_USERS_PASSWORD.log
        fi


echo "" >> ${FINALDIR}/3_7_DBA_USERS_PASSWORD.log


echo ""



echo ""

echo "*************************** End of this module 3.7 check ***************************" >> ${FINALDIR}/3_7_DBA_USERS_PASSWORD.log

echo "*********************************************************************************" >> ${FINALDIR}/3_7_DBA_USERS_PASSWORD.log

}

REP_Fn_3_8_PROFILE_PASSWORD_VERIFY(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/3_8_PROFILE_PASSWORD_VERIFY.sql


checker=`cat ${REPSQLDIR}/sql_3_8_password_verifyfunction.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_3_8_password_verifyfunction.log  >> ${FINALDIR}/3_8_PROFILE_PASSWORD_VERIFY.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/3_8_PROFILE_PASSWORD_VERIFY.log
         echo " 3.8 Ensure PASSWORD_VERIFY_FUNCTION Is Set for All Profiles  - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 3.8 Ensure PASSWORD_VERIFY_FUNCTION Is Set for All Profiles - AS PER CIS STANDARDS " >>  ${FINALDIR}/3_8_PROFILE_PASSWORD_VERIFY.log
        else
        echo ""  >>  ${FINALDIR}/3_8_PROFILE_PASSWORD_VERIFY.log

        echo " 3.8 Ensure PASSWORD_VERIFY_FUNCTION Is Set for All Profiles - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
                echo " 3.8 Ensure PASSWORD_VERIFY_FUNCTION Is Set for All Profiles  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/3_8_PROFILE_PASSWORD_VERIFY.log
        fi


echo "" >> ${FINALDIR}/3_8_PROFILE_PASSWORD_VERIFY.log


echo ""



echo ""

echo "*************************** End of this module 3.8 check ***************************" >> ${FINALDIR}/3_8_PROFILE_PASSWORD_VERIFY.log

echo "*********************************************************************************" >> ${FINALDIR}/3_8_PROFILE_PASSWORD_VERIFY.log

}

REP_Fn_3_9_PROFILE_SESSIONS_PER_USER(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/3_9_PROFILE_SESSIONS_PER_USER.sql


checker=`cat ${REPSQLDIR}/sql_3_9_sessionsper_user.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_3_9_sessionsper_user.log  >> ${FINALDIR}/3_9_PROFILE_SESSIONS_PER_USER.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/3_9_PROFILE_SESSIONS_PER_USER.log
         echo " 3.9 Ensure SESSIONS_PER_USER Is Less than or Qual to 10 - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 3.9 Ensure SESSIONS_PER_USER Is Less than or Qual to 10 - AS PER CIS STANDARDS " >>  ${FINALDIR}/3_9_PROFILE_SESSIONS_PER_USER.log
        else
        echo ""  >>  ${FINALDIR}/3_9_PROFILE_SESSIONS_PER_USER.log

        echo " 3.9 Ensure SESSIONS_PER_USER Is Less than or Qual to 10  - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
                echo " 3.9 Ensure SESSIONS_PER_USER Is Less than or Qual to 10  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/3_9_PROFILE_SESSIONS_PER_USER.log
        fi


echo "" >> ${FINALDIR}/3_9_PROFILE_SESSIONS_PER_USER.log


echo ""



echo ""

echo "*************************** End of this module 3.9 check ***************************" >> ${FINALDIR}/3_9_PROFILE_SESSIONS_PER_USER.log

echo "*********************************************************************************" >> ${FINALDIR}/3_9_PROFILE_SESSIONS_PER_USER.log

}

REP_Fn_3_10_USERS_WITH_DEFAULT_PROFILE(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/3_10_USERS_WITH_DEFAULT_PROFILE.sql


checker=`cat ${REPSQLDIR}/sql_3_10_users_default_profile.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_3_10_users_default_profile.log  >> ${FINALDIR}/3_10_USERS_WITH_DEFAULT_PROFILE.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/3_10_USERS_WITH_DEFAULT_PROFILE.log
         echo " 3.10 Ensure No Users Are Assigned the DEFAULT Profile - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 3.10 Ensure No Users Are Assigned the DEFAULT Profile - AS PER CIS STANDARDS " >>  ${FINALDIR}/3_10_USERS_WITH_DEFAULT_PROFILE.log
        else
        echo ""  >>  ${FINALDIR}/3_10_USERS_WITH_DEFAULT_PROFILE.log

        echo " 3.10 Ensure No Users Are Assigned the DEFAULT Profile  - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
                echo " 3.10 Ensure No Users Are Assigned the DEFAULT Profile  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/3_10_USERS_WITH_DEFAULT_PROFILE.log
        fi


echo "" >> ${FINALDIR}/3_10_USERS_WITH_DEFAULT_PROFILE.log


echo ""



echo ""

echo "*************************** End of this module 3.10 check ***************************" >> ${FINALDIR}/3_10_USERS_WITH_DEFAULT_PROFILE.log

echo "*********************************************************************************" >> ${FINALDIR}/3_10_USERS_WITH_DEFAULT_PROFILE.log

}

######################### SECTION 3 ENDS HERE #########################

REP_Fn_4_1_1_PRIVILEGE_PACKAGES_OBJECTS(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/4_1_1_PRIVILEGE_PACKAGES_OBJECTS.sql


checker=`cat ${REPSQLDIR}/sql_4_1_1_privilege_package_object.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_4_1_1_privilege_package_object.log  >> ${FINALDIR}/4_1_1_PRIVILEGE_PACKAGES_OBJECTS.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/4_1_1_PRIVILEGE_PACKAGES_OBJECTS.log
         echo " 4.1.1 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_ADVISOR - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 4.1.1 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_ADVISOR - AS PER CIS STANDARDS " >>  ${FINALDIR}/4_1_1_PRIVILEGE_PACKAGES_OBJECTS.log
        else
        echo ""  >>  ${FINALDIR}/4_1_1_PRIVILEGE_PACKAGES_OBJECTS.log

        echo " 4.1.1 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_ADVISOR  - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
                echo " 4.1.1 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_ADVISOR  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/4_1_1_PRIVILEGE_PACKAGES_OBJECTS.log
        fi


echo "" >> ${FINALDIR}/4_1_1_PRIVILEGE_PACKAGES_OBJECTS.log


echo ""



echo ""

echo "*************************** End of this module 4.1.1 check ***************************" >> ${FINALDIR}/4_1_1_PRIVILEGE_PACKAGES_OBJECTS.log

echo "*********************************************************************************" >> ${FINALDIR}/4_1_1_PRIVILEGE_PACKAGES_OBJECTS.log

}

REP_Fn_4_1_2_DBMS_CRYPTO(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/4_1_2_DBMS_CRYPTO.sql


checker=`cat ${REPSQLDIR}/sql_4_1_2_DBMS_CRYPTO.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_4_1_2_DBMS_CRYPTO.log  >> ${FINALDIR}/4_1_2_DBMS_CRYPTO.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/4_1_2_DBMS_CRYPTO.log
         echo " 4.1.2 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_CRYPTO - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 4.1.2 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_CRYPTO - AS PER CIS STANDARDS " >>  ${FINALDIR}/4_1_2_DBMS_CRYPTO.log
        else
        echo ""  >>  ${FINALDIR}/4_1_2_DBMS_CRYPTO.log

        echo " 4.1.2 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_CRYPTO  - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
                echo " 4.1.2 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_CRYPTO  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/4_1_2_DBMS_CRYPTO.log
        fi


echo "" >> ${FINALDIR}/4_1_2_DBMS_CRYPTO.log


echo ""



echo ""

echo "*************************** End of this module 4.1.2 check ***************************" >> ${FINALDIR}/4_1_2_DBMS_CRYPTO.log

echo "*********************************************************************************" >> ${FINALDIR}/4_1_2_DBMS_CRYPTO.log

}

REP_Fn_4_1_3_DBMS_JAVA(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/4_1_3_DBMS_JAVA.sql


checker=`cat ${REPSQLDIR}/sql_4_1_3_DBMS_JAVA.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_4_1_3_DBMS_JAVA.log  >> ${FINALDIR}/4_1_3_DBMS_JAVA.log


if [ ${checker} == 0 ];
        then
        echo ""  >>  ${FINALDIR}/4_1_3_DBMS_JAVA.log
         echo " 4.1.3 Ensure EXECUTE Is not Revoked from PUBLIC on DBMS_JAVA - AS PER Doc ID 1165830.1 " >>  ${FINALDIR}/CIS_Success.log
            echo " 4.1.3 Ensure EXECUTE Is not Revoked from PUBLIC on DBMS_JAVA - AS PER Doc ID 1165830.1 " >>  ${FINALDIR}/4_1_3_DBMS_JAVA.log
        else
        echo ""  >>  ${FINALDIR}/4_1_3_DBMS_JAVA.log

        echo " 4.1.3 Ensure EXECUTE Is not Revoked from PUBLIC on DBMS_JAVA - AS PER Doc ID 1165830.1  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
                echo " 4.1.3 Ensure EXECUTE Is not Revoked from PUBLIC on DBMS_JAVA - AS PER Doc ID 1165830.1 .. Need Attention" >>  ${FINALDIR}/4_1_3_DBMS_JAVA.log
        fi


echo "" >> ${FINALDIR}/4_1_3_DBMS_JAVA.log


echo ""



echo ""

echo "*************************** End of this module 4.1.3 check ***************************" >> ${FINALDIR}/4_1_3_DBMS_JAVA.log

echo "*********************************************************************************" >> ${FINALDIR}/4_1_3_DBMS_JAVA.log

}

REP_Fn_4_1_4_DBMS_JAVA_TEST(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/4_1_4_DBMS_JAVA_TEST.sql


checker=`cat ${REPSQLDIR}/sql_4_1_4_DBMS_JAVA_TEST.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_4_1_4_DBMS_JAVA_TEST.log  >> ${FINALDIR}/4_1_4_DBMS_JAVA_TEST.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/4_1_4_DBMS_JAVA_TEST.log
         echo " 4.1.4 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_JAVA_TEST - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 4.1.4 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_JAVA_TEST - AS PER CIS STANDARDS " >>  ${FINALDIR}/4_1_4_DBMS_JAVA_TEST.log
        else
        echo ""  >>  ${FINALDIR}/4_1_4_DBMS_JAVA_TEST.log

        echo " 4.1.4 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_JAVA_TEST  - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
                echo " 4.1.4 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_JAVA_TEST  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/4_1_4_DBMS_JAVA_TEST.log
        fi


echo "" >> ${FINALDIR}/4_1_4_DBMS_JAVA_TEST.log


echo ""



echo ""

echo "*************************** End of this module 4.1.4 check ***************************" >> ${FINALDIR}/4_1_4_DBMS_JAVA_TEST.log

echo "*********************************************************************************" >> ${FINALDIR}/4_1_4_DBMS_JAVA_TEST.log

}

REP_Fn_4_1_5_DBMS_JOB(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/4_1_5_DBMS_JOB.sql


checker=`cat ${REPSQLDIR}/sql_4_1_5_DBMS_JOB.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_4_1_5_DBMS_JOB.log  >> ${FINALDIR}/4_1_5_DBMS_JOB.log


if [ ${checker} == 0 ];
        then
        echo ""  >>  ${FINALDIR}/4_1_5_DBMS_JOB.log
         echo " 4.1.5 Ensure EXECUTE Is not Revoked from PUBLIC on DBMS_LOB - AS PER Doc ID 1165830.1 " >>  ${FINALDIR}/CIS_Success.log
            echo " 4.1.5 Ensure EXECUTE Is not Revoked from PUBLIC on DBMS_LOB - AS PER Doc ID 1165830.1 " >>  ${FINALDIR}/4_1_5_DBMS_JOB.log
        else
        echo ""  >>  ${FINALDIR}/4_1_5_DBMS_JOB.log

        echo " 4.1.5 Ensure EXECUTE Is not Revoked from PUBLIC on DBMS_LOB - AS PER Doc ID 1165830.1  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
                echo " 4.1.5 Ensure EXECUTE Is not Revoked from PUBLIC on DBMS_LOB - AS PER Doc ID 1165830.1 .. Need Attention" >>  ${FINALDIR}/4_1_5_DBMS_JOB.log
        fi


echo "" >> ${FINALDIR}/4_1_5_DBMS_JOB.log


echo ""



echo ""

echo "*************************** End of this module 4.1.5 check ***************************" >> ${FINALDIR}/4_1_5_DBMS_JOB.log

echo "*********************************************************************************" >> ${FINALDIR}/4_1_5_DBMS_JOB.log

}

REP_Fn_4_1_6_DBMS_LDAP(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/4_1_6_DBMS_LDAP.sql


checker=`cat ${REPSQLDIR}/sql_4_1_6_DBMS_LDAP.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_4_1_6_DBMS_LDAP.log  >> ${FINALDIR}/4_1_6_DBMS_LDAP.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/4_1_6_DBMS_LDAP.log
         echo " 4.1.6 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_LDAP - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 4.1.6 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_LDAP - AS PER CIS STANDARDS " >>  ${FINALDIR}/4_1_6_DBMS_LDAP.log
        else
        echo ""  >>  ${FINALDIR}/4_1_6_DBMS_LDAP.log

        echo " 4.1.6 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_LDAP  - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
                echo " 4.1.6 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_LDAP  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/4_1_6_DBMS_LDAP.log
        fi


echo "" >> ${FINALDIR}/4_1_6_DBMS_LDAP.log


echo ""



echo ""

echo "*************************** End of this module 4.1.6 check ***************************" >> ${FINALDIR}/4_1_6_DBMS_LDAP.log

echo "*********************************************************************************" >> ${FINALDIR}/4_1_6_DBMS_LDAP.log

}

REP_Fn_4_1_7_DBMS_LOB(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/4_1_7_DBMS_LOB.sql


checker=`cat ${REPSQLDIR}/sql_4_1_7_DBMS_LOB.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_4_1_7_DBMS_LOB.log  >> ${FINALDIR}/4_1_7_DBMS_LOB.log


if [ ${checker} == 0 ];
        then
        echo ""  >>  ${FINALDIR}/4_1_7_DBMS_LOB.log
         echo " 4.1.7 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_LOB - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 4.1.7 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_LOB - AS PER CIS STANDARDS " >>  ${FINALDIR}/4_1_7_DBMS_LOB.log
        else
        echo ""  >>  ${FINALDIR}/4_1_7_DBMS_LOB.log

        echo " 4.1.7 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_LOB  - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
                echo " 4.1.7 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_LOB  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/4_1_7_DBMS_LOB.log
        fi


echo "" >> ${FINALDIR}/4_1_7_DBMS_LOB.log


echo ""



echo ""

echo "*************************** End of this module 4.1.7 check ***************************" >> ${FINALDIR}/4_1_7_DBMS_LOB.log

echo "*********************************************************************************" >> ${FINALDIR}/4_1_7_DBMS_LOB.log

}

REP_Fn_4_1_8_DBMS_OBFUSCATION_TOOLKIT(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/4_1_8_DBMS_OBFUSCATION_TOOLKIT.sql


checker=`cat ${REPSQLDIR}/sql_4_1_8_DBMS_OBFUSCATION_TOOLKIT.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_4_1_8_DBMS_OBFUSCATION_TOOLKIT.log  >> ${FINALDIR}/4_1_8_DBMS_OBFUSCATION_TOOLKIT.log


if [ ${checker} == 0 ];
        then
        echo ""  >>  ${FINALDIR}/4_1_8_DBMS_OBFUSCATION_TOOLKIT.log
         echo " 4.1.8 Ensure EXECUTE Is not Revoked from PUBLIC on DBMS_OBFUSCATION_TOOLKIT - AS PER Doc ID 1165830.1 " >>  ${FINALDIR}/CIS_Success.log
            echo " 4.1.8 Ensure EXECUTE Is not Revoked from PUBLIC on DBMS_OBFUSCATION_TOOLKIT - AS PER Doc ID 1165830.1 " >>  ${FINALDIR}/4_1_8_DBMS_OBFUSCATION_TOOLKIT.log
        else
        echo ""  >>  ${FINALDIR}/4_1_8_DBMS_OBFUSCATION_TOOLKIT.log

        echo " 4.1.8 Ensure EXECUTE Is not Revoked from PUBLIC on DBMS_OBFUSCATION_TOOLKIT - AS PER Doc ID 1165830.1  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
                echo " 4.1.8 Ensure EXECUTE Is not Revoked from PUBLIC on DBMS_OBFUSCATION_TOOLKIT - AS PER Doc ID 1165830.1 .. Need Attention" >>  ${FINALDIR}/4_1_8_DBMS_OBFUSCATION_TOOLKIT.log
        fi


echo "" >> ${FINALDIR}/4_1_8_DBMS_OBFUSCATION_TOOLKIT.log


echo ""



echo ""

echo "*************************** End of this module 4.1.8 check ***************************" >> ${FINALDIR}/4_1_8_DBMS_OBFUSCATION_TOOLKIT.log

echo "*********************************************************************************" >> ${FINALDIR}/4_1_8_DBMS_OBFUSCATION_TOOLKIT.log

}

REP_Fn_4_1_9_DBMS_BACKUP_RESTORE(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/4_1_9_DBMS_BACKUP_RESTORE.sql


checker=`cat ${REPSQLDIR}/sql_4_1_9_DBMS_BACKUP_RESTORE.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_4_1_9_DBMS_BACKUP_RESTORE.log  >> ${FINALDIR}/4_1_9_DBMS_BACKUP_RESTORE.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/4_1_9_DBMS_BACKUP_RESTORE.log
         echo " 4.1.9 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_BACKUP_RESTORE - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 4.1.9 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_BACKUP_RESTORE - AS PER CIS STANDARDS " >>  ${FINALDIR}/4_1_9_DBMS_BACKUP_RESTORE.log
        else
        echo ""  >>  ${FINALDIR}/4_1_9_DBMS_BACKUP_RESTORE.log

        echo " 4.1.9 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_BACKUP_RESTORE  - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
                echo " 4.1.9 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_BACKUP_RESTORE  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/4_1_9_DBMS_BACKUP_RESTORE.log
        fi


echo "" >> ${FINALDIR}/4_1_9_DBMS_BACKUP_RESTORE.log


echo ""



echo ""

echo "*************************** End of this module 4.1.9 check ***************************" >> ${FINALDIR}/4_1_9_DBMS_BACKUP_RESTORE.log

echo "*********************************************************************************" >> ${FINALDIR}/4_1_9_DBMS_BACKUP_RESTORE.log

}

REP_Fn_4_1_10_DBMS_SCHEDULER(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/4_1_10_DBMS_SCHEDULER.sql


checker=`cat ${REPSQLDIR}/sql_4_1_10_DBMS_SCHEDULER.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_4_1_10_DBMS_SCHEDULER.log  >> ${FINALDIR}/4_1_10_DBMS_SCHEDULER.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/4_1_10_DBMS_SCHEDULER.log
         echo " 4.1.10 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_SCHEDULER - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 4.1.10 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_SCHEDULER - AS PER CIS STANDARDS " >>  ${FINALDIR}/4_1_10_DBMS_SCHEDULER.log
        else
        echo ""  >>  ${FINALDIR}/4_1_10_DBMS_SCHEDULER.log

        echo " 4.1.10 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_SCHEDULER  - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
                echo " 4.1.10 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_SCHEDULER  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/4_1_10_DBMS_SCHEDULER.log
        fi


echo "" >> ${FINALDIR}/4_1_10_DBMS_SCHEDULER.log


echo ""



echo ""

echo "*************************** End of this module 4.1.10 check ***************************" >> ${FINALDIR}/4_1_10_DBMS_SCHEDULER.log

echo "*********************************************************************************" >> ${FINALDIR}/4_1_10_DBMS_SCHEDULER.log

}

REP_Fn_4_1_11_DBMS_SQL(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/4_1_11_DBMS_SQL.sql


checker=`cat ${REPSQLDIR}/sql_4_1_11_DBMS_SQL.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_4_1_11_DBMS_SQL.log  >> ${FINALDIR}/4_1_11_DBMS_SQL.log


if [ ${checker} == 0 ];
        then
        echo ""  >>  ${FINALDIR}/4_1_11_DBMS_SQL.log
         echo " 4.1.11 Ensure EXECUTE Is not Revoked from PUBLIC on DBMS_SQL - AS PER Doc ID 1165830.1 " >>  ${FINALDIR}/CIS_Success.log
            echo " 4.1.11 Ensure EXECUTE Is not Revoked from PUBLIC on DBMS_SQL - AS PER Doc ID 1165830.1 " >>  ${FINALDIR}/4_1_11_DBMS_SQL.log
        else
        echo ""  >>  ${FINALDIR}/4_1_11_DBMS_SQL.log

        echo " 4.1.11 Ensure EXECUTE Is not Revoked from PUBLIC on DBMS_SQL - AS PER Doc ID 1165830.1  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
                echo " 4.1.11 Ensure EXECUTE Is not Revoked from PUBLIC on DBMS_SQL - AS PER Doc ID 1165830.1 .. Need Attention" >>  ${FINALDIR}/4_1_11_DBMS_SQL.log
        fi


echo "" >> ${FINALDIR}/4_1_11_DBMS_SQL.log


echo ""



echo ""

echo "*************************** End of this module 4.1.11 check ***************************" >> ${FINALDIR}/4_1_11_DBMS_SQL.log

echo "*********************************************************************************" >> ${FINALDIR}/4_1_11_DBMS_SQL.log

}

REP_Fn_4_1_12_DBMS_XMLGEN(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/4_1_12_DBMS_XMLGEN.sql


checker=`cat ${REPSQLDIR}/sql_4_1_12_DBMS_XMLGEN.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_4_1_12_DBMS_XMLGEN.log  >> ${FINALDIR}/4_1_12_DBMS_XMLGEN.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/4_1_12_DBMS_XMLGEN.log
         echo " 4.1.12 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_XMLGEN - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 4.1.12 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_XMLGEN - AS PER CIS STANDARDS " >>  ${FINALDIR}/4_1_12_DBMS_XMLGEN.log
        else
        echo ""  >>  ${FINALDIR}/4_1_12_DBMS_XMLGEN.log

        echo " 4.1.12 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_XMLGEN  - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
                echo " 4.1.12 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_XMLGEN  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/4_1_12_DBMS_XMLGEN.log
        fi


echo "" >> ${FINALDIR}/4_1_12_DBMS_XMLGEN.log


echo ""



echo ""

echo "*************************** End of this module 4.1.12 check ***************************" >> ${FINALDIR}/4_1_12_DBMS_XMLGEN.log

echo "*********************************************************************************" >> ${FINALDIR}/4_1_12_DBMS_XMLGEN.log

}

REP_Fn_4_1_13_DBMS_XMLQUERY(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/4_1_13_DBMS_XMLQUERY.sql


checker=`cat ${REPSQLDIR}/sql_4_1_13_DBMS_XMLQUERY.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_4_1_13_DBMS_XMLQUERY.log  >> ${FINALDIR}/4_1_13_DBMS_XMLQUERY.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/4_1_13_DBMS_XMLQUERY.log
         echo " 4.1.13 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_XMLQUERY - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 4.1.13 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_XMLQUERY - AS PER CIS STANDARDS " >>  ${FINALDIR}/4_1_13_DBMS_XMLQUERY.log
        else
        echo ""  >>  ${FINALDIR}/4_1_13_DBMS_XMLQUERY.log

        echo " 4.1.13 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_XMLQUERY  - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
                echo " 4.1.13 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_XMLQUERY  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/4_1_13_DBMS_XMLQUERY.log
        fi


echo "" >> ${FINALDIR}/4_1_13_DBMS_XMLQUERY.log


echo ""



echo ""

echo "*************************** End of this module 4.1.13 check ***************************" >> ${FINALDIR}/4_1_13_DBMS_XMLQUERY.log

echo "*********************************************************************************" >> ${FINALDIR}/4_1_13_DBMS_XMLQUERY.log

}

REP_Fn_4_1_14_UTL_FILE(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/4_1_14_UTL_FILE.sql


checker=`cat ${REPSQLDIR}/sql_4_1_14_UTL_FILE.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_4_1_14_UTL_FILE.log  >> ${FINALDIR}/4_1_14_UTL_FILE.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/4_1_14_UTL_FILE.log
         echo " 4.1.14 Ensure EXECUTE Is Revoked from PUBLIC on UTL_FILE - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 4.1.14 Ensure EXECUTE Is Revoked from PUBLIC on UTL_FILE - AS PER CIS STANDARDS " >>  ${FINALDIR}/4_1_14_UTL_FILE.log
        else
        echo ""  >>  ${FINALDIR}/4_1_14_UTL_FILE.log

        echo " 4.1.14 Ensure EXECUTE Is Revoked from PUBLIC on UTL_FILE  - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
                echo " 4.1.14 Ensure EXECUTE Is Revoked from PUBLIC on UTL_FILE  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/4_1_14_UTL_FILE.log
        fi


echo "" >> ${FINALDIR}/4_1_14_UTL_FILE.log


echo ""



echo ""

echo "*************************** End of this module 4.1.14 check ***************************" >> ${FINALDIR}/4_1_14_UTL_FILE.log

echo "*********************************************************************************" >> ${FINALDIR}/4_1_14_UTL_FILE.log

}

REP_Fn_4_1_15_UTL_INADDR(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/4_1_15_UTL_INADDR.sql


checker=`cat ${REPSQLDIR}/sql_4_1_15_UTL_INADDR.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_4_1_15_UTL_INADDR.log  >> ${FINALDIR}/4_1_15_UTL_INADDR.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/4_1_15_UTL_INADDR.log
         echo " 4.1.15 Ensure EXECUTE Is Revoked from PUBLIC on UTL_INADDR - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 4.1.15 Ensure EXECUTE Is Revoked from PUBLIC on UTL_INADDR - AS PER CIS STANDARDS " >>  ${FINALDIR}/4_1_15_UTL_INADDR.log
        else
        echo ""  >>  ${FINALDIR}/4_1_15_UTL_INADDR.log

        echo " 4.1.15 Ensure EXECUTE Is Revoked from PUBLIC on UTL_INADDR  - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
                echo " 4.1.15 Ensure EXECUTE Is Revoked from PUBLIC on UTL_INADDR  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/4_1_15_UTL_INADDR.log
        fi


echo "" >> ${FINALDIR}/4_1_15_UTL_INADDR.log


echo ""



echo ""

echo "*************************** End of this module 4.1.15 check ***************************" >> ${FINALDIR}/4_1_15_UTL_INADDR.log

echo "*********************************************************************************" >> ${FINALDIR}/4_1_15_UTL_INADDR.log

}

REP_Fn_4_1_16_UTL_TCP(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/4_1_16_UTL_TCP.sql


checker=`cat ${REPSQLDIR}/sql_4_1_16_UTL_TCP.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_4_1_16_UTL_TCP.log  >> ${FINALDIR}/4_1_16_UTL_TCP.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/4_1_16_UTL_TCP.log
         echo " 4.1.16 Ensure EXECUTE Is Revoked from PUBLIC on UTL_TCP - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 4.1.16 Ensure EXECUTE Is Revoked from PUBLIC on UTL_TCP - AS PER CIS STANDARDS " >>  ${FINALDIR}/4_1_16_UTL_TCP.log
        else
        echo ""  >>  ${FINALDIR}/4_1_16_UTL_TCP.log

        echo " 4.1.16 Ensure EXECUTE Is Revoked from PUBLIC on UTL_TCP  - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
                echo " 4.1.16 Ensure EXECUTE Is Revoked from PUBLIC on UTL_TCP  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/4_1_16_UTL_TCP.log
        fi


echo "" >> ${FINALDIR}/4_1_16_UTL_TCP.log


echo ""



echo ""

echo "*************************** End of this module 4.1.16 check ***************************" >> ${FINALDIR}/4_1_16_UTL_TCP.log

echo "*********************************************************************************" >> ${FINALDIR}/4_1_16_UTL_TCP.log

}

REP_Fn_4_1_17_UTL_MAIL(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/4_1_17_UTL_MAIL.sql


checker=`cat ${REPSQLDIR}/sql_4_1_17_UTL_MAIL.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_4_1_17_UTL_MAIL.log  >> ${FINALDIR}/4_1_17_UTL_MAIL.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/4_1_17_UTL_MAIL.log
         echo " 4.1.17 Ensure EXECUTE Is Revoked from PUBLIC on UTL_MAIL - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 4.1.17 Ensure EXECUTE Is Revoked from PUBLIC on UTL_MAIL - AS PER CIS STANDARDS " >>  ${FINALDIR}/4_1_17_UTL_MAIL.log
        else
        echo ""  >>  ${FINALDIR}/4_1_17_UTL_MAIL.log

        echo " 4.1.17 Ensure EXECUTE Is Revoked from PUBLIC on UTL_MAIL  - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
                echo " 4.1.17 Ensure EXECUTE Is Revoked from PUBLIC on UTL_MAIL  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/4_1_17_UTL_MAIL.log
        fi


echo "" >> ${FINALDIR}/4_1_17_UTL_MAIL.log


echo ""



echo ""

echo "*************************** End of this module 4.1.17 check ***************************" >> ${FINALDIR}/4_1_17_UTL_MAIL.log

echo "*********************************************************************************" >> ${FINALDIR}/4_1_17_UTL_MAIL.log

}

REP_Fn_4_1_18_UTL_SMTP(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/4_1_18_UTL_SMTP.sql


checker=`cat ${REPSQLDIR}/sql_4_1_18_UTL_SMTP.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_4_1_18_UTL_SMTP.log  >> ${FINALDIR}/4_1_18_UTL_SMTP.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/4_1_18_UTL_SMTP.log
         echo " 4.1.18 Ensure EXECUTE Is Revoked from PUBLIC on UTL_SMTP - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 4.1.18 Ensure EXECUTE Is Revoked from PUBLIC on UTL_SMTP - AS PER CIS STANDARDS " >>  ${FINALDIR}/4_1_18_UTL_SMTP.log
        else
        echo ""  >>  ${FINALDIR}/4_1_18_UTL_SMTP.log

        echo " 4.1.18 Ensure EXECUTE Is Revoked from PUBLIC on UTL_SMTP  - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
                echo " 4.1.18 Ensure EXECUTE Is Revoked from PUBLIC on UTL_SMTP  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/4_1_18_UTL_SMTP.log
        fi


echo "" >> ${FINALDIR}/4_1_18_UTL_SMTP.log


echo ""



echo ""

echo "*************************** End of this module 4.1.18 check ***************************" >> ${FINALDIR}/4_1_18_UTL_SMTP.log

echo "*********************************************************************************" >> ${FINALDIR}/4_1_18_UTL_SMTP.log

}

REP_Fn_4_1_19_UTL_DBWS(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/4_1_19_UTL_DBWS.sql


checker=`cat ${REPSQLDIR}/sql_4_1_19_UTL_DBWS.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_4_1_19_UTL_DBWS.log  >> ${FINALDIR}/4_1_19_UTL_DBWS.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/4_1_19_UTL_DBWS.log
         echo " 4.1.19 Ensure EXECUTE Is Revoked from PUBLIC on UTL_DBWS - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 4.1.19 Ensure EXECUTE Is Revoked from PUBLIC on UTL_DBWS - AS PER CIS STANDARDS " >>  ${FINALDIR}/4_1_19_UTL_DBWS.log
        else
        echo ""  >>  ${FINALDIR}/4_1_19_UTL_DBWS.log

        echo " 4.1.19 Ensure EXECUTE Is Revoked from PUBLIC on UTL_DBWS  - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
                echo " 4.1.19 Ensure EXECUTE Is Revoked from PUBLIC on UTL_DBWS  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/4_1_19_UTL_DBWS.log
        fi


echo "" >> ${FINALDIR}/4_1_19_UTL_DBWS.log


echo ""



echo ""

echo "*************************** End of this module 4.1.19 check ***************************" >> ${FINALDIR}/4_1_19_UTL_DBWS.log

echo "*********************************************************************************" >> ${FINALDIR}/4_1_19_UTL_DBWS.log

}

REP_Fn_4_1_20_UTL_ORAMTS(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/4_1_20_UTL_ORAMTS.sql


checker=`cat ${REPSQLDIR}/sql_4_1_20_UTL_ORAMTS.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_4_1_20_UTL_ORAMTS.log  >> ${FINALDIR}/4_1_20_UTL_ORAMTS.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/4_1_20_UTL_ORAMTS.log
         echo " 4.1.20 Ensure EXECUTE Is Revoked from PUBLIC on UTL_ORAMTS - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 4.1.20 Ensure EXECUTE Is Revoked from PUBLIC on UTL_ORAMTS - AS PER CIS STANDARDS " >>  ${FINALDIR}/4_1_20_UTL_ORAMTS.log
        else
        echo ""  >>  ${FINALDIR}/4_1_20_UTL_ORAMTS.log

        echo " 4.1.20 Ensure EXECUTE Is Revoked from PUBLIC on UTL_ORAMTS  - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
                echo " 4.1.20 Ensure EXECUTE Is Revoked from PUBLIC on UTL_ORAMTS  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/4_1_20_UTL_ORAMTS.log
        fi


echo "" >> ${FINALDIR}/4_1_20_UTL_ORAMTS.log


echo ""



echo ""

echo "*************************** End of this module 4.1.20 check ***************************" >> ${FINALDIR}/4_1_20_UTL_ORAMTS.log

echo "*********************************************************************************" >> ${FINALDIR}/4_1_20_UTL_ORAMTS.log

}

REP_Fn_4_1_21_UTL_HTTP(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/4_1_21_UTL_HTTP.sql


checker=`cat ${REPSQLDIR}/sql_4_1_21_UTL_HTTP.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_4_1_21_UTL_HTTP.log  >> ${FINALDIR}/4_1_21_UTL_HTTP.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/4_1_21_UTL_HTTP.log
         echo " 4.1.21 Ensure EXECUTE Is Revoked from PUBLIC on UTL_HTTP - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 4.1.21 Ensure EXECUTE Is Revoked from PUBLIC on UTL_HTTP - AS PER CIS STANDARDS " >>  ${FINALDIR}/4_1_21_UTL_HTTP.log
        else
        echo ""  >>  ${FINALDIR}/4_1_21_UTL_HTTP.log

        echo " 4.1.21 Ensure EXECUTE Is Revoked from PUBLIC on UTL_HTTP  - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
                echo " 4.1.21 Ensure EXECUTE Is Revoked from PUBLIC on UTL_HTTP  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/4_1_21_UTL_HTTP.log
        fi


echo "" >> ${FINALDIR}/4_1_21_UTL_HTTP.log


echo ""



echo ""

echo "*************************** End of this module 4.1.21 check ***************************" >> ${FINALDIR}/4_1_21_UTL_HTTP.log

echo "*********************************************************************************" >> ${FINALDIR}/4_1_21_UTL_HTTP.log

}

REP_Fn_4_1_22_HTTPURITYPE(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/4_1_22_HTTPURITYPE.sql


checker=`cat ${REPSQLDIR}/sql_4_1_22_HTTPURITYPE.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_4_1_22_HTTPURITYPE.log  >> ${FINALDIR}/4_1_22_HTTPURITYPE.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/4_1_22_HTTPURITYPE.log
         echo " 4.1.22 Ensure EXECUTE Is Revoked from PUBLIC on HTTPURITYPE - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 4.1.22 Ensure EXECUTE Is Revoked from PUBLIC on HTTPURITYPE - AS PER CIS STANDARDS " >>  ${FINALDIR}/4_1_22_HTTPURITYPE.log
        else
        echo ""  >>  ${FINALDIR}/4_1_22_HTTPURITYPE.log

        echo " 4.1.22 Ensure EXECUTE Is Revoked from PUBLIC on HTTPURITYPE  - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
                echo " 4.1.22 Ensure EXECUTE Is Revoked from PUBLIC on HTTPURITYPE  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/4_1_22_HTTPURITYPE.log
        fi


echo "" >> ${FINALDIR}/4_1_22_HTTPURITYPE.log


echo ""



echo ""

echo "*************************** End of this module 4.1.22 check ***************************" >> ${FINALDIR}/4_1_22_HTTPURITYPE.log

echo "*********************************************************************************" >> ${FINALDIR}/4_1_22_HTTPURITYPE.log

}

######################### SECTION 4.1 ENDS HERE #########################


REP_Fn_4_2_1_DBMS_SYS_SQL(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/4_2_1_DBMS_SYS_SQL.sql


checker=`cat ${REPSQLDIR}/sql_4_2_1_DBMS_SYS_SQL.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_4_2_1_DBMS_SYS_SQL.log  >> ${FINALDIR}/4_2_1_DBMS_SYS_SQL.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/4_2_1_DBMS_SYS_SQL.log
         echo " 4.2.1 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_SYS_SQL - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 4.2.1 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_SYS_SQL - AS PER CIS STANDARDS " >>  ${FINALDIR}/4_2_1_DBMS_SYS_SQL.log
        else
        echo ""  >>  ${FINALDIR}/4_2_1_DBMS_SYS_SQL.log

        echo " 4.2.1 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_SYS_SQL  - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
                echo " 4.2.1 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_SYS_SQL  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/4_2_1_DBMS_SYS_SQL.log
        fi


echo "" >> ${FINALDIR}/4_2_1_DBMS_SYS_SQL.log


echo ""



echo ""

echo "*************************** End of this module 4.2.1 check ***************************" >> ${FINALDIR}/4_2_1_DBMS_SYS_SQL.log

echo "*********************************************************************************" >> ${FINALDIR}/4_2_1_DBMS_SYS_SQL.log

}

REP_Fn_4_2_2_DBMS_BACKUP_RESTORE(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/4_2_2_DBMS_BACKUP_RESTORE.sql


checker=`cat ${REPSQLDIR}/sql_4_2_2_DBMS_BACKUP_RESTORE.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_4_2_2_DBMS_BACKUP_RESTORE.log  >> ${FINALDIR}/4_2_2_DBMS_BACKUP_RESTORE.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/4_2_2_DBMS_BACKUP_RESTORE.log
         echo " 4.2.2 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_BACKUP_RESTORE - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 4.2.2 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_BACKUP_RESTORE - AS PER CIS STANDARDS " >>  ${FINALDIR}/4_2_2_DBMS_BACKUP_RESTORE.log
        else
        echo ""  >>  ${FINALDIR}/4_2_2_DBMS_BACKUP_RESTORE.log

        echo " 4.2.2 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_BACKUP_RESTORE  - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
                echo " 4.2.2 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_BACKUP_RESTORE  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/4_2_2_DBMS_BACKUP_RESTORE.log
        fi


echo "" >> ${FINALDIR}/4_2_2_DBMS_BACKUP_RESTORE.log


echo ""



echo ""

echo "*************************** End of this module 4.2.2 check ***************************" >> ${FINALDIR}/4_2_2_DBMS_BACKUP_RESTORE.log

echo "*********************************************************************************" >> ${FINALDIR}/4_2_2_DBMS_BACKUP_RESTORE.log

}

REP_Fn_4_2_3_DBMS_AQADM_SYSCALLS(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/4_2_3_DBMS_AQADM_SYSCALLS.sql


checker=`cat ${REPSQLDIR}/sql_4_2_3_DBMS_AQADM_SYSCALLS.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_4_2_3_DBMS_AQADM_SYSCALLS.log  >> ${FINALDIR}/4_2_3_DBMS_AQADM_SYSCALLS.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/4_2_3_DBMS_AQADM_SYSCALLS.log
         echo " 4.2.3 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_AQADM_SYSCALLS - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 4.2.3 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_AQADM_SYSCALLS - AS PER CIS STANDARDS " >>  ${FINALDIR}/4_2_3_DBMS_AQADM_SYSCALLS.log
        else
        echo ""  >>  ${FINALDIR}/4_2_3_DBMS_AQADM_SYSCALLS.log

        echo " 4.2.3 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_AQADM_SYSCALLS  - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
            echo " 4.2.3 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_AQADM_SYSCALLS  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/4_2_3_DBMS_AQADM_SYSCALLS.log
        fi


echo "" >> ${FINALDIR}/4_2_3_DBMS_AQADM_SYSCALLS.log


echo ""



echo ""

echo "*************************** End of this module 4.2.3 check ***************************" >> ${FINALDIR}/4_2_3_DBMS_AQADM_SYSCALLS.log

echo "*********************************************************************************" >> ${FINALDIR}/4_2_3_DBMS_AQADM_SYSCALLS.log

}

REP_Fn_4_2_4_DBMS_REPACT_SQL_UTL(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/4_2_4_DBMS_REPACT_SQL_UTL.sql


checker=`cat ${REPSQLDIR}/sql_4_2_4_DBMS_REPACT_SQL_UTL.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_4_2_4_DBMS_REPACT_SQL_UTL.log  >> ${FINALDIR}/4_2_4_DBMS_REPACT_SQL_UTL.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/4_2_4_DBMS_REPACT_SQL_UTL.log
         echo " 4.2.4 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_REPACT_SQL_UTL - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 4.2.4 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_REPACT_SQL_UTL - AS PER CIS STANDARDS " >>  ${FINALDIR}/4_2_4_DBMS_REPACT_SQL_UTL.log
        else
        echo ""  >>  ${FINALDIR}/4_2_4_DBMS_REPACT_SQL_UTL.log

        echo " 4.2.4 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_REPACT_SQL_UTL  - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
            echo " 4.2.4 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_REPACT_SQL_UTL  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/4_2_4_DBMS_REPACT_SQL_UTL.log
        fi


echo "" >> ${FINALDIR}/4_2_4_DBMS_REPACT_SQL_UTL.log


echo ""



echo ""

echo "*************************** End of this module 4.2.4 check ***************************" >> ${FINALDIR}/4_2_4_DBMS_REPACT_SQL_UTL.log

echo "*********************************************************************************" >> ${FINALDIR}/4_2_4_DBMS_REPACT_SQL_UTL.log

}

REP_Fn_4_2_5_INITJVMAUX(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/4_2_5_INITJVMAUX.sql


checker=`cat ${REPSQLDIR}/sql_4_2_5_INITJVMAUX.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_4_2_5_INITJVMAUX.log  >> ${FINALDIR}/4_2_5_INITJVMAUX.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/4_2_5_INITJVMAUX.log
         echo " 4.2.5 Ensure EXECUTE Is Revoked from PUBLIC on INITJVMAUX - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 4.2.5 Ensure EXECUTE Is Revoked from PUBLIC on INITJVMAUX - AS PER CIS STANDARDS " >>  ${FINALDIR}/4_2_5_INITJVMAUX.log
        else
        echo ""  >>  ${FINALDIR}/4_2_5_INITJVMAUX.log

        echo " 4.2.5 Ensure EXECUTE Is Revoked from PUBLIC on INITJVMAUX  - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
            echo " 4.2.5 Ensure EXECUTE Is Revoked from PUBLIC on INITJVMAUX  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/4_2_5_INITJVMAUX.log
        fi


echo "" >> ${FINALDIR}/4_2_5_INITJVMAUX.log


echo ""



echo ""

echo "*************************** End of this module 4.2.5 check ***************************" >> ${FINALDIR}/4_2_5_INITJVMAUX.log

echo "*********************************************************************************" >> ${FINALDIR}/4_2_5_INITJVMAUX.log

}

REP_Fn_4_2_6_DBMS_STREAMS_ADM_UTL(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/4_2_6_DBMS_STREAMS_ADM_UTL.sql


checker=`cat ${REPSQLDIR}/sql_4_2_6_DBMS_STREAMS_ADM_UTL.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_4_2_6_DBMS_STREAMS_ADM_UTL.log  >> ${FINALDIR}/4_2_6_DBMS_STREAMS_ADM_UTL.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/4_2_6_DBMS_STREAMS_ADM_UTL.log
         echo " 4.2.6 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_STREAMS_ADM_UTL - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 4.2.6 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_STREAMS_ADM_UTL - AS PER CIS STANDARDS " >>  ${FINALDIR}/4_2_6_DBMS_STREAMS_ADM_UTL.log
        else
        echo ""  >>  ${FINALDIR}/4_2_6_DBMS_STREAMS_ADM_UTL.log

        echo " 4.2.6 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_STREAMS_ADM_UTL  - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
            echo " 4.2.6 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_STREAMS_ADM_UTL  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/4_2_6_DBMS_STREAMS_ADM_UTL.log
        fi


echo "" >> ${FINALDIR}/4_2_6_DBMS_STREAMS_ADM_UTL.log


echo ""



echo ""

echo "*************************** End of this module 4.2.6 check ***************************" >> ${FINALDIR}/4_2_6_DBMS_STREAMS_ADM_UTL.log

echo "*********************************************************************************" >> ${FINALDIR}/4_2_6_DBMS_STREAMS_ADM_UTL.log

}

REP_Fn_4_2_7_DBMS_AQADM_SYS(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/4_2_7_DBMS_AQADM_SYS.sql


checker=`cat ${REPSQLDIR}/sql_4_2_7_DBMS_AQADM_SYS.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_4_2_7_DBMS_AQADM_SYS.log  >> ${FINALDIR}/4_2_7_DBMS_AQADM_SYS.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/4_2_7_DBMS_AQADM_SYS.log
         echo " 4.2.7 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_AQADM_SYS - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 4.2.7 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_AQADM_SYS - AS PER CIS STANDARDS " >>  ${FINALDIR}/4_2_7_DBMS_AQADM_SYS.log
        else
        echo ""  >>  ${FINALDIR}/4_2_7_DBMS_AQADM_SYS.log

        echo " 4.2.7 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_AQADM_SYS  - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
            echo " 4.2.7 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_AQADM_SYS  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/4_2_7_DBMS_AQADM_SYS.log
        fi


echo "" >> ${FINALDIR}/4_2_7_DBMS_AQADM_SYS.log


echo ""



echo ""

echo "*************************** End of this module 4.2.7 check ***************************" >> ${FINALDIR}/4_2_7_DBMS_AQADM_SYS.log

echo "*********************************************************************************" >> ${FINALDIR}/4_2_7_DBMS_AQADM_SYS.log

}

REP_Fn_4_2_8_DBMS_STREAMS_RPC(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/4_2_8_DBMS_STREAMS_RPC.sql


checker=`cat ${REPSQLDIR}/sql_4_2_8_DBMS_STREAMS_RPC.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_4_2_8_DBMS_STREAMS_RPC.log  >> ${FINALDIR}/4_2_8_DBMS_STREAMS_RPC.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/4_2_8_DBMS_STREAMS_RPC.log
         echo " 4.2.8 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_STREAMS_RPC - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 4.2.8 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_STREAMS_RPC - AS PER CIS STANDARDS " >>  ${FINALDIR}/4_2_8_DBMS_STREAMS_RPC.log
        else
        echo ""  >>  ${FINALDIR}/4_2_8_DBMS_STREAMS_RPC.log

        echo " 4.2.8 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_STREAMS_RPC  - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
            echo " 4.2.8 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_STREAMS_RPC  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/4_2_8_DBMS_STREAMS_RPC.log
        fi


echo "" >> ${FINALDIR}/4_2_8_DBMS_STREAMS_RPC.log


echo ""



echo ""

echo "*************************** End of this module 4.2.8 check ***************************" >> ${FINALDIR}/4_2_8_DBMS_STREAMS_RPC.log

echo "*********************************************************************************" >> ${FINALDIR}/4_2_8_DBMS_STREAMS_RPC.log

}

REP_Fn_4_2_9_DBMS_PRVTAQIM(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/4_2_9_DBMS_PRVTAQIM.sql


checker=`cat ${REPSQLDIR}/sql_4_2_9_DBMS_PRVTAQIM.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_4_2_9_DBMS_PRVTAQIM.log  >> ${FINALDIR}/4_2_9_DBMS_PRVTAQIM.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/4_2_9_DBMS_PRVTAQIM.log
         echo " 4.2.9 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_PRVTAQIM - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 4.2.9 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_PRVTAQIM - AS PER CIS STANDARDS " >>  ${FINALDIR}/4_2_9_DBMS_PRVTAQIM.log
        else
        echo ""  >>  ${FINALDIR}/4_2_9_DBMS_PRVTAQIM.log

        echo " 4.2.9 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_PRVTAQIM  - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
            echo " 4.2.9 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_PRVTAQIM  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/4_2_9_DBMS_PRVTAQIM.log
        fi


echo "" >> ${FINALDIR}/4_2_9_DBMS_PRVTAQIM.log


echo ""



echo ""

echo "*************************** End of this module 4.2.9 check ***************************" >> ${FINALDIR}/4_2_9_DBMS_PRVTAQIM.log

echo "*********************************************************************************" >> ${FINALDIR}/4_2_9_DBMS_PRVTAQIM.log

}

REP_Fn_4_2_10_LTADM(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/4_2_10_LTADM.sql


checker=`cat ${REPSQLDIR}/sql_4_2_10_LTADM.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_4_2_10_LTADM.log  >> ${FINALDIR}/4_2_10_LTADM.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/4_2_10_LTADM.log
         echo " 4.2.10 Ensure EXECUTE Is Revoked from PUBLIC on LTADM - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 4.2.10 Ensure EXECUTE Is Revoked from PUBLIC on LTADM - AS PER CIS STANDARDS " >>  ${FINALDIR}/4_2_10_LTADM.log
        else
        echo ""  >>  ${FINALDIR}/4_2_10_LTADM.log

        echo " 4.2.10 Ensure EXECUTE Is Revoked from PUBLIC on LTADM  - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
            echo " 4.2.10 Ensure EXECUTE Is Revoked from PUBLIC on LTADM  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/4_2_10_LTADM.log
        fi


echo "" >> ${FINALDIR}/4_2_10_LTADM.log


echo ""



echo ""

echo "*************************** End of this module 4.2.10 check ***************************" >> ${FINALDIR}/4_2_10_LTADM.log

echo "*********************************************************************************" >> ${FINALDIR}/4_2_10_LTADM.log

}

REP_Fn_4_2_11_WWV_DBMS_SQL(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/4_2_11_WWV_DBMS_SQL.sql


checker=`cat ${REPSQLDIR}/sql_4_2_11_WWV_DBMS_SQL.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_4_2_11_WWV_DBMS_SQL.log  >> ${FINALDIR}/4_2_11_WWV_DBMS_SQL.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/4_2_11_WWV_DBMS_SQL.log
         echo " 4.2.11 Ensure EXECUTE Is Revoked from PUBLIC on WWV_DBMS_SQL - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 4.2.11 Ensure EXECUTE Is Revoked from PUBLIC on WWV_DBMS_SQL - AS PER CIS STANDARDS " >>  ${FINALDIR}/4_2_11_WWV_DBMS_SQL.log
        else
        echo ""  >>  ${FINALDIR}/4_2_11_WWV_DBMS_SQL.log

        echo " 4.2.11 Ensure EXECUTE Is Revoked from PUBLIC on WWV_DBMS_SQL  - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
            echo " 4.2.11 Ensure EXECUTE Is Revoked from PUBLIC on WWV_DBMS_SQL  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/4_2_11_WWV_DBMS_SQL.log
        fi


echo "" >> ${FINALDIR}/4_2_11_WWV_DBMS_SQL.log


echo ""



echo ""

echo "*************************** End of this module 4.2.11 check ***************************" >> ${FINALDIR}/4_2_11_WWV_DBMS_SQL.log

echo "*********************************************************************************" >> ${FINALDIR}/4_2_11_WWV_DBMS_SQL.log

}

REP_Fn_4_2_12_WWV_EXECUTE_IMMEDIATE(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/4_2_12_WWV_EXECUTE_IMMEDIATE.sql


checker=`cat ${REPSQLDIR}/sql_4_2_12_WWV_EXECUTE_IMMEDIATE.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_4_2_12_WWV_EXECUTE_IMMEDIATE.log  >> ${FINALDIR}/4_2_12_WWV_EXECUTE_IMMEDIATE.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/4_2_12_WWV_EXECUTE_IMMEDIATE.log
         echo " 4.2.12 Ensure EXECUTE Is Revoked from PUBLIC on WWV_EXECUTE_IMMEDIATE - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 4.2.12 Ensure EXECUTE Is Revoked from PUBLIC on WWV_EXECUTE_IMMEDIATE - AS PER CIS STANDARDS " >>  ${FINALDIR}/4_2_12_WWV_EXECUTE_IMMEDIATE.log
        else
        echo ""  >>  ${FINALDIR}/4_2_12_WWV_EXECUTE_IMMEDIATE.log

        echo " 4.2.12 Ensure EXECUTE Is Revoked from PUBLIC on WWV_EXECUTE_IMMEDIATE  - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
            echo " 4.2.12 Ensure EXECUTE Is Revoked from PUBLIC on WWV_EXECUTE_IMMEDIATE  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/4_2_12_WWV_EXECUTE_IMMEDIATE.log
        fi


echo "" >> ${FINALDIR}/4_2_12_WWV_EXECUTE_IMMEDIATE.log


echo ""



echo ""

echo "*************************** End of this module 4.2.12 check ***************************" >> ${FINALDIR}/4_2_12_WWV_EXECUTE_IMMEDIATE.log

echo "*********************************************************************************" >> ${FINALDIR}/4_2_12_WWV_EXECUTE_IMMEDIATE.log

}

REP_Fn_4_2_13_DBMS_IJOB(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/4_2_13_DBMS_IJOB.sql


checker=`cat ${REPSQLDIR}/sql_4_2_13_DBMS_IJOB.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_4_2_13_DBMS_IJOB.log  >> ${FINALDIR}/4_2_13_DBMS_IJOB.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/4_2_13_DBMS_IJOB.log
         echo " 4.2.13 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_IJOB - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 4.2.13 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_IJOB - AS PER CIS STANDARDS " >>  ${FINALDIR}/4_2_13_DBMS_IJOB.log
        else
        echo ""  >>  ${FINALDIR}/4_2_13_DBMS_IJOB.log

        echo " 4.2.12 Ensure EXECUTE Is Revoked from PUBLIC on WWV_EXECUTE_IMMEDIATE  - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
            echo " 4.2.12 Ensure EXECUTE Is Revoked from PUBLIC on WWV_EXECUTE_IMMEDIATE  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/4_2_13_DBMS_IJOB.log
        fi


echo "" >> ${FINALDIR}/4_2_13_DBMS_IJOB.log


echo ""



echo ""

echo "*************************** End of this module 4.2.13 check ***************************" >> ${FINALDIR}/4_2_13_DBMS_IJOB.log

echo "*********************************************************************************" >> ${FINALDIR}/4_2_13_DBMS_IJOB.log

}

REP_Fn_4_2_14_DBMS_FILE_TRANSFER(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/4_2_14_DBMS_FILE_TRANSFER.sql


checker=`cat ${REPSQLDIR}/sql_4_2_13_DBMS_IJOB.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_4_2_13_DBMS_IJOB.log  >> ${FINALDIR}/4_2_14_DBMS_FILE_TRANSFER.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/4_2_14_DBMS_FILE_TRANSFER.log
         echo " 4.2.14 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_FILE_TRANSFER - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 4.2.14 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_FILE_TRANSFER - AS PER CIS STANDARDS " >>  ${FINALDIR}/4_2_14_DBMS_FILE_TRANSFER.log
        else
        echo ""  >>  ${FINALDIR}/4_2_14_DBMS_FILE_TRANSFER.log

        echo " 4.2.14 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_FILE_TRANSFER  - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
            echo " 4.2.14 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_FILE_TRANSFER  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/4_2_14_DBMS_FILE_TRANSFER.log
        fi


echo "" >> ${FINALDIR}/4_2_14_DBMS_FILE_TRANSFER.log


echo ""



echo ""

echo "*************************** End of this module 4.2.14 check ***************************" >> ${FINALDIR}/4_2_14_DBMS_FILE_TRANSFER.log

echo "*********************************************************************************" >> ${FINALDIR}/4_2_14_DBMS_FILE_TRANSFER.log

}

######################### SECTION 4.2 ENDS HERE #########################

REP_Fn_4_3_1_SELECT_ANY_DICTIONARY(){

echo "" >> cat ${SHELLDIR}/sql_4_3_1_Rev_SELECT_ANY_DICTIONARY.log  | grep -v selected |  awk {'print "revoke " $2,$3,$4,$5,$6,$7 " from " $1 ";"'} | grep -v "revoke       from ;"

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/4_3_1_SELECT_ANY_DICTIONARY.sql

checker=`cat ${REPSQLDIR}/sql_4_3_1_SELECT_ANY_DICTIONARY.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_4_3_1_SELECT_ANY_DICTIONARY.log  >> ${FINALDIR}/4_3_1_SELECT_ANY_DICTIONARY.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/4_3_1_SELECT_ANY_DICTIONARY.log
         echo " 4.3.1 Ensure SELECT_ANY_DICTIONARY Is Revoked from Unauthorized GRANTEE - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 4.3.1 Ensure SELECT_ANY_DICTIONARY Is Revoked from Unauthorized GRANTEE - AS PER CIS STANDARDS " >>  ${FINALDIR}/4_3_1_SELECT_ANY_DICTIONARY.log
        else
        echo ""  >>  ${FINALDIR}/4_3_1_SELECT_ANY_DICTIONARY.log

        echo " 4.3.1 Ensure SELECT_ANY_DICTIONARY Is Revoked from Unauthorized GRANTEE  - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
            echo " 4.3.1 Ensure SELECT_ANY_DICTIONARY Is Revoked from Unauthorized GRANTEE  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/4_3_1_SELECT_ANY_DICTIONARY.log
        fi


echo "" >> ${FINALDIR}/4_3_1_SELECT_ANY_DICTIONARY.log


echo ""



echo ""

echo "*************************** End of this module 4.3.1 check ***************************" >> ${FINALDIR}/4_3_1_SELECT_ANY_DICTIONARY.log

echo "*********************************************************************************" >> ${FINALDIR}/4_3_1_SELECT_ANY_DICTIONARY.log

}

REP_Fn_4_3_2_SELECT_ANY_TABLE(){

cat ${SHELLDIR}/sql_4_3_2_Rev_SELECT_ANY_TABLE.log  | grep -v selected |  awk {'print "revoke " $2,$3,$4,$5,$6,$7 " from " $1 ";"'} | grep -v "revoke       from ;"

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/4_3_2_SELECT_ANY_TABLE.sql

checker=`cat ${REPSQLDIR}/sql_4_3_2_SELECT_ANY_TABLE.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_4_3_2_SELECT_ANY_TABLE.log  >> ${FINALDIR}/4_3_2_SELECT_ANY_TABLE.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/4_3_2_SELECT_ANY_TABLE.log
         echo " 4.3.2 Ensure SELECT ANY TABLE Is Revoked from Unauthorized GRANTEE - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 4.3.2 Ensure SELECT ANY TABLE Is Revoked from Unauthorized GRANTEE - AS PER CIS STANDARDS " >>  ${FINALDIR}/4_3_2_SELECT_ANY_TABLE.log
        else
        echo ""  >>  ${FINALDIR}/4_3_2_SELECT_ANY_TABLE.log

        echo " 4.3.2 Ensure SELECT ANY TABLE Is Revoked from Unauthorized GRANTEE  - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
            echo " 4.3.2 Ensure SELECT ANY TABLE Is Revoked from Unauthorized GRANTEE  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/4_3_2_SELECT_ANY_TABLE.log
        fi


echo "" >> ${FINALDIR}/4_3_2_SELECT_ANY_TABLE.log


echo ""



echo ""

echo "*************************** End of this module 4.3.2 check ***************************" >> ${FINALDIR}/4_3_2_SELECT_ANY_TABLE.log

echo "*********************************************************************************" >> ${FINALDIR}/4_3_2_SELECT_ANY_TABLE.log

}

REP_Fn_4_3_3_AUDIT_SYSTEM(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/4_3_3_AUDIT_SYSTEM.sql

checker=`cat ${REPSQLDIR}/sql_4_3_3_AUDIT_SYSTEM.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_4_3_3_AUDIT_SYSTEM.log  >> ${FINALDIR}/4_3_3_AUDIT_SYSTEM.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/4_3_3_AUDIT_SYSTEM.log
         echo " 4.3.3 Ensure AUDIT SYSTEM Is Revoked from Unauthorized GRANTEE - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 4.3.3 Ensure AUDIT SYSTEM Is Revoked from Unauthorized GRANTEE - AS PER CIS STANDARDS " >>  ${FINALDIR}/4_3_3_AUDIT_SYSTEM.log
        else
        echo ""  >>  ${FINALDIR}/4_3_3_AUDIT_SYSTEM.log

        echo " 4.3.3 Ensure AUDIT SYSTEM Is Revoked from Unauthorized GRANTEE  - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
            echo " 4.3.3 Ensure AUDIT SYSTEM Is Revoked from Unauthorized GRANTEE  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/4_3_3_AUDIT_SYSTEM.log
        fi


echo "" >> ${FINALDIR}/4_3_3_AUDIT_SYSTEM.log


echo ""



echo ""

echo "*************************** End of this module 4.3.3 check ***************************" >> ${FINALDIR}/4_3_3_AUDIT_SYSTEM.log

echo "*********************************************************************************" >> ${FINALDIR}/4_3_3_AUDIT_SYSTEM.log

}

REP_Fn_4_3_4_EXEMPT_ACCESS_POLICY(){

cat ${SHELLDIR}/sql_4_3_4_Rev_EXEMPT_ACCESS_POLICY.log  | grep -v selected |  awk {'print "revoke " $2,$3,$4,$5,$6,$7 " from " $1 ";"'} | grep -v "revoke       from ;"

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/4_3_4_EXEMPT_ACCESS_POLICY.sql

checker=`cat ${REPSQLDIR}/sql_4_3_4_EXEMPT_ACCESS_POLICY.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_4_3_4_EXEMPT_ACCESS_POLICY.log  >> ${FINALDIR}/4_3_4_EXEMPT_ACCESS_POLICY.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/4_3_4_EXEMPT_ACCESS_POLICY.log
         echo " 4.3.4 Ensure EXEMPT ACCESS POLICY Is Revoked from Unauthorized GRANTEE - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 4.3.4 Ensure EXEMPT ACCESS POLICY Is Revoked from Unauthorized GRANTEE - AS PER CIS STANDARDS " >>  ${FINALDIR}/4_3_4_EXEMPT_ACCESS_POLICY.log
        else
        echo ""  >>  ${FINALDIR}/4_3_4_EXEMPT_ACCESS_POLICY.log

        echo " 4.3.4 Ensure EXEMPT ACCESS POLICY Is Revoked from Unauthorized GRANTEE - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
            echo " 4.3.4 Ensure EXEMPT ACCESS POLICY Is Revoked from Unauthorized GRANTEE - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/4_3_4_EXEMPT_ACCESS_POLICY.log
        fi


echo "" >> ${FINALDIR}/4_3_4_EXEMPT_ACCESS_POLICY.log


echo ""



echo ""

echo "*************************** End of this module 4.3.4 check ***************************" >> ${FINALDIR}/4_3_4_EXEMPT_ACCESS_POLICY.log

echo "*********************************************************************************" >> ${FINALDIR}/4_3_4_EXEMPT_ACCESS_POLICY.log

}

REP_Fn_4_3_5_BECOME_USER(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/4_3_5_BECOME_USER.sql

checker=`cat ${REPSQLDIR}/sql_4_3_5_BECOME_USER.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_4_3_5_BECOME_USER.log  >> ${FINALDIR}/4_3_5_BECOME_USER.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/4_3_5_BECOME_USER.log
         echo " 4.3.5 Ensure BECOME USER Is Revoked from Unauthorized GRANTEE - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 4.3.5 Ensure BECOME USER Is Revoked from Unauthorized GRANTEE - AS PER CIS STANDARDS " >>  ${FINALDIR}/4_3_5_BECOME_USER.log
        else
        echo ""  >>  ${FINALDIR}/4_3_5_BECOME_USER.log

        echo " 4.3.5 Ensure BECOME USER Is Revoked from Unauthorized GRANTEE - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
            echo " 4.3.5 Ensure BECOME USER Is Revoked from Unauthorized GRANTEE - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/4_3_5_BECOME_USER.log
        fi


echo "" >> ${FINALDIR}/4_3_5_BECOME_USER.log


echo ""



echo ""

echo "*************************** End of this module 4.3.5 check ***************************" >> ${FINALDIR}/4_3_5_BECOME_USER.log

echo "*********************************************************************************" >> ${FINALDIR}/4_3_5_BECOME_USER.log

}

REP_Fn_4_3_6_CREATE_PROCEDURE(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/4_3_6_CREATE_PROCEDURE.sql

checker=`cat ${REPSQLDIR}/sql_4_3_6_CREATE_PROCEDURE.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_4_3_6_CREATE_PROCEDURE.log  >> ${FINALDIR}/4_3_6_CREATE_PROCEDURE.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/4_3_6_CREATE_PROCEDURE.log
         echo " 4.3.6 Ensure CREATE_PROCEDURE Is Revoked from Unauthorized GRANTEE - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 4.3.6 Ensure CREATE_PROCEDURE Is Revoked from Unauthorized GRANTEE - AS PER CIS STANDARDS " >>  ${FINALDIR}/4_3_6_CREATE_PROCEDURE.log
        else
        echo ""  >>  ${FINALDIR}/4_3_6_CREATE_PROCEDURE.log

        echo " 4.3.6 Ensure CREATE_PROCEDURE Is Revoked from Unauthorized GRANTEE - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
            echo " 4.3.6 Ensure CREATE_PROCEDURE Is Revoked from Unauthorized GRANTEE - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/4_3_6_CREATE_PROCEDURE.log
        fi


echo "" >> ${FINALDIR}/4_3_6_CREATE_PROCEDURE.log


echo ""



echo ""

echo "*************************** End of this module 4.3.6 check ***************************" >> ${FINALDIR}/4_3_6_CREATE_PROCEDURE.log

echo "*********************************************************************************" >> ${FINALDIR}/4_3_6_CREATE_PROCEDURE.log

}

REP_Fn_4_3_7_ALTER_SYSTEM(){

cat ${SHELLDIR}/sql_4_3_7_Rev_ALTER_SYSTEM.log  | grep -v selected |  awk {'print "revoke " $2,$3,$4,$5,$6,$7 " from " $1 ";"'} | grep -v "revoke       from ;"

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/4_3_7_ALTER_SYSTEM.sql

checker=`cat ${REPSQLDIR}/sql_4_3_7_ALTER_SYSTEM.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_4_3_7_ALTER_SYSTEM.log  >> ${FINALDIR}/4_3_7_ALTER_SYSTEM.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/4_3_7_ALTER_SYSTEM.log
         echo " 4.3.7 Ensure ALTER SYSTEM Is Revoked from Unauthorized GRANTEE - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 4.3.7 Ensure ALTER SYSTEM Is Revoked from Unauthorized GRANTEE - AS PER CIS STANDARDS " >>  ${FINALDIR}/4_3_7_ALTER_SYSTEM.log
        else
        echo ""  >>  ${FINALDIR}/4_3_7_ALTER_SYSTEM.log

        echo " 4.3.7 Ensure ALTER SYSTEM Is Revoked from Unauthorized GRANTEE - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
            echo " 4.3.7 Ensure ALTER SYSTEM Is Revoked from Unauthorized GRANTEE - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/4_3_7_ALTER_SYSTEM.log
        fi


echo "" >> ${FINALDIR}/4_3_7_ALTER_SYSTEM.log


echo ""



echo ""

echo "*************************** End of this module 4.3.7 check ***************************" >> ${FINALDIR}/4_3_7_ALTER_SYSTEM.log

echo "*********************************************************************************" >> ${FINALDIR}/4_3_7_ALTER_SYSTEM.log

}

REP_Fn_4_3_8_CREATE_ANY_LIBRARY(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/4_3_8_CREATE_ANY_LIBRARY.sql

checker=`cat ${REPSQLDIR}/sql_4_3_8_CREATE_ANY_LIBRARY.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_4_3_8_CREATE_ANY_LIBRARY.log  >> ${FINALDIR}/4_3_8_CREATE_ANY_LIBRARY.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/4_3_8_CREATE_ANY_LIBRARY.log
         echo " 4.3.8 Ensure CREATE ANY LIBRARY Is Revoked from Unauthorized GRANTEE - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 4.3.8 Ensure CREATE ANY LIBRARY Is Revoked from Unauthorized GRANTEE - AS PER CIS STANDARDS " >>  ${FINALDIR}/4_3_8_CREATE_ANY_LIBRARY.log
        else
        echo ""  >>  ${FINALDIR}/4_3_8_CREATE_ANY_LIBRARY.log

        echo " 4.3.8 Ensure CREATE ANY LIBRARY Is Revoked from Unauthorized GRANTEE - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
            echo " 4.3.8 Ensure CREATE ANY LIBRARY Is Revoked from Unauthorized GRANTEE - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/4_3_8_CREATE_ANY_LIBRARY.log
        fi


echo "" >> ${FINALDIR}/4_3_8_CREATE_ANY_LIBRARY.log


echo ""



echo ""

echo "*************************** End of this module 4.3.8 check ***************************" >> ${FINALDIR}/4_3_8_CREATE_ANY_LIBRARY.log

echo "*********************************************************************************" >> ${FINALDIR}/4_3_8_CREATE_ANY_LIBRARY.log

}

REP_Fn_4_3_9_CREATE_LIBRARY(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/4_3_9_CREATE_LIBRARY.sql

checker=`cat ${REPSQLDIR}/sql_4_3_9_CREATE_LIBRARY.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_4_3_9_CREATE_LIBRARY.log  >> ${FINALDIR}/4_3_9_CREATE_LIBRARY.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/4_3_9_CREATE_LIBRARY.log
         echo " 4.3.9 Ensure CREATE LIBRARY Is Revoked from Unauthorized GRANTEE - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 4.3.9 Ensure CREATE LIBRARY Is Revoked from Unauthorized GRANTEE - AS PER CIS STANDARDS " >>  ${FINALDIR}/4_3_9_CREATE_LIBRARY.log
        else
        echo ""  >>  ${FINALDIR}/4_3_9_CREATE_LIBRARY.log

        echo " 4.3.9 Ensure CREATE LIBRARY Is Revoked from Unauthorized GRANTEE - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
            echo " 4.3.9 Ensure CREATE LIBRARY Is Revoked from Unauthorized GRANTEE - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/4_3_9_CREATE_LIBRARY.log
        fi


echo "" >> ${FINALDIR}/4_3_9_CREATE_LIBRARY.log


echo ""



echo ""

echo "*************************** End of this module 4.3.9 check ***************************" >> ${FINALDIR}/4_3_9_CREATE_LIBRARY.log

echo "*********************************************************************************" >> ${FINALDIR}/4_3_9_CREATE_LIBRARY.log

}

REP_Fn_4_3_10_GRANT_ANY_OBJECT_PRIV(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/4_3_10_GRANT_ANY_OBJECT_PRIV.sql

checker=`cat ${REPSQLDIR}/sql_4_3_10_GRANT_ANY_OBJECT_PRIV.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_4_3_10_GRANT_ANY_OBJECT_PRIV.log  >> ${FINALDIR}/4_3_10_GRANT_ANY_OBJECT_PRIV.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/4_3_10_GRANT_ANY_OBJECT_PRIV.log
         echo " 4.3.10 Ensure GRANT ANY OBJECT PRIVILEGE Is Revoked from GRANTEE - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 4.3.10 Ensure GRANT ANY OBJECT PRIVILEGE Is Revoked from GRANTEE - AS PER CIS STANDARDS " >>  ${FINALDIR}/4_3_10_GRANT_ANY_OBJECT_PRIV.log
        else
        echo ""  >>  ${FINALDIR}/4_3_10_GRANT_ANY_OBJECT_PRIV.log

        echo " 4.3.10 Ensure GRANT ANY OBJECT PRIVILEGE Is Revoked from GRANTEE - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
            echo " 4.3.10 Ensure GRANT ANY OBJECT PRIVILEGE Is Revoked from GRANTEE - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/4_3_10_GRANT_ANY_OBJECT_PRIV.log
        fi


echo "" >> ${FINALDIR}/4_3_10_GRANT_ANY_OBJECT_PRIV.log


echo ""



echo ""

echo "*************************** End of this module 4.3.10 check ***************************" >> ${FINALDIR}/4_3_10_GRANT_ANY_OBJECT_PRIV.log

echo "*********************************************************************************" >> ${FINALDIR}/4_3_10_GRANT_ANY_OBJECT_PRIV.log

}

REP_Fn_4_3_11_GRANT_ANY_ROLE(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/4_3_11_GRANT_ANY_ROLE.sql

checker=`cat ${REPSQLDIR}/sql_4_3_11_GRANT_ANY_ROLE.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_4_3_11_GRANT_ANY_ROLE.log  >> ${FINALDIR}/4_3_11_GRANT_ANY_ROLE.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/4_3_11_GRANT_ANY_ROLE.log
         echo " 4.3.11 Ensure GRANT ANY ROLE Is Revoked from Unauthorized GRANTEE - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 4.3.11 Ensure GRANT ANY ROLE Is Revoked from Unauthorized GRANTEE - AS PER CIS STANDARDS " >>  ${FINALDIR}/4_3_11_GRANT_ANY_ROLE.log
        else
        echo ""  >>  ${FINALDIR}/4_3_11_GRANT_ANY_ROLE.log

        echo " 4.3.11 Ensure GRANT ANY ROLE Is Revoked from Unauthorized GRANTEE - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
            echo " 4.3.11 Ensure GRANT ANY ROLE Is Revoked from Unauthorized GRANTEE - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/4_3_11_GRANT_ANY_ROLE.log
        fi


echo "" >> ${FINALDIR}/4_3_11_GRANT_ANY_ROLE.log


echo ""



echo ""

echo "*************************** End of this module 4.3.11 check ***************************" >> ${FINALDIR}/4_3_11_GRANT_ANY_ROLE.log

echo "*********************************************************************************" >> ${FINALDIR}/4_3_11_GRANT_ANY_ROLE.log

}

REP_Fn_4_3_12_GRANT_ANY_PRIV(){

cat ${SHELLDIR}/sql_4_3_12_GRANT_ANY_PRIVILEGE.log  | grep -v selected |  awk {'print "revoke " $2,$3,$4,$5,$6,$7 " from " $1 ";"'} | grep -v "revoke       from ;"

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/4_3_12_GRANT_ANY_PRIV.sql

checker=`cat ${REPSQLDIR}/sql_4_3_12_GRANT_ANY_PRIV.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_4_3_12_GRANT_ANY_PRIV.log  >> ${FINALDIR}/4_3_12_GRANT_ANY_PRIV.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/4_3_12_GRANT_ANY_PRIV.log
         echo " 4.3.12 Ensure GRANT ANY PRIVILEGE Is Revoked from Unauthorized GRANTEE - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 4.3.12 Ensure GRANT ANY PRIVILEGE Is Revoked from Unauthorized GRANTEE - AS PER CIS STANDARDS " >>  ${FINALDIR}/4_3_12_GRANT_ANY_PRIV.log
        else
        echo ""  >>  ${FINALDIR}/4_3_12_GRANT_ANY_PRIV.log

        echo " 4.3.12 Ensure GRANT ANY PRIVILEGE Is Revoked from Unauthorized GRANTEE - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
            echo " 4.3.12 Ensure GRANT ANY PRIVILEGE Is Revoked from Unauthorized GRANTEE - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/4_3_12_GRANT_ANY_PRIV.log
        fi


echo "" >> ${FINALDIR}/4_3_12_GRANT_ANY_PRIV.log


echo ""



echo ""

echo "*************************** End of this module 4.3.12 check ***************************" >> ${FINALDIR}/4_3_12_GRANT_ANY_PRIV.log

echo "*********************************************************************************" >> ${FINALDIR}/4_3_12_GRANT_ANY_PRIV.log

}

######################### SECTION 4.3 ENDS HERE #########################

REP_Fn_4_4_1_DELETE_CATALOG_ROLE(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/4_4_1_DELETE_CATALOG_ROLE.sql

checker=`cat ${REPSQLDIR}/sql_4_4_1_DELETE_CATALOG_ROLE.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_4_4_1_DELETE_CATALOG_ROLE.log  >> ${FINALDIR}/4_4_1_DELETE_CATALOG_ROLE.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/4_4_1_DELETE_CATALOG_ROLE.log
         echo " 4.4.1 Ensure DELETE_CATALOG_ROLE Is Revoked from Unauthorized GRANTEE - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 4.4.1 Ensure DELETE_CATALOG_ROLE Is Revoked from Unauthorized GRANTEE - AS PER CIS STANDARDS " >>  ${FINALDIR}/4_4_1_DELETE_CATALOG_ROLE.log
        else
        echo ""  >>  ${FINALDIR}/4_4_1_DELETE_CATALOG_ROLE.log

        echo " 4.4.1 Ensure DELETE_CATALOG_ROLE Is Revoked from Unauthorized GRANTEE - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
            echo " 4.4.1 Ensure DELETE_CATALOG_ROLE Is Revoked from Unauthorized GRANTEE - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/4_4_1_DELETE_CATALOG_ROLE.log
        fi


echo "" >> ${FINALDIR}/4_4_1_DELETE_CATALOG_ROLE.log


echo ""



echo ""

echo "*************************** End of this module 4.4.1 check ***************************" >> ${FINALDIR}/4_4_1_DELETE_CATALOG_ROLE.log

echo "*********************************************************************************" >> ${FINALDIR}/4_4_1_DELETE_CATALOG_ROLE.log

}

REP_Fn_4_4_2_SELECT_CATALOG_ROLE(){

cat ${SHELLDIR}/sql_4_4_2_SELECT_CATALOG_ROLE.log  | grep -v selected |  awk {'print "revoke " $2,$3,$4,$5,$6,$7 " from " $1 ";"'} | grep -v "revoke       from ;"

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/4_4_2_SELECT_CATALOG_ROLE.sql

checker=`cat ${REPSQLDIR}/sql_4_4_2_SELECT_CATALOG_ROLE.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_4_4_2_SELECT_CATALOG_ROLE.log  >> ${FINALDIR}/4_4_2_SELECT_CATALOG_ROLE.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/4_4_2_SELECT_CATALOG_ROLE.log
         echo " 4.4.2 Ensure SELECT_CATALOG_ROLE Is Revoked from Unauthorized GRANTEE - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 4.4.2 Ensure SELECT_CATALOG_ROLE Is Revoked from Unauthorized GRANTEE - AS PER CIS STANDARDS " >>  ${FINALDIR}/4_4_2_SELECT_CATALOG_ROLE.log
        else
        echo ""  >>  ${FINALDIR}/4_4_2_SELECT_CATALOG_ROLE.log

        echo " 4.4.2 Ensure SELECT_CATALOG_ROLE Is Revoked from Unauthorized GRANTEE - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
            echo " 4.4.2 Ensure SELECT_CATALOG_ROLE Is Revoked from Unauthorized GRANTEE - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/4_4_2_SELECT_CATALOG_ROLE.log
        fi


echo "" >> ${FINALDIR}/4_4_2_SELECT_CATALOG_ROLE.log


echo ""



echo ""

echo "*************************** End of this module 4.4.2 check ***************************" >> ${FINALDIR}/4_4_2_SELECT_CATALOG_ROLE.log

echo "*********************************************************************************" >> ${FINALDIR}/4_4_2_SELECT_CATALOG_ROLE.log

}

REP_Fn_4_4_3_EXECUTE_CATALOG_ROLE(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/4_4_3_EXECUTE_CATALOG_ROLE.sql

checker=`cat ${REPSQLDIR}/sql_4_4_3_EXECUTE_CATALOG_ROLE.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_4_4_3_EXECUTE_CATALOG_ROLE.log  >> ${FINALDIR}/4_4_3_EXECUTE_CATALOG_ROLE.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/4_4_3_EXECUTE_CATALOG_ROLE.log
         echo " 4.4.3 Ensure EXECUTE_CATALOG_ROLE Is Revoked from Unauthorized GRANTEE - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 4.4.3 Ensure EXECUTE_CATALOG_ROLE Is Revoked from Unauthorized GRANTEE - AS PER CIS STANDARDS " >>  ${FINALDIR}/4_4_3_EXECUTE_CATALOG_ROLE.log
        else
        echo ""  >>  ${FINALDIR}/4_4_3_EXECUTE_CATALOG_ROLE.log

        echo " 4.4.3 Ensure EXECUTE_CATALOG_ROLE Is Revoked from Unauthorized GRANTEE - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
            echo " 4.4.3 Ensure EXECUTE_CATALOG_ROLE Is Revoked from Unauthorized GRANTEE - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/4_4_3_EXECUTE_CATALOG_ROLE.log
        fi


echo "" >> ${FINALDIR}/4_4_3_EXECUTE_CATALOG_ROLE.log


echo ""



echo ""

echo "*************************** End of this module 4.4.3 check ***************************" >> ${FINALDIR}/4_4_3_EXECUTE_CATALOG_ROLE.log

echo "*********************************************************************************" >> ${FINALDIR}/4_4_3_EXECUTE_CATALOG_ROLE.log

}

REP_Fn_4_4_4_REVOKE_DBA(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/4_4_4_REVOKE_DBA.sql

checker=`cat ${REPSQLDIR}/sql_4_4_4_REVOKE_DBA.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_4_4_4_REVOKE_DBA.log  >> ${FINALDIR}/4_4_4_REVOKE_DBA.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/4_4_4_REVOKE_DBA.log
         echo " 4.4.4 Ensure DBA Is Revoked from Unauthorized GRANTEE - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 4.4.4 Ensure DBA Is Revoked from Unauthorized GRANTEE - AS PER CIS STANDARDS " >>  ${FINALDIR}/4_4_4_REVOKE_DBA.log
        else
        echo ""  >>  ${FINALDIR}/4_4_4_REVOKE_DBA.log

        echo " 4.4.4 Ensure DBA Is Revoked from Unauthorized GRANTEE - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
            echo " 4.4.4 Ensure DBA Is Revoked from Unauthorized GRANTEE - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/4_4_4_REVOKE_DBA.log
        fi


echo "" >> ${FINALDIR}/4_4_4_REVOKE_DBA.log


echo ""



echo ""

echo "*************************** End of this module 4.4.4 check ***************************" >> ${FINALDIR}/4_4_4_REVOKE_DBA.log

echo "*********************************************************************************" >> ${FINALDIR}/4_4_4_REVOKE_DBA.log

}

######################### SECTION 4.4 ENDS HERE #########################

REP_Fn_4_5_1_REV_ALL_AUD(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/4_5_1_REV_ALL_AUD.sql

checker=`cat ${REPSQLDIR}/sql_4_5_1_REV_ALL_AUD.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_4_5_1_REV_ALL_AUD.log  >> ${FINALDIR}/4_5_1_REV_ALL_AUD.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/4_5_1_REV_ALL_AUD.log
         echo " 4.5.1 Ensure ALL Is Revoked from Unauthorized GRANTEE on AUD$ - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 4.5.1 Ensure ALL Is Revoked from Unauthorized GRANTEE on AUD$ - AS PER CIS STANDARDS " >>  ${FINALDIR}/4_5_1_REV_ALL_AUD.log
        else
        echo ""  >>  ${FINALDIR}/4_5_1_REV_ALL_AUD.log

        echo " 4.5.1 Ensure ALL Is Revoked from Unauthorized GRANTEE on AUD$ - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
            echo " 4.5.1 Ensure ALL Is Revoked from Unauthorized GRANTEE on AUD$ - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/4_5_1_REV_ALL_AUD.log
        fi


echo "" >> ${FINALDIR}/4_5_1_REV_ALL_AUD.log


echo ""



echo ""

echo "*************************** End of this module 4.5.1 check ***************************" >> ${FINALDIR}/4_5_1_REV_ALL_AUD.log

echo "*********************************************************************************" >> ${FINALDIR}/4_5_1_REV_ALL_AUD.log

}

REP_Fn_4_5_2_REV_ALL_USER_HISTORY(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/4_5_2_REV_ALL_USER_HISTORY.sql

checker=`cat ${REPSQLDIR}/sql_4_5_2_REV_ALL_USER_HISTORY.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_4_5_2_REV_ALL_USER_HISTORY.log  >> ${FINALDIR}/4_5_2_REV_ALL_USER_HISTORY.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/4_5_2_REV_ALL_USER_HISTORY.log
         echo " 4.5.2 Ensure ALL Is Revoked from Unauthorized GRANTEE on USER_HISTORY$ - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 4.5.2 Ensure ALL Is Revoked from Unauthorized GRANTEE on USER_HISTORY$ - AS PER CIS STANDARDS " >>  ${FINALDIR}/4_5_2_REV_ALL_USER_HISTORY.log
        else
        echo ""  >>  ${FINALDIR}/4_5_2_REV_ALL_USER_HISTORY.log

        echo " 4.5.2 Ensure ALL Is Revoked from Unauthorized GRANTEE on USER_HISTORY$ - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
            echo " 4.5.2 Ensure ALL Is Revoked from Unauthorized GRANTEE on USER_HISTORY$ - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/4_5_2_REV_ALL_USER_HISTORY.log
        fi


echo "" >> ${FINALDIR}/4_5_2_REV_ALL_USER_HISTORY.log


echo ""



echo ""

echo "*************************** End of this module 4.5.2 check ***************************" >> ${FINALDIR}/4_5_2_REV_ALL_USER_HISTORY.log

echo "*********************************************************************************" >> ${FINALDIR}/4_5_2_REV_ALL_USER_HISTORY.log

}

REP_Fn_4_5_3_REV_ALL_LINK(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/4_5_3_REV_ALL_LINK.sql

checker=`cat ${REPSQLDIR}/sql_4_5_3_REV_ALL_LINK.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_4_5_3_REV_ALL_LINK.log  >> ${FINALDIR}/4_5_3_REV_ALL_LINK.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/4_5_3_REV_ALL_LINK.log
         echo " 4.5.3 Ensure ALL Is Revoked from Unauthorized GRANTEE on LINK$ - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 4.5.3 Ensure ALL Is Revoked from Unauthorized GRANTEE on LINK$ - AS PER CIS STANDARDS " >>  ${FINALDIR}/4_5_3_REV_ALL_LINK.log
        else
        echo ""  >>  ${FINALDIR}/4_5_3_REV_ALL_LINK.log

        echo " 4.5.3 Ensure ALL Is Revoked from Unauthorized GRANTEE on LINK$ - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
            echo " 4.5.3 Ensure ALL Is Revoked from Unauthorized GRANTEE on LINK$ - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/4_5_3_REV_ALL_LINK.log
        fi


echo "" >> ${FINALDIR}/4_5_3_REV_ALL_LINK.log


echo ""



echo ""

echo "*************************** End of this module 4.5.3 check ***************************" >> ${FINALDIR}/4_5_3_REV_ALL_LINK.log

echo "*********************************************************************************" >> ${FINALDIR}/4_5_3_REV_ALL_LINK.log

}

REP_Fn_4_5_4_REV_ALL_SYS_USER(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/4_5_4_REV_ALL_SYS_USER.sql

checker=`cat ${REPSQLDIR}/sql_4_5_4_REV_ALL_SYS_USER.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_4_5_4_REV_ALL_SYS_USER.log  >> ${FINALDIR}/4_5_4_REV_ALL_SYS_USER.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/4_5_4_REV_ALL_SYS_USER.log
         echo " 4.5.4 Ensure ALL Is Revoked from Unauthorized GRANTEE on SYS.USER$ - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 4.5.4 Ensure ALL Is Revoked from Unauthorized GRANTEE on SYS.USER$ - AS PER CIS STANDARDS " >>  ${FINALDIR}/4_5_4_REV_ALL_SYS_USER.log
        else
        echo ""  >>  ${FINALDIR}/4_5_4_REV_ALL_SYS_USER.log

        echo " 4.5.4 Ensure ALL Is Revoked from Unauthorized GRANTEE on SYS.USER$ - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
            echo " 4.5.4 Ensure ALL Is Revoked from Unauthorized GRANTEE on SYS.USER$ - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/4_5_4_REV_ALL_SYS_USER.log
        fi


echo "" >> ${FINALDIR}/4_5_4_REV_ALL_SYS_USER.log


echo ""



echo ""

echo "*************************** End of this module 4.5.4 check ***************************" >> ${FINALDIR}/4_5_4_REV_ALL_SYS_USER.log

echo "*********************************************************************************" >> ${FINALDIR}/4_5_4_REV_ALL_SYS_USER.log

}

REP_Fn_4_5_5_REV_ALL_DBA(){

cat ${SHELLDIR}/sql_4_5_5_Rev_ALL_DBA.log  | grep -v selected |  awk {'print "revoke " $2,$3,$4,$5,$6,$7 " from " $1 ";"'} | grep -v "revoke       from ;"

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/4_5_5_REV_ALL_DBA.sql

checker=`cat ${REPSQLDIR}/sql_4_5_5_REV_ALL_DBA.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_4_5_5_REV_ALL_DBA.log  >> ${FINALDIR}/4_5_5_REV_ALL_DBA.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/4_5_5_REV_ALL_DBA.log
         echo " 4.5.5 Ensure ALL Is Revoked from Unauthorized GRANTEE on DBA_%  - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 4.5.5 Ensure ALL Is Revoked from Unauthorized GRANTEE on DBA_%  - AS PER CIS STANDARDS " >>  ${FINALDIR}/4_5_5_REV_ALL_DBA.log
        else
        echo ""  >>  ${FINALDIR}/4_5_5_REV_ALL_DBA.log

        echo " 4.5.5 Ensure ALL Is Revoked from Unauthorized GRANTEE on DBA_%  - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
            echo " 4.5.5 Ensure ALL Is Revoked from Unauthorized GRANTEE on DBA_%  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/4_5_5_REV_ALL_DBA.log
        fi


echo "" >> ${FINALDIR}/4_5_5_REV_ALL_DBA.log


echo ""



echo ""

echo "*************************** End of this module 4.5.5 check ***************************" >> ${FINALDIR}/4_5_5_REV_ALL_DBA.log

echo "*********************************************************************************" >> ${FINALDIR}/4_5_5_REV_ALL_DBA.log

}

REP_Fn_4_5_6_REV_ALL_SYS_SCHEDULER_CREDENTIAL(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/4_5_6_REV_ALL_SYS_SCHEDULER_CREDENTIAL.sql

checker=`cat ${REPSQLDIR}/sql_4_5_6_REV_ALL_SYS_SCHEDULER_CREDENTIAL.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_4_5_6_REV_ALL_SYS_SCHEDULER_CREDENTIAL.log  >> ${FINALDIR}/4_5_6_REV_ALL_SYS_SCHEDULER_CREDENTIAL.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/4_5_6_REV_ALL_SYS_SCHEDULER_CREDENTIAL.log
         echo " 4.5.6 Ensure ALL Is Revoked from Unauthorized GRANTEE on SYS.SCHEDULER$_CREDENTIAL  - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 4.5.6 Ensure ALL Is Revoked from Unauthorized GRANTEE on SYS.SCHEDULER$_CREDENTIAL  - AS PER CIS STANDARDS " >>  ${FINALDIR}/4_5_6_REV_ALL_SYS_SCHEDULER_CREDENTIAL.log
        else
        echo ""  >>  ${FINALDIR}/4_5_6_REV_ALL_SYS_SCHEDULER_CREDENTIAL.log

        echo " 4.5.6 Ensure ALL Is Revoked from Unauthorized GRANTEE on SYS.SCHEDULER$_CREDENTIAL  - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
            echo " 4.5.6 Ensure ALL Is Revoked from Unauthorized GRANTEE on SYS.SCHEDULER$_CREDENTIAL  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/4_5_6_REV_ALL_SYS_SCHEDULER_CREDENTIAL.log
        fi


echo "" >> ${FINALDIR}/4_5_6_REV_ALL_SYS_SCHEDULER_CREDENTIAL.log


echo ""



echo ""

echo "*************************** End of this module 4.5.6 check ***************************" >> ${FINALDIR}/4_5_6_REV_ALL_SYS_SCHEDULER_CREDENTIAL.log

echo "*********************************************************************************" >> ${FINALDIR}/4_5_6_REV_ALL_SYS_SCHEDULER_CREDENTIAL.log

}

REP_Fn_4_5_7_DROP_SYS_USER_MIG(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/4_5_7_DROP_SYS_USER_MIG.sql

checker=`cat ${REPSQLDIR}/sql_4_5_7_DROP_SYS_USER_MIG.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_4_5_7_DROP_SYS_USER_MIG.log  >> ${FINALDIR}/4_5_7_DROP_SYS_USER_MIG.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/4_5_7_DROP_SYS_USER_MIG.log
         echo " 4.5.7 Ensure SYS.USER$MIG Has Been Dropped  - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 4.5.7 Ensure SYS.USER$MIG Has Been Dropped  - AS PER CIS STANDARDS " >>  ${FINALDIR}/4_5_7_DROP_SYS_USER_MIG.log
        else
        echo ""  >>  ${FINALDIR}/4_5_7_DROP_SYS_USER_MIG.log

        echo " 4.5.7 Ensure SYS.USER$MIG Has Been Dropped  - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
            echo " 4.5.7 Ensure SYS.USER$MIG Has Been Dropped  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/4_5_7_DROP_SYS_USER_MIG.log
        fi


echo "" >> ${FINALDIR}/4_5_7_DROP_SYS_USER_MIG.log


echo ""



echo ""

echo "*************************** End of this module 4.5.7 check ***************************" >> ${FINALDIR}/4_5_7_DROP_SYS_USER_MIG.log

echo "*********************************************************************************" >> ${FINALDIR}/4_5_7_DROP_SYS_USER_MIG.log

}

######################### SECTION 4.5 ENDS HERE #########################

REP_Fn_4_6_REV_ANY(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/4_6_REV_ANY.sql

checker=`cat ${REPSQLDIR}/sql_4_6_REV_ANY.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_4_6_REV_ANY.log  >> ${FINALDIR}/4_6_REV_ANY.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/4_6_REV_ANY.log
         echo " 4.6 Ensure %ANY% Is Revoked from Unauthorized GRANTEE  - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 4.6 Ensure %ANY% Is Revoked from Unauthorized GRANTEE  - AS PER CIS STANDARDS " >>  ${FINALDIR}/4_6_REV_ANY.log
        else
        echo ""  >>  ${FINALDIR}/4_6_REV_ANY.log

        echo " 4.6 Ensure %ANY% Is Revoked from Unauthorized GRANTEE  - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
            echo " 4.6 Ensure %ANY% Is Revoked from Unauthorized GRANTEE  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/4_6_REV_ANY.log
        fi


echo "" >> ${FINALDIR}/4_6_REV_ANY.log


echo ""



echo ""

echo "*************************** End of this module 4.6 check ***************************" >> ${FINALDIR}/4_6_REV_ANY.log

echo "*********************************************************************************" >> ${FINALDIR}/4_6_REV_ANY.log

}

REP_Fn_4_7_REV_DBA_SYS_PRIVS(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/4_7_REV_DBA_SYS_PRIVS.sql

checker=`cat ${REPSQLDIR}/sql_4_7_REV_DBA_SYS_PRIVS.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_4_7_REV_DBA_SYS_PRIVS.log  >> ${FINALDIR}/4_7_REV_DBA_SYS_PRIVS.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/4_7_REV_DBA_SYS_PRIVS.log
         echo " 4.7 Ensure DBA_SYS_PRIVS.% Is Revoked from Unauthorized GRANTEE with ADMIN_OPTION Set to YES  - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 4.7 Ensure DBA_SYS_PRIVS.% Is Revoked from Unauthorized GRANTEE with ADMIN_OPTION Set to YES  - AS PER CIS STANDARDS " >>  ${FINALDIR}/4_7_REV_DBA_SYS_PRIVS.log
        else
        echo ""  >>  ${FINALDIR}/4_7_REV_DBA_SYS_PRIVS.log

        echo " 4.7 Ensure DBA_SYS_PRIVS.% Is Revoked from Unauthorized GRANTEE with ADMIN_OPTION Set to YES - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
            echo " 4.7 Ensure DBA_SYS_PRIVS.% Is Revoked from Unauthorized GRANTEE with ADMIN_OPTION Set to YES  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/4_7_REV_DBA_SYS_PRIVS.log
        fi


echo "" >> ${FINALDIR}/4_7_REV_DBA_SYS_PRIVS.log


echo ""



echo ""

echo "*************************** End of this module 4.7 check ***************************" >> ${FINALDIR}/4_7_REV_DBA_SYS_PRIVS.log

echo "*********************************************************************************" >> ${FINALDIR}/4_7_REV_DBA_SYS_PRIVS.log

}

REP_Fn_4_8_PROXY_USER_PRIV(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/4_8_PROXY_USER_PRIV.sql

checker=`cat ${REPSQLDIR}/sql_4_8_PROXY_USER_PRIV.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_4_8_PROXY_USER_PRIV.log  >> ${FINALDIR}/4_8_PROXY_USER_PRIV.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/4_8_PROXY_USER_PRIV.log
         echo " 4.8 Ensure Proxy Users Have Only CONNECT Privilege  - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 4.8 Ensure Proxy Users Have Only CONNECT Privilege  - AS PER CIS STANDARDS " >>  ${FINALDIR}/4_8_PROXY_USER_PRIV.log
        else
        echo ""  >>  ${FINALDIR}/4_8_PROXY_USER_PRIV.log

        echo " 4.8 Ensure Proxy Users Have Only CONNECT Privilege - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
            echo " 4.8 Ensure Proxy Users Have Only CONNECT Privilege  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/4_8_PROXY_USER_PRIV.log
        fi


echo "" >> ${FINALDIR}/4_8_PROXY_USER_PRIV.log


echo ""



echo ""

echo "*************************** End of this module 4.8 check ***************************" >> ${FINALDIR}/4_8_PROXY_USER_PRIV.log

echo "*********************************************************************************" >> ${FINALDIR}/4_8_PROXY_USER_PRIV.log

}

REP_Fn_4_9_REV_EXE_ANY_PROC_OUTLN(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/4_9_REV_EXE_ANY_PROC_OUTLN.sql

checker=`cat ${REPSQLDIR}/sql_4_9_REV_EXE_ANY_PROC_OUTLN.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_4_9_REV_EXE_ANY_PROC_OUTLN.log  >> ${FINALDIR}/4_9_REV_EXE_ANY_PROC_OUTLN.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/4_9_REV_EXE_ANY_PROC_OUTLN.log
         echo " 4.9 Ensure EXECUTE ANY PROCEDURE Is Revoked from OUTLN - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 4.9 Ensure EXECUTE ANY PROCEDURE Is Revoked from OUTLN  - AS PER CIS STANDARDS " >>  ${FINALDIR}/4_9_REV_EXE_ANY_PROC_OUTLN.log
        else
        echo ""  >>  ${FINALDIR}/4_9_REV_EXE_ANY_PROC_OUTLN.log

        echo " 4.9 Ensure EXECUTE ANY PROCEDURE Is Revoked from OUTLN - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
            echo " 4.9 Ensure EXECUTE ANY PROCEDURE Is Revoked from OUTLN  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/4_9_REV_EXE_ANY_PROC_OUTLN.log
        fi


echo "" >> ${FINALDIR}/4_9_REV_EXE_ANY_PROC_OUTLN.log


echo ""



echo ""

echo "*************************** End of this module 4.9 check ***************************" >> ${FINALDIR}/4_9_REV_EXE_ANY_PROC_OUTLN.log

echo "*********************************************************************************" >> ${FINALDIR}/4_9_REV_EXE_ANY_PROC_OUTLN.log

}

REP_Fn_4_10_REV_EXE_ANY_PROC_DBSNMP(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/4_10_REV_EXE_ANY_PROC_DBSNMP.sql

checker=`cat ${REPSQLDIR}/sql_4_10_REV_EXE_ANY_PROC_DBSNMP.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_4_10_REV_EXE_ANY_PROC_DBSNMP.log  >> ${FINALDIR}/4_10_REV_EXE_ANY_PROC_DBSNMP.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/4_10_REV_EXE_ANY_PROC_DBSNMP.log
         echo " 4.10 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_FILE_TRANSFER - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 4.10 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_FILE_TRANSFER  - AS PER CIS STANDARDS " >>  ${FINALDIR}/4_10_REV_EXE_ANY_PROC_DBSNMP.log
        else
        echo ""  >>  ${FINALDIR}/4_10_REV_EXE_ANY_PROC_DBSNMP.log

        echo " 4.10 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_FILE_TRANSFER - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
            echo " 4.10 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_FILE_TRANSFER  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/4_10_REV_EXE_ANY_PROC_DBSNMP.log
        fi


echo "" >> ${FINALDIR}/4_10_REV_EXE_ANY_PROC_DBSNMP.log


echo ""



echo ""

echo "*************************** End of this module 4.10 check ***************************" >> ${FINALDIR}/4_10_REV_EXE_ANY_PROC_DBSNMP.log

echo "*********************************************************************************" >> ${FINALDIR}/4_10_REV_EXE_ANY_PROC_DBSNMP.log

}

######################### SECTION 4 ENDS HERE #########################

REP_Fn_5_1_AUDIT_USER(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/5_1_AUDIT_USER.sql

checker=`cat ${REPSQLDIR}/sql_5_1_AUDIT_USER.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_5_1_AUDIT_USER.log  >> ${FINALDIR}/5_1_AUDIT_USER.log


if [ ${checker} == 0 ];
        then
        echo ""  >>  ${FINALDIR}/5_1_AUDIT_USER.log
         echo " 5.1 Enable USER Audit Option  - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 5.1 Enable USER Audit Option  - AS PER CIS STANDARDS " >>  ${FINALDIR}/5_1_AUDIT_USER.log
        else
        echo ""  >>  ${FINALDIR}/5_1_AUDIT_USER.log

        echo " 5.1 Enable USER Audit Option - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
            echo " 5.1 Enable USER Audit Option  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/5_1_AUDIT_USER.log
        fi


echo "" >> ${FINALDIR}/5_1_AUDIT_USER.log


echo ""



echo ""

echo "*************************** End of this module 5.1 check ***************************" >> ${FINALDIR}/5_1_AUDIT_USER.log

echo "*********************************************************************************" >> ${FINALDIR}/5_1_AUDIT_USER.log

}

REP_Fn_5_2_AUDIT_ALETR_USER(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/5_2_AUDIT_ALETR_USER.sql

checker=`cat ${REPSQLDIR}/sql_5_2_AUDIT_ALETR_USER.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_5_2_AUDIT_ALETR_USER.log  >> ${FINALDIR}/5_2_AUDIT_ALETR_USER.log


if [ ${checker} == 0 ];
        then
        echo ""  >>  ${FINALDIR}/5_2_AUDIT_ALETR_USER.log
         echo " 5.2 Enable ALTER USER Audit Option  - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 5.2 Enable ALTER USER Audit Option  - AS PER CIS STANDARDS " >>  ${FINALDIR}/5_2_AUDIT_ALETR_USER.log
        else
        echo ""  >>  ${FINALDIR}/5_2_AUDIT_ALETR_USER.log

        echo " 5.2 Enable ALTER USER Audit Option - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
            echo " 5.2 Enable ALTER USER Audit Option  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/5_2_AUDIT_ALETR_USER.log
        fi


echo "" >> ${FINALDIR}/5_2_AUDIT_ALETR_USER.log


echo ""



echo ""

echo "*************************** End of this module 5.2 check ***************************" >> ${FINALDIR}/5_2_AUDIT_ALETR_USER.log

echo "*********************************************************************************" >> ${FINALDIR}/5_2_AUDIT_ALETR_USER.log

}

REP_Fn_5_3_AUDIT_DROP_USER(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/5_3_AUDIT_DROP_USER.sql

checker=`cat ${REPSQLDIR}/sql_5_3_AUDIT_DROP_USER.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_5_3_AUDIT_DROP_USER.log  >> ${FINALDIR}/5_3_AUDIT_DROP_USER.log


if [ ${checker} == 0 ];
        then
        echo ""  >>  ${FINALDIR}/5_3_AUDIT_DROP_USER.log
         echo " 5.3 Enable DROP USER Audit Option  - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 5.3 Enable DROP USER Audit Option  - AS PER CIS STANDARDS " >>  ${FINALDIR}/5_3_AUDIT_DROP_USER.log
        else
        echo ""  >>  ${FINALDIR}/5_3_AUDIT_DROP_USER.log

        echo " 5.3 Enable DROP USER Audit Option - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
            echo " 5.3 Enable DROP USER Audit Option  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/5_3_AUDIT_DROP_USER.log
        fi


echo "" >> ${FINALDIR}/5_3_AUDIT_DROP_USER.log


echo ""



echo ""

echo "*************************** End of this module 5.3 check ***************************" >> ${FINALDIR}/5_3_AUDIT_DROP_USER.log

echo "*********************************************************************************" >> ${FINALDIR}/5_3_AUDIT_DROP_USER.log

}

REP_Fn_5_4_AUDIT_ROLE(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/5_4_AUDIT_ROLE.sql

checker=`cat ${REPSQLDIR}/sql_5_4_AUDIT_ROLE.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_5_4_AUDIT_ROLE.log  >> ${FINALDIR}/5_4_AUDIT_ROLE.log


if [ ${checker} == 0 ];
        then
        echo ""  >>  ${FINALDIR}/5_4_AUDIT_ROLE.log
         echo " 5.4 Enable ROLE Audit Option  - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 5.4 Enable ROLE Audit Option  - AS PER CIS STANDARDS " >>  ${FINALDIR}/5_4_AUDIT_ROLE.log
        else
        echo ""  >>  ${FINALDIR}/5_4_AUDIT_ROLE.log

        echo " 5.4 Enable ROLE Audit Option - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
            echo " 5.4 Enable ROLE Audit Option  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/5_4_AUDIT_ROLE.log
        fi


echo "" >> ${FINALDIR}/5_4_AUDIT_ROLE.log


echo ""



echo ""

echo "*************************** End of this module 5.4 check ***************************" >> ${FINALDIR}/5_4_AUDIT_ROLE.log

echo "*********************************************************************************" >> ${FINALDIR}/5_4_AUDIT_ROLE.log

}

REP_Fn_5_5_AUDIT_SYSTEM_GRANT(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/5_5_AUDIT_SYSTEM_GRANT.sql

checker=`cat ${REPSQLDIR}/sql_5_5_AUDIT_SYSTEM_GRANT.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_5_5_AUDIT_SYSTEM_GRANT.log  >> ${FINALDIR}/5_5_AUDIT_SYSTEM_GRANT.log


if [ ${checker} == 0 ];
        then
        echo ""  >>  ${FINALDIR}/5_5_AUDIT_SYSTEM_GRANT.log
         echo " 5.5 Enable SYSTEM GRANT Audit Option  - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 5.5 Enable SYSTEM GRANT Audit Option  - AS PER CIS STANDARDS " >>  ${FINALDIR}/5_5_AUDIT_SYSTEM_GRANT.log
        else
        echo ""  >>  ${FINALDIR}/5_5_AUDIT_SYSTEM_GRANT.log

        echo " 5.5 Enable SYSTEM GRANT Audit Option - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
            echo " 5.5 Enable SYSTEM GRANT Audit Option  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/5_5_AUDIT_SYSTEM_GRANT.log
        fi


echo "" >> ${FINALDIR}/5_5_AUDIT_SYSTEM_GRANT.log


echo ""



echo ""

echo "*************************** End of this module 5.5 check ***************************" >> ${FINALDIR}/5_5_AUDIT_SYSTEM_GRANT.log

echo "*********************************************************************************" >> ${FINALDIR}/5_5_AUDIT_SYSTEM_GRANT.log

}

REP_Fn_5_6_AUDIT_PROFILE(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/5_6_AUDIT_PROFILE.sql

checker=`cat ${REPSQLDIR}/sql_5_6_AUDIT_PROFILE.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_5_6_AUDIT_PROFILE.log  >> ${FINALDIR}/5_6_AUDIT_PROFILE.log


if [ ${checker} == 0 ];
        then
        echo ""  >>  ${FINALDIR}/5_6_AUDIT_PROFILE.log
         echo " 5.6 Enable PROFILE Audit Option  - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 5.6 Enable PROFILE Audit Option  - AS PER CIS STANDARDS " >>  ${FINALDIR}/5_6_AUDIT_PROFILE.log
        else
        echo ""  >>  ${FINALDIR}/5_6_AUDIT_PROFILE.log

        echo " 5.6 Enable PROFILE Audit Option - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
            echo " 5.6 Enable PROFILE Audit Option  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/5_6_AUDIT_PROFILE.log
        fi


echo "" >> ${FINALDIR}/5_6_AUDIT_PROFILE.log


echo ""



echo ""

echo "*************************** End of this module 5.6 check ***************************" >> ${FINALDIR}/5_6_AUDIT_PROFILE.log

echo "*********************************************************************************" >> ${FINALDIR}/5_6_AUDIT_PROFILE.log

}

REP_Fn_5_7_AUDIT_ALETR_PROFILE(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/5_7_AUDIT_ALETR_PROFILE.sql

checker=`cat ${REPSQLDIR}/sql_5_7_AUDIT_ALETR_PROFILE.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_5_7_AUDIT_ALETR_PROFILE.log  >> ${FINALDIR}/5_7_AUDIT_ALETR_PROFILE.log


if [ ${checker} == 0 ];
        then
        echo ""  >>  ${FINALDIR}/5_7_AUDIT_ALETR_PROFILE.log
         echo " 5.7 Enable ALTER PROFILE Audit Option  - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 5.7 Enable ALTER PROFILE Audit Option  - AS PER CIS STANDARDS " >>  ${FINALDIR}/5_7_AUDIT_ALETR_PROFILE.log
        else
        echo ""  >>  ${FINALDIR}/5_7_AUDIT_ALETR_PROFILE.log

        echo " 5.7 Enable ALTER PROFILE Audit Option - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
            echo " 5.7 Enable ALTER PROFILE Audit Option  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/5_7_AUDIT_ALETR_PROFILE.log
        fi


echo "" >> ${FINALDIR}/5_7_AUDIT_ALETR_PROFILE.log


echo ""



echo ""

echo "*************************** End of this module 5.7 check ***************************" >> ${FINALDIR}/5_7_AUDIT_ALETR_PROFILE.log

echo "*********************************************************************************" >> ${FINALDIR}/5_7_AUDIT_ALETR_PROFILE.log

}

REP_Fn_5_8_AUDIT_DROP_PROFILE(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/5_8_AUDIT_DROP_PROFILE.sql

checker=`cat ${REPSQLDIR}/sql_5_8_AUDIT_DROP_PROFILE.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_5_8_AUDIT_DROP_PROFILE.log  >> ${FINALDIR}/5_8_AUDIT_DROP_PROFILE.log


if [ ${checker} == 0 ];
        then
        echo ""  >>  ${FINALDIR}/5_8_AUDIT_DROP_PROFILE.log
         echo " 5.8 Enable DROP PROFILE Audit Option  - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 5.8 Enable DROP PROFILE Audit Option  - AS PER CIS STANDARDS " >>  ${FINALDIR}/5_8_AUDIT_DROP_PROFILE.log
        else
        echo ""  >>  ${FINALDIR}/5_8_AUDIT_DROP_PROFILE.log

        echo " 5.8 Enable DROP PROFILE Audit Option - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
            echo " 5.8 Enable DROP PROFILE Audit Option  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/5_8_AUDIT_DROP_PROFILE.log
        fi


echo "" >> ${FINALDIR}/5_8_AUDIT_DROP_PROFILE.log


echo ""



echo ""

echo "*************************** End of this module 5.8 check ***************************" >> ${FINALDIR}/5_8_AUDIT_DROP_PROFILE.log

echo "*********************************************************************************" >> ${FINALDIR}/5_8_AUDIT_DROP_PROFILE.log

}

REP_Fn_5_9_AUDIT_DATABASE_LINK(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/5_9_AUDIT_DATABASE_LINK.sql

checker=`cat ${REPSQLDIR}/sql_5_9_AUDIT_DATABASE_LINK.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_5_9_AUDIT_DATABASE_LINK.log  >> ${FINALDIR}/5_9_AUDIT_DATABASE_LINK.log


if [ ${checker} == 0 ];
        then
        echo ""  >>  ${FINALDIR}/5_9_AUDIT_DATABASE_LINK.log
         echo " 5.9 Enable DATABASE LINK Audit Option  - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 5.9 Enable DATABASE LINK Audit Option  - AS PER CIS STANDARDS " >>  ${FINALDIR}/5_9_AUDIT_DATABASE_LINK.log
        else
        echo ""  >>  ${FINALDIR}/5_9_AUDIT_DATABASE_LINK.log

        echo " 5.9 Enable DATABASE LINK Audit Option - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
            echo " 5.9 Enable DATABASE LINK Audit Option  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/5_9_AUDIT_DATABASE_LINK.log
        fi


echo "" >> ${FINALDIR}/5_9_AUDIT_DATABASE_LINK.log


echo ""



echo ""

echo "*************************** End of this module 5.9 check ***************************" >> ${FINALDIR}/5_9_AUDIT_DATABASE_LINK.log

echo "*********************************************************************************" >> ${FINALDIR}/5_9_AUDIT_DATABASE_LINK.log

}

REP_Fn_5_10_AUDIT_PUBLIC_DATABASE_LINK(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/5_10_AUDIT_PUBLIC_DATABASE_LINK.sql

checker=`cat ${REPSQLDIR}/sql_5_10_AUDIT_PUBLIC_DATABASE_LINK.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_5_10_AUDIT_PUBLIC_DATABASE_LINK.log  >> ${FINALDIR}/5_10_AUDIT_PUBLIC_DATABASE_LINK.log


if [ ${checker} == 0 ];
        then
        echo ""  >>  ${FINALDIR}/5_10_AUDIT_PUBLIC_DATABASE_LINK.log
         echo " 5.10 Enable PUBLIC DATABASE LINK Audit Option  - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 5.10 Enable PUBLIC DATABASE LINK Audit Option  - AS PER CIS STANDARDS " >>  ${FINALDIR}/5_10_AUDIT_PUBLIC_DATABASE_LINK.log
        else
        echo ""  >>  ${FINALDIR}/5_10_AUDIT_PUBLIC_DATABASE_LINK.log

        echo " 5.10 Enable PUBLIC DATABASE LINK Audit Option - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
            echo " 5.10 Enable PUBLIC DATABASE LINK Audit Option  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/5_10_AUDIT_PUBLIC_DATABASE_LINK.log
        fi


echo "" >> ${FINALDIR}/5_10_AUDIT_PUBLIC_DATABASE_LINK.log


echo ""



echo ""

echo "*************************** End of this module 5.10 check ***************************" >> ${FINALDIR}/5_10_AUDIT_PUBLIC_DATABASE_LINK.log

echo "*********************************************************************************" >> ${FINALDIR}/5_10_AUDIT_PUBLIC_DATABASE_LINK.log

}

REP_Fn_5_11_AUDIT_PUBLIC_SYNONYM(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/5_11_AUDIT_PUBLIC_SYNONYM.sql

checker=`cat ${REPSQLDIR}/sql_5_11_AUDIT_PUBLIC_SYNONYM.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_5_11_AUDIT_PUBLIC_SYNONYM.log  >> ${FINALDIR}/5_11_AUDIT_PUBLIC_SYNONYM.log


if [ ${checker} == 0 ];
        then
        echo ""  >>  ${FINALDIR}/5_11_AUDIT_PUBLIC_SYNONYM.log
         echo " 5.11 Enable PUBLIC SYNONYM Audit Option  - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 5.11 Enable PUBLIC SYNONYM Audit Option  - AS PER CIS STANDARDS " >>  ${FINALDIR}/5_11_AUDIT_PUBLIC_SYNONYM.log
        else
        echo ""  >>  ${FINALDIR}/5_11_AUDIT_PUBLIC_SYNONYM.log

        echo " 5.11 Enable PUBLIC SYNONYM Audit Option - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
            echo " 5.11 Enable PUBLIC SYNONYM Audit Option  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/5_11_AUDIT_PUBLIC_SYNONYM.log
        fi


echo "" >> ${FINALDIR}/5_11_AUDIT_PUBLIC_SYNONYM.log


echo ""



echo ""

echo "*************************** End of this module 5.11 check ***************************" >> ${FINALDIR}/5_11_AUDIT_PUBLIC_SYNONYM.log

echo "*********************************************************************************" >> ${FINALDIR}/5_11_AUDIT_PUBLIC_SYNONYM.log

}

REP_Fn_5_12_AUDIT_SYNONYM(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/5_12_AUDIT_SYNONYM.sql

checker=`cat ${REPSQLDIR}/sql_5_12_AUDIT_SYNONYM.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_5_12_AUDIT_SYNONYM.log  >> ${FINALDIR}/5_12_AUDIT_SYNONYM.log


if [ ${checker} == 0 ];
        then
        echo ""  >>  ${FINALDIR}/5_12_AUDIT_SYNONYM.log
         echo " 5.12 Enable SYNONYM Audit Option  - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 5.12 Enable SYNONYM Audit Option  - AS PER CIS STANDARDS " >>  ${FINALDIR}/5_12_AUDIT_SYNONYM.log
        else
        echo ""  >>  ${FINALDIR}/5_12_AUDIT_SYNONYM.log

        echo " 5.12 Enable SYNONYM Audit Option - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
            echo " 5.12 Enable SYNONYM Audit Option  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/5_12_AUDIT_SYNONYM.log
        fi


echo "" >> ${FINALDIR}/5_12_AUDIT_SYNONYM.log


echo ""



echo ""

echo "*************************** End of this module 5.12 check ***************************" >> ${FINALDIR}/5_12_AUDIT_SYNONYM.log

echo "*********************************************************************************" >> ${FINALDIR}/5_12_AUDIT_SYNONYM.log

}

REP_Fn_5_13_AUDIT_GRANT_DIRECTORY(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/5_13_AUDIT_GRANT_DIRECTORY.sql

checker=`cat ${REPSQLDIR}/sql_5_13_AUDIT_GRANT_DIRECTORY.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_5_13_AUDIT_GRANT_DIRECTORY.log  >> ${FINALDIR}/5_13_AUDIT_GRANT_DIRECTORY.log


if [ ${checker} == 0 ];
        then
        echo ""  >>  ${FINALDIR}/5_13_AUDIT_GRANT_DIRECTORY.log
         echo " 5.13 Enable GRANT DIRECTORY Audit Option  - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 5.13 Enable GRANT DIRECTORY Audit Option  - AS PER CIS STANDARDS " >>  ${FINALDIR}/5_13_AUDIT_GRANT_DIRECTORY.log
        else
        echo ""  >>  ${FINALDIR}/5_13_AUDIT_GRANT_DIRECTORY.log

        echo " 5.13 Enable GRANT DIRECTORY Audit Option - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
            echo " 5.13 Enable GRANT DIRECTORY Audit Option  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/5_13_AUDIT_GRANT_DIRECTORY.log
        fi


echo "" >> ${FINALDIR}/5_13_AUDIT_GRANT_DIRECTORY.log


echo ""



echo ""

echo "*************************** End of this module 5.13 check ***************************" >> ${FINALDIR}/5_13_AUDIT_GRANT_DIRECTORY.log

echo "*********************************************************************************" >> ${FINALDIR}/5_13_AUDIT_GRANT_DIRECTORY.log

}

REP_Fn_5_14_AUDIT_SELECT_ANY_DICTIONARY(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/5_14_AUDIT_SELECT_ANY_DICTIONARY.sql

checker=`cat ${REPSQLDIR}/sql_5_14_AUDIT_SELECT_ANY_DICTIONARY.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_5_14_AUDIT_SELECT_ANY_DICTIONARY.log  >> ${FINALDIR}/5_14_AUDIT_SELECT_ANY_DICTIONARY.log


if [ ${checker} == 0 ];
        then
        echo ""  >>  ${FINALDIR}/5_14_AUDIT_SELECT_ANY_DICTIONARY.log
         echo " 5.14 Enable SELECT ANY DICTIONARY Audit Option  - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 5.14 Enable SELECT ANY DICTIONARY Audit Option  - AS PER CIS STANDARDS " >>  ${FINALDIR}/5_14_AUDIT_SELECT_ANY_DICTIONARY.log
        else
        echo ""  >>  ${FINALDIR}/5_14_AUDIT_SELECT_ANY_DICTIONARY.log

        echo " 5.14 Enable SELECT ANY DICTIONARY Audit Option - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
            echo " 5.14 Enable SELECT ANY DICTIONARY Audit Option  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/5_14_AUDIT_SELECT_ANY_DICTIONARY.log
        fi


echo "" >> ${FINALDIR}/5_14_AUDIT_SELECT_ANY_DICTIONARY.log


echo ""



echo ""

echo "*************************** End of this module 5.14 check ***************************" >> ${FINALDIR}/5_14_AUDIT_SELECT_ANY_DICTIONARY.log

echo "*********************************************************************************" >> ${FINALDIR}/5_14_AUDIT_SELECT_ANY_DICTIONARY.log

}

REP_Fn_5_15_AUDIT_GRANT_ANY_OBJ_PRIV(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/5_15_AUDIT_GRANT_ANY_OBJ_PRIV.sql

checker=`cat ${REPSQLDIR}/sql_5_15_AUDIT_GRANT_ANY_OBJ_PRIV.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_5_15_AUDIT_GRANT_ANY_OBJ_PRIV.log  >> ${FINALDIR}/5_15_AUDIT_GRANT_ANY_OBJ_PRIV.log


if [ ${checker} == 0 ];
        then
        echo ""  >>  ${FINALDIR}/5_15_AUDIT_GRANT_ANY_OBJ_PRIV.log
         echo " 5.15 Enable GRANT ANY OBJECT PRIVILEGE Audit Option  - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 5.15 Enable GRANT ANY OBJECT PRIVILEGE Audit Option  - AS PER CIS STANDARDS " >>  ${FINALDIR}/5_15_AUDIT_GRANT_ANY_OBJ_PRIV.log
        else
        echo ""  >>  ${FINALDIR}/5_15_AUDIT_GRANT_ANY_OBJ_PRIV.log

        echo " 5.15 Enable GRANT ANY OBJECT PRIVILEGE Audit Option - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
            echo " 5.15 Enable GRANT ANY OBJECT PRIVILEGE Audit Option  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/5_15_AUDIT_GRANT_ANY_OBJ_PRIV.log
        fi


echo "" >> ${FINALDIR}/5_15_AUDIT_GRANT_ANY_OBJ_PRIV.log


echo ""



echo ""

echo "*************************** End of this module 5.15 check ***************************" >> ${FINALDIR}/5_15_AUDIT_GRANT_ANY_OBJ_PRIV.log

echo "*********************************************************************************" >> ${FINALDIR}/5_15_AUDIT_GRANT_ANY_OBJ_PRIV.log

}

REP_Fn_5_16_AUDIT_GRANT_ANY_PRIV(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/5_16_AUDIT_GRANT_ANY_PRIV.sql

checker=`cat ${REPSQLDIR}/sql_5_15_AUDIT_GRANT_ANY_OBJ_PRIV.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_5_15_AUDIT_GRANT_ANY_OBJ_PRIV.log  >> ${FINALDIR}/5_16_AUDIT_GRANT_ANY_PRIV.log


if [ ${checker} == 0 ];
        then
        echo ""  >>  ${FINALDIR}/5_16_AUDIT_GRANT_ANY_PRIV.log
         echo " 5.16 Enable GRANT ANY PRIVILEGE Audit Option  - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 5.16 Enable GRANT ANY PRIVILEGE Audit Option  - AS PER CIS STANDARDS " >>  ${FINALDIR}/5_16_AUDIT_GRANT_ANY_PRIV.log
        else
        echo ""  >>  ${FINALDIR}/5_16_AUDIT_GRANT_ANY_PRIV.log

        echo " 5.16 Enable GRANT ANY PRIVILEGE Audit Option - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
            echo " 5.16 Enable GRANT ANY PRIVILEGE Audit Option  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/5_16_AUDIT_GRANT_ANY_PRIV.log
        fi


echo "" >> ${FINALDIR}/5_16_AUDIT_GRANT_ANY_PRIV.log


echo ""



echo ""

echo "*************************** End of this module 5.16 check ***************************" >> ${FINALDIR}/5_16_AUDIT_GRANT_ANY_PRIV.log

echo "*********************************************************************************" >> ${FINALDIR}/5_16_AUDIT_GRANT_ANY_PRIV.log

}

REP_Fn_5_17_AUDIT_DROP_ANY_PROC(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/5_17_AUDIT_DROP_ANY_PROC.sql

checker=`cat ${REPSQLDIR}/sql_5_17_AUDIT_DROP_ANY_PROC.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_5_17_AUDIT_DROP_ANY_PROC.log  >> ${FINALDIR}/5_17_AUDIT_DROP_ANY_PROC.log


if [ ${checker} == 0 ];
        then
        echo ""  >>  ${FINALDIR}/5_17_AUDIT_DROP_ANY_PROC.log
         echo " 5.17 Enable DROP ANY PROCEDURE Audit Option  - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 5.17 Enable DROP ANY PROCEDURE Audit Option  - AS PER CIS STANDARDS " >>  ${FINALDIR}/5_17_AUDIT_DROP_ANY_PROC.log
        else
        echo ""  >>  ${FINALDIR}/5_17_AUDIT_DROP_ANY_PROC.log

        echo " 5.17 Enable DROP ANY PROCEDURE Audit Option - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
            echo " 5.17 Enable DROP ANY PROCEDURE Audit Option  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/5_17_AUDIT_DROP_ANY_PROC.log
        fi


echo "" >> ${FINALDIR}/5_17_AUDIT_DROP_ANY_PROC.log


echo ""



echo ""

echo "*************************** End of this module 5.17 check ***************************" >> ${FINALDIR}/5_17_AUDIT_DROP_ANY_PROC.log

echo "*********************************************************************************" >> ${FINALDIR}/5_17_AUDIT_DROP_ANY_PROC.log

}

REP_Fn_5_18_AUDIT_ALL_SYS_AUD(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/5_18_AUDIT_ALL_SYS_AUD.sql

checker=`cat ${REPSQLDIR}/sql_5_18_AUDIT_ALL_SYS_AUD.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_5_18_AUDIT_ALL_SYS_AUD.log  >> ${FINALDIR}/5_18_AUDIT_ALL_SYS_AUD.log


if [ ${checker} == 0 ];
        then
        echo ""  >>  ${FINALDIR}/5_18_AUDIT_ALL_SYS_AUD.log
         echo " 5.18 Enable ALL Audit Option on SYS.AUD$  - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 5.18 Enable ALL Audit Option on SYS.AUD$  - AS PER CIS STANDARDS " >>  ${FINALDIR}/5_18_AUDIT_ALL_SYS_AUD.log
        else
        echo ""  >>  ${FINALDIR}/5_18_AUDIT_ALL_SYS_AUD.log

        echo " 5.18 Enable ALL Audit Option on SYS.AUD$ - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
            echo " 5.18 Enable ALL Audit Option on SYS.AUD$  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/5_18_AUDIT_ALL_SYS_AUD.log
        fi


echo "" >> ${FINALDIR}/5_18_AUDIT_ALL_SYS_AUD.log


echo ""



echo ""

echo "*************************** End of this module 5.18 check ***************************" >> ${FINALDIR}/5_18_AUDIT_ALL_SYS_AUD.log

echo "*********************************************************************************" >> ${FINALDIR}/5_18_AUDIT_ALL_SYS_AUD.log

}

REP_Fn_5_19_AUDIT_PROCEDURE(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/5_19_AUDIT_PROCEDURE.sql

checker=`cat ${REPSQLDIR}/sql_5_19_AUDIT_PROCEDURE.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_5_19_AUDIT_PROCEDURE.log  >> ${FINALDIR}/5_19_AUDIT_PROCEDURE.log


if [ ${checker} == 0 ];
        then
        echo ""  >>  ${FINALDIR}/5_19_AUDIT_PROCEDURE.log
         echo " 5.19 Enable PROCEDURE Audit Option  - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 5.19 Enable PROCEDURE Audit Option  - AS PER CIS STANDARDS " >>  ${FINALDIR}/5_19_AUDIT_PROCEDURE.log
        else
        echo ""  >>  ${FINALDIR}/5_19_AUDIT_PROCEDURE.log

        echo " 5.19 Enable PROCEDURE Audit Option - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
            echo " 5.19 Enable PROCEDURE Audit Option  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/5_19_AUDIT_PROCEDURE.log
        fi


echo "" >> ${FINALDIR}/5_19_AUDIT_PROCEDURE.log


echo ""



echo ""

echo "*************************** End of this module 5.19 check ***************************" >> ${FINALDIR}/5_19_AUDIT_PROCEDURE.log

echo "*********************************************************************************" >> ${FINALDIR}/5_19_AUDIT_PROCEDURE.log

}

REP_Fn_5_20_AUDIT_ALETR_SYSTEM(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/5_20_AUDIT_ALETR_SYSTEM.sql

checker=`cat ${REPSQLDIR}/sql_5_20_AUDIT_ALETR_SYSTEM.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_5_20_AUDIT_ALETR_SYSTEM.log  >> ${FINALDIR}/5_20_AUDIT_ALETR_SYSTEM.log


if [ ${checker} == 0 ];
        then
        echo ""  >>  ${FINALDIR}/5_20_AUDIT_ALETR_SYSTEM.log
         echo " 5.20 Enable ALTER SYSTEM Audit Option  - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 5.20 Enable ALTER SYSTEM Audit Option  - AS PER CIS STANDARDS " >>  ${FINALDIR}/5_20_AUDIT_ALETR_SYSTEM.log
        else
        echo ""  >>  ${FINALDIR}/5_20_AUDIT_ALETR_SYSTEM.log

        echo " 5.20 Enable ALTER SYSTEM Audit Option - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
            echo " 5.20 Enable ALTER SYSTEM Audit Option  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/5_20_AUDIT_ALETR_SYSTEM.log
        fi


echo "" >> ${FINALDIR}/5_20_AUDIT_ALETR_SYSTEM.log


echo ""



echo ""

echo "*************************** End of this module 5.20 check ***************************" >> ${FINALDIR}/5_20_AUDIT_ALETR_SYSTEM.log

echo "*********************************************************************************" >> ${FINALDIR}/5_20_AUDIT_ALETR_SYSTEM.log

}

REP_Fn_5_21_AUDIT_TRIGGER(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/5_21_AUDIT_TRIGGER.sql

checker=`cat ${REPSQLDIR}/sql_5_21_AUDIT_TRIGGER.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_5_21_AUDIT_TRIGGER.log  >> ${FINALDIR}/5_21_AUDIT_TRIGGER.log


if [ ${checker} == 0 ];
        then
        echo ""  >>  ${FINALDIR}/5_21_AUDIT_TRIGGER.log
         echo " 5.21 Enable TRIGGER Audit Option  - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 5.21 Enable TRIGGER Audit Option  - AS PER CIS STANDARDS " >>  ${FINALDIR}/5_21_AUDIT_TRIGGER.log
        else
        echo ""  >>  ${FINALDIR}/5_21_AUDIT_TRIGGER.log

        echo " 5.21 Enable TRIGGER Audit Option - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
            echo " 5.21 Enable TRIGGER Audit Option  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/5_21_AUDIT_TRIGGER.log
        fi


echo "" >> ${FINALDIR}/5_21_AUDIT_TRIGGER.log


echo ""



echo ""

echo "*************************** End of this module 5.21 check ***************************" >> ${FINALDIR}/5_21_AUDIT_TRIGGER.log

echo "*********************************************************************************" >> ${FINALDIR}/5_21_AUDIT_TRIGGER.log

}

REP_Fn_5_22_AUDIT_CREATE_SESSION(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/5_22_AUDIT_CREATE_SESSION.sql

checker=`cat ${REPSQLDIR}/sql_5_22_AUDIT_CREATE_SESSION.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_5_22_AUDIT_CREATE_SESSION.log  >> ${FINALDIR}/5_22_AUDIT_CREATE_SESSION.log


if [ ${checker} == 0 ];
        then
        echo ""  >>  ${FINALDIR}/5_22_AUDIT_CREATE_SESSION.log
         echo " 5.22 Enable CREATE SESSION Audit Option  - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 5.22 Enable CREATE SESSION Audit Option  - AS PER CIS STANDARDS " >>  ${FINALDIR}/5_22_AUDIT_CREATE_SESSION.log
        else
        echo ""  >>  ${FINALDIR}/5_22_AUDIT_CREATE_SESSION.log

        echo " 5.22 Enable CREATE SESSION Audit Option - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
            echo " 5.22 Enable CREATE SESSION Audit Option  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/5_22_AUDIT_CREATE_SESSION.log
        fi


echo "" >> ${FINALDIR}/5_22_AUDIT_CREATE_SESSION.log


echo ""



echo ""

echo "*************************** End of this module 5.22 check ***************************" >> ${FINALDIR}/5_22_AUDIT_CREATE_SESSION.log

echo "*********************************************************************************" >> ${FINALDIR}/5_22_AUDIT_CREATE_SESSION.log

}

######################### SECTION 5 ENDS HERE #########################

consolidation() {

printf "********************************************************************"
echo  ""
echo "Consolidated Success CIS report:  "
cat ${FINALDIR}/CIS_Success.log

echo ""
printf "********************************************************************"
echo ""
echo "Consolidated Failure CIS report:  "

 if [ -f  ${FINALDIR}/CIS_Failure.log ]
        then
        cat ${FINALDIR}/CIS_Failure.log
        else
        echo " No Failures..."
fi

echo ""

printf "***************************************************************************************"


cat ${FINALDIR}/1_patch_artifact.log > ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/1_2_DEF_Pass.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/1_3_DEF_SCHEM_DROP.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/2_1_1_SECURE_LIST.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/2_1_2_EXTPROC_LIST.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/2_1_3_ADMIN_RESTRCT_LIST.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/2_1_4_SECURE_REG.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/2_2_1_AUDSYS.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/2_2_2_AUDTRAIL.log  >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/2_2_3_GLOB_NAM.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/2_2_4_LOC_LIS.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/2_2_6_OS_ROLE.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/2_2_7_DICTIONARY_ACCESSIBILITY.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/2_2_8_Rem_Login_Pwdfile.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/2_2_9_REM_OS.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/2_2_10_REM_OS_ROLES.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/2_2_12_SEC_CASE_SENSITIVE_LOGON.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/2_2_13_SEC_MAX_FAILED_LOGIN.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/2_2_14_SEC_ERROR_FURTHER_ACTION.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/2_2_15_SEC_ERROR_TRACE_ACTION.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/2_2_16_SEC_RETURN_SERVER_BANNER.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/2_2_17_SQL92_SECURITY.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/2_2_18_TRACE_FILES_PUBLIC.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/2_2_19_RESOURCE_LIMIT.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/3_1_PROFILE_FAILED_LOGIN.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/3_2_PROFILE_PASSWORD_LOCK.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/3_3_PROFILE_PASSWORD_LIFE.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/3_4_PROFILE_PASSWORD_REUSE.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/3_5_PROFILE_PASSWORD_REUSE_TIME.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/3_6_PROFILE_PASSWORD_GRACE_TIME.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/3_7_DBA_USERS_PASSWORD.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/3_8_PROFILE_PASSWORD_VERIFY.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/3_9_PROFILE_SESSIONS_PER_USER.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/3_10_USERS_WITH_DEFAULT_PROFILE.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/4_1_1_PRIVILEGE_PACKAGES_OBJECTS.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/4_1_2_DBMS_CRYPTO.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/4_1_3_DBMS_JAVA.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/4_1_4_DBMS_JAVA_TEST.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/4_1_5_DBMS_JOB.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/4_1_6_DBMS_LDAP.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/4_1_7_DBMS_LOB.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/4_1_8_DBMS_OBFUSCATION_TOOLKIT.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/4_1_9_DBMS_BACKUP_RESTORE.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/4_1_10_DBMS_SCHEDULER.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/4_1_11_DBMS_SQL.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/4_1_12_DBMS_XMLGEN.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/4_1_13_DBMS_XMLQUERY.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/4_1_14_UTL_FILE.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/4_1_15_UTL_INADDR.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/4_1_16_UTL_TCP.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/4_1_17_UTL_MAIL.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/4_1_18_UTL_SMTP.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/4_1_19_UTL_DBWS.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/4_1_20_UTL_ORAMTS.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/4_1_21_UTL_HTTP.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/4_1_22_HTTPURITYPE.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/4_2_1_DBMS_SYS_SQL.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/4_2_2_DBMS_BACKUP_RESTORE.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/4_2_3_DBMS_AQADM_SYSCALLS.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/4_2_4_DBMS_REPACT_SQL_UTL.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/4_2_5_INITJVMAUX.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/4_2_6_DBMS_STREAMS_ADM_UTL.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/4_2_7_DBMS_AQADM_SYS.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/4_2_8_DBMS_STREAMS_RPC.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/4_2_9_DBMS_PRVTAQIM.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/4_2_10_LTADM.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/4_2_11_WWV_DBMS_SQL.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/4_2_12_WWV_EXECUTE_IMMEDIATE.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/4_2_13_DBMS_IJOB.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/4_2_14_DBMS_FILE_TRANSFER.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/4_3_1_SELECT_ANY_DICTIONARY.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/4_3_2_SELECT_ANY_TABLE.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/4_3_3_AUDIT_SYSTEM.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/4_3_4_EXEMPT_ACCESS_POLICY.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/4_3_5_BECOME_USER.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/4_3_6_CREATE_PROCEDURE.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/4_3_7_ALTER_SYSTEM.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/4_3_8_CREATE_ANY_LIBRARY.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/4_3_9_CREATE_LIBRARY.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/4_3_10_GRANT_ANY_OBJECT_PRIV.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/4_3_11_GRANT_ANY_ROLE.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/4_3_12_GRANT_ANY_PRIV.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/4_4_1_DELETE_CATALOG_ROLE.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/4_4_2_SELECT_CATALOG_ROLE.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/4_4_3_EXECUTE_CATALOG_ROLE.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/4_4_4_REVOKE_DBA.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/4_5_1_REV_ALL_AUD.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/4_5_2_REV_ALL_USER_HISTORY.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/4_5_3_REV_ALL_LINK.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/4_5_4_REV_ALL_SYS_USER.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/4_5_5_REV_ALL_DBA.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/4_5_6_REV_ALL_SYS_SCHEDULER_CREDENTIAL.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/4_5_7_DROP_SYS_USER_MIG.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/4_6_REV_ANY.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/4_7_REV_DBA_SYS_PRIVS.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/4_8_PROXY_USER_PRIV.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/4_9_REV_EXE_ANY_PROC_OUTLN.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/4_10_REV_EXE_ANY_PROC_DBSNMP.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/5_1_AUDIT_USER.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/5_2_AUDIT_ALETR_USER.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/5_3_AUDIT_DROP_USER.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/5_4_AUDIT_ROLE.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/5_5_AUDIT_SYSTEM_GRANT.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/5_6_AUDIT_PROFILE.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/5_7_AUDIT_ALETR_PROFILE.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/5_8_AUDIT_DROP_PROFILE.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/5_9_AUDIT_DATABASE_LINK.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/5_10_AUDIT_PUBLIC_DATABASE_LINK.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/5_11_AUDIT_PUBLIC_SYNONYM.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/5_12_AUDIT_SYNONYM.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/5_13_AUDIT_GRANT_DIRECTORY.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/5_14_AUDIT_SELECT_ANY_DICTIONARY.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/5_15_AUDIT_GRANT_ANY_OBJ_PRIV.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/5_16_AUDIT_GRANT_ANY_PRIV.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/5_17_AUDIT_DROP_ANY_PROC.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/5_18_AUDIT_ALL_SYS_AUD.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/5_19_AUDIT_PROCEDURE.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/5_20_AUDIT_ALETR_SYSTEM.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/5_21_AUDIT_TRIGGER.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/5_22_AUDIT_CREATE_SESSION.log >> ${FINALDIR}/Final_OP.log
echo "*************************** Final Output ***************************"

cat  ${FINALDIR}/Final_OP.log

}

fn_reporting(){

        REP_Fn_1_patch_artifact
        REP_Fn_1_2_DEF_Pass
        REP_Fn_1_3_DEF_SCHEM_DROP
        REP_Fn_2_1_LIST_HARD
        REP_Fn_2_2_1_AUDSYS
        REP_Fn_2_2_2_AUDTRAIL
        REP_Fn_2_2_3_GLOB_NAM
        REP_Fn_2_2_4_LOC_LIS
        REP_Fn_2_2_6_OS_ROLE
        REP_Fn_2_2_7_DICTIONARY_ACCESSIBILITY
        REP_Fn_2_2_8_Rem_Login_Pwdfile
        REP_Fn_2_2_9_REM_OS_AUTH
        REP_Fn_2_2_10_REM_OS_ROLES
        REP_Fn_2_2_12_SEC_CASE_SENSITIVE_LOGON
        REP_Fn_2_2_13_SEC_MAX_FAILED_LOGIN
        REP_Fn_2_2_14_SEC_ERROR_FURTHER_ACTION
        REP_Fn_2_2_15_SEC_ERROR_TRACE_ACTION
        REP_Fn_2_2_16_SEC_RETURN_SERVER_BANNER
        REP_Fn_2_2_17_SQL92_SECURITY
        REP_Fn_2_2_18_TRACE_FILES_PUBLIC
        REP_Fn_2_2_19_RESOURCE_LIMIT
        REP_Fn_3_1_PROFILE_FAILED_LOGIN
        REP_Fn_3_2_PROFILE_PASSWORD_LOCK
        REP_Fn_3_3_PROFILE_PASSWORD_LIFE
        REP_Fn_3_4_PROFILE_PASSWORD_REUSE
        REP_Fn_3_5_PROFILE_PASSWORD_REUSE_TIME
        REP_Fn_3_6_PROFILE_PASSWORD_GRACE_TIME
        REP_Fn_3_7_DBA_USERS_PASSWORD
        REP_Fn_3_8_PROFILE_PASSWORD_VERIFY
        REP_Fn_3_9_PROFILE_SESSIONS_PER_USER
        REP_Fn_3_10_USERS_WITH_DEFAULT_PROFILE
        REP_Fn_4_1_1_PRIVILEGE_PACKAGES_OBJECTS
        REP_Fn_4_1_2_DBMS_CRYPTO
        REP_Fn_4_1_3_DBMS_JAVA
        REP_Fn_4_1_4_DBMS_JAVA_TEST
        REP_Fn_4_1_5_DBMS_JOB
        REP_Fn_4_1_6_DBMS_LDAP
        REP_Fn_4_1_7_DBMS_LOB
        REP_Fn_4_1_8_DBMS_OBFUSCATION_TOOLKIT
        REP_Fn_4_1_9_DBMS_BACKUP_RESTORE
        REP_Fn_4_1_10_DBMS_SCHEDULER
        REP_Fn_4_1_11_DBMS_SQL
        REP_Fn_4_1_12_DBMS_XMLGEN
        REP_Fn_4_1_13_DBMS_XMLQUERY
        REP_Fn_4_1_14_UTL_FILE
        REP_Fn_4_1_15_UTL_INADDR
        REP_Fn_4_1_16_UTL_TCP
        REP_Fn_4_1_17_UTL_MAIL
        REP_Fn_4_1_18_UTL_SMTP
        REP_Fn_4_1_19_UTL_DBWS
        REP_Fn_4_1_20_UTL_ORAMTS
        REP_Fn_4_1_21_UTL_HTTP
        REP_Fn_4_1_22_HTTPURITYPE
        REP_Fn_4_2_1_DBMS_SYS_SQL
        REP_Fn_4_2_2_DBMS_BACKUP_RESTORE
        REP_Fn_4_2_3_DBMS_AQADM_SYSCALLS
        REP_Fn_4_2_4_DBMS_REPACT_SQL_UTL
        REP_Fn_4_2_5_INITJVMAUX
        REP_Fn_4_2_6_DBMS_STREAMS_ADM_UTL
        REP_Fn_4_2_7_DBMS_AQADM_SYS
        REP_Fn_4_2_8_DBMS_STREAMS_RPC
        REP_Fn_4_2_9_DBMS_PRVTAQIM
        REP_Fn_4_2_10_LTADM
        REP_Fn_4_2_11_WWV_DBMS_SQL
        REP_Fn_4_2_12_WWV_EXECUTE_IMMEDIATE
        REP_Fn_4_2_13_DBMS_IJOB
        REP_Fn_4_2_14_DBMS_FILE_TRANSFER
        REP_Fn_4_3_1_SELECT_ANY_DICTIONARY
        REP_Fn_4_3_2_SELECT_ANY_TABLE
        REP_Fn_4_3_3_AUDIT_SYSTEM
        REP_Fn_4_3_4_EXEMPT_ACCESS_POLICY
        REP_Fn_4_3_5_BECOME_USER
        REP_Fn_4_3_6_CREATE_PROCEDURE
        REP_Fn_4_3_7_ALTER_SYSTEM
        REP_Fn_4_3_8_CREATE_ANY_LIBRARY
        REP_Fn_4_3_9_CREATE_LIBRARY
        REP_Fn_4_3_10_GRANT_ANY_OBJECT_PRIV
        REP_Fn_4_3_11_GRANT_ANY_ROLE
        REP_Fn_4_3_12_GRANT_ANY_PRIV
        REP_Fn_4_4_1_DELETE_CATALOG_ROLE
        REP_Fn_4_4_2_SELECT_CATALOG_ROLE
        REP_Fn_4_4_3_EXECUTE_CATALOG_ROLE
        REP_Fn_4_4_4_REVOKE_DBA
        REP_Fn_4_5_1_REV_ALL_AUD
        REP_Fn_4_5_2_REV_ALL_USER_HISTORY
        REP_Fn_4_5_3_REV_ALL_LINK
        REP_Fn_4_5_4_REV_ALL_SYS_USER
        REP_Fn_4_5_5_REV_ALL_DBA
        REP_Fn_4_5_6_REV_ALL_SYS_SCHEDULER_CREDENTIAL
        REP_Fn_4_5_7_DROP_SYS_USER_MIG
        REP_Fn_4_6_REV_ANY
        REP_Fn_4_7_REV_DBA_SYS_PRIVS
        REP_Fn_4_8_PROXY_USER_PRIV
        REP_Fn_4_9_REV_EXE_ANY_PROC_OUTLN
        REP_Fn_4_10_REV_EXE_ANY_PROC_DBSNMP
        REP_Fn_5_1_AUDIT_USER
        REP_Fn_5_2_AUDIT_ALETR_USER
        REP_Fn_5_3_AUDIT_DROP_USER
        REP_Fn_5_4_AUDIT_ROLE
        REP_Fn_5_5_AUDIT_SYSTEM_GRANT
        REP_Fn_5_6_AUDIT_PROFILE
        REP_Fn_5_7_AUDIT_ALETR_PROFILE
        REP_Fn_5_8_AUDIT_DROP_PROFILE
        REP_Fn_5_9_AUDIT_DATABASE_LINK
        REP_Fn_5_10_AUDIT_PUBLIC_DATABASE_LINK
        REP_Fn_5_11_AUDIT_PUBLIC_SYNONYM
        REP_Fn_5_12_AUDIT_SYNONYM
        REP_Fn_5_13_AUDIT_GRANT_DIRECTORY
        REP_Fn_5_14_AUDIT_SELECT_ANY_DICTIONARY
        REP_Fn_5_15_AUDIT_GRANT_ANY_OBJ_PRIV
        REP_Fn_5_16_AUDIT_GRANT_ANY_PRIV
        REP_Fn_5_17_AUDIT_DROP_ANY_PROC
        REP_Fn_5_18_AUDIT_ALL_SYS_AUD
        REP_Fn_5_19_AUDIT_PROCEDURE
        REP_Fn_5_20_AUDIT_ALETR_SYSTEM
        REP_Fn_5_21_AUDIT_TRIGGER
        REP_Fn_5_22_AUDIT_CREATE_SESSION
        consolidation
}

fn_exec_hardening(){

        Exec_Fn_1_HARDEN
        Exec_Fn_REV_HARDEN_4
        Exec_fn_2_1_LIST_HARD

}


fn_exec_hardening
Exec_fn_2_2_4_LOC_LIST
fn_reporting#!/bin/bash
SHELLDIR=/home/oracle/shell_scr/db_harden
FINALDIR=${SHELLDIR}/OPDIR
HARDENDIR=${FINALDIR}/HRDSQLDIR
REPSQLDIR=${SHELLDIR}/rep_sqls
mkdir  -p ${SHELLDIR}
mkdir  -p ${FINALDIR}
mkdir  -p ${HARDENDIR}
cat /etc/oratab | grep -v + | tail -1 | tr ":"  "\n" | head -1 > ${SHELLDIR}/DBNAME.out
cat /etc/oratab | grep -v + | tail -1 | tr ":"  "\n" | head -2 | tail -1  > ${SHELLDIR}/OHOME.out

rm -rf ${FINALDIR}/*.log

DBNAME=`cat ${SHELLDIR}/DBNAME.out`
OHOME=`cat ${SHELLDIR}/OHOME.out`

clear
echo "***************************************************************************************"
echo "*                   DATABASE HARDENING AUTOMATIONION SCRIPT                         *"
echo "*             ! This Script is to harden params in the Oracle Database as per CSI  !           *"
echo "*                     Please proceed the information's below                          *"
echo "*            No Intervention required                                             *"
echo "***************************************************************************************"

REP_Fn_1_patch_artifact(){
echo "****************************************************************************************" > ${FINALDIR}/1_patch_artifact.log
echo ""
echo ""  >> ${FINALDIR}/1_patch_artifact.log

echo "  1. Patching Information "  >> ${FINALDIR}/1_patch_artifact.log

echo ""  >> ${FINALDIR}/1_patch_artifact.log
echo ""  >> ${FINALDIR}/1_patch_artifact.log

${OHOME}/OPatch/opatch lsinventory | grep -A 34 "Local Machine Information"  >> ${FINALDIR}/1_patch_artifact.log

patch_appl=`${OHOME}/OPatch/opatch lsinventory | grep applied | head -1`

patch_in_sec=`echo ${patch_appl} | cut -d " " -f7,8,9`

curr_sec=`date +%s`
patch_in_sec=`date -d "$dat" +%s`

echo "" >> ${FINALDIR}/1_patch_artifact.log
echo >> ${FINALDIR}/1_patch_artifact.log

 diff_var=`expr ${curr_sec} - ${patch_in_sec}`

                if [ ${diff_var} -gt 10520000  ];
                then
                echo " 1. Patching Information - NOT AS PER CIS STANDARDS.. Need Attention!! "  > ${FINALDIR}/CIS_Failure.log
                                echo " 1. Patching Information - NOT AS PER CIS STANDARDS.. Need Attention!! "  >> ${FINALDIR}/1_patch_artifact.log
                else
                echo " 1. Patching Information - AS PER CIS STANDARDS." > ${FINALDIR}/CIS_Success.log
                                echo " 1. Patching Information - AS PER CIS STANDARDS"  >> ${FINALDIR}/1_patch_artifact.log
                fi

echo ""  >> ${FINALDIR}/1_patch_artifact.log

echo ""

echo ""

echo "*************************** End of this module 1.1 check....***************************" >> ${FINALDIR}/1_patch_artifact.log
echo "*********************************************************************************" >>  ${FINALDIR}/1_patch_artifact.log
}

######################### 1.1 ENDS HERE ##############################################################

REP_Fn_1_2_DEF_Pass(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/1_2_Def_Pass.sql


checker=`cat ${REPSQLDIR}/1_2_DEF_Sql.log | grep "no rows selected" | wc -l`

cat ${REPSQLDIR}/1_2_DEF_Sql.log  >> ${FINALDIR}/1_2_DEF_Pass.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/1_2_DEF_Pass.log
         echo " 1.2 Ensure All Default Passwords are changed - AS PER CIS STANDARDS" >>  ${FINALDIR}/CIS_Success.log
            echo " 1.2 Ensure All Default Passwords are changed - AS PER CIS STANDARDS" >>  ${FINALDIR}/1_2_DEF_Pass.log
        else
        echo ""  >>  ${FINALDIR}/1_2_DEF_Pass.log

        echo " 1.2  Ensure All Default Passwords are changed - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/CIS_Failure.log
                echo " 1.2  Ensure All Default Passwords are changed - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/1_2_DEF_Pass.log
        fi


echo ""

echo ""


echo "" >> ${FINALDIR}/1_2_DEF_Pass.log
echo "***************************End of this module 1.2 check....***************************" >> ${FINALDIR}/1_2_DEF_Pass.log


echo "*********************************************************************************" >> ${FINALDIR}/1_2_DEF_Pass.log

}

######################### 1.2 ENDS HERE ##############################################################

REP_Fn_1_3_DEF_SCHEM_DROP(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/1_3_Def_Schem.sql


checker=`cat ${REPSQLDIR}/1_3_DEF_Schem.log | grep "no rows selected" | wc -l`

cat ${REPSQLDIR}/1_3_DEF_Schem.log  >> ${FINALDIR}/1_3_DEF_SCHEM_DROP.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/1_3_DEF_SCHEM_DROP.log
         echo " 1.3 Ensure All Default schemas are dropped - AS PER CIS STANDARDS" >>  ${FINALDIR}/CIS_Success.log
            echo " 1.3 Ensure All Default schemas are dropped  - AS PER CIS STANDARDS" >>  ${FINALDIR}/1_3_DEF_SCHEM_DROP.log
        else
        echo ""  >>  ${FINALDIR}/1_3_DEF_SCHEM_DROP.log

        echo " 1.3 Ensure All Default schemas are dropped  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/CIS_Failure.log
                echo " 1.3 Ensure All Default schemas are dropped  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/1_3_DEF_SCHEM_DROP.log
        fi


echo "" >> ${FINALDIR}/1_3_DEF_SCHEM_DROP.log


echo ""



echo ""

echo "*************************** End of this module 1.3 check ***************************" >> ${FINALDIR}/1_3_DEF_SCHEM_DROP.log

echo "*********************************************************************************" >> ${FINALDIR}/1_3_DEF_SCHEM_DROP.log

}

######################### 1.3 ENDS HERE ##############################################################

REP_Fn_2_1_LIST_HARD() {

LIS_OWNER=`ps -ef | grep tnslsnr  | grep -v grep | awk {'print $1'}`

LIS_NAME=`ps -ef | grep tnslsnr  | grep -v grep | awk {'print $9'}`

${OHOME}/bin/lsnrctl status ${LIS}


LIS_PART_HOME=`ps -ef | grep tnslsnr  | grep -v grep | awk {'print $8'} | awk '{ sub("/[^/]*$", ""); print }' | awk '{ sub("/[^/]*$", ""); print }'`
LIS_LOCATION=${LIS_PART_HOME}/network/admin/listener.ora

checker=`sudo grep -i "SECURE_CONTROL_${LIS_NAME}" ${LIS_LOCATION} | wc -l`
checker_desc=`sudo grep -i "SECURE_CONTROL" ${LIS_LOCATION}`

ext_proc_check=`sudo grep -i "extproc" ${LIS_LOCATION} | wc -l`
ext_proc_check_desc=`sudo grep -i "extproc" ${LIS_LOCATION}`


admin_check=`sudo grep -i "admin_restrictions" ${LIS_LOCATION} | wc -l`
admin_check_desc=`sudo grep -i "admin_restrictions" ${LIS_LOCATION}`


sec_reg_check=`sudo grep -i "secure_register" ${LIS_LOCATION} | wc -l`
sec_reg_check_desc=`sudo grep -i "secure_register" ${LIS_LOCATION}`




if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/2_1_1_SECURE_LIST.log
         echo " 2.1.1 Ensure Secure Control Listener is Set  - AS PER CIS STANDARDS" >>  ${FINALDIR}/CIS_Success.log
            echo " 2.1.1 Ensure Secure Control Listener is Set   - AS PER CIS STANDARDS" >>  ${FINALDIR}/2_1_1_SECURE_LIST.log
        else
        echo ""  >>  ${FINALDIR}/2_1_1_SECURE_LIST.log

        echo " 2.1.1 Ensure Secure Control Listener is Set   - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/CIS_Failure.log
                echo " 2.1.1 Ensure Secure Control Listener is Set   - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/2_1_1_SECURE_LIST.log
        fi


echo "" >> ${FINALDIR}/2_1_1_SECURE_LIST.log
echo " ${checker_desc} " >> ${FINALDIR}/2_1_1_SECURE_LIST.log
echo ""

echo ""


if [ ${ext_proc_check} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/2_1_2_EXTPROC_LIST.log
         echo " 2.1.2 Ensure Extproc is removed  - NOT AS PER CIS STANDARDS.. Need Attention" >>  ${FINALDIR}/CIS_Failure.log
            echo " 2.1.2 Ensure Extproc is removed   - NOT AS PER CIS STANDARDS.. Need Attention" >>  ${FINALDIR}/2_1_2_EXTPROC_LIST.log
        else
        echo ""  >>  ${FINALDIR}/2_1_2_EXTPROC_LIST.log

        echo " 2.1.2 Ensure Extproc is removed   -  AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
                echo " 2.1.2 Ensure Extproc is removed   -  AS PER CIS STANDARDS " >>  ${FINALDIR}/2_1_2_EXTPROC_LIST.log
fi


echo ""

echo ""



if [ ${admin_check} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/2_1_3_ADMIN_RESTRCT_LIST.log
         echo " 2.1.3 Ensure Admin restriction is Set  -  AS PER CIS STANDARDS" >>  ${FINALDIR}/CIS_Success.log
            echo " 2.1.3 Ensure Admin restriction is Set   -  AS PER CIS STANDARDS" >>  ${FINALDIR}/2_1_3_ADMIN_RESTRCT_LIST.log
        else
        echo ""  >>  ${FINALDIR}/2_1_3_ADMIN_RESTRCT_LIST.log

        echo " 2.1.3 Ensure Admin restriction is Set   - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/CIS_Failure.log
                echo " 2.1.3 Ensure Admin restriction is Set   - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/2_1_3_ADMIN_RESTRCT_LIST.log
fi
echo " ${admin_check_desc} " >> ${FINALDIR}/2_1_3_ADMIN_RESTRCT_LIST.log

echo ""

echo ""


if [ ${sec_reg_check} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/2_1_4_SECURE_REG.log
         echo " 2.1.4 Ensure Secure Registration is Set to TCP/IPC -  AS PER CIS STANDARDS" >>  ${FINALDIR}/CIS_Success.log
            echo " 2.1.4 Ensure Secure Registration is Set to TCP/IPC -  AS PER CIS STANDARDS" >>  ${FINALDIR}/2_1_4_SECURE_REG.log
        else
        echo ""  >>  ${FINALDIR}/2_1_4_SECURE_REG.log

        echo " 2.1.4 Ensure Secure Registration is Set to TCP/IPC - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/CIS_Failure.log
                echo " 2.1.4 Ensure Secure Registration is Set to TCP/IPC - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/2_1_4_SECURE_REG.log
fi

echo " ${sec_reg_check_desc} " >> ${FINALDIR}/2_1_4_SECURE_REG.log
echo ""

echo ""






echo " *************************** End of this module 2.1.1, 2.1.2, 2.1.3 and 2.1.4 check..***************************" >> ${FINALDIR}/2_1_4_SECURE_REG.log

echo ""

echo "*******************************"



}

######################### 2.1.1 ENDS HERE ##############################################################

REP_Fn_2_2_1_AUDSYS(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/2_2_1_Aud_SYS.sql


checker=`cat ${REPSQLDIR}/2_2_1_Aud_SYS.log | grep -i "TRUE" | wc -l`

cat ${REPSQLDIR}/2_2_1_Aud_SYS.log  >> ${FINALDIR}/2_2_1_AUDSYS.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/2_2_1_AUDSYS.log
         echo " 2.2.1 Ensure SYS AUDIT OPERATION ARE ENABLED - AS PER CIS STANDARDS" >>  ${FINALDIR}/CIS_Success.log
            echo "2.2.1 Ensure SYS AUDIT OPERATION ARE ENABLED  - AS PER CIS STANDARDS" >>  ${FINALDIR}/2_2_1_AUDSYS.log
        else
        echo ""  >>  ${FINALDIR}/2_2_1_AUDSYS.log

        echo " 2.2.1 Ensure SYS AUDIT OPERATION ARE ENABLED   - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/CIS_Failure.log
                echo " 2.2.1 Ensure SYS AUDIT OPERATION ARE ENABLED   - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/2_2_1_AUDSYS.log
        fi


echo "" >> ${FINALDIR}/2_2_1_AUDSYS.log


echo ""



echo ""

echo "*************************** End of this module 2.2.1 check ***************************" >> ${FINALDIR}/2_2_1_AUDSYS.log

echo "*********************************************************************************" >> ${FINALDIR}/2_2_1_AUDSYS.log

}

REP_Fn_2_2_2_AUDTRAIL(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/2_2_2_Aud_TRAIL.sql


checker=`cat ${REPSQLDIR}/sql_2_2_2_Aud_SYS.log | grep -i "None" | wc -l`

cat ${REPSQLDIR}/sql_2_2_2_Aud_SYS.log  >> ${FINALDIR}/2_2_2_AUDTRAIL.log


if [ ${checker} != 1 ];
        then
        echo ""  >>  ${FINALDIR}/2_2_2_AUDTRAIL.log
         echo " 2.2.2 Ensure AUDIT Trail is not set to NONE  - AS PER CIS STANDARDS" >>  ${FINALDIR}/CIS_Success.log
            echo "2.2.2 Ensure AUDIT Trail is not set to NONE  - AS PER CIS STANDARDS" >>  ${FINALDIR}/2_2_2_AUDTRAIL.log
        else
        echo ""  >>  ${FINALDIR}/2_2_2_AUDTRAIL.log

        echo " 2.2.2 Ensure AUDIT Trail is not set to NONE    - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/CIS_Failure.log
                echo " 2.2.2 Ensure AUDIT Trail is not set to NONE   - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/2_2_2_AUDTRAIL.log
        fi


echo "" >> ${FINALDIR}/2_2_2_AUDTRAIL.log


echo ""



echo ""

echo "*************************** End of this module 2.2.2 check ***************************" >> ${FINALDIR}/2_2_2_AUDTRAIL.log

echo "*********************************************************************************" >> ${FINALDIR}/2_2_2_AUDTRAIL.log

}

REP_Fn_2_2_3_GLOB_NAM(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/2_2_3_Gb_names.sql


checker=`cat ${REPSQLDIR}/sql_2_2_3_Gb_names.log | grep -i "True" | wc -l`

cat ${REPSQLDIR}/sql_2_2_2_Aud_SYS.log  >> ${FINALDIR}/2_2_3_GLOB_NAM.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/2_2_3_GLOB_NAM.log
         echo " 2.2.3 Ensure Global Names are set to True - AS PER CIS STANDARDS" >>  ${FINALDIR}/CIS_Success.log
            echo "2.2.3 Ensure Global Names are set to True - AS PER CIS STANDARDS" >>  ${FINALDIR}/2_2_3_GLOB_NAM.log
        else
        echo ""  >>  ${FINALDIR}/2_2_3_GLOB_NAM.log

        echo " 2.2.3 Ensure Global Names are set to True   - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/CIS_Failure.log
                echo " 2.2.3 Ensure Global Names are set to True  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/2_2_3_GLOB_NAM.log
        fi


echo "" >> ${FINALDIR}/2_2_3_GLOB_NAM.log


echo ""



echo ""

echo "*************************** End of this module 2.2.3 check ***************************" >> ${FINALDIR}/2_2_3_GLOB_NAM.log

echo "*********************************************************************************" >> ${FINALDIR}/2_2_3_GLOB_NAM.log

}

REP_Fn_2_2_4_LOC_LIS(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/2_2_4_Loc_Lis.sql


checker=`cat ${REPSQLDIR}/sql_2_2_4_LOC_LIS.log | grep -i "Description" | wc -l`

cat ${REPSQLDIR}/sql_2_2_4_LOC_LIS.log  >> ${FINALDIR}/2_2_4_LOC_LIS.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/2_2_4_LOC_LIS.log
         echo " 2.2.4 Ensure Local Listener is set to appropriate value - AS PER CIS STANDARDS" >>  ${FINALDIR}/CIS_Success.log
         echo "2.2.4 Ensure Local Listener is set to appropriate value  - AS PER CIS STANDARDS" >>  ${FINALDIR}/2_2_4_LOC_LIS.log
        else
        echo ""  >>  ${FINALDIR}/2_2_4_LOC_LIS.log

        echo " 2.2.4 Ensure Local Listener is set to appropriate value   - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/CIS_Failure.log
                echo " 2.2.4 Ensure Local Listener is set to appropriate value   - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/2_2_4_LOC_LIS.log
        fi


echo "" >> ${FINALDIR}/2_2_4_LOC_LIS.log


echo ""



echo ""

echo "*************************** End of this module 2.2.4 check ***************************" >> ${FINALDIR}/2_2_4_LOC_LIS.log

echo "*********************************************************************************" >> ${FINALDIR}/2_2_4_LOC_LIS.log

}

Exec_Fn_1_HARDEN(){


${OHOME}/bin/sqlplus "/ as sysdba"  @${SHELLDIR}/harden.sql
${OHOME}/bin/sqlplus "/ as sysdba"  @${SHELLDIR}/harden_4.sql
${OHOME}/bin/sqlplus "/ as sysdba"  @${SHELLDIR}/revoke_harden_4.sql

  if [ -f ${HARDENDIR}/HARDEN_1_2_DEF_Sql.log ]
  then
  cat ${HARDENDIR}/HARDEN_1_2_DEF_Sql.log  > ${FINALDIR}/HARDENING_SQL.log
  else
  echo " Hardening Script has not executed "
  fi
}

Exec_Fn_REV_HARDEN_4(){

echo "set echo on" > ${SHELLDIR}/revoke_harden.sql

echo "spool ${SHELLDIR}/revoke_harden.log" >> ${SHELLDIR}/revoke_harden.sql


cat /home/oracle/shell_scr/db_harden/sql_4_3_1_Rev_SELECT_ANY_DICTIONARY.log | grep -v selected |  awk {'print "revoke " $2,$3,$4,$5,$6,$7 " from " $1 ";"'} | grep -v "revoke       from ;" >> ${SHELLDIR}/revoke_harden.sql

cat /home/oracle/shell_scr/db_harden/sql_4_3_2_Rev_SELECT_ANY_TABLE.log | grep -v selected |  awk {'print "revoke " $2,$3,$4,$5,$6,$7 " from " $1 ";"'} | grep -v "revoke       from ;" >> ${SHELLDIR}/revoke_harden.sql

cat /home/oracle/shell_scr/db_harden/sql_4_3_3_Rev_AUDIT_SYSTEM.log | grep -v selected |  awk {'print "revoke " $2,$3,$4,$5,$6,$7 " from " $1 ";"'} | grep -v "revoke       from ;" >> ${SHELLDIR}/revoke_harden.sql

cat /home/oracle/shell_scr/db_harden/sql_4_3_4_Rev_EXEMPT_ACCESS_POLICY.log | grep -v selected |  awk {'print "revoke " $2,$3,$4,$5,$6,$7 " from " $1 ";"'} | grep -v "revoke       from ;" >> ${SHELLDIR}/revoke_harden.sql

cat /home/oracle/shell_scr/db_harden/sql_4_3_5_Rev_BECOME_USER.log | grep -v selected |  awk {'print "revoke " $2,$3,$4,$5,$6,$7 " from " $1 ";"'} | grep -v "revoke       from ;" >> ${SHELLDIR}/revoke_harden.sql

cat /home/oracle/shell_scr/db_harden/sql_4_3_6_Rev_CREATE_PROCEDURE.log | grep -v selected |  awk {'print "revoke " $2,$3,$4,$5,$6,$7 " from " $1 ";"'} | grep -v "revoke       from ;" >> ${SHELLDIR}/revoke_harden.sql

cat /home/oracle/shell_scr/db_harden/sql_4_3_7_Rev_ALTER_SYSTEM.log | grep -v selected |  awk {'print "revoke " $2,$3,$4,$5,$6,$7 " from " $1 ";"'} | grep -v "revoke       from ;" >> ${SHELLDIR}/revoke_harden.sql

cat /home/oracle/shell_scr/db_harden/sql_4_3_8_Rev_CREATE_ANY_LIBRARY.log | grep -v selected |  awk {'print "revoke " $2,$3,$4,$5,$6,$7 " from " $1 ";"'} | grep -v "revoke       from ;" >> ${SHELLDIR}/revoke_harden.sql

cat /home/oracle/shell_scr/db_harden/sql_4_3_9_Rev_CREATE_LIBRARY.log | grep -v selected |  awk {'print "revoke " $2,$3,$4,$5,$6,$7 " from " $1 ";"'} | grep -v "revoke       from ;" >> ${SHELLDIR}/revoke_harden.sql

cat /home/oracle/shell_scr/db_harden/sql_4_3_10_Rev_GRANT_ANY_OBJ_PRIV.log | grep -v selected |  awk {'print "revoke " $2,$3,$4,$5,$6,$7 " from " $1 ";"'} | grep -v "revoke       from ;" >> ${SHELLDIR}/revoke_harden.sql

cat /home/oracle/shell_scr/db_harden/sql_4_3_11_Rev_GRANT_ANY_ROLE.log | grep -v selected |  awk {'print "revoke " $2,$3,$4,$5,$6,$7 " from " $1 ";"'} | grep -v "revoke       from ;" >> ${SHELLDIR}/revoke_harden.sql

cat /home/oracle/shell_scr/db_harden/sql_4_3_12_Rev_GRANT_ANY_PRIVILEGE.log | grep -v selected |  awk {'print "revoke " $2,$3,$4,$5,$6,$7 " from " $1 ";"'} | grep -v "revoke       from ;" >> ${SHELLDIR}/revoke_harden.sql

cat /home/oracle/shell_scr/db_harden/sql_4_4_1_Rev_DELETE_CATALOG_ROLE.log | grep -v selected |  awk {'print "revoke " $2,$3,$4,$5,$6,$7 " from " $1 ";"'} | grep -v "revoke       from ;" >> ${SHELLDIR}/revoke_harden.sql

cat /home/oracle/shell_scr/db_harden/sql_4_4_2_Rev_SELECT_CATALOG_ROLE.log | grep -v selected |  awk {'print "revoke " $2,$3,$4,$5,$6,$7 " from " $1 ";"'} | grep -v "revoke       from ;" >> ${SHELLDIR}/revoke_harden.sql

cat /home/oracle/shell_scr/db_harden/sql_4_4_3_Rev_EXECUTE_CATALOG_ROLE.log | grep -v selected |  awk {'print "revoke " $2,$3,$4,$5,$6,$7 " from " $1 ";"'} | grep -v "revoke       from ;" >> ${SHELLDIR}/revoke_harden.sql

cat /home/oracle/shell_scr/db_harden/sql_4_4_4_Rev_DBA.log | grep -v selected |  awk {'print "revoke " $2,$3,$4,$5,$6,$7 " from " $1 ";"'} | grep -v "revoke       from ;" >> ${SHELLDIR}/revoke_harden.sql

cat /home/oracle/shell_scr/db_harden/sql_4_5_1_Rev_ALL_AUD.log | grep -v selected |  awk {'print "revoke " $2,$3,$4,$5,$6,$7 " from " $1 ";"'} | grep -v "revoke       from ;" >> ${SHELLDIR}/revoke_harden.sql

cat /home/oracle/shell_scr/db_harden/sql_4_5_2_Rev_ALL_USER_HISTORY.log | grep -v selected |  awk {'print "revoke " $2,$3,$4,$5,$6,$7 " from " $1 ";"'} | grep -v "revoke       from ;" >> ${SHELLDIR}/revoke_harden.sql

cat /home/oracle/shell_scr/db_harden/sql_4_5_3_Rev_ALL_LINK.log | grep -v selected |  awk {'print "revoke " $2,$3,$4,$5,$6,$7 " from " $1 ";"'} | grep -v "revoke       from ;" >> ${SHELLDIR}/revoke_harden.sql

cat /home/oracle/shell_scr/db_harden/sql_4_5_4_Rev_ALL_SYS_USER.log | grep -v selected |  awk {'print "revoke " $2,$3,$4,$5,$6,$7 " from " $1 ";"'} | grep -v "revoke       from ;" >> ${SHELLDIR}/revoke_harden.sql

cat /home/oracle/shell_scr/db_harden/sql_4_5_5_Rev_ALL_DBA.log | grep -v selected |  awk {'print "revoke all on "$3" from " $1 ";"'} | grep -v "revoke       from ;" >> ${SHELLDIR}/revoke_harden.sql

cat /home/oracle/shell_scr/db_harden/sql_4_5_6_Rev_ALL_SYS_SCHEDULER_CREDENTIAL.log | grep -v selected |  awk {'print "revoke " $2,$3,$4,$5,$6,$7 " from " $1 ";"'} | grep -v "revoke       from ;" >> ${SHELLDIR}/revoke_harden.sql

cat /home/oracle/shell_scr/db_harden/sql_4_5_7_Drop_SYS_USER_MIG.log | grep -v selected |  awk {'print "revoke " $2,$3,$4,$5,$6,$7 " from " $1 ";"'} | grep -v "revoke       from ;" >> ${SHELLDIR}/revoke_harden.sql

cat /home/oracle/shell_scr/db_harden/sql_4_6_Rev_ANY.log | grep -v selected |  awk {'print "revoke " $2,$3,$4,$5,$6,$7 " from " $1 ";"'} | grep -v "revoke       from ;" >> ${SHELLDIR}/revoke_harden.sql

cat /home/oracle/shell_scr/db_harden/sql_4_7_Rev_ADMIN_OPTION_YES.log | grep -v selected |  awk {'print "revoke " $2,$3,$4,$5,$6,$7 " from " $1 ";"'} | grep -v "revoke       from ;" >> ${SHELLDIR}/revoke_harden.sql

cat /home/oracle/shell_scr/db_harden/sql_4_8_Rev_CONNECT_Priv.log | grep -v selected |  awk {'print "revoke " $2,$3,$4,$5,$6,$7 " from " $1 ";"'} | grep -v "revoke       from ;" >> ${SHELLDIR}/revoke_harden.sql

cat /home/oracle/shell_scr/db_harden/sql_4_9_Rev_EXECUTE_ANY_PROCEDURE_OUTLN.log | grep -v selected |  awk {'print "revoke " $2,$3,$4,$5,$6,$7 " from " $1 ";"'} | grep -v "revoke       from ;" >> ${SHELLDIR}/revoke_harden.sql

echo "spool off"  >> revoke_harden.sql

echo "exit" >> revoke_harden.sql

${OHOME}/bin/sqlplus "/ as sysdba"  @${SHELLDIR}/revoke_harden.sql

cat ${SHELLDIR}/revoke_harden.log  >> ${FINALDIR}/revoke_harden.log

echo "" >> ${FINALDIR}/revoke_harden.log

echo ""

echo ""

echo "*************************** Revoke Hardening Sestion Ends here ***************************" >> ${FINALDIR}/revoke_harden.log

echo "*********************************************************************************" >> ${FINALDIR}/revoke_harden.log

}

Exec_fn_2_1_LIST_HARD(){

LIS_OWNER=`ps -ef | grep tnslsnr  | grep -v grep | awk {'print $1'}`

LIS_NAME=`ps -ef | grep tnslsnr  | grep -v grep | awk {'print $9'}`

${OHOME}/bin/lsnrctl status ${LIS}


LIS_PART_HOME=`ps -ef | grep tnslsnr  | grep -v grep | awk {'print $8'} | awk '{ sub("/[^/]*$", ""); print }' | awk '{ sub("/[^/]*$", ""); print }'`
LIS_LOCATION=${LIS_PART_HOME}/network/admin/listener.ora
TEMP_LIST_LOCATION=${LIS_PART_HOME}/network/admin/test.out
cp ${LIS_LOCATION} ${LIS_LOCATION}.bk

 sed '/EXTPROC/d'  ${LIS_LOCATION} > ${TEMP_LIST_LOCATION}
 sed '/EXTPROC1/d'  ${LIS_LOCATION} > ${TEMP_LIST_LOCATION}
 mv ${TEMP_LIST_LOCATION}   ${LIS_LOCATION}

 echo  "SECURE_CONTROL_${LIS_NAME}=TCPS" >> ${LIS_LOCATION}
 echo  "ADMIN_RESTRICTIONS_${LIS_NAME}=ON" >> ${LIS_LOCATION}
 echo  "SECURE_REGISTER_${LIS_NAME}=IPC"  >> ${LIS_LOCATION}


}

Exec_fn_2_2_4_LOC_LIST(){

LIS_OWNER=`ps -ef | grep tnslsnr  | grep -v grep | awk {'print $1'}`

LIS_NAME=`ps -ef | grep tnslsnr  | grep -v grep | awk {'print $9'}`

#LOC_VAR=`${OHOME}/bin/lsnrctl status ${LIS} | grep -i Description`
LOC_VAR=`${OHOME}/bin/lsnrctl status ${LIS_NAME} |  grep -v "Connecting to" | grep -i "description"`


echo " SET ECHO ON " > ${SHELLDIR}/harden_loc_lis.sql
echo " spool ${HARDENDIR}/sql_harden_loc_lis.log " >> ${SHELLDIR}/harden_loc_lis.sql
echo "ALTER SYSTEM SET LOCAL_LISTENER='$LOC_VAR';" >> ${SHELLDIR}/harden_loc_lis.sql
echo "spool off" >> ${SHELLDIR}/harden_loc_lis.sql
echo "exit;" >> ${SHELLDIR}/harden_loc_lis.sql

${OHOME}/bin/sqlplus "/ as sysdba"  @${SHELLDIR}/harden_loc_lis.sql

 if [ -f ${HARDENDIR}/sql_harden_loc_lis.log ]
  then
  cat ${HARDENDIR}/sql_harden_loc_lis.log  >> ${FINALDIR}/HARDENING_SQL.log
  else
  echo " Local Listener Hardening Script has not executed"
  fi


}

REP_Fn_2_2_6_OS_ROLE(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/2_2_6_OS_ROLE.sql


checker=`cat ${REPSQLDIR}/sql_2_2_6_os_roles.log | grep -i "FALSE" | wc -l`

cat ${REPSQLDIR}/sql_2_2_6_os_roles.log  >> ${FINALDIR}/2_2_6_OS_ROLE.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/2_2_6_OS_ROLE.log
         echo " 2.2.6 Ensure OS_ROLES Is Set to FALSE - AS PER CIS STANDARDS" >>  ${FINALDIR}/CIS_Success.log
            echo " 2.2.6 Ensure OS_ROLES Is Set to FALSE - AS PER CIS STANDARDS" >>  ${FINALDIR}/2_2_6_OS_ROLE.log
        else
        echo ""  >>  ${FINALDIR}/2_2_6_OS_ROLE.log

        echo " 2.2.6 Ensure OS_ROLES Is Set to FALSE   - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/CIS_Failure.log
                echo " 2.2.6 Ensure OS_ROLES Is Set to FALSE  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/2_2_6_OS_ROLE.log
        fi


echo "" >> ${FINALDIR}/2_2_6_OS_ROLE.log


echo ""



echo ""

echo "*************************** End of this module 2.2.6 check ***************************" >> ${FINALDIR}/2_2_6_OS_ROLE.log

echo "*********************************************************************************" >> ${FINALDIR}/2_2_6_OS_ROLE.log

}

REP_Fn_2_2_7_DICTIONARY_ACCESSIBILITY(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/2_2_7_DICTIONARY_ACCESSIBILITY.sql


checker=`cat ${REPSQLDIR}/sql_2_2_7_dict_access.log | grep -i "FALSE" | wc -l`

cat ${REPSQLDIR}/sql_2_2_7_dict_access.log  >> ${FINALDIR}/2_2_7_DICTIONARY_ACCESSIBILITY.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/2_2_7_DICTIONARY_ACCESSIBILITY.log
         echo " 2.2.7 Ensure O7_DICTIONARY_ACCESSIBILITY Is Set to FALSE - AS PER CIS STANDARDS" >>  ${FINALDIR}/CIS_Success.log
            echo " 2.2.7 Ensure O7_DICTIONARY_ACCESSIBILITY Is Set to FALSE - AS PER CIS STANDARDS" >>  ${FINALDIR}/2_2_7_DICTIONARY_ACCESSIBILITY.log
        else
        echo ""  >>  ${FINALDIR}/2_2_7_DICTIONARY_ACCESSIBILITY.log

        echo " 2.2.7 Ensure O7_DICTIONARY_ACCESSIBILITY Is Set to FALSE   - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/CIS_Failure.log
                echo " 2.2.7 Ensure O7_DICTIONARY_ACCESSIBILITY Is Set to FALSE  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/2_2_7_DICTIONARY_ACCESSIBILITY.log
        fi


echo "" >> ${FINALDIR}/2_2_7_DICTIONARY_ACCESSIBILITY.log


echo ""



echo ""

echo "*************************** End of this module 2.2.7 check ***************************" >> ${FINALDIR}/2_2_7_DICTIONARY_ACCESSIBILITY.log

echo "*********************************************************************************" >> ${FINALDIR}/2_2_7_DICTIONARY_ACCESSIBILITY.log

}

REP_Fn_2_2_8_Rem_Login_Pwdfile(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/2_2_8_Rem_Login_Pwdfile.sql


checker=`cat ${REPSQLDIR}/sql_2_2_8_Rem_LoginPwd_File.log | grep -i "NONE" | wc -l`

cat ${REPSQLDIR}/sql_2_2_8_Rem_LoginPwd_File.log  >> ${FINALDIR}/2_2_8_Rem_Login_Pwdfile.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/2_2_8_Rem_Login_Pwdfile.log
         echo " 2.2.8 Ensure REMOTE_LOGIN_PASSWORDFILE Is Set to NONE - AS PER CIS STANDARDS" >>  ${FINALDIR}/CIS_Success.log
            echo "2.2.8 Ensure REMOTE_LOGIN_PASSWORDFILE Is Set to NONE - AS PER CIS STANDARDS" >>  ${FINALDIR}/2_2_8_Rem_Login_Pwdfile.log
        else
        echo ""  >>  ${FINALDIR}/2_2_8_Rem_Login_Pwdfile.log

        echo " 2.2.8 Ensure REMOTE_LOGIN_PASSWORDFILE Is Set to NONE   - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/CIS_Failure.log
                echo " 2.2.8 Ensure REMOTE_LOGIN_PASSWORDFILE Is Set to NONE  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/2_2_8_Rem_Login_Pwdfile.log
        fi


echo "" >> ${FINALDIR}/2_2_8_Rem_Login_Pwdfile.log


echo ""



echo ""

echo "*************************** End of this module 2.2.8 check ***************************" >> ${FINALDIR}/2_2_8_Rem_Login_Pwdfile.log

echo "*********************************************************************************" >> ${FINALDIR}/2_2_8_Rem_Login_Pwdfile.log

}

REP_Fn_2_2_9_REM_OS_AUTH(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/2_2_9_rem_OS_Authent.sql


checker=`cat ${REPSQLDIR}/sql_2_2_9_os_authent.log | grep -i "FALSE" | wc -l`

cat ${REPSQLDIR}/sql_2_2_9_os_authent.log  >> ${FINALDIR}/2_2_9_REM_OS.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/2_2_9_REM_OS.log
         echo " 2.2.9 Ensure REMOTE_OS_AUTHENT Is Set to FALSE - AS PER CIS STANDARDS" >>  ${FINALDIR}/CIS_Success.log
            echo "2.2.9 Ensure REMOTE_OS_AUTHENT Is Set to FALSE - AS PER CIS STANDARDS" >>  ${FINALDIR}/2_2_9_REM_OS.log
        else
        echo ""  >>  ${FINALDIR}/2_2_9_REM_OS.log

        echo " 2.2.9 Ensure REMOTE_OS_AUTHENT Is Set to FALSE   - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/CIS_Failure.log
                echo " Ensure REMOTE_OS_AUTHENT Is Set to FALSE  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/2_2_9_REM_OS.log
        fi


echo "" >> ${FINALDIR}/2_2_9_REM_OS.log


echo ""



echo ""

echo "*************************** End of this module 2.2.9 check ***************************" >> ${FINALDIR}/2_2_9_REM_OS.log

echo "*********************************************************************************" >> ${FINALDIR}/2_2_9_REM_OS.log

}

REP_Fn_2_2_10_REM_OS_ROLES(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/2_2_10_rem_OS_roles.sql


checker=`cat ${REPSQLDIR}/sql_2_2_10_Rem_OS_roles.log | grep -i "FALSE" | wc -l`

cat ${REPSQLDIR}/sql_2_2_10_Rem_OS_roles.log  >> ${FINALDIR}/2_2_10_REM_OS_ROLES.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/2_2_10_REM_OS_ROLES.log
         echo " 2.2.10 Ensure REMOTE_OS_ROLES Is Set to FALSE - AS PER CIS STANDARDS" >>  ${FINALDIR}/CIS_Success.log
            echo "2.2.9 Ensure REMOTE_OS_ROLES Is Set to FALSE - AS PER CIS STANDARDS" >>  ${FINALDIR}/2_2_10_REM_OS_ROLES.log
        else
        echo ""  >>  ${FINALDIR}/2_2_10_REM_OS_ROLES.log

        echo " 2.2.9 Ensure Ensure REMOTE_OS_ROLES Is Set to FALSE   - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/CIS_Failure.log
                echo " 2.2.9 Ensure Ensure REMOTE_OS_ROLES Is Set to FALSE  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/2_2_10_REM_OS_ROLES.log
        fi


echo "" >> ${FINALDIR}/2_2_10_REM_OS_ROLES.log


echo ""



echo ""

echo "*************************** End of this module 2.2.10 check ***************************" >> ${FINALDIR}/2_2_10_REM_OS_ROLES.log

echo "*********************************************************************************" >> ${FINALDIR}/2_2_10_REM_OS_ROLES.log

}

REP_Fn_2_2_12_SEC_CASE_SENSITIVE_LOGON(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/2_2_12_SEC_CASE_SENSITIVE_LOGON.sql


checker=`cat ${REPSQLDIR}/sql_2_2_12_Sec_case_sensLogon.log | grep -i "TRUE" | wc -l`

cat ${REPSQLDIR}/sql_2_2_12_Sec_case_sensLogon.log  >> ${FINALDIR}/2_2_12_SEC_CASE_SENSITIVE_LOGON.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/2_2_12_SEC_CASE_SENSITIVE_LOGON.log
         echo " 2.2.12 Ensure SEC_CASE_SENSITIVE_LOGON Is Set to TRUE  - AS PER CIS STANDARDS" >>  ${FINALDIR}/CIS_Success.log
            echo " 2.2.12 Ensure SEC_CASE_SENSITIVE_LOGON Is Set to TRUE - AS PER CIS STANDARDS" >>  ${FINALDIR}/2_2_12_SEC_CASE_SENSITIVE_LOGON.log
        else
        echo ""  >>  ${FINALDIR}/2_2_12_SEC_CASE_SENSITIVE_LOGON.log

        echo " 2.2.12 Ensure SEC_CASE_SENSITIVE_LOGON Is Set to TRUE   - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/CIS_Failure.log
                echo " 2.2.12 Ensure SEC_CASE_SENSITIVE_LOGON Is Set to TRUE  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/2_2_12_SEC_CASE_SENSITIVE_LOGON.log
        fi


echo "" >> ${FINALDIR}/2_2_12_SEC_CASE_SENSITIVE_LOGON.log


echo ""



echo ""

echo "*************************** End of this module 2.2.12 check ***************************" >> ${FINALDIR}/2_2_12_SEC_CASE_SENSITIVE_LOGON.log

echo "*********************************************************************************" >> ${FINALDIR}/2_2_12_SEC_CASE_SENSITIVE_LOGON.log

}

REP_Fn_2_2_13_SEC_MAX_FAILED_LOGIN(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/2_2_13_SEC_MAX_FAILED_LOGIN.sql


checker=`cat ${REPSQLDIR}/sql_2_2_13_Sec_maxfailed_login.log | grep -i "10" | wc -l`

cat ${REPSQLDIR}/sql_2_2_13_Sec_maxfailed_login.log  >> ${FINALDIR}/2_2_13_SEC_MAX_FAILED_LOGIN.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/2_2_13_SEC_MAX_FAILED_LOGIN.log
         echo " 2.2.13 Ensure SEC_MAX_FAILED_LOGIN_ATTEMPTS Is Set to 10 - AS PER CIS STANDARDS" >>  ${FINALDIR}/CIS_Success.log
            echo " 2.2.13 Ensure SEC_MAX_FAILED_LOGIN_ATTEMPTS Is Set to 10 - AS PER CIS STANDARDS" >>  ${FINALDIR}/2_2_13_SEC_MAX_FAILED_LOGIN.log
        else
        echo ""  >>  ${FINALDIR}/2_2_13_SEC_MAX_FAILED_LOGIN.log

        echo " 2.2.13 Ensure SEC_MAX_FAILED_LOGIN_ATTEMPTS Is Set to 10   - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/CIS_Failure.log
                echo " 2.2.13 Ensure SEC_MAX_FAILED_LOGIN_ATTEMPTS Is Set to 10  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/2_2_13_SEC_MAX_FAILED_LOGIN.log
        fi


echo "" >> ${FINALDIR}/2_2_13_SEC_MAX_FAILED_LOGIN.log


echo ""



echo ""

echo "*************************** End of this module 2.2.13 check ***************************" >> ${FINALDIR}/2_2_13_SEC_MAX_FAILED_LOGIN.log

echo "*********************************************************************************" >> ${FINALDIR}/2_2_13_SEC_MAX_FAILED_LOGIN.log

}

REP_Fn_2_2_14_SEC_ERROR_FURTHER_ACTION(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/2_2_14_SEC_ERROR_FURTHER_ACTION.sql


checker=`cat ${REPSQLDIR}/sql_2_2_14_SEC_PROTOCOL_ERROR_FURTHER_ACTION.log | grep -E '(DROP,3)|(DELAY,3)' | wc -l`

cat ${REPSQLDIR}/sql_2_2_14_SEC_PROTOCOL_ERROR_FURTHER_ACTION.log  >> ${FINALDIR}/2_2_14_SEC_ERROR_FURTHER_ACTION.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/2_2_14_SEC_ERROR_FURTHER_ACTION.log
         echo " 2.2.14 Ensure SEC_PROTOCOL_ERROR_FURTHER_ACTION Is Set to (DELAY,3) or (DROP,3) - AS PER CIS STANDARDS" >>  ${FINALDIR}/CIS_Success.log
            echo " 2.2.14 Ensure SEC_PROTOCOL_ERROR_FURTHER_ACTION Is Set to (DELAY,3) or (DROP,3) - AS PER CIS STANDARDS" >>  ${FINALDIR}/2_2_14_SEC_ERROR_FURTHER_ACTION.log
        else
        echo ""  >>  ${FINALDIR}/2_2_14_SEC_ERROR_FURTHER_ACTION.log

        echo " 2.2.14 Ensure SEC_PROTOCOL_ERROR_FURTHER_ACTION Is Set to (DELAY,3) or (DROP,3)  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/CIS_Failure.log
                echo " 2.2.14 Ensure SEC_PROTOCOL_ERROR_FURTHER_ACTION Is Set to (DELAY,3) or (DROP,3)  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/2_2_14_SEC_ERROR_FURTHER_ACTION.log
        fi


echo "" >> ${FINALDIR}/2_2_14_SEC_ERROR_FURTHER_ACTION.log


echo ""



echo ""

echo "*************************** End of this module 2.2.14 check ***************************" >> ${FINALDIR}/2_2_14_SEC_ERROR_FURTHER_ACTION.log

echo "*********************************************************************************" >> ${FINALDIR}/2_2_14_SEC_ERROR_FURTHER_ACTION.log

}

REP_Fn_2_2_15_SEC_ERROR_TRACE_ACTION(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/2_2_15_SEC_ERROR_TRACE_ACTION.sql


checker=`cat ${REPSQLDIR}/sql_2_2_15_SEC_PROTOCOL_ERROR_TRACE_ACTION.log | grep -i "LOG" | wc -l`

cat ${REPSQLDIR}/sql_2_2_15_SEC_PROTOCOL_ERROR_TRACE_ACTION.log  >> ${FINALDIR}/2_2_15_SEC_ERROR_TRACE_ACTION.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/2_2_15_SEC_ERROR_TRACE_ACTION.log
         echo " 2.2.15 Ensure SEC_PROTOCOL_ERROR_TRACE_ACTION Is Set to LOG - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 2.2.15 Ensure SEC_PROTOCOL_ERROR_TRACE_ACTION Is Set to LOG - AS PER CIS STANDARDS" >>  ${FINALDIR}/2_2_15_SEC_ERROR_TRACE_ACTION.log
        else
        echo ""  >>  ${FINALDIR}/2_2_15_SEC_ERROR_TRACE_ACTION.log

        echo " 2.2.15 Ensure SEC_PROTOCOL_ERROR_TRACE_ACTION Is Set to LOG  - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
                echo " 2.2.15 Ensure SEC_PROTOCOL_ERROR_TRACE_ACTION Is Set to LOG  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/2_2_15_SEC_ERROR_TRACE_ACTION.log
        fi


echo "" >> ${FINALDIR}/2_2_15_SEC_ERROR_TRACE_ACTION.log


echo ""



echo ""

echo "*************************** End of this module 2.2.15 check ***************************" >> ${FINALDIR}/2_2_15_SEC_ERROR_TRACE_ACTION.log

echo "*********************************************************************************" >> ${FINALDIR}/2_2_15_SEC_ERROR_TRACE_ACTION.log

}

REP_Fn_2_2_16_SEC_RETURN_SERVER_BANNER(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/2_2_16_SEC_RETURN_SERVER_BANNER.sql


checker=`cat ${REPSQLDIR}/sql_2_2_16_SEC_RETURN_SERVER_RELEASE_BANNER.log | grep -i "FALSE" | wc -l`

cat ${REPSQLDIR}/sql_2_2_16_SEC_RETURN_SERVER_RELEASE_BANNER.log  >> ${FINALDIR}/2_2_16_SEC_RETURN_SERVER_BANNER.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/2_2_16_SEC_RETURN_SERVER_BANNER.log
         echo " 2.2.16 Ensure SEC_RETURN_SERVER_RELEASE_BANNER Is Set to FALSE - AS PER CIS STANDARDS" >>  ${FINALDIR}/CIS_Success.log
            echo " 2.2.16 Ensure SEC_RETURN_SERVER_RELEASE_BANNER Is Set to FALSE - AS PER CIS STANDARDS" >>  ${FINALDIR}/2_2_16_SEC_RETURN_SERVER_BANNER.log
        else
        echo ""  >>  ${FINALDIR}/2_2_16_SEC_RETURN_SERVER_BANNER.log

        echo " 2.2.16 Ensure SEC_RETURN_SERVER_RELEASE_BANNER Is Set to FALSE  - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
                echo " 2.2.16 Ensure SEC_RETURN_SERVER_RELEASE_BANNER Is Set to FALSE  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/2_2_16_SEC_RETURN_SERVER_BANNER.log
        fi


echo "" >> ${FINALDIR}/2_2_16_SEC_RETURN_SERVER_BANNER.log


echo ""



echo ""

echo "*************************** End of this module 2.2.16 check ***************************" >> ${FINALDIR}/2_2_16_SEC_RETURN_SERVER_BANNER.log

echo "*********************************************************************************" >> ${FINALDIR}/2_2_16_SEC_RETURN_SERVER_BANNER.log

}

REP_Fn_2_2_17_SQL92_SECURITY(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/2_2_17_SQL92_SECURITY.sql


checker=`cat ${REPSQLDIR}/sql_2_2_17_SQL92_SECURITY.log | grep -i "FALSE" | wc -l`

cat ${REPSQLDIR}/sql_2_2_17_SQL92_SECURITY.log  >> ${FINALDIR}/2_2_17_SQL92_SECURITY.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/2_2_17_SQL92_SECURITY.log
         echo " 2.2.17 Ensure SQL92_SECURITY Is Set to FALSE - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 2.2.17 Ensure SQL92_SECURITY Is Set to FALSE - AS PER CIS STANDARDS " >>  ${FINALDIR}/2_2_17_SQL92_SECURITY.log
        else
        echo ""  >>  ${FINALDIR}/2_2_17_SQL92_SECURITY.log

        echo " 2.2.17 Ensure SQL92_SECURITY Is Set to FALSE  - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
                echo " 2.2.17 Ensure SQL92_SECURITY Is Set to FALSE  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/2_2_17_SQL92_SECURITY.log
        fi


echo "" >> ${FINALDIR}/2_2_17_SQL92_SECURITY.log


echo ""



echo ""

echo "*************************** End of this module 2.2.17 check ***************************" >> ${FINALDIR}/2_2_17_SQL92_SECURITY.log

echo "*********************************************************************************" >> ${FINALDIR}/2_2_17_SQL92_SECURITY.log

}

REP_Fn_2_2_18_TRACE_FILES_PUBLIC(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/2_2_18_TRACE_FILES_PUBLIC.sql


checker=`cat ${REPSQLDIR}/sql_2_2_18_TRACE_FILES_PUBLIC.log | grep trace_files_public | grep -i "FALSE" | wc -l`

cat ${REPSQLDIR}/sql_2_2_18_TRACE_FILES_PUBLIC.log  >> ${FINALDIR}/2_2_18_TRACE_FILES_PUBLIC.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/2_2_18_TRACE_FILES_PUBLIC.log
         echo " 2.2.18 Ensure _TRACE_FILES_PUBLIC Is Set to FALSE - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 2.2.18 Ensure _TRACE_FILES_PUBLIC Is Set to FALSE - AS PER CIS STANDARDS " >>  ${FINALDIR}/2_2_18_TRACE_FILES_PUBLIC.log
        else
        echo ""  >>  ${FINALDIR}/2_2_18_TRACE_FILES_PUBLIC.log

        echo " 2.2.18 Ensure _TRACE_FILES_PUBLIC Is Set to FALSE  - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
                echo " 2.2.18 Ensure _TRACE_FILES_PUBLIC Is Set to FALSE  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/2_2_18_TRACE_FILES_PUBLIC.log
        fi


echo "" >> ${FINALDIR}/2_2_18_TRACE_FILES_PUBLIC.log


echo ""



echo ""

echo "*************************** End of this module 2.2.18 check ***************************" >> ${FINALDIR}/2_2_18_TRACE_FILES_PUBLIC.log

echo "*********************************************************************************" >> ${FINALDIR}/2_2_18_TRACE_FILES_PUBLIC.log

}

REP_Fn_2_2_19_RESOURCE_LIMIT(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/2_2_19_RESOURCE_LIMIT.sql


checker=`cat ${REPSQLDIR}/sql_2_2_19_RESOURCE_LIMIT.log | grep -i "TRUE" | wc -l`

cat ${REPSQLDIR}/sql_2_2_19_RESOURCE_LIMIT.log  >> ${FINALDIR}/2_2_19_RESOURCE_LIMIT.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/2_2_19_RESOURCE_LIMIT.log
         echo " 2.2.19 Ensure RESOURCE_LIMIT Is Set to TRUE - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 2.2.19 Ensure RESOURCE_LIMIT Is Set to TRUE - AS PER CIS STANDARDS " >>  ${FINALDIR}/2_2_19_RESOURCE_LIMIT.log
        else
        echo ""  >>  ${FINALDIR}/2_2_19_RESOURCE_LIMIT.log

        echo " 2.2.19 Ensure RESOURCE_LIMIT Is Set to TRUE  - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
                echo " 2.2.19 Ensure RESOURCE_LIMIT Is Set to TRUE  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/2_2_19_RESOURCE_LIMIT.log
        fi


echo "" >> ${FINALDIR}/2_2_19_RESOURCE_LIMIT.log


echo ""



echo ""

echo "*************************** End of this module 2.2.19 check ***************************" >> ${FINALDIR}/2_2_19_RESOURCE_LIMIT.log

echo "*********************************************************************************" >> ${FINALDIR}/2_2_19_RESOURCE_LIMIT.log

}

######################### SECTION 2 ENDS HERE #########################


REP_Fn_3_1_PROFILE_FAILED_LOGIN(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/3_1_PROFILE_FAILED_LOGIN.sql


checker=`cat ${REPSQLDIR}/sql_3_1_failed_login.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_3_1_failed_login.log  >> ${FINALDIR}/3_1_PROFILE_FAILED_LOGIN.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/3_1_PROFILE_FAILED_LOGIN.log
         echo " 3.1 Ensure FAILED_LOGIN_ATTEMPTS Is Less than or Equal to 5 - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 3.1 Ensure FAILED_LOGIN_ATTEMPTS Is Less than or Equal to 5 - AS PER CIS STANDARDS " >>  ${FINALDIR}/3_1_PROFILE_FAILED_LOGIN.log
        else
        echo ""  >>  ${FINALDIR}/3_1_PROFILE_FAILED_LOGIN.log

        echo " 3.1 Ensure FAILED_LOGIN_ATTEMPTS Is Less than or Equal to 5  - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
                echo " 3.1 Ensure FAILED_LOGIN_ATTEMPTS Is Less than or Equal to 5  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/3_1_PROFILE_FAILED_LOGIN.log
        fi


echo "" >> ${FINALDIR}/3_1_PROFILE_FAILED_LOGIN.log


echo ""



echo ""

echo "*************************** End of this module 3.1 check ***************************" >> ${FINALDIR}/3_1_PROFILE_FAILED_LOGIN.log

echo "*********************************************************************************" >> ${FINALDIR}/3_1_PROFILE_FAILED_LOGIN.log

}

REP_Fn_3_2_PROFILE_PASSWORD_LOCK(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/3_2_PROFILE_PASSWORD_LOCK.sql


checker=`cat ${REPSQLDIR}/sql_3_2_password_lock.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_3_2_password_lock.log  >> ${FINALDIR}/3_2_PROFILE_PASSWORD_LOCK.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/3_2_PROFILE_PASSWORD_LOCK.log
         echo " 3.2 Ensure PASSWORD_LOCK_TIME Is Greater than or Equal to 1 - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 3.2 Ensure PASSWORD_LOCK_TIME Is Greater than or Equal to 1 - AS PER CIS STANDARDS " >>  ${FINALDIR}/3_2_PROFILE_PASSWORD_LOCK.log
        else
        echo ""  >>  ${FINALDIR}/3_2_PROFILE_PASSWORD_LOCK.log

        echo " 3.2 Ensure PASSWORD_LOCK_TIME Is Greater than or Equal to 1  - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
                echo " 3.2 Ensure PASSWORD_LOCK_TIME Is Greater than or Equal to 1  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/3_2_PROFILE_PASSWORD_LOCK.log
        fi


echo "" >> ${FINALDIR}/3_2_PROFILE_PASSWORD_LOCK.log


echo ""



echo ""

echo "*************************** End of this module 3.2 check ***************************" >> ${FINALDIR}/3_2_PROFILE_PASSWORD_LOCK.log

echo "*********************************************************************************" >> ${FINALDIR}/3_2_PROFILE_PASSWORD_LOCK.log

}

REP_Fn_3_3_PROFILE_PASSWORD_LIFE(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/3_3_PROFILE_PASSWORD_LIFE.sql


checker=`cat ${REPSQLDIR}/sql_3_3_password_lock.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_3_3_password_lock.log  >> ${FINALDIR}/3_3_PROFILE_PASSWORD_LIFE.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/3_3_PROFILE_PASSWORD_LIFE.log
         echo " 3.3 Ensure PASSWORD_LIFE_TIME Is Less than or Equal to 90 - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 3.3 Ensure PASSWORD_LIFE_TIME Is Less than or Equal to 90 - AS PER CIS STANDARDS " >>  ${FINALDIR}/3_3_PROFILE_PASSWORD_LIFE.log
        else
        echo ""  >>  ${FINALDIR}/3_3_PROFILE_PASSWORD_LIFE.log

        echo " 3.3 Ensure PASSWORD_LIFE_TIME Is Less than or Equal to 90  - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
                echo " 3.3 Ensure PASSWORD_LIFE_TIME Is Less than or Equal to 90  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/3_3_PROFILE_PASSWORD_LIFE.log
        fi


echo "" >> ${FINALDIR}/3_3_PROFILE_PASSWORD_LIFE.log


echo ""



echo ""

echo "*************************** End of this module 3.3 check ***************************" >> ${FINALDIR}/3_3_PROFILE_PASSWORD_LIFE.log

echo "*********************************************************************************" >> ${FINALDIR}/3_3_PROFILE_PASSWORD_LIFE.log

}

REP_Fn_3_4_PROFILE_PASSWORD_REUSE(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/3_4_PROFILE_PASSWORD_REUSE.sql


checker=`cat ${REPSQLDIR}/sql_3_4_password_reusemax.log | grep -i "20" | wc -l`

cat ${REPSQLDIR}/sql_3_4_password_reusemax.log  >> ${FINALDIR}/3_4_PROFILE_PASSWORD_REUSE.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/3_4_PROFILE_PASSWORD_REUSE.log
         echo " 3.4 Ensure PASSWORD_REUSE_MAX Is Greater than or Equal to 20 - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 3.4 Ensure PASSWORD_REUSE_MAX Is Greater than or Equal to 20 - AS PER CIS STANDARDS " >>  ${FINALDIR}/3_4_PROFILE_PASSWORD_REUSE.log
        else
        echo ""  >>  ${FINALDIR}/3_4_PROFILE_PASSWORD_REUSE.log

        echo " 3.4 Ensure PASSWORD_REUSE_MAX Is Greater than or Equal to 20  - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
                echo " 3.4 Ensure PASSWORD_REUSE_MAX Is Greater than or Equal to 20  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/3_4_PROFILE_PASSWORD_REUSE.log
        fi


echo "" >> ${FINALDIR}/3_4_PROFILE_PASSWORD_REUSE.log


echo ""



echo ""

echo "*************************** End of this module 3.4 check ***************************" >> ${FINALDIR}/3_4_PROFILE_PASSWORD_REUSE.log

echo "*********************************************************************************" >> ${FINALDIR}/3_4_PROFILE_PASSWORD_REUSE.log

}

REP_Fn_3_5_PROFILE_PASSWORD_REUSE_TIME(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/3_5_PROFILE_PASSWORD_REUSE_TIME.sql


checker=`cat ${REPSQLDIR}/sql_3_5_password_reusetime.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_3_5_password_reusetime.log  >> ${FINALDIR}/3_5_PROFILE_PASSWORD_REUSE_TIME.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/3_5_PROFILE_PASSWORD_REUSE_TIME.log
         echo " 3.5 Ensure PASSWORD_REUSE_TIME Is Greater than or Equal to 365 - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 3.5 Ensure PASSWORD_REUSE_TIME Is Greater than or Equal to 365 - AS PER CIS STANDARDS " >>  ${FINALDIR}/3_5_PROFILE_PASSWORD_REUSE_TIME.log
        else
        echo ""  >>  ${FINALDIR}/3_5_PROFILE_PASSWORD_REUSE_TIME.log

        echo " 3.5 Ensure PASSWORD_REUSE_TIME Is Greater than or Equal to 365  - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
                echo " 3.5 Ensure PASSWORD_REUSE_TIME Is Greater than or Equal to 365  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/3_5_PROFILE_PASSWORD_REUSE_TIME.log
        fi


echo "" >> ${FINALDIR}/3_5_PROFILE_PASSWORD_REUSE_TIME.log


echo ""



echo ""

echo "*************************** End of this module 3.5 check ***************************" >> ${FINALDIR}/3_5_PROFILE_PASSWORD_REUSE_TIME.log

echo "*********************************************************************************" >> ${FINALDIR}/3_5_PROFILE_PASSWORD_REUSE_TIME.log

}

REP_Fn_3_6_PROFILE_PASSWORD_GRACE_TIME(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/3_6_PROFILE_PASSWORD_GRACE_TIME.sql


checker=`cat ${REPSQLDIR}/sql_3_6_password_gracetime.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_3_6_password_gracetime.log  >> ${FINALDIR}/3_6_PROFILE_PASSWORD_GRACE_TIME.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/3_6_PROFILE_PASSWORD_GRACE_TIME.log
         echo " 3.6 Ensure PASSWORD_GRACE_TIME Is Greater than or Equal to 5 - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 3.6 Ensure PASSWORD_GRACE_TIME Is Greater than or Equal to 5 - AS PER CIS STANDARDS " >>  ${FINALDIR}/3_6_PROFILE_PASSWORD_GRACE_TIME.log
        else
        echo ""  >>  ${FINALDIR}/3_6_PROFILE_PASSWORD_GRACE_TIME.log

        echo " 3.6 Ensure PASSWORD_GRACE_TIME Is Greater than or Equal to 5  - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
                echo " 3.6 Ensure PASSWORD_GRACE_TIME Is Greater than or Equal to 5  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/3_6_PROFILE_PASSWORD_GRACE_TIME.log
        fi


echo "" >> ${FINALDIR}/3_6_PROFILE_PASSWORD_GRACE_TIME.log


echo ""



echo ""

echo "*************************** End of this module 3.6 check ***************************" >> ${FINALDIR}/3_6_PROFILE_PASSWORD_GRACE_TIME.log

echo "*********************************************************************************" >> ${FINALDIR}/3_6_PROFILE_PASSWORD_GRACE_TIME.log

}

REP_Fn_3_7_DBA_USERS_PASSWORD(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/3_7_DBA_USERS_PASSWORD.sql


checker=`cat ${REPSQLDIR}/sql_3_7_dbauser_password.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_3_7_dbauser_password.log  >> ${FINALDIR}/3_7_DBA_USERS_PASSWORD.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/3_7_DBA_USERS_PASSWORD.log
         echo " 3.7 Ensure DBA_USERS.PASSWORD Is Not Set to EXTERNAL for Any User - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 3.7 Ensure DBA_USERS.PASSWORD Is Not Set to EXTERNAL for Any User - AS PER CIS STANDARDS " >>  ${FINALDIR}/3_7_DBA_USERS_PASSWORD.log
        else
        echo ""  >>  ${FINALDIR}/3_7_DBA_USERS_PASSWORD.log

        echo " 3.7 Ensure DBA_USERS.PASSWORD Is Not Set to EXTERNAL for Any User  - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
                echo " 3.7 Ensure DBA_USERS.PASSWORD Is Not Set to EXTERNAL for Any User  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/3_7_DBA_USERS_PASSWORD.log
        fi


echo "" >> ${FINALDIR}/3_7_DBA_USERS_PASSWORD.log


echo ""



echo ""

echo "*************************** End of this module 3.7 check ***************************" >> ${FINALDIR}/3_7_DBA_USERS_PASSWORD.log

echo "*********************************************************************************" >> ${FINALDIR}/3_7_DBA_USERS_PASSWORD.log

}

REP_Fn_3_8_PROFILE_PASSWORD_VERIFY(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/3_8_PROFILE_PASSWORD_VERIFY.sql


checker=`cat ${REPSQLDIR}/sql_3_8_password_verifyfunction.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_3_8_password_verifyfunction.log  >> ${FINALDIR}/3_8_PROFILE_PASSWORD_VERIFY.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/3_8_PROFILE_PASSWORD_VERIFY.log
         echo " 3.8 Ensure PASSWORD_VERIFY_FUNCTION Is Set for All Profiles  - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 3.8 Ensure PASSWORD_VERIFY_FUNCTION Is Set for All Profiles - AS PER CIS STANDARDS " >>  ${FINALDIR}/3_8_PROFILE_PASSWORD_VERIFY.log
        else
        echo ""  >>  ${FINALDIR}/3_8_PROFILE_PASSWORD_VERIFY.log

        echo " 3.8 Ensure PASSWORD_VERIFY_FUNCTION Is Set for All Profiles - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
                echo " 3.8 Ensure PASSWORD_VERIFY_FUNCTION Is Set for All Profiles  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/3_8_PROFILE_PASSWORD_VERIFY.log
        fi


echo "" >> ${FINALDIR}/3_8_PROFILE_PASSWORD_VERIFY.log


echo ""



echo ""

echo "*************************** End of this module 3.8 check ***************************" >> ${FINALDIR}/3_8_PROFILE_PASSWORD_VERIFY.log

echo "*********************************************************************************" >> ${FINALDIR}/3_8_PROFILE_PASSWORD_VERIFY.log

}

REP_Fn_3_9_PROFILE_SESSIONS_PER_USER(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/3_9_PROFILE_SESSIONS_PER_USER.sql


checker=`cat ${REPSQLDIR}/sql_3_9_sessionsper_user.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_3_9_sessionsper_user.log  >> ${FINALDIR}/3_9_PROFILE_SESSIONS_PER_USER.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/3_9_PROFILE_SESSIONS_PER_USER.log
         echo " 3.9 Ensure SESSIONS_PER_USER Is Less than or Qual to 10 - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 3.9 Ensure SESSIONS_PER_USER Is Less than or Qual to 10 - AS PER CIS STANDARDS " >>  ${FINALDIR}/3_9_PROFILE_SESSIONS_PER_USER.log
        else
        echo ""  >>  ${FINALDIR}/3_9_PROFILE_SESSIONS_PER_USER.log

        echo " 3.9 Ensure SESSIONS_PER_USER Is Less than or Qual to 10  - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
                echo " 3.9 Ensure SESSIONS_PER_USER Is Less than or Qual to 10  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/3_9_PROFILE_SESSIONS_PER_USER.log
        fi


echo "" >> ${FINALDIR}/3_9_PROFILE_SESSIONS_PER_USER.log


echo ""



echo ""

echo "*************************** End of this module 3.9 check ***************************" >> ${FINALDIR}/3_9_PROFILE_SESSIONS_PER_USER.log

echo "*********************************************************************************" >> ${FINALDIR}/3_9_PROFILE_SESSIONS_PER_USER.log

}

REP_Fn_3_10_USERS_WITH_DEFAULT_PROFILE(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/3_10_USERS_WITH_DEFAULT_PROFILE.sql


checker=`cat ${REPSQLDIR}/sql_3_10_users_default_profile.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_3_10_users_default_profile.log  >> ${FINALDIR}/3_10_USERS_WITH_DEFAULT_PROFILE.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/3_10_USERS_WITH_DEFAULT_PROFILE.log
         echo " 3.10 Ensure No Users Are Assigned the DEFAULT Profile - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 3.10 Ensure No Users Are Assigned the DEFAULT Profile - AS PER CIS STANDARDS " >>  ${FINALDIR}/3_10_USERS_WITH_DEFAULT_PROFILE.log
        else
        echo ""  >>  ${FINALDIR}/3_10_USERS_WITH_DEFAULT_PROFILE.log

        echo " 3.10 Ensure No Users Are Assigned the DEFAULT Profile  - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
                echo " 3.10 Ensure No Users Are Assigned the DEFAULT Profile  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/3_10_USERS_WITH_DEFAULT_PROFILE.log
        fi


echo "" >> ${FINALDIR}/3_10_USERS_WITH_DEFAULT_PROFILE.log


echo ""



echo ""

echo "*************************** End of this module 3.10 check ***************************" >> ${FINALDIR}/3_10_USERS_WITH_DEFAULT_PROFILE.log

echo "*********************************************************************************" >> ${FINALDIR}/3_10_USERS_WITH_DEFAULT_PROFILE.log

}

######################### SECTION 3 ENDS HERE #########################

REP_Fn_4_1_1_PRIVILEGE_PACKAGES_OBJECTS(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/4_1_1_PRIVILEGE_PACKAGES_OBJECTS.sql


checker=`cat ${REPSQLDIR}/sql_4_1_1_privilege_package_object.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_4_1_1_privilege_package_object.log  >> ${FINALDIR}/4_1_1_PRIVILEGE_PACKAGES_OBJECTS.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/4_1_1_PRIVILEGE_PACKAGES_OBJECTS.log
         echo " 4.1.1 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_ADVISOR - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 4.1.1 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_ADVISOR - AS PER CIS STANDARDS " >>  ${FINALDIR}/4_1_1_PRIVILEGE_PACKAGES_OBJECTS.log
        else
        echo ""  >>  ${FINALDIR}/4_1_1_PRIVILEGE_PACKAGES_OBJECTS.log

        echo " 4.1.1 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_ADVISOR  - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
                echo " 4.1.1 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_ADVISOR  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/4_1_1_PRIVILEGE_PACKAGES_OBJECTS.log
        fi


echo "" >> ${FINALDIR}/4_1_1_PRIVILEGE_PACKAGES_OBJECTS.log


echo ""



echo ""

echo "*************************** End of this module 4.1.1 check ***************************" >> ${FINALDIR}/4_1_1_PRIVILEGE_PACKAGES_OBJECTS.log

echo "*********************************************************************************" >> ${FINALDIR}/4_1_1_PRIVILEGE_PACKAGES_OBJECTS.log

}

REP_Fn_4_1_2_DBMS_CRYPTO(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/4_1_2_DBMS_CRYPTO.sql


checker=`cat ${REPSQLDIR}/sql_4_1_2_DBMS_CRYPTO.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_4_1_2_DBMS_CRYPTO.log  >> ${FINALDIR}/4_1_2_DBMS_CRYPTO.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/4_1_2_DBMS_CRYPTO.log
         echo " 4.1.2 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_CRYPTO - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 4.1.2 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_CRYPTO - AS PER CIS STANDARDS " >>  ${FINALDIR}/4_1_2_DBMS_CRYPTO.log
        else
        echo ""  >>  ${FINALDIR}/4_1_2_DBMS_CRYPTO.log

        echo " 4.1.2 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_CRYPTO  - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
                echo " 4.1.2 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_CRYPTO  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/4_1_2_DBMS_CRYPTO.log
        fi


echo "" >> ${FINALDIR}/4_1_2_DBMS_CRYPTO.log


echo ""



echo ""

echo "*************************** End of this module 4.1.2 check ***************************" >> ${FINALDIR}/4_1_2_DBMS_CRYPTO.log

echo "*********************************************************************************" >> ${FINALDIR}/4_1_2_DBMS_CRYPTO.log

}

REP_Fn_4_1_3_DBMS_JAVA(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/4_1_3_DBMS_JAVA.sql


checker=`cat ${REPSQLDIR}/sql_4_1_3_DBMS_JAVA.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_4_1_3_DBMS_JAVA.log  >> ${FINALDIR}/4_1_3_DBMS_JAVA.log


if [ ${checker} == 0 ];
        then
        echo ""  >>  ${FINALDIR}/4_1_3_DBMS_JAVA.log
         echo " 4.1.3 Ensure EXECUTE Is not Revoked from PUBLIC on DBMS_JAVA - AS PER Doc ID 1165830.1 " >>  ${FINALDIR}/CIS_Success.log
            echo " 4.1.3 Ensure EXECUTE Is not Revoked from PUBLIC on DBMS_JAVA - AS PER Doc ID 1165830.1 " >>  ${FINALDIR}/4_1_3_DBMS_JAVA.log
        else
        echo ""  >>  ${FINALDIR}/4_1_3_DBMS_JAVA.log

        echo " 4.1.3 Ensure EXECUTE Is not Revoked from PUBLIC on DBMS_JAVA - AS PER Doc ID 1165830.1  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
                echo " 4.1.3 Ensure EXECUTE Is not Revoked from PUBLIC on DBMS_JAVA - AS PER Doc ID 1165830.1 .. Need Attention" >>  ${FINALDIR}/4_1_3_DBMS_JAVA.log
        fi


echo "" >> ${FINALDIR}/4_1_3_DBMS_JAVA.log


echo ""



echo ""

echo "*************************** End of this module 4.1.3 check ***************************" >> ${FINALDIR}/4_1_3_DBMS_JAVA.log

echo "*********************************************************************************" >> ${FINALDIR}/4_1_3_DBMS_JAVA.log

}

REP_Fn_4_1_4_DBMS_JAVA_TEST(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/4_1_4_DBMS_JAVA_TEST.sql


checker=`cat ${REPSQLDIR}/sql_4_1_4_DBMS_JAVA_TEST.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_4_1_4_DBMS_JAVA_TEST.log  >> ${FINALDIR}/4_1_4_DBMS_JAVA_TEST.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/4_1_4_DBMS_JAVA_TEST.log
         echo " 4.1.4 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_JAVA_TEST - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 4.1.4 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_JAVA_TEST - AS PER CIS STANDARDS " >>  ${FINALDIR}/4_1_4_DBMS_JAVA_TEST.log
        else
        echo ""  >>  ${FINALDIR}/4_1_4_DBMS_JAVA_TEST.log

        echo " 4.1.4 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_JAVA_TEST  - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
                echo " 4.1.4 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_JAVA_TEST  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/4_1_4_DBMS_JAVA_TEST.log
        fi


echo "" >> ${FINALDIR}/4_1_4_DBMS_JAVA_TEST.log


echo ""



echo ""

echo "*************************** End of this module 4.1.4 check ***************************" >> ${FINALDIR}/4_1_4_DBMS_JAVA_TEST.log

echo "*********************************************************************************" >> ${FINALDIR}/4_1_4_DBMS_JAVA_TEST.log

}

REP_Fn_4_1_5_DBMS_JOB(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/4_1_5_DBMS_JOB.sql


checker=`cat ${REPSQLDIR}/sql_4_1_5_DBMS_JOB.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_4_1_5_DBMS_JOB.log  >> ${FINALDIR}/4_1_5_DBMS_JOB.log


if [ ${checker} == 0 ];
        then
        echo ""  >>  ${FINALDIR}/4_1_5_DBMS_JOB.log
         echo " 4.1.5 Ensure EXECUTE Is not Revoked from PUBLIC on DBMS_LOB - AS PER Doc ID 1165830.1 " >>  ${FINALDIR}/CIS_Success.log
            echo " 4.1.5 Ensure EXECUTE Is not Revoked from PUBLIC on DBMS_LOB - AS PER Doc ID 1165830.1 " >>  ${FINALDIR}/4_1_5_DBMS_JOB.log
        else
        echo ""  >>  ${FINALDIR}/4_1_5_DBMS_JOB.log

        echo " 4.1.5 Ensure EXECUTE Is not Revoked from PUBLIC on DBMS_LOB - AS PER Doc ID 1165830.1  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
                echo " 4.1.5 Ensure EXECUTE Is not Revoked from PUBLIC on DBMS_LOB - AS PER Doc ID 1165830.1 .. Need Attention" >>  ${FINALDIR}/4_1_5_DBMS_JOB.log
        fi


echo "" >> ${FINALDIR}/4_1_5_DBMS_JOB.log


echo ""



echo ""

echo "*************************** End of this module 4.1.5 check ***************************" >> ${FINALDIR}/4_1_5_DBMS_JOB.log

echo "*********************************************************************************" >> ${FINALDIR}/4_1_5_DBMS_JOB.log

}

REP_Fn_4_1_6_DBMS_LDAP(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/4_1_6_DBMS_LDAP.sql


checker=`cat ${REPSQLDIR}/sql_4_1_6_DBMS_LDAP.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_4_1_6_DBMS_LDAP.log  >> ${FINALDIR}/4_1_6_DBMS_LDAP.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/4_1_6_DBMS_LDAP.log
         echo " 4.1.6 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_LDAP - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 4.1.6 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_LDAP - AS PER CIS STANDARDS " >>  ${FINALDIR}/4_1_6_DBMS_LDAP.log
        else
        echo ""  >>  ${FINALDIR}/4_1_6_DBMS_LDAP.log

        echo " 4.1.6 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_LDAP  - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
                echo " 4.1.6 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_LDAP  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/4_1_6_DBMS_LDAP.log
        fi


echo "" >> ${FINALDIR}/4_1_6_DBMS_LDAP.log


echo ""



echo ""

echo "*************************** End of this module 4.1.6 check ***************************" >> ${FINALDIR}/4_1_6_DBMS_LDAP.log

echo "*********************************************************************************" >> ${FINALDIR}/4_1_6_DBMS_LDAP.log

}

REP_Fn_4_1_7_DBMS_LOB(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/4_1_7_DBMS_LOB.sql


checker=`cat ${REPSQLDIR}/sql_4_1_7_DBMS_LOB.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_4_1_7_DBMS_LOB.log  >> ${FINALDIR}/4_1_7_DBMS_LOB.log


if [ ${checker} == 0 ];
        then
        echo ""  >>  ${FINALDIR}/4_1_7_DBMS_LOB.log
         echo " 4.1.7 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_LOB - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 4.1.7 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_LOB - AS PER CIS STANDARDS " >>  ${FINALDIR}/4_1_7_DBMS_LOB.log
        else
        echo ""  >>  ${FINALDIR}/4_1_7_DBMS_LOB.log

        echo " 4.1.7 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_LOB  - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
                echo " 4.1.7 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_LOB  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/4_1_7_DBMS_LOB.log
        fi


echo "" >> ${FINALDIR}/4_1_7_DBMS_LOB.log


echo ""



echo ""

echo "*************************** End of this module 4.1.7 check ***************************" >> ${FINALDIR}/4_1_7_DBMS_LOB.log

echo "*********************************************************************************" >> ${FINALDIR}/4_1_7_DBMS_LOB.log

}

REP_Fn_4_1_8_DBMS_OBFUSCATION_TOOLKIT(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/4_1_8_DBMS_OBFUSCATION_TOOLKIT.sql


checker=`cat ${REPSQLDIR}/sql_4_1_8_DBMS_OBFUSCATION_TOOLKIT.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_4_1_8_DBMS_OBFUSCATION_TOOLKIT.log  >> ${FINALDIR}/4_1_8_DBMS_OBFUSCATION_TOOLKIT.log


if [ ${checker} == 0 ];
        then
        echo ""  >>  ${FINALDIR}/4_1_8_DBMS_OBFUSCATION_TOOLKIT.log
         echo " 4.1.8 Ensure EXECUTE Is not Revoked from PUBLIC on DBMS_OBFUSCATION_TOOLKIT - AS PER Doc ID 1165830.1 " >>  ${FINALDIR}/CIS_Success.log
            echo " 4.1.8 Ensure EXECUTE Is not Revoked from PUBLIC on DBMS_OBFUSCATION_TOOLKIT - AS PER Doc ID 1165830.1 " >>  ${FINALDIR}/4_1_8_DBMS_OBFUSCATION_TOOLKIT.log
        else
        echo ""  >>  ${FINALDIR}/4_1_8_DBMS_OBFUSCATION_TOOLKIT.log

        echo " 4.1.8 Ensure EXECUTE Is not Revoked from PUBLIC on DBMS_OBFUSCATION_TOOLKIT - AS PER Doc ID 1165830.1  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
                echo " 4.1.8 Ensure EXECUTE Is not Revoked from PUBLIC on DBMS_OBFUSCATION_TOOLKIT - AS PER Doc ID 1165830.1 .. Need Attention" >>  ${FINALDIR}/4_1_8_DBMS_OBFUSCATION_TOOLKIT.log
        fi


echo "" >> ${FINALDIR}/4_1_8_DBMS_OBFUSCATION_TOOLKIT.log


echo ""



echo ""

echo "*************************** End of this module 4.1.8 check ***************************" >> ${FINALDIR}/4_1_8_DBMS_OBFUSCATION_TOOLKIT.log

echo "*********************************************************************************" >> ${FINALDIR}/4_1_8_DBMS_OBFUSCATION_TOOLKIT.log

}

REP_Fn_4_1_9_DBMS_BACKUP_RESTORE(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/4_1_9_DBMS_BACKUP_RESTORE.sql


checker=`cat ${REPSQLDIR}/sql_4_1_9_DBMS_BACKUP_RESTORE.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_4_1_9_DBMS_BACKUP_RESTORE.log  >> ${FINALDIR}/4_1_9_DBMS_BACKUP_RESTORE.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/4_1_9_DBMS_BACKUP_RESTORE.log
         echo " 4.1.9 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_BACKUP_RESTORE - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 4.1.9 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_BACKUP_RESTORE - AS PER CIS STANDARDS " >>  ${FINALDIR}/4_1_9_DBMS_BACKUP_RESTORE.log
        else
        echo ""  >>  ${FINALDIR}/4_1_9_DBMS_BACKUP_RESTORE.log

        echo " 4.1.9 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_BACKUP_RESTORE  - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
                echo " 4.1.9 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_BACKUP_RESTORE  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/4_1_9_DBMS_BACKUP_RESTORE.log
        fi


echo "" >> ${FINALDIR}/4_1_9_DBMS_BACKUP_RESTORE.log


echo ""



echo ""

echo "*************************** End of this module 4.1.9 check ***************************" >> ${FINALDIR}/4_1_9_DBMS_BACKUP_RESTORE.log

echo "*********************************************************************************" >> ${FINALDIR}/4_1_9_DBMS_BACKUP_RESTORE.log

}

REP_Fn_4_1_10_DBMS_SCHEDULER(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/4_1_10_DBMS_SCHEDULER.sql


checker=`cat ${REPSQLDIR}/sql_4_1_10_DBMS_SCHEDULER.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_4_1_10_DBMS_SCHEDULER.log  >> ${FINALDIR}/4_1_10_DBMS_SCHEDULER.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/4_1_10_DBMS_SCHEDULER.log
         echo " 4.1.10 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_SCHEDULER - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 4.1.10 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_SCHEDULER - AS PER CIS STANDARDS " >>  ${FINALDIR}/4_1_10_DBMS_SCHEDULER.log
        else
        echo ""  >>  ${FINALDIR}/4_1_10_DBMS_SCHEDULER.log

        echo " 4.1.10 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_SCHEDULER  - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
                echo " 4.1.10 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_SCHEDULER  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/4_1_10_DBMS_SCHEDULER.log
        fi


echo "" >> ${FINALDIR}/4_1_10_DBMS_SCHEDULER.log


echo ""



echo ""

echo "*************************** End of this module 4.1.10 check ***************************" >> ${FINALDIR}/4_1_10_DBMS_SCHEDULER.log

echo "*********************************************************************************" >> ${FINALDIR}/4_1_10_DBMS_SCHEDULER.log

}

REP_Fn_4_1_11_DBMS_SQL(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/4_1_11_DBMS_SQL.sql


checker=`cat ${REPSQLDIR}/sql_4_1_11_DBMS_SQL.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_4_1_11_DBMS_SQL.log  >> ${FINALDIR}/4_1_11_DBMS_SQL.log


if [ ${checker} == 0 ];
        then
        echo ""  >>  ${FINALDIR}/4_1_11_DBMS_SQL.log
         echo " 4.1.11 Ensure EXECUTE Is not Revoked from PUBLIC on DBMS_SQL - AS PER Doc ID 1165830.1 " >>  ${FINALDIR}/CIS_Success.log
            echo " 4.1.11 Ensure EXECUTE Is not Revoked from PUBLIC on DBMS_SQL - AS PER Doc ID 1165830.1 " >>  ${FINALDIR}/4_1_11_DBMS_SQL.log
        else
        echo ""  >>  ${FINALDIR}/4_1_11_DBMS_SQL.log

        echo " 4.1.11 Ensure EXECUTE Is not Revoked from PUBLIC on DBMS_SQL - AS PER Doc ID 1165830.1  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
                echo " 4.1.11 Ensure EXECUTE Is not Revoked from PUBLIC on DBMS_SQL - AS PER Doc ID 1165830.1 .. Need Attention" >>  ${FINALDIR}/4_1_11_DBMS_SQL.log
        fi


echo "" >> ${FINALDIR}/4_1_11_DBMS_SQL.log


echo ""



echo ""

echo "*************************** End of this module 4.1.11 check ***************************" >> ${FINALDIR}/4_1_11_DBMS_SQL.log

echo "*********************************************************************************" >> ${FINALDIR}/4_1_11_DBMS_SQL.log

}

REP_Fn_4_1_12_DBMS_XMLGEN(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/4_1_12_DBMS_XMLGEN.sql


checker=`cat ${REPSQLDIR}/sql_4_1_12_DBMS_XMLGEN.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_4_1_12_DBMS_XMLGEN.log  >> ${FINALDIR}/4_1_12_DBMS_XMLGEN.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/4_1_12_DBMS_XMLGEN.log
         echo " 4.1.12 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_XMLGEN - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 4.1.12 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_XMLGEN - AS PER CIS STANDARDS " >>  ${FINALDIR}/4_1_12_DBMS_XMLGEN.log
        else
        echo ""  >>  ${FINALDIR}/4_1_12_DBMS_XMLGEN.log

        echo " 4.1.12 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_XMLGEN  - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
                echo " 4.1.12 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_XMLGEN  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/4_1_12_DBMS_XMLGEN.log
        fi


echo "" >> ${FINALDIR}/4_1_12_DBMS_XMLGEN.log


echo ""



echo ""

echo "*************************** End of this module 4.1.12 check ***************************" >> ${FINALDIR}/4_1_12_DBMS_XMLGEN.log

echo "*********************************************************************************" >> ${FINALDIR}/4_1_12_DBMS_XMLGEN.log

}

REP_Fn_4_1_13_DBMS_XMLQUERY(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/4_1_13_DBMS_XMLQUERY.sql


checker=`cat ${REPSQLDIR}/sql_4_1_13_DBMS_XMLQUERY.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_4_1_13_DBMS_XMLQUERY.log  >> ${FINALDIR}/4_1_13_DBMS_XMLQUERY.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/4_1_13_DBMS_XMLQUERY.log
         echo " 4.1.13 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_XMLQUERY - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 4.1.13 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_XMLQUERY - AS PER CIS STANDARDS " >>  ${FINALDIR}/4_1_13_DBMS_XMLQUERY.log
        else
        echo ""  >>  ${FINALDIR}/4_1_13_DBMS_XMLQUERY.log

        echo " 4.1.13 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_XMLQUERY  - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
                echo " 4.1.13 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_XMLQUERY  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/4_1_13_DBMS_XMLQUERY.log
        fi


echo "" >> ${FINALDIR}/4_1_13_DBMS_XMLQUERY.log


echo ""



echo ""

echo "*************************** End of this module 4.1.13 check ***************************" >> ${FINALDIR}/4_1_13_DBMS_XMLQUERY.log

echo "*********************************************************************************" >> ${FINALDIR}/4_1_13_DBMS_XMLQUERY.log

}

REP_Fn_4_1_14_UTL_FILE(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/4_1_14_UTL_FILE.sql


checker=`cat ${REPSQLDIR}/sql_4_1_14_UTL_FILE.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_4_1_14_UTL_FILE.log  >> ${FINALDIR}/4_1_14_UTL_FILE.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/4_1_14_UTL_FILE.log
         echo " 4.1.14 Ensure EXECUTE Is Revoked from PUBLIC on UTL_FILE - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 4.1.14 Ensure EXECUTE Is Revoked from PUBLIC on UTL_FILE - AS PER CIS STANDARDS " >>  ${FINALDIR}/4_1_14_UTL_FILE.log
        else
        echo ""  >>  ${FINALDIR}/4_1_14_UTL_FILE.log

        echo " 4.1.14 Ensure EXECUTE Is Revoked from PUBLIC on UTL_FILE  - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
                echo " 4.1.14 Ensure EXECUTE Is Revoked from PUBLIC on UTL_FILE  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/4_1_14_UTL_FILE.log
        fi


echo "" >> ${FINALDIR}/4_1_14_UTL_FILE.log


echo ""



echo ""

echo "*************************** End of this module 4.1.14 check ***************************" >> ${FINALDIR}/4_1_14_UTL_FILE.log

echo "*********************************************************************************" >> ${FINALDIR}/4_1_14_UTL_FILE.log

}

REP_Fn_4_1_15_UTL_INADDR(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/4_1_15_UTL_INADDR.sql


checker=`cat ${REPSQLDIR}/sql_4_1_15_UTL_INADDR.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_4_1_15_UTL_INADDR.log  >> ${FINALDIR}/4_1_15_UTL_INADDR.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/4_1_15_UTL_INADDR.log
         echo " 4.1.15 Ensure EXECUTE Is Revoked from PUBLIC on UTL_INADDR - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 4.1.15 Ensure EXECUTE Is Revoked from PUBLIC on UTL_INADDR - AS PER CIS STANDARDS " >>  ${FINALDIR}/4_1_15_UTL_INADDR.log
        else
        echo ""  >>  ${FINALDIR}/4_1_15_UTL_INADDR.log

        echo " 4.1.15 Ensure EXECUTE Is Revoked from PUBLIC on UTL_INADDR  - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
                echo " 4.1.15 Ensure EXECUTE Is Revoked from PUBLIC on UTL_INADDR  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/4_1_15_UTL_INADDR.log
        fi


echo "" >> ${FINALDIR}/4_1_15_UTL_INADDR.log


echo ""



echo ""

echo "*************************** End of this module 4.1.15 check ***************************" >> ${FINALDIR}/4_1_15_UTL_INADDR.log

echo "*********************************************************************************" >> ${FINALDIR}/4_1_15_UTL_INADDR.log

}

REP_Fn_4_1_16_UTL_TCP(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/4_1_16_UTL_TCP.sql


checker=`cat ${REPSQLDIR}/sql_4_1_16_UTL_TCP.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_4_1_16_UTL_TCP.log  >> ${FINALDIR}/4_1_16_UTL_TCP.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/4_1_16_UTL_TCP.log
         echo " 4.1.16 Ensure EXECUTE Is Revoked from PUBLIC on UTL_TCP - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 4.1.16 Ensure EXECUTE Is Revoked from PUBLIC on UTL_TCP - AS PER CIS STANDARDS " >>  ${FINALDIR}/4_1_16_UTL_TCP.log
        else
        echo ""  >>  ${FINALDIR}/4_1_16_UTL_TCP.log

        echo " 4.1.16 Ensure EXECUTE Is Revoked from PUBLIC on UTL_TCP  - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
                echo " 4.1.16 Ensure EXECUTE Is Revoked from PUBLIC on UTL_TCP  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/4_1_16_UTL_TCP.log
        fi


echo "" >> ${FINALDIR}/4_1_16_UTL_TCP.log


echo ""



echo ""

echo "*************************** End of this module 4.1.16 check ***************************" >> ${FINALDIR}/4_1_16_UTL_TCP.log

echo "*********************************************************************************" >> ${FINALDIR}/4_1_16_UTL_TCP.log

}

REP_Fn_4_1_17_UTL_MAIL(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/4_1_17_UTL_MAIL.sql


checker=`cat ${REPSQLDIR}/sql_4_1_17_UTL_MAIL.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_4_1_17_UTL_MAIL.log  >> ${FINALDIR}/4_1_17_UTL_MAIL.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/4_1_17_UTL_MAIL.log
         echo " 4.1.17 Ensure EXECUTE Is Revoked from PUBLIC on UTL_MAIL - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 4.1.17 Ensure EXECUTE Is Revoked from PUBLIC on UTL_MAIL - AS PER CIS STANDARDS " >>  ${FINALDIR}/4_1_17_UTL_MAIL.log
        else
        echo ""  >>  ${FINALDIR}/4_1_17_UTL_MAIL.log

        echo " 4.1.17 Ensure EXECUTE Is Revoked from PUBLIC on UTL_MAIL  - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
                echo " 4.1.17 Ensure EXECUTE Is Revoked from PUBLIC on UTL_MAIL  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/4_1_17_UTL_MAIL.log
        fi


echo "" >> ${FINALDIR}/4_1_17_UTL_MAIL.log


echo ""



echo ""

echo "*************************** End of this module 4.1.17 check ***************************" >> ${FINALDIR}/4_1_17_UTL_MAIL.log

echo "*********************************************************************************" >> ${FINALDIR}/4_1_17_UTL_MAIL.log

}

REP_Fn_4_1_18_UTL_SMTP(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/4_1_18_UTL_SMTP.sql


checker=`cat ${REPSQLDIR}/sql_4_1_18_UTL_SMTP.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_4_1_18_UTL_SMTP.log  >> ${FINALDIR}/4_1_18_UTL_SMTP.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/4_1_18_UTL_SMTP.log
         echo " 4.1.18 Ensure EXECUTE Is Revoked from PUBLIC on UTL_SMTP - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 4.1.18 Ensure EXECUTE Is Revoked from PUBLIC on UTL_SMTP - AS PER CIS STANDARDS " >>  ${FINALDIR}/4_1_18_UTL_SMTP.log
        else
        echo ""  >>  ${FINALDIR}/4_1_18_UTL_SMTP.log

        echo " 4.1.18 Ensure EXECUTE Is Revoked from PUBLIC on UTL_SMTP  - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
                echo " 4.1.18 Ensure EXECUTE Is Revoked from PUBLIC on UTL_SMTP  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/4_1_18_UTL_SMTP.log
        fi


echo "" >> ${FINALDIR}/4_1_18_UTL_SMTP.log


echo ""



echo ""

echo "*************************** End of this module 4.1.18 check ***************************" >> ${FINALDIR}/4_1_18_UTL_SMTP.log

echo "*********************************************************************************" >> ${FINALDIR}/4_1_18_UTL_SMTP.log

}

REP_Fn_4_1_19_UTL_DBWS(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/4_1_19_UTL_DBWS.sql


checker=`cat ${REPSQLDIR}/sql_4_1_19_UTL_DBWS.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_4_1_19_UTL_DBWS.log  >> ${FINALDIR}/4_1_19_UTL_DBWS.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/4_1_19_UTL_DBWS.log
         echo " 4.1.19 Ensure EXECUTE Is Revoked from PUBLIC on UTL_DBWS - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 4.1.19 Ensure EXECUTE Is Revoked from PUBLIC on UTL_DBWS - AS PER CIS STANDARDS " >>  ${FINALDIR}/4_1_19_UTL_DBWS.log
        else
        echo ""  >>  ${FINALDIR}/4_1_19_UTL_DBWS.log

        echo " 4.1.19 Ensure EXECUTE Is Revoked from PUBLIC on UTL_DBWS  - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
                echo " 4.1.19 Ensure EXECUTE Is Revoked from PUBLIC on UTL_DBWS  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/4_1_19_UTL_DBWS.log
        fi


echo "" >> ${FINALDIR}/4_1_19_UTL_DBWS.log


echo ""



echo ""

echo "*************************** End of this module 4.1.19 check ***************************" >> ${FINALDIR}/4_1_19_UTL_DBWS.log

echo "*********************************************************************************" >> ${FINALDIR}/4_1_19_UTL_DBWS.log

}

REP_Fn_4_1_20_UTL_ORAMTS(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/4_1_20_UTL_ORAMTS.sql


checker=`cat ${REPSQLDIR}/sql_4_1_20_UTL_ORAMTS.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_4_1_20_UTL_ORAMTS.log  >> ${FINALDIR}/4_1_20_UTL_ORAMTS.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/4_1_20_UTL_ORAMTS.log
         echo " 4.1.20 Ensure EXECUTE Is Revoked from PUBLIC on UTL_ORAMTS - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 4.1.20 Ensure EXECUTE Is Revoked from PUBLIC on UTL_ORAMTS - AS PER CIS STANDARDS " >>  ${FINALDIR}/4_1_20_UTL_ORAMTS.log
        else
        echo ""  >>  ${FINALDIR}/4_1_20_UTL_ORAMTS.log

        echo " 4.1.20 Ensure EXECUTE Is Revoked from PUBLIC on UTL_ORAMTS  - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
                echo " 4.1.20 Ensure EXECUTE Is Revoked from PUBLIC on UTL_ORAMTS  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/4_1_20_UTL_ORAMTS.log
        fi


echo "" >> ${FINALDIR}/4_1_20_UTL_ORAMTS.log


echo ""



echo ""

echo "*************************** End of this module 4.1.20 check ***************************" >> ${FINALDIR}/4_1_20_UTL_ORAMTS.log

echo "*********************************************************************************" >> ${FINALDIR}/4_1_20_UTL_ORAMTS.log

}

REP_Fn_4_1_21_UTL_HTTP(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/4_1_21_UTL_HTTP.sql


checker=`cat ${REPSQLDIR}/sql_4_1_21_UTL_HTTP.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_4_1_21_UTL_HTTP.log  >> ${FINALDIR}/4_1_21_UTL_HTTP.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/4_1_21_UTL_HTTP.log
         echo " 4.1.21 Ensure EXECUTE Is Revoked from PUBLIC on UTL_HTTP - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 4.1.21 Ensure EXECUTE Is Revoked from PUBLIC on UTL_HTTP - AS PER CIS STANDARDS " >>  ${FINALDIR}/4_1_21_UTL_HTTP.log
        else
        echo ""  >>  ${FINALDIR}/4_1_21_UTL_HTTP.log

        echo " 4.1.21 Ensure EXECUTE Is Revoked from PUBLIC on UTL_HTTP  - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
                echo " 4.1.21 Ensure EXECUTE Is Revoked from PUBLIC on UTL_HTTP  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/4_1_21_UTL_HTTP.log
        fi


echo "" >> ${FINALDIR}/4_1_21_UTL_HTTP.log


echo ""



echo ""

echo "*************************** End of this module 4.1.21 check ***************************" >> ${FINALDIR}/4_1_21_UTL_HTTP.log

echo "*********************************************************************************" >> ${FINALDIR}/4_1_21_UTL_HTTP.log

}

REP_Fn_4_1_22_HTTPURITYPE(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/4_1_22_HTTPURITYPE.sql


checker=`cat ${REPSQLDIR}/sql_4_1_22_HTTPURITYPE.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_4_1_22_HTTPURITYPE.log  >> ${FINALDIR}/4_1_22_HTTPURITYPE.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/4_1_22_HTTPURITYPE.log
         echo " 4.1.22 Ensure EXECUTE Is Revoked from PUBLIC on HTTPURITYPE - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 4.1.22 Ensure EXECUTE Is Revoked from PUBLIC on HTTPURITYPE - AS PER CIS STANDARDS " >>  ${FINALDIR}/4_1_22_HTTPURITYPE.log
        else
        echo ""  >>  ${FINALDIR}/4_1_22_HTTPURITYPE.log

        echo " 4.1.22 Ensure EXECUTE Is Revoked from PUBLIC on HTTPURITYPE  - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
                echo " 4.1.22 Ensure EXECUTE Is Revoked from PUBLIC on HTTPURITYPE  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/4_1_22_HTTPURITYPE.log
        fi


echo "" >> ${FINALDIR}/4_1_22_HTTPURITYPE.log


echo ""



echo ""

echo "*************************** End of this module 4.1.22 check ***************************" >> ${FINALDIR}/4_1_22_HTTPURITYPE.log

echo "*********************************************************************************" >> ${FINALDIR}/4_1_22_HTTPURITYPE.log

}

######################### SECTION 4.1 ENDS HERE #########################


REP_Fn_4_2_1_DBMS_SYS_SQL(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/4_2_1_DBMS_SYS_SQL.sql


checker=`cat ${REPSQLDIR}/sql_4_2_1_DBMS_SYS_SQL.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_4_2_1_DBMS_SYS_SQL.log  >> ${FINALDIR}/4_2_1_DBMS_SYS_SQL.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/4_2_1_DBMS_SYS_SQL.log
         echo " 4.2.1 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_SYS_SQL - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 4.2.1 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_SYS_SQL - AS PER CIS STANDARDS " >>  ${FINALDIR}/4_2_1_DBMS_SYS_SQL.log
        else
        echo ""  >>  ${FINALDIR}/4_2_1_DBMS_SYS_SQL.log

        echo " 4.2.1 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_SYS_SQL  - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
                echo " 4.2.1 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_SYS_SQL  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/4_2_1_DBMS_SYS_SQL.log
        fi


echo "" >> ${FINALDIR}/4_2_1_DBMS_SYS_SQL.log


echo ""



echo ""

echo "*************************** End of this module 4.2.1 check ***************************" >> ${FINALDIR}/4_2_1_DBMS_SYS_SQL.log

echo "*********************************************************************************" >> ${FINALDIR}/4_2_1_DBMS_SYS_SQL.log

}

REP_Fn_4_2_2_DBMS_BACKUP_RESTORE(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/4_2_2_DBMS_BACKUP_RESTORE.sql


checker=`cat ${REPSQLDIR}/sql_4_2_2_DBMS_BACKUP_RESTORE.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_4_2_2_DBMS_BACKUP_RESTORE.log  >> ${FINALDIR}/4_2_2_DBMS_BACKUP_RESTORE.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/4_2_2_DBMS_BACKUP_RESTORE.log
         echo " 4.2.2 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_BACKUP_RESTORE - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 4.2.2 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_BACKUP_RESTORE - AS PER CIS STANDARDS " >>  ${FINALDIR}/4_2_2_DBMS_BACKUP_RESTORE.log
        else
        echo ""  >>  ${FINALDIR}/4_2_2_DBMS_BACKUP_RESTORE.log

        echo " 4.2.2 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_BACKUP_RESTORE  - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
                echo " 4.2.2 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_BACKUP_RESTORE  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/4_2_2_DBMS_BACKUP_RESTORE.log
        fi


echo "" >> ${FINALDIR}/4_2_2_DBMS_BACKUP_RESTORE.log


echo ""



echo ""

echo "*************************** End of this module 4.2.2 check ***************************" >> ${FINALDIR}/4_2_2_DBMS_BACKUP_RESTORE.log

echo "*********************************************************************************" >> ${FINALDIR}/4_2_2_DBMS_BACKUP_RESTORE.log

}

REP_Fn_4_2_3_DBMS_AQADM_SYSCALLS(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/4_2_3_DBMS_AQADM_SYSCALLS.sql


checker=`cat ${REPSQLDIR}/sql_4_2_3_DBMS_AQADM_SYSCALLS.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_4_2_3_DBMS_AQADM_SYSCALLS.log  >> ${FINALDIR}/4_2_3_DBMS_AQADM_SYSCALLS.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/4_2_3_DBMS_AQADM_SYSCALLS.log
         echo " 4.2.3 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_AQADM_SYSCALLS - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 4.2.3 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_AQADM_SYSCALLS - AS PER CIS STANDARDS " >>  ${FINALDIR}/4_2_3_DBMS_AQADM_SYSCALLS.log
        else
        echo ""  >>  ${FINALDIR}/4_2_3_DBMS_AQADM_SYSCALLS.log

        echo " 4.2.3 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_AQADM_SYSCALLS  - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
            echo " 4.2.3 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_AQADM_SYSCALLS  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/4_2_3_DBMS_AQADM_SYSCALLS.log
        fi


echo "" >> ${FINALDIR}/4_2_3_DBMS_AQADM_SYSCALLS.log


echo ""



echo ""

echo "*************************** End of this module 4.2.3 check ***************************" >> ${FINALDIR}/4_2_3_DBMS_AQADM_SYSCALLS.log

echo "*********************************************************************************" >> ${FINALDIR}/4_2_3_DBMS_AQADM_SYSCALLS.log

}

REP_Fn_4_2_4_DBMS_REPACT_SQL_UTL(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/4_2_4_DBMS_REPACT_SQL_UTL.sql


checker=`cat ${REPSQLDIR}/sql_4_2_4_DBMS_REPACT_SQL_UTL.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_4_2_4_DBMS_REPACT_SQL_UTL.log  >> ${FINALDIR}/4_2_4_DBMS_REPACT_SQL_UTL.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/4_2_4_DBMS_REPACT_SQL_UTL.log
         echo " 4.2.4 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_REPACT_SQL_UTL - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 4.2.4 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_REPACT_SQL_UTL - AS PER CIS STANDARDS " >>  ${FINALDIR}/4_2_4_DBMS_REPACT_SQL_UTL.log
        else
        echo ""  >>  ${FINALDIR}/4_2_4_DBMS_REPACT_SQL_UTL.log

        echo " 4.2.4 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_REPACT_SQL_UTL  - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
            echo " 4.2.4 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_REPACT_SQL_UTL  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/4_2_4_DBMS_REPACT_SQL_UTL.log
        fi


echo "" >> ${FINALDIR}/4_2_4_DBMS_REPACT_SQL_UTL.log


echo ""



echo ""

echo "*************************** End of this module 4.2.4 check ***************************" >> ${FINALDIR}/4_2_4_DBMS_REPACT_SQL_UTL.log

echo "*********************************************************************************" >> ${FINALDIR}/4_2_4_DBMS_REPACT_SQL_UTL.log

}

REP_Fn_4_2_5_INITJVMAUX(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/4_2_5_INITJVMAUX.sql


checker=`cat ${REPSQLDIR}/sql_4_2_5_INITJVMAUX.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_4_2_5_INITJVMAUX.log  >> ${FINALDIR}/4_2_5_INITJVMAUX.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/4_2_5_INITJVMAUX.log
         echo " 4.2.5 Ensure EXECUTE Is Revoked from PUBLIC on INITJVMAUX - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 4.2.5 Ensure EXECUTE Is Revoked from PUBLIC on INITJVMAUX - AS PER CIS STANDARDS " >>  ${FINALDIR}/4_2_5_INITJVMAUX.log
        else
        echo ""  >>  ${FINALDIR}/4_2_5_INITJVMAUX.log

        echo " 4.2.5 Ensure EXECUTE Is Revoked from PUBLIC on INITJVMAUX  - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
            echo " 4.2.5 Ensure EXECUTE Is Revoked from PUBLIC on INITJVMAUX  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/4_2_5_INITJVMAUX.log
        fi


echo "" >> ${FINALDIR}/4_2_5_INITJVMAUX.log


echo ""



echo ""

echo "*************************** End of this module 4.2.5 check ***************************" >> ${FINALDIR}/4_2_5_INITJVMAUX.log

echo "*********************************************************************************" >> ${FINALDIR}/4_2_5_INITJVMAUX.log

}

REP_Fn_4_2_6_DBMS_STREAMS_ADM_UTL(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/4_2_6_DBMS_STREAMS_ADM_UTL.sql


checker=`cat ${REPSQLDIR}/sql_4_2_6_DBMS_STREAMS_ADM_UTL.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_4_2_6_DBMS_STREAMS_ADM_UTL.log  >> ${FINALDIR}/4_2_6_DBMS_STREAMS_ADM_UTL.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/4_2_6_DBMS_STREAMS_ADM_UTL.log
         echo " 4.2.6 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_STREAMS_ADM_UTL - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 4.2.6 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_STREAMS_ADM_UTL - AS PER CIS STANDARDS " >>  ${FINALDIR}/4_2_6_DBMS_STREAMS_ADM_UTL.log
        else
        echo ""  >>  ${FINALDIR}/4_2_6_DBMS_STREAMS_ADM_UTL.log

        echo " 4.2.6 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_STREAMS_ADM_UTL  - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
            echo " 4.2.6 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_STREAMS_ADM_UTL  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/4_2_6_DBMS_STREAMS_ADM_UTL.log
        fi


echo "" >> ${FINALDIR}/4_2_6_DBMS_STREAMS_ADM_UTL.log


echo ""



echo ""

echo "*************************** End of this module 4.2.6 check ***************************" >> ${FINALDIR}/4_2_6_DBMS_STREAMS_ADM_UTL.log

echo "*********************************************************************************" >> ${FINALDIR}/4_2_6_DBMS_STREAMS_ADM_UTL.log

}

REP_Fn_4_2_7_DBMS_AQADM_SYS(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/4_2_7_DBMS_AQADM_SYS.sql


checker=`cat ${REPSQLDIR}/sql_4_2_7_DBMS_AQADM_SYS.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_4_2_7_DBMS_AQADM_SYS.log  >> ${FINALDIR}/4_2_7_DBMS_AQADM_SYS.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/4_2_7_DBMS_AQADM_SYS.log
         echo " 4.2.7 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_AQADM_SYS - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 4.2.7 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_AQADM_SYS - AS PER CIS STANDARDS " >>  ${FINALDIR}/4_2_7_DBMS_AQADM_SYS.log
        else
        echo ""  >>  ${FINALDIR}/4_2_7_DBMS_AQADM_SYS.log

        echo " 4.2.7 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_AQADM_SYS  - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
            echo " 4.2.7 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_AQADM_SYS  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/4_2_7_DBMS_AQADM_SYS.log
        fi


echo "" >> ${FINALDIR}/4_2_7_DBMS_AQADM_SYS.log


echo ""



echo ""

echo "*************************** End of this module 4.2.7 check ***************************" >> ${FINALDIR}/4_2_7_DBMS_AQADM_SYS.log

echo "*********************************************************************************" >> ${FINALDIR}/4_2_7_DBMS_AQADM_SYS.log

}

REP_Fn_4_2_8_DBMS_STREAMS_RPC(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/4_2_8_DBMS_STREAMS_RPC.sql


checker=`cat ${REPSQLDIR}/sql_4_2_8_DBMS_STREAMS_RPC.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_4_2_8_DBMS_STREAMS_RPC.log  >> ${FINALDIR}/4_2_8_DBMS_STREAMS_RPC.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/4_2_8_DBMS_STREAMS_RPC.log
         echo " 4.2.8 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_STREAMS_RPC - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 4.2.8 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_STREAMS_RPC - AS PER CIS STANDARDS " >>  ${FINALDIR}/4_2_8_DBMS_STREAMS_RPC.log
        else
        echo ""  >>  ${FINALDIR}/4_2_8_DBMS_STREAMS_RPC.log

        echo " 4.2.8 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_STREAMS_RPC  - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
            echo " 4.2.8 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_STREAMS_RPC  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/4_2_8_DBMS_STREAMS_RPC.log
        fi


echo "" >> ${FINALDIR}/4_2_8_DBMS_STREAMS_RPC.log


echo ""



echo ""

echo "*************************** End of this module 4.2.8 check ***************************" >> ${FINALDIR}/4_2_8_DBMS_STREAMS_RPC.log

echo "*********************************************************************************" >> ${FINALDIR}/4_2_8_DBMS_STREAMS_RPC.log

}

REP_Fn_4_2_9_DBMS_PRVTAQIM(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/4_2_9_DBMS_PRVTAQIM.sql


checker=`cat ${REPSQLDIR}/sql_4_2_9_DBMS_PRVTAQIM.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_4_2_9_DBMS_PRVTAQIM.log  >> ${FINALDIR}/4_2_9_DBMS_PRVTAQIM.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/4_2_9_DBMS_PRVTAQIM.log
         echo " 4.2.9 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_PRVTAQIM - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 4.2.9 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_PRVTAQIM - AS PER CIS STANDARDS " >>  ${FINALDIR}/4_2_9_DBMS_PRVTAQIM.log
        else
        echo ""  >>  ${FINALDIR}/4_2_9_DBMS_PRVTAQIM.log

        echo " 4.2.9 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_PRVTAQIM  - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
            echo " 4.2.9 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_PRVTAQIM  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/4_2_9_DBMS_PRVTAQIM.log
        fi


echo "" >> ${FINALDIR}/4_2_9_DBMS_PRVTAQIM.log


echo ""



echo ""

echo "*************************** End of this module 4.2.9 check ***************************" >> ${FINALDIR}/4_2_9_DBMS_PRVTAQIM.log

echo "*********************************************************************************" >> ${FINALDIR}/4_2_9_DBMS_PRVTAQIM.log

}

REP_Fn_4_2_10_LTADM(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/4_2_10_LTADM.sql


checker=`cat ${REPSQLDIR}/sql_4_2_10_LTADM.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_4_2_10_LTADM.log  >> ${FINALDIR}/4_2_10_LTADM.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/4_2_10_LTADM.log
         echo " 4.2.10 Ensure EXECUTE Is Revoked from PUBLIC on LTADM - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 4.2.10 Ensure EXECUTE Is Revoked from PUBLIC on LTADM - AS PER CIS STANDARDS " >>  ${FINALDIR}/4_2_10_LTADM.log
        else
        echo ""  >>  ${FINALDIR}/4_2_10_LTADM.log

        echo " 4.2.10 Ensure EXECUTE Is Revoked from PUBLIC on LTADM  - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
            echo " 4.2.10 Ensure EXECUTE Is Revoked from PUBLIC on LTADM  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/4_2_10_LTADM.log
        fi


echo "" >> ${FINALDIR}/4_2_10_LTADM.log


echo ""



echo ""

echo "*************************** End of this module 4.2.10 check ***************************" >> ${FINALDIR}/4_2_10_LTADM.log

echo "*********************************************************************************" >> ${FINALDIR}/4_2_10_LTADM.log

}

REP_Fn_4_2_11_WWV_DBMS_SQL(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/4_2_11_WWV_DBMS_SQL.sql


checker=`cat ${REPSQLDIR}/sql_4_2_11_WWV_DBMS_SQL.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_4_2_11_WWV_DBMS_SQL.log  >> ${FINALDIR}/4_2_11_WWV_DBMS_SQL.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/4_2_11_WWV_DBMS_SQL.log
         echo " 4.2.11 Ensure EXECUTE Is Revoked from PUBLIC on WWV_DBMS_SQL - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 4.2.11 Ensure EXECUTE Is Revoked from PUBLIC on WWV_DBMS_SQL - AS PER CIS STANDARDS " >>  ${FINALDIR}/4_2_11_WWV_DBMS_SQL.log
        else
        echo ""  >>  ${FINALDIR}/4_2_11_WWV_DBMS_SQL.log

        echo " 4.2.11 Ensure EXECUTE Is Revoked from PUBLIC on WWV_DBMS_SQL  - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
            echo " 4.2.11 Ensure EXECUTE Is Revoked from PUBLIC on WWV_DBMS_SQL  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/4_2_11_WWV_DBMS_SQL.log
        fi


echo "" >> ${FINALDIR}/4_2_11_WWV_DBMS_SQL.log


echo ""



echo ""

echo "*************************** End of this module 4.2.11 check ***************************" >> ${FINALDIR}/4_2_11_WWV_DBMS_SQL.log

echo "*********************************************************************************" >> ${FINALDIR}/4_2_11_WWV_DBMS_SQL.log

}

REP_Fn_4_2_12_WWV_EXECUTE_IMMEDIATE(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/4_2_12_WWV_EXECUTE_IMMEDIATE.sql


checker=`cat ${REPSQLDIR}/sql_4_2_12_WWV_EXECUTE_IMMEDIATE.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_4_2_12_WWV_EXECUTE_IMMEDIATE.log  >> ${FINALDIR}/4_2_12_WWV_EXECUTE_IMMEDIATE.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/4_2_12_WWV_EXECUTE_IMMEDIATE.log
         echo " 4.2.12 Ensure EXECUTE Is Revoked from PUBLIC on WWV_EXECUTE_IMMEDIATE - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 4.2.12 Ensure EXECUTE Is Revoked from PUBLIC on WWV_EXECUTE_IMMEDIATE - AS PER CIS STANDARDS " >>  ${FINALDIR}/4_2_12_WWV_EXECUTE_IMMEDIATE.log
        else
        echo ""  >>  ${FINALDIR}/4_2_12_WWV_EXECUTE_IMMEDIATE.log

        echo " 4.2.12 Ensure EXECUTE Is Revoked from PUBLIC on WWV_EXECUTE_IMMEDIATE  - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
            echo " 4.2.12 Ensure EXECUTE Is Revoked from PUBLIC on WWV_EXECUTE_IMMEDIATE  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/4_2_12_WWV_EXECUTE_IMMEDIATE.log
        fi


echo "" >> ${FINALDIR}/4_2_12_WWV_EXECUTE_IMMEDIATE.log


echo ""



echo ""

echo "*************************** End of this module 4.2.12 check ***************************" >> ${FINALDIR}/4_2_12_WWV_EXECUTE_IMMEDIATE.log

echo "*********************************************************************************" >> ${FINALDIR}/4_2_12_WWV_EXECUTE_IMMEDIATE.log

}

REP_Fn_4_2_13_DBMS_IJOB(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/4_2_13_DBMS_IJOB.sql


checker=`cat ${REPSQLDIR}/sql_4_2_13_DBMS_IJOB.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_4_2_13_DBMS_IJOB.log  >> ${FINALDIR}/4_2_13_DBMS_IJOB.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/4_2_13_DBMS_IJOB.log
         echo " 4.2.13 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_IJOB - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 4.2.13 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_IJOB - AS PER CIS STANDARDS " >>  ${FINALDIR}/4_2_13_DBMS_IJOB.log
        else
        echo ""  >>  ${FINALDIR}/4_2_13_DBMS_IJOB.log

        echo " 4.2.12 Ensure EXECUTE Is Revoked from PUBLIC on WWV_EXECUTE_IMMEDIATE  - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
            echo " 4.2.12 Ensure EXECUTE Is Revoked from PUBLIC on WWV_EXECUTE_IMMEDIATE  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/4_2_13_DBMS_IJOB.log
        fi


echo "" >> ${FINALDIR}/4_2_13_DBMS_IJOB.log


echo ""



echo ""

echo "*************************** End of this module 4.2.13 check ***************************" >> ${FINALDIR}/4_2_13_DBMS_IJOB.log

echo "*********************************************************************************" >> ${FINALDIR}/4_2_13_DBMS_IJOB.log

}

REP_Fn_4_2_14_DBMS_FILE_TRANSFER(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/4_2_14_DBMS_FILE_TRANSFER.sql


checker=`cat ${REPSQLDIR}/sql_4_2_13_DBMS_IJOB.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_4_2_13_DBMS_IJOB.log  >> ${FINALDIR}/4_2_14_DBMS_FILE_TRANSFER.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/4_2_14_DBMS_FILE_TRANSFER.log
         echo " 4.2.14 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_FILE_TRANSFER - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 4.2.14 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_FILE_TRANSFER - AS PER CIS STANDARDS " >>  ${FINALDIR}/4_2_14_DBMS_FILE_TRANSFER.log
        else
        echo ""  >>  ${FINALDIR}/4_2_14_DBMS_FILE_TRANSFER.log

        echo " 4.2.14 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_FILE_TRANSFER  - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
            echo " 4.2.14 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_FILE_TRANSFER  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/4_2_14_DBMS_FILE_TRANSFER.log
        fi


echo "" >> ${FINALDIR}/4_2_14_DBMS_FILE_TRANSFER.log


echo ""



echo ""

echo "*************************** End of this module 4.2.14 check ***************************" >> ${FINALDIR}/4_2_14_DBMS_FILE_TRANSFER.log

echo "*********************************************************************************" >> ${FINALDIR}/4_2_14_DBMS_FILE_TRANSFER.log

}

######################### SECTION 4.2 ENDS HERE #########################

REP_Fn_4_3_1_SELECT_ANY_DICTIONARY(){

echo "" >> cat ${SHELLDIR}/sql_4_3_1_Rev_SELECT_ANY_DICTIONARY.log  | grep -v selected |  awk {'print "revoke " $2,$3,$4,$5,$6,$7 " from " $1 ";"'} | grep -v "revoke       from ;"

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/4_3_1_SELECT_ANY_DICTIONARY.sql

checker=`cat ${REPSQLDIR}/sql_4_3_1_SELECT_ANY_DICTIONARY.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_4_3_1_SELECT_ANY_DICTIONARY.log  >> ${FINALDIR}/4_3_1_SELECT_ANY_DICTIONARY.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/4_3_1_SELECT_ANY_DICTIONARY.log
         echo " 4.3.1 Ensure SELECT_ANY_DICTIONARY Is Revoked from Unauthorized GRANTEE - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 4.3.1 Ensure SELECT_ANY_DICTIONARY Is Revoked from Unauthorized GRANTEE - AS PER CIS STANDARDS " >>  ${FINALDIR}/4_3_1_SELECT_ANY_DICTIONARY.log
        else
        echo ""  >>  ${FINALDIR}/4_3_1_SELECT_ANY_DICTIONARY.log

        echo " 4.3.1 Ensure SELECT_ANY_DICTIONARY Is Revoked from Unauthorized GRANTEE  - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
            echo " 4.3.1 Ensure SELECT_ANY_DICTIONARY Is Revoked from Unauthorized GRANTEE  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/4_3_1_SELECT_ANY_DICTIONARY.log
        fi


echo "" >> ${FINALDIR}/4_3_1_SELECT_ANY_DICTIONARY.log


echo ""



echo ""

echo "*************************** End of this module 4.3.1 check ***************************" >> ${FINALDIR}/4_3_1_SELECT_ANY_DICTIONARY.log

echo "*********************************************************************************" >> ${FINALDIR}/4_3_1_SELECT_ANY_DICTIONARY.log

}

REP_Fn_4_3_2_SELECT_ANY_TABLE(){

cat ${SHELLDIR}/sql_4_3_2_Rev_SELECT_ANY_TABLE.log  | grep -v selected |  awk {'print "revoke " $2,$3,$4,$5,$6,$7 " from " $1 ";"'} | grep -v "revoke       from ;"

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/4_3_2_SELECT_ANY_TABLE.sql

checker=`cat ${REPSQLDIR}/sql_4_3_2_SELECT_ANY_TABLE.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_4_3_2_SELECT_ANY_TABLE.log  >> ${FINALDIR}/4_3_2_SELECT_ANY_TABLE.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/4_3_2_SELECT_ANY_TABLE.log
         echo " 4.3.2 Ensure SELECT ANY TABLE Is Revoked from Unauthorized GRANTEE - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 4.3.2 Ensure SELECT ANY TABLE Is Revoked from Unauthorized GRANTEE - AS PER CIS STANDARDS " >>  ${FINALDIR}/4_3_2_SELECT_ANY_TABLE.log
        else
        echo ""  >>  ${FINALDIR}/4_3_2_SELECT_ANY_TABLE.log

        echo " 4.3.2 Ensure SELECT ANY TABLE Is Revoked from Unauthorized GRANTEE  - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
            echo " 4.3.2 Ensure SELECT ANY TABLE Is Revoked from Unauthorized GRANTEE  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/4_3_2_SELECT_ANY_TABLE.log
        fi


echo "" >> ${FINALDIR}/4_3_2_SELECT_ANY_TABLE.log


echo ""



echo ""

echo "*************************** End of this module 4.3.2 check ***************************" >> ${FINALDIR}/4_3_2_SELECT_ANY_TABLE.log

echo "*********************************************************************************" >> ${FINALDIR}/4_3_2_SELECT_ANY_TABLE.log

}

REP_Fn_4_3_3_AUDIT_SYSTEM(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/4_3_3_AUDIT_SYSTEM.sql

checker=`cat ${REPSQLDIR}/sql_4_3_3_AUDIT_SYSTEM.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_4_3_3_AUDIT_SYSTEM.log  >> ${FINALDIR}/4_3_3_AUDIT_SYSTEM.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/4_3_3_AUDIT_SYSTEM.log
         echo " 4.3.3 Ensure AUDIT SYSTEM Is Revoked from Unauthorized GRANTEE - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 4.3.3 Ensure AUDIT SYSTEM Is Revoked from Unauthorized GRANTEE - AS PER CIS STANDARDS " >>  ${FINALDIR}/4_3_3_AUDIT_SYSTEM.log
        else
        echo ""  >>  ${FINALDIR}/4_3_3_AUDIT_SYSTEM.log

        echo " 4.3.3 Ensure AUDIT SYSTEM Is Revoked from Unauthorized GRANTEE  - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
            echo " 4.3.3 Ensure AUDIT SYSTEM Is Revoked from Unauthorized GRANTEE  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/4_3_3_AUDIT_SYSTEM.log
        fi


echo "" >> ${FINALDIR}/4_3_3_AUDIT_SYSTEM.log


echo ""



echo ""

echo "*************************** End of this module 4.3.3 check ***************************" >> ${FINALDIR}/4_3_3_AUDIT_SYSTEM.log

echo "*********************************************************************************" >> ${FINALDIR}/4_3_3_AUDIT_SYSTEM.log

}

REP_Fn_4_3_4_EXEMPT_ACCESS_POLICY(){

cat ${SHELLDIR}/sql_4_3_4_Rev_EXEMPT_ACCESS_POLICY.log  | grep -v selected |  awk {'print "revoke " $2,$3,$4,$5,$6,$7 " from " $1 ";"'} | grep -v "revoke       from ;"

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/4_3_4_EXEMPT_ACCESS_POLICY.sql

checker=`cat ${REPSQLDIR}/sql_4_3_4_EXEMPT_ACCESS_POLICY.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_4_3_4_EXEMPT_ACCESS_POLICY.log  >> ${FINALDIR}/4_3_4_EXEMPT_ACCESS_POLICY.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/4_3_4_EXEMPT_ACCESS_POLICY.log
         echo " 4.3.4 Ensure EXEMPT ACCESS POLICY Is Revoked from Unauthorized GRANTEE - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 4.3.4 Ensure EXEMPT ACCESS POLICY Is Revoked from Unauthorized GRANTEE - AS PER CIS STANDARDS " >>  ${FINALDIR}/4_3_4_EXEMPT_ACCESS_POLICY.log
        else
        echo ""  >>  ${FINALDIR}/4_3_4_EXEMPT_ACCESS_POLICY.log

        echo " 4.3.4 Ensure EXEMPT ACCESS POLICY Is Revoked from Unauthorized GRANTEE - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
            echo " 4.3.4 Ensure EXEMPT ACCESS POLICY Is Revoked from Unauthorized GRANTEE - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/4_3_4_EXEMPT_ACCESS_POLICY.log
        fi


echo "" >> ${FINALDIR}/4_3_4_EXEMPT_ACCESS_POLICY.log


echo ""



echo ""

echo "*************************** End of this module 4.3.4 check ***************************" >> ${FINALDIR}/4_3_4_EXEMPT_ACCESS_POLICY.log

echo "*********************************************************************************" >> ${FINALDIR}/4_3_4_EXEMPT_ACCESS_POLICY.log

}

REP_Fn_4_3_5_BECOME_USER(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/4_3_5_BECOME_USER.sql

checker=`cat ${REPSQLDIR}/sql_4_3_5_BECOME_USER.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_4_3_5_BECOME_USER.log  >> ${FINALDIR}/4_3_5_BECOME_USER.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/4_3_5_BECOME_USER.log
         echo " 4.3.5 Ensure BECOME USER Is Revoked from Unauthorized GRANTEE - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 4.3.5 Ensure BECOME USER Is Revoked from Unauthorized GRANTEE - AS PER CIS STANDARDS " >>  ${FINALDIR}/4_3_5_BECOME_USER.log
        else
        echo ""  >>  ${FINALDIR}/4_3_5_BECOME_USER.log

        echo " 4.3.5 Ensure BECOME USER Is Revoked from Unauthorized GRANTEE - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
            echo " 4.3.5 Ensure BECOME USER Is Revoked from Unauthorized GRANTEE - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/4_3_5_BECOME_USER.log
        fi


echo "" >> ${FINALDIR}/4_3_5_BECOME_USER.log


echo ""



echo ""

echo "*************************** End of this module 4.3.5 check ***************************" >> ${FINALDIR}/4_3_5_BECOME_USER.log

echo "*********************************************************************************" >> ${FINALDIR}/4_3_5_BECOME_USER.log

}

REP_Fn_4_3_6_CREATE_PROCEDURE(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/4_3_6_CREATE_PROCEDURE.sql

checker=`cat ${REPSQLDIR}/sql_4_3_6_CREATE_PROCEDURE.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_4_3_6_CREATE_PROCEDURE.log  >> ${FINALDIR}/4_3_6_CREATE_PROCEDURE.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/4_3_6_CREATE_PROCEDURE.log
         echo " 4.3.6 Ensure CREATE_PROCEDURE Is Revoked from Unauthorized GRANTEE - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 4.3.6 Ensure CREATE_PROCEDURE Is Revoked from Unauthorized GRANTEE - AS PER CIS STANDARDS " >>  ${FINALDIR}/4_3_6_CREATE_PROCEDURE.log
        else
        echo ""  >>  ${FINALDIR}/4_3_6_CREATE_PROCEDURE.log

        echo " 4.3.6 Ensure CREATE_PROCEDURE Is Revoked from Unauthorized GRANTEE - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
            echo " 4.3.6 Ensure CREATE_PROCEDURE Is Revoked from Unauthorized GRANTEE - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/4_3_6_CREATE_PROCEDURE.log
        fi


echo "" >> ${FINALDIR}/4_3_6_CREATE_PROCEDURE.log


echo ""



echo ""

echo "*************************** End of this module 4.3.6 check ***************************" >> ${FINALDIR}/4_3_6_CREATE_PROCEDURE.log

echo "*********************************************************************************" >> ${FINALDIR}/4_3_6_CREATE_PROCEDURE.log

}

REP_Fn_4_3_7_ALTER_SYSTEM(){

cat ${SHELLDIR}/sql_4_3_7_Rev_ALTER_SYSTEM.log  | grep -v selected |  awk {'print "revoke " $2,$3,$4,$5,$6,$7 " from " $1 ";"'} | grep -v "revoke       from ;"

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/4_3_7_ALTER_SYSTEM.sql

checker=`cat ${REPSQLDIR}/sql_4_3_7_ALTER_SYSTEM.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_4_3_7_ALTER_SYSTEM.log  >> ${FINALDIR}/4_3_7_ALTER_SYSTEM.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/4_3_7_ALTER_SYSTEM.log
         echo " 4.3.7 Ensure ALTER SYSTEM Is Revoked from Unauthorized GRANTEE - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 4.3.7 Ensure ALTER SYSTEM Is Revoked from Unauthorized GRANTEE - AS PER CIS STANDARDS " >>  ${FINALDIR}/4_3_7_ALTER_SYSTEM.log
        else
        echo ""  >>  ${FINALDIR}/4_3_7_ALTER_SYSTEM.log

        echo " 4.3.7 Ensure ALTER SYSTEM Is Revoked from Unauthorized GRANTEE - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
            echo " 4.3.7 Ensure ALTER SYSTEM Is Revoked from Unauthorized GRANTEE - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/4_3_7_ALTER_SYSTEM.log
        fi


echo "" >> ${FINALDIR}/4_3_7_ALTER_SYSTEM.log


echo ""



echo ""

echo "*************************** End of this module 4.3.7 check ***************************" >> ${FINALDIR}/4_3_7_ALTER_SYSTEM.log

echo "*********************************************************************************" >> ${FINALDIR}/4_3_7_ALTER_SYSTEM.log

}

REP_Fn_4_3_8_CREATE_ANY_LIBRARY(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/4_3_8_CREATE_ANY_LIBRARY.sql

checker=`cat ${REPSQLDIR}/sql_4_3_8_CREATE_ANY_LIBRARY.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_4_3_8_CREATE_ANY_LIBRARY.log  >> ${FINALDIR}/4_3_8_CREATE_ANY_LIBRARY.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/4_3_8_CREATE_ANY_LIBRARY.log
         echo " 4.3.8 Ensure CREATE ANY LIBRARY Is Revoked from Unauthorized GRANTEE - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 4.3.8 Ensure CREATE ANY LIBRARY Is Revoked from Unauthorized GRANTEE - AS PER CIS STANDARDS " >>  ${FINALDIR}/4_3_8_CREATE_ANY_LIBRARY.log
        else
        echo ""  >>  ${FINALDIR}/4_3_8_CREATE_ANY_LIBRARY.log

        echo " 4.3.8 Ensure CREATE ANY LIBRARY Is Revoked from Unauthorized GRANTEE - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
            echo " 4.3.8 Ensure CREATE ANY LIBRARY Is Revoked from Unauthorized GRANTEE - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/4_3_8_CREATE_ANY_LIBRARY.log
        fi


echo "" >> ${FINALDIR}/4_3_8_CREATE_ANY_LIBRARY.log


echo ""



echo ""

echo "*************************** End of this module 4.3.8 check ***************************" >> ${FINALDIR}/4_3_8_CREATE_ANY_LIBRARY.log

echo "*********************************************************************************" >> ${FINALDIR}/4_3_8_CREATE_ANY_LIBRARY.log

}

REP_Fn_4_3_9_CREATE_LIBRARY(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/4_3_9_CREATE_LIBRARY.sql

checker=`cat ${REPSQLDIR}/sql_4_3_9_CREATE_LIBRARY.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_4_3_9_CREATE_LIBRARY.log  >> ${FINALDIR}/4_3_9_CREATE_LIBRARY.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/4_3_9_CREATE_LIBRARY.log
         echo " 4.3.9 Ensure CREATE LIBRARY Is Revoked from Unauthorized GRANTEE - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 4.3.9 Ensure CREATE LIBRARY Is Revoked from Unauthorized GRANTEE - AS PER CIS STANDARDS " >>  ${FINALDIR}/4_3_9_CREATE_LIBRARY.log
        else
        echo ""  >>  ${FINALDIR}/4_3_9_CREATE_LIBRARY.log

        echo " 4.3.9 Ensure CREATE LIBRARY Is Revoked from Unauthorized GRANTEE - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
            echo " 4.3.9 Ensure CREATE LIBRARY Is Revoked from Unauthorized GRANTEE - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/4_3_9_CREATE_LIBRARY.log
        fi


echo "" >> ${FINALDIR}/4_3_9_CREATE_LIBRARY.log


echo ""



echo ""

echo "*************************** End of this module 4.3.9 check ***************************" >> ${FINALDIR}/4_3_9_CREATE_LIBRARY.log

echo "*********************************************************************************" >> ${FINALDIR}/4_3_9_CREATE_LIBRARY.log

}

REP_Fn_4_3_10_GRANT_ANY_OBJECT_PRIV(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/4_3_10_GRANT_ANY_OBJECT_PRIV.sql

checker=`cat ${REPSQLDIR}/sql_4_3_10_GRANT_ANY_OBJECT_PRIV.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_4_3_10_GRANT_ANY_OBJECT_PRIV.log  >> ${FINALDIR}/4_3_10_GRANT_ANY_OBJECT_PRIV.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/4_3_10_GRANT_ANY_OBJECT_PRIV.log
         echo " 4.3.10 Ensure GRANT ANY OBJECT PRIVILEGE Is Revoked from GRANTEE - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 4.3.10 Ensure GRANT ANY OBJECT PRIVILEGE Is Revoked from GRANTEE - AS PER CIS STANDARDS " >>  ${FINALDIR}/4_3_10_GRANT_ANY_OBJECT_PRIV.log
        else
        echo ""  >>  ${FINALDIR}/4_3_10_GRANT_ANY_OBJECT_PRIV.log

        echo " 4.3.10 Ensure GRANT ANY OBJECT PRIVILEGE Is Revoked from GRANTEE - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
            echo " 4.3.10 Ensure GRANT ANY OBJECT PRIVILEGE Is Revoked from GRANTEE - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/4_3_10_GRANT_ANY_OBJECT_PRIV.log
        fi


echo "" >> ${FINALDIR}/4_3_10_GRANT_ANY_OBJECT_PRIV.log


echo ""



echo ""

echo "*************************** End of this module 4.3.10 check ***************************" >> ${FINALDIR}/4_3_10_GRANT_ANY_OBJECT_PRIV.log

echo "*********************************************************************************" >> ${FINALDIR}/4_3_10_GRANT_ANY_OBJECT_PRIV.log

}

REP_Fn_4_3_11_GRANT_ANY_ROLE(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/4_3_11_GRANT_ANY_ROLE.sql

checker=`cat ${REPSQLDIR}/sql_4_3_11_GRANT_ANY_ROLE.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_4_3_11_GRANT_ANY_ROLE.log  >> ${FINALDIR}/4_3_11_GRANT_ANY_ROLE.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/4_3_11_GRANT_ANY_ROLE.log
         echo " 4.3.11 Ensure GRANT ANY ROLE Is Revoked from Unauthorized GRANTEE - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 4.3.11 Ensure GRANT ANY ROLE Is Revoked from Unauthorized GRANTEE - AS PER CIS STANDARDS " >>  ${FINALDIR}/4_3_11_GRANT_ANY_ROLE.log
        else
        echo ""  >>  ${FINALDIR}/4_3_11_GRANT_ANY_ROLE.log

        echo " 4.3.11 Ensure GRANT ANY ROLE Is Revoked from Unauthorized GRANTEE - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
            echo " 4.3.11 Ensure GRANT ANY ROLE Is Revoked from Unauthorized GRANTEE - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/4_3_11_GRANT_ANY_ROLE.log
        fi


echo "" >> ${FINALDIR}/4_3_11_GRANT_ANY_ROLE.log


echo ""



echo ""

echo "*************************** End of this module 4.3.11 check ***************************" >> ${FINALDIR}/4_3_11_GRANT_ANY_ROLE.log

echo "*********************************************************************************" >> ${FINALDIR}/4_3_11_GRANT_ANY_ROLE.log

}

REP_Fn_4_3_12_GRANT_ANY_PRIV(){

cat ${SHELLDIR}/sql_4_3_12_GRANT_ANY_PRIVILEGE.log  | grep -v selected |  awk {'print "revoke " $2,$3,$4,$5,$6,$7 " from " $1 ";"'} | grep -v "revoke       from ;"

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/4_3_12_GRANT_ANY_PRIV.sql

checker=`cat ${REPSQLDIR}/sql_4_3_12_GRANT_ANY_PRIV.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_4_3_12_GRANT_ANY_PRIV.log  >> ${FINALDIR}/4_3_12_GRANT_ANY_PRIV.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/4_3_12_GRANT_ANY_PRIV.log
         echo " 4.3.12 Ensure GRANT ANY PRIVILEGE Is Revoked from Unauthorized GRANTEE - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 4.3.12 Ensure GRANT ANY PRIVILEGE Is Revoked from Unauthorized GRANTEE - AS PER CIS STANDARDS " >>  ${FINALDIR}/4_3_12_GRANT_ANY_PRIV.log
        else
        echo ""  >>  ${FINALDIR}/4_3_12_GRANT_ANY_PRIV.log

        echo " 4.3.12 Ensure GRANT ANY PRIVILEGE Is Revoked from Unauthorized GRANTEE - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
            echo " 4.3.12 Ensure GRANT ANY PRIVILEGE Is Revoked from Unauthorized GRANTEE - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/4_3_12_GRANT_ANY_PRIV.log
        fi


echo "" >> ${FINALDIR}/4_3_12_GRANT_ANY_PRIV.log


echo ""



echo ""

echo "*************************** End of this module 4.3.12 check ***************************" >> ${FINALDIR}/4_3_12_GRANT_ANY_PRIV.log

echo "*********************************************************************************" >> ${FINALDIR}/4_3_12_GRANT_ANY_PRIV.log

}

######################### SECTION 4.3 ENDS HERE #########################

REP_Fn_4_4_1_DELETE_CATALOG_ROLE(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/4_4_1_DELETE_CATALOG_ROLE.sql

checker=`cat ${REPSQLDIR}/sql_4_4_1_DELETE_CATALOG_ROLE.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_4_4_1_DELETE_CATALOG_ROLE.log  >> ${FINALDIR}/4_4_1_DELETE_CATALOG_ROLE.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/4_4_1_DELETE_CATALOG_ROLE.log
         echo " 4.4.1 Ensure DELETE_CATALOG_ROLE Is Revoked from Unauthorized GRANTEE - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 4.4.1 Ensure DELETE_CATALOG_ROLE Is Revoked from Unauthorized GRANTEE - AS PER CIS STANDARDS " >>  ${FINALDIR}/4_4_1_DELETE_CATALOG_ROLE.log
        else
        echo ""  >>  ${FINALDIR}/4_4_1_DELETE_CATALOG_ROLE.log

        echo " 4.4.1 Ensure DELETE_CATALOG_ROLE Is Revoked from Unauthorized GRANTEE - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
            echo " 4.4.1 Ensure DELETE_CATALOG_ROLE Is Revoked from Unauthorized GRANTEE - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/4_4_1_DELETE_CATALOG_ROLE.log
        fi


echo "" >> ${FINALDIR}/4_4_1_DELETE_CATALOG_ROLE.log


echo ""



echo ""

echo "*************************** End of this module 4.4.1 check ***************************" >> ${FINALDIR}/4_4_1_DELETE_CATALOG_ROLE.log

echo "*********************************************************************************" >> ${FINALDIR}/4_4_1_DELETE_CATALOG_ROLE.log

}

REP_Fn_4_4_2_SELECT_CATALOG_ROLE(){

cat ${SHELLDIR}/sql_4_4_2_SELECT_CATALOG_ROLE.log  | grep -v selected |  awk {'print "revoke " $2,$3,$4,$5,$6,$7 " from " $1 ";"'} | grep -v "revoke       from ;"

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/4_4_2_SELECT_CATALOG_ROLE.sql

checker=`cat ${REPSQLDIR}/sql_4_4_2_SELECT_CATALOG_ROLE.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_4_4_2_SELECT_CATALOG_ROLE.log  >> ${FINALDIR}/4_4_2_SELECT_CATALOG_ROLE.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/4_4_2_SELECT_CATALOG_ROLE.log
         echo " 4.4.2 Ensure SELECT_CATALOG_ROLE Is Revoked from Unauthorized GRANTEE - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 4.4.2 Ensure SELECT_CATALOG_ROLE Is Revoked from Unauthorized GRANTEE - AS PER CIS STANDARDS " >>  ${FINALDIR}/4_4_2_SELECT_CATALOG_ROLE.log
        else
        echo ""  >>  ${FINALDIR}/4_4_2_SELECT_CATALOG_ROLE.log

        echo " 4.4.2 Ensure SELECT_CATALOG_ROLE Is Revoked from Unauthorized GRANTEE - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
            echo " 4.4.2 Ensure SELECT_CATALOG_ROLE Is Revoked from Unauthorized GRANTEE - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/4_4_2_SELECT_CATALOG_ROLE.log
        fi


echo "" >> ${FINALDIR}/4_4_2_SELECT_CATALOG_ROLE.log


echo ""



echo ""

echo "*************************** End of this module 4.4.2 check ***************************" >> ${FINALDIR}/4_4_2_SELECT_CATALOG_ROLE.log

echo "*********************************************************************************" >> ${FINALDIR}/4_4_2_SELECT_CATALOG_ROLE.log

}

REP_Fn_4_4_3_EXECUTE_CATALOG_ROLE(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/4_4_3_EXECUTE_CATALOG_ROLE.sql

checker=`cat ${REPSQLDIR}/sql_4_4_3_EXECUTE_CATALOG_ROLE.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_4_4_3_EXECUTE_CATALOG_ROLE.log  >> ${FINALDIR}/4_4_3_EXECUTE_CATALOG_ROLE.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/4_4_3_EXECUTE_CATALOG_ROLE.log
         echo " 4.4.3 Ensure EXECUTE_CATALOG_ROLE Is Revoked from Unauthorized GRANTEE - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 4.4.3 Ensure EXECUTE_CATALOG_ROLE Is Revoked from Unauthorized GRANTEE - AS PER CIS STANDARDS " >>  ${FINALDIR}/4_4_3_EXECUTE_CATALOG_ROLE.log
        else
        echo ""  >>  ${FINALDIR}/4_4_3_EXECUTE_CATALOG_ROLE.log

        echo " 4.4.3 Ensure EXECUTE_CATALOG_ROLE Is Revoked from Unauthorized GRANTEE - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
            echo " 4.4.3 Ensure EXECUTE_CATALOG_ROLE Is Revoked from Unauthorized GRANTEE - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/4_4_3_EXECUTE_CATALOG_ROLE.log
        fi


echo "" >> ${FINALDIR}/4_4_3_EXECUTE_CATALOG_ROLE.log


echo ""



echo ""

echo "*************************** End of this module 4.4.3 check ***************************" >> ${FINALDIR}/4_4_3_EXECUTE_CATALOG_ROLE.log

echo "*********************************************************************************" >> ${FINALDIR}/4_4_3_EXECUTE_CATALOG_ROLE.log

}

REP_Fn_4_4_4_REVOKE_DBA(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/4_4_4_REVOKE_DBA.sql

checker=`cat ${REPSQLDIR}/sql_4_4_4_REVOKE_DBA.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_4_4_4_REVOKE_DBA.log  >> ${FINALDIR}/4_4_4_REVOKE_DBA.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/4_4_4_REVOKE_DBA.log
         echo " 4.4.4 Ensure DBA Is Revoked from Unauthorized GRANTEE - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 4.4.4 Ensure DBA Is Revoked from Unauthorized GRANTEE - AS PER CIS STANDARDS " >>  ${FINALDIR}/4_4_4_REVOKE_DBA.log
        else
        echo ""  >>  ${FINALDIR}/4_4_4_REVOKE_DBA.log

        echo " 4.4.4 Ensure DBA Is Revoked from Unauthorized GRANTEE - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
            echo " 4.4.4 Ensure DBA Is Revoked from Unauthorized GRANTEE - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/4_4_4_REVOKE_DBA.log
        fi


echo "" >> ${FINALDIR}/4_4_4_REVOKE_DBA.log


echo ""



echo ""

echo "*************************** End of this module 4.4.4 check ***************************" >> ${FINALDIR}/4_4_4_REVOKE_DBA.log

echo "*********************************************************************************" >> ${FINALDIR}/4_4_4_REVOKE_DBA.log

}

######################### SECTION 4.4 ENDS HERE #########################

REP_Fn_4_5_1_REV_ALL_AUD(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/4_5_1_REV_ALL_AUD.sql

checker=`cat ${REPSQLDIR}/sql_4_5_1_REV_ALL_AUD.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_4_5_1_REV_ALL_AUD.log  >> ${FINALDIR}/4_5_1_REV_ALL_AUD.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/4_5_1_REV_ALL_AUD.log
         echo " 4.5.1 Ensure ALL Is Revoked from Unauthorized GRANTEE on AUD$ - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 4.5.1 Ensure ALL Is Revoked from Unauthorized GRANTEE on AUD$ - AS PER CIS STANDARDS " >>  ${FINALDIR}/4_5_1_REV_ALL_AUD.log
        else
        echo ""  >>  ${FINALDIR}/4_5_1_REV_ALL_AUD.log

        echo " 4.5.1 Ensure ALL Is Revoked from Unauthorized GRANTEE on AUD$ - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
            echo " 4.5.1 Ensure ALL Is Revoked from Unauthorized GRANTEE on AUD$ - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/4_5_1_REV_ALL_AUD.log
        fi


echo "" >> ${FINALDIR}/4_5_1_REV_ALL_AUD.log


echo ""



echo ""

echo "*************************** End of this module 4.5.1 check ***************************" >> ${FINALDIR}/4_5_1_REV_ALL_AUD.log

echo "*********************************************************************************" >> ${FINALDIR}/4_5_1_REV_ALL_AUD.log

}

REP_Fn_4_5_2_REV_ALL_USER_HISTORY(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/4_5_2_REV_ALL_USER_HISTORY.sql

checker=`cat ${REPSQLDIR}/sql_4_5_2_REV_ALL_USER_HISTORY.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_4_5_2_REV_ALL_USER_HISTORY.log  >> ${FINALDIR}/4_5_2_REV_ALL_USER_HISTORY.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/4_5_2_REV_ALL_USER_HISTORY.log
         echo " 4.5.2 Ensure ALL Is Revoked from Unauthorized GRANTEE on USER_HISTORY$ - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 4.5.2 Ensure ALL Is Revoked from Unauthorized GRANTEE on USER_HISTORY$ - AS PER CIS STANDARDS " >>  ${FINALDIR}/4_5_2_REV_ALL_USER_HISTORY.log
        else
        echo ""  >>  ${FINALDIR}/4_5_2_REV_ALL_USER_HISTORY.log

        echo " 4.5.2 Ensure ALL Is Revoked from Unauthorized GRANTEE on USER_HISTORY$ - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
            echo " 4.5.2 Ensure ALL Is Revoked from Unauthorized GRANTEE on USER_HISTORY$ - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/4_5_2_REV_ALL_USER_HISTORY.log
        fi


echo "" >> ${FINALDIR}/4_5_2_REV_ALL_USER_HISTORY.log


echo ""



echo ""

echo "*************************** End of this module 4.5.2 check ***************************" >> ${FINALDIR}/4_5_2_REV_ALL_USER_HISTORY.log

echo "*********************************************************************************" >> ${FINALDIR}/4_5_2_REV_ALL_USER_HISTORY.log

}

REP_Fn_4_5_3_REV_ALL_LINK(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/4_5_3_REV_ALL_LINK.sql

checker=`cat ${REPSQLDIR}/sql_4_5_3_REV_ALL_LINK.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_4_5_3_REV_ALL_LINK.log  >> ${FINALDIR}/4_5_3_REV_ALL_LINK.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/4_5_3_REV_ALL_LINK.log
         echo " 4.5.3 Ensure ALL Is Revoked from Unauthorized GRANTEE on LINK$ - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 4.5.3 Ensure ALL Is Revoked from Unauthorized GRANTEE on LINK$ - AS PER CIS STANDARDS " >>  ${FINALDIR}/4_5_3_REV_ALL_LINK.log
        else
        echo ""  >>  ${FINALDIR}/4_5_3_REV_ALL_LINK.log

        echo " 4.5.3 Ensure ALL Is Revoked from Unauthorized GRANTEE on LINK$ - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
            echo " 4.5.3 Ensure ALL Is Revoked from Unauthorized GRANTEE on LINK$ - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/4_5_3_REV_ALL_LINK.log
        fi


echo "" >> ${FINALDIR}/4_5_3_REV_ALL_LINK.log


echo ""



echo ""

echo "*************************** End of this module 4.5.3 check ***************************" >> ${FINALDIR}/4_5_3_REV_ALL_LINK.log

echo "*********************************************************************************" >> ${FINALDIR}/4_5_3_REV_ALL_LINK.log

}

REP_Fn_4_5_4_REV_ALL_SYS_USER(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/4_5_4_REV_ALL_SYS_USER.sql

checker=`cat ${REPSQLDIR}/sql_4_5_4_REV_ALL_SYS_USER.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_4_5_4_REV_ALL_SYS_USER.log  >> ${FINALDIR}/4_5_4_REV_ALL_SYS_USER.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/4_5_4_REV_ALL_SYS_USER.log
         echo " 4.5.4 Ensure ALL Is Revoked from Unauthorized GRANTEE on SYS.USER$ - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 4.5.4 Ensure ALL Is Revoked from Unauthorized GRANTEE on SYS.USER$ - AS PER CIS STANDARDS " >>  ${FINALDIR}/4_5_4_REV_ALL_SYS_USER.log
        else
        echo ""  >>  ${FINALDIR}/4_5_4_REV_ALL_SYS_USER.log

        echo " 4.5.4 Ensure ALL Is Revoked from Unauthorized GRANTEE on SYS.USER$ - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
            echo " 4.5.4 Ensure ALL Is Revoked from Unauthorized GRANTEE on SYS.USER$ - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/4_5_4_REV_ALL_SYS_USER.log
        fi


echo "" >> ${FINALDIR}/4_5_4_REV_ALL_SYS_USER.log


echo ""



echo ""

echo "*************************** End of this module 4.5.4 check ***************************" >> ${FINALDIR}/4_5_4_REV_ALL_SYS_USER.log

echo "*********************************************************************************" >> ${FINALDIR}/4_5_4_REV_ALL_SYS_USER.log

}

REP_Fn_4_5_5_REV_ALL_DBA(){

cat ${SHELLDIR}/sql_4_5_5_Rev_ALL_DBA.log  | grep -v selected |  awk {'print "revoke " $2,$3,$4,$5,$6,$7 " from " $1 ";"'} | grep -v "revoke       from ;"

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/4_5_5_REV_ALL_DBA.sql

checker=`cat ${REPSQLDIR}/sql_4_5_5_REV_ALL_DBA.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_4_5_5_REV_ALL_DBA.log  >> ${FINALDIR}/4_5_5_REV_ALL_DBA.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/4_5_5_REV_ALL_DBA.log
         echo " 4.5.5 Ensure ALL Is Revoked from Unauthorized GRANTEE on DBA_%  - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 4.5.5 Ensure ALL Is Revoked from Unauthorized GRANTEE on DBA_%  - AS PER CIS STANDARDS " >>  ${FINALDIR}/4_5_5_REV_ALL_DBA.log
        else
        echo ""  >>  ${FINALDIR}/4_5_5_REV_ALL_DBA.log

        echo " 4.5.5 Ensure ALL Is Revoked from Unauthorized GRANTEE on DBA_%  - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
            echo " 4.5.5 Ensure ALL Is Revoked from Unauthorized GRANTEE on DBA_%  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/4_5_5_REV_ALL_DBA.log
        fi


echo "" >> ${FINALDIR}/4_5_5_REV_ALL_DBA.log


echo ""



echo ""

echo "*************************** End of this module 4.5.5 check ***************************" >> ${FINALDIR}/4_5_5_REV_ALL_DBA.log

echo "*********************************************************************************" >> ${FINALDIR}/4_5_5_REV_ALL_DBA.log

}

REP_Fn_4_5_6_REV_ALL_SYS_SCHEDULER_CREDENTIAL(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/4_5_6_REV_ALL_SYS_SCHEDULER_CREDENTIAL.sql

checker=`cat ${REPSQLDIR}/sql_4_5_6_REV_ALL_SYS_SCHEDULER_CREDENTIAL.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_4_5_6_REV_ALL_SYS_SCHEDULER_CREDENTIAL.log  >> ${FINALDIR}/4_5_6_REV_ALL_SYS_SCHEDULER_CREDENTIAL.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/4_5_6_REV_ALL_SYS_SCHEDULER_CREDENTIAL.log
         echo " 4.5.6 Ensure ALL Is Revoked from Unauthorized GRANTEE on SYS.SCHEDULER$_CREDENTIAL  - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 4.5.6 Ensure ALL Is Revoked from Unauthorized GRANTEE on SYS.SCHEDULER$_CREDENTIAL  - AS PER CIS STANDARDS " >>  ${FINALDIR}/4_5_6_REV_ALL_SYS_SCHEDULER_CREDENTIAL.log
        else
        echo ""  >>  ${FINALDIR}/4_5_6_REV_ALL_SYS_SCHEDULER_CREDENTIAL.log

        echo " 4.5.6 Ensure ALL Is Revoked from Unauthorized GRANTEE on SYS.SCHEDULER$_CREDENTIAL  - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
            echo " 4.5.6 Ensure ALL Is Revoked from Unauthorized GRANTEE on SYS.SCHEDULER$_CREDENTIAL  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/4_5_6_REV_ALL_SYS_SCHEDULER_CREDENTIAL.log
        fi


echo "" >> ${FINALDIR}/4_5_6_REV_ALL_SYS_SCHEDULER_CREDENTIAL.log


echo ""



echo ""

echo "*************************** End of this module 4.5.6 check ***************************" >> ${FINALDIR}/4_5_6_REV_ALL_SYS_SCHEDULER_CREDENTIAL.log

echo "*********************************************************************************" >> ${FINALDIR}/4_5_6_REV_ALL_SYS_SCHEDULER_CREDENTIAL.log

}

REP_Fn_4_5_7_DROP_SYS_USER_MIG(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/4_5_7_DROP_SYS_USER_MIG.sql

checker=`cat ${REPSQLDIR}/sql_4_5_7_DROP_SYS_USER_MIG.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_4_5_7_DROP_SYS_USER_MIG.log  >> ${FINALDIR}/4_5_7_DROP_SYS_USER_MIG.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/4_5_7_DROP_SYS_USER_MIG.log
         echo " 4.5.7 Ensure SYS.USER$MIG Has Been Dropped  - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 4.5.7 Ensure SYS.USER$MIG Has Been Dropped  - AS PER CIS STANDARDS " >>  ${FINALDIR}/4_5_7_DROP_SYS_USER_MIG.log
        else
        echo ""  >>  ${FINALDIR}/4_5_7_DROP_SYS_USER_MIG.log

        echo " 4.5.7 Ensure SYS.USER$MIG Has Been Dropped  - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
            echo " 4.5.7 Ensure SYS.USER$MIG Has Been Dropped  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/4_5_7_DROP_SYS_USER_MIG.log
        fi


echo "" >> ${FINALDIR}/4_5_7_DROP_SYS_USER_MIG.log


echo ""



echo ""

echo "*************************** End of this module 4.5.7 check ***************************" >> ${FINALDIR}/4_5_7_DROP_SYS_USER_MIG.log

echo "*********************************************************************************" >> ${FINALDIR}/4_5_7_DROP_SYS_USER_MIG.log

}

######################### SECTION 4.5 ENDS HERE #########################

REP_Fn_4_6_REV_ANY(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/4_6_REV_ANY.sql

checker=`cat ${REPSQLDIR}/sql_4_6_REV_ANY.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_4_6_REV_ANY.log  >> ${FINALDIR}/4_6_REV_ANY.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/4_6_REV_ANY.log
         echo " 4.6 Ensure %ANY% Is Revoked from Unauthorized GRANTEE  - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 4.6 Ensure %ANY% Is Revoked from Unauthorized GRANTEE  - AS PER CIS STANDARDS " >>  ${FINALDIR}/4_6_REV_ANY.log
        else
        echo ""  >>  ${FINALDIR}/4_6_REV_ANY.log

        echo " 4.6 Ensure %ANY% Is Revoked from Unauthorized GRANTEE  - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
            echo " 4.6 Ensure %ANY% Is Revoked from Unauthorized GRANTEE  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/4_6_REV_ANY.log
        fi


echo "" >> ${FINALDIR}/4_6_REV_ANY.log


echo ""



echo ""

echo "*************************** End of this module 4.6 check ***************************" >> ${FINALDIR}/4_6_REV_ANY.log

echo "*********************************************************************************" >> ${FINALDIR}/4_6_REV_ANY.log

}

REP_Fn_4_7_REV_DBA_SYS_PRIVS(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/4_7_REV_DBA_SYS_PRIVS.sql

checker=`cat ${REPSQLDIR}/sql_4_7_REV_DBA_SYS_PRIVS.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_4_7_REV_DBA_SYS_PRIVS.log  >> ${FINALDIR}/4_7_REV_DBA_SYS_PRIVS.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/4_7_REV_DBA_SYS_PRIVS.log
         echo " 4.7 Ensure DBA_SYS_PRIVS.% Is Revoked from Unauthorized GRANTEE with ADMIN_OPTION Set to YES  - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 4.7 Ensure DBA_SYS_PRIVS.% Is Revoked from Unauthorized GRANTEE with ADMIN_OPTION Set to YES  - AS PER CIS STANDARDS " >>  ${FINALDIR}/4_7_REV_DBA_SYS_PRIVS.log
        else
        echo ""  >>  ${FINALDIR}/4_7_REV_DBA_SYS_PRIVS.log

        echo " 4.7 Ensure DBA_SYS_PRIVS.% Is Revoked from Unauthorized GRANTEE with ADMIN_OPTION Set to YES - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
            echo " 4.7 Ensure DBA_SYS_PRIVS.% Is Revoked from Unauthorized GRANTEE with ADMIN_OPTION Set to YES  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/4_7_REV_DBA_SYS_PRIVS.log
        fi


echo "" >> ${FINALDIR}/4_7_REV_DBA_SYS_PRIVS.log


echo ""



echo ""

echo "*************************** End of this module 4.7 check ***************************" >> ${FINALDIR}/4_7_REV_DBA_SYS_PRIVS.log

echo "*********************************************************************************" >> ${FINALDIR}/4_7_REV_DBA_SYS_PRIVS.log

}

REP_Fn_4_8_PROXY_USER_PRIV(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/4_8_PROXY_USER_PRIV.sql

checker=`cat ${REPSQLDIR}/sql_4_8_PROXY_USER_PRIV.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_4_8_PROXY_USER_PRIV.log  >> ${FINALDIR}/4_8_PROXY_USER_PRIV.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/4_8_PROXY_USER_PRIV.log
         echo " 4.8 Ensure Proxy Users Have Only CONNECT Privilege  - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 4.8 Ensure Proxy Users Have Only CONNECT Privilege  - AS PER CIS STANDARDS " >>  ${FINALDIR}/4_8_PROXY_USER_PRIV.log
        else
        echo ""  >>  ${FINALDIR}/4_8_PROXY_USER_PRIV.log

        echo " 4.8 Ensure Proxy Users Have Only CONNECT Privilege - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
            echo " 4.8 Ensure Proxy Users Have Only CONNECT Privilege  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/4_8_PROXY_USER_PRIV.log
        fi


echo "" >> ${FINALDIR}/4_8_PROXY_USER_PRIV.log


echo ""



echo ""

echo "*************************** End of this module 4.8 check ***************************" >> ${FINALDIR}/4_8_PROXY_USER_PRIV.log

echo "*********************************************************************************" >> ${FINALDIR}/4_8_PROXY_USER_PRIV.log

}

REP_Fn_4_9_REV_EXE_ANY_PROC_OUTLN(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/4_9_REV_EXE_ANY_PROC_OUTLN.sql

checker=`cat ${REPSQLDIR}/sql_4_9_REV_EXE_ANY_PROC_OUTLN.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_4_9_REV_EXE_ANY_PROC_OUTLN.log  >> ${FINALDIR}/4_9_REV_EXE_ANY_PROC_OUTLN.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/4_9_REV_EXE_ANY_PROC_OUTLN.log
         echo " 4.9 Ensure EXECUTE ANY PROCEDURE Is Revoked from OUTLN - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 4.9 Ensure EXECUTE ANY PROCEDURE Is Revoked from OUTLN  - AS PER CIS STANDARDS " >>  ${FINALDIR}/4_9_REV_EXE_ANY_PROC_OUTLN.log
        else
        echo ""  >>  ${FINALDIR}/4_9_REV_EXE_ANY_PROC_OUTLN.log

        echo " 4.9 Ensure EXECUTE ANY PROCEDURE Is Revoked from OUTLN - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
            echo " 4.9 Ensure EXECUTE ANY PROCEDURE Is Revoked from OUTLN  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/4_9_REV_EXE_ANY_PROC_OUTLN.log
        fi


echo "" >> ${FINALDIR}/4_9_REV_EXE_ANY_PROC_OUTLN.log


echo ""



echo ""

echo "*************************** End of this module 4.9 check ***************************" >> ${FINALDIR}/4_9_REV_EXE_ANY_PROC_OUTLN.log

echo "*********************************************************************************" >> ${FINALDIR}/4_9_REV_EXE_ANY_PROC_OUTLN.log

}

REP_Fn_4_10_REV_EXE_ANY_PROC_DBSNMP(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/4_10_REV_EXE_ANY_PROC_DBSNMP.sql

checker=`cat ${REPSQLDIR}/sql_4_10_REV_EXE_ANY_PROC_DBSNMP.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_4_10_REV_EXE_ANY_PROC_DBSNMP.log  >> ${FINALDIR}/4_10_REV_EXE_ANY_PROC_DBSNMP.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/4_10_REV_EXE_ANY_PROC_DBSNMP.log
         echo " 4.10 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_FILE_TRANSFER - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 4.10 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_FILE_TRANSFER  - AS PER CIS STANDARDS " >>  ${FINALDIR}/4_10_REV_EXE_ANY_PROC_DBSNMP.log
        else
        echo ""  >>  ${FINALDIR}/4_10_REV_EXE_ANY_PROC_DBSNMP.log

        echo " 4.10 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_FILE_TRANSFER - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
            echo " 4.10 Ensure EXECUTE Is Revoked from PUBLIC on DBMS_FILE_TRANSFER  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/4_10_REV_EXE_ANY_PROC_DBSNMP.log
        fi


echo "" >> ${FINALDIR}/4_10_REV_EXE_ANY_PROC_DBSNMP.log


echo ""



echo ""

echo "*************************** End of this module 4.10 check ***************************" >> ${FINALDIR}/4_10_REV_EXE_ANY_PROC_DBSNMP.log

echo "*********************************************************************************" >> ${FINALDIR}/4_10_REV_EXE_ANY_PROC_DBSNMP.log

}

######################### SECTION 4 ENDS HERE #########################

REP_Fn_5_1_AUDIT_USER(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/5_1_AUDIT_USER.sql

checker=`cat ${REPSQLDIR}/sql_5_1_AUDIT_USER.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_5_1_AUDIT_USER.log  >> ${FINALDIR}/5_1_AUDIT_USER.log


if [ ${checker} == 0 ];
        then
        echo ""  >>  ${FINALDIR}/5_1_AUDIT_USER.log
         echo " 5.1 Enable USER Audit Option  - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 5.1 Enable USER Audit Option  - AS PER CIS STANDARDS " >>  ${FINALDIR}/5_1_AUDIT_USER.log
        else
        echo ""  >>  ${FINALDIR}/5_1_AUDIT_USER.log

        echo " 5.1 Enable USER Audit Option - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
            echo " 5.1 Enable USER Audit Option  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/5_1_AUDIT_USER.log
        fi


echo "" >> ${FINALDIR}/5_1_AUDIT_USER.log


echo ""



echo ""

echo "*************************** End of this module 5.1 check ***************************" >> ${FINALDIR}/5_1_AUDIT_USER.log

echo "*********************************************************************************" >> ${FINALDIR}/5_1_AUDIT_USER.log

}

REP_Fn_5_2_AUDIT_ALETR_USER(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/5_2_AUDIT_ALETR_USER.sql

checker=`cat ${REPSQLDIR}/sql_5_2_AUDIT_ALETR_USER.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_5_2_AUDIT_ALETR_USER.log  >> ${FINALDIR}/5_2_AUDIT_ALETR_USER.log


if [ ${checker} == 0 ];
        then
        echo ""  >>  ${FINALDIR}/5_2_AUDIT_ALETR_USER.log
         echo " 5.2 Enable ALTER USER Audit Option  - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 5.2 Enable ALTER USER Audit Option  - AS PER CIS STANDARDS " >>  ${FINALDIR}/5_2_AUDIT_ALETR_USER.log
        else
        echo ""  >>  ${FINALDIR}/5_2_AUDIT_ALETR_USER.log

        echo " 5.2 Enable ALTER USER Audit Option - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
            echo " 5.2 Enable ALTER USER Audit Option  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/5_2_AUDIT_ALETR_USER.log
        fi


echo "" >> ${FINALDIR}/5_2_AUDIT_ALETR_USER.log


echo ""



echo ""

echo "*************************** End of this module 5.2 check ***************************" >> ${FINALDIR}/5_2_AUDIT_ALETR_USER.log

echo "*********************************************************************************" >> ${FINALDIR}/5_2_AUDIT_ALETR_USER.log

}

REP_Fn_5_3_AUDIT_DROP_USER(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/5_3_AUDIT_DROP_USER.sql

checker=`cat ${REPSQLDIR}/sql_5_3_AUDIT_DROP_USER.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_5_3_AUDIT_DROP_USER.log  >> ${FINALDIR}/5_3_AUDIT_DROP_USER.log


if [ ${checker} == 0 ];
        then
        echo ""  >>  ${FINALDIR}/5_3_AUDIT_DROP_USER.log
         echo " 5.3 Enable DROP USER Audit Option  - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 5.3 Enable DROP USER Audit Option  - AS PER CIS STANDARDS " >>  ${FINALDIR}/5_3_AUDIT_DROP_USER.log
        else
        echo ""  >>  ${FINALDIR}/5_3_AUDIT_DROP_USER.log

        echo " 5.3 Enable DROP USER Audit Option - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
            echo " 5.3 Enable DROP USER Audit Option  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/5_3_AUDIT_DROP_USER.log
        fi


echo "" >> ${FINALDIR}/5_3_AUDIT_DROP_USER.log


echo ""



echo ""

echo "*************************** End of this module 5.3 check ***************************" >> ${FINALDIR}/5_3_AUDIT_DROP_USER.log

echo "*********************************************************************************" >> ${FINALDIR}/5_3_AUDIT_DROP_USER.log

}

REP_Fn_5_4_AUDIT_ROLE(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/5_4_AUDIT_ROLE.sql

checker=`cat ${REPSQLDIR}/sql_5_4_AUDIT_ROLE.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_5_4_AUDIT_ROLE.log  >> ${FINALDIR}/5_4_AUDIT_ROLE.log


if [ ${checker} == 0 ];
        then
        echo ""  >>  ${FINALDIR}/5_4_AUDIT_ROLE.log
         echo " 5.4 Enable ROLE Audit Option  - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 5.4 Enable ROLE Audit Option  - AS PER CIS STANDARDS " >>  ${FINALDIR}/5_4_AUDIT_ROLE.log
        else
        echo ""  >>  ${FINALDIR}/5_4_AUDIT_ROLE.log

        echo " 5.4 Enable ROLE Audit Option - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
            echo " 5.4 Enable ROLE Audit Option  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/5_4_AUDIT_ROLE.log
        fi


echo "" >> ${FINALDIR}/5_4_AUDIT_ROLE.log


echo ""



echo ""

echo "*************************** End of this module 5.4 check ***************************" >> ${FINALDIR}/5_4_AUDIT_ROLE.log

echo "*********************************************************************************" >> ${FINALDIR}/5_4_AUDIT_ROLE.log

}

REP_Fn_5_5_AUDIT_SYSTEM_GRANT(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/5_5_AUDIT_SYSTEM_GRANT.sql

checker=`cat ${REPSQLDIR}/sql_5_5_AUDIT_SYSTEM_GRANT.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_5_5_AUDIT_SYSTEM_GRANT.log  >> ${FINALDIR}/5_5_AUDIT_SYSTEM_GRANT.log


if [ ${checker} == 0 ];
        then
        echo ""  >>  ${FINALDIR}/5_5_AUDIT_SYSTEM_GRANT.log
         echo " 5.5 Enable SYSTEM GRANT Audit Option  - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 5.5 Enable SYSTEM GRANT Audit Option  - AS PER CIS STANDARDS " >>  ${FINALDIR}/5_5_AUDIT_SYSTEM_GRANT.log
        else
        echo ""  >>  ${FINALDIR}/5_5_AUDIT_SYSTEM_GRANT.log

        echo " 5.5 Enable SYSTEM GRANT Audit Option - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
            echo " 5.5 Enable SYSTEM GRANT Audit Option  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/5_5_AUDIT_SYSTEM_GRANT.log
        fi


echo "" >> ${FINALDIR}/5_5_AUDIT_SYSTEM_GRANT.log


echo ""



echo ""

echo "*************************** End of this module 5.5 check ***************************" >> ${FINALDIR}/5_5_AUDIT_SYSTEM_GRANT.log

echo "*********************************************************************************" >> ${FINALDIR}/5_5_AUDIT_SYSTEM_GRANT.log

}

REP_Fn_5_6_AUDIT_PROFILE(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/5_6_AUDIT_PROFILE.sql

checker=`cat ${REPSQLDIR}/sql_5_6_AUDIT_PROFILE.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_5_6_AUDIT_PROFILE.log  >> ${FINALDIR}/5_6_AUDIT_PROFILE.log


if [ ${checker} == 0 ];
        then
        echo ""  >>  ${FINALDIR}/5_6_AUDIT_PROFILE.log
         echo " 5.6 Enable PROFILE Audit Option  - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 5.6 Enable PROFILE Audit Option  - AS PER CIS STANDARDS " >>  ${FINALDIR}/5_6_AUDIT_PROFILE.log
        else
        echo ""  >>  ${FINALDIR}/5_6_AUDIT_PROFILE.log

        echo " 5.6 Enable PROFILE Audit Option - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
            echo " 5.6 Enable PROFILE Audit Option  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/5_6_AUDIT_PROFILE.log
        fi


echo "" >> ${FINALDIR}/5_6_AUDIT_PROFILE.log


echo ""



echo ""

echo "*************************** End of this module 5.6 check ***************************" >> ${FINALDIR}/5_6_AUDIT_PROFILE.log

echo "*********************************************************************************" >> ${FINALDIR}/5_6_AUDIT_PROFILE.log

}

REP_Fn_5_7_AUDIT_ALETR_PROFILE(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/5_7_AUDIT_ALETR_PROFILE.sql

checker=`cat ${REPSQLDIR}/sql_5_7_AUDIT_ALETR_PROFILE.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_5_7_AUDIT_ALETR_PROFILE.log  >> ${FINALDIR}/5_7_AUDIT_ALETR_PROFILE.log


if [ ${checker} == 0 ];
        then
        echo ""  >>  ${FINALDIR}/5_7_AUDIT_ALETR_PROFILE.log
         echo " 5.7 Enable ALTER PROFILE Audit Option  - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 5.7 Enable ALTER PROFILE Audit Option  - AS PER CIS STANDARDS " >>  ${FINALDIR}/5_7_AUDIT_ALETR_PROFILE.log
        else
        echo ""  >>  ${FINALDIR}/5_7_AUDIT_ALETR_PROFILE.log

        echo " 5.7 Enable ALTER PROFILE Audit Option - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
            echo " 5.7 Enable ALTER PROFILE Audit Option  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/5_7_AUDIT_ALETR_PROFILE.log
        fi


echo "" >> ${FINALDIR}/5_7_AUDIT_ALETR_PROFILE.log


echo ""



echo ""

echo "*************************** End of this module 5.7 check ***************************" >> ${FINALDIR}/5_7_AUDIT_ALETR_PROFILE.log

echo "*********************************************************************************" >> ${FINALDIR}/5_7_AUDIT_ALETR_PROFILE.log

}

REP_Fn_5_8_AUDIT_DROP_PROFILE(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/5_8_AUDIT_DROP_PROFILE.sql

checker=`cat ${REPSQLDIR}/sql_5_8_AUDIT_DROP_PROFILE.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_5_8_AUDIT_DROP_PROFILE.log  >> ${FINALDIR}/5_8_AUDIT_DROP_PROFILE.log


if [ ${checker} == 0 ];
        then
        echo ""  >>  ${FINALDIR}/5_8_AUDIT_DROP_PROFILE.log
         echo " 5.8 Enable DROP PROFILE Audit Option  - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 5.8 Enable DROP PROFILE Audit Option  - AS PER CIS STANDARDS " >>  ${FINALDIR}/5_8_AUDIT_DROP_PROFILE.log
        else
        echo ""  >>  ${FINALDIR}/5_8_AUDIT_DROP_PROFILE.log

        echo " 5.8 Enable DROP PROFILE Audit Option - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
            echo " 5.8 Enable DROP PROFILE Audit Option  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/5_8_AUDIT_DROP_PROFILE.log
        fi


echo "" >> ${FINALDIR}/5_8_AUDIT_DROP_PROFILE.log


echo ""



echo ""

echo "*************************** End of this module 5.8 check ***************************" >> ${FINALDIR}/5_8_AUDIT_DROP_PROFILE.log

echo "*********************************************************************************" >> ${FINALDIR}/5_8_AUDIT_DROP_PROFILE.log

}

REP_Fn_5_9_AUDIT_DATABASE_LINK(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/5_9_AUDIT_DATABASE_LINK.sql

checker=`cat ${REPSQLDIR}/sql_5_9_AUDIT_DATABASE_LINK.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_5_9_AUDIT_DATABASE_LINK.log  >> ${FINALDIR}/5_9_AUDIT_DATABASE_LINK.log


if [ ${checker} == 0 ];
        then
        echo ""  >>  ${FINALDIR}/5_9_AUDIT_DATABASE_LINK.log
         echo " 5.9 Enable DATABASE LINK Audit Option  - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 5.9 Enable DATABASE LINK Audit Option  - AS PER CIS STANDARDS " >>  ${FINALDIR}/5_9_AUDIT_DATABASE_LINK.log
        else
        echo ""  >>  ${FINALDIR}/5_9_AUDIT_DATABASE_LINK.log

        echo " 5.9 Enable DATABASE LINK Audit Option - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
            echo " 5.9 Enable DATABASE LINK Audit Option  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/5_9_AUDIT_DATABASE_LINK.log
        fi


echo "" >> ${FINALDIR}/5_9_AUDIT_DATABASE_LINK.log


echo ""



echo ""

echo "*************************** End of this module 5.9 check ***************************" >> ${FINALDIR}/5_9_AUDIT_DATABASE_LINK.log

echo "*********************************************************************************" >> ${FINALDIR}/5_9_AUDIT_DATABASE_LINK.log

}

REP_Fn_5_10_AUDIT_PUBLIC_DATABASE_LINK(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/5_10_AUDIT_PUBLIC_DATABASE_LINK.sql

checker=`cat ${REPSQLDIR}/sql_5_10_AUDIT_PUBLIC_DATABASE_LINK.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_5_10_AUDIT_PUBLIC_DATABASE_LINK.log  >> ${FINALDIR}/5_10_AUDIT_PUBLIC_DATABASE_LINK.log


if [ ${checker} == 0 ];
        then
        echo ""  >>  ${FINALDIR}/5_10_AUDIT_PUBLIC_DATABASE_LINK.log
         echo " 5.10 Enable PUBLIC DATABASE LINK Audit Option  - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 5.10 Enable PUBLIC DATABASE LINK Audit Option  - AS PER CIS STANDARDS " >>  ${FINALDIR}/5_10_AUDIT_PUBLIC_DATABASE_LINK.log
        else
        echo ""  >>  ${FINALDIR}/5_10_AUDIT_PUBLIC_DATABASE_LINK.log

        echo " 5.10 Enable PUBLIC DATABASE LINK Audit Option - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
            echo " 5.10 Enable PUBLIC DATABASE LINK Audit Option  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/5_10_AUDIT_PUBLIC_DATABASE_LINK.log
        fi


echo "" >> ${FINALDIR}/5_10_AUDIT_PUBLIC_DATABASE_LINK.log


echo ""



echo ""

echo "*************************** End of this module 5.10 check ***************************" >> ${FINALDIR}/5_10_AUDIT_PUBLIC_DATABASE_LINK.log

echo "*********************************************************************************" >> ${FINALDIR}/5_10_AUDIT_PUBLIC_DATABASE_LINK.log

}

REP_Fn_5_11_AUDIT_PUBLIC_SYNONYM(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/5_11_AUDIT_PUBLIC_SYNONYM.sql

checker=`cat ${REPSQLDIR}/sql_5_11_AUDIT_PUBLIC_SYNONYM.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_5_11_AUDIT_PUBLIC_SYNONYM.log  >> ${FINALDIR}/5_11_AUDIT_PUBLIC_SYNONYM.log


if [ ${checker} == 0 ];
        then
        echo ""  >>  ${FINALDIR}/5_11_AUDIT_PUBLIC_SYNONYM.log
         echo " 5.11 Enable PUBLIC SYNONYM Audit Option  - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 5.11 Enable PUBLIC SYNONYM Audit Option  - AS PER CIS STANDARDS " >>  ${FINALDIR}/5_11_AUDIT_PUBLIC_SYNONYM.log
        else
        echo ""  >>  ${FINALDIR}/5_11_AUDIT_PUBLIC_SYNONYM.log

        echo " 5.11 Enable PUBLIC SYNONYM Audit Option - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
            echo " 5.11 Enable PUBLIC SYNONYM Audit Option  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/5_11_AUDIT_PUBLIC_SYNONYM.log
        fi


echo "" >> ${FINALDIR}/5_11_AUDIT_PUBLIC_SYNONYM.log


echo ""



echo ""

echo "*************************** End of this module 5.11 check ***************************" >> ${FINALDIR}/5_11_AUDIT_PUBLIC_SYNONYM.log

echo "*********************************************************************************" >> ${FINALDIR}/5_11_AUDIT_PUBLIC_SYNONYM.log

}

REP_Fn_5_12_AUDIT_SYNONYM(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/5_12_AUDIT_SYNONYM.sql

checker=`cat ${REPSQLDIR}/sql_5_12_AUDIT_SYNONYM.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_5_12_AUDIT_SYNONYM.log  >> ${FINALDIR}/5_12_AUDIT_SYNONYM.log


if [ ${checker} == 0 ];
        then
        echo ""  >>  ${FINALDIR}/5_12_AUDIT_SYNONYM.log
         echo " 5.12 Enable SYNONYM Audit Option  - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 5.12 Enable SYNONYM Audit Option  - AS PER CIS STANDARDS " >>  ${FINALDIR}/5_12_AUDIT_SYNONYM.log
        else
        echo ""  >>  ${FINALDIR}/5_12_AUDIT_SYNONYM.log

        echo " 5.12 Enable SYNONYM Audit Option - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
            echo " 5.12 Enable SYNONYM Audit Option  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/5_12_AUDIT_SYNONYM.log
        fi


echo "" >> ${FINALDIR}/5_12_AUDIT_SYNONYM.log


echo ""



echo ""

echo "*************************** End of this module 5.12 check ***************************" >> ${FINALDIR}/5_12_AUDIT_SYNONYM.log

echo "*********************************************************************************" >> ${FINALDIR}/5_12_AUDIT_SYNONYM.log

}

REP_Fn_5_13_AUDIT_GRANT_DIRECTORY(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/5_13_AUDIT_GRANT_DIRECTORY.sql

checker=`cat ${REPSQLDIR}/sql_5_13_AUDIT_GRANT_DIRECTORY.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_5_13_AUDIT_GRANT_DIRECTORY.log  >> ${FINALDIR}/5_13_AUDIT_GRANT_DIRECTORY.log


if [ ${checker} == 0 ];
        then
        echo ""  >>  ${FINALDIR}/5_13_AUDIT_GRANT_DIRECTORY.log
         echo " 5.13 Enable GRANT DIRECTORY Audit Option  - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 5.13 Enable GRANT DIRECTORY Audit Option  - AS PER CIS STANDARDS " >>  ${FINALDIR}/5_13_AUDIT_GRANT_DIRECTORY.log
        else
        echo ""  >>  ${FINALDIR}/5_13_AUDIT_GRANT_DIRECTORY.log

        echo " 5.13 Enable GRANT DIRECTORY Audit Option - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
            echo " 5.13 Enable GRANT DIRECTORY Audit Option  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/5_13_AUDIT_GRANT_DIRECTORY.log
        fi


echo "" >> ${FINALDIR}/5_13_AUDIT_GRANT_DIRECTORY.log


echo ""



echo ""

echo "*************************** End of this module 5.13 check ***************************" >> ${FINALDIR}/5_13_AUDIT_GRANT_DIRECTORY.log

echo "*********************************************************************************" >> ${FINALDIR}/5_13_AUDIT_GRANT_DIRECTORY.log

}

REP_Fn_5_14_AUDIT_SELECT_ANY_DICTIONARY(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/5_14_AUDIT_SELECT_ANY_DICTIONARY.sql

checker=`cat ${REPSQLDIR}/sql_5_14_AUDIT_SELECT_ANY_DICTIONARY.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_5_14_AUDIT_SELECT_ANY_DICTIONARY.log  >> ${FINALDIR}/5_14_AUDIT_SELECT_ANY_DICTIONARY.log


if [ ${checker} == 0 ];
        then
        echo ""  >>  ${FINALDIR}/5_14_AUDIT_SELECT_ANY_DICTIONARY.log
         echo " 5.14 Enable SELECT ANY DICTIONARY Audit Option  - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 5.14 Enable SELECT ANY DICTIONARY Audit Option  - AS PER CIS STANDARDS " >>  ${FINALDIR}/5_14_AUDIT_SELECT_ANY_DICTIONARY.log
        else
        echo ""  >>  ${FINALDIR}/5_14_AUDIT_SELECT_ANY_DICTIONARY.log

        echo " 5.14 Enable SELECT ANY DICTIONARY Audit Option - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
            echo " 5.14 Enable SELECT ANY DICTIONARY Audit Option  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/5_14_AUDIT_SELECT_ANY_DICTIONARY.log
        fi


echo "" >> ${FINALDIR}/5_14_AUDIT_SELECT_ANY_DICTIONARY.log


echo ""



echo ""

echo "*************************** End of this module 5.14 check ***************************" >> ${FINALDIR}/5_14_AUDIT_SELECT_ANY_DICTIONARY.log

echo "*********************************************************************************" >> ${FINALDIR}/5_14_AUDIT_SELECT_ANY_DICTIONARY.log

}

REP_Fn_5_15_AUDIT_GRANT_ANY_OBJ_PRIV(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/5_15_AUDIT_GRANT_ANY_OBJ_PRIV.sql

checker=`cat ${REPSQLDIR}/sql_5_15_AUDIT_GRANT_ANY_OBJ_PRIV.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_5_15_AUDIT_GRANT_ANY_OBJ_PRIV.log  >> ${FINALDIR}/5_15_AUDIT_GRANT_ANY_OBJ_PRIV.log


if [ ${checker} == 0 ];
        then
        echo ""  >>  ${FINALDIR}/5_15_AUDIT_GRANT_ANY_OBJ_PRIV.log
         echo " 5.15 Enable GRANT ANY OBJECT PRIVILEGE Audit Option  - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 5.15 Enable GRANT ANY OBJECT PRIVILEGE Audit Option  - AS PER CIS STANDARDS " >>  ${FINALDIR}/5_15_AUDIT_GRANT_ANY_OBJ_PRIV.log
        else
        echo ""  >>  ${FINALDIR}/5_15_AUDIT_GRANT_ANY_OBJ_PRIV.log

        echo " 5.15 Enable GRANT ANY OBJECT PRIVILEGE Audit Option - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
            echo " 5.15 Enable GRANT ANY OBJECT PRIVILEGE Audit Option  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/5_15_AUDIT_GRANT_ANY_OBJ_PRIV.log
        fi


echo "" >> ${FINALDIR}/5_15_AUDIT_GRANT_ANY_OBJ_PRIV.log


echo ""



echo ""

echo "*************************** End of this module 5.15 check ***************************" >> ${FINALDIR}/5_15_AUDIT_GRANT_ANY_OBJ_PRIV.log

echo "*********************************************************************************" >> ${FINALDIR}/5_15_AUDIT_GRANT_ANY_OBJ_PRIV.log

}

REP_Fn_5_16_AUDIT_GRANT_ANY_PRIV(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/5_16_AUDIT_GRANT_ANY_PRIV.sql

checker=`cat ${REPSQLDIR}/sql_5_15_AUDIT_GRANT_ANY_OBJ_PRIV.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_5_15_AUDIT_GRANT_ANY_OBJ_PRIV.log  >> ${FINALDIR}/5_16_AUDIT_GRANT_ANY_PRIV.log


if [ ${checker} == 0 ];
        then
        echo ""  >>  ${FINALDIR}/5_16_AUDIT_GRANT_ANY_PRIV.log
         echo " 5.16 Enable GRANT ANY PRIVILEGE Audit Option  - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 5.16 Enable GRANT ANY PRIVILEGE Audit Option  - AS PER CIS STANDARDS " >>  ${FINALDIR}/5_16_AUDIT_GRANT_ANY_PRIV.log
        else
        echo ""  >>  ${FINALDIR}/5_16_AUDIT_GRANT_ANY_PRIV.log

        echo " 5.16 Enable GRANT ANY PRIVILEGE Audit Option - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
            echo " 5.16 Enable GRANT ANY PRIVILEGE Audit Option  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/5_16_AUDIT_GRANT_ANY_PRIV.log
        fi


echo "" >> ${FINALDIR}/5_16_AUDIT_GRANT_ANY_PRIV.log


echo ""



echo ""

echo "*************************** End of this module 5.16 check ***************************" >> ${FINALDIR}/5_16_AUDIT_GRANT_ANY_PRIV.log

echo "*********************************************************************************" >> ${FINALDIR}/5_16_AUDIT_GRANT_ANY_PRIV.log

}

REP_Fn_5_17_AUDIT_DROP_ANY_PROC(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/5_17_AUDIT_DROP_ANY_PROC.sql

checker=`cat ${REPSQLDIR}/sql_5_17_AUDIT_DROP_ANY_PROC.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_5_17_AUDIT_DROP_ANY_PROC.log  >> ${FINALDIR}/5_17_AUDIT_DROP_ANY_PROC.log


if [ ${checker} == 0 ];
        then
        echo ""  >>  ${FINALDIR}/5_17_AUDIT_DROP_ANY_PROC.log
         echo " 5.17 Enable DROP ANY PROCEDURE Audit Option  - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 5.17 Enable DROP ANY PROCEDURE Audit Option  - AS PER CIS STANDARDS " >>  ${FINALDIR}/5_17_AUDIT_DROP_ANY_PROC.log
        else
        echo ""  >>  ${FINALDIR}/5_17_AUDIT_DROP_ANY_PROC.log

        echo " 5.17 Enable DROP ANY PROCEDURE Audit Option - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
            echo " 5.17 Enable DROP ANY PROCEDURE Audit Option  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/5_17_AUDIT_DROP_ANY_PROC.log
        fi


echo "" >> ${FINALDIR}/5_17_AUDIT_DROP_ANY_PROC.log


echo ""



echo ""

echo "*************************** End of this module 5.17 check ***************************" >> ${FINALDIR}/5_17_AUDIT_DROP_ANY_PROC.log

echo "*********************************************************************************" >> ${FINALDIR}/5_17_AUDIT_DROP_ANY_PROC.log

}

REP_Fn_5_18_AUDIT_ALL_SYS_AUD(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/5_18_AUDIT_ALL_SYS_AUD.sql

checker=`cat ${REPSQLDIR}/sql_5_18_AUDIT_ALL_SYS_AUD.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_5_18_AUDIT_ALL_SYS_AUD.log  >> ${FINALDIR}/5_18_AUDIT_ALL_SYS_AUD.log


if [ ${checker} == 0 ];
        then
        echo ""  >>  ${FINALDIR}/5_18_AUDIT_ALL_SYS_AUD.log
         echo " 5.18 Enable ALL Audit Option on SYS.AUD$  - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 5.18 Enable ALL Audit Option on SYS.AUD$  - AS PER CIS STANDARDS " >>  ${FINALDIR}/5_18_AUDIT_ALL_SYS_AUD.log
        else
        echo ""  >>  ${FINALDIR}/5_18_AUDIT_ALL_SYS_AUD.log

        echo " 5.18 Enable ALL Audit Option on SYS.AUD$ - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
            echo " 5.18 Enable ALL Audit Option on SYS.AUD$  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/5_18_AUDIT_ALL_SYS_AUD.log
        fi


echo "" >> ${FINALDIR}/5_18_AUDIT_ALL_SYS_AUD.log


echo ""



echo ""

echo "*************************** End of this module 5.18 check ***************************" >> ${FINALDIR}/5_18_AUDIT_ALL_SYS_AUD.log

echo "*********************************************************************************" >> ${FINALDIR}/5_18_AUDIT_ALL_SYS_AUD.log

}

REP_Fn_5_19_AUDIT_PROCEDURE(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/5_19_AUDIT_PROCEDURE.sql

checker=`cat ${REPSQLDIR}/sql_5_19_AUDIT_PROCEDURE.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_5_19_AUDIT_PROCEDURE.log  >> ${FINALDIR}/5_19_AUDIT_PROCEDURE.log


if [ ${checker} == 0 ];
        then
        echo ""  >>  ${FINALDIR}/5_19_AUDIT_PROCEDURE.log
         echo " 5.19 Enable PROCEDURE Audit Option  - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 5.19 Enable PROCEDURE Audit Option  - AS PER CIS STANDARDS " >>  ${FINALDIR}/5_19_AUDIT_PROCEDURE.log
        else
        echo ""  >>  ${FINALDIR}/5_19_AUDIT_PROCEDURE.log

        echo " 5.19 Enable PROCEDURE Audit Option - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
            echo " 5.19 Enable PROCEDURE Audit Option  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/5_19_AUDIT_PROCEDURE.log
        fi


echo "" >> ${FINALDIR}/5_19_AUDIT_PROCEDURE.log


echo ""



echo ""

echo "*************************** End of this module 5.19 check ***************************" >> ${FINALDIR}/5_19_AUDIT_PROCEDURE.log

echo "*********************************************************************************" >> ${FINALDIR}/5_19_AUDIT_PROCEDURE.log

}

REP_Fn_5_20_AUDIT_ALETR_SYSTEM(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/5_20_AUDIT_ALETR_SYSTEM.sql

checker=`cat ${REPSQLDIR}/sql_5_20_AUDIT_ALETR_SYSTEM.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_5_20_AUDIT_ALETR_SYSTEM.log  >> ${FINALDIR}/5_20_AUDIT_ALETR_SYSTEM.log


if [ ${checker} == 0 ];
        then
        echo ""  >>  ${FINALDIR}/5_20_AUDIT_ALETR_SYSTEM.log
         echo " 5.20 Enable ALTER SYSTEM Audit Option  - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 5.20 Enable ALTER SYSTEM Audit Option  - AS PER CIS STANDARDS " >>  ${FINALDIR}/5_20_AUDIT_ALETR_SYSTEM.log
        else
        echo ""  >>  ${FINALDIR}/5_20_AUDIT_ALETR_SYSTEM.log

        echo " 5.20 Enable ALTER SYSTEM Audit Option - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
            echo " 5.20 Enable ALTER SYSTEM Audit Option  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/5_20_AUDIT_ALETR_SYSTEM.log
        fi


echo "" >> ${FINALDIR}/5_20_AUDIT_ALETR_SYSTEM.log


echo ""



echo ""

echo "*************************** End of this module 5.20 check ***************************" >> ${FINALDIR}/5_20_AUDIT_ALETR_SYSTEM.log

echo "*********************************************************************************" >> ${FINALDIR}/5_20_AUDIT_ALETR_SYSTEM.log

}

REP_Fn_5_21_AUDIT_TRIGGER(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/5_21_AUDIT_TRIGGER.sql

checker=`cat ${REPSQLDIR}/sql_5_21_AUDIT_TRIGGER.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_5_21_AUDIT_TRIGGER.log  >> ${FINALDIR}/5_21_AUDIT_TRIGGER.log


if [ ${checker} == 0 ];
        then
        echo ""  >>  ${FINALDIR}/5_21_AUDIT_TRIGGER.log
         echo " 5.21 Enable TRIGGER Audit Option  - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 5.21 Enable TRIGGER Audit Option  - AS PER CIS STANDARDS " >>  ${FINALDIR}/5_21_AUDIT_TRIGGER.log
        else
        echo ""  >>  ${FINALDIR}/5_21_AUDIT_TRIGGER.log

        echo " 5.21 Enable TRIGGER Audit Option - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
            echo " 5.21 Enable TRIGGER Audit Option  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/5_21_AUDIT_TRIGGER.log
        fi


echo "" >> ${FINALDIR}/5_21_AUDIT_TRIGGER.log


echo ""



echo ""

echo "*************************** End of this module 5.21 check ***************************" >> ${FINALDIR}/5_21_AUDIT_TRIGGER.log

echo "*********************************************************************************" >> ${FINALDIR}/5_21_AUDIT_TRIGGER.log

}

REP_Fn_5_22_AUDIT_CREATE_SESSION(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/5_22_AUDIT_CREATE_SESSION.sql

checker=`cat ${REPSQLDIR}/sql_5_22_AUDIT_CREATE_SESSION.log | grep -i "no rows selected" | wc -l`

cat ${REPSQLDIR}/sql_5_22_AUDIT_CREATE_SESSION.log  >> ${FINALDIR}/5_22_AUDIT_CREATE_SESSION.log


if [ ${checker} == 0 ];
        then
        echo ""  >>  ${FINALDIR}/5_22_AUDIT_CREATE_SESSION.log
         echo " 5.22 Enable CREATE SESSION Audit Option  - AS PER CIS STANDARDS " >>  ${FINALDIR}/CIS_Success.log
            echo " 5.22 Enable CREATE SESSION Audit Option  - AS PER CIS STANDARDS " >>  ${FINALDIR}/5_22_AUDIT_CREATE_SESSION.log
        else
        echo ""  >>  ${FINALDIR}/5_22_AUDIT_CREATE_SESSION.log

        echo " 5.22 Enable CREATE SESSION Audit Option - NOT AS PER CIS STANDARDS  - Need Attention" >>  ${FINALDIR}/CIS_Failure.log
            echo " 5.22 Enable CREATE SESSION Audit Option  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/5_22_AUDIT_CREATE_SESSION.log
        fi


echo "" >> ${FINALDIR}/5_22_AUDIT_CREATE_SESSION.log


echo ""



echo ""

echo "*************************** End of this module 5.22 check ***************************" >> ${FINALDIR}/5_22_AUDIT_CREATE_SESSION.log

echo "*********************************************************************************" >> ${FINALDIR}/5_22_AUDIT_CREATE_SESSION.log

}

######################### SECTION 5 ENDS HERE #########################

consolidation() {

printf "********************************************************************"
echo  ""
echo "Consolidated Success CIS report:  "
cat ${FINALDIR}/CIS_Success.log

echo ""
printf "********************************************************************"
echo ""
echo "Consolidated Failure CIS report:  "

 if [ -f  ${FINALDIR}/CIS_Failure.log ]
        then
        cat ${FINALDIR}/CIS_Failure.log
        else
        echo " No Failures..."
fi

echo ""

printf "***************************************************************************************"


cat ${FINALDIR}/1_patch_artifact.log > ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/1_2_DEF_Pass.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/1_3_DEF_SCHEM_DROP.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/2_1_1_SECURE_LIST.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/2_1_2_EXTPROC_LIST.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/2_1_3_ADMIN_RESTRCT_LIST.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/2_1_4_SECURE_REG.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/2_2_1_AUDSYS.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/2_2_2_AUDTRAIL.log  >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/2_2_3_GLOB_NAM.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/2_2_4_LOC_LIS.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/2_2_6_OS_ROLE.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/2_2_7_DICTIONARY_ACCESSIBILITY.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/2_2_8_Rem_Login_Pwdfile.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/2_2_9_REM_OS.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/2_2_10_REM_OS_ROLES.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/2_2_12_SEC_CASE_SENSITIVE_LOGON.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/2_2_13_SEC_MAX_FAILED_LOGIN.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/2_2_14_SEC_ERROR_FURTHER_ACTION.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/2_2_15_SEC_ERROR_TRACE_ACTION.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/2_2_16_SEC_RETURN_SERVER_BANNER.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/2_2_17_SQL92_SECURITY.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/2_2_18_TRACE_FILES_PUBLIC.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/2_2_19_RESOURCE_LIMIT.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/3_1_PROFILE_FAILED_LOGIN.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/3_2_PROFILE_PASSWORD_LOCK.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/3_3_PROFILE_PASSWORD_LIFE.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/3_4_PROFILE_PASSWORD_REUSE.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/3_5_PROFILE_PASSWORD_REUSE_TIME.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/3_6_PROFILE_PASSWORD_GRACE_TIME.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/3_7_DBA_USERS_PASSWORD.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/3_8_PROFILE_PASSWORD_VERIFY.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/3_9_PROFILE_SESSIONS_PER_USER.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/3_10_USERS_WITH_DEFAULT_PROFILE.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/4_1_1_PRIVILEGE_PACKAGES_OBJECTS.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/4_1_2_DBMS_CRYPTO.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/4_1_3_DBMS_JAVA.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/4_1_4_DBMS_JAVA_TEST.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/4_1_5_DBMS_JOB.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/4_1_6_DBMS_LDAP.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/4_1_7_DBMS_LOB.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/4_1_8_DBMS_OBFUSCATION_TOOLKIT.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/4_1_9_DBMS_BACKUP_RESTORE.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/4_1_10_DBMS_SCHEDULER.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/4_1_11_DBMS_SQL.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/4_1_12_DBMS_XMLGEN.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/4_1_13_DBMS_XMLQUERY.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/4_1_14_UTL_FILE.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/4_1_15_UTL_INADDR.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/4_1_16_UTL_TCP.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/4_1_17_UTL_MAIL.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/4_1_18_UTL_SMTP.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/4_1_19_UTL_DBWS.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/4_1_20_UTL_ORAMTS.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/4_1_21_UTL_HTTP.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/4_1_22_HTTPURITYPE.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/4_2_1_DBMS_SYS_SQL.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/4_2_2_DBMS_BACKUP_RESTORE.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/4_2_3_DBMS_AQADM_SYSCALLS.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/4_2_4_DBMS_REPACT_SQL_UTL.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/4_2_5_INITJVMAUX.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/4_2_6_DBMS_STREAMS_ADM_UTL.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/4_2_7_DBMS_AQADM_SYS.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/4_2_8_DBMS_STREAMS_RPC.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/4_2_9_DBMS_PRVTAQIM.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/4_2_10_LTADM.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/4_2_11_WWV_DBMS_SQL.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/4_2_12_WWV_EXECUTE_IMMEDIATE.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/4_2_13_DBMS_IJOB.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/4_2_14_DBMS_FILE_TRANSFER.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/4_3_1_SELECT_ANY_DICTIONARY.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/4_3_2_SELECT_ANY_TABLE.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/4_3_3_AUDIT_SYSTEM.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/4_3_4_EXEMPT_ACCESS_POLICY.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/4_3_5_BECOME_USER.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/4_3_6_CREATE_PROCEDURE.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/4_3_7_ALTER_SYSTEM.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/4_3_8_CREATE_ANY_LIBRARY.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/4_3_9_CREATE_LIBRARY.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/4_3_10_GRANT_ANY_OBJECT_PRIV.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/4_3_11_GRANT_ANY_ROLE.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/4_3_12_GRANT_ANY_PRIV.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/4_4_1_DELETE_CATALOG_ROLE.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/4_4_2_SELECT_CATALOG_ROLE.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/4_4_3_EXECUTE_CATALOG_ROLE.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/4_4_4_REVOKE_DBA.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/4_5_1_REV_ALL_AUD.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/4_5_2_REV_ALL_USER_HISTORY.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/4_5_3_REV_ALL_LINK.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/4_5_4_REV_ALL_SYS_USER.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/4_5_5_REV_ALL_DBA.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/4_5_6_REV_ALL_SYS_SCHEDULER_CREDENTIAL.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/4_5_7_DROP_SYS_USER_MIG.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/4_6_REV_ANY.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/4_7_REV_DBA_SYS_PRIVS.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/4_8_PROXY_USER_PRIV.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/4_9_REV_EXE_ANY_PROC_OUTLN.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/4_10_REV_EXE_ANY_PROC_DBSNMP.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/5_1_AUDIT_USER.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/5_2_AUDIT_ALETR_USER.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/5_3_AUDIT_DROP_USER.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/5_4_AUDIT_ROLE.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/5_5_AUDIT_SYSTEM_GRANT.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/5_6_AUDIT_PROFILE.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/5_7_AUDIT_ALETR_PROFILE.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/5_8_AUDIT_DROP_PROFILE.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/5_9_AUDIT_DATABASE_LINK.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/5_10_AUDIT_PUBLIC_DATABASE_LINK.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/5_11_AUDIT_PUBLIC_SYNONYM.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/5_12_AUDIT_SYNONYM.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/5_13_AUDIT_GRANT_DIRECTORY.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/5_14_AUDIT_SELECT_ANY_DICTIONARY.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/5_15_AUDIT_GRANT_ANY_OBJ_PRIV.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/5_16_AUDIT_GRANT_ANY_PRIV.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/5_17_AUDIT_DROP_ANY_PROC.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/5_18_AUDIT_ALL_SYS_AUD.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/5_19_AUDIT_PROCEDURE.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/5_20_AUDIT_ALETR_SYSTEM.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/5_21_AUDIT_TRIGGER.log >> ${FINALDIR}/Final_OP.log
cat ${FINALDIR}/5_22_AUDIT_CREATE_SESSION.log >> ${FINALDIR}/Final_OP.log
echo "*************************** Final Output ***************************"

cat  ${FINALDIR}/Final_OP.log

}

fn_reporting(){

        REP_Fn_1_patch_artifact
        REP_Fn_1_2_DEF_Pass
        REP_Fn_1_3_DEF_SCHEM_DROP
        REP_Fn_2_1_LIST_HARD
        REP_Fn_2_2_1_AUDSYS
        REP_Fn_2_2_2_AUDTRAIL
        REP_Fn_2_2_3_GLOB_NAM
        REP_Fn_2_2_4_LOC_LIS
        REP_Fn_2_2_6_OS_ROLE
        REP_Fn_2_2_7_DICTIONARY_ACCESSIBILITY
        REP_Fn_2_2_8_Rem_Login_Pwdfile
        REP_Fn_2_2_9_REM_OS_AUTH
        REP_Fn_2_2_10_REM_OS_ROLES
        REP_Fn_2_2_12_SEC_CASE_SENSITIVE_LOGON
        REP_Fn_2_2_13_SEC_MAX_FAILED_LOGIN
        REP_Fn_2_2_14_SEC_ERROR_FURTHER_ACTION
        REP_Fn_2_2_15_SEC_ERROR_TRACE_ACTION
        REP_Fn_2_2_16_SEC_RETURN_SERVER_BANNER
        REP_Fn_2_2_17_SQL92_SECURITY
        REP_Fn_2_2_18_TRACE_FILES_PUBLIC
        REP_Fn_2_2_19_RESOURCE_LIMIT
        REP_Fn_3_1_PROFILE_FAILED_LOGIN
        REP_Fn_3_2_PROFILE_PASSWORD_LOCK
        REP_Fn_3_3_PROFILE_PASSWORD_LIFE
        REP_Fn_3_4_PROFILE_PASSWORD_REUSE
        REP_Fn_3_5_PROFILE_PASSWORD_REUSE_TIME
        REP_Fn_3_6_PROFILE_PASSWORD_GRACE_TIME
        REP_Fn_3_7_DBA_USERS_PASSWORD
        REP_Fn_3_8_PROFILE_PASSWORD_VERIFY
        REP_Fn_3_9_PROFILE_SESSIONS_PER_USER
        REP_Fn_3_10_USERS_WITH_DEFAULT_PROFILE
        REP_Fn_4_1_1_PRIVILEGE_PACKAGES_OBJECTS
        REP_Fn_4_1_2_DBMS_CRYPTO
        REP_Fn_4_1_3_DBMS_JAVA
        REP_Fn_4_1_4_DBMS_JAVA_TEST
        REP_Fn_4_1_5_DBMS_JOB
        REP_Fn_4_1_6_DBMS_LDAP
        REP_Fn_4_1_7_DBMS_LOB
        REP_Fn_4_1_8_DBMS_OBFUSCATION_TOOLKIT
        REP_Fn_4_1_9_DBMS_BACKUP_RESTORE
        REP_Fn_4_1_10_DBMS_SCHEDULER
        REP_Fn_4_1_11_DBMS_SQL
        REP_Fn_4_1_12_DBMS_XMLGEN
        REP_Fn_4_1_13_DBMS_XMLQUERY
        REP_Fn_4_1_14_UTL_FILE
        REP_Fn_4_1_15_UTL_INADDR
        REP_Fn_4_1_16_UTL_TCP
        REP_Fn_4_1_17_UTL_MAIL
        REP_Fn_4_1_18_UTL_SMTP
        REP_Fn_4_1_19_UTL_DBWS
        REP_Fn_4_1_20_UTL_ORAMTS
        REP_Fn_4_1_21_UTL_HTTP
        REP_Fn_4_1_22_HTTPURITYPE
        REP_Fn_4_2_1_DBMS_SYS_SQL
        REP_Fn_4_2_2_DBMS_BACKUP_RESTORE
        REP_Fn_4_2_3_DBMS_AQADM_SYSCALLS
        REP_Fn_4_2_4_DBMS_REPACT_SQL_UTL
        REP_Fn_4_2_5_INITJVMAUX
        REP_Fn_4_2_6_DBMS_STREAMS_ADM_UTL
        REP_Fn_4_2_7_DBMS_AQADM_SYS
        REP_Fn_4_2_8_DBMS_STREAMS_RPC
        REP_Fn_4_2_9_DBMS_PRVTAQIM
        REP_Fn_4_2_10_LTADM
        REP_Fn_4_2_11_WWV_DBMS_SQL
        REP_Fn_4_2_12_WWV_EXECUTE_IMMEDIATE
        REP_Fn_4_2_13_DBMS_IJOB
        REP_Fn_4_2_14_DBMS_FILE_TRANSFER
        REP_Fn_4_3_1_SELECT_ANY_DICTIONARY
        REP_Fn_4_3_2_SELECT_ANY_TABLE
        REP_Fn_4_3_3_AUDIT_SYSTEM
        REP_Fn_4_3_4_EXEMPT_ACCESS_POLICY
        REP_Fn_4_3_5_BECOME_USER
        REP_Fn_4_3_6_CREATE_PROCEDURE
        REP_Fn_4_3_7_ALTER_SYSTEM
        REP_Fn_4_3_8_CREATE_ANY_LIBRARY
        REP_Fn_4_3_9_CREATE_LIBRARY
        REP_Fn_4_3_10_GRANT_ANY_OBJECT_PRIV
        REP_Fn_4_3_11_GRANT_ANY_ROLE
        REP_Fn_4_3_12_GRANT_ANY_PRIV
        REP_Fn_4_4_1_DELETE_CATALOG_ROLE
        REP_Fn_4_4_2_SELECT_CATALOG_ROLE
        REP_Fn_4_4_3_EXECUTE_CATALOG_ROLE
        REP_Fn_4_4_4_REVOKE_DBA
        REP_Fn_4_5_1_REV_ALL_AUD
        REP_Fn_4_5_2_REV_ALL_USER_HISTORY
        REP_Fn_4_5_3_REV_ALL_LINK
        REP_Fn_4_5_4_REV_ALL_SYS_USER
        REP_Fn_4_5_5_REV_ALL_DBA
        REP_Fn_4_5_6_REV_ALL_SYS_SCHEDULER_CREDENTIAL
        REP_Fn_4_5_7_DROP_SYS_USER_MIG
        REP_Fn_4_6_REV_ANY
        REP_Fn_4_7_REV_DBA_SYS_PRIVS
        REP_Fn_4_8_PROXY_USER_PRIV
        REP_Fn_4_9_REV_EXE_ANY_PROC_OUTLN
        REP_Fn_4_10_REV_EXE_ANY_PROC_DBSNMP
        REP_Fn_5_1_AUDIT_USER
        REP_Fn_5_2_AUDIT_ALETR_USER
        REP_Fn_5_3_AUDIT_DROP_USER
        REP_Fn_5_4_AUDIT_ROLE
        REP_Fn_5_5_AUDIT_SYSTEM_GRANT
        REP_Fn_5_6_AUDIT_PROFILE
        REP_Fn_5_7_AUDIT_ALETR_PROFILE
        REP_Fn_5_8_AUDIT_DROP_PROFILE
        REP_Fn_5_9_AUDIT_DATABASE_LINK
        REP_Fn_5_10_AUDIT_PUBLIC_DATABASE_LINK
        REP_Fn_5_11_AUDIT_PUBLIC_SYNONYM
        REP_Fn_5_12_AUDIT_SYNONYM
        REP_Fn_5_13_AUDIT_GRANT_DIRECTORY
        REP_Fn_5_14_AUDIT_SELECT_ANY_DICTIONARY
        REP_Fn_5_15_AUDIT_GRANT_ANY_OBJ_PRIV
        REP_Fn_5_16_AUDIT_GRANT_ANY_PRIV
        REP_Fn_5_17_AUDIT_DROP_ANY_PROC
        REP_Fn_5_18_AUDIT_ALL_SYS_AUD
        REP_Fn_5_19_AUDIT_PROCEDURE
        REP_Fn_5_20_AUDIT_ALETR_SYSTEM
        REP_Fn_5_21_AUDIT_TRIGGER
        REP_Fn_5_22_AUDIT_CREATE_SESSION
        consolidation
}

fn_exec_hardening(){

        Exec_Fn_1_HARDEN
        Exec_Fn_REV_HARDEN_4
        Exec_fn_2_1_LIST_HARD

}


fn_exec_hardening
Exec_fn_2_2_4_LOC_LIST
fn_reporting 
