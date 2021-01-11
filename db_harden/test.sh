#!/bin/bash
SHELLDIR=/home/oracle/shell_scr/db_harden
FINALDIR=${SHELLDIR}/OPDIR
HARDENDIR=${FINALDIR}/HRDSQLDIR
mkdir  -p ${SHELLDIR}
mkdir  -p ${FINALDIR}
mkdir  -p ${HARDENDIR}
cat /etc/oratab | grep -v + | tail -1 | tr ":"  "\n" | head -1 > ${SHELLDIR}/DBNAME.out
cat /etc/oratab | grep -v + | tail -1 | tr ":"  "\n" | head -2 | tail -1  > ${SHELLDIR}/OHOME.out

rm -rf ${FINALDIR}/*.log

DBNAME=`cat ${SHELLDIR}/DBNAME.out`
OHOME=`cat ${SHELLDIR}/OHOME.out`


Exec_Fn_1_2_DEF_Pass(){


${OHOME}/bin/sqlplus "/ as sysdba"  @${SHELLDIR}/harden.sql 


  if [ -f ${HARDENDIR}/HARDEN_1_2_DEF_Sql.log ]
  then
  cat ${HARDENDIR}/HARDEN_1_2_DEF_Sql.log  > ${FINALDIR}/HARDENING_SQL.log 
  else 
  echo " Hardening not performed for Default users"
  fi
}


Exec_Fn_1_2_DEF_Pass




