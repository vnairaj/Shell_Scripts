#!/bin/bash


DRDIR=/home/oracle/shell_scr/drlag
mkdir  -p $DRDIR
grep '=$' $ORACLE_HOME/network/admin/tnsnames.ora | grep ^[A-Z] | tr "=" "\t" > $DRDIR/INPFILE.out
pass=`cat /home/oracle/shell_scr/.pass`

DRDIR=/home/oracle/shell_scr/drlag
for DB in `cat $DRDIR/INPFILE.out`; do
DBNAME=$DB

echo "DB name is $DBNAME"
echo "Pass is $pass"
echo "In SCN loop"

sqlplus -s "sys/${pass}@${DBNAME} as sysdba" <<EOF
set head off
set pages 0
spool $DRDIR/${DBNAME}_scn.log
select to_char(current_scn) from v\$database;
spool off
EOF


scnnum=`cat $DRDIR/${DBNAME}_scn.log | head -1`
echo "PRIM value : ${scnnum}"


echo "Proceeding to Timestamp loop"

sqlplus -s "/ as sysdba" <<EOF
set pages 0
set head off
spool $DRDIR/${DBNAME}_time.log
 select to_char(scn_to_timestamp(${scnnum}),'YYYY-MM-DD HH24:MI:SS')  as timestamp from dual;

spool off
EOF

done


	cd $DRDIR

 STBY_time=`ls -ltrh *time.log | grep -Ei   '_st|dr' | awk {'print $9'} | head -1 | xargs cat | head -1` 
 PRIM_time=`ls -ltrh *time.log | grep -Evi  '_st|dr' | awk {'print $9'} | head -1 | xargs cat | head -1`

	echo "STBY TIME : $STBY_time"
	echo "PRIM TIME : $PRIM_time"

  st_ss=`date --date "$STBY_time" +%s`
  pr_ss=`date --date "$PRIM_time" +%s`


	echo "ST SS : $st_ss"
	echo "PR SS : $pr_ss"


	timgap=`expr $pr_ss - $st_ss`


	echo " Time Gap : $timgap"

	if [ $timgap -ge 900 ];
	then
		echo "Warning - DR Log gap exceeded 15 minutes RPO" 

		if [ $timgap -ge 1200 ];
		then
		echo "Critical - DR Log gap exceeded 20 minutes RPO"

			if [ $timgap -ge 1800 ];
			then
			echo "Disaster - DR Log gap exceed 30 minutes RPO"
			fi
		fi
	fi



	

