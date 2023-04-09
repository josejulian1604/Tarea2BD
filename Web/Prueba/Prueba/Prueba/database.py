import pyodbc

# Set up connection details
server = 'DESKTOP-LHKIQDK'
database = 'Tarea1_2023'
username = 'sa'
password = 'CowardlySpice16'

# Create a connection to the database
conn = pyodbc.connect('DRIVER={SQL Server};SERVER='+server+';DATABASE='+database+';UID='+username+';PWD='+ password)

# Create a cursor object to execute SQL statements
cursor = conn.cursor()
