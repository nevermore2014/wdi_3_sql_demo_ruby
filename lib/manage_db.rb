require 'pg'

module GA
  class ManageDB
    attr_accessor :dbname, :user

    def initialize(dbname, user="", password="")
      @dbname = dbname
      @user = user
      @password = password
    end

    def connect
      @conn = PG.connect(dbname: @dbname)
    end

    def create_database
      #system("createdb -e #{@dbname} 2> /dev/null")
      system("createdb #{@dbname} 2> /dev/null")
    end

    def drop_database
      system("dropdb #{@dbname} 2> /dev/null")
    end
  end
end