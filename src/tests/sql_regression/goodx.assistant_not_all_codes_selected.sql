    -- Ref: OT 21418
    -- This test checks that weight-modifiers are correctly calculated for assistants.
    -- When the subset of codes selected for the assistant and weight-modifier codes are distinct from each other 
    --    .. a pseudo-weight-modifier must be calculated and used for the calculation of the assistant codes
    -- The issue was addressed by ignoring the weight-modifier in the main calculation  and then processing the pseudo-weight-modifier at the end of the calculation.
    -- This test is validated instead of posted so that the pseudo-weight-modifier entries (PH#0018 SP) in the XML can be compared.

    \echo Parameters: this test assumes that a goodx1 directory exists, and that at least one debtor has been created and is ready for posting. 
        SELECT set_config('test.debtor', min( fdreknr )::text, FALSE ) <> '' as debtor FROM goodx1.debmstr; 
        SELECT set_config('test.creditor', min( fdreknr )::text, FALSE ) <> '' as creditor FROM lysglb.cremstr where entity = 1; 
        SELECT set_config('test.period', lysglb.get_current_finperiod(1)::text, FALSE) <> '' as current_period; 
        SELECT set_config('test.treating_doc', mainid::text, FALSE) <> '' as treating_doc from goodx1.view_treating_docs limit 1;
        SELECT set_config('test.ref_doc', mainid::text, FALSE) <> '' as ref_doc from goodx1.view_ref_docs limit 1;


    WITH _my_test AS( select tariffs.validate_xml(format( '<table>
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
                                                                <_3rd_party_id_varchar>00000007</_3rd_party_id_varchar>
                                                                <row>
                                                                    <a_id_integer>1</a_id_integer>
                                                                    <_3rd_party_id_varchar>001</_3rd_party_id_varchar>
                                                                    <service_centre_a_id_integer>1</service_centre_a_id_integer>
                                                                    <treating_doctor_a_id_integer>1</treating_doctor_a_id_integer>
                                                                    <referring_doctor_a_id_integer>2</referring_doctor_a_id_integer>
                                                                    <date_date>%2$s</date_date>
                                                                    <srec_a_id_integer>1</srec_a_id_integer>
                                                                    <billing_code_varchar>1671</billing_code_varchar>
                                                                    <tariffcol_integer>1</tariffcol_integer>
                                                                    <description_varchar>Colomyotomy (Reilly operation)</description_varchar>
                                                                    <ledger_varchar>INC1</ledger_varchar>
                                                                    <amt_numeric2>1821.3</amt_numeric2>
                                                                    <vat_numeric2>237.56</vat_numeric2>
                                                                    <pat_portion_numeric2>0</pat_portion_numeric2>
                                                                    <amt_adjustment_practice_numeric2>0</amt_adjustment_practice_numeric2>
                                                                    <amt_adjustment_maid_numeric2>0</amt_adjustment_maid_numeric2>
                                                                    <qty_numeric2>1</qty_numeric2>
                                                                    <processed_integer>1</processed_integer>
                                                                    <posting_analisenr_integer>1</posting_analisenr_integer>
                                                                    <invoice_extension_varchar>P</invoice_extension_varchar>
                                                                    <auth_no_varchar/>
                                                                    <rx_repeats_integer>0</rx_repeats_integer>
                                                                    <icdlist_varchararr>
                                                                        <element>A01.1</element>
                                                                    </icdlist_varchararr>
                                                                    <goodx_batkey_varchar>0000000007001C</goodx_batkey_varchar>
                                                                </row>
                                                                <row>
                                                                    <a_id_integer>2</a_id_integer>
                                                                    <_3rd_party_id_varchar>001</_3rd_party_id_varchar>
                                                                    <service_centre_a_id_integer>1</service_centre_a_id_integer>
                                                                    <treating_doctor_a_id_integer>1</treating_doctor_a_id_integer>
                                                                    <referring_doctor_a_id_integer>2</referring_doctor_a_id_integer>
                                                                    <date_date>%2$s</date_date>
                                                                    <srec_a_id_integer>1</srec_a_id_integer>
                                                                    <billing_code_varchar>1671</billing_code_varchar>
                                                                    <tariffcol_integer>1</tariffcol_integer>
                                                                    <description_varchar>Colomyotomy (Reilly operation)</description_varchar>
                                                                    <ledger_varchar>INC1</ledger_varchar>
                                                                    <amt_numeric2>1821.3</amt_numeric2>
                                                                    <vat_numeric2>237.56</vat_numeric2>
                                                                    <pat_portion_numeric2>0</pat_portion_numeric2>
                                                                    <amt_adjustment_practice_numeric2>0</amt_adjustment_practice_numeric2>
                                                                    <amt_adjustment_maid_numeric2>0</amt_adjustment_maid_numeric2>
                                                                    <qty_numeric2>1</qty_numeric2>
                                                                    <processed_integer>1</processed_integer>
                                                                    <posting_analisenr_integer>1</posting_analisenr_integer>
                                                                    <invoice_extension_varchar>P</invoice_extension_varchar>
                                                                    <auth_no_varchar/>
                                                                    <rx_repeats_integer>0</rx_repeats_integer>
                                                                    <icdlist_varchararr>
                                                                        <element>A01.1</element>
                                                                    </icdlist_varchararr>
                                                                    <goodx_batkey_varchar>0000000007001C</goodx_batkey_varchar>
                                                                </row>            
                                                                <row>
                                                                    <a_id_integer>3</a_id_integer>
                                                                    <_3rd_party_id_varchar>002</_3rd_party_id_varchar>
                                                                    <service_centre_a_id_integer>1</service_centre_a_id_integer>
                                                                    <treating_doctor_a_id_integer>1</treating_doctor_a_id_integer>
                                                                    <referring_doctor_a_id_integer>2</referring_doctor_a_id_integer>
                                                                    <date_date>%2$s</date_date>
                                                                    <srec_a_id_integer>1</srec_a_id_integer>
                                                                    <billing_code_varchar>1675</billing_code_varchar>
                                                                    <tariffcol_integer>1</tariffcol_integer>
                                                                    <description_varchar>Appendicectomy</description_varchar>
                                                                    <ledger_varchar>INC1</ledger_varchar>
                                                                    <amt_numeric2>1575.2</amt_numeric2>
                                                                    <vat_numeric2>205.46</vat_numeric2>
                                                                    <pat_portion_numeric2>0</pat_portion_numeric2>
                                                                    <amt_adjustment_practice_numeric2>0</amt_adjustment_practice_numeric2>
                                                                    <amt_adjustment_maid_numeric2>0</amt_adjustment_maid_numeric2>
                                                                    <qty_numeric2>1</qty_numeric2>
                                                                    <processed_integer>1</processed_integer>
                                                                    <posting_analisenr_integer>2</posting_analisenr_integer>
                                                                    <invoice_extension_varchar>P</invoice_extension_varchar>
                                                                    <auth_no_varchar/>
                                                                    <rx_repeats_integer>0</rx_repeats_integer>
                                                                    <icdlist_varchararr>
                                                                        <element>A01.1</element>
                                                                    </icdlist_varchararr>
                                                                    <goodx_batkey_varchar>0000000007002C</goodx_batkey_varchar>
                                                                </row>
                                                                <row>
                                                                    <a_id_integer>4</a_id_integer>
                                                                    <_3rd_party_id_varchar>003</_3rd_party_id_varchar>
                                                                    <service_centre_a_id_integer>1</service_centre_a_id_integer>
                                                                    <treating_doctor_a_id_integer>1</treating_doctor_a_id_integer>
                                                                    <referring_doctor_a_id_integer>2</referring_doctor_a_id_integer>
                                                                    <date_date>%2$s</date_date>
                                                                    <srec_a_id_integer>1</srec_a_id_integer>
                                                                    <billing_code_varchar>0018 SP</billing_code_varchar>
                                                                </row>
                                                                <row>
                                                                    <a_id_integer>5</a_id_integer>
                                                                    <_3rd_party_id_varchar>004</_3rd_party_id_varchar>
                                                                    <service_centre_a_id_integer>1</service_centre_a_id_integer>
                                                                    <treating_doctor_a_id_integer>1</treating_doctor_a_id_integer>
                                                                    <referring_doctor_a_id_integer>2</referring_doctor_a_id_integer>
                                                                    <date_date>%2$s</date_date>
                                                                    <srec_a_id_integer>1</srec_a_id_integer>
                                                                    <billing_code_varchar>0009</billing_code_varchar>
                                                                    <modified_items_integerarr>
                                                                        <element>3</element>
                                                                        <element>4</element>
                                                                    </modified_items_integerarr>
                                                                </row>
                                                                <row>
                                                                    <a_id_integer>6</a_id_integer>
                                                                    <_3rd_party_id_varchar>004</_3rd_party_id_varchar>
                                                                    <service_centre_a_id_integer>1</service_centre_a_id_integer>
                                                                    <treating_doctor_a_id_integer>1</treating_doctor_a_id_integer>
                                                                    <referring_doctor_a_id_integer>2</referring_doctor_a_id_integer>
                                                                    <date_date>%2$s</date_date>
                                                                    
                                                                   
                                                                    <srec_a_id_integer>1</srec_a_id_integer>
                                                                    <billing_code_varchar>0009</billing_code_varchar>
                                                                    <modified_items_integerarr>
                                                                        <element>1</element>
                                                                        <element>3</element>
                                                                        <element>4</element>
                                                                    </modified_items_integerarr>
                                                                </row>
                                                                <row>
                                                                    <a_id_integer>7</a_id_integer>
                                                                    <_3rd_party_id_varchar>004</_3rd_party_id_varchar>
                                                                    <service_centre_a_id_integer>1</service_centre_a_id_integer>
                                                                    <treating_doctor_a_id_integer>1</treating_doctor_a_id_integer>
                                                                    <referring_doctor_a_id_integer>2</referring_doctor_a_id_integer>
                                                                    <date_date>%2$s</date_date>
                                                                    <srec_a_id_integer>1</srec_a_id_integer>
                                                                    <billing_code_varchar>0009</billing_code_varchar>
                                                                    <modified_items_integerarr>
                                                                        <element>1</element>
                                                                        <element>2</element>
                                                                        <element>4</element>
                                                                    </modified_items_integerarr>
                                                                </row>
                                                                <row>
                                                                    <a_id_integer>8</a_id_integer>
                                                                    <_3rd_party_id_varchar>004</_3rd_party_id_varchar>
                                                                    <service_centre_a_id_integer>1</service_centre_a_id_integer>
                                                                    <treating_doctor_a_id_integer>1</treating_doctor_a_id_integer>
                                                                    <referring_doctor_a_id_integer>2</referring_doctor_a_id_integer>
                                                                    <date_date>%2$s</date_date>
                                                                    
                                                                   
                                                                    <srec_a_id_integer>1</srec_a_id_integer>
                                                                    <billing_code_varchar>0009</billing_code_varchar>
                                                                </row>
                                                                <row>
                                                                    <a_id_integer>9</a_id_integer>
                                                                    <_3rd_party_id_varchar>004</_3rd_party_id_varchar>
                                                                    <service_centre_a_id_integer>1</service_centre_a_id_integer>
                                                                    <treating_doctor_a_id_integer>1</treating_doctor_a_id_integer>
                                                                    <referring_doctor_a_id_integer>2</referring_doctor_a_id_integer>
                                                                    <date_date>%2$s</date_date>
                                                                    <srec_a_id_integer>1</srec_a_id_integer>
                                                                    <billing_code_varchar>0009</billing_code_varchar>
                                                                    <modified_items_integerarr>
                                                                        <element>1</element>
                                                                        <element>2</element>
                                                                        <element>3</element>
                                                                    </modified_items_integerarr>
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
                                                                <goodx_id_integer>1</goodx_id_integer>
                                                            </doctor>
                                                            <doctor>
                                                                <a_id_integer>2</a_id_integer>
                                                                <goodx_id_integer>%4$s</goodx_id_integer>
                                                            </doctor>
                                                            <doctor>
                                                                <a_id_integer>3</a_id_integer>
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
                                                 ) AS myval )

    SELECT  unnest( xpath( '/table/feedback/summary/critical/text()', myval ))::text AS critical_errors 
           , unnest( xpath( '/table/invoices/invoice/row/a_id_integer/text()', myval ))::TEXT::INTEGER as a_id_integer
           , unnest( xpath( '/table/invoices/invoice/row/billing_code_varchar/text()', myval ))::TEXT AS billing_code
           , unnest( xpath( '/table/invoices/invoice/row/units_numeric4/text()', myval ))::TEXT::NUMERIC(15,2) AS units
           , unnest( xpath( '/table/invoices/invoice/row/modifier_varchararr/element/text()', myval ))::TEXT AS modified_by
           , xpath( '/modified_items_integerarr/element/text()', unnest( xpath( '/table/invoices/invoice/row/modified_items_integerarr', myval )))  AS modified
    FROM _my_test;

     