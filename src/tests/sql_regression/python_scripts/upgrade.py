import os
import configparser
import psycopg2
import psycopg2.extras

directory = '.'

def load_config(filename):
    """
        Load and return configuration from the specified file.
    """
    parser = configparser.ConfigParser()
    if not parser.read(filename):
        raise Exception('Could not load config from %s' % filename)
    config = parser._sections
    for key in config['db'].keys():
        k = 'DB%s' % key.upper()
        if os.environ.get(k):
            config['db'][key] = os.environ[k]
    return config


config = load_config( 'upgrade.cfg')
print( config )
db = dict(config['db'])
conn = psycopg2.connect(host=db['host'], port=db['port'], user=db['user'], password=db['pass'], dbname=db['name'])
conn.autocommit = True
cur = conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor)

    
for root, dirs, files in os.walk(directory):
    for file in files:
        if file.endswith('.sql'):
            if not file.startswith( 'clear'):
                print( f""" -------- {file}""" )
                #open(file, 'r').read()
                content = open(file, 'r').read()
                #print( content )
                cur.execute(content)
            