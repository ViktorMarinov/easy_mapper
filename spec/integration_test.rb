require 'spec_helper'
require 'sqlite3'

RSpec.describe 'EasyMapper integration' do
  let(:user_model) do
    Class.new do
      include EasyMapper::Model

      attributes :first_name, :last_name, :age
    end
  end

  before(:all) do
    # TODO: auto start a test database

    EasyMapper::Config.adapter = EasyMapper::Adapters::PostgreAdapter.new(
      database: 'easy_mapper_test_db',
      user: 'easy_mapper_user',
      password: ''
    )
  end

  describe 'saves the record in the database' do
    user = user_model.new(
      first_name: 'Pesho',
      last_name: 'Petrov',
      age: 15
    )

    user.save
  end
end
