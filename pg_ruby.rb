require 'pg'

dbname = "pgtest1"

# Called to command line utilities
system("dropdb #{dbname} 2> /dev/null")
system("createdb #{dbname} 2> /dev/null")
# %x{"createdb #{dbname}"}

conn = PG.connect(dbname: dbname)

conn.exec("CREATE TABLE users (id serial primary key, age integer, name text)")

insert_sql = "INSERT INTO users (age, name)VALUES (23, 'Jill')"
res = conn.exec(insert_sql)

puts "result of the insert is #{res}"

5.times do |i|
	AGE = 20 + (i*4)
	name = "person_#{i}"
	insert_sql = "INSERT INTO users (age, name) VALUES (#{AGE}, '#{name}')"
	res = conn.exec(insert_sql)
	puts "result of the insert is #{res.result_status}"

end


# Select the row where id is 2
select_sql = "SELECT * FROM users WHERE id = 2"
res = conn.exec(select_sql)

puts " resutls class is #{res.class.name}"

res.each do |result|
	puts "result is #{result}"
end











