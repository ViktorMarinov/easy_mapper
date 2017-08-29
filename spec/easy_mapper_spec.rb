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
    end
  end

  before(:all) do
    # TODO: auto start a test database

    EasyMapper::Config.db_adapter = EasyMapper::Adapters::PostgreAdapter.new(
      database: 'easy_mapper_test_db',
      user: 'easy_mapper_user',
      password: ''
    )
  end

  before(:each) do
    user_model.objects.delete_all
  end

  it 'can save a record in the database' do
    user = user_model.new(
      first_name: 'Pesho',
      last_name: 'Petrov',
      age: 17
    )

    user.save

    actual = user_model.objects.where(first_name: 'Pesho').exec
    expect(actual).to match_array [user]
  end

  it 'updates the record if id already exists' do
    user = user_model.new(
      first_name: 'Pesho',
      last_name: 'Petrov',
      age: 20
    )

    user.save
    user.age = 21
    user.save

    actual = user_model.objects.where(id: user.id).exec
    expect(actual).to eq [user]
  end
end
