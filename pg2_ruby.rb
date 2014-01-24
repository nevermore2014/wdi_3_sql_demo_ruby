require 'pg'

dbname = "pgtest2"

system("dropdb #{dbname} 2> /dev/null")
system("createdb #{dbname} 2> /dev/null")

conn = PG.connect(dbname: dbname)

conn.exec("CREATE TABLE users (id serial primary key, name text, age integer, phone text, email text)")





