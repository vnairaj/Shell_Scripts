set lines 120
set pages 120
column KSPPINM format a30
column KSPPSTVL format a30

spool /home/oracle/shell_scr/db_harden/rep_sqls/sql_2_2_18_TRACE_FILES_PUBLIC.log

SELECT
  ksppinm,
  ksppstvl
FROM
  x$ksppi a,
  x$ksppsv b
WHERE
  a.indx=b.indx
AND
  substr(ksppinm,1,1) = '_'
ORDER BY ksppinm;

spool off

exit;
