---------------------------------------------------------------------------------------------------------------------------------------
\echo  set global parameters: static for test
---------------------------------------------------------------------------------------------------------------------------------------
SELECT set_config( 'test.finper' , lysglb.get_current_finperiod(1)::TEXT, false ) <> '' AS finper,
       set_config( 'test.schema' , 'year'||mod( lysglb.get_current_finyear(1), 100 )::TEXT, false ) <> '' AS transaction_schema,
       set_config( 'test.adir' , '1'::TEXT, false ) <> '' AS adir,
       set_config( 'test.xml_template', '<era>
                                                <header>
                                                    <a_id_integer>1</a_id_integer>
                                                    <delete_temp_integer>0</delete_temp_integer>
                                                    <global>
                                                        <adir_integer>%5$s</adir_integer>
                                                        <period_integer>%1$s</period_integer>
                                                        <user>AUTO</user>
                                                    </global>
                                                    <funder>
                                                        <name/>
                                                    </funder>
                                                    <reference_nos>
                                                        <goodx_cashbook>%2$s</goodx_cashbook>
                                                        <goodx_deposit_no/>
                                                        <allow_post_on_reconned>0</allow_post_on_reconned>
                                                        <bank_payment/>
                                                    </reference_nos>
                                                    <bank_deposit>
                                                        <bank_details>
                                                            <branch_code/>
                                                            <bank_name/>
                                                            <payer>S</payer>
                                                        </bank_details>
                                                        <transaction>
                                                            <paid_amount>100</paid_amount>
                                                            <date_time>2022-01-05T00:00:00</date_time>
                                                        </transaction>
                                                    </bank_deposit>
                                                </header>
                                                <payments>
                                                    <payment>
                                                        <a_id_integer>1</a_id_integer>
                                                        <transaction_type>%4$s</transaction_type>
                                                        <items>
                                                            <item>
                                                                <a_id_integer>1</a_id_integer>
                                                                <ledger>%3$s</ledger>
                                                                <paid_to_provider_amt>100</paid_to_provider_amt>
                                                                <vat>0</vat>
                                                                <payment_method>0</payment_method>
                                                                <cost_centre_id>0</cost_centre_id>
                                                            </item>
                                                        </items>
                                                    </payment>
                                                </payments>
                                            </era>', false) <> '' AS xml_template,
       set_config( 'test.xml_template_reversal', '<era>
                                                <header>
                                                    <a_id_integer>1</a_id_integer>
                                                    <delete_temp_integer>0</delete_temp_integer>
                                                    <global>
                                                        <adir_integer>%6$s</adir_integer>
                                                        <period_integer>%1$s</period_integer>
                                                        <user>AUTO</user>
                                                    </global>
                                                    <funder>
                                                        <name/>
                                                    </funder>
                                                    <reference_nos>
                                                        <goodx_cashbook>%2$s</goodx_cashbook>
                                                        <goodx_deposit_no>%5$s</goodx_deposit_no>
                                                        <allow_post_on_reconned>0</allow_post_on_reconned>
                                                        <bank_payment/>
                                                    </reference_nos>
                                                    <bank_deposit>
                                                        <bank_details>
                                                            <branch_code/>
                                                            <bank_name/>
                                                            <payer>S</payer>
                                                        </bank_details>
                                                        <transaction>
                                                            <paid_amount>100</paid_amount>
                                                            <date_time>2022-01-05T00:00:00</date_time>
                                                        </transaction>
                                                    </bank_deposit>
                                                </header>
                                                <payments>
                                                    <payment>
                                                        <a_id_integer>1</a_id_integer>
                                                        <transaction_type>-%4$s</transaction_type>
                                                        <items>
                                                            <item>
                                                                <a_id_integer>1</a_id_integer>
                                                                <ledger>%3$s</ledger>
                                                                <paid_to_provider_amt>100</paid_to_provider_amt>
                                                                <vat>0</vat>
                                                                <payment_method>0</payment_method>
                                                                <cost_centre_id>0</cost_centre_id>
                                                            </item>
                                                        </items>
                                                    </payment>
                                                </payments>
                                            </era>', false ) <> '' AS xml_template_reversal,
       set_config( 'test.template_flag_tran_as_reconned', 'UPDATE %1$s SET ptipe = %7$s, kasrekon = %6$s WHERE entity = %2$s AND doknr = %3$L'
                                            , false ) <> '' AS template_flag_tran_as_reconned;
                                             ;
\echo -----------------------------------------------------------------------------------------------------------------------------------------------
\echo --=======================================[TEST1:  Deposit on KAS1, contra KAS2. Post and correction in KAS1, then another correction from KAS2]
\echo -----------------------------------------------------------------------------------------------------------------------------------------------
\echo  set parameters for TEST1

SELECT set_config( 'test.primary_cashbook', 'KAS1', FALSE ) AS primary_cashbook,
       set_config( 'test.contra_cashbook', 'KAS2', FALSE ) AS contra_cashbook,
       set_config( 'test.primary_transaction', '20', FALSE ) AS primary_transaction,
       set_config( 'test.contra_transaction', '30', FALSE ) AS contra_transaction;
WITH a AS (INSERT INTO lysglb.recon_mstr_s  ( entity, cashbook )
            SELECT current_setting( 'test.adir' )::Integer, substr( current_setting( 'test.primary_cashbook' ),4,10) ::INTEGER
            RETURNING mainid)
SELECT set_config('test.reconid' , mainid::text, FALSE) <> '' AS recon_id FROM a;

\echo  TEST1.00: post INTE-CASHBOOK deposit between KAS1 and KAS2

with a AS ( select tariffs.cj_post_xml( format( current_setting( 'test.xml_template' )
                                               , lysglb.get_current_finperiod(1)
                                               , current_setting( 'test.primary_cashbook' ) --2
                                               , current_setting( 'test.contra_cashbook' ) --3
                                               , current_setting( 'test.primary_transaction' )--4
                                               , current_setting( 'test.adir') --5
                                                    )::xml --1
                                                   ) AS res )
SELECT DISTINCT jsonb_array_elements( (xpath( 'era/feedback/summary/feedback_summary/text()',res ))[1]::TEXT::JSONB )->>'code' AS feedback_summary,
       ( xpath( 'era/feedback/summary/info/text()', res ) )[1]::TEXT  AS info,
       (xpath( 'era/feedback/summary/critical/text()', res ))[1]::TEXT AS critical_errors,
       set_config( 'test.primary_doknr', (xpath( 'era/payments/payment/items/item/inte_cashbook/deposit_no/text()', res ))[1]::TEXT, false) <> '' AS primary_doknr,
       set_config( 'test.contra_doknr', (xpath( 'era/payments/payment/items/item/inte_cashbook/deposit_no/text()', res ))[2]::TEXT, FALSE)  <> '' AS contra_doknr,
       set_config( 'test.primary_analysis_table', (xpath( 'era/payments/payment/items/item/inte_cashbook/analysis_table/text()', res ))[1]::TEXT, false) <> '' AS primary_analysis_table,
       set_config( 'test.contra_analysis_table', (xpath( 'era/payments/payment/items/item/inte_cashbook/analysis_table/text()', res ))[2]::TEXT, FALSE) <> '' AS contra_analysis_table,
       (xpath( 'era/payments/payment/transaction_type/text()', res ))[1]::TEXT AS _primary_trantype,
       (xpath( 'era/payments/payment/transaction_type/text()', res ))[2]::TEXT AS _contra_trantype
       --, res
FROM a;

\echo Record posted document numbers
DO
$$
BEGIN
  EXECUTE format('select set_config(  %2$L ,doknr, false ), set_config(  %3$L, nappikode, false ) from %1$s WHERE doknr = %4$L order by mainid desc limit 1', current_setting( 'test.primary_analysis_table' ),'test.primary_doknr','test.primary_nappi_doknr', current_setting( 'test.primary_doknr' ) );
  EXECUTE format('select set_config(  %2$L ,doknr, false ), set_config(  %3$L, nappikode, false ) from %1$s WHERE doknr = %4$L order by mainid desc limit 1', current_setting( 'test.contra_analysis_table' ),'test.contra_doknr','test.contra_nappi_doknr', current_setting( 'test.contra_doknr' ) );
END;
$$;

\echo check(1) posted to correct tables (2) doknr vs nappikode

SELECT split_part( current_setting( 'test.primary_analysis_table' ), '.',2 ) AS primary_analysis_table,
       split_part( current_setting( 'test.contra_analysis_table' ), '.',2 ) AS secondary_analysis_table,
       current_setting( 'test.primary_doknr' ) = current_setting( 'test.contra_nappi_doknr' ) AS primary_doc_vs_contra_nappi,
       current_setting( 'test.primary_nappi_doknr' ) =  current_setting( 'test.contra_doknr' ) AS contra_doc_vs_primary_nappi;


\echo  TEST1.01 : reverse INTE-CASHBOOK deposit between KAS1 and KAS2 on primary cashbook side.

with a AS ( select tariffs.cj_post_xml( format( current_setting( 'test.xml_template_reversal' ) , lysglb.get_current_finperiod(1)
                                                                                           , current_setting( 'test.primary_cashbook' ) --2
                                                                                           , current_setting( 'test.contra_cashbook' ) --3
                                                                                           , current_setting( 'test.primary_transaction' )--4
                                                                                           ,  current_setting( 'test.primary_doknr' ) --5
                                                                                           , current_setting( 'test.adir') --6

                                                                                           )::xml  ) AS res )
SELECT DISTINCT jsonb_array_elements( (xpath( 'era/feedback/summary/feedback_summary/text()',res ))[1]::TEXT::JSONB )->>'code' AS feedback_summary,
       ( xpath( 'era/feedback/summary/info/text()', res ) )[1]::TEXT  AS info,
       (xpath( 'era/feedback/summary/critical/text()', res ))[1]::TEXT AS critical_errors,
       set_config( 'test.primary_doknr_reversal_p', (xpath( 'era/payments/payment/items/item/inte_cashbook/deposit_no/text()', res ))[1]::TEXT, false) <> '' AS primary_doknr_reversal_p,
       set_config( 'test.contra_doknr_reversal_p', (xpath( 'era/payments/payment/items/item/inte_cashbook/deposit_no/text()', res ))[2]::TEXT, FALSE)  <> '' AS contra_doknr_reversal_p,
       set_config( 'test.primary_analysis_table_reversal_p', (xpath( 'era/payments/payment/items/item/inte_cashbook/analysis_table/text()', res ))[1]::TEXT, false) <> '' AS primary_analysis_table_reversal_p,
       set_config( 'test.contra_analysis_table_reversal_p', (xpath( 'era/payments/payment/items/item/inte_cashbook/analysis_table/text()', res ))[2]::TEXT, FALSE) <> '' AS contra_analysis_table_reversal_p,
       (xpath( 'era/payments/payment/transaction_type/text()', res ))[1]::TEXT AS _primary_trantype,
       (xpath( 'era/payments/payment/transaction_type/text()', res ))[2]::TEXT AS _contra_trantype
       --, res
FROM a;




-- check(1)posted to correct correct tables (2) same document numbers used for corrections AS source on both tables
SELECT split_part( current_setting( 'test.primary_analysis_table_reversal_p' ), '.',2 ) AS primary_analysis_table_reversal_p,
       split_part( current_setting( 'test.contra_analysis_table_reversal_p' ), '.',2 ) AS contra_analysis_table_reversal_p,
       current_setting( 'test.primary_doknr' )=current_setting( 'test.primary_doknr_reversal_p' ) AS primary_docno_for_reversal_ok,
       current_setting( 'test.primary_nappi_doknr' )=current_setting( 'test.contra_doknr_reversal_p' ) AS contra_docno_for_reversal_ok;



\echo  TEST1.02 : reverse INTE-CASHBOOK deposit between KAS1 and KAS2 on CONTRA cashbook side. (Change trantype to -30 and switch cashbook)


with a AS ( select tariffs.cj_post_xml( format( current_setting( 'test.xml_template_reversal' ) , lysglb.get_current_finperiod(1)
                                                                                           , current_setting( 'test.contra_cashbook' ) --2
                                                                                           , current_setting( 'test.primary_cashbook' ) --3
                                                                                           , current_setting( 'test.contra_transaction' )--4
                                                                                           , current_setting( 'test.contra_doknr' )  --5
                                                                                           , current_setting( 'test.adir') --6
                                                                                           )::xml  ) AS res )
SELECT DISTINCT jsonb_array_elements( (xpath( 'era/feedback/summary/feedback_summary/text()',res ))[1]::TEXT::JSONB )->>'code' AS feedback_summary,
       ( xpath( 'era/feedback/summary/info/text()', res ) )[1]::TEXT  AS info,
       (xpath( 'era/feedback/summary/critical/text()', res ))[1]::TEXT AS critical_errors,
       set_config( 'test.primary_doknr_reversal_p', (xpath( 'era/payments/payment/items/item/inte_cashbook/deposit_no/text()', res ))[1]::TEXT, false) <> '' AS primary_doknr_reversal_p,
       set_config( 'test.contra_doknr_reversal_p', (xpath( 'era/payments/payment/items/item/inte_cashbook/deposit_no/text()', res ))[2]::TEXT, FALSE)  <> '' AS contra_doknr_reversal_p,
       set_config( 'test.primary_analysis_table_reversal_p', (xpath( 'era/payments/payment/items/item/inte_cashbook/analysis_table/text()', res ))[1]::TEXT, false) <> '' AS primary_analysis_table_reversal_p,
       set_config( 'test.contra_analysis_table_reversal_p', (xpath( 'era/payments/payment/items/item/inte_cashbook/analysis_table/text()', res ))[2]::TEXT, FALSE) <> '' AS contra_analysis_table_reversal_p,
       (xpath( 'era/payments/payment/transaction_type/text()', res ))[1]::TEXT AS _primary_trantype,
       (xpath( 'era/payments/payment/transaction_type/text()', res ))[2]::TEXT AS _contra_trantype
       --, res
FROM a;

-- check(1)correct tables (2) same document numbers used for corrections AS source on both tables
SELECT split_part( current_setting( 'test.primary_analysis_table_reversal_p' ), '.',2 ) AS primary_analysis_table_reversal_p,
       split_part( current_setting( 'test.contra_analysis_table_reversal_p' ), '.',2 ) AS contra_analysis_table_reversal_p,
       current_setting ('test.primary_nappi_doknr' )=current_setting( 'test.primary_doknr_reversal_p' ) AS primary_docno_for_reversal_ok,
       current_setting ('test.primary_doknr' )=current_setting( 'test.contra_doknr_reversal_p' ) AS contra_docno_for_reversal_ok;

---------------------------------------------------------------------------------------------------------------------------------------
\echo TEST1.1.2: Recon test - make sure that corrections cannot be posted if one of the two source transactions is flagged as reconned.
---------------------------------------------------------------------------------------------------------------------------------------
BEGIN; --recon_test_1_2
        SAVEPOINT recon_test_1_2;


        \echo TEST1.21 flag primary document as reconned
        DO
        $$
        BEGIN
            EXECUTE format(current_setting ('test.template_flag_tran_as_reconned')
                             ,replace( current_setting( 'test.primary_analysis_table' ), '_s', '_d' ) --1
                             ,current_setting( 'test.adir' ) --2
                             ,current_setting( 'test.primary_doknr' ) --3
                             ,current_setting( 'test.primary_cashbook' ) --4
                             ,current_setting( 'test.primary_transaction' ) --5
                             ,10 --6
                             ,current_setting('test.reconid') --7
                             );
        END;
        $$;
       
        \echo TEST1.22  Try and post correction from the primary document side (primary flagged as reconned) - should fail
        with a AS ( select tariffs.cj_post_xml( format( current_setting( 'test.xml_template_reversal' ) , lysglb.get_current_finperiod(1)
                                                                                                   , current_setting( 'test.primary_cashbook' ) --2
                                                                                                   , current_setting( 'test.contra_cashbook' ) --3
                                                                                                   , current_setting( 'test.primary_transaction' )--4
                                                                                                   ,  current_setting( 'test.primary_doknr' ) --5
                                                                                                   , current_setting( 'test.adir') --6

                                                                                                   )::xml  ) AS res )
        SELECT DISTINCT jsonb_array_elements( (xpath( 'era/feedback/summary/feedback_summary/text()',res ))[1]::TEXT::JSONB )->>'code' AS feedback_summary,
               ( xpath( 'era/feedback/summary/info/text()', res ) )[1]::TEXT  AS info,
               (xpath( 'era/feedback/summary/critical/text()', res ))[1]::TEXT AS critical_errors,
               set_config( 'test.primary_doknr_reversal_p', (xpath( 'era/payments/payment/items/item/inte_cashbook/deposit_no/text()', res ))[1]::TEXT, false) <> '' AS primary_doknr_reversal_p,
               set_config( 'test.contra_doknr_reversal_p', (xpath( 'era/payments/payment/items/item/inte_cashbook/deposit_no/text()', res ))[2]::TEXT, FALSE)  <> '' AS contra_doknr_reversal_p,
               set_config( 'test.primary_analysis_table_reversal_p', (xpath( 'era/payments/payment/items/item/inte_cashbook/analysis_table/text()', res ))[1]::TEXT, false) <> '' AS primary_analysis_table_reversal_p,
               set_config( 'test.contra_analysis_table_reversal_p', (xpath( 'era/payments/payment/items/item/inte_cashbook/analysis_table/text()', res ))[2]::TEXT, FALSE) <> '' AS contra_analysis_table_reversal_p,
               (xpath( 'era/payments/payment/transaction_type/text()', res ))[1]::TEXT AS _primary_trantype,
               (xpath( 'era/payments/payment/transaction_type/text()', res ))[2]::TEXT AS _contra_trantype
               --, res
        FROM a;


        \echo TEST1.22  Try and post correction from the contra document side (primary flagged as reconned)  - should fail
        with a AS ( select tariffs.cj_post_xml( format( current_setting( 'test.xml_template_reversal' ) , lysglb.get_current_finperiod(1)
                                                                                                   , current_setting( 'test.contra_cashbook' ) --2
                                                                                                   , current_setting( 'test.primary_cashbook' ) --3
                                                                                                   , current_setting( 'test.contra_transaction' )--4
                                                                                                   ,  current_setting( 'test.contra_doknr' ) --5
                                                                                                   , current_setting( 'test.adir') --6

                                                                                                   )::xml  ) AS res )
        SELECT DISTINCT jsonb_array_elements( (xpath( 'era/feedback/summary/feedback_summary/text()',res ))[1]::TEXT::JSONB )->>'code' AS feedback_summary,
               ( xpath( 'era/feedback/summary/info/text()', res ) )[1]::TEXT  AS info,
               (xpath( 'era/feedback/summary/critical/text()', res ))[1]::TEXT AS critical_errors,
               set_config( 'test.primary_doknr_reversal_p', (xpath( 'era/payments/payment/items/item/inte_cashbook/deposit_no/text()', res ))[1]::TEXT, false) <> '' AS primary_doknr_reversal_p,
               set_config( 'test.contra_doknr_reversal_p', (xpath( 'era/payments/payment/items/item/inte_cashbook/deposit_no/text()', res ))[2]::TEXT, FALSE)  <> '' AS contra_doknr_reversal_p,
               set_config( 'test.primary_analysis_table_reversal_p', (xpath( 'era/payments/payment/items/item/inte_cashbook/analysis_table/text()', res ))[1]::TEXT, false) <> '' AS primary_analysis_table_reversal_p,
               set_config( 'test.contra_analysis_table_reversal_p', (xpath( 'era/payments/payment/items/item/inte_cashbook/analysis_table/text()', res ))[2]::TEXT, FALSE) <> '' AS contra_analysis_table_reversal_p,
               (xpath( 'era/payments/payment/transaction_type/text()', res ))[1]::TEXT AS _primary_trantype,
               (xpath( 'era/payments/payment/transaction_type/text()', res ))[2]::TEXT AS _contra_trantype
               --, res
        FROM a;

        ROLLBACK TO recon_test_1_2;
END; --recon_test_1_2

\echo TEST1.3 flag contra document as reconned,
BEGIN; --recon_test_1_3
    SAVEPOINT recon_test_1_3;

    DO
    $$
    BEGIN
        EXECUTE format(current_setting ('test.template_flag_tran_as_reconned')
                         ,replace( current_setting( 'test.contra_analysis_table' ), '_s', '_d' ) --1
                         ,current_setting( 'test.adir' ) --2
                         ,current_setting( 'test.contra_doknr' ) --3
                         ,current_setting( 'test.contra_cashbook' ) --4
                         ,current_setting( 'test.contra_transaction' ) --5
                         ,10 --6
                         ,current_setting('test.reconid') --7
                         );
    END;
    $$;


    \echo TEST1.31  Try and post correction from the contra document side (contra flagged as reconned) - should fail
    with a AS ( select tariffs.cj_post_xml( format( current_setting( 'test.xml_template_reversal' ) , lysglb.get_current_finperiod(1)
                                                                                               , current_setting( 'test.contra_cashbook' ) --2
                                                                                               , current_setting( 'test.primary_cashbook' ) --3
                                                                                               , current_setting( 'test.contra_transaction' )--4
                                                                                               ,  current_setting( 'test.contra_doknr' ) --5
                                                                                               , current_setting( 'test.adir') --6

                                                                                               )::xml  ) AS res )
    SELECT DISTINCT jsonb_array_elements( (xpath( 'era/feedback/summary/feedback_summary/text()',res ))[1]::TEXT::JSONB )->>'code' AS feedback_summary,
           ( xpath( 'era/feedback/summary/info/text()', res ) )[1]::TEXT  AS info,
           (xpath( 'era/feedback/summary/critical/text()', res ))[1]::TEXT AS critical_errors,
           set_config( 'test.primary_doknr_reversal_p', (xpath( 'era/payments/payment/items/item/inte_cashbook/deposit_no/text()', res ))[1]::TEXT, false) <> '' AS primary_doknr_reversal_p,
           set_config( 'test.contra_doknr_reversal_p', (xpath( 'era/payments/payment/items/item/inte_cashbook/deposit_no/text()', res ))[2]::TEXT, FALSE)  <> '' AS contra_doknr_reversal_p,
           set_config( 'test.primary_analysis_table_reversal_p', (xpath( 'era/payments/payment/items/item/inte_cashbook/analysis_table/text()', res ))[1]::TEXT, false) <> '' AS primary_analysis_table_reversal_p,
           set_config( 'test.contra_analysis_table_reversal_p', (xpath( 'era/payments/payment/items/item/inte_cashbook/analysis_table/text()', res ))[2]::TEXT, FALSE) <> '' AS contra_analysis_table_reversal_p,
           (xpath( 'era/payments/payment/transaction_type/text()', res ))[1]::TEXT AS _primary_trantype,
           (xpath( 'era/payments/payment/transaction_type/text()', res ))[2]::TEXT AS _contra_trantype
           --, res
    FROM a;


    \echo TEST1.32  Try and post correction from the primary document side (contra flagged as reconned) - should fail
    with a AS ( select tariffs.cj_post_xml( format( current_setting( 'test.xml_template_reversal' ) , lysglb.get_current_finperiod(1)
                                                                                               , current_setting( 'test.primary_cashbook' ) --2
                                                                                               , current_setting( 'test.contra_cashbook' ) --3
                                                                                               , current_setting( 'test.primary_transaction' )--4
                                                                                               ,  current_setting( 'test.primary_doknr' ) --5
                                                                                               , current_setting( 'test.adir') --6

                                                                                               )::xml  ) AS res )
    SELECT DISTINCT jsonb_array_elements( (xpath( 'era/feedback/summary/feedback_summary/text()',res ))[1]::TEXT::JSONB )->>'code' AS feedback_summary,
           ( xpath( 'era/feedback/summary/info/text()', res ) )[1]::TEXT  AS info,
           (xpath( 'era/feedback/summary/critical/text()', res ))[1]::TEXT AS critical_errors,
           set_config( 'test.primary_doknr_reversal_p', (xpath( 'era/payments/payment/items/item/inte_cashbook/deposit_no/text()', res ))[1]::TEXT, false) <> '' AS primary_doknr_reversal_p,
           set_config( 'test.contra_doknr_reversal_p', (xpath( 'era/payments/payment/items/item/inte_cashbook/deposit_no/text()', res ))[2]::TEXT, FALSE)  <> '' AS contra_doknr_reversal_p,
           set_config( 'test.primary_analysis_table_reversal_p', (xpath( 'era/payments/payment/items/item/inte_cashbook/analysis_table/text()', res ))[1]::TEXT, false) <> '' AS primary_analysis_table_reversal_p,
           set_config( 'test.contra_analysis_table_reversal_p', (xpath( 'era/payments/payment/items/item/inte_cashbook/analysis_table/text()', res ))[2]::TEXT, FALSE) <> '' AS contra_analysis_table_reversal_p,
           (xpath( 'era/payments/payment/transaction_type/text()', res ))[1]::TEXT AS _primary_trantype,
           (xpath( 'era/payments/payment/transaction_type/text()', res ))[2]::TEXT AS _contra_trantype
           --, res
    FROM a;

    ROLLBACK TO recon_test_1_3;
END;  --recon_test_1_3

---------------------------------------------------------------------------------------------------------------------------------------
\echo TEST1.4  Try and post correction to another cashbook. This must fail
---------------------------------------------------------------------------------------------------------------------------------------

BEGIN; --invalid_cashbook_test_1_4
    SAVEPOINT invalid_cashbook_test_1_4;

    \echo TEST1.41  Try and post correction from the primary document side - should fail
    with a AS ( select tariffs.cj_post_xml( format( current_setting( 'test.xml_template_reversal' ) , lysglb.get_current_finperiod(1)
                                                                                               , current_setting( 'test.primary_cashbook' ) --2
                                                                                               , 'KAS3' --3
                                                                                               , current_setting( 'test.primary_transaction' )--4
                                                                                               ,  current_setting( 'test.primary_doknr' ) --5
                                                                                               , current_setting( 'test.adir') --6

                                                                                               )::xml  ) AS res )
    SELECT DISTINCT jsonb_array_elements( (xpath( 'era/feedback/summary/feedback_summary/text()',res ))[1]::TEXT::JSONB )->>'code' AS feedback_summary,
           ( xpath( 'era/feedback/summary/info/text()', res ) )[1]::TEXT  AS info,
           (xpath( 'era/feedback/summary/critical/text()', res ))[1]::TEXT AS critical_errors,
           set_config( 'test.primary_doknr_reversal_p', (xpath( 'era/payments/payment/items/item/inte_cashbook/deposit_no/text()', res ))[1]::TEXT, false) <> '' AS primary_doknr_reversal_p,
           set_config( 'test.contra_doknr_reversal_p', (xpath( 'era/payments/payment/items/item/inte_cashbook/deposit_no/text()', res ))[2]::TEXT, FALSE)  <> '' AS contra_doknr_reversal_p,
           set_config( 'test.primary_analysis_table_reversal_p', (xpath( 'era/payments/payment/items/item/inte_cashbook/analysis_table/text()', res ))[1]::TEXT, false) <> '' AS primary_analysis_table_reversal_p,
           set_config( 'test.contra_analysis_table_reversal_p', (xpath( 'era/payments/payment/items/item/inte_cashbook/analysis_table/text()', res ))[2]::TEXT, FALSE) <> '' AS contra_analysis_table_reversal_p,
           (xpath( 'era/payments/payment/transaction_type/text()', res ))[1]::TEXT AS _primary_trantype,
           (xpath( 'era/payments/payment/transaction_type/text()', res ))[2]::TEXT AS _contra_trantype
           --, res
    FROM a;


    \echo TEST1.42  Try and post correction from the contra document side - should fail
    with a AS ( select tariffs.cj_post_xml( format( current_setting( 'test.xml_template_reversal' ) , lysglb.get_current_finperiod(1)
                                                                                               , current_setting( 'test.contra_cashbook' ) --2
                                                                                               , 'KAS3' --3
                                                                                               , current_setting( 'test.contra_transaction' )--4
                                                                                               ,  current_setting( 'test.contra_doknr' ) --5
                                                                                               , current_setting( 'test.adir') --6

                                                                                               )::xml  ) AS res )
    SELECT DISTINCT jsonb_array_elements( (xpath( 'era/feedback/summary/feedback_summary/text()',res ))[1]::TEXT::JSONB )->>'code' AS feedback_summary,
           ( xpath( 'era/feedback/summary/info/text()', res ) )[1]::TEXT  AS info,
           (xpath( 'era/feedback/summary/critical/text()', res ))[1]::TEXT AS critical_errors,
           set_config( 'test.primary_doknr_reversal_p', (xpath( 'era/payments/payment/items/item/inte_cashbook/deposit_no/text()', res ))[1]::TEXT, false) <> '' AS primary_doknr_reversal_p,
           set_config( 'test.contra_doknr_reversal_p', (xpath( 'era/payments/payment/items/item/inte_cashbook/deposit_no/text()', res ))[2]::TEXT, FALSE)  <> '' AS contra_doknr_reversal_p,
           set_config( 'test.primary_analysis_table_reversal_p', (xpath( 'era/payments/payment/items/item/inte_cashbook/analysis_table/text()', res ))[1]::TEXT, false) <> '' AS primary_analysis_table_reversal_p,
           set_config( 'test.contra_analysis_table_reversal_p', (xpath( 'era/payments/payment/items/item/inte_cashbook/analysis_table/text()', res ))[2]::TEXT, FALSE) <> '' AS contra_analysis_table_reversal_p,
           (xpath( 'era/payments/payment/transaction_type/text()', res ))[1]::TEXT AS _primary_trantype,
           (xpath( 'era/payments/payment/transaction_type/text()', res ))[2]::TEXT AS _contra_trantype
           --, res
    FROM a;




    ROLLBACK TO invalid_cashbook_test_1_4;
END;  --invalid_cashbook_test_1_4


---------------------------------------------------------------------------------------------------------------------------------------
\echo TEST1.5  Try and post correction to a non-cashbook ledger. This must fail
---------------------------------------------------------------------------------------------------------------------------------------

BEGIN; --invalid_cashbook_test_1_5
    SAVEPOINT invalid_cashbook_test_1_5;

    \echo TEST1.51  Try and post correction from the primary document side - should fail
    with a AS ( select tariffs.cj_post_xml( format( current_setting( 'test.xml_template_reversal' ) , lysglb.get_current_finperiod(1)
                                                                                               , current_setting( 'test.primary_cashbook' ) --2
                                                                                               , 'INC1' --3
                                                                                               , current_setting( 'test.primary_transaction' )--4
                                                                                               ,  current_setting( 'test.primary_doknr' ) --5
                                                                                               , current_setting( 'test.adir') --6

                                                                                               )::xml  ) AS res )
    SELECT DISTINCT jsonb_array_elements( (xpath( 'era/feedback/summary/feedback_summary/text()',res ))[1]::TEXT::JSONB )->>'code' AS feedback_summary,
           ( xpath( 'era/feedback/summary/info/text()', res ) )[1]::TEXT  AS info,
           (xpath( 'era/feedback/summary/critical/text()', res ))[1]::TEXT AS critical_errors,
           set_config( 'test.primary_doknr_reversal_p', (xpath( 'era/payments/payment/items/item/inte_cashbook/deposit_no/text()', res ))[1]::TEXT, false) <> '' AS primary_doknr_reversal_p,
           set_config( 'test.contra_doknr_reversal_p', (xpath( 'era/payments/payment/items/item/inte_cashbook/deposit_no/text()', res ))[2]::TEXT, FALSE)  <> '' AS contra_doknr_reversal_p,
           set_config( 'test.primary_analysis_table_reversal_p', (xpath( 'era/payments/payment/items/item/inte_cashbook/analysis_table/text()', res ))[1]::TEXT, false) <> '' AS primary_analysis_table_reversal_p,
           set_config( 'test.contra_analysis_table_reversal_p', (xpath( 'era/payments/payment/items/item/inte_cashbook/analysis_table/text()', res ))[2]::TEXT, FALSE) <> '' AS contra_analysis_table_reversal_p,
           (xpath( 'era/payments/payment/transaction_type/text()', res ))[1]::TEXT AS _primary_trantype,
           (xpath( 'era/payments/payment/transaction_type/text()', res ))[2]::TEXT AS _contra_trantype
           --, res
    FROM a;


    \echo TEST1.52  Try and post correction from the contra document side - should fail
    with a AS ( select tariffs.cj_post_xml( format( current_setting( 'test.xml_template_reversal' ) , lysglb.get_current_finperiod(1)
                                                                                               , current_setting( 'test.contra_cashbook' ) --2
                                                                                               , 'INC1' --3
                                                                                               , current_setting( 'test.contra_transaction' )--4
                                                                                               ,  current_setting( 'test.contra_doknr' ) --5
                                                                                               , current_setting( 'test.adir') --6

                                                                                               )::xml  ) AS res )
    SELECT DISTINCT jsonb_array_elements( (xpath( 'era/feedback/summary/feedback_summary/text()',res ))[1]::TEXT::JSONB )->>'code' AS feedback_summary,
           ( xpath( 'era/feedback/summary/info/text()', res ) )[1]::TEXT  AS info,
           (xpath( 'era/feedback/summary/critical/text()', res ))[1]::TEXT AS critical_errors,
           set_config( 'test.primary_doknr_reversal_p', (xpath( 'era/payments/payment/items/item/inte_cashbook/deposit_no/text()', res ))[1]::TEXT, false) <> '' AS primary_doknr_reversal_p,
           set_config( 'test.contra_doknr_reversal_p', (xpath( 'era/payments/payment/items/item/inte_cashbook/deposit_no/text()', res ))[2]::TEXT, FALSE)  <> '' AS contra_doknr_reversal_p,
           set_config( 'test.primary_analysis_table_reversal_p', (xpath( 'era/payments/payment/items/item/inte_cashbook/analysis_table/text()', res ))[1]::TEXT, false) <> '' AS primary_analysis_table_reversal_p,
           set_config( 'test.contra_analysis_table_reversal_p', (xpath( 'era/payments/payment/items/item/inte_cashbook/analysis_table/text()', res ))[2]::TEXT, FALSE) <> '' AS contra_analysis_table_reversal_p,
           (xpath( 'era/payments/payment/transaction_type/text()', res ))[1]::TEXT AS _primary_trantype,
           (xpath( 'era/payments/payment/transaction_type/text()', res ))[2]::TEXT AS _contra_trantype
           --, res
    FROM a;




    ROLLBACK TO invalid_cashbook_test_1_5;
END;  --invalid_cashbook_test_1_5





\echo ----------------------------------------------------------------------------------------
\echo --=======================================[TEST2:  Cheque on KAS1, Contra (deposit) KAS2]
\echo ----------------------------------------------------------------------------------------

\echo  set parameters for TEST2

SELECT set_config( 'test.primary_transaction', '30', FALSE ) AS primary_transaction,
       set_config( 'test.contra_transaction', '20', FALSE ) AS contra_transaction;

\echo  TEST2.00: post INTE-CASHBOOK cheque between KAS1 and KAS2

with a AS ( select tariffs.cj_post_xml( format( current_setting( 'test.xml_template' )
                                       , lysglb.get_current_finperiod(1)
                                       , current_setting( 'test.primary_cashbook' ) --2
                                       , current_setting( 'test.contra_cashbook' ) --3
                                       , current_setting( 'test.primary_transaction' )--4
                                       , current_setting( 'test.adir') --5
                                        )::xml --1
                                                   ) AS res )
SELECT DISTINCT jsonb_array_elements( (xpath( 'era/feedback/summary/feedback_summary/text()',res ))[1]::TEXT::JSONB )->>'code' AS feedback_summary,
       ( xpath( 'era/feedback/summary/info/text()', res ) )[1]::TEXT  AS info,
       (xpath( 'era/feedback/summary/critical/text()', res ))[1]::TEXT AS critical_errors,
       set_config( 'test.primary_doknr', (xpath( 'era/payments/payment/items/item/inte_cashbook/deposit_no/text()', res ))[1]::TEXT, false) <> '' AS primary_doknr,
       set_config( 'test.contra_doknr', (xpath( 'era/payments/payment/items/item/inte_cashbook/deposit_no/text()', res ))[2]::TEXT, FALSE)  <> '' AS contra_doknr,
       set_config( 'test.primary_analysis_table', (xpath( 'era/payments/payment/items/item/inte_cashbook/analysis_table/text()', res ))[1]::TEXT, false) <> '' AS primary_analysis_table,
       set_config( 'test.contra_analysis_table', (xpath( 'era/payments/payment/items/item/inte_cashbook/analysis_table/text()', res ))[2]::TEXT, FALSE) <> '' AS contra_analysis_table,
       (xpath( 'era/payments/payment/transaction_type/text()', res ))[1]::TEXT AS _primary_trantype,
       (xpath( 'era/payments/payment/transaction_type/text()', res ))[2]::TEXT AS _contra_trantype
FROM a;

\echo Record posted document numbers
DO
$$
BEGIN
  EXECUTE format('select set_config(  %2$L ,doknr, false ), set_config(  %3$L, nappikode, false ) from %1$s WHERE doknr = %4$L order by mainid desc limit 1', current_setting( 'test.primary_analysis_table' ),'test.primary_doknr','test.primary_nappi_doknr', current_setting( 'test.primary_doknr' ) );
  EXECUTE format('select set_config(  %2$L ,doknr, false ), set_config(  %3$L, nappikode, false ) from %1$s WHERE doknr = %4$L order by mainid desc limit 1', current_setting( 'test.contra_analysis_table' ),'test.contra_doknr','test.contra_nappi_doknr', current_setting( 'test.contra_doknr' ) );
END;
$$;

\echo check(1) posted to correct tables (2) doknr vs nappikode

SELECT split_part( current_setting( 'test.primary_analysis_table' ), '.',2 ) AS primary_analysis_table,
       split_part( current_setting( 'test.contra_analysis_table' ), '.',2 ) AS secondary_analysis_table,
       current_setting( 'test.primary_doknr' ) = current_setting( 'test.contra_nappi_doknr' ) AS primary_doc_vs_contra_nappi,
       current_setting( 'test.primary_nappi_doknr' ) =  current_setting( 'test.contra_doknr' ) AS contra_doc_vs_primary_nappi;


\echo  TEST2.01 : reverse INTE-CASHBOOK cheque between KAS1 and KAS2 on primary cashbook side.

with a AS ( select tariffs.cj_post_xml( format( current_setting( 'test.xml_template_reversal' ) , lysglb.get_current_finperiod(1)
                                                                                           , current_setting( 'test.primary_cashbook' ) --2
                                                                                           , current_setting( 'test.contra_cashbook' ) --3
                                                                                           , current_setting( 'test.primary_transaction' )--4
                                                                                           ,  current_setting( 'test.primary_doknr' ) --5
                                                                                           , current_setting( 'test.adir') --6

                                                                                           )::xml  ) AS res )
SELECT DISTINCT jsonb_array_elements( (xpath( 'era/feedback/summary/feedback_summary/text()',res ))[1]::TEXT::JSONB )->>'code' AS feedback_summary,
       ( xpath( 'era/feedback/summary/info/text()', res ) )[1]::TEXT  AS info,
       (xpath( 'era/feedback/summary/critical/text()', res ))[1]::TEXT AS critical_errors,
       set_config( 'test.primary_doknr_reversal_p', (xpath( 'era/payments/payment/items/item/inte_cashbook/deposit_no/text()', res ))[1]::TEXT, false) <> '' AS primary_doknr_reversal_p,
       set_config( 'test.contra_doknr_reversal_p', (xpath( 'era/payments/payment/items/item/inte_cashbook/deposit_no/text()', res ))[2]::TEXT, FALSE)  <> '' AS contra_doknr_reversal_p,
       set_config( 'test.primary_analysis_table_reversal_p', (xpath( 'era/payments/payment/items/item/inte_cashbook/analysis_table/text()', res ))[1]::TEXT, false) <> '' AS primary_analysis_table_reversal_p,
       set_config( 'test.contra_analysis_table_reversal_p', (xpath( 'era/payments/payment/items/item/inte_cashbook/analysis_table/text()', res ))[2]::TEXT, FALSE) <> '' AS contra_analysis_table_reversal_p,
       (xpath( 'era/payments/payment/transaction_type/text()', res ))[1]::TEXT AS _primary_trantype,
       (xpath( 'era/payments/payment/transaction_type/text()', res ))[2]::TEXT AS _contra_trantype
       --, res
FROM a;

-- check(1)posted to correct correct tables (2) same document numbers used for corrections AS source on both tables
SELECT split_part( current_setting( 'test.primary_analysis_table_reversal_p' ), '.',2 ) AS primary_analysis_table_reversal_p,
       split_part( current_setting( 'test.contra_analysis_table_reversal_p' ), '.',2 ) AS contra_analysis_table_reversal_p,
       current_setting( 'test.primary_doknr' )=current_setting( 'test.primary_doknr_reversal_p' ) AS primary_docno_for_reversal_ok,
       current_setting( 'test.primary_nappi_doknr' )=current_setting( 'test.contra_doknr_reversal_p' ) AS contra_docno_for_reversal_ok;

\echo  TEST2.02 : reverse INTE-CASHBOOK cheque between KAS1 and KAS2 on CONTRA cashbook side. (Change trantype to -20 and switch cashbook)


with a AS ( select tariffs.cj_post_xml( format( current_setting( 'test.xml_template_reversal' ) , lysglb.get_current_finperiod(1)
                                                                                           , current_setting( 'test.contra_cashbook' ) --2
                                                                                           , current_setting( 'test.primary_cashbook' ) --3
                                                                                           , current_setting( 'test.contra_transaction' )--4
                                                                                           , current_setting( 'test.contra_doknr' )  --5
                                                                                           , current_setting( 'test.adir') --6
                                                                                           )::xml  ) AS res )
SELECT DISTINCT jsonb_array_elements( (xpath( 'era/feedback/summary/feedback_summary/text()',res ))[1]::TEXT::JSONB )->>'code' AS feedback_summary,
       ( xpath( 'era/feedback/summary/info/text()', res ) )[1]::TEXT  AS info,
       (xpath( 'era/feedback/summary/critical/text()', res ))[1]::TEXT AS critical_errors,
       set_config( 'test.primary_doknr_reversal_p', (xpath( 'era/payments/payment/items/item/inte_cashbook/deposit_no/text()', res ))[1]::TEXT, false) <> '' AS primary_doknr_reversal_p,
       set_config( 'test.contra_doknr_reversal_p', (xpath( 'era/payments/payment/items/item/inte_cashbook/deposit_no/text()', res ))[2]::TEXT, FALSE)  <> '' AS contra_doknr_reversal_p,
       set_config( 'test.primary_analysis_table_reversal_p', (xpath( 'era/payments/payment/items/item/inte_cashbook/analysis_table/text()', res ))[1]::TEXT, false) <> '' AS primary_analysis_table_reversal_p,
       set_config( 'test.contra_analysis_table_reversal_p', (xpath( 'era/payments/payment/items/item/inte_cashbook/analysis_table/text()', res ))[2]::TEXT, FALSE) <> '' AS contra_analysis_table_reversal_p,
       (xpath( 'era/payments/payment/transaction_type/text()', res ))[1]::TEXT AS _primary_trantype,
       (xpath( 'era/payments/payment/transaction_type/text()', res ))[2]::TEXT AS _contra_trantype
       --, res
FROM a;

-- check(1)correct tables (2) same document numbers used for corrections AS source on both tables
SELECT split_part( current_setting( 'test.primary_analysis_table_reversal_p' ), '.',2 ) AS primary_analysis_table_reversal_p,
       split_part( current_setting( 'test.contra_analysis_table_reversal_p' ), '.',2 ) AS contra_analysis_table_reversal_p,
       current_setting ('test.primary_nappi_doknr' )=current_setting( 'test.primary_doknr_reversal_p' ) AS primary_docno_for_reversal_ok,
       current_setting ('test.primary_doknr' )=current_setting( 'test.contra_doknr_reversal_p' ) AS contra_docno_for_reversal_ok;

---------------------------------------------------------------------------------------------------------------------------------------
\echo TEST2.1.2: Recon test - make sure that corrections cannot be posted if one of the two source transactions is flagged as reconned.
---------------------------------------------------------------------------------------------------------------------------------------
BEGIN; --recon_test_2_2
        SAVEPOINT recon_test_2_2;


        \echo TEST2.21 flag primary document as reconned
        DO
        $$
        BEGIN
            EXECUTE format(current_setting ('test.template_flag_tran_as_reconned')
                             ,replace( current_setting( 'test.primary_analysis_table' ), '_s', '_d' ) --1
                             ,current_setting( 'test.adir' ) --2
                             ,current_setting( 'test.primary_doknr' ) --3
                             ,current_setting( 'test.primary_cashbook' ) --4
                             ,current_setting( 'test.primary_transaction' ) --5
                             ,10 --6
                             ,current_setting('test.reconid') --7
                             );
        END;
        $$;
        \echo TEST2.22  Try and post correction from the primary document side (primary flagged as reconned) - should fail
        with a AS ( select tariffs.cj_post_xml( format( current_setting( 'test.xml_template_reversal' ) , lysglb.get_current_finperiod(1)
                                                                                                   , current_setting( 'test.primary_cashbook' ) --2
                                                                                                   , current_setting( 'test.contra_cashbook' ) --3
                                                                                                   , current_setting( 'test.primary_transaction' )--4
                                                                                                   ,  current_setting( 'test.primary_doknr' ) --5
                                                                                                   , current_setting( 'test.adir') --6

                                                                                                   )::xml  ) AS res )
        SELECT DISTINCT jsonb_array_elements( (xpath( 'era/feedback/summary/feedback_summary/text()',res ))[1]::TEXT::JSONB )->>'code' AS feedback_summary,
               ( xpath( 'era/feedback/summary/info/text()', res ) )[1]::TEXT  AS info,
               (xpath( 'era/feedback/summary/critical/text()', res ))[1]::TEXT AS critical_errors,
               set_config( 'test.primary_doknr_reversal_p', (xpath( 'era/payments/payment/items/item/inte_cashbook/deposit_no/text()', res ))[1]::TEXT, false) <> '' AS primary_doknr_reversal_p,
               set_config( 'test.contra_doknr_reversal_p', (xpath( 'era/payments/payment/items/item/inte_cashbook/deposit_no/text()', res ))[2]::TEXT, FALSE)  <> '' AS contra_doknr_reversal_p,
               set_config( 'test.primary_analysis_table_reversal_p', (xpath( 'era/payments/payment/items/item/inte_cashbook/analysis_table/text()', res ))[1]::TEXT, false) <> '' AS primary_analysis_table_reversal_p,
               set_config( 'test.contra_analysis_table_reversal_p', (xpath( 'era/payments/payment/items/item/inte_cashbook/analysis_table/text()', res ))[2]::TEXT, FALSE) <> '' AS contra_analysis_table_reversal_p,
               (xpath( 'era/payments/payment/transaction_type/text()', res ))[1]::TEXT AS _primary_trantype,
               (xpath( 'era/payments/payment/transaction_type/text()', res ))[2]::TEXT AS _contra_trantype
               --, res
        FROM a;


        \echo TEST2.22  Try and post correction from the contra document side (primary flagged as reconned)  - should fail
        with a AS ( select tariffs.cj_post_xml( format( current_setting( 'test.xml_template_reversal' ) , lysglb.get_current_finperiod(1)
                                                                                                   , current_setting( 'test.contra_cashbook' ) --2
                                                                                                   , current_setting( 'test.primary_cashbook' ) --3
                                                                                                   , current_setting( 'test.contra_transaction' )--4
                                                                                                   ,  current_setting( 'test.contra_doknr' ) --5
                                                                                                   , current_setting( 'test.adir') --6

                                                                                                   )::xml  ) AS res )
        SELECT DISTINCT jsonb_array_elements( (xpath( 'era/feedback/summary/feedback_summary/text()',res ))[1]::TEXT::JSONB )->>'code' AS feedback_summary,
               ( xpath( 'era/feedback/summary/info/text()', res ) )[1]::TEXT  AS info,
               (xpath( 'era/feedback/summary/critical/text()', res ))[1]::TEXT AS critical_errors,
               set_config( 'test.primary_doknr_reversal_p', (xpath( 'era/payments/payment/items/item/inte_cashbook/deposit_no/text()', res ))[1]::TEXT, false) <> '' AS primary_doknr_reversal_p,
               set_config( 'test.contra_doknr_reversal_p', (xpath( 'era/payments/payment/items/item/inte_cashbook/deposit_no/text()', res ))[2]::TEXT, FALSE)  <> '' AS contra_doknr_reversal_p,
               set_config( 'test.primary_analysis_table_reversal_p', (xpath( 'era/payments/payment/items/item/inte_cashbook/analysis_table/text()', res ))[1]::TEXT, false) <> '' AS primary_analysis_table_reversal_p,
               set_config( 'test.contra_analysis_table_reversal_p', (xpath( 'era/payments/payment/items/item/inte_cashbook/analysis_table/text()', res ))[2]::TEXT, FALSE) <> '' AS contra_analysis_table_reversal_p,
               (xpath( 'era/payments/payment/transaction_type/text()', res ))[1]::TEXT AS _primary_trantype,
               (xpath( 'era/payments/payment/transaction_type/text()', res ))[2]::TEXT AS _contra_trantype
               --, res
        FROM a;

        ROLLBACK TO recon_test_2_2;
END; --recon_test_2_2

\echo Test2.3 flag contra document as reconned,
BEGIN; --recon_test_2_3
    SAVEPOINT recon_test_2_3;

    DO
    $$
    BEGIN
        EXECUTE format(current_setting ('test.template_flag_tran_as_reconned')
                         ,replace( current_setting( 'test.contra_analysis_table' ), '_s', '_d' ) --1
                         ,current_setting( 'test.adir' ) --2
                         ,current_setting( 'test.contra_doknr' ) --3
                         ,current_setting( 'test.contra_cashbook' ) --4
                         ,current_setting( 'test.contra_transaction' ) --5
                         ,10 --6
                         ,current_setting('test.reconid') --7
                         );
    END;
    $$;


    \echo TEST2.31  Try and post correction from the contra document side (contra flagged as reconned) - should fail
    with a AS ( select tariffs.cj_post_xml( format( current_setting( 'test.xml_template_reversal' ) , lysglb.get_current_finperiod(1)
                                                                                               , current_setting( 'test.contra_cashbook' ) --2
                                                                                               , current_setting( 'test.primary_cashbook' ) --3
                                                                                               , current_setting( 'test.contra_transaction' )--4
                                                                                               ,  current_setting( 'test.contra_doknr' ) --5
                                                                                               , current_setting( 'test.adir') --6

                                                                                               )::xml  ) AS res )
    SELECT DISTINCT jsonb_array_elements( (xpath( 'era/feedback/summary/feedback_summary/text()',res ))[1]::TEXT::JSONB )->>'code' AS feedback_summary,
           ( xpath( 'era/feedback/summary/info/text()', res ) )[1]::TEXT  AS info,
           (xpath( 'era/feedback/summary/critical/text()', res ))[1]::TEXT AS critical_errors,
           set_config( 'test.primary_doknr_reversal_p', (xpath( 'era/payments/payment/items/item/inte_cashbook/deposit_no/text()', res ))[1]::TEXT, false) <> '' AS primary_doknr_reversal_p,
           set_config( 'test.contra_doknr_reversal_p', (xpath( 'era/payments/payment/items/item/inte_cashbook/deposit_no/text()', res ))[2]::TEXT, FALSE)  <> '' AS contra_doknr_reversal_p,
           set_config( 'test.primary_analysis_table_reversal_p', (xpath( 'era/payments/payment/items/item/inte_cashbook/analysis_table/text()', res ))[1]::TEXT, false) <> '' AS primary_analysis_table_reversal_p,
           set_config( 'test.contra_analysis_table_reversal_p', (xpath( 'era/payments/payment/items/item/inte_cashbook/analysis_table/text()', res ))[2]::TEXT, FALSE) <> '' AS contra_analysis_table_reversal_p,
           (xpath( 'era/payments/payment/transaction_type/text()', res ))[1]::TEXT AS _primary_trantype,
           (xpath( 'era/payments/payment/transaction_type/text()', res ))[2]::TEXT AS _contra_trantype
    FROM a;

\echo TEST2.32  Try and post correction from the primary document side (contra flagged as reconned) - should fail
    with a AS ( select tariffs.cj_post_xml( format( current_setting( 'test.xml_template_reversal' ) , lysglb.get_current_finperiod(1)
                                                                                               , current_setting( 'test.primary_cashbook' ) --2
                                                                                               , current_setting( 'test.contra_cashbook' ) --3
                                                                                               , current_setting( 'test.primary_transaction' )--4
                                                                                               ,  current_setting( 'test.primary_doknr' ) --5
                                                                                               , current_setting( 'test.adir') --6

                                                                                               )::xml  ) AS res )
    SELECT DISTINCT jsonb_array_elements( (xpath( 'era/feedback/summary/feedback_summary/text()',res ))[1]::TEXT::JSONB )->>'code' AS feedback_summary,
           ( xpath( 'era/feedback/summary/info/text()', res ) )[1]::TEXT  AS info,
           (xpath( 'era/feedback/summary/critical/text()', res ))[1]::TEXT AS critical_errors,
           set_config( 'test.primary_doknr_reversal_p', (xpath( 'era/payments/payment/items/item/inte_cashbook/deposit_no/text()', res ))[1]::TEXT, false) <> '' AS primary_doknr_reversal_p,
           set_config( 'test.contra_doknr_reversal_p', (xpath( 'era/payments/payment/items/item/inte_cashbook/deposit_no/text()', res ))[2]::TEXT, FALSE)  <> '' AS contra_doknr_reversal_p,
           set_config( 'test.primary_analysis_table_reversal_p', (xpath( 'era/payments/payment/items/item/inte_cashbook/analysis_table/text()', res ))[1]::TEXT, false) <> '' AS primary_analysis_table_reversal_p,
           set_config( 'test.contra_analysis_table_reversal_p', (xpath( 'era/payments/payment/items/item/inte_cashbook/analysis_table/text()', res ))[2]::TEXT, FALSE) <> '' AS contra_analysis_table_reversal_p,
           (xpath( 'era/payments/payment/transaction_type/text()', res ))[1]::TEXT AS _primary_trantype,
           (xpath( 'era/payments/payment/transaction_type/text()', res ))[2]::TEXT AS _contra_trantype
           --, res
    FROM a;

    ROLLBACK TO recon_test_2_3;
END;  --recon_test_2_3

---------------------------------------------------------------------------------------------------------------------------------------
\echo TEST2.4  Try and post correction to another cashbook. This must fail
---------------------------------------------------------------------------------------------------------------------------------------

BEGIN; --invalid_cashbook_test_2_4
    SAVEPOINT invalid_cashbook_test_2_4;

    \echo TEST2.31  Try and post correction from the primary document side - should fail
    with a AS ( select tariffs.cj_post_xml( format( current_setting( 'test.xml_template_reversal' ) , lysglb.get_current_finperiod(1)
                                                                                               , current_setting( 'test.primary_cashbook' ) --2
                                                                                               , 'KAS3' --3
                                                                                               , current_setting( 'test.primary_transaction' )--4
                                                                                               ,  current_setting( 'test.primary_doknr' ) --5
                                                                                               , current_setting( 'test.adir') --6

                                                                                               )::xml  ) AS res )
    SELECT DISTINCT jsonb_array_elements( (xpath( 'era/feedback/summary/feedback_summary/text()',res ))[1]::TEXT::JSONB )->>'code' AS feedback_summary,
           ( xpath( 'era/feedback/summary/info/text()', res ) )[1]::TEXT  AS info,
           (xpath( 'era/feedback/summary/critical/text()', res ))[1]::TEXT AS critical_errors,
           set_config( 'test.primary_doknr_reversal_p', (xpath( 'era/payments/payment/items/item/inte_cashbook/deposit_no/text()', res ))[1]::TEXT, false) <> '' AS primary_doknr_reversal_p,
           set_config( 'test.contra_doknr_reversal_p', (xpath( 'era/payments/payment/items/item/inte_cashbook/deposit_no/text()', res ))[2]::TEXT, FALSE)  <> '' AS contra_doknr_reversal_p,
           set_config( 'test.primary_analysis_table_reversal_p', (xpath( 'era/payments/payment/items/item/inte_cashbook/analysis_table/text()', res ))[1]::TEXT, false) <> '' AS primary_analysis_table_reversal_p,
           set_config( 'test.contra_analysis_table_reversal_p', (xpath( 'era/payments/payment/items/item/inte_cashbook/analysis_table/text()', res ))[2]::TEXT, FALSE) <> '' AS contra_analysis_table_reversal_p,
           (xpath( 'era/payments/payment/transaction_type/text()', res ))[1]::TEXT AS _primary_trantype,
           (xpath( 'era/payments/payment/transaction_type/text()', res ))[2]::TEXT AS _contra_trantype
           --, res
    FROM a;


    \echo TEST2.32  Try and post correction from the contra document side - should fail
    with a AS ( select tariffs.cj_post_xml( format( current_setting( 'test.xml_template_reversal' ) , lysglb.get_current_finperiod(1)
                                                                                               , current_setting( 'test.contra_cashbook' ) --2
                                                                                               , 'KAS3' --3
                                                                                               , current_setting( 'test.contra_transaction' )--4
                                                                                               ,  current_setting( 'test.contra_doknr' ) --5
                                                                                               , current_setting( 'test.adir') --6

                                                                                               )::xml  ) AS res )
    SELECT DISTINCT jsonb_array_elements( (xpath( 'era/feedback/summary/feedback_summary/text()',res ))[1]::TEXT::JSONB )->>'code' AS feedback_summary,
           ( xpath( 'era/feedback/summary/info/text()', res ) )[1]::TEXT  AS info,
           (xpath( 'era/feedback/summary/critical/text()', res ))[1]::TEXT AS critical_errors,
           set_config( 'test.primary_doknr_reversal_p', (xpath( 'era/payments/payment/items/item/inte_cashbook/deposit_no/text()', res ))[1]::TEXT, false) <> '' AS primary_doknr_reversal_p,
           set_config( 'test.contra_doknr_reversal_p', (xpath( 'era/payments/payment/items/item/inte_cashbook/deposit_no/text()', res ))[2]::TEXT, FALSE)  <> '' AS contra_doknr_reversal_p,
           set_config( 'test.primary_analysis_table_reversal_p', (xpath( 'era/payments/payment/items/item/inte_cashbook/analysis_table/text()', res ))[1]::TEXT, false) <> '' AS primary_analysis_table_reversal_p,
           set_config( 'test.contra_analysis_table_reversal_p', (xpath( 'era/payments/payment/items/item/inte_cashbook/analysis_table/text()', res ))[2]::TEXT, FALSE) <> '' AS contra_analysis_table_reversal_p,
           (xpath( 'era/payments/payment/transaction_type/text()', res ))[1]::TEXT AS _primary_trantype,
           (xpath( 'era/payments/payment/transaction_type/text()', res ))[2]::TEXT AS _contra_trantype
           --, res
    FROM a;




    ROLLBACK TO invalid_cashbook_test_2_4;
END;  --invalid_cashbook_test_2_4

---------------------------------------------------------------------------------------------------------------------------------------
\echo TEST2.5  Try and post correction to a non-cashbook ledger. This must fail
---------------------------------------------------------------------------------------------------------------------------------------

BEGIN; --invalid_cashbook_test_2_5
    SAVEPOINT invalid_cashbook_test_2_5;

    \echo TEST2.51  Try and post correction from the contra document side - should fail
    with a AS ( select tariffs.cj_post_xml( format( current_setting( 'test.xml_template_reversal' ) , lysglb.get_current_finperiod(1)
                                                                                               , current_setting( 'test.primary_cashbook' ) --2
                                                                                               , 'INC1' --3
                                                                                               , current_setting( 'test.primary_transaction' )--4
                                                                                               ,  current_setting( 'test.primary_doknr' ) --5
                                                                                               , current_setting( 'test.adir') --6

                                                                                               )::xml  ) AS res )
    SELECT DISTINCT jsonb_array_elements( (xpath( 'era/feedback/summary/feedback_summary/text()',res ))[1]::TEXT::JSONB )->>'code' AS feedback_summary,
           ( xpath( 'era/feedback/summary/info/text()', res ) )[1]::TEXT  AS info,
           (xpath( 'era/feedback/summary/critical/text()', res ))[1]::TEXT AS critical_errors,
           set_config( 'test.primary_doknr_reversal_p', (xpath( 'era/payments/payment/items/item/inte_cashbook/deposit_no/text()', res ))[1]::TEXT, false) <> '' AS primary_doknr_reversal_p,
           set_config( 'test.contra_doknr_reversal_p', (xpath( 'era/payments/payment/items/item/inte_cashbook/deposit_no/text()', res ))[2]::TEXT, FALSE)  <> '' AS contra_doknr_reversal_p,
           set_config( 'test.primary_analysis_table_reversal_p', (xpath( 'era/payments/payment/items/item/inte_cashbook/analysis_table/text()', res ))[1]::TEXT, false) <> '' AS primary_analysis_table_reversal_p,
           set_config( 'test.contra_analysis_table_reversal_p', (xpath( 'era/payments/payment/items/item/inte_cashbook/analysis_table/text()', res ))[2]::TEXT, FALSE) <> '' AS contra_analysis_table_reversal_p,
           (xpath( 'era/payments/payment/transaction_type/text()', res ))[1]::TEXT AS _primary_trantype,
           (xpath( 'era/payments/payment/transaction_type/text()', res ))[2]::TEXT AS _contra_trantype
           --, res
    FROM a;


    \echo TEST2.52  Try and post correction from the primary document side - should fail
    with a AS ( select tariffs.cj_post_xml( format( current_setting( 'test.xml_template_reversal' ) , lysglb.get_current_finperiod(1)
                                                                                               , current_setting( 'test.contra_cashbook' ) --2
                                                                                               , 'INC1' --3
                                                                                               , current_setting( 'test.contra_transaction' )--4
                                                                                               ,  current_setting( 'test.contra_doknr' ) --5
                                                                                               , current_setting( 'test.adir') --6

                                                                                               )::xml  ) AS res )
    SELECT DISTINCT jsonb_array_elements( (xpath( 'era/feedback/summary/feedback_summary/text()',res ))[1]::TEXT::JSONB )->>'code' AS feedback_summary,
           ( xpath( 'era/feedback/summary/info/text()', res ) )[1]::TEXT  AS info,
           (xpath( 'era/feedback/summary/critical/text()', res ))[1]::TEXT AS critical_errors,
           set_config( 'test.primary_doknr_reversal_p', (xpath( 'era/payments/payment/items/item/inte_cashbook/deposit_no/text()', res ))[1]::TEXT, false) <> '' AS primary_doknr_reversal_p,
           set_config( 'test.contra_doknr_reversal_p', (xpath( 'era/payments/payment/items/item/inte_cashbook/deposit_no/text()', res ))[2]::TEXT, FALSE)  <> '' AS contra_doknr_reversal_p,
           set_config( 'test.primary_analysis_table_reversal_p', (xpath( 'era/payments/payment/items/item/inte_cashbook/analysis_table/text()', res ))[1]::TEXT, false) <> '' AS primary_analysis_table_reversal_p,
           set_config( 'test.contra_analysis_table_reversal_p', (xpath( 'era/payments/payment/items/item/inte_cashbook/analysis_table/text()', res ))[2]::TEXT, FALSE) <> '' AS contra_analysis_table_reversal_p,
           (xpath( 'era/payments/payment/transaction_type/text()', res ))[1]::TEXT AS _primary_trantype,
           (xpath( 'era/payments/payment/transaction_type/text()', res ))[2]::TEXT AS _contra_trantype
           --, res
    FROM a;

    ROLLBACK TO invalid_cashbook_test_2_5;
END;  --invalid_cashbook_test_2_5

