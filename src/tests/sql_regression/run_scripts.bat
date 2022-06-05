echo off
REM  This batchfile is a Flintstone version of SQL testing process that will hopefully be implemented later.
REM  The idea is to execute various SQL manipulations and check that the result is correct.
REM  In this directory .sql files define the tests, and the corresponding .txt file carries the model answer.
REM  Process (repeatable): 
REM     - sql is run and result is piped into batch file %test_output%.test_output .
REM     - "fc" used to compare the output generated with the model answer.  This sum total of all test results is piped into result.txt
REM     - result.txt typed 
REM Example: goodx.claimclass.sql / goodx.claimclass.txt

REM ------------------
cls
del result.txt
set connstr=-p 5428 -h localhost -d goodxweb -U postgres

REM -------------------------
copy 'create dummy to avoid file not found echo' > dummy.test_output
copy 'create dummy to avoid file not found echo' > dummy.result
del *.test_output
del *.result

rem goto assistant_credit_notes

REM jump to analysis tests if the correct tables have been created.
for /f %%i in ('psql %connstr% -t -c "select count(*) from pg_tables where tablename = $$to_deb_primary$$"') do set _version=%%i
IF %_version%==1 goto analysis_test

REM ------------ Tests exclusively for pre-analysis-tables data

psql %connstr% -f "goodx.regression_test_functions.sql"

set _test_script=goodx.basic_transaction_test
echo ---- Preloading .. %_test_script% (not output)
psql %connstr% -f "%_test_script%.sql"  

set _test_script=goodx.basic_transaction_test
echo ---- REGRESSION TEST %_test_script% >> result.txt
set test_output=%_test_script%.test_output
psql %connstr% -f "%_test_script%.sql"  > %test_output% 
fc %test_output% %_test_script%.txt >> result.txt

goto all_versions

REM ------------ Tests exclusively for analysis-tables data
:analysis_test
set _test_script=goodx.analysis_schema
echo ---- REGRESSION TEST %_test_script% >> result.txt
set test_output=%_test_script%.test_output
psql %connstr% -f "%_test_script%.sql"  > %test_output% 
fc %test_output% %_test_script%.txt >> result.txt

set _test_script=goodx.analysis_cost_center
echo ---- REGRESSION TEST %_test_script% >> result.txt
set test_output=%_test_script%.test_output
psql %connstr% -f "%_test_script%.sql"  > %test_output% 
fc %test_output% %_test_script%.txt >> result.txt

set _test_script=goodx.analysis.definitions
echo ---- REGRESSION TEST %_test_script% >> result.txt
set test_output=%_test_script%.test_output
psql %connstr% -f "%_test_script%.sql"  > %test_output% 
fc %test_output% %_test_script%.txt >> result.txt


REM ------------ Tests for all db versions
:all_versions
set _test_script=goodx.invoices.icd10
echo ---- REGRESSION TEST %_test_script% >> result.txt
set test_output=%_test_script%.test_output
psql %connstr% -f "%_test_script%.sql"  > %test_output% 
fc %test_output% %_test_script%.txt >> result.txt

set _test_script=goodx.invoices.icd10
echo ---- REGRESSION TEST %_test_script% >> result.txt
set test_output=%_test_script%.test_output
psql %connstr% -f "%_test_script%.sql"  > %test_output% 
fc %test_output% %_test_script%.txt >> result.txt

set _test_script=goodx.assistant_anaesthetist
echo ---- REGRESSION TEST %_test_script% >> result.txt
set test_output=%_test_script%.test_output
psql %connstr% -f "%_test_script%.sql"  > %test_output% 
fc %test_output% %_test_script%.txt >> result.txt

set _test_script=goodx.assistant_not_all_codes_selected
echo ---- REGRESSION TEST %_test_script% >> result.txt
set test_output=%_test_script%.test_output
psql %connstr% -f "%_test_script%.sql"  > %test_output% 
fc %test_output% %_test_script%.txt >> result.txt

