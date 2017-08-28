require 'spec_helper'
require 'easy_mapper/adapters/postgre_adapter'
require 'easy_mapper/model'

RSpec.describe 'EasyMapper::Adapters::PostgreAdapter' do
  before(:all) do
    @adapter = EasyMapper::Adapters::PostgreAdapter.new(
      database: 'easy_mapper_test_db',
      user: 'easy_mapper_user',
      password: ''
    )
  end

  let(:record) do
    {
      id: 1,
      first_name: 'Pesho',
      last_name: 'Petrov',
      age: 20
    }
  end

  describe 'connect' do
    it 'uses the config given on creation' do
      @adapter.connect
    end
  end

  describe 'execute' do
    it 'can execute a simple query' do
      result = @adapter.execute("SELECT 1,2")
      expect(result.values).to eq [[1, 2]]
    end
  end

  describe 'escape' do
    it 'escapes the string properly' do
      expect(@adapter.escape("' or ''='")).to eq "'' or ''''=''"
    end
  end
end
