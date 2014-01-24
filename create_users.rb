require_relative './lib/user'
require_relative './lib/manage_db'
require 'pry'

tom = GA::User.new("tom", 33)

dbname = "tomdb"
db = GA::ManageDB.new(dbname)
db.drop_database
db.create_database

tom.dbname = dbname
GA::User.connect(dbname)
binding.pry
tom.connect

tom.create_table('users', id: 'primary_key', name: 'text', age: 'integer')
tom.save

# dbname = "tomdb"
# tom.connect(dbname)


