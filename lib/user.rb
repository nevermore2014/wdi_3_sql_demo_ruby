module GA
  class User
    attr_accessor :id, :name, :age
    def initialize(id, name, age)
      @db_id = id
      @name = name
      @age = age
    end
  end
end
