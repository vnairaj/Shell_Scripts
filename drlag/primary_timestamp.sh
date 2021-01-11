#!/bin/bash
DRDIR=/home/oracle/shell_scr/drlag
export ORACLE_SID=VRDB
sqlplus -s "/ as sysdba" <<EOF
set head off
set pages 0
spool $DRDIR/primary_scn.log
select to_char(current_scn) from v\$database;
spool off
EOF


prim=`cat primary_scn.log | head -1`
echo "PRIM value : $prim"
sqlplus -s "/ as sysdba" <<EOF
alter session set nls_date_format='dd-mm-yyyy hh:mi:ss';
set pages 0
set head off
spool $DRDIR/prim_timestamp.log 
 select to_char(scn_to_timestamp($prim),'DD-MM-YYYY HH24:MI:SS')  as timestamp from dual;

spool off
EOF

