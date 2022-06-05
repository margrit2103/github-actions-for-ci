import filecmp
import glob

d1 = "./goodx_repo/_dump/sql_regression/answ"
d2 = "./goodx_repo/_dump/sql_regression/model_answ"
files = glob.glob(f"{d2}/*.txt")

# shallow comparison
match, mismatch, errors = filecmp.cmpfiles(d1, d2, files)
print('Shallow comparison')
print("Matched results:", match)
print("Mismatched results:", mismatch)
print("Errors:", errors)
if len(errors) > 0:
    raise Exception("**** Files not found in either the model or answ folders") 
if len(mismatch) > 0:
    raise Exception("**** Test answer does not correspond to model answer") 

# deep comparison
#match, mismatch, errors = filecmp.cmpfiles(d1, d2, files, shallow=False)
#print('Deep comparison')
#print("Match:", match)
#print("Mismatch:", mismatch)
#print("Errors:", errors)
