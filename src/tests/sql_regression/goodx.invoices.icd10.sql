\echo ICD-10 tests

\echo Parameters: This test assumes that a goodx1 directory exists, and that at least one debtor has been created and is ready for posting. 

SELECT set_config( 'test.debtor', min( fdreknr )::TEXT, false ) <> '' as _debtor FROM goodx1.debmstr; 

SELECT set_config( 'test.xml', '<table>
    <global_data>
        <a_id_integer>1</a_id_integer>
        <delete_temp_integer>0</delete_temp_integer>
        <adir_integer>1</adir_integer>
        <return_billing_lists_info>0</return_billing_lists_info>
        %1$s
    </global_data>
    <invoices>
        <invoice>
            <a_id_integer>1</a_id_integer>
            <debtor_a_id_integer>1</debtor_a_id_integer>
            <patient_a_id_integer>1</patient_a_id_integer>
            <treating_doctor_a_id_integer>1</treating_doctor_a_id_integer>
            <service_centre_a_id_integer>1</service_centre_a_id_integer>
            <maid_option_varchar>DISC53</maid_option_varchar>
            <referring_doctor_a_id_integer>2</referring_doctor_a_id_integer>
            <linking_doc_varchar/>
            %4$s
            <row>
                <a_id_integer>1</a_id_integer>
                
                <_3rd_party_id_varchar>001</_3rd_party_id_varchar>
                <service_centre_a_id_integer>1</service_centre_a_id_integer>
                <treating_doctor_a_id_integer>1</treating_doctor_a_id_integer>
                <referring_doctor_a_id_integer>2</referring_doctor_a_id_integer>
                
                <srec_a_id_integer>1</srec_a_id_integer>
                <billing_code_varchar>0190</billing_code_varchar>
                %3$s
            </row>
        </invoice>
    </invoices>
    <debtors>
        <debtor>
            <a_id_integer>1</a_id_integer>
            <adir_integer>1</adir_integer>
            <goodx_id_integer>%2$s</goodx_id_integer>
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
            <goodx_id_integer>2</goodx_id_integer>
        </doctor>
    </doctors>
    <service_centres>
        <service_centre>
            <a_id_integer>1</a_id_integer>
            <goodx_id_integer>1</goodx_id_integer>
        </service_centre>
    </service_centres>
</table>
', false ) <> '' as _xml_template_created;

SELECT set_config( 'test.date_string', format( '<date_date>%1$sT00:00:00</date_date>', to_char( now() ,'yyyy-mm-dd') ), FALSE) <> '' as date_string_set;


\echo  ----------------------------------------------------- Invalid ICD-10 rule loaded on DB
SELECT set_config( 'test.ICD_string', 'A01.1'::TEXT, false );
select lysglb.update_toggles(1, 'icd10_no_validation', '5');

WITH _payload as ( select format( current_setting( 'test.xml' ), '', current_setting( 'test.debtor' ), current_setting( 'test.ICD_string'), current_setting( 'test.date_string' ) ) as _xml )
SELECT xpath ( '/table/feedback/row/code/text()', tariffs.validate_xml( _xml::XML ) )::TEXT[] @> ARRAY['DIAG01']::text[] as _found_invalid_setting FROM _payload;

\echo ----------------------------------------------------- SET ICD-10 string to NULL: Check that system returns DIAG04 for forced_validation and ignores for other settings
SELECT set_config( 'test.ICD_string', ''::TEXT, false );

\echo NO ICD-10 codes in XML. Do not check ICD-10 codes (hard-coded instruction, as posted in desktop system)
WITH _payload as ( select format( current_setting( 'test.xml' ), '<use_input_diagnosis_integer>1</use_input_diagnosis_integer>', current_setting( 'test.debtor' ), current_setting( 'test.ICD_string'), current_setting( 'test.date_string' ) ) as _xml )
SELECT xpath ( '/table/feedback/row/code/text()', tariffs.validate_xml( _xml::XML ) )::TEXT[] @> ARRAY['DIAG02']::text[] as _found_diag02 FROM _payload;

\echo NO ICD-10 codes in XML. Do not check ICD-10 codes (as configured at site for entity)
select lysglb.update_toggles(1, 'icd10_no_validation', '1');

WITH _payload as ( select format( current_setting( 'test.xml' ), '', current_setting( 'test.debtor' ), current_setting( 'test.ICD_string'), current_setting( 'test.date_string' ) ) as _xml )
SELECT xpath ( '/table/feedback/row/code/text()', tariffs.validate_xml( _xml::XML ) )::TEXT[] @> ARRAY['DIAG03']::text[] as _found_diag03 FROM _payload;

\echo NO ICD-10 codes in XML. Check ICD-10 codes (as configured at site for entity)
select lysglb.update_toggles(1, 'icd10_no_validation', '0');

WITH _payload as ( select format( current_setting( 'test.xml' ), '', current_setting( 'test.debtor' ), current_setting( 'test.ICD_string'), current_setting( 'test.date_string' ) ) as _xml )
SELECT xpath ( '/table/feedback/row/code/text()', tariffs.validate_xml( _xml::XML ) )::TEXT[] @> ARRAY['DIAG04']::text[] as _found_diag04 FROM _payload;


\echo ----------------------------------------------------- SET INVALID ICD-10: only return error for forced_validation
SELECT set_config( 'test.ICD_string', '<icdlist_varchararr><element>INVALID ICD-10</element></icdlist_varchararr>'::TEXT, false );

\echo NO ICD-10 codes in XML. Do not check ICD-10 codes (hard-coded instruction, as posted in desktop system)
WITH _payload as ( select format( current_setting( 'test.xml' ), '<use_input_diagnosis_integer>1</use_input_diagnosis_integer>', current_setting( 'test.debtor' ), current_setting( 'test.ICD_string'), current_setting( 'test.date_string' ) ) as _xml )
SELECT xpath ( '/table/feedback/row/code/text()', tariffs.validate_xml( _xml::XML ) )::TEXT[] @> ARRAY['DIAG02']::text[] as _found_diag02  FROM _payload;

\echo NO ICD-10 codes in XML. Do not check ICD-10 codes (as configured at site for entity)
select lysglb.update_toggles(1, 'icd10_no_validation', '1');

WITH _payload as ( select format( current_setting( 'test.xml' ), '', current_setting( 'test.debtor' ), current_setting( 'test.ICD_string'), current_setting( 'test.date_string' ) ) as _xml )
SELECT xpath ( '/table/feedback/row/code/text()', tariffs.validate_xml( _xml::XML ) )::TEXT[] @> ARRAY['DIAG03']::text[] as _found_diag03 FROM _payload;

\echo NO ICD-10 codes in XML. Check ICD-10 codes (as configured at site for entity)
select lysglb.update_toggles(1, 'icd10_no_validation', '0');

WITH _payload as ( select format( current_setting( 'test.xml' ), '', current_setting( 'test.debtor' ), current_setting( 'test.ICD_string'), current_setting( 'test.date_string' ) ) as _xml )
SELECT xpath ( '/table/feedback/row/code/text()', tariffs.validate_xml( _xml::XML ) )::TEXT[] @> ARRAY['ICD01']::text[] as _found_icd01 FROM _payload;


\echo ----------------------------------------------------- SET VALID ICD-10: only checked for forced_validation
SELECT set_config( 'test.ICD_string', '<icdlist_varchararr><element>A01.1</element></icdlist_varchararr>'::TEXT, false );

\echo NO ICD-10 codes in XML. Do not check ICD-10 codes (hard-coded instruction, as posted in desktop system)
WITH _payload as ( select format( current_setting( 'test.xml' ), '<use_input_diagnosis_integer>1</use_input_diagnosis_integer>', current_setting( 'test.debtor' ), current_setting( 'test.ICD_string'), current_setting( 'test.date_string' ) ) as _xml )
SELECT xpath ( '/table/feedback/row/code/text()', tariffs.validate_xml( _xml::XML ) )::TEXT[] @> ARRAY['DIAG02']::text[] as _found_diag02 FROM _payload;

\echo NO ICD-10 codes in XML. Do not check ICD-10 codes (as configured at site for entity)
select lysglb.update_toggles(1, 'icd10_no_validation', '1');

WITH _payload as ( select format( current_setting( 'test.xml' ), '', current_setting( 'test.debtor' ), current_setting( 'test.ICD_string'), current_setting( 'test.date_string' ) ) as _xml )
SELECT xpath ( '/table/feedback/row/code/text()', tariffs.validate_xml( _xml::XML ) )::TEXT[] @> ARRAY['DIAG03']::text[] as _found_diag03 FROM _payload;

\echo NO ICD-10 codes in XML. Check ICD-10 codes (as configured at site for entity)
select lysglb.update_toggles(1, 'icd10_no_validation', '0');

WITH _payload as ( select format( current_setting( 'test.xml' ), '', current_setting( 'test.debtor' ), current_setting( 'test.ICD_string'), current_setting( 'test.date_string' ) ) as _xml )
    , _result as ( SELECT xpath ( '/table/feedback/row/code/text()', tariffs.validate_xml( _xml::XML ) )::TEXT[]::TEXT AS _res FROM _payload )
    SELECT strpos( _res,'ICD') = 0 as _no_icd_10_error,  strpos( _res, 'DIAG' ) = 0 AS _no_diagnosis_error FROM _result;
     
