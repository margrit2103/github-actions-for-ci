import sys
import getopt


__all_pars, remainder = getopt.getopt (  sys.argv[1:], '', ['output-dir=','db-tag=','test-dir=','answ-dir=','sh-file='] ) 


def get_parameters():
    _parameters = {'output-dir':'.'}
    print (  f"Parameters {__all_pars}" )
    for opt, arg in __all_pars:
        print( f"""{opt} , {arg}""" )  
        if opt in ('--output-dir'):
           _output_dir = arg
           _parameters['output-dir'] = _output_dir
        if opt in ('--db-tag'):
           _parameters['db-tag'] = arg
        if opt in ('--test-dir'):
           _parameters['test-dir'] = arg           
        if opt in ('--answ-dir'):
           _parameters['answ-dir'] = arg     
        if opt in ('--sh-file'):
           _parameters['sh-file'] = arg            
    return _parameters
    