### THIS SCRIPT REPLACES FUNCTION lysglb.__sfd_update_tariff_price_table_for_year

import psycopg2

def do_connection():
    _user = 'postgres'
    _password = 'masterkey'
    _host = 'localhost'
    _port = '5432'
    #_port = '5428'    
    _database = 'goodxweb'    
    return psycopg2.connect(user = _user,
                                  password = _password,
                                  host = _host,
                                  port = _port,
                                  database = _database)                                