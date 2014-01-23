require 'pg'
require 'pry'

module GA
  class PostgresDirect

    # From ActiveRecord
    NATIVE_DATABASE_TYPES = {
      primary_key: "serial primary key",
      string: { name: "character varying", limit: 255 },
      text: { name: "text" }, integer: { name: "integer" },
      float: { name: "float" }, decimal: { name: "decimal" },
      datetime: { name: "timestamp" }, timestamp: { name: "timestamp" },
      time: { name: "time" }, date: { name: "date" },
      daterange: { name: "daterange" }, numrange: { name: "numrange" },
      tsrange: { name: "tsrange" },
      tstzrange: { name: "tstzrange" },
      int4range: { name: "int4range" },
      int8range: { name: "int8range" }, binary: { name: "bytea" },
      boolean: { name: "boolean" }, xml: { name: "xml" },
      tsvector: { name: "tsvector" }, hstore: { name: "hstore" },
      inet: { name: "inet" }, cidr: { name: "cidr" },
      macaddr: { name: "macaddr" }, uuid: { name: "uuid" },
      json: { name: "json" }, ltree: { name: "ltree" }
    }

    def initialize(dbname, user="", password="")
      @dbname = dbname
      @user = user
      @password = password
    end

    def connect
      @conn = PG.connect(dbname: @dbname)
    end

    def create_database
#      system("createdb -e #{@dbname} 2> /dev/null")
      system("createdb #{@dbname} 2> /dev/null")
    end

    def drop_database
      system("dropdb #{@dbname} 2> /dev/null")
    end

    def drop_table(table_name)
      @conn.exec("DROP TABLE IF EXISTS #{table_name}")
    end

    def create_table(table_name, columns={})
      @conn.exec(create_table_sql(table_name, columns))
    end

    def create_table_sql(table_name, columns={})
      cols_str = ""
      columns.each do |col_name, col_type|
        cols_str << "#{col_name} #{xlate_datatypes(col_type)},"
      end
      sql = "CREATE TABLE #{table_name} (#{cols_str})"
      # remove the last comma ','
      sql[0..sql.rindex(',')-1] + ")"
    end

    def insert(table_name, col_options={})
      sql = self.create_insert_sql(table_name, col_options)
      @conn.exec(sql)
    end

    def create_insert_sql(table_name, cols_hash)
      col_names ="#{cols_hash.keys.map(&:to_sym).join(',')}"
      cols_hash.each do |k, v|
        if v.class.name == "String"
          cols_hash[k] = "'#{v}'"
        end
      end
      values = "#{cols_hash.values.join(',')}"
      "INSERT INTO #{table_name} (#{col_names}) VALUES (#{values})"
    end

    private

    def xlate_datatypes(col_type)
      db_type = col_type.to_sym

      if db_type == :primary_key
        "serial primary key"
        elsif db_type == :string
          "character varying(255)"
        else
          NATIVE_DATABASE_TYPES[db_type.to_sym][:name]
        end
    end
  end
end
