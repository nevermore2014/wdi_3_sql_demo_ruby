require 'pg'

def show_status(res)
  status = res.result_status
  status_str = res.res_status(status)

  puts "status is #{status}"
  puts "status_str is #{status_str}"
end

dbname = "ga_test_1"
system("dropdb #{dbname} 2> /dev/null")
system("createdb #{dbname} 2> /dev/null")

conn = PG.connect(dbname: dbname)

# Create table
sql = "CREATE TABLE users (id serial primary key,age integer,name character varying(255))"
res = conn.exec(sql)
show_status(res)

# Insert into table
age = 33
name = "joe"

sql = "INSERT INTO users (age,name) VALUES (#{age},'#{name}')"
res = conn.exec(sql)
show_status(res)

5.times do |i|
  age += i * 4
  name = "person_#{i}"
  sql = "INSERT INTO users (age,name) VALUES (#{age},'#{name}')"
  res = conn.exec(sql)
end


sql = "SELECT * FROM users WHERE age > 43"
res = conn.exec(sql)
show_status(res)
res.each do |result|
  puts "result is #{result}"
end