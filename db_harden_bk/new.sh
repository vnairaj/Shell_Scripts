#!/bin/bash
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

${OHOME}/OPatch/opatch lsinventory | grep -A 34 "Local Machine Information"  >> ${FINALDIR}/1_patch_artifact.log

patch_appl=`${OHOME}/OPatch/opatch lsinventory | grep applied | head -1`

patch_in_sec=`echo ${patch_appl} | cut -d " " -f7,8,9`

curr_sec=`date +%s`
patch_in_sec=`date -d "$dat" +%s`

 diff_var=`expr ${curr_sec} - ${patch_in_sec}`

                if [ ${diff_var} -gt 10520000  ];
                then
                echo " 1. Patching Information - NOT AS PER CIS STANDARDS.. Need Attention!! "  > ${FINALDIR}/CIS_Failure.log
                                echo " 1. Patching Information - NOT AS PER CIS STANDARDS.. Need Attention!! "  >> ${FINALDIR}/1_patch_artifact.log
                else
                echo " 1. Patching Information - AS PER CIS STANDARDS." > ${FINALDIR}/CIS_Success.log
                                echo " 1. Patching Information - AS PER CIS STANDARDS.. Need Attention!! "  >> ${FINALDIR}/1_patch_artifact.log
                fi

echo ""  >> ${FINALDIR}/1_patch_artifact.log
echo "End of this module 1.1 check....****" >> ${FINALDIR}/1_patch_artifact.log
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


echo "" >> ${FINALDIR}/1_2_DEF_Pass.log
echo "End of this module 1.2 check....****" >> ${FINALDIR}/1_2_DEF_Pass.log

echo "*********************************************************************************" >> ${FINALDIR}/1_2_DEF_Pass.log

}




Exec_Fn_1_2_DEF_Pass(){


${OHOME}/bin/sqlplus "/ as sysdba"  @${SHELLDIR}/harden.sql


  if [ -f ${HARDENDIR}/HARDEN_1_2_DEF_Sql.log ]
  then
  cat ${HARDENDIR}/HARDEN_1_2_DEF_Sql.log  > ${FINALDIR}/HARDENING_SQL.log
  else
  echo " Hardening not performed for Default users"
  fi
}

######################### 1.2 ENDS HERE ##############################################################

consolidation() {


printf "***************************************************************************************"
echo  ""
echo "Success CIS:  "
cat ${FINALDIR}/CIS_Success.log

echo ""
printf "***************************************************************************************"
echo ""
echo "Failure CIS: "

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




echo "Final Output"

cat  ${FINALDIR}/Final_OP.log




}


fn_reporting(){

        REP_Fn_1_patch_artifact
        REP_Fn_1_2_DEF_Pass
        consolidation
}

fn_exec_hardening(){

        Exec_Fn_1_2_DEF_Pass
}


fn_exec_hardening
fn_reporting

