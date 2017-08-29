require 'spec_helper'
require 'easy_mapper/adapters/postgre_adapter'
require 'easy_mapper/config'
require 'easy_mapper/db_repository'

RSpec.describe 'EasyMapper::Config' do

  let(:adapter) do
    EasyMapper::Adapters::PostgreAdapter.new(
      database: 'easy_mapper_test_db',
      user: 'easy_mapper_user',
      password: ''
    )
  end

  it 'stores the db adapter to be used' do
    EasyMapper::Config.db_adapter = adapter

    expect(EasyMapper::Config.db_adapter).to be adapter
  end
end
