import filecmp
import glob
import os

result_path = "./goodx_repo/_dump/sql_regression"
#result_path = "c:/xxx"

result_summary_file = f"{result_path}/test_result.txt"



d1 = f"{result_path}/answ"
d2 = f"{result_path}/model_answ"



files=[]
for fileName_relative in glob.glob(d2+"**/*.txt",recursive=True):       
    files.append(os.path.basename(fileName_relative))

# shallow comparison
compare_failed = False
match, mismatch, errors = filecmp.cmpfiles(d1, d2, files)
print(f"{result_path}/test_result.txt")
with open(result_summary_file, 'w') as f:
    try:
        f.write('--[Test result]---------------------------\n')
        f.write('Shallow comparison\n')
        f.write(f"File compared: {files}\n")
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
        raise Exception(f"SCRIPT FAILURE {_result}") 
    finally:        
        f.close()
        with open(result_summary_file, 'r') as f:
            file_contents = f.read()
            f.close()
            print(file_contents)

if compare_failed:
    raise Exception(f"**** Test failed")     
        
        

# deep comparison
#match, mismatch, errors = filecmp.cmpfiles(d1, d2, files, shallow=False)
#print('Deep comparison')
#print("Match:", match)
#print("Mismatch:", mismatch)
#print("Errors:", errors)
