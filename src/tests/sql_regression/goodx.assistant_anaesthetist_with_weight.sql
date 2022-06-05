-- Ref: OT 23686: Assistant anaesthetic codes
-- Check that time calculations are correct when the time spent by the primary practioner differs from the time spent by die assistant.

\echo Parameters: this test assumes that a goodx1 directory exists, and that at least one debtor has been created and is ready for posting.
    SELECT set_config('test.debtor', min(fdreknr)::text, FALSE) <> '' as debtor FROM goodx1.debmstr;
    SELECT set_config('test.creditor', min(fdreknr)::text, FALSE) <> '' as creditor FROM lysglb.cremstr where entity = 1;
    SELECT set_config('test.period', lysglb.get_current_finperiod(1)::text, FALSE) <> '' as current_period;
    SELECT set_config('test.treating_doc', mainid::text, FALSE) <> '' as treating_doc from goodx1.view_treating_docs limit 1;
    SELECT set_config('test.ref_doc', mainid::text, FALSE) <> '' as ref_doc from goodx1.view_ref_docs limit 1;
    SELECT set_config('test.mpystipe', mpystipe, FALSE) <> '' AS mpystipe FROM lysglb.mpy WHERE fdid = 1;
    SELECT set_config('test.xml_template','<table>
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
                                                            <billing_code_varchar>1049 N</billing_code_varchar>
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
                                                            <billing_code_varchar>0023</billing_code_varchar>
                                                            <qty_numeric2>%6$s</qty_numeric2>
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
                                                            <billing_code_varchar>0018 AN</billing_code_varchar>
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
                                                            <qty_numeric2>1</qty_numeric2>
                                                            <srec_a_id_integer>1</srec_a_id_integer>
                                                            <billing_code_varchar>0029</billing_code_varchar>
                                                            <tariffcol_integer>1</tariffcol_integer>
                                                            <icdlist_varchararr>
                                                                <element>A01.1</element>
                                                            </icdlist_varchararr>
                                                        </row>
                                                        <row>
                                                            <a_id_integer>41</a_id_integer>
                                                            <_3rd_party_id_varchar>003</_3rd_party_id_varchar>
                                                            <service_centre_a_id_integer>1</service_centre_a_id_integer>
                                                            <treating_doctor_a_id_integer>1</treating_doctor_a_id_integer>
                                                            <referring_doctor_a_id_integer>2</referring_doctor_a_id_integer>
                                                            <date_date>%2$s</date_date>
                                                            <qty_numeric2>61</qty_numeric2>
                                                            <srec_a_id_integer>1</srec_a_id_integer>
                                                            <billing_code_varchar>0029</billing_code_varchar>
                                                            <tariffcol_integer>1</tariffcol_integer>
                                                            <icdlist_varchararr>
                                                                <element>A01.1</element>
                                                            </icdlist_varchararr>
                                                        </row>
                                                        <row>
                                                            <a_id_integer>42</a_id_integer>
                                                            <_3rd_party_id_varchar>003</_3rd_party_id_varchar>
                                                            <service_centre_a_id_integer>1</service_centre_a_id_integer>
                                                            <treating_doctor_a_id_integer>1</treating_doctor_a_id_integer>
                                                            <referring_doctor_a_id_integer>2</referring_doctor_a_id_integer>
                                                            <date_date>%2$s</date_date>
                                                            <qty_numeric2>250</qty_numeric2>
                                                            <srec_a_id_integer>1</srec_a_id_integer>
                                                            <billing_code_varchar>0029</billing_code_varchar>
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
                                           </table>',FALSE) <> '' as xml_template;
                                           
UPDATE lysglb.mpy SET mpystipe = 'Y' WHERE fdid = 1;

\echo Simple billing group calculation. Primary practioner = 1 minute (no reduction).
WITH _my_test AS (SELECT tariffs.validate_xml(format(current_setting('test.xml_template'),
                                                           current_setting('test.period')::INTEGER, --1
                                                           to_char(now(), 'yyyy-mm-dd'), --2
                                                           current_setting('test.debtor')::INTEGER, --3
                                                           current_setting('test.treating_doc')::INTEGER, --4
                                                           current_setting('test.ref_doc') ::INTEGER, --5
                                                           1 --6
                              )::XML
                              ) AS myval
),
     b AS(SELECT unnest(xpath('/table/feedback/summary/critical/text()', myval))::text AS critical_errors,
                 unnest(xpath('/table/invoices/invoice/row/a_id_integer/text()', myval))::text::integer AS a_id_integer,
                 unnest(xpath('/table/invoices/invoice/row/billing_code_varchar/text()', myval))::text AS billing_code,
                 unnest(xpath('/table/invoices/invoice/row/qty_numeric2/text()', myval))::text::numeric(15,2) AS minutes,
                 unnest(xpath('/table/invoices/invoice/row/units_numeric4/text()', myval))::text::numeric(15,2) AS units,
                 unnest(xpath('/table/invoices/invoice/row/units_adjustment/text()', myval))::text::numeric(15,2) AS units_adjustment,
                 unnest(xpath('/table/invoices/invoice/row/unit_info_text/text()', myval))::text AS unit_info_text,
                 unnest(xpath('/table/invoices/invoice/row/posting_order_numeric2/text()', myval)) AS posting_order_numeric2
          FROM _my_test)
SELECT * FROM b;


\echo Simple billing group calculation for GP. Primary practioner = 1000 minute (reduction for 0023).
WITH _my_test AS (SELECT tariffs.validate_xml(format(current_setting('test.xml_template'),
                                                           current_setting('test.period')::INTEGER, --1
                                                           to_char(now(), 'yyyy-mm-dd'), --2
                                                           current_setting('test.debtor')::INTEGER, --3
                                                           current_setting('test.treating_doc')::INTEGER, --4
                                                           current_setting('test.ref_doc') ::INTEGER, --5
                                                           1000 --6
                                                    )::XML
                                             ) AS myval
),
     b AS(SELECT unnest(xpath('/table/feedback/summary/critical/text()', myval))::text AS critical_errors,
                 unnest(xpath('/table/invoices/invoice/row/a_id_integer/text()', myval))::text::integer AS a_id_integer,
                 unnest(xpath('/table/invoices/invoice/row/billing_code_varchar/text()', myval))::text AS billing_code,
                 unnest(xpath('/table/invoices/invoice/row/qty_numeric2/text()', myval))::text::numeric(15,2) AS minutes,
                 unnest(xpath('/table/invoices/invoice/row/units_numeric4/text()', myval))::text::numeric(15,2) AS units,
                 unnest(xpath('/table/invoices/invoice/row/units_adjustment/text()', myval))::text::numeric(15,2) AS units_adjustment,
                 unnest(xpath('/table/invoices/invoice/row/unit_info_text/text()', myval))::text AS unit_info_text,
                 unnest(xpath('/table/invoices/invoice/row/posting_order_numeric2/text()', myval)) AS posting_order_numeric2
          FROM _my_test)
SELECT * FROM b;

UPDATE lysglb.mpy SET mpystipe = 'N' WHERE fdid = 1;

\echo Simple billing group calculation for specialist. Primary practioner = 1000 minute (no reduction for 0023, no 0036/0035 rows).
WITH _my_test AS (SELECT tariffs.validate_xml(format(current_setting('test.xml_template'),
                                                           current_setting('test.period')::INTEGER, --1
                                                           to_char(now(), 'yyyy-mm-dd'), --2
                                                           current_setting('test.debtor')::INTEGER, --3
                                                           current_setting('test.treating_doc')::INTEGER, --4
                                                           current_setting('test.ref_doc') ::INTEGER, --5
                                                           1000 --6
                                                    )::XML
                                             ) AS myval
),
     b AS(SELECT unnest(xpath('/table/feedback/summary/critical/text()', myval))::text AS critical_errors,
                 unnest(xpath('/table/invoices/invoice/row/a_id_integer/text()', myval))::text::integer AS a_id_integer,
                 unnest(xpath('/table/invoices/invoice/row/billing_code_varchar/text()', myval))::text AS billing_code,
                 unnest(xpath('/table/invoices/invoice/row/qty_numeric2/text()', myval))::text::numeric(15,2) AS minutes,
                 unnest(xpath('/table/invoices/invoice/row/units_numeric4/text()', myval))::text::numeric(15,2) AS units,
                 unnest(xpath('/table/invoices/invoice/row/units_adjustment/text()', myval))::text::numeric(15,2) AS units_adjustment,
                 unnest(xpath('/table/invoices/invoice/row/unit_info_text/text()', myval))::text AS unit_info_text,
                 unnest(xpath('/table/invoices/invoice/row/posting_order_numeric2/text()', myval)) AS posting_order_numeric2
          FROM _my_test)
SELECT * FROM b;


UPDATE lysglb.mpy SET mpystipe = current_setting('test.mpystipe') where fdid = 1;