set _test_script=goodx.cashbook.inte_cashbook
echo ---- REGRESSION TEST %_test_script% >> result.txt
set test_output=%_test_script%.test_output
psql %connstr% -f "%_test_script%.sql"  > %test_output% 
fc %test_output% %_test_script%.txt >> result.txt

set _test_script=goodx.claimclass
echo ---- REGRESSION TEST %_test_script% >> result.txt
set test_output=%_test_script%.test_output
psql %connstr% -f "%_test_script%.sql"  > %test_output% 
fc %test_output% %_test_script%.txt >> result.txt

set _test_script=goodx.invoices.icd10
echo ---- REGRESSION TEST %_test_script% >> result.txt
set test_output=%_test_script%.test_output
psql %connstr% -f "%_test_script%.sql"  > %test_output% 
fc %test_output% %_test_script%.txt >> result.txt

set _test_script=goodx.invoices_unit_reduction_modifier_tests
echo ---- REGRESSION TEST %_test_script% >> result.txt
set test_output=%_test_script%.test_output
psql %connstr% -f "%_test_script%.sql"  > %test_output% 
fc %test_output% %_test_script%.txt >> result.txt

:assistant_credit_notes

set _parameter_script=goodx.assistant_000_credit_notes
set _test_script=goodx.assistant_001_credit_notes
echo ---- REGRESSION TEST %_test_script% >> result.txt
set test_output=%_test_script%.test_output
psql %connstr% -f "%_parameter_script%.sql" -f"%_test_script%.sql"  > %test_output% 
fc %test_output% %_test_script%.txt >> result.txt

set _test_script=goodx.assistant_002_credit_notes
echo ---- REGRESSION TEST %_test_script% >> result.txt
set test_output=%_test_script%.test_output
psql %connstr% -f "%_parameter_script%.sql" -f "%_test_script%.sql"  > %test_output% 
fc %test_output% %_test_script%.txt >> result.txt

set _test_script=goodx.assistant_003_credit_notes
echo ---- REGRESSION TEST %_test_script% >> result.txt
set test_output=%_test_script%.test_output
psql %connstr% -f "%_parameter_script%.sql" -f "%_test_script%.sql"  > %test_output% 
fc %test_output% %_test_script%.txt >> result.txt

set _test_script=goodx.assistant_004_credit_notes
echo ---- REGRESSION TEST %_test_script% >> result.txt
set test_output=%_test_script%.test_output
psql %connstr% -f "%_parameter_script%.sql" -f "%_test_script%.sql"  > %test_output% 
fc %test_output% %_test_script%.txt >> result.txt

set _test_script=goodx.assistant_005_credit_notes
echo ---- REGRESSION TEST %_test_script% >> result.txt
set test_output=%_test_script%.test_output
psql %connstr% -f "%_parameter_script%.sql" -f "%_test_script%.sql"  > %test_output% 
fc %test_output% %_test_script%.txt >> result.txt

set _test_script=goodx.assistant_anaesthetist_with_weight
echo ---- %_test_script% >> result.txt
set test_output=%_test_script%.test_output
psql %connstr% -f "%_test_script%.sql"  > %test_output% 
fc %test_output% %_test_script%.txt >> result.txt

set _test_script=goodx.claimclass
echo ---- %_test_script% >> result.txt
set test_output=%_test_script%.test_output
psql %connstr% -f "%_test_script%.sql"  > %test_output% 
fc %test_output% %_test_script%.txt >> result.txt



REM ---- END Assistant creditor credit notes test group


REM -- Add other scripts here...
REM set _test_script=goodx.claimclass
REM set test_output=%_test_script%.test_output
REM echo ---- REGRESSION TEST %_test_script% >> result.txt
REM psql %connstr% -f "%_test_script%.sql"  > %test_output% 
REM fc %test_output% %_test_script%.txt >> result.txt
echo --------------------------[Result]----------------------------------------------
type result.txt



:end
echo "End of script"