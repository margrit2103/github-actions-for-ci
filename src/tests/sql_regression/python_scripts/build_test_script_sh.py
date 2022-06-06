from datetime import datetime
import sys 
import getopt
import glob
import dbconnection, standard_parameters
import psycopg2
import os


def add_test(f,_testname,_text):
    f.write(f"echo Testing {_testname}")
    f.write(f'psql -U postgres -d goodxweb -c"SET client_min_messages TO WARNING;" {_text}\n')
    
   
def main():
    _parameters = standard_parameters.get_parameters()    
    print( _parameters )
    sh_file = "./goodx_repo/_dump/test.sh"
    #sh_file = 'c:/aaa/test.sh'
    analysis_file_tests=['goodx.analysis_schema','goodx.analysis_cost_center','goodx.analysis.definitions']
    year_schema_file_tests=['goodx.regression_test_functions','goodx.basic_transaction_test']
    assistant_credit_note_tests=['goodx.assistant_001_credit_notes','goodx.assistant_002_credit_notes','goodx.assistant_003_credit_notes','goodx.assistant_004_credit_notes','goodx.assistant_005_credit_notes']
    parameter_scripts=['goodx.assistant_000_credit_notes']
    special_tests=analysis_file_tests+year_schema_file_tests+assistant_credit_note_tests+parameter_scripts
    

    connection = dbconnection.do_connection()
    try:
        cursor = connection.cursor()            
        cursor.execute("SELECT EXISTS(SELECT FROM pg_tables WHERE tablename = 'to_deb_primary')::text")            
        analysis_record = cursor.fetchone()[0]
        print( analysis_record )
        with open(_parameters["sh-file"], 'w') as f:
            #load different script for analysis-table project
            if analysis_record == 'true':
                for _test in analysis_file_tests: 
                    add_test(f, _test, f'-f "{_parameters["test-dir"]}/{_test}.sql" > {_parameters["answ-dir"]}/{_test}.txt\n')
            else: 
                for _test in year_schema_file_tests:
                    add_test(f, _test, f'-f "{_parameters["test-dir"]}/{_test}.sql" > {_parameters["answ-dir"]}/{_test}.txt\n')
            
            #parameter script goodx.assistant_000_credit_notes.sql loads posting transaction template 
            for _test in assistant_credit_note_tests:
                add_test(f, _test, f'-f "{_parameters["test-dir"]}/goodx.assistant_000_credit_notes.sql" -f "{_parameters["test-dir"]}/{_test}.sql" > {_parameters["answ-dir"]}/{_test}.txt\n')
                
            #load remaining scripts (leave out special_tests)    
            for fileName_relative in glob.glob(f"{_parameters['test-dir']}**/*.sql",recursive=True): 
                _test = os.path.basename(fileName_relative).replace('.sql','')            
                if not(_test in special_tests):
                    add_test(f, _test, f'-f "{_parameters["test-dir"]}/{_test}.sql" > {_parameters["answ-dir"]}/{_test}.txt\n')

            f.close()
    finally:
        if(connection.closed == 0 ):
            cursor.close()
            connection.close()    

if __name__ == "__main__":
    main()   