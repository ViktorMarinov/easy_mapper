require 'spec_helper'
require 'easy_mapper/adapters/postgre_adapter'
require 'easy_mapper/model'

RSpec.describe "EasyMapper::Adapters::PostgreAdapter" do

  let(:adapter) do
    EasyMapper::Adapters::PostgreAdapter.new(
      database: 'easy_mapper_test_db',
      user: 'easy_mapper_user',
      password: ''
    )
  end

  describe 'upsert' do
    it 'creates a new record if the primary key does not exist' do
      record = {
        id: 1,
        first_name: 'Pesho',
        last_name: 'Petrov',
        age: 20
      }

      adapter.upsert("Users", record, primary_keys: [:id])
      result = adapter.find("Users").each do |row|
        puts row
      end
    end

    it 'updates the record if the primary key exists' do

    end
  end
end
