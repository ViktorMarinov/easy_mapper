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

  describe 'connect' do
    it 'uses the config given on creation' do
      @adapter.connect
    end
  end
end
