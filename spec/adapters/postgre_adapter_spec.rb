require 'spec_helper'
require 'easy_mapper/adapters/postgre_adapter'
require 'easy_mapper/model'

RSpec.describe "EasyMapper::Adapters::PostgreAdapter" do

  before(:all) do
    @adapter = EasyMapper::Adapters::PostgreAdapter.new(
      database: 'easy_mapper_test_db',
      user: 'easy_mapper_user',
      password: ''
    )
  end

  before(:each) do
    @adapter.delete("Users")
  end

  let(:record) do
    {
      id: 1,
      first_name: 'Pesho',
      last_name: 'Petrov',
      age: 20
    }
  end

  describe 'upsert' do
    it 'saves a record' do
      @adapter.upsert("Users", record, primary_keys: [:id])
      expected = [{id:1, first_name:"Pesho", last_name:"Petrov", age:20}]
      expect(@adapter.find("Users")).to eq expected
    end

    it 'updates the record if the primary key exists' do
      @adapter.upsert("Users", record, primary_keys: [:id])
      expect(@adapter.find("Users", where: {id: 1}).length).to be 1

      record[:age] = 21

      @adapter.upsert("Users", record, primary_keys: [:id])
      find_result = @adapter.find("Users", where: {id: 1})

      expect(find_result.length).to be 1
      expect(find_result.first[:age]).to eq 21
    end
  end

  describe 'delete' do
    it 'can delete a record' do
      @adapter.upsert("Users", record, primary_keys: [:id])
      find_result = @adapter.find("Users", where: {id: 1})
      expect(find_result.length).to be 1

      @adapter.delete("Users", where: {id: 1})
      find_result = @adapter.find("Users", where: {id: 1})
      expect(find_result.length).to eq 0
    end

    it 'deletes every record if no where is given' do
      @adapter.upsert("Users", record, primary_keys: [:id])
      record[:id] = 2
      @adapter.upsert("Users", record, primary_keys: [:id])

      @adapter.delete("Users")
      expect(@adapter.find("Users", where: {first_name: 'Pesho'}).length).to be 0
    end
  end

  describe 'find' do

    before(:each) do
      @adapter.upsert("Users", record, primary_keys: [:id])
      record[:id] = 2
      record[:first_name] = 'Gosho'
      record[:last_name] = 'Todorov'
      @adapter.upsert("Users", record, primary_keys: [:id])
    end

    it 'can filter by column values' do
      expect(@adapter.find("Users", where: {age: 20}).length).to be 2
    end

    it 'can order ascending' do
      result = @adapter.find("Users", order_by: {first_name: :asc})
      expect(result.first[:first_name]).to eq "Gosho"
    end

    it 'can order descending' do
      result = @adapter.find("Users", order_by: {last_name: :desc})
      expect(result.first[:last_name]).to eq "Todorov"
    end
  end
end
