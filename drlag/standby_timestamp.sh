#!/bin/bash
DRDIR=/home/oracle/shell_scr/drlag
export ORACLE_SID=VRDB_STBY
sqlplus -s "/ as sysdba" <<EOF
set head off
set pages 0
spool $DRDIR/standby_scn.log
select to_char(current_scn) from v\$database;
spool off
EOF


stand=`cat standby_scn.log | head -1`
echo "PRIM value : $prim"
export ORACLE_SID=VRDB
sqlplus -s "/ as sysdba" <<EOF
alter session set nls_date_format='dd-mm-yyyy hh:mi:ss';
set pages 0
set head off
spool $DRDIR/standby_timestamp.log 
 select to_char(scn_to_timestamp($stand),'DD-MM-YYYY HH24:MI:SS')  as timestamp from dual;

spool off
EOF

