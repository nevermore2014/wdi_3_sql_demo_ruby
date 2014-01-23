require_relative './spec_helper'
require_relative '../lib/postgres_direct'
require_relative '../lib/user'

describe GA::PostgresDirect do
  let(:dbname) { 'pg_direct_test'}

  it "#new" do
    expect(GA::PostgresDirect.new(dbname)).to be_an_instance_of GA::PostgresDirect
  end

  subject { GA::PostgresDirect.new(dbname) }
  describe "with an existing DB" do
    before(:each) do
      system("createdb #{dbname} 2> /dev/null")
    end

    it "#connect" do
      conn = subject.connect
      expect(conn).to be_an_instance_of PG::Connection
      expect(conn.status).to eq 0
    end

    describe "with a DB connection" do
      subject do
        pd = GA::PostgresDirect.new(dbname)
        pd.connect
        pd
      end
      let(:table_name) {"users"}
      let(:columns) { {id: 'primary_key', age: 'integer', name: 'string'}}
      let(:expected_sql) do
        "CREATE TABLE users (id serial primary key,age integer,name character varying(255))"
      end

      before(:each) do
        subject.drop_table(table_name)
      end

      it "#create_table_sql" do
        sql = subject.create_table_sql(table_name, columns )
        expect(sql).to eq expected_sql
      end

      it "#create_table" do
        expect(subject.create_table(table_name, columns )).to be_an_instance_of PG::Result
      end

      describe "with a users table" do
        let(:name) {'joe'}
        let(:age) { 33}
        let(:expected_sql) {"INSERT INTO users (age,name) VALUES (#{age},'#{name}')"}

        before(:each) do
          subject.create_table(table_name, columns )
        end

        it "#create_insert_sql" do
          result = subject.create_insert_sql(table_name, age: age, name: name)
          expect(result).to eq expected_sql
        end

        it "#insert" do
          result = subject.insert(table_name, age: age, name: name)
          expect(result).to be_an_instance_of PG::Result
          expect(result.res_status(result.result_status)).to eq "PGRES_COMMAND_OK"
        end

        describe "populated users table" do 
          before(:each) do 
            4.times do |i|
              subject.insert(table_name, age: 20+i, name: "person_#{i}")
            end
          end

          it "#select_sql" do
            expect(subject.create_select_sql(table_name)).to eq "SELECT * FROM #{table_name}"
          end

          it "#select" do
            result = subject.select(table_name)
            expect(result).to be_an_instance_of PG::Result
            expect(result.res_status(result.result_status)).to eq "PGRES_TUPLES_OK"

            expect(result[0]['age'].to_i).to eq 20
            expect(result[0]['name']).to eq 'person_0'
            expect(result[3]['age'].to_i).to eq 23
            expect(result[3]['name']).to eq 'person_3'

            result.each do |user_hash|
              # built the class name dynamically!
              users = GA::User.new(user_hash["id"], user_hash["name"], user_hash["age"])
            end          
          end
        end
      end
    end
  end

end
