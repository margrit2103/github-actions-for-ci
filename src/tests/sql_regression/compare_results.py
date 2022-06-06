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
match, mismatch, errors = filecmp.cmpfiles(d1, d2, files)
print(f"{result_path}/test_result.txt")
with open(result_summary_file, 'w') as f:
    try:
        f.write('readme')
        f.write('Shallow comparison')
        f.write(f"File compared: {files}")
        f.write(f"Matched results: {match}")
        f.write(f"Mismatched results: {mismatch}")
        
        f.write(f"Errors: {errors}")

        _result = ''
        if len(errors) > 0:
            _result  = f"{_result} \n**** Files not found in either the model or answ folders"
        if len(mismatch) > 0:
            _result  = f"{_result} \n**** Test answer does not correspond to model answer"
        if _result != '':    
            f.write(_result)            
        else:
            f.write('OK')    
    except:
        raise Exception(_result) 
    finally:        
        f.close()
        with open(result_summary_file, 'r') as f:
            file_contents = f.read()
            f.close()
            print(file_contents)
        
        

# deep comparison
#match, mismatch, errors = filecmp.cmpfiles(d1, d2, files, shallow=False)
#print('Deep comparison')
#print("Match:", match)
#print("Mismatch:", mismatch)
#print("Errors:", errors)
