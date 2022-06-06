# This script does a shallow comparison of the delphi sql-regression tests results.
# The results are documented in the dump
#   - test_result.txt summarizes the result
#   - /answ result of the actual test 
#   - /model_answ contains the expected result.
#
# Script parameters:  --db-tag quantsolutions/testdb:tagname 
#                     (Example: --db-tag quantsolutions/testdb:latest)

 
import filecmp
import glob
import os
from datetime import datetime
import standard_parameters

def main():
    _parameters = standard_parameters.get_parameters()    
    result_path = "./goodx_repo/_dump/sql_regression"
    #result_path = "c:/xxx"


    result_summary_file = f"{result_path}/test_result.txt"

    now = datetime.now() # current date and time
    date_time = now.strftime("%m/%d/%Y, %H:%M:%S")


    d1 = f"{result_path}/answ"
    d2 = f"{result_path}/model_answ"


    files=[]
    for fileName_relative in glob.glob(d2+"**/*.txt",recursive=False):       
        files.append(os.path.basename(fileName_relative))


    # shallow comparison
    compare_failed = False
    match, mismatch, errors = filecmp.cmpfiles(d1, d2, files)
    with open(result_summary_file, 'w') as f:
        try:
            f.write('--[Test details]---------------------------\n')
            f.write(f"Test run on {date_time} \nDocker {_parameters['db-tag']}\n\n")
            f.write('--[Test result]---------------------------\n')
            f.write('Shallow comparison\n')
            #f.write(f"Files compared: {files}\n")
            f.write(f"Matched results: {match}\n")
            f.write(f"Mismatched results: {mismatch}\n")        
            f.write(f"Errors: {errors}\n")
            _result = '\n'
            if len(errors) > 0:
                _result  = f"{_result}**** Files missing in either the model or answ folders\n"
                compare_failed = True
            if len(mismatch) > 0:
                _result  = f"{_result}**** Test answer does not correspond to model answer\n"
            if _result != '':   
                compare_failed = True        
                f.write(_result)            
            else:
                f.write('**** Test successful. OK\n')    
        except:
            raise Exception(f"**** SCRIPT FAILURE {_result}") 
        finally:        
            f.close()
            with open(result_summary_file, 'r') as f:
                file_contents = f.read()
                f.close()
                print(file_contents)

    if compare_failed:
        raise Exception(f"**** Test failed !!!!")     
        
if __name__ == "__main__":
    main()          

# deep comparison
#match, mismatch, errors = filecmp.cmpfiles(d1, d2, files, shallow=False)
#print('Deep comparison')
#print("Match:", match)
#print("Mismatch:", mismatch)
#print("Errors:", errors)
