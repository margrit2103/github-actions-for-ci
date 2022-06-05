-- Ref: OT 21935
-- This test checks that unit reduction modifiers work correctly.
-- There are two types of unit reduction modifiers:
--           - GLV84 allows for specific reduction factors per line
--           - GLV85 applies a single reduction factor for all lines
-- The test applies the same modifier multiple times to the same line items. This is to make sure that the reduction amount is NOT
-- applied more than once and that the function handles reduction to less than zero correctly.
-- It is assumed that :
--        modifier 6305 has been created as a GLV84 modifier
--        modifier "6305 GLV85" has been created as a GLV85 modifier

\echo Parameters: this test assumes that a goodx1 directory exists, and that at least one debtor has been created and is ready for posting.
    SELECT set_config('test.debtor', min( fdreknr )::text, FALSE ) <> '' as debtor FROM goodx1.debmstr;
    SELECT set_config('test.creditor', min( fdreknr )::text, FALSE ) <> '' as creditor FROM lysglb.cremstr where entity = 1;
    SELECT set_config('test.period', lysglb.get_current_finperiod(1)::text, FALSE) <> '' as current_period;
    SELECT set_config('test.treating_doc', mainid::text, FALSE) <> '' as treating_doc from goodx1.view_treating_docs limit 1;
    SELECT set_config('test.ref_doc', mainid::text, FALSE) <> '' as ref_doc from goodx1.view_ref_docs limit 1;

\echo GLV84 test

\echo Parameters: this test assumes that a goodx1 directory exists, and that at least one debtor has been created and is ready for posting. 
    SELECT set_config('test.debtor', min( fdreknr )::text, FALSE ) <> '' as debtor FROM goodx1.debmstr; 
    SELECT set_config('test.creditor', min( fdreknr )::text, FALSE ) <> '' as creditor FROM lysglb.cremstr where entity = 1; 
    SELECT set_config('test.period', lysglb.get_current_finperiod(1)::text, FALSE) <> '' as current_period; 
    SELECT set_config('test.treating_doc', mainid::text, FALSE) <> '' as treating_doc from goodx1.view_treating_docs limit 1;
    SELECT set_config('test.ref_doc', mainid::text, FALSE) <> '' as ref_doc from goodx1.view_ref_docs limit 1;



