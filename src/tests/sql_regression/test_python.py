from datetime import datetime
import sys 
import getopt
import glob

def get_parameters():
    __all_pars, remainder = getopt.getopt (  sys.argv[1:], '', ['output-dir=','db-tag='] ) 
    _parameters = {'output-dir':'.'}
    print (  f"Parameters {__all_pars}" )
    for opt, arg in __all_pars:
        print( f"""{opt} , {arg}""" )  
        if opt in ('--output-dir'):
           _output_dir = arg
           _parameters['output-dir'] = _output_dir
        if opt in ('--db-tag'):
           _parameters['db-tag'] = arg
    return _parameters
    

def main():
    _parameters = get_parameters()    
    now = datetime.now() # current date and time
    date_time = now.strftime("%m/%d/%Y, %H:%M:%S")
    print(f"""{_parameters['output-dir']}test_info""")
    with open(f"""{_parameters['output-dir']}test_info.txt""", 'w') as f:
        f.write(f"""Test run on {date_time} \nTag {_parameters['db-tag']}""")
        f.close() 
    for f in glob.glob("*.sql"):
        print(f)

if __name__ == "__main__":
    main()   