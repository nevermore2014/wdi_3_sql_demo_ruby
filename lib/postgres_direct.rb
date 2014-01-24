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

    attr_accessor :dbname

    def initialize(dbname)
      @dbname = dbname
    end

    def connect
      @conn = PG.connect(dbname: @dbname)
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

    def create_insert_sql(table_name, col_val_hash)
      col_names ="#{col_val_hash.keys.map(&:to_sym).join(',')}"
      col_val_hash.each do |k, v|
        if v.class.name == "String"
          col_val_hash[k] = "'#{v}'"
        end
      end
      values = "#{col_val_hash.values.join(',')}"
      "INSERT INTO #{table_name} (#{col_names}) VALUES (#{values})"
    end

    def self.select(table_name, where_clause="")
      sql = create_select_sql(table_name, where_clause)
      @conn.exec(sql)
    end

    def self.create_select_sql(table_name, where_clause="")
      sql = "SELECT * FROM #{table_name}"
      sql += " WHERE #{where_clause}" unless where_clause.empty?
    end

    def self.find
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
