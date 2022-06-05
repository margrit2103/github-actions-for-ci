\echo This test is loosely based on "tests\sql_regression\goodx.analysis_schema.sql".  It should be discontinued after merging branch 20593_analysis_file_schema
\echo references to cashbook analysis files are hard-coded and will not work after year23.

\echo Parameters: this test assumes that a goodx1 directory exists, and that at least one debtor has been created and is ready for posting. 
    SELECT set_config('test.debtor', min( fdreknr )::text, FALSE ) <> '' as debtor FROM goodx1.debmstr; 
    SELECT set_config('test.creditor', min( fdreknr )::text, FALSE ) <> '' as creditor FROM lysglb.cremstr where entity = 1; 
    SELECT set_config('test.period', lysglb.get_current_finperiod(1)::text, FALSE) <> '' as current_period; 
    SELECT set_config('test.treating_doc', mainid::text, FALSE) <> '' as treating_doc from goodx1.view_treating_docs limit 1;
    SELECT set_config('test.ref_doc', mainid::text, FALSE) <> '' as ref_doc from goodx1.view_ref_docs limit 1;
    

\echo Balancing test before tests - this is to be able to establish whether data was possibly broken before the test was run.
SELECT _ok FROM analysis_diagnostic.check_ledger_movement_totals( current_setting( 'test.period' )::INTEGER / 100 );
SELECT * FROM analysis_diagnostic.check_major_control_totals( ARRAY[1]);


\echo Post debtor invoice 
    WITH _payload AS (
        SELECT unnest( xpath( '/table/feedback/summary/feedback_summary/text()', 
                       tariffs.post_xml( format( '<table>
                                                    <global_data>
                                                        <a_id_integer>1</a_id_integer>
                                                        <delete_temp_integer>0</delete_temp_integer>
                                                        <adir_integer>1</adir_integer>
                                                        <system_user_varchar>AUTO</system_user_varchar>
                                                        <return_billing_lists_info>0</return_billing_lists_info>
                                                        <use_input_diagnosis_integer>1</use_input_diagnosis_integer>
                                                    </global_data>
                                                    <invoices>
                                                        <invoice>
                                                            <a_id_integer>1</a_id_integer>                                     
                                                            <date_date>%2$s</date_date>
                                                            <systemdate_date>%2$s</systemdate_date>
                                                            <period_integer>%1$s</period_integer>
                                                            <debtor_a_id_integer>1</debtor_a_id_integer>
                                                            <patient_a_id_integer>1</patient_a_id_integer>
                                                            <treating_doctor_a_id_integer>1</treating_doctor_a_id_integer>
                                                            <service_centre_a_id_integer>1</service_centre_a_id_integer>
                                                            <maid_option_varchar>DISC53</maid_option_varchar>
                                                            <referring_doctor_a_id_integer>2</referring_doctor_a_id_integer>
                                                            <linking_doc_varchar/>
                                                            <_3rd_party_id_varchar>00000001</_3rd_party_id_varchar>
                                                            <row>
                                                                <a_id_integer>7</a_id_integer>
                                                                <_3rd_party_id_varchar>007</_3rd_party_id_varchar>
                                                                <service_centre_a_id_integer>1</service_centre_a_id_integer>
                                                                <treating_doctor_a_id_integer>1</treating_doctor_a_id_integer>
                                                                <referring_doctor_a_id_integer>2</referring_doctor_a_id_integer>
                                                                <date_date>%2$s</date_date>
                                                                <srec_a_id_integer>1</srec_a_id_integer>
                                                                <billing_code_varchar>0190</billing_code_varchar>
                                                                <tariffcol_integer>1</tariffcol_integer>
                                                                <icdlist_varchararr>
                                                                    <element>A01.1</element>
                                                                </icdlist_varchararr>
                                                            </row>
                                                            <row>
                                                                <a_id_integer>9</a_id_integer>
                                                                <_3rd_party_id_varchar>009</_3rd_party_id_varchar>
                                                                <service_centre_a_id_integer>1</service_centre_a_id_integer>
                                                                <treating_doctor_a_id_integer>1</treating_doctor_a_id_integer>
                                                                <referring_doctor_a_id_integer>2</referring_doctor_a_id_integer>
                                                                <date_date>%2$s</date_date>
                                                                <srec_a_id_integer>1</srec_a_id_integer>
                                                                <billing_code_varchar>1478</billing_code_varchar>
                                                                <tariffcol_integer>1</tariffcol_integer>
                                                                <description_varchar>Velopharyngeal reconstruction </description_varchar>
                                                                <icdlist_varchararr>
                                                                    <element>A01.1</element>
                                                                </icdlist_varchararr>
                                                            </row>
                                                            <row>
                                                                <a_id_integer>10</a_id_integer>
                                                                <_3rd_party_id_varchar>010</_3rd_party_id_varchar>
                                                                <service_centre_a_id_integer>1</service_centre_a_id_integer>
                                                                <treating_doctor_a_id_integer>1</treating_doctor_a_id_integer>
                                                                <referring_doctor_a_id_integer>2</referring_doctor_a_id_integer>
                                                                <date_date>%2$s</date_date>
                                                                <srec_a_id_integer>1</srec_a_id_integer>
                                                                <billing_code_varchar>1477</billing_code_varchar>
                                                                <tariffcol_integer>1</tariffcol_integer>
                                                                <icdlist_varchararr>
                                                                    <element>A01.1</element>
                                                                </icdlist_varchararr>
                                                            </row>
                                                        </invoice>
                                                    </invoices>
                                                    <debtors>
                                                        <debtor>
                                                            <a_id_integer>1</a_id_integer>
                                                            <adir_integer>1</adir_integer>
                                                            <goodx_id_integer>%3$s</goodx_id_integer>
                                                        </debtor>
                                                    </debtors>
                                                    <patients>
                                                        <patient>
                                                            <a_id_integer>1</a_id_integer>
                                                            <goodx_id_integer>1</goodx_id_integer>
                                                            <debtor_a_id_integer>1</debtor_a_id_integer>
                                                            <update_existing_data_integer>0</update_existing_data_integer>
                                                        </patient>
                                                    </patients>
                                                    <doctors>
                                                        <doctor>
                                                            <a_id_integer>1</a_id_integer>
                                                            <goodx_id_integer>%4$s</goodx_id_integer>
                                                        </doctor>
                                                        <doctor>
                                                            <a_id_integer>2</a_id_integer>
                                                            <goodx_id_integer>%5$s</goodx_id_integer>
                                                        </doctor>
                                                    </doctors>
                                                    <service_centres>
                                                        <service_centre>
                                                            <a_id_integer>1</a_id_integer>
                                                            <goodx_id_integer>1</goodx_id_integer>
                                                        </service_centre>
                                                    </service_centres>
                                                </table>', current_setting( 'test.period' )::INTEGER, 
                                                           to_char( now(), 'yyyy-mm-dd' ), 
                                                           current_setting( 'test.debtor' )::INTEGER,
                                                           current_setting( 'test.treating_doc')::INTEGER,
                                                           current_setting( 'test.ref_doc') ::INTEGER
                                                           
                                                           )::XML 
                    )
                )
        )::text::jsonb AS post_invoice )
    , _answ as ( SELECT jsonb_array_elements( post_invoice )->>'code' as result FROM _payload )
    SELECT * from _answ WHERE result = 'OK100';
                        
