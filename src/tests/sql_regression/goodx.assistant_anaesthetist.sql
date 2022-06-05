-- Ref: OT 22082: Assistant anaesthetic code: ability to select codes on which to apply
-- When set up to apply on all codes: Specific codes must automatically be excluded
-- When set up to select codes: Specific codes must be "unselected" on the code selection screen, with a "not recommended" hint. The user must however still be able to select them if required.
-- ...This is mainly to cater for clients who are used to claiming these codes.

\echo Parameters: this test assumes that a goodx1 directory exists, and that at least one debtor has been created and is ready for posting.
    SELECT set_config('test.debtor', min(fdreknr)::text, FALSE) <> '' as debtor FROM goodx1.debmstr;
    SELECT set_config('test.creditor', min(fdreknr)::text, FALSE) <> '' as creditor FROM lysglb.cremstr where entity = 1;
    SELECT set_config('test.period', lysglb.get_current_finperiod(1)::text, FALSE) <> '' as current_period;
    SELECT set_config('test.treating_doc', mainid::text, FALSE) <> '' as treating_doc from goodx1.view_treating_docs limit 1;
    SELECT set_config('test.ref_doc', mainid::text, FALSE) <> '' as ref_doc from goodx1.view_ref_docs limit 1;

WITH _my_test AS (SELECT tariffs.validate_xml(format('<table>
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
                                            <_3rd_party_id_varchar>00000011</_3rd_party_id_varchar>
                                            <row>
                                                <a_id_integer>10</a_id_integer>
                                                <_3rd_party_id_varchar>001</_3rd_party_id_varchar>
                                                <service_centre_a_id_integer>1</service_centre_a_id_integer>
                                                <treating_doctor_a_id_integer>1</treating_doctor_a_id_integer>
                                                <referring_doctor_a_id_integer>2</referring_doctor_a_id_integer>
                                                <date_date>%2$s</date_date>
                                                <srec_a_id_integer>1</srec_a_id_integer>
                                                <billing_code_varchar>0151</billing_code_varchar>
                                                <qty_numeric2>1</qty_numeric2>
                                                <icdlist_varchararr>
                                                    <element>A01.1</element>
                                                </icdlist_varchararr>
                                            </row>
                                            <row>
                                                <a_id_integer>20</a_id_integer>
                                                <_3rd_party_id_varchar>002</_3rd_party_id_varchar>
                                                <service_centre_a_id_integer>1</service_centre_a_id_integer>
                                                <treating_doctor_a_id_integer>1</treating_doctor_a_id_integer>
                                                <referring_doctor_a_id_integer>2</referring_doctor_a_id_integer>
                                                <date_date>%2$s</date_date>

                                                <srec_a_id_integer>1</srec_a_id_integer>
                                                <billing_code_varchar>0637 N</billing_code_varchar>
                                                <icdlist_varchararr>
                                                    <element>A01.1</element>
                                                </icdlist_varchararr>
                                            </row>
                                            <row>
                                                <a_id_integer>30</a_id_integer>
                                                <_3rd_party_id_varchar>003</_3rd_party_id_varchar>
                                                <service_centre_a_id_integer>1</service_centre_a_id_integer>
                                                <treating_doctor_a_id_integer>1</treating_doctor_a_id_integer>
                                                <referring_doctor_a_id_integer>2</referring_doctor_a_id_integer>
                                                <date_date>%2$s</date_date>
                                                <srec_a_id_integer>1</srec_a_id_integer>
                                                <billing_code_varchar>5445</billing_code_varchar>
                                                <tariffcol_integer>1</tariffcol_integer>
                                                <icdlist_varchararr>
                                                    <element>A01.1</element>
                                                </icdlist_varchararr>
                                            </row>
                                            <row>
                                                <a_id_integer>40</a_id_integer>
                                                <_3rd_party_id_varchar>003</_3rd_party_id_varchar>
                                                <service_centre_a_id_integer>1</service_centre_a_id_integer>
                                                <treating_doctor_a_id_integer>1</treating_doctor_a_id_integer>
                                                <referring_doctor_a_id_integer>2</referring_doctor_a_id_integer>
                                                <date_date>%2$s</date_date>


                                                <srec_a_id_integer>1</srec_a_id_integer>
                                                <billing_code_varchar>5441</billing_code_varchar>
                                                <tariffcol_integer>1</tariffcol_integer>
                                                <icdlist_varchararr>
                                                    <element>A01.1</element>
                                                </icdlist_varchararr>
                                            </row>
                                            <row>
                                                <a_id_integer>50</a_id_integer>
                                                <_3rd_party_id_varchar>004</_3rd_party_id_varchar>
                                                <service_centre_a_id_integer>1</service_centre_a_id_integer>
                                                <treating_doctor_a_id_integer>1</treating_doctor_a_id_integer>
                                                <referring_doctor_a_id_integer>2</referring_doctor_a_id_integer>
                                                <date_date>%2$s</date_date>
                                                <srec_a_id_integer>1</srec_a_id_integer>
                                                <billing_code_varchar>0032</billing_code_varchar>
                                                <icdlist_varchararr>
                                                    <element>A01.1</element>
                                                </icdlist_varchararr>
                                            </row>
                                            <row>
                                                <a_id_integer>60</a_id_integer>
                                                <_3rd_party_id_varchar>005</_3rd_party_id_varchar>
                                                <service_centre_a_id_integer>1</service_centre_a_id_integer>
                                                <treating_doctor_a_id_integer>1</treating_doctor_a_id_integer>
                                                <referring_doctor_a_id_integer>2</referring_doctor_a_id_integer>
                                                <date_date>%2$s</date_date>
                                                <srec_a_id_integer>1</srec_a_id_integer>
                                                <billing_code_varchar>0023</billing_code_varchar>
                                                <tariffcol_integer>1</tariffcol_integer>
                                                <qty_numeric2>1</qty_numeric2>
                                            </row>

                                            <row>
                                                <a_id_integer>70</a_id_integer>
                                                <service_centre_a_id_integer>1</service_centre_a_id_integer>
                                                <treating_doctor_a_id_integer>1</treating_doctor_a_id_integer>
                                                <referring_doctor_a_id_integer>2</referring_doctor_a_id_integer>
                                                <date_date>%2$s</date_date>
                                                <srec_a_id_integer>1</srec_a_id_integer>
                                                <billing_code_varchar>0029</billing_code_varchar>
                                                <icdlist_varchararr>
                                                    <element>A01.1</element>
                                                </icdlist_varchararr>
                                                <qty_numeric2>1</qty_numeric2>
                                            </row>
                                            <row>
                                                <a_id_integer>80</a_id_integer>
                                                <service_centre_a_id_integer>1</service_centre_a_id_integer>
                                                <treating_doctor_a_id_integer>1</treating_doctor_a_id_integer>
                                                <referring_doctor_a_id_integer>2</referring_doctor_a_id_integer>
                                                <date_date>%2$s</date_date>
                                                <srec_a_id_integer>1</srec_a_id_integer>
                                                <billing_code_varchar>0029</billing_code_varchar>
                                                <icdlist_varchararr>
                                                    <element>A01.1</element>
                                                </icdlist_varchararr>
                                                <modified_items_integerarr>
                                                    <element>20</element>
                                                    <element>30</element>
                                                    <element>50</element>
                                                </modified_items_integerarr>
                                                <qty_numeric2>1</qty_numeric2>
                                            </row>
                                            <row>
                                                <a_id_integer>90</a_id_integer>
                                                <service_centre_a_id_integer>1</service_centre_a_id_integer>
                                                <treating_doctor_a_id_integer>1</treating_doctor_a_id_integer>
                                                <referring_doctor_a_id_integer>2</referring_doctor_a_id_integer>
                                                <date_date>%2$s</date_date>
                                                <srec_a_id_integer>1</srec_a_id_integer>
                                                <billing_code_varchar>0029</billing_code_varchar>
                                                <icdlist_varchararr>
                                                    <element>A01.1</element>
                                                </icdlist_varchararr>
                                                <qty_numeric2>100</qty_numeric2>
                                            </row>
                                            <row>
                                                <a_id_integer>100</a_id_integer>
                                                <service_centre_a_id_integer>1</service_centre_a_id_integer>
                                                <treating_doctor_a_id_integer>1</treating_doctor_a_id_integer>
                                                <referring_doctor_a_id_integer>2</referring_doctor_a_id_integer>
                                                <date_date>%2$s</date_date>
                                                <srec_a_id_integer>1</srec_a_id_integer>
                                                <billing_code_varchar>0029</billing_code_varchar>
                                                <icdlist_varchararr>
                                                    <element>A01.1</element>
                                                </icdlist_varchararr>
                                                <modified_items_integerarr>
                                                    <element>20</element>
                                                    <element>30</element>
                                                    <element>50</element>
                                                </modified_items_integerarr>
                                                <qty_numeric2>100</qty_numeric2>
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
                                </table>
                             ', current_setting('test.period')::INTEGER,
                                                           to_char(now(), 'yyyy-mm-dd'),
                                                           current_setting('test.debtor')::INTEGER,
                                                           current_setting('test.treating_doc')::INTEGER,
                                                           current_setting('test.ref_doc') ::INTEGER
                                                           )::XML
                                                           ) AS myval
                           )
SELECT   unnest(xpath('/table/feedback/summary/critical/text()', myval))::text AS critical_errors
       , unnest(xpath('/table/invoices/invoice/row/a_id_integer/text()', myval))::text::INTEGER AS a_id_integer
       , unnest(xpath('/table/invoices/invoice/row/billing_code_varchar/text()', myval))::text AS billing_code
       , unnest(xpath('/table/invoices/invoice/row/units_numeric4/text()', myval))::text::NUMERIC(15,2) AS units
       , unnest(xpath('/table/invoices/invoice/row/modified_items_integerarr', myval))  AS modified
       , unnest(xpath('/table/invoices/invoice/row/qty_numeric2/text()', myval))::text::numeric(15,2) AS minutes
       , unnest(xpath('/table/invoices/invoice/row/units_numeric4/text()', myval))::text::numeric(15,2) AS units
       , unnest(xpath('/table/invoices/invoice/row/units_adjustment/text()', myval))::text::numeric(15,2) AS units_adjustment
       , unnest(xpath('/table/invoices/invoice/row/unit_info_text/text()', myval))::text AS unit_info_text
FROM _my_test;



