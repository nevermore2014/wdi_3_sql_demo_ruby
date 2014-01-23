require_relative './spec_helper'
require_relative '../lib/manage_db'

describe GA::ManageDB do
  let(:dbname) { 'pg_direct_test'}

  it "#new" do
    expect(GA::ManageDB.new(dbname)).to be_an_instance_of GA::ManageDB
  end

  subject { GA::ManageDB.new(dbname) }

  describe "without a existing DB" do
    before(:each) do
      system("dropdb #{dbname} 2> /dev/null")
    end

    it "#drop_database" do
      expect(subject.drop_database).to eq false
    end

    it "#create_database" do
      expect(subject.create_database).to eq true
    end
  end
  describe "with an existing DB" do
    before(:each) do
      system("createdb #{dbname} 2> /dev/null")
    end

    it "#drop_database" do
      expect(subject.drop_database).to eq true
    end

    it "#create_database" do
      expect(subject.create_database).to eq false
    end

  end

end

def psql_check_db(dbname)
    %x( psql -l | grep "dkfjdk")
end
