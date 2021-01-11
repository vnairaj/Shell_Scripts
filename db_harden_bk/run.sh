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


REP_Fn_1_patch_artifact()
{
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



REP_Fn_2_2_5_O7_DICT(){

${OHOME}/bin/sqlplus "/ as sysdba" @${REPSQLDIR}/2_2_5_O7_Dict.sql


checker=`cat ${REPSQLDIR}/sql_2_2_5_O7_Dict.log | grep -i "False" | wc -l`

cat ${REPSQLDIR}/sql_2_2_5_O7_Dict.log  >> ${FINALDIR}/2_2_5_O7_DICT.log


if [ ${checker} == 1 ];
        then
        echo ""  >>  ${FINALDIR}/2_2_5_O7_DICT.log
         echo " 2.2.5 Ensure O7_DICTIONARY_ACCESSIBILITY IS SET TO FALSE  - AS PER CIS STANDARDS" >>  ${FINALDIR}/CIS_Success.log
         echo "2.2.5 Ensure O7_DICTIONARY_ACCESSIBILITY IS SET TO FALSE   - AS PER CIS STANDARDS" >>  ${FINALDIR}/2_2_5_O7_DICT.log
        else
        echo ""  >>  ${FINALDIR}/2_2_5_O7_DICT.log

        echo " 2.2.5 Ensure O7_DICTIONARY_ACCESSIBILITY IS SET TO FALSE  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/CIS_Failure.log
                echo " 2.2.5 Ensure O7_DICTIONARY_ACCESSIBILITY IS SET TO FALSE  - NOT AS PER CIS STANDARDS .. Need Attention" >>  ${FINALDIR}/2_2_5_O7_DICT.log
        fi


echo "" >> ${FINALDIR}/2_2_5_O7_DICT.log


echo ""



echo ""

echo "*************************** End of this module 2.2.5 check ***************************" >> ${FINALDIR}/2_2_5_O7_DICT.log

echo "*********************************************************************************" >> ${FINALDIR}/2_2_5_O7_DICT.log

}










Exec_Fn_1_HARDEN(){


${OHOME}/bin/sqlplus "/ as sysdba"  @${SHELLDIR}/harden.sql


  if [ -f ${HARDENDIR}/HARDEN_1_2_DEF_Sql.log ]
  then
  cat ${HARDENDIR}/HARDEN_1_2_DEF_Sql.log  > ${FINALDIR}/HARDENING_SQL.log
  else
  echo " Hardening Script has not executed"
  fi
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
 mv ${TEMP_LIST_LOCATION}   ${LIS_LOCATION}

 echo  "SECURE_CONTROL_${LIS_NAME}=TCPS" >> ${LIS_LOCATION}
 echo  "ADMIN_RESTRICTIONS_${LIS_NAME}=ON" >> ${LIS_LOCATION}
 echo  "SECURE_REGISTER_${LIS_NAME}=IPC"  >> ${LIS_LOCATION}
 

}


Exec_fn_2_2_4_LOC_LIST(){

LIS_OWNER=`ps -ef | grep tnslsnr  | grep -v grep | awk {'print $1'}`

LIS_NAME=`ps -ef | grep tnslsnr  | grep -v grep | awk {'print $9'}`

LOC_VAR=`${OHOME}/bin/lsnrctl status ${LIS} | grep -i Description`



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
cat ${FINALDIR}/2_2_5_O7_DICT.log >> ${FINALDIR}/Final_OP.log
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
		REP_Fn_2_2_5_O7_DICT
        consolidation
}

fn_exec_hardening(){

        Exec_Fn_1_HARDEN
		Exec_fn_2_1_LIST_HARD
		Exec_fn_2_2_4_LOC_LIST
		
}


#fn_exec_hardening
fn_reporting


