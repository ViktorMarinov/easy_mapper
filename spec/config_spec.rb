require 'spec_helper'
require 'easy_mapper/adapters/postgre_adapter'
require 'easy_mapper/config'

RSpec.describe 'EasyMapper::Config' do
  it 'sets default adapter to be used' do
    EasyMapper::Config.adapter = EasyMapper::Adapters::PostgreAdapter.new(
      database: 'easy_mapper_test_db',
      user: 'easy_mapper_user',
      password: ''
    )
  end
end
