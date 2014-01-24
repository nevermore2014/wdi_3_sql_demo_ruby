require 'pg'

dbname = "pgtest2"

puts 'What is the name?'
name = gets.chomp

puts 'How old are your?'
age = gets.chomp.to_i

puts 'what your phone number ?'
phone = gets.chomp

puts 'what is your email address?'
email = gets.chomp


insert_sql = "INSERT INTO users (name, age, phone, email) VALUES ('#{name}', #{age}, '#{phone}', '#{email}')"
conn = PG.connect(dbname: dbname)

res = conn.exec(insert_sql)

puts "result of the insert is #{res}"