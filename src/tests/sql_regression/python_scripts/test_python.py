from datetime import datetime
import sys 
import getopt
import glob
import psycopg2

def get_parameters():
    __all_pars, remainder = getopt.getopt (  sys.argv[1:], '', ['output-dir=','db-tag=','test-dir='] ) 
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
    return _parameters
    
def do_connection():
    _user = 'postgres'
    _password = 'masterkey'
    _host = 'localhost'
    _port = '5432'
    _database = 'goodxweb'
    return psycopg2.connect(user = _user,
                                  password = _password,
                                  host = _host,
                                  port = _port,
                                  database = _database)    
    

def main():
    _parameters = get_parameters()    
    now = datetime.now() # current date and time
    date_time = now.strftime("%m/%d/%Y, %H:%M:%S")
    print(f"{_parameters['output-dir']}test_info")
    with open(f"{_parameters['output-dir']}test_info.txt", 'w') as f:
        f.write(f"Test run on {date_time} \nDocker {_parameters['db-tag']}")
        f.close() 
    do_connection()
    cursor = connection.cursor()    
    try:
        for f in glob.glob(f"{_parameters['test-dir']}*.sql"):
            try:
                print(f)
                cursor.execute(open(f"{_parameters['test-dir']}{f}", "r").read())
        except (Exception, psycopg2.Error) as error :
            print(f"Error while executing {f}")
    finally:
        if(connection.closed == 0 ):
            cursor.close()
            connection.close()

if __name__ == "__main__":
    main()   