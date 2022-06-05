-- See goodx.assistant_000_credit_notes.sql for general description of the test.
--  Test 2 (reverse all codes at once) 
--      2.1  Post invoice with 5 assistant codes 
--      2.2  Reverse entire invoice
                                              
\echo ---------------------------------------------------------------------- 
\echo Test 2 (reverse all codes at once) 
\echo ---------------------------------------------------------------------- 
\echo 2.1  Post invoice with 5 assistant codes 

WITH _my_test AS (SELECT tariffs.post_xml(current_setting('test.invoice_template')::XML) AS myval)
SELECT   unnest(xpath('/table/feedback/summary/critical/text()', myval))::text AS critical_errors 
       , unnest(xpath('/table/invoices/invoice/row/a_id_integer/text()', myval))::text::INTEGER AS a_id_integer
       , unnest(xpath('/table/invoices/invoice/row/billing_code_varchar/text()', myval))::text AS billing_code
       , unnest(xpath('/table/invoices/invoice/row/units_numeric4/text()', myval))::text::NUMERIC(15,2) AS units
       , unnest(xpath('/table/invoices/invoice/row/modified_items_integerarr', myval))  AS modified      
FROM _my_test;

SELECT set_config('test.latest_deb_invnr', invnr, FALSE) <> '' as latest_deb_invnr from lysglb.deboop order by doid desc limit 1;

\echo 2.2  Credit note for all rows at once
WITH _answ AS 
     (SELECT tariffs.post_xml(format('<table>
                                                        <global_data>
                                                            <a_id_integer>1</a_id_integer>
                                                            <delete_temp_integer>0</delete_temp_integer>
                                                            <adir_integer>1</adir_integer>
                                                            <system_user_varchar>AUTO</system_user_varchar>
                                                            <return_billing_lists_info>0</return_billing_lists_info>
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
                                                                <note_varchar>TEST2 Reversal all rows</note_varchar>
                                                                <account_type_integer>3</account_type_integer>
                                                            </credit_note>
                                                        </credit_notes>
                                                    </table>
                                                    ', current_setting('test.period'),  --1
                                                           to_char(now(), 'yyyy-mm-dd'), --2                                                           
                                                           current_setting('test.latest_deb_invnr') --3                                                           
                                )::XML)as cnote)
, b AS (SELECT (xpath('/table/feedback/summary/critical/text()', cnote))[1] as critical,
                xj1.*
         FROM _answ 
         CROSS JOIN LATERAL(SELECT (jsonb_array_elements(unnest(xpath('/table/feedback/summary/feedback_summary/text()', cnote))::text::jsonb))->>'code' as result) xj1  
)
SELECT * FROM b 
WHERE (result = 'OK10') OR (critical is NOT NULL);       

\echo 2.3.  Check that the total turnover is zero on debtors and creditors
WITH a AS (SELECT * FROM lysglb.interaccount_link WHERE source_doc = current_setting('test.latest_deb_invnr') AND source_entity = 1 AND source_type = 1)
, b AS (SELECT b.entity, invnr AS debinvnr, turnover AS deb_turnover, target_doc FROM lysglb.vdebopen b
     JOIN a ON a.source_doc = b.invnr AND a.source_entity = b.entity)
, c AS (SELECT c.entity, debinvnr, target_doc, cre_turnover FROM lysglb.creopen c 
      JOIN a ON c.entity = a.target_entity AND c.debinvnr = a.source_doc AND c.creinvnr = a.target_doc)
SELECT count(DISTINCT debinvnr) AS deb_invoices, count(DISTINCT target_doc) AS cre_invoices, sum(deb_turnover) AS deb_turnover, sum(cre_turnover) AS cre_turnover  
FROM b
LEFT JOIN c USING (entity, debinvnr, target_doc);