WITH _my_test AS( select tariffs.validate_xml( format( '<table>
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
                                                        <_3rd_party_id_varchar>00000014</_3rd_party_id_varchar>
                                                        <row>
                                                            <a_id_integer>1</a_id_integer>
                                                            <_3rd_party_id_varchar>001</_3rd_party_id_varchar>
                                                            <service_centre_a_id_integer>1</service_centre_a_id_integer>
                                                            <treating_doctor_a_id_integer>1</treating_doctor_a_id_integer>
                                                            <referring_doctor_a_id_integer>2</referring_doctor_a_id_integer>
                                                            <date_date>%2$s</date_date>
                                                            
                                                            
                                                            <srec_a_id_integer>1</srec_a_id_integer>
                                                            <billing_code_varchar>3557</billing_code_varchar>
                                                            <tariffcol_integer>1</tariffcol_integer>
                                                            <description_varchar>Catheterisation aorta or vena </description_varchar>
                                                            <ledger_varchar>INC1</ledger_varchar>
                                                            <qty_numeric2>1</qty_numeric2>
                                                            <processed_integer>1</processed_integer>
                                                            <auth_no_varchar/>
                                                            <rx_repeats_integer>0</rx_repeats_integer>
                                                            <icdlist_varchararr>
                                                                <element>A01.0</element>
                                                                <element>M01.31</element>
                                                            </icdlist_varchararr>
                                                        </row>
                                                        <row>
                                                            <a_id_integer>2</a_id_integer>
                                                            <_3rd_party_id_varchar>002</_3rd_party_id_varchar>
                                                            <service_centre_a_id_integer>1</service_centre_a_id_integer>
                                                            <treating_doctor_a_id_integer>1</treating_doctor_a_id_integer>
                                                            <referring_doctor_a_id_integer>2</referring_doctor_a_id_integer>
                                                            <date_date>%2$s</date_date>
                                                            
                                                            
                                                            <srec_a_id_integer>1</srec_a_id_integer>
                                                            <billing_code_varchar>3559</billing_code_varchar>
                                                            <tariffcol_integer>1</tariffcol_integer>
                                                            <icdlist_varchararr>
                                                                <element>A01.0</element>
                                                                <element>M01.31</element>
                                                            </icdlist_varchararr>
                                                        </row>
                                                        <row>
                                                            <a_id_integer>3</a_id_integer>
                                                            <_3rd_party_id_varchar>003</_3rd_party_id_varchar>
                                                            <service_centre_a_id_integer>1</service_centre_a_id_integer>
                                                            <treating_doctor_a_id_integer>1</treating_doctor_a_id_integer>
                                                            <referring_doctor_a_id_integer>2</referring_doctor_a_id_integer>
                                                            <date_date>%2$s</date_date>
                                                            
                                                            
                                                            <srec_a_id_integer>1</srec_a_id_integer>
                                                            <billing_code_varchar>3560</billing_code_varchar>
                                                            <tariffcol_integer>1</tariffcol_integer>
                                                            <icdlist_varchararr>
                                                                <element>A01.0</element>
                                                                <element>M01.31</element>
                                                            </icdlist_varchararr>
                                                        </row>
                                                        <row>
                                                            <a_id_integer>4</a_id_integer>
                                                            <_3rd_party_id_varchar>004</_3rd_party_id_varchar>
                                                            <service_centre_a_id_integer>1</service_centre_a_id_integer>
                                                            <treating_doctor_a_id_integer>1</treating_doctor_a_id_integer>
                                                            <referring_doctor_a_id_integer>2</referring_doctor_a_id_integer>
                                                            <date_date>%2$s</date_date>
                                                            
                                                            
                                                            <srec_a_id_integer>1</srec_a_id_integer>
                                                            <billing_code_varchar>6305</billing_code_varchar>
                                                            <tariffcol_integer>1</tariffcol_integer>
                                                            <icdlist_varchararr>
                                                                <element>A01.0</element>
                                                                <element>M01.31</element>
                                                            </icdlist_varchararr>
                                                        </row>
                                                        <row>
                                                            <a_id_integer>5</a_id_integer>
                                                            <_3rd_party_id_varchar>004</_3rd_party_id_varchar>
                                                            <service_centre_a_id_integer>1</service_centre_a_id_integer>
                                                            <treating_doctor_a_id_integer>1</treating_doctor_a_id_integer>
                                                            <referring_doctor_a_id_integer>2</referring_doctor_a_id_integer>
                                                            <date_date>%2$s</date_date>
                                                            
                                                            
                                                            <srec_a_id_integer>1</srec_a_id_integer>
                                                            <billing_code_varchar>6305</billing_code_varchar>
                                                            <tariffcol_integer>1</tariffcol_integer>
                                                            <icdlist_varchararr>
                                                                <element>A01.0</element>
                                                                <element>M01.31</element>
                                                            </icdlist_varchararr>
                                                        </row>
                                                        <row>
                                                            <a_id_integer>6</a_id_integer>
                                                            <_3rd_party_id_varchar>006</_3rd_party_id_varchar>
                                                            <service_centre_a_id_integer>1</service_centre_a_id_integer>
                                                            <treating_doctor_a_id_integer>1</treating_doctor_a_id_integer>
                                                            <referring_doctor_a_id_integer>2</referring_doctor_a_id_integer>
                                                            <date_date>%2$s</date_date>
                                                            
                                                            
                                                            <srec_a_id_integer>1</srec_a_id_integer>
                                                            <billing_code_varchar>6305</billing_code_varchar>
                                                            <tariffcol_integer>1</tariffcol_integer>
                                                            <icdlist_varchararr>
                                                                <element>A01.0</element>
                                                                <element>M01.31</element>
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

                                            
                                            ) AS myval )

 select (xpath( '/table/feedback/summary/critical/text()', myval ))[1] AS no_critical_errors, 
          xpath( '/table/invoices/invoice/row/billing_code_varchar/text()',  myval ),
          xpath( '/table/invoices/invoice/row/units_numeric4/text()',  myval )
 FROM _my_test;




\echo GLV85 test

WITH _my_test AS( select tariffs.validate_xml( format( '<table>
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
                                                        <_3rd_party_id_varchar>00000014</_3rd_party_id_varchar>
                                                        <row>
                                                            <a_id_integer>1</a_id_integer>
                                                            <_3rd_party_id_varchar>001</_3rd_party_id_varchar>
                                                            <service_centre_a_id_integer>1</service_centre_a_id_integer>
                                                            <treating_doctor_a_id_integer>1</treating_doctor_a_id_integer>
                                                            <referring_doctor_a_id_integer>2</referring_doctor_a_id_integer>
                                                            <date_date>%2$s</date_date>
                                                            
                                                            
                                                            <srec_a_id_integer>1</srec_a_id_integer>
                                                            <billing_code_varchar>3557</billing_code_varchar>
                                                            <tariffcol_integer>1</tariffcol_integer>
                                                            <description_varchar>Catheterisation aorta or vena </description_varchar>
                                                            <ledger_varchar>INC1</ledger_varchar>
                                                            <qty_numeric2>1</qty_numeric2>
                                                            <processed_integer>1</processed_integer>
                                                            <auth_no_varchar/>
                                                            <rx_repeats_integer>0</rx_repeats_integer>
                                                            <icdlist_varchararr>
                                                                <element>A01.0</element>
                                                                <element>M01.31</element>
                                                            </icdlist_varchararr>
                                                        </row>
                                                        <row>
                                                            <a_id_integer>2</a_id_integer>
                                                            <_3rd_party_id_varchar>002</_3rd_party_id_varchar>
                                                            <service_centre_a_id_integer>1</service_centre_a_id_integer>
                                                            <treating_doctor_a_id_integer>1</treating_doctor_a_id_integer>
                                                            <referring_doctor_a_id_integer>2</referring_doctor_a_id_integer>
                                                            <date_date>%2$s</date_date>
                                                            
                                                            
                                                            <srec_a_id_integer>1</srec_a_id_integer>
                                                            <billing_code_varchar>3559</billing_code_varchar>
                                                            <tariffcol_integer>1</tariffcol_integer>
                                                            <icdlist_varchararr>
                                                                <element>A01.0</element>
                                                                <element>M01.31</element>
                                                            </icdlist_varchararr>
                                                        </row>
                                                        <row>
                                                            <a_id_integer>3</a_id_integer>
                                                            <_3rd_party_id_varchar>003</_3rd_party_id_varchar>
                                                            <service_centre_a_id_integer>1</service_centre_a_id_integer>
                                                            <treating_doctor_a_id_integer>1</treating_doctor_a_id_integer>
                                                            <referring_doctor_a_id_integer>2</referring_doctor_a_id_integer>
                                                            <date_date>%2$s</date_date>
                                                            
                                                            
                                                            <srec_a_id_integer>1</srec_a_id_integer>
                                                            <billing_code_varchar>3560</billing_code_varchar>
                                                            <tariffcol_integer>1</tariffcol_integer>
                                                            <icdlist_varchararr>
                                                                <element>A01.0</element>
                                                                <element>M01.31</element>
                                                            </icdlist_varchararr>
                                                        </row>
                                                        <row>
                                                            <a_id_integer>4</a_id_integer>
                                                            <_3rd_party_id_varchar>004</_3rd_party_id_varchar>
                                                            <service_centre_a_id_integer>1</service_centre_a_id_integer>
                                                            <treating_doctor_a_id_integer>1</treating_doctor_a_id_integer>
                                                            <referring_doctor_a_id_integer>2</referring_doctor_a_id_integer>
                                                            <date_date>%2$s</date_date>
                                                            
                                                            
                                                            <srec_a_id_integer>1</srec_a_id_integer>
                                                            <billing_code_varchar>6305 GLV85</billing_code_varchar>
                                                            <tariffcol_integer>1</tariffcol_integer>
                                                            <icdlist_varchararr>
                                                                <element>A01.0</element>
                                                                <element>M01.31</element>
                                                            </icdlist_varchararr>
                                                        </row>
                                                        <row>
                                                            <a_id_integer>5</a_id_integer>
                                                            <_3rd_party_id_varchar>004</_3rd_party_id_varchar>
                                                            <service_centre_a_id_integer>1</service_centre_a_id_integer>
                                                            <treating_doctor_a_id_integer>1</treating_doctor_a_id_integer>
                                                            <referring_doctor_a_id_integer>2</referring_doctor_a_id_integer>
                                                            <date_date>%2$s</date_date>
                                                            
                                                            
                                                            <srec_a_id_integer>1</srec_a_id_integer>
                                                            <billing_code_varchar>6305 GLV85</billing_code_varchar>
                                                            <tariffcol_integer>1</tariffcol_integer>
                                                            <icdlist_varchararr>
                                                                <element>A01.0</element>
                                                                <element>M01.31</element>
                                                            </icdlist_varchararr>
                                                        </row>
                                                        <row>
                                                            <a_id_integer>6</a_id_integer>
                                                            <_3rd_party_id_varchar>006</_3rd_party_id_varchar>
                                                            <service_centre_a_id_integer>1</service_centre_a_id_integer>
                                                            <treating_doctor_a_id_integer>1</treating_doctor_a_id_integer>
                                                            <referring_doctor_a_id_integer>2</referring_doctor_a_id_integer>
                                                            <date_date>%2$s</date_date>
                                                            
                                                            
                                                            <srec_a_id_integer>1</srec_a_id_integer>
                                                            <billing_code_varchar>6305 GLV85</billing_code_varchar>
                                                            <tariffcol_integer>1</tariffcol_integer>
                                                            <icdlist_varchararr>
                                                                <element>A01.0</element>
                                                                <element>M01.31</element>
                                                            </icdlist_varchararr>
                                                        </row>
                                                        <row>
                                                            <a_id_integer>6</a_id_integer>
                                                            <_3rd_party_id_varchar>006</_3rd_party_id_varchar>
                                                            <service_centre_a_id_integer>1</service_centre_a_id_integer>
                                                            <treating_doctor_a_id_integer>1</treating_doctor_a_id_integer>
                                                            <referring_doctor_a_id_integer>2</referring_doctor_a_id_integer>
                                                            <date_date>%2$s</date_date>
                                                            
                                                            
                                                            <srec_a_id_integer>1</srec_a_id_integer>
                                                            <billing_code_varchar>6305 GLV85</billing_code_varchar>
                                                            <tariffcol_integer>1</tariffcol_integer>
                                                            <icdlist_varchararr>
                                                                <element>A01.0</element>
                                                                <element>M01.31</element>
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

                                                           ) AS myval )

 select (xpath( '/table/feedback/summary/critical/text()', myval ))[1] AS no_critical_errors, 
          xpath( '/table/invoices/invoice/row/billing_code_varchar/text()',  myval ),
          xpath( '/table/invoices/invoice/row/units_numeric4/text()',  myval )
 FROM _my_test;
 