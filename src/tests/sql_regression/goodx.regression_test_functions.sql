--- This regression file added for non analysis table regression_tests. Remove later (Loaded as part of analysis-schema for analysis DDL)

CREATE SCHEMA IF NOT EXISTS analysis_diagnostic;

CREATE OR REPLACE FUNCTION analysis_diagnostic.check_ledger_movement_totals( IN _year INTEGER, OUT _d NUMERIC, OUT _c NUMERIC, OUT _ok BOOLEAN )
RETURNS record 
LANGUAGE SQL
AS 
$check_manleer_totals$
/* Check if "manleer" movement balances for a specific year. Simulates a trial balance using the manleer entries.
If this test fails it probably indicates that something is failing in trigger analysis.analysis_movement_tr()
*/
    WITH a AS (SELECT kode, reknr, mgroottotaal FROM lysglb.v_ledger_acc_types                 
               CROSS JOIN LATERAL(  SELECT reknr, mgroottotaal FROM lysglb.get_mantable( 1, $1, kode, 1 )  ) xj1)
    , kas AS (SELECT 'KAS' AS kode, reknr, mgroottotaal FROM lysglb.get_mantable(1, $1, 'KAS', 1))                
    , b AS (SELECT kode, reknr,  sum( mgroottotaal ) AS mgroottotaal FROM a GROUP BY kode, reknr  UNION SELECT kode, reknr,  sum( mgroottotaal ) AS mgroottotaal FROM kas GROUP BY kode, reknr)
    , c AS (SELECT b.*, 
                   CASE WHEN kode IN ( 'INC', 'LOA', 'CLI', 'SCR' ) THEN CASE WHEN mgroottotaal < 0 THEN abs(mgroottotaal)
                                                                    ELSE 0 END                                                               
                        ELSE  CASE WHEN mgroottotaal < 0 THEN 0
                                                               ELSE abs(mgroottotaal) END
                   END AS _d, 
                   CASE WHEN kode IN ( 'INC', 'LOA', 'CLI', 'SCR' ) THEN CASE WHEN mgroottotaal < 0 THEN 0
                                                                    ELSE abs(mgroottotaal) END
                   ELSE CASE WHEN mgroottotaal < 0 THEN abs(mgroottotaal)
                                                   ELSE 0 END
                   END AS _c
            FROM  b)
    SELECT  sum( _d), sum( _c ) , sum( _d) IS NOT DISTINCT FROM sum( _c ) FROM c;
$check_manleer_totals$;

CREATE OR REPLACE FUNCTION analysis_diagnostic.check_major_control_totals( IN entities INTEGER[], OUT entity integer, OUT deb_s_vs_man_ok boolean,OUT deb_s_vs_cas1_ok boolean,OUT deb_s_vs_deboop_ok boolean,OUT deb_s_vs_debfopen_ok boolean,OUT deb_s_vs_debfdetail_ok boolean,OUT cre_s_vs_cli2_ok boolean,OUT cre_s_vs_man_ok boolean,OUT cre_s_vs_creopen_ok boolean,OUT cashbook_ok boolean,OUT analysis_ok boolean )
RETURNS SETOF RECORD 
LANGUAGE PLPGSQL
AS
$check_major_control_totals$
DECLARE _tempschema TEXT;
BEGIN
/* Check major control totals.  Send back comparisons as boolean values for sql-regression*/
    DROP TABLE IF EXISTS diagnostics_check_major_control_totals;
    PERFORM utility.mct_all('diagnostics_check_major_control_totals',ARRAY[1,2,3,4], entities );
    
    SELECT nspname FROM pg_namespace WHERE  oid = pg_my_temp_schema() INTO _tempschema;
    PERFORM utility.create_column(_tempschema, 'diagnostics_check_major_control_totals', 'cashooptot_3', 'NUMERIC', 'null');
    PERFORM utility.create_column(_tempschema, 'diagnostics_check_major_control_totals', 'ontoop_3', 'NUMERIC', 'null');
    PERFORM utility.create_column(_tempschema, 'diagnostics_check_major_control_totals', 'dtot_4', 'NUMERIC', 'null');
    PERFORM utility.create_column(_tempschema, 'diagnostics_check_major_control_totals', 'stot_4', 'NUMERIC', 'null');
    
    RETURN QUERY SELECT   a.entity, 
                          (stotal_1 IS NOT DISTINCT FROM mantot_1) AS deb_s_vs_man_ok
                        , (stotal_1 IS NOT DISTINCT FROM controlacc_1) AS deb_s_vs_cas1_ok
                        , (stotal_1 IS NOT DISTINCT FROM debcre_open_1) AS deb_s_vs_deboop_ok
                        , (stotal_1 IS NOT DISTINCT FROM debfopentot_1) AS deb_s_vs_debfopen_ok
                        , (stotal_1 IS NOT DISTINCT FROM debfdettot_1) AS deb_s_vs_debfdetail_ok
                        , (stotal_2 IS NOT DISTINCT FROM controlacc_2) AS cre_s_vs_cli2_ok
                        , (stotal_2 IS NOT DISTINCT FROM mantot_2) AS cre_s_vs_man_ok
                        , (stotal_2 IS NOT DISTINCT FROM debcre_open_2) AS cre_s_vs_creopen_ok
                        , (cashooptot_3 IS NOT DISTINCT FROM ontoop_3) AS cashbook_ok
                        , (dtot_4 IS NOT DISTINCT FROM stot_4) AS analysis_ok
                 FROM diagnostics_check_major_control_totals a;
END;
$check_major_control_totals$;
