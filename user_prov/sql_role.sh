#!/bin/bash

printf "Enter the existing username to be modelled with in CAPS:"
read modlusr

sqlplus -s / as sysdba <<EOF

SET LINES 200
 col grantee for a20
 col type for a20
 col pv for a60
 set heading off
 set pages 0

spool user_sql_model.log
select grantee
  , 'ROL' type
  , granted_role pv
    from dba_role_privs
    where grantee = '$modlusr'
    union
    select grantee
    , 'PRV' type
    , privilege pv
   from dba_sys_privs
   where grantee = '$modlusr' union
   select grantee
   , 'OBJ' type,
   regexp_replace(max(decode(privilege,'WRITE','WRITE,'))||
   max(decode(privilege,'READ','READ,'))||
   max(decode(privilege,'EXECUTE','EXECUTE')),'WRITE,READ,EXECUTE','ALL')||
   regexp_replace(max(decode(privilege,'SELECT','SELECT'))||
   max(decode(privilege,'DELETE',',DELETE'))||
   max(decode(privilege,'UPDATE',',UPDATE'))||
   max(decode(privilege,'INSERT',',INSERT')),'SELECT,DELETE,UPDATE,INSERT','ALL')||
   ' ON '||object_type||' "'||a.owner||'"."'||table_name||'"' pv
   from dba_tab_privs a
   , dba_objects b
   where a.owner=b.owner
   and a.table_name = b.object_name
   and a.grantee='$modlusr'
   group by a.owner
   , table_name
   , object_type
   , grantee
   union
   select grantee
   , 'COL' type,
   privilege||' ('||column_name||') ON "'||owner||'"."'||table_name||'"' pv
   from dba_col_privs
   where grantee='$modlusr'
   union
   select username grantee
   , '---' type
   , 'empty user ---' pv
  from dba_users
   where not username in (select distinct grantee from dba_role_privs)
   and not username in (select distinct grantee from dba_sys_privs)
   and not username in (select distinct grantee from dba_tab_privs)
   and username like '$modlusr'
   group by username
   order by grantee
   , type
   , pv;
spool off

EOF

