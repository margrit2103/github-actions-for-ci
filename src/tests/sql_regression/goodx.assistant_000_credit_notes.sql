-- Ref: OT 23697
-- This test that credit notes are handled correctly for debtor invoices that have generated creditor invoices.
-- The test does not check amounts, just that the correct rows are found.
-- Some issues were experienced when subsets of codes were reversed in a series of credit notes.
--
-- In order to simplify maintenance, the test has been spread across six files:
--      - goodx.assistant_000_credit_notes.sql (setting up the configuration)
--      - goodx.assistant_001_credit_notes.sql .. goodx.assistant_001_credit_notes.sql (actual tests)
--
--  Test 1 (reverse single assistant, multiple assistants, remaining codes)
--      1.1  Post invoice with 5 assistant codes 
--      1.2  Credit note for second assistant code only
--      1.3  Credit note for remaining assistant codes
--      1.4.  Reverse the remaining codes on the invoice
--      1.5.  Check that the total turnover is zero on debtors and creditors
--  Test 2 (reverse all codes at once) 
--      2.1  Post invoice with 5 assistant codes 
--      2.2  Reverse entire invoice
--  Test 3 (reverse codes not linked to assistant, then all codes linked to assistant) 
--      3.1  Post invoice with 5 assistant codes 
--      3.2  Reverse codes not linked to assistant
--      3.3  Reverse codes all codes linked to assistant
--  Test 4  (reverse codes not linked to assistant, single linked to assistant, remaining codes linked to assistant) 
--      4.1  Post invoice with 5 assistant codes 
--      4.2  Reverse codes not linked to assistant
--      4.3  Reverse second code code linked to assistant
--      4.4  Reverse remaining codes code linked to assistant
--  Test 5  (Post multiple invoices, reverse them all in the same batch)
--      5.1  Post 3 invoice with 5 assistant codes (Check that 3 creditor invoices have been generated for each debtor invoice)
--      5.2  Reverse everything




\echo Parameters: this test assumes that a goodx1 directory exists, and that at least one debtor has been created and is ready for posting. 
    SELECT set_config('test.debtor', min(fdreknr)::text, FALSE) <> '' as debtor FROM goodx1.debmstr; 
    SELECT set_config('test.creditor', min(fdreknr)::text, FALSE) <> '' as creditor FROM lysglb.cremstr where entity = 1; 
    SELECT set_config('test.period', lysglb.get_current_finperiod(1)::text, FALSE) <> '' as current_period; 
    SELECT set_config('test.treating_doc', mainid::text, FALSE) <> '' as treating_doc from goodx1.view_treating_docs limit 1;
    SELECT set_config('test.ref_doc', mainid::text, FALSE) <> '' as ref_doc from goodx1.view_ref_docs limit 1;
    SELECT set_config('test.assistant_doc', mainid::text, FALSE) <> '' as ref_doc FROM goodx1.view_assistant_docs WHERE nullif(creditor,'') IS NOT NULL LIMIT 1;
    
    
\echo Parameters Invoice template    
    SELECT set_config('test.invoice_template',format('<table>
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
                                                                <assistant_a_id_integer>4</assistant_a_id_integer>
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
                                                                <assistant_a_id_integer>4</assistant_a_id_integer>
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
                                                                <assistant_a_id_integer>4</assistant_a_id_integer>
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
                                                                <assistant_a_id_integer>4</assistant_a_id_integer>
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
                                                                <assistant_a_id_integer>4</assistant_a_id_integer>
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
                                                        <doctor>
                                                            <a_id_integer>4</a_id_integer>
                                                            <goodx_id_integer>%6$s</goodx_id_integer>
                                                        </doctor>
                                                        
                                                    </doctors>
                                                    <service_centres>
                                                        <service_centre>
                                                            <a_id_integer>1</a_id_integer>
                                                            <goodx_id_integer>1</goodx_id_integer>
                                                        </service_centre>
                                                    </service_centres>
                                                </table>', current_setting('test.period'), --1
                                                           to_char(now(), 'yyyy-mm-dd'), --2
                                                           current_setting('test.debtor'), --3
                                                           current_setting('test.treating_doc'), --4
                                                           current_setting('test.ref_doc'), --5
                                                           current_setting('test.assistant_doc') --6
                                )::text, FALSE) <> '' as invoice_template;
                                