\echo Post debtor credit note
    WITH _payload AS (
        WITH _inv AS ( SELECT invnr FROM lysglb.debfdetail ORDER BY dfdid DESC LIMIT 1 ),
             _payload AS ( SELECT format( '<table>
                                            <global_data>
                                                <a_id_integer>1</a_id_integer>
                                                <delete_temp_integer>0</delete_temp_integer>
                                                <adir_integer>1</adir_integer>
                                                <system_user_varchar>AUTO</system_user_varchar>
                                                <return_billing_lists_info>0</return_billing_lists_info>
                                                <use_input_diagnosis_integer>1</use_input_diagnosis_integer>
                                                <doc_no/>
                                            </global_data>
                                            <credit_notes>
                                                <credit_note>
                                                    <a_id_integer>1</a_id_integer>
                                                    <invnr_varchar>%3$s</invnr_varchar>
                                                    <doc_no/>
                                                    <date_date>%2$s</date_date>
                                                    <systemdate_date>%2$s</systemdate_date>
                                                    <period_integer>%1$s</period_integer>
                                                    <note_varchar>TEST</note_varchar>
                                                    <account_type_integer>3</account_type_integer>            
                                                </credit_note>
                                            </credit_notes>
                                        </table>' , current_setting( 'test.period' )::INTEGER, to_char( now(), 'yyyy-mm-dd' ) , invnr )  AS payload 
                                        FROM _inv )
        SELECT  unnest( xpath( '/table/feedback/summary/feedback_summary/text()', tariffs.post_xml(payload::XML)))::text::jsonb AS cnote FROM _payload )
    , _answ as ( SELECT jsonb_array_elements( cnote )->>'code' as result FROM _payload )
    SELECT * from _answ WHERE result = 'OK10';        

\echo Post creditor ledger invoice
    WITH _payload AS (
        SELECT unnest( xpath( '/table/feedback/summary/feedback_summary/text()', 
         tariffs.post_xml( format( '<table>
                                        <global_data>
                                            <a_id_integer>1</a_id_integer>
                                            <delete_temp_integer>0</delete_temp_integer>
                                            <adir_integer>1</adir_integer>
                                            <system_user_varchar>AUTO</system_user_varchar>
                                            <return_billing_lists_info>0</return_billing_lists_info>
                                            <use_input_diagnosis_integer>1</use_input_diagnosis_integer>
                                        </global_data>
                                        <creditors>
                                            <creditor>
                                                <a_id_integer>1</a_id_integer>
                                                <goodx_id_integer>%3$s</goodx_id_integer>
                                            </creditor>
                                        </creditors>
                                        <creditor_invoices>
                                            <creditor_invoice>
                                                <a_id_integer>1</a_id_integer>
                                                <creditor_a_id_integer>1</creditor_a_id_integer>
                                                <date_date>%2$s</date_date>
                                                <period_integer>%1$s</period_integer>
                                                <supplier_invno_varchar>%4$s</supplier_invno_varchar>
                                                <adir_integer>1</adir_integer>
                                                <cre_invtype_integer>2</cre_invtype_integer>
                                                <description_varchar/>
                                                <row>
                                                    <a_id_integer>1</a_id_integer>
                                                    <ledger_varchar>EXP4</ledger_varchar>
                                                    <qty_numeric2>1</qty_numeric2>
                                                    <amt_numeric2>13.80</amt_numeric2>
                                                    <vat_numeric2>1.80</vat_numeric2>
                                                    <description_varchar>12</description_varchar>
                                                </row>
                                                <row>
                                                    <a_id_integer>2</a_id_integer>
                                                    <ledger_varchar>INC2</ledger_varchar>
                                                    <qty_numeric2>1</qty_numeric2>
                                                    <amt_numeric2>13.80</amt_numeric2>
                                                    <vat_numeric2>1.80</vat_numeric2>
                                                    <description_varchar>1245</description_varchar>
                                                </row>
                                            </creditor_invoice>
                                        </creditor_invoices>
                                    </table>
        ', current_setting( 'test.period' )::INTEGER, to_char( now(), 'yyyy-mm-dd' ), current_setting( 'test.creditor' )::INTEGER , 'Ldgr:' || to_char( now(), 'yyyymmddhhMIss' ) )::xml
        )
        )
        )::text::jsonb AS post_invoice)
    , _answ as ( SELECT jsonb_array_elements( post_invoice )->>'code' as result FROM _payload )
    SELECT * from _answ WHERE result = 'OK101';
              
\echo Post creditor ledger cnote
    WITH _payload AS (
        WITH _inv AS ( SELECT creinvnr FROM lysglb.creopen ORDER BY mainid DESC LIMIT 1 ),
             _payload AS ( SELECT format(   '<table>
                                                <global_data>
                                                    <a_id_integer>1</a_id_integer>
                                                    <delete_temp_integer>0</delete_temp_integer>
                                                    <adir_integer>1</adir_integer>
                                                    <system_user_varchar>AUTO</system_user_varchar>
                                                    <return_billing_lists_info>0</return_billing_lists_info>
                                                    <use_input_diagnosis_integer>1</use_input_diagnosis_integer>
                                                    <doc_no/>
                                                </global_data>
                                                <credit_notes>
                                                    <credit_note>
                                                        <a_id_integer>1</a_id_integer>
                                                        <invnr_varchar>%4$s</invnr_varchar>
                                                        <doc_no/>
                                                        <date_date>%2$s</date_date>
                                                        <systemdate_date>%2$s</systemdate_date>
                                                        <period_integer>%1$s</period_integer>
                                                        <note_varchar>12134</note_varchar>
                                                        <account_type_integer>4</account_type_integer>
                                                        <row>
                                                            <a_id_integer>1</a_id_integer>
                                                            <srec_a_id_integer>1</srec_a_id_integer>
                                                            <qty_numeric2>0</qty_numeric2>
                                                            <amt_numeric2>13.8</amt_numeric2>
                                                            <billing_code_varchar>EXP4</billing_code_varchar>
                                                            <vat_numeric2>1.8</vat_numeric2>
                                                            <pat_portion_numeric2>0</pat_portion_numeric2>
                                                        </row>
                                                        <row>
                                                            <a_id_integer>2</a_id_integer>
                                                            <srec_a_id_integer>1</srec_a_id_integer>
                                                            <qty_numeric2>0</qty_numeric2>
                                                            <amt_numeric2>13.8</amt_numeric2>
                                                            <billing_code_varchar>INC2</billing_code_varchar>
                                                            <vat_numeric2>1.8</vat_numeric2>
                                                            <pat_portion_numeric2>0</pat_portion_numeric2>
                                                        </row>
                                                    </credit_note>
                                                </credit_notes>
                                            </table>
                    ', current_setting( 'test.period' )::INTEGER, to_char( now(), 'yyyy-mm-dd' ), current_setting( 'test.creditor' )::INTEGER , creinvnr )  AS payload
                    from _inv )
        SELECT  unnest( xpath( '/table/feedback/summary/feedback_summary/text()', tariffs.post_xml(payload::XML)))::text::jsonb AS cnote FROM _payload)
    , _answ as ( SELECT jsonb_array_elements( cnote )->>'code' as result FROM _payload )
    SELECT * from _answ WHERE result = 'OK10';        

\echo Post creditor stock invoice
    WITH _payload AS (
        SELECT unnest( xpath( '/table/feedback/summary/feedback_summary/text()', 
         tariffs.post_xml( format( '<table>
                                        <global_data>
                                            <a_id_integer>1</a_id_integer>
                                            <delete_temp_integer>0</delete_temp_integer>
                                            <adir_integer>1</adir_integer>
                                            <system_user_varchar>AUTO</system_user_varchar>
                                            <return_billing_lists_info>0</return_billing_lists_info>
                                            <use_input_diagnosis_integer>1</use_input_diagnosis_integer>
                                        </global_data>
                                        <creditors>
                                            <creditor>
                                                <a_id_integer>1</a_id_integer>
                                                <goodx_id_integer>%3$s</goodx_id_integer>
                                            </creditor>
                                        </creditors>
                                        <creditor_invoices>
                                            <creditor_invoice>
                                                <a_id_integer>1</a_id_integer>
                                                <creditor_a_id_integer>1</creditor_a_id_integer>
                                                <date_date>%2$s</date_date>
                                                <period_integer>%1$s</period_integer>
                                                <supplier_invno_varchar>%4$s</supplier_invno_varchar>
                                                <adir_integer>1</adir_integer>
                                                <cre_invtype_integer>1</cre_invtype_integer>
                                                <delivery_crenr_integer>0</delivery_crenr_integer>
                                                <supplier_ordnr_varchar/>
                                                <row>
                                                    <a_id_integer>1</a_id_integer>
                                                    <ledger_varchar>CAS2</ledger_varchar>
                                                    <qty_numeric2>1.00</qty_numeric2>
                                                    <amt_numeric2>795.34</amt_numeric2>
                                                    <vat_numeric2>103.74</vat_numeric2>
                                                    <description_varchar>DRILL BIT 1.1MM 310113 CSM  31</description_varchar>
                                                    <billing_code_varchar>02010060</billing_code_varchar>
                                                    <warehouse_goodx_id_integer>1</warehouse_goodx_id_integer>
                                                    <bin_goodx_id_integer>1</bin_goodx_id_integer>
                                                    <last_pprice_mode_integer>1</last_pprice_mode_integer>
                                                </row>
                                                <row>
                                                    <a_id_integer>2</a_id_integer>
                                                    <ledger_varchar>CAS2</ledger_varchar>
                                                    <qty_numeric2>100.00</qty_numeric2>
                                                    <amt_numeric2>87.53</amt_numeric2>
                                                    <vat_numeric2>11.42</vat_numeric2>
                                                    <description_varchar>HYDROQUINONE PDR   100 G</description_varchar>
                                                    <billing_code_varchar>GMED7497</billing_code_varchar>
                                                    <warehouse_goodx_id_integer>1</warehouse_goodx_id_integer>
                                                    <bin_goodx_id_integer>1</bin_goodx_id_integer>
                                                    <last_pprice_mode_integer>1</last_pprice_mode_integer>
                                                </row>
                                            </creditor_invoice>
                                        </creditor_invoices>
                                    </table>'
                                    , current_setting( 'test.period' )::INTEGER, to_char( now(), 'yyyy-mm-dd' ), current_setting( 'test.creditor' )::INTEGER , 'Stk:'|| to_char( now(), 'yyyymmddhhMIss' ) )::xml
                )
            )
        )::text::jsonb AS post_invoice)
    , _answ as ( SELECT jsonb_array_elements( post_invoice )->>'code' as result FROM _payload )
    SELECT * from _answ WHERE result = 'OK101';

\echo Post creditor stock cnote
    WITH _payload AS (
        WITH _inv AS ( SELECT creinvnr FROM lysglb.creopen ORDER BY mainid DESC LIMIT 1 ),
             _payload AS ( SELECT format( ' <table>
                                                <global_data>
                                                    <a_id_integer>1</a_id_integer>
                                                    <delete_temp_integer>0</delete_temp_integer>
                                                    <adir_integer>1</adir_integer>
                                                    <system_user_varchar>AUTO</system_user_varchar>
                                                    <return_billing_lists_info>0</return_billing_lists_info>
                                                    <use_input_diagnosis_integer>1</use_input_diagnosis_integer>
                                                    <doc_no/>
                                                </global_data>
                                                <credit_notes>
                                                    <credit_note>
                                                        <a_id_integer>1</a_id_integer>
                                                        <invnr_varchar>%4$s</invnr_varchar>
                                                        <doc_no/>
                                                        <date_date>%2$s</date_date>
                                                        <systemdate_date>%2$s</systemdate_date>
                                                        <period_integer>%1$s</period_integer>
                                                        <note_varchar>TES</note_varchar>
                                                        <account_type_integer>4</account_type_integer>
                                                        <row>
                                                            <a_id_integer>1</a_id_integer>
                                                            <srec_a_id_integer>1</srec_a_id_integer>
                                                            <qty_numeric2>1</qty_numeric2>
                                                            <amt_numeric2>0</amt_numeric2>
                                                            <billing_code_varchar>02010060</billing_code_varchar>
                                                            <vat_numeric2>0</vat_numeric2>
                                                            <pat_portion_numeric2>0</pat_portion_numeric2>
                                                        </row>
                                                        <row>
                                                            <a_id_integer>2</a_id_integer>
                                                            <srec_a_id_integer>1</srec_a_id_integer>
                                                            <qty_numeric2>100</qty_numeric2>
                                                            <amt_numeric2>0</amt_numeric2>
                                                            <billing_code_varchar>001C</billing_code_varchar>
                                                            <vat_numeric2>0</vat_numeric2>
                                                            <pat_portion_numeric2>0</pat_portion_numeric2>
                                                        </row>
                                                    </credit_note>
                                                </credit_notes>
                                            </table>
                    ', current_setting( 'test.period' )::INTEGER, to_char( now(), 'yyyy-mm-dd' ), current_setting( 'test.creditor' )::INTEGER , creinvnr )  AS payload
                    from _inv )
        SELECT  unnest( xpath( '/table/feedback/summary/feedback_summary/text()', tariffs.post_xml(payload::XML)))::text::jsonb AS cnote FROM _payload)
    , _answ as ( SELECT jsonb_array_elements( cnote )->>'code' as result FROM _payload )
    SELECT * from _answ WHERE result = 'OK10';

\echo Post journal: Ledgers
    SELECT unnest( xpath( '/era/feedback/summary/feedback_summary/text()',
                  tariffs.cj_post_xml( format(  '<era>
                                                    <header>
                                                        <a_id_integer>1</a_id_integer>
                                                        <global>
                                                            <adir_integer>1</adir_integer>
                                                            <user>AUTO</user>
                                                        </global>
                                                    </header>
                                                    <journals>
                                                        <journal>
                                                            <a_id_integer>1</a_id_integer>
                                                            <date>%2$s</date>
                                                            <description>TEST</description>
                                                            <ref_no>00000001</ref_no>
                                                            <jnl_match>8666</jnl_match>
                                                            <jnl_type>T</jnl_type>
                                                            <period_integer>%1$s</period_integer>
                                                            <payer/>
                                                            <entry>
                                                                <a_id_integer>1</a_id_integer>
                                                                <pma_no_d>INC1</pma_no_d>
                                                                <description>TEST</description>
                                                                <jnl_action/>
                                                                <amount>12</amount>
                                                                <vat>1.57</vat>
                                                            </entry>
                                                            <entry>
                                                                <a_id_integer>2</a_id_integer>
                                                                <pma_no_c>INC2</pma_no_c>
                                                                <description>CREDIT JOURNAL</description>
                                                                <jnl_action/>
                                                                <amount>12</amount>
                                                                <vat>1.57</vat>
                                                            </entry>
                                                        </journal>
                                                    </journals>
                                                </era>'  
                , current_setting( 'test.period' )::INTEGER, to_char( now(), 'yyyy-mm-dd' ) )::XML 
                                     )
                    )        
             )::text::jsonb AS post_jnl;

\echo Post journal: Debtor
    WITH _debinfo AS ( SELECT reknr, invnr FROM lysglb.vdebopen WHERE postp = 'I'  ORDER BY doid DESC LIMIT 1)
    SELECT unnest( xpath( '/era/feedback/summary/feedback_summary/text()',
                  tariffs.cj_post_xml( format(  '<era>
                                                    <header>
                                                        <a_id_integer>1</a_id_integer>
                                                        <global>
                                                            <adir_integer>1</adir_integer>
                                                            <user>AUTO</user>
                                                        </global>
                                                    </header>
                                                    <journals>
                                                        <journal>
                                                            <a_id_integer>1</a_id_integer>
                                                            <date>%2$s</date>
                                                            <description>TEST</description>
                                                            <ref_no>00000003</ref_no>
                                                            <jnl_match>8666</jnl_match>
                                                            <jnl_type>T</jnl_type>
                                                            <period_integer>%1$s</period_integer>
                                                            <payer>M</payer>
                                                            <entry>
                                                                <a_id_integer>1</a_id_integer>
                                                                <pma_no_d>%4$s</pma_no_d>
                                                                <description>TEST</description>
                                                                <jnl_action/>
                                                                <goodx_itemnr>1</goodx_itemnr>
                                                                <amount>500</amount>
                                                                <goodx_invnr>%3$s</goodx_invnr>
                                                            </entry>
                                                            <entry>
                                                                <a_id_integer>2</a_id_integer>
                                                                <pma_no_c>INC1</pma_no_c>
                                                                <description>TEST</description>
                                                                <jnl_action/>
                                                                <amount>500</amount>
                                                                <vat>65.22</vat>
                                                            </entry>
                                                        </journal>
                                                    </journals>
                                                </era>
                                                '  
                , current_setting( 'test.period' )::INTEGER, to_char( now(), 'yyyy-mm-dd' ), invnr, reknr )::XML 
                                     )
                    )        
             )::text::jsonb AS post_jnl
    FROM _debinfo;

\echo Post journal: Creditor
    WITH _creinfo AS ( select creinvnr, crenr, supplier_invnr from lysglb.creopen order by mainid desc limit 1)
    SELECT  unnest( xpath( '/era/feedback/summary/feedback_summary/text()',
                  tariffs.cj_post_xml( format(  '<era>
                                                    <header>
                                                        <a_id_integer>1</a_id_integer>
                                                        <global>
                                                            <adir_integer>1</adir_integer>
                                                            <user>AUTO</user>
                                                        </global>
                                                    </header>
                                                    <journals>
                                                        <journal>
                                                            <a_id_integer>1</a_id_integer>
                                                            <date>%2$s</date>
                                                            <description>CRE JOURNAL TEST</description>
                                                            <ref_no>00000011</ref_no>
                                                            <jnl_match>8666</jnl_match>
                                                            <jnl_type>T</jnl_type>
                                                            <period_integer>%1$s</period_integer>
                                                            <payer>M</payer>
                                                            <entry>
                                                                <a_id_integer>1</a_id_integer>
                                                                <pma_no_c>CRE%4$s</pma_no_c>
                                                                <description>%5$s</description>
                                                                <jnl_action/>
                                                                <amount>100</amount>
                                                                <goodx_itemnr>1</goodx_itemnr>
                                                                <goodx_invnr>%3$s</goodx_invnr>
                                                            </entry>
                                                            <entry>
                                                                <a_id_integer>2</a_id_integer>
                                                                <pma_no_d>INC1</pma_no_d>
                                                                <description>Stk:20210824094400</description>
                                                                <jnl_action/>
                                                                <amount>100</amount>
                                                                <vat>13.04</vat>
                                                            </entry>
                                                        </journal>
                                                    </journals>
                                                </era>
                                                '  
                , current_setting( 'test.period' )::INTEGER, to_char( now(), 'yyyy-mm-dd' ), creinvnr, crenr, supplier_invnr)::XML 
                                     )
                    )        
             )::text::jsonb 
           AS post_jnl
    FROM _creinfo;

\echo Post deposit to ledger
    SELECT jsonb_array_elements( unnest( xpath( '/era/feedback/summary/feedback_summary/text()', 
                   tariffs.cj_post_xml( format( '<era>
                                                    <header>
                                                        <a_id_integer>1</a_id_integer>
                                                        <delete_temp_integer>0</delete_temp_integer>
                                                        <global>
                                                            <adir_integer>1</adir_integer>
                                                            <period_integer>%1$s</period_integer>
                                                            <user>AUTO</user>
                                                        </global>
                                                        <funder>
                                                            <name>DEP 1 </name>
                                                        </funder>
                                                        <reference_nos>
                                                            <goodx_cashbook>KAS1</goodx_cashbook>
                                                            <goodx_deposit_no/>
                                                            <bank_payment>INC1</bank_payment>
                                                        </reference_nos>
                                                        <bank_deposit>
                                                            <bank_details>
                                                                <branch_code/>
                                                                <bank_name/>
                                                                <payer>S</payer>
                                                            </bank_details>
                                                            <transaction>
                                                                <paid_amount>113</paid_amount>
                                                                <date_time>%2$s</date_time>
                                                            </transaction>
                                                        </bank_deposit>
                                                    </header>
                                                    <payments>
                                                        <payment>
                                                            <a_id_integer>1</a_id_integer>
                                                            <transaction_type>20</transaction_type>
                                                            <items>
                                                                <item>
                                                                    <a_id_integer>1</a_id_integer>
                                                                    <ledger>INC1</ledger>
                                                                    <paid_to_provider_amt>113</paid_to_provider_amt>
                                                                    <vat>14.74</vat>
                                                                    <payment_method>0</payment_method>
                                                                </item>
                                                            </items>
                                                        </payment>
                                                    </payments>
                                                </era>
    ', current_setting( 'test.period' )::INTEGER, to_char( now(), 'yyyy-mm-dd' ) )::XML 
                )
            )
    )::text::jsonb )->>'code' AS post_deposit;  


\echo Post correction on ledger deposit
    WITH _traninfo AS ( select docnr from lysglb.cashoop order by coid desc limit 1),
        _payload AS ( select format( ' <era>
                                            <header>
                                                <a_id_integer>1</a_id_integer>
                                                <delete_temp_integer>0</delete_temp_integer>
                                                <global>
                                                    <adir_integer>1</adir_integer>
                                                    <period_integer>%1$s</period_integer>
                                                    <user>AUTO</user>
                                                </global>
                                                <funder>
                                                    <name/>
                                                </funder>
                                                <reference_nos>
                                                    <goodx_cashbook>KAS1</goodx_cashbook>
                                                    <goodx_deposit_no>%3$s</goodx_deposit_no>
                                                    <bank_payment/>
                                                </reference_nos>
                                                <bank_deposit>
                                                    <bank_details>
                                                        <branch_code/>
                                                        <bank_name>TEST</bank_name>
                                                        <payer> </payer>
                                                    </bank_details>
                                                    <transaction>
                                                        <paid_amount>200</paid_amount>
                                                        <date_time>%2$s</date_time>
                                                    </transaction>
                                                </bank_deposit>
                                            </header>
                                            <payments>
                                                <payment>
                                                    <a_id_integer>1</a_id_integer>
                                                    <transaction_type>-20</transaction_type>
                                                    <items>
                                                        <item>
                                                            <a_id_integer>1</a_id_integer>
                                                            <ledger>INC2</ledger>
                                                            <paid_to_provider_amt>200</paid_to_provider_amt>
                                                            <vat>26.09</vat>
                                                            <payment_method>1</payment_method>
                                                        </item>
                                                    </items>
                                                </payment>
                                            </payments>
                                        </era>
                                    ',  current_setting( 'test.period' )::INTEGER, to_char( now(), 'yyyy-mm-dd' ) , docnr )::XML as payload
                    
                            from _traninfo
                             )
    SELECT  jsonb_array_elements( unnest( xpath( '/era/feedback/summary/feedback_summary/text()', tariffs.cj_post_xml(payload::XML)))::text::jsonb ) ->>'code' AS deposit_correction FROM _payload;                    
    

\echo Post cheque to ledger
    SELECT jsonb_array_elements( unnest( xpath( '/era/feedback/summary/feedback_summary/text()', 
                   tariffs.cj_post_xml( format( '<era>
                                                    <header>
                                                        <a_id_integer>1</a_id_integer>
                                                        <delete_temp_integer>0</delete_temp_integer>
                                                        <global>
                                                            <adir_integer>1</adir_integer>
                                                            <period_integer>%1$s</period_integer>
                                                            <user>AUTO</user>
                                                        </global>
                                                        <funder>
                                                            <name>CHQ 1 </name>
                                                        </funder>
                                                        <reference_nos>
                                                            <goodx_cashbook>KAS1</goodx_cashbook>
                                                            <goodx_deposit_no/>
                                                            <bank_payment>INC1</bank_payment>
                                                        </reference_nos>
                                                        <bank_deposit>
                                                            <bank_details>
                                                                <branch_code/>
                                                                <bank_name/>
                                                                <payer>S</payer>
                                                            </bank_details>
                                                            <transaction>
                                                                <paid_amount>113</paid_amount>
                                                                <date_time>%2$s</date_time>
                                                            </transaction>
                                                        </bank_deposit>
                                                    </header>
                                                    <payments>
                                                        <payment>
                                                            <a_id_integer>1</a_id_integer>
                                                            <transaction_type>30</transaction_type>
                                                            <items>
                                                                <item>
                                                                    <a_id_integer>1</a_id_integer>
                                                                    <ledger>EXP1</ledger>
                                                                    <paid_to_provider_amt>113</paid_to_provider_amt>
                                                                    <vat>14.74</vat>
                                                                    <payment_method>0</payment_method>
                                                                </item>
                                                            </items>
                                                        </payment>
                                                    </payments>
                                                </era>
    ', current_setting( 'test.period' )::INTEGER, to_char( now(), 'yyyy-mm-dd' ) )::XML 
                )
            )
    )::text::jsonb )->>'code' AS post_cheque;  


\echo Post correction on ledger cheque
    WITH _traninfo AS ( select docnr from lysglb.cashoop order by coid desc limit 1),
        _payload AS ( select format( ' <era>
                                            <header>
                                                <a_id_integer>1</a_id_integer>
                                                <delete_temp_integer>0</delete_temp_integer>
                                                <global>
                                                    <adir_integer>1</adir_integer>
                                                    <period_integer>%1$s</period_integer>
                                                    <user>AUTO</user>
                                                </global>
                                                <funder>
                                                    <name/>
                                                </funder>
                                                <reference_nos>
                                                    <goodx_cashbook>KAS1</goodx_cashbook>
                                                    <goodx_deposit_no>%3$s</goodx_deposit_no>
                                                    <bank_payment/>
                                                </reference_nos>
                                                <bank_deposit>
                                                    <bank_details>
                                                        <branch_code/>
                                                        <bank_name>TEST</bank_name>
                                                        <payer> </payer>
                                                    </bank_details>
                                                    <transaction>
                                                        <paid_amount>200</paid_amount>
                                                        <date_time>%2$s</date_time>
                                                    </transaction>
                                                </bank_deposit>
                                            </header>
                                            <payments>
                                                <payment>
                                                    <a_id_integer>1</a_id_integer>
                                                    <transaction_type>-30</transaction_type>
                                                    <items>
                                                        <item>
                                                            <a_id_integer>1</a_id_integer>
                                                            <ledger>INC2</ledger>
                                                            <paid_to_provider_amt>200</paid_to_provider_amt>
                                                            <vat>26.09</vat>
                                                            <payment_method>1</payment_method>
                                                        </item>
                                                    </items>
                                                </payment>
                                            </payments>
                                        </era>
                                    ',  current_setting( 'test.period' )::INTEGER, to_char( now(), 'yyyy-mm-dd' ) , docnr )::XML as payload
                    
                            from _traninfo                                
                             )                         
    SELECT  jsonb_array_elements( unnest( xpath( '/era/feedback/summary/feedback_summary/text()', tariffs.cj_post_xml(payload::XML)))::text::jsonb ) ->>'code' AS cheque_correction FROM _payload;                    

\echo Post receipt (deposit) on debtor invoice
    WITH _inv AS ( SELECT reknr, invnr FROM lysglb.vdebopen where postp ='I' ORDER BY doid DESC LIMIT 1  ),
         _payload as ( SELECT format(  '<era>
                                            <header>
                                                <a_id_integer>1</a_id_integer>
                                                <delete_temp_integer>0</delete_temp_integer>
                                                <global>
                                                    <adir_integer>1</adir_integer>
                                                    <period_integer>%1$s</period_integer>
                                                    <user>AUTO</user>
                                                </global>
                                                <funder>
                                                    <name/>
                                                </funder>
                                                <reference_nos>
                                                    <goodx_cashbook>KAS1</goodx_cashbook>
                                                    <goodx_deposit_no/>
                                                    <bank_payment/>
                                                </reference_nos>
                                                <bank_deposit>
                                                    <bank_details>
                                                        <branch_code/>
                                                        <bank_name/>
                                                        <payer>M</payer>
                                                    </bank_details>
                                                    <transaction>
                                                        <paid_amount>12</paid_amount>
                                                        <date_time>%2$s</date_time>
                                                    </transaction>
                                                </bank_deposit>
                                            </header>
                                            <payments>
                                                <payment>
                                                    <a_id_integer>1</a_id_integer>
                                                    <transaction_type>25</transaction_type>
                                                    <items>
                                                        <item>
                                                            <a_id_integer>1</a_id_integer>
                                                            <apply_payment_to>M</apply_payment_to>
                                                            <goodx_invnr>%3$s</goodx_invnr>
                                                            <goodx_itemnr>1</goodx_itemnr>
                                                            <item_match>72</item_match>
                                                            <paid_to_provider_amt>12</paid_to_provider_amt>
                                                            <payment_method>1</payment_method>
                                                            <vat>0</vat>
                                                        </item>
                                                    </items>
                                                    <member>
                                                        <pma_no>%4$s</pma_no>
                                                    </member>
                                                </payment>
                                            </payments>
                                        </era>'
                , current_setting( 'test.period' )::INTEGER, to_char( now(), 'yyyy-mm-dd' ), invnr, reknr )::XML  as payload
                FROM _inv
                                     )
    SELECT  jsonb_array_elements( unnest( xpath( '/era/feedback/summary/feedback_summary/text()', tariffs.cj_post_xml(payload::XML)))::text::jsonb ) ->>'code' AS debtor_deposit FROM _payload;                                          


\echo Reverse receipt (deposit) on debtor invoice: too much
    WITH _inv AS ( select doknr as deposit_no, dokcre as turnover_source_doc, reknr as _debtor, splitnr  from year23.dep1_s order by mainid desc limit 1 ),
         _payload as ( SELECT format(  '<era>
                                            <header>
                                                <a_id_integer>1</a_id_integer>
                                                <delete_temp_integer>0</delete_temp_integer>
                                                <global>
                                                    <adir_integer>1</adir_integer>
                                                    <period_integer>%1$s</period_integer>
                                                    <user>AUTO</user>
                                                </global>
                                                <funder>
                                                    <name/>
                                                </funder>
                                                <reference_nos>
                                                    <goodx_cashbook>KAS1</goodx_cashbook>
                                                     <goodx_deposit_no>%5$s</goodx_deposit_no>
                                                    <goodx_deposit_no/>
                                                    <bank_payment/>
                                                </reference_nos>
                                                <bank_deposit>
                                                    <bank_details>
                                                        <branch_code/>
                                                        <bank_name/>
                                                        <payer>M</payer>
                                                    </bank_details>
                                                    <transaction>
                                                        <paid_amount>24</paid_amount>
                                                        <date_time>%2$s</date_time>
                                                    </transaction>
                                                </bank_deposit>
                                            </header>
                                            <payments>
                                                <payment>
                                                    <a_id_integer>1</a_id_integer>
                                                    <transaction_type>-25</transaction_type>
                                                    <doknr>%6$s</doknr>
                                                    <items>
                                                        <item>
                                                            <a_id_integer>1</a_id_integer>
                                                            <apply_payment_to>M</apply_payment_to>
                                                            <goodx_invnr>%3$s</goodx_invnr>
                                                            <goodx_itemnr>1</goodx_itemnr>
                                                            <item_match>72</item_match>
                                                            <paid_to_provider_amt>24</paid_to_provider_amt>
                                                            <payment_method>1</payment_method>
                                                            <vat>0</vat>
                                                        </item>
                                                    </items>
                                                    <member>
                                                        <pma_no>%4$s</pma_no>
                                                    </member>
                                                </payment>
                                            </payments>
                                        </era>'
                , current_setting( 'test.period' )::INTEGER, to_char( now(), 'yyyy-mm-dd' ), turnover_source_doc, _debtor,deposit_no, splitnr )::XML  as payload
                FROM _inv
            )
    SELECT  jsonb_array_elements( unnest( xpath( '/era/feedback/summary/feedback_summary/text()', tariffs.cj_post_xml(payload::XML)))::text::jsonb ) ->>'code' AS debtor_deposit_wb FROM _payload;                                          


\echo Add to receipt (deposit) on debtor invoice
    WITH _inv AS ( select doknr as deposit_no, dokcre as turnover_source_doc, reknr as _debtor, splitnr  from year23.dep1_s order by mainid desc limit 1  ),
         _payload as ( SELECT format(  '<era>
                                            <header>
                                                <a_id_integer>1</a_id_integer>
                                                <delete_temp_integer>0</delete_temp_integer>
                                                <global>
                                                    <adir_integer>1</adir_integer>
                                                    <period_integer>%1$s</period_integer>
                                                    <user>AUTO</user>
                                                </global>
                                                <funder>
                                                    <name/>
                                                </funder>
                                                <reference_nos>
                                                    <goodx_cashbook>KAS1</goodx_cashbook>
                                                     <goodx_deposit_no>%5$s</goodx_deposit_no>
                                                    <goodx_deposit_no/>
                                                    <bank_payment/>
                                                </reference_nos>
                                                <bank_deposit>
                                                    <bank_details>
                                                        <branch_code/>
                                                        <bank_name/>
                                                        <payer>M</payer>
                                                    </bank_details>
                                                    <transaction>
                                                        <paid_amount>-12</paid_amount>
                                                        <date_time>%2$s</date_time>
                                                    </transaction>
                                                </bank_deposit>
                                            </header>
                                            <payments>
                                                <payment>
                                                    <a_id_integer>1</a_id_integer>
                                                    <transaction_type>-25</transaction_type>
                                                    <doknr>%6$s</doknr>
                                                    <items>
                                                        <item>
                                                            <a_id_integer>1</a_id_integer>
                                                            <apply_payment_to>M</apply_payment_to>
                                                            <goodx_invnr>%3$s</goodx_invnr>
                                                            <goodx_itemnr>1</goodx_itemnr>
                                                            <item_match>72</item_match>
                                                            <paid_to_provider_amt>-12</paid_to_provider_amt>
                                                            <payment_method>1</payment_method>
                                                            <vat>0</vat>
                                                        </item>
                                                    </items>
                                                    <member>
                                                        <pma_no>%4$s</pma_no>
                                                    </member>
                                                </payment>
                                            </payments>
                                        </era>'
                , current_setting( 'test.period' )::INTEGER, to_char( now(), 'yyyy-mm-dd' ), turnover_source_doc, _debtor,deposit_no, splitnr )::XML  as payload
                FROM _inv
            )
    SELECT  jsonb_array_elements( unnest( xpath( '/era/feedback/summary/feedback_summary/text()', tariffs.cj_post_xml(payload::XML)))::text::jsonb ) ->>'code' AS debtor_deposit_wb FROM _payload;                                          


\echo Post payment (cheque) on creditor invoice
WITH _inv AS ( select creinvnr, crenr, supplier_invnr from lysglb.creopen order by mainid desc limit 1 ),
      _payload as ( SELECT format(  '<era>
                                            <header>
                                                <a_id_integer>1</a_id_integer>
                                                <delete_temp_integer>0</delete_temp_integer>
                                                <global>
                                                    <adir_integer>1</adir_integer>
                                                    <period_integer>%1$s</period_integer>
                                                    <user>AUTO</user>
                                                </global>
                                                <funder>
                                                    <name/>
                                                </funder>
                                                <reference_nos>
                                                    <goodx_cashbook>KAS1</goodx_cashbook>
                                                    <goodx_deposit_no/>
                                                    <bank_payment/>
                                                </reference_nos>
                                                <bank_deposit>
                                                    <bank_details>
                                                        <branch_code/>
                                                        <bank_name/>
                                                        <payer>S</payer>
                                                    </bank_details>
                                                    <transaction>
                                                        <paid_amount>1992</paid_amount>
                                                        <date_time>%2sS</date_time>
                                                    </transaction>
                                                </bank_deposit>
                                            </header>
                                            <payments>
                                                <payment>
                                                    <a_id_integer>1</a_id_integer>
                                                    <transaction_type>35</transaction_type>
                                                    <items>
                                                        <item>
                                                            <a_id_integer>1</a_id_integer>
                                                            <goodx_invnr>%3$s</goodx_invnr>
                                                            <paid_to_provider_amt>1992</paid_to_provider_amt>
                                                            <vat>0</vat>
                                                            <payment_method>0</payment_method>
                                                            <item_match>72</item_match>
                                                        </item>
                                                    </items>
                                                    <member>
                                                        <pma_no>CRE%4$s</pma_no>
                                                    </member>
                                                </payment>
                                            </payments>
                                        </era>' 
                                        , current_setting( 'test.period' )::INTEGER, to_char( now(), 'yyyy-mm-dd' ), creinvnr, crenr )::XML  as payload
                  
                                        from _inv)
                                        
SELECT  jsonb_array_elements( unnest( xpath( '/era/feedback/summary/feedback_summary/text()', tariffs.cj_post_xml(payload::XML)))::text::jsonb ) ->>'code' AS creditor_payment FROM _payload;                                          

\echo Reverse payment (cheque) on creditor invoice
    WITH _inv AS ( select doknr as transaction_no, dokcre as turnover_source_doc, reknr as _pma_no, splitnr  from year23.chq1_s order by mainid desc limit 1  ),
         _payload as ( SELECT format(  '<era>
                                            <header>
                                                <a_id_integer>1</a_id_integer>
                                                <delete_temp_integer>0</delete_temp_integer>
                                                <global>
                                                    <adir_integer>1</adir_integer>
                                                    <period_integer>%1$s</period_integer>
                                                    <user>AUTO</user>
                                                </global>
                                                <funder>
                                                    <name/>
                                                </funder>
                                                <reference_nos>
                                                    <goodx_cashbook>KAS1</goodx_cashbook>
                                                     <goodx_deposit_no>%5$s</goodx_deposit_no>
                                                    <goodx_deposit_no/>
                                                    <bank_payment/>
                                                </reference_nos>
                                                <bank_deposit>
                                                    <bank_details>
                                                        <branch_code/>
                                                        <bank_name/>
                                                        <payer>M</payer>
                                                    </bank_details>
                                                    <transaction>
                                                        <paid_amount>36</paid_amount>
                                                        <date_time>%2$s</date_time>
                                                    </transaction>
                                                </bank_deposit>
                                            </header>
                                            <payments>
                                                <payment>
                                                    <a_id_integer>1</a_id_integer>
                                                    <transaction_type>-35</transaction_type>
                                                    <doknr>%6$s</doknr>
                                                    <items>
                                                        <item>
                                                            <a_id_integer>1</a_id_integer>
                                                            <apply_payment_to>M</apply_payment_to>
                                                            <goodx_invnr>%3$s</goodx_invnr>
                                                            <goodx_itemnr>1</goodx_itemnr>
                                                            <item_match>72</item_match>
                                                            <paid_to_provider_amt>36</paid_to_provider_amt>
                                                            <payment_method>1</payment_method>
                                                            <vat>0</vat>
                                                        </item>
                                                    </items>
                                                    <member>
                                                        <pma_no>%4$s</pma_no>
                                                    </member>
                                                </payment>
                                            </payments>
                                        </era>'
                , current_setting( 'test.period' )::INTEGER, to_char( now(), 'yyyy-mm-dd' ), turnover_source_doc, _pma_no,transaction_no, splitnr )::XML  as payload
                FROM _inv
            )
    SELECT  jsonb_array_elements( unnest( xpath( '/era/feedback/summary/feedback_summary/text()', tariffs.cj_post_xml(payload::XML)))::text::jsonb ) ->>'code' AS cre_deposit_wb FROM _payload;                                          

\echo Add payment (cheque) on creditor invoice
    WITH _inv AS ( select doknr as transaction_no, dokcre as turnover_source_doc, reknr as _pma_no, splitnr  from year23.chq1_s order by mainid desc limit 1 ),
         _payload as ( SELECT format(  '<era>
                                            <header>
                                                <a_id_integer>1</a_id_integer>
                                                <delete_temp_integer>0</delete_temp_integer>
                                                <global>
                                                    <adir_integer>1</adir_integer>
                                                    <period_integer>%1$s</period_integer>
                                                    <user>AUTO</user>
                                                </global>
                                                <funder>
                                                    <name/>
                                                </funder>
                                                <reference_nos>
                                                    <goodx_cashbook>KAS1</goodx_cashbook>
                                                     <goodx_deposit_no>%5$s</goodx_deposit_no>
                                                    <goodx_deposit_no/>
                                                    <bank_payment/>
                                                </reference_nos>
                                                <bank_deposit>
                                                    <bank_details>
                                                        <branch_code/>
                                                        <bank_name/>
                                                        <payer>M</payer>
                                                    </bank_details>
                                                    <transaction>
                                                        <paid_amount>-24</paid_amount>
                                                        <date_time>%2$s</date_time>
                                                    </transaction>
                                                </bank_deposit>
                                            </header>
                                            <payments>
                                                <payment>
                                                    <a_id_integer>1</a_id_integer>
                                                    <transaction_type>-35</transaction_type>
                                                    <doknr>%6$s</doknr>
                                                    <items>
                                                        <item>
                                                            <a_id_integer>1</a_id_integer>
                                                            <apply_payment_to>M</apply_payment_to>
                                                            <goodx_invnr>%3$s</goodx_invnr>
                                                            <goodx_itemnr>1</goodx_itemnr>
                                                            <item_match>72</item_match>
                                                            <paid_to_provider_amt>-24</paid_to_provider_amt>
                                                            <payment_method>1</payment_method>
                                                            <vat>0</vat>
                                                        </item>
                                                    </items>
                                                    <member>
                                                        <pma_no>%4$s</pma_no>
                                                    </member>
                                                </payment>
                                            </payments>
                                        </era>'
                , current_setting( 'test.period' )::INTEGER, to_char( now(), 'yyyy-mm-dd' ), turnover_source_doc, _pma_no,transaction_no, splitnr )::XML  as payload
                FROM _inv
            )
    SELECT  jsonb_array_elements( unnest( xpath( '/era/feedback/summary/feedback_summary/text()', tariffs.cj_post_xml(payload::XML)))::text::jsonb ) ->>'code' AS cre_deposit_wb FROM _payload;                                          

\echo Balancing test after tests 
SELECT _ok FROM analysis_diagnostic.check_ledger_movement_totals( current_setting( 'test.period' )::INTEGER / 100 );
SELECT * FROM analysis_diagnostic.check_major_control_totals( ARRAY[1]);
