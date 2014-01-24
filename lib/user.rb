require_relative './postgres_direct'
require 'pry'

module GA
  class User < PostgresDirect
    attr_accessor :id, :name, :age

    def initialize(name, age)
      @name = name
      @age = age
    end

    def save
      # will create a new row!! for now
      # self.update('users',id: @id,  age: @age, name: @name)
      self.insert('users', age: @age, name: @name)
    end

    def self.find_by_id(id)
      res = self.select('users', "id = #{id}")
      user_hash = res.first
      user = GA::User.new(user_hash["id"], user_hash["name"], user_hash["age"])
      user.id = user_hash['id']
    end

    def self.find_all
      res = self.select('users')
      res.map do |user_hash|
        # built the class name dynamically!
        GA::User.new(user_hash["id"], user_hash["name"], user_hash["age"])
      end
    end
  end
end
