from datetime import datetime
import sys 
import getopt
import glob
import dbconnection, standard_parameters
import psycopg2

   
def main():
    _parameters = standard_parameters.get_parameters()    
    now = datetime.now() # current date and time
    date_time = now.strftime("%m/%d/%Y, %H:%M:%S")
    print(f"{_parameters['output-dir']}test_info")
    with open(f"{_parameters['output-dir']}test_info.txt", 'w') as f:
        f.write(f"Test run on {date_time} \nDocker {_parameters['db-tag']}")
        f.close() 
    dbconnection.do_connection()
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