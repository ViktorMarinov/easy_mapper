require 'spec_helper'
require 'easy_mapper/model'

RSpec.describe EasyMapper do
  it 'has a version number' do
    expect(EasyMapper::VERSION).not_to be nil
  end

  let(:user_model) do
    Class.new do
      include EasyMapper::Model

      table_name 'Users'
      attributes :id, :first_name, :last_name, :age
      primary_keys :id
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

  it 'can save a record in the database' do
    user = user_model.new(
      id: 1,
      first_name: 'Pesho',
      last_name: 'Petrov',
      age: 17
    )

    user.save

    # TODO: search and check if the same
  end

  it 'updates the record if id already exists' do
    user = user_model.new(
      id: 1,
      first_name: 'Pesho',
      last_name: 'Petrov',
      age: 20
    )

    user.save

    # TODO: search and check if updated
  end
end
