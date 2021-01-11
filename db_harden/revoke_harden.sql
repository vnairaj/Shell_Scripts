set echo on
spool /home/oracle/shell_scr/db_harden/revoke_harden.log
revoke ALTER      from VINAY;
revoke DELETE      from VINAY;
revoke INDEX      from VINAY;
revoke INSERT      from VINAY;
revoke SELECT      from VINAY;
revoke UPDATE      from VINAY;
revoke REFERENCES      from VINAY;
revoke READ      from VINAY;
revoke ON COMMIT REFRESH    from VINAY;
revoke QUERY REWRITE     from VINAY;
revoke DEBUG      from VINAY;
revoke FLASHBACK      from VINAY;
revoke ALTER      from INTELLECTCARDS;
revoke DELETE      from INTELLECTCARDS;
revoke INDEX      from INTELLECTCARDS;
revoke INSERT      from INTELLECTCARDS;
revoke SELECT      from INTELLECTCARDS;
revoke UPDATE      from INTELLECTCARDS;
revoke REFERENCES      from INTELLECTCARDS;
revoke READ      from INTELLECTCARDS;
revoke ON COMMIT REFRESH    from INTELLECTCARDS;
revoke QUERY REWRITE     from INTELLECTCARDS;
revoke DEBUG      from INTELLECTCARDS;
revoke FLASHBACK      from INTELLECTCARDS;
revoke ALTER      from CARDS_FIN;
revoke DELETE      from CARDS_FIN;
revoke INDEX      from CARDS_FIN;
revoke INSERT      from CARDS_FIN;
revoke SELECT      from CARDS_FIN;
revoke UPDATE      from CARDS_FIN;
revoke REFERENCES      from CARDS_FIN;
revoke READ      from CARDS_FIN;
revoke ON COMMIT REFRESH    from CARDS_FIN;
revoke QUERY REWRITE     from CARDS_FIN;
revoke DEBUG      from CARDS_FIN;
revoke FLASHBACK      from CARDS_FIN;
revoke all on DBA_DV_STATUS from VRDB008;
revoke all on DBA_DV_STATUS from VRDB009;
revoke all on  from ;
spool off
exit
